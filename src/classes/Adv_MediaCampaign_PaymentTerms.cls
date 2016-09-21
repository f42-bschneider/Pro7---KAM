public with sharing class Adv_MediaCampaign_PaymentTerms extends TriggerController {

    public Adv_MediaCampaign_PaymentTerms(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                          List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    protected override void runBeforeInsert() {
        inheritPaymentTerms((List<ADvendio__MediaCampaign__c>)lstNewItems);
    }

    protected override void runBeforeUpdate() {
        inheritPaymentTerms((List<ADvendio__MediaCampaign__c>)lstNewItems);
    }


    /*
     * Initialize a static variable for the default SomDig_Zahlungsbedingung__c
     */
    private static SomDig_Zahlungsbedingung__c[] defaultPaymentTerms {
        get {
            if (defaultPaymentTerms == null) {
                defaultPaymentTerms = [Select Id FROM SomDig_Zahlungsbedingung__c WHERE SomDig_SAPCode__c = 'ZB01'];
            }
            return defaultPaymentTerms;
        }
        set;
    }

    /*
     * Set the default SomDig_Zahlungsbedingung__c for all MediaCampaigns in the trigger context
     */
    private void inheritPaymentTerms(List<ADvendio__MediaCampaign__c> lstNewRecords) {
        if (!defaultPaymentTerms.isEmpty()) {
            for (ADvendio__MediaCampaign__c mc : lstNewRecords) {
                if (mc.SomDig_Zahlungsbedingung__c == null) {
                    mc.SomDig_Zahlungsbedingung__c = defaultPaymentTerms[0].Id;
                }
            }
        }
    }

}