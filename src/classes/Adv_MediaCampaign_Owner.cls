public with sharing class Adv_MediaCampaign_Owner extends TriggerController {

    public Adv_MediaCampaign_Owner(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                   List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    // before Insert
    protected override void runBeforeInsert() {
        assignOwner((List<ADvendio__MediaCampaign__c>) lstNewItems, null);
    }

    // before Update
    protected override void runBeforeUpdate() {
        assignOwner((List<ADvendio__MediaCampaign__c>) lstNewItems, (Map<Id, ADvendio__MediaCampaign__c>) mapOldItems);
    }

    /**
     * Assign the own of Media Campaign to the proper person if required.
     *
     * @param   lstNewMediaCampaigns    A list of ADvendio__MediaCampaign__c to check.
     * @param   mapOldMediaCampaigns    A map contains ADvendio__MediaCampaign__c with old value for comparison. Key is Id of ADvendio__MediaCampaign__c, value is ADvendio__MediaCampaign__c.
     */
    private void assignOwner(List<ADvendio__MediaCampaign__c> lstNewMediaCampaigns, Map<Id, ADvendio__MediaCampaign__c> mapOldMediaCampaigns) {
        // This is designed for "before events".
        for (ADvendio__MediaCampaign__c opp : lstNewMediaCampaigns) {
            if (mapOldMediaCampaigns == null ||
                mapOldMediaCampaigns.get(opp.Id).ADvendio__Stage__c != opp.ADvendio__Stage__c ||
                mapOldMediaCampaigns.get(opp.Id).ADvendio__Propability__c != opp.ADvendio__Propability__c ||
                mapOldMediaCampaigns.get(opp.Id).OwnerId != opp.OwnerId ||
                mapOldMediaCampaigns.get(opp.Id).OwnerId != opp.SomDig_BetreuerSales__c ||
                mapOldMediaCampaigns.get(opp.Id).OwnerId != opp.SomDig_BetreuerPam__c) {

                if (opp.ADvendio__Stage__c != null &&
                    (opp.ADvendio__Stage__c == 'Booked' || opp.ADvendio__Stage__c == 'IO received' || opp.ADvendio__Stage__c.contains('(100%)'))) {
                    if (opp.SomDig_BetreuerPam__c != null) {
                        opp.OwnerId = opp.SomDig_BetreuerPam__c;
                    }/* else {
                        opp.SomDig_BetreuerPam__c.addError('Kein Betreuer PAM definiert!');
                    }*/
                } else {
                    if (opp.SomDig_BetreuerSales__c != null) {
                        opp.OwnerId = opp.SomDig_BetreuerSales__c;
                    }/* else {
                        opp.SomDig_BetreuerSales__c.addError('Kein Betreuer Sales definiert!');
                    }*/
                }
            }
        }

    }
}