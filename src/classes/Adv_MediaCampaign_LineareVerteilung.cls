public with sharing class Adv_MediaCampaign_LineareVerteilung extends TriggerController {

	/**
	 * Constructor.
	 * @see TriggerController   The base class of trigger controller.
	 */
    public Adv_MediaCampaign_LineareVerteilung(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                         List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    // before Update
    protected override void runAfterUpdate() {
       setCampaignItemLinearDistribution((List<Advendio__MediaCampaign__c>) lstNewItems, (Map<Id, Advendio__MediaCampaign__c>) mapOldItems);
    }

    /**
    * force campaign-items to use linear-distribution if their campaign demands for it
    * @param	a list of Advendio__MediaCampaign__c records (trigger.new)
    * @param	a map of Advendio__MediaCampaign__c records (trigger.oldMap)
    **/
    private void setCampaignItemLinearDistribution(List<Advendio__MediaCampaign__c> newCampaigns, Map<Id, Advendio__MediaCampaign__c> oldCampaignMap) {
    	Map<Id, ADvendio__MediaCampaign__c> mediaCampaigns	= new Map<Id, ADvendio__MediaCampaign__c>();

    	for (Advendio__MediaCampaign__c mc : newCampaigns) {
    		if (isVorkasse(mc) && !isVorkasse(oldCampaignMap.get(mc.Id))) {
    			mediaCampaigns.put(mc.Id, mc);
    		}
    	}

    	if (!mediaCampaigns.isEmpty()) {
    		List<ADvendio__Campaign_Item__c> campaignItemsToUpdate	= new List<ADvendio__Campaign_Item__c>();
    		for (ADvendio__Campaign_Item__c ci : [SELECT Id, ADvendio__LinearDistribution__c, ADvendio__Media_Campaign__c FROM ADvendio__Campaign_Item__c WHERE ADvendio__Media_Campaign__c IN :mediaCampaigns.keySet() AND ADvendio__LinearDistribution__c = false]) {
    			campaignItemsToUpdate.add(new ADvendio__Campaign_Item__c(Id=ci.Id, ADvendio__LinearDistribution__c=true));
    		}

    		if (!campaignItemsToUpdate.isEmpty()) {
    			update campaignItemsToUpdate;
    		}
    	}
    }

    public static Boolean isVorkasse(Advendio__MediaCampaign__c mc) {
    	if ('before / during Billingperiod'.equals(mc.ADvendio__PaymentStart__c) && 'total account (one Invoice)'.equals(mc.ADvendio__PaymentInterval__c)) {
    		return true;
    	}
    	return false;
    }
}