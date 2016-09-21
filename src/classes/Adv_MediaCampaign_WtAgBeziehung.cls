public with sharing class Adv_MediaCampaign_WtAgBeziehung extends TriggerController {

    // Constructor
    public Adv_MediaCampaign_WtAgBeziehung(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                           List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    protected override void runBeforeInsert() {
        copyCustomAccountLockupsToADvendioAccountLookups((List<ADvendio__MediaCampaign__c>) lstNewItems, NULL);
    }

    protected override void runBeforeUpdate() {
        copyCustomAccountLockupsToADvendioAccountLookups((List<ADvendio__MediaCampaign__c>) lstNewItems, (Map<Id, ADvendio__MediaCampaign__c>) mapOldItems);
    }

    private void copyCustomAccountLockupsToADvendioAccountLookups(List<ADvendio__MediaCampaign__c> l_oListNewMediaCampaigns, Map<Id, ADvendio__MediaCampaign__c> l_oMapOldMediaCampaigns) {
        Map<Id, SomDig_WtAgBeziehung__c> l_oMapWtAgBeziehungen = new Map<Id, SomDig_WtAgBeziehung__c>();


        for (ADvendio__MediaCampaign__c l_oMediaCampaign : l_oListNewMediaCampaigns) {
            // Only copy WT and AG lookups from SomDig_WtAgBeziehung__c if
            // - the MediaCampaign is of RecordType 'Angebot' AND either
            //   - the MediaCampaign is inserted (i.e. l_oMapOldMediaCampaigns is NULL)
            //   - OR the MediaCampaign's lookup to SomDig_WtAgBeziehung__c has changed

            if (l_oMapOldMediaCampaigns == NULL || l_oMediaCampaign.SomDig_WtAgBeziehung__c != l_oMapOldMediaCampaigns.get(l_oMediaCampaign.Id).SomDig_WtAgBeziehung__c) 
                l_oMapWtAgBeziehungen.put(l_oMediaCampaign.SomDig_WtAgBeziehung__c, null);

        }

        if (!l_oMapWtAgBeziehungen.isEmpty()) {
            for (SomDig_WtAgBeziehung__c l_oWtAgBeziehung : [SELECT Id, SomDig_Werbetreibender__c, SomDig_Agentur__c
                                                               FROM SomDig_WtAgBeziehung__c
                                                              WHERE Id IN :l_oMapWtAgBeziehungen.keySet()]) {

                l_oMapWtAgBeziehungen.put(l_oWtAgBeziehung.Id, l_oWtAgBeziehung);
            }

            for (ADvendio__MediaCampaign__c l_oMediaCampaign : l_oListNewMediaCampaigns) {
                if (l_oMediaCampaign.SomDig_WtAgBeziehung__c != null) {
                    SomDig_WtAgBeziehung__c l_oWtAgBeziehung = l_oMapWtAgBeziehungen.get(l_oMediaCampaign.SomDig_WtAgBeziehung__c);
                    l_oMediaCampaign.ADvendio__Account__c = l_oWtAgBeziehung.SomDig_Werbetreibender__c;
                    l_oMediaCampaign.ADvendio__Agency__c = l_oWtAgBeziehung.SomDig_Agentur__c;
                } else {
                    l_oMediaCampaign.ADvendio__Account__c = null;
                    l_oMediaCampaign.ADvendio__Agency__c = null;
                }
            }
        }
    }

}