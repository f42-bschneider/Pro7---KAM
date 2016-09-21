public with sharing class SomTv_B2BAktionsmitgliederHistory extends TriggerController {

    public SomTv_B2BAktionsmitgliederHistory(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List <sObject> lstNewItems, Map <Id, sObject> mapNewItems, List <sObject> lstOldItems, Map <Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    protected override void runAfterInsert() {
        doRollupToCampaign();
    }

    protected override void runAfterUpdate() {
        doRollupToCampaign();
        addHistory();
    }

    protected override void runAfterDelete() {
        doRollupToCampaign();
        deleteHistory();
    }

    protected override void runAfterUndelete() {
        doRollupToCampaign();
        deleteHistory();
    }

    /**
     * Add a history record when status of CampaignMember changed.
     *
     */
    private void addHistory() {
        if (isAfter && isUpdate) {
            List <SomTv_B2BAktionsmitgliederHistory__c> histories = new List <SomTv_B2BAktionsmitgliederHistory__c> ();

            for (CampaignMember cm: (List <CampaignMember> ) lstNewItems) {
                CampaignMember cm_old = mapOldItems == null ? null : (CampaignMember) mapOldItems.get(cm.Id);
                if (cm_old != null && cm_old.Status != cm.Status) {
                    SomTv_B2BAktionsmitgliederHistory__c h = new SomTv_B2BAktionsmitgliederHistory__c();
                    h.SomTv_B2BAktinsmitglied__c = cm.ContactId;
                    h.SomTv_Kampagne__c = cm.CampaignId;
                    h.SomTv_MitgliedID__c = String.valueOf(cm.Id);
                    h.SomTv_StatusAlt__c = cm_old.Status;
                    h.SomTv_StatusNeu__c = cm.Status;
                    histories.add(h);
                }
            }

            if (!histories.isEmpty()) {
                insert histories; 
            }
        }
    }

    /**
     * Delete the histories if there are.
     */
    private void deleteHistory() {
        if (isAfter && isDelete) {
            Set <Id> ids = new Set <Id> ();

            for (CampaignMember cm: (List <CampaignMember> ) lstOldItems) {
                ids.add(cm.Id);
            }

            ids.remove(null);

            if (!ids.isEmpty()) {
                for (List <SomTv_B2BAktionsmitgliederHistory__c> records: [SELECT Id FROM SomTv_B2BAktionsmitgliederHistory__c WHERE SomTv_MitgliedID__c IN: ids]) {
                    delete records;
                }
            }
        }
    }

    /**
     * Rollup some data to Campaign.
     */
    private void doRollupToCampaign() {
        // Only do rollup for after events.
        if (isBefore) {
            return;
        }

        // Get list of campaigns to update
        List <CampaignMember> listNewRecords = isDelete ? (List <CampaignMember> ) lstOldItems : (List <CampaignMember> ) lstNewItems;
        Map <Id, CampaignMember> mapOldRecords = isUpdate ? (Map <Id, CampaignMember> ) mapOldItems : null;


        // Get Campaign IDs which should be updated
        Set <ID> setCampaignIds = new Set <ID> ();
        for (CampaignMember cm: listNewRecords) {
            // if a campaign member is deleted or inserted, in everycase, do the update
            if (!isUpdate)
                setCampaignIds.add(cm.CampaignID);

            // If it is upated. Only when the status field changed
            else if (mapOldRecords.containsKey(cm.Id) && mapOldRecords.get(cm.Id).Status != cm.Status)
                setCampaignIds.add(cm.CampaignID);

            else if (mapOldRecords.containsKey(cm.Id) && mapOldRecords.get(cm.Id).SomTv_AnzahlGaeste__c != cm.SomTv_AnzahlGaeste__c)
                setCampaignIds.add(cm.CampaignID);
        }


        // Get List of Campaigns which should be updated
        List<Campaign> listCampaign = new List <Campaign> ([SELECT ID, (SELECT SomTv_AnzahlGaeste__c FROM CampaignMembers WHERE SomTv_AnzahlGaeste__c != null AND SomTv_AnzahlGaeste__c != 'Keine') FROM Campaign WHERE ID IN: setCampaignIds]);


        // Get map with field identifier and API Name, eg "absage", "SomTv_Absage__c"
        Map<String, String> mapGetFields = initMapToCompareFields('Campaign');


        // Loop through all campaigns. Set each field which can be matched with a picklist field to 0
        List<Schema.PicklistEntry> ple = CampaignMember.Status.getDescribe().getPicklistValues();
        for (Campaign c: listCampaign) {
            for (Schema.PicklistEntry f : ple) {

                String sField = prepareString(f.getValue());
                if (mapGetFields.containsKey(sField))
                    c.put(mapGetFields.get(sField), 0);
            }
        }



        // Get Campaign Members grouped by Campaign and Status
        AggregateResult[] arGroupedByStatus = [SELECT CampaignID cID, Status, COUNT(ID) number FROM CampaignMember WHERE CampaignID IN: setCampaignIds group by CampaignID, Status];

        // Write results into campaign, if field is found in the map
        for (Campaign c: listCampaign) {

            // Calculate number of statuses
            for (AggregateResult ar: arGroupedByStatus) {
                if (c.ID == String.valueOf(ar.get('cID'))) {

                    String sPLStatus = prepareString(String.valueOf(ar.get('Status')));

                    if (mapGetFields.containsKey(sPLStatus))
                        c.put(mapGetFields.get(sPLStatus), ar.get('number'));
                }
            }

            // Calculate Sum Gäste, add the values from the children
            c.SomTv_GesamteGaeste__c = 0;
            for (CampaignMember m: c.CampaignMembers)
                c.SomTv_GesamteGaeste__c += Integer.valueOf(m.SomTv_AnzahlGaeste__c);
        }


        try {
            update listCampaign;
        } catch (Exception e) {
            System.Debug('###' + e.getMessage());
        }
    }

    public String prepareString(String s) {
        // Remove unneccessary characters
        s = s.replace('ä', 'ae');
        s = s.replace('ö', 'oe');
        s = s.replace('ü', 'ue');

        s = s.replaceAll('[^a-z^A-z^0-9]', '');
        s = s.toLowerCase();

        return s;
    }

    public Map <String, String> initMapToCompareFields(String sObj) {

        // Get Fields of Object
        SObjectType objToken = Schema.getGlobalDescribe().get(sObj);
        Map <String, SObjectField> mapFields = objToken.getDescribe().fields.getMap();

        Set <String> setFields = mapFields.keySet();

        // Map identifier string with API name. eg. "absage" and "SomTv__Absage__c"
        Map <String, String> mapFieldsPrepared = new Map <String, String> ();

        for (String s: setFields) {
            SObjectField fieldToken = mapFields.get(s);
            DescribeFieldResult selectedField = fieldToken.getDescribe();

            // API Field name
            String sFieldName = selectedField.getName();

            // Take only SomTV Fied
            if (sFieldName.startsWith('SomTv_')) {
                // Remove SomeTv_ at start and __c at end and lowercase
                String sIdentifier = sFieldName.subString(6, sFieldName.length() - 3);

                // Prepare the string
                sIdentifier = prepareString(sIdentifier);

                mapFieldsPrepared.put(sIdentifier, sFieldName);
            }
        }

        return mapFieldsPrepared;
    }
}