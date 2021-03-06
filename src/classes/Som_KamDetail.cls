/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* Som_KamDetail
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         25-4-2016
* @description  
* @lastchange  
* @objects      
* =================================================================
*/
public without sharing class Som_KamDetail extends TriggerController {
	
    public Som_KamDetail(Boolean isAfter, Boolean isBefore,
        Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    protected override void runBeforeDelete() {
        deleteAssociatedStrategyProfileTopics((Map<Id, Som_KamDetail__c>) mapOldItems);
    }

    private static void deleteAssociatedStrategyProfileTopics(Map<Id, Som_KamDetail__c> mapOldItems){
        delete [SELECT Id FROM Som_KamStrategyProfileTopic__c WHERE Som_KamDetail__c IN :mapOldItems.keySet()];
    }

}