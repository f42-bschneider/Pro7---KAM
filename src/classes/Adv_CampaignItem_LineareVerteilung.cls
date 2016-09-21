public with sharing class Adv_CampaignItem_LineareVerteilung extends TriggerController{
	/**
	 * Constructor.
	 * @see TriggerController   The base class of trigger controller.
	 */
    public Adv_CampaignItem_LineareVerteilung(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                         List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    // before Insert
    protected override void runBeforeInsert() {
        getLinearDistributionFromCampaign((List<ADvendio__Campaign_Item__c>) lstNewItems, null);
    }

    // before Update
    protected override void runBeforeUpdate() {
        getLinearDistributionFromCampaign((List<ADvendio__Campaign_Item__c>) lstNewItems, (Map<Id, ADvendio__Campaign_Item__c>) mapOldItems);
    }

    /**
    * force campaign-items to use linear-distribution if their campaign demands for it
    * @param	a list of ADvendio__Campaign_Item__c records (trigger.new)
    * @param	a map of ADvendio__Campaign_Item__c records (trigger.oldMap)
    **/
    private void getLinearDistributionFromCampaign(List<ADvendio__Campaign_Item__c> newItems, Map<Id, ADvendio__Campaign_Item__c> oldItemMap) {
    	Map<Id, ADvendio__MediaCampaign__c> mediaCampaigns	= new Map<Id, ADvendio__MediaCampaign__c>();

    	for (ADvendio__Campaign_Item__c ci : newItems) {
    		if ((	isInsert ||
    				ci.ADvendio__LinearDistribution__c != oldItemMap.get(ci.Id).ADvendio__LinearDistribution__c)
    				&& !ci.ADvendio__LinearDistribution__c
    			) {
    			mediaCampaigns.put(ci.ADvendio__Media_Campaign__c, null);
    		}
    	}

    	if (!mediaCampaigns.isEmpty()) {
    		for (ADvendio__MediaCampaign__c mc : [SELECT Id, ADvendio__PaymentInterval__c, ADvendio__PaymentStart__c FROM ADvendio__MediaCampaign__c WHERE Id IN :mediaCampaigns.keySet()]) {
    			mediaCampaigns.put(mc.Id, mc);
    		}

    		for (ADvendio__Campaign_Item__c ci : newItems) {
    			if ((	isInsert ||
	    				ci.ADvendio__LinearDistribution__c != oldItemMap.get(ci.Id).ADvendio__LinearDistribution__c)
	    				&& !ci.ADvendio__LinearDistribution__c
	    			) {

	    			ADvendio__MediaCampaign__c mc	= mediaCampaigns.get(ci.ADvendio__Media_Campaign__c);
	    			if (Adv_MediaCampaign_LineareVerteilung.isVorkasse(mc)) {
	    				ci.ADvendio__LinearDistribution__c	= true;
	    			}
    			}
    		}
    	}
    }
}