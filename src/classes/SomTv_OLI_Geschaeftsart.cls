public with sharing class SomTv_OLI_Geschaeftsart {

    /*
     * Method is called in Opportunity trigger
     *
     * Find relevant OLIs based on two different scenarios:
     * - the opp's SomTv_MutterOpportunity__c has changed, i.e. the opp was added to or removed from a mother-child-opp relationship
     * - the opp's RecordType has changed, i.e. the mother-opp has been changed
     *
     * Then run update_Geschaeftsart to update the OLIs' SomTv_Geschaeftsart__c field
     */
    public static void updateOpportunityLineItems(Map<Id, Opportunity> mapNewOpps, Map<Id, Opportunity> mapOldOpps) {
        Set<Id> setOppIdsWithChangedMotherOpp = new Set<Id>();
        Set<Id> setOppIdsWithChangedRecordType = new Set<Id>();
        List<OpportunityLineItem> listOLIs = new List<OpportunityLineItem>();

        for (Opportunity opp : mapNewOpps.values()){
            Opportunity oldOpp = mapOldOpps.get(opp.Id);

            if (oldOpp.SomTv_MutterOpportunity__c != opp.SomTv_MutterOpportunity__c)
                setOppIdsWithChangedMotherOpp.add(opp.Id);

            if (oldOpp.RecordTypeId != opp.RecordTypeId)
                setOppIdsWithChangedRecordType.add(opp.Id);
        }

        if (!setOppIdsWithChangedMotherOpp.isEmpty()) {
            listOLIs = [
                SELECT Id, OpportunityId, Product2Id, SomTv_Geschaeftsart__c
                  FROM OpportunityLineItem
                 WHERE OpportunityId IN :setOppIdsWithChangedMotherOpp
            ];
        }

        if (!setOppIdsWithChangedRecordType.isEmpty()) {
            listOLIs = [
                SELECT Id, OpportunityId, Product2Id, SomTv_Geschaeftsart__c
                  FROM OpportunityLineItem
                 WHERE Opportunity.SomTv_MutterOpportunity__c IN :setOppIdsWithChangedRecordType
            ];
        }

        if (!listOLIs.isEmpty()) {
            updateGeschaeftsart(listOLIs);
            update listOLIs;
        }
    }


    /*
    * Method is called in OpportunityLineItem trigger
     *
     * Filter OLIs which already have a SomTv_Geschaeftsart__c (set via Workflow field update)
     * and run the update_Geschaeftsart logic
     */
    public static void filterAndUpdate(List<OpportunityLineItem> list_new_OLIs) {
        List<OpportunityLineItem> listChangesOLIs = new List<OpportunityLineItem>();

        for (OpportunityLineItem oli : list_new_OLIs) {
            if (oli.SomTv_Geschaeftsart__c == null)
                listChangesOLIs.add(oli);
        }

        if (!listChangesOLIs.isEmpty()) {
            updateGeschaeftsart(listChangesOLIs);
        }
    }


    /*
     * Receive a list of OLIs and find the correct SomTv_Geschaeftsart__c
     * Depends on the opp's sphere and whether the opp has a SomTv_MutterOpportunity__r of record type 'SomTv_Commitment' or 'SomTv_Zubuchung'
     */
    static void updateGeschaeftsart(List<OpportunityLineItem> listOLIs) {
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<Id> setProduct2Ids = new Set<Id>();

        for (OpportunityLineItem oli : listOLIs) {
            setOpportunityIds.add(oli.OpportunityId);
            setProduct2Ids.add(oli.Product2Id);
        }

        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([
            SELECT Id, P7S1_Sphere__c, SomTv_MutterOpportunity__r.RecordType.DeveloperName
            FROM Opportunity
            WHERE Id IN :setOpportunityIds
        ]);
        Map<Id, Product2> mapProduct2s = new Map<Id, Product2>([
            SELECT Id, SomTv_GAinnerhalbCommitment__c, SomTv_GAausserhalbCommitment__c
            FROM Product2
            WHERE Id IN :setProduct2Ids
        ]);

        for (OpportunityLineItem oli : listOLIs) {
            Opportunity opp = mapOpportunities.get(oli.OpportunityId);
            Product2 product2 = mapProduct2s.get(oli.Product2Id);

            if (opp != null && product2 != null && (opp.P7S1_Sphere__c == 'SomDe' || opp.P7S1_Sphere__c == 'SomAt')) {
                String motherRecordType = opp.SomTv_MutterOpportunity__r.RecordType.DeveloperName;

                if (motherRecordType == 'SomTv_Commitment' || motherRecordType == 'SomTv_Zubuchung') {
                    oli.SomTv_Geschaeftsart__c = product2.SomTv_GAinnerhalbCommitment__c;
                } else {
                    oli.SomTv_Geschaeftsart__c = product2.SomTv_GAausserhalbCommitment__c;
                }
            }
        }
    }


}