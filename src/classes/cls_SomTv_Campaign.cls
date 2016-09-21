/**
 *  The trigger controller class for sObject Campaign.
 */
public without sharing class cls_SomTv_Campaign extends TriggerController {
    /**
     * Constructor.
     * @see TriggerController   The base class of trigger controller.
     */
    public cls_SomTv_Campaign(Boolean isAfter, Boolean isBefore,
            Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    /**
     * Override method to perform action after an insert operation was fired.
     * @see TriggerController#runAfterInsert
     */
    protected override void runAfterInsert() {
        checkParentCampaign();
        prefillCampaignMemberStatus();
    }

    /**
     * Override method to perform action after an update operation was fired.
     * @see TriggerController#runAfterUpdate
     */
    protected override void runAfterUpdate() {
        checkParentCampaign();
    }

    /**
     * Override method to perform action after a delete operation was fired.
     * @see TriggerController#runAfterDelete
     */
    protected override void runAfterDelete() {
        checkParentCampaign();
    }

    /**
     * Override method to perform action after an undelete operation was fired.
     * @see TriggerController#runAfterUndelete
     */
    protected override void runAfterUndelete() {
        checkParentCampaign();
    }

    /**
     * Check whether there is a parent campaign and update the parent-campaign's SomTv_UhrzeitStart__c and SomTv_UhrzeitEnde__c.
     *
     */
    private void checkParentCampaign() {
        List<Campaign> lstRecords = null;

        if (isAfter && (isInsert || isUpdate || isUndelete)) {
            lstRecords = (List<Campaign>)lstNewItems;
        } else if (isAfter && isDelete) {
            lstRecords = (List<Campaign>)lstOldItems;
        }

        if (lstRecords == null || lstRecords.isEmpty()) return;


        Set<Id> parentIds = new Set<Id>();

        Map<Id, RecordType> mRecordTypes = new Map<Id, RecordType> ([SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Campaign']);

        for (Campaign cam : lstRecords) {
            if (mRecordTypes.containsKey(cam.RecordTypeId)) {
                if ('SomTv_Event'.equals(mRecordTypes.get(cam.RecordTypeId).DeveloperName) ||
                    'SomTv_Mailing'.equals(mRecordTypes.get(cam.RecordTypeId).DeveloperName) ||
                    'SomTv_Medien'.equals(mRecordTypes.get(cam.RecordTypeId).DeveloperName))
                {
                    // Only SomTV.
                    if (isInsert || isDelete || isUndelete) {
                        parentIds.add(cam.ParentId);
                    } else if (isUpdate) {
                        Campaign cam_old = mapOldItems == null ? null : (Campaign)mapOldItems.get(cam.Id);
                        if (cam_old != null) {
                            if (cam.ParentId != cam_old.ParentId) {
                                parentIds.add(cam.ParentId);
                                parentIds.add(cam_old.ParentId);
                            } else if (cam.SomTv_UhrzeitStart__c != cam_old.SomTv_UhrzeitStart__c || cam.SomTv_UhrzeitEnde__c != cam_old.SomTv_UhrzeitEnde__c) {
                                parentIds.add(cam.ParentId);
                            }
                        }
                    }
                }
            }
        }

        parentIds.remove(null);

        if (!parentIds.isEmpty()) {
            Map<Id, Campaign> mParents = new Map<Id, Campaign>([SELECT Id, SomTv_UhrzeitStart__c, SomTv_UhrzeitEnde__c FROM Campaign WHERE Id IN :parentIds]);

            for (Campaign cam : mParents.values()) {
                cam.SomTv_UhrzeitStart__c = null;
                cam.SomTv_UhrzeitEnde__c  = null;
            }

            String query = 'SELECT ParentId, MIN(SomTv_UhrzeitStart__c) StartDate, MAX(SomTv_UhrzeitEnde__c) EndDate FROM Campaign '
                         + 'WHERE isDeleted = false AND SomTv_UhrzeitStart__c != null AND SomTv_UhrzeitEnde__c != null AND ParentId IN :parentIds '
                         + 'GROUP BY ParentId';

            for (AggregateResult res : Database.query(query)) {
                System.debug('\n\nAggregateResult: ' + res);
                Campaign cam =  mParents.get((Id)res.get('ParentId'));
                if (cam != null) {
                    cam.SomTv_UhrzeitStart__c = (DateTime)res.get('StartDate');
                    cam.SomTv_UhrzeitEnde__c  = (DateTime)res.get('EndDate');
                }
            }

            update mParents.values();
        }

    }

    /**
     * Fill CampaignMemberStatus for Campaigns.
     *
     */
    private void prefillCampaignMemberStatus() {

        // Only for after insert!
        if (isAfter && isInsert) {

            // Get RecordTypes
            Map<Id, RecordType> mRecordTypes = new Map<Id, RecordType> ([SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Campaign']);

            List<P7S1_CampaignMemberStatusDefaultValues__c> listDefaults = new List<P7S1_CampaignMemberStatusDefaultValues__c>([SELECT Name, SomTv_Event__c, SomTv_Mailing__c, SomTv_Medien__c FROM P7S1_CampaignMemberStatusDefaultValues__c]);
            List<CampaignMemberStatus>  lstCMS = new List<CampaignMemberStatus>();


            Integer iSortOrder = 3;
            for (Campaign c : (List<Campaign>)lstNewItems) {

                if (mRecordTypes.containsKey(c.RecordTypeId)) {

                    String sRCName = mRecordTypes.get(c.RecordTypeId).DeveloperName;

                    // Only continue if the campaign is one of these record Types
                    for(P7S1_CampaignMemberStatusDefaultValues__c cms : listDefaults) {
                        if(cms.SomTv_Event__c && sRCName == 'SomTv_Event' ||
                           cms.SomTv_Mailing__c && sRCName == 'SomTv_Mailing' ||
                           cms.SomTv_Medien__c && sRCName == 'SomTv_Medien') {

                           lstCMS.add(new CampaignMemberStatus(CampaignId = c.ID, Label=cms.Name, SortOrder=iSortOrder, IsDefault=false, HasResponded=false));
                           iSortOrder++;
                        }
                    }
                    iSortOrder = 3;
                }
            }

            if (!lstCMS.isEmpty()){
                try{            
                    Database.insert(lstCMS, false);
                    insert lstCMS;
                }catch(Exception e){
                    System.Debug('###' + e.getMessage());
                }
            }
        }
    }

    /**
     * Sum the SomTv_MN3__c of all Opportunities with RecordType 'SomTv_SalesPush' for given Campaigns.
     * update then SomTv_OpportunitiesMN3Gesamt__c and SomTv_OpportunitiesMN3Gewonnen__c of Campaigns respectively.
     *
     * @param campaignIds   Id of Campaigns to check.
     */
    public static void updateMN3OfCampaignByIds(Set<Id> campaignIds) {
        if (campaignIds != null) {
            campaignIds.remove(null);

            if (!campaignIds.isEmpty()) {
                List<String> recordTypes = new List<String> { 'SomTv_Commitment', 'SomTv_Paket', 'SomTv_Zubuchung', 'SomTv_BuchungenOhneVertraege', 'SomTv_SalesPush' };
                for (List<Campaign> campaigns : [SELECT Id, SomTv_OpportunitiesMN3Gesamt__c, SomTv_OpportunitiesMN3Gewonnen__c,
                                                 (SELECT Probability, StageName, SomTv_MN3__c FROM Opportunities WHERE IsDeleted=false AND RecordType.DeveloperName IN :recordTypes)
                                                 FROM Campaign
                                                 WHERE Id IN :campaignIds ])
                {
                    for (Campaign cam : campaigns) {
                        cam.SomTv_OpportunitiesMN3Gesamt__c = 0;
                        cam.SomTv_OpportunitiesMN3Gewonnen__c = 0;
                        for (Opportunity opp : cam.Opportunities) {
                            cam.SomTv_OpportunitiesMN3Gesamt__c += (opp.SomTV_MN3__c == null ? 0 : opp.SomTV_MN3__c);
                            if ('Geschlossene und gewonnene'.equals(opp.StageName)) {
                                cam.SomTv_OpportunitiesMN3Gewonnen__c += (opp.SomTV_MN3__c == null ? 0 : opp.SomTV_MN3__c);
                            }
                        }
                    }
                    update campaigns;
                }
            }
        }
    }
}