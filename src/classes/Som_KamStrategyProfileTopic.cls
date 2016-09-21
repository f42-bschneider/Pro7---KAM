/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* Som_KamStrategyProfileTopic
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         25-4-2016
* @description  
* @lastchange  
* @objects      
* =================================================================
*/
public with sharing class Som_KamStrategyProfileTopic extends TriggerController{
	public Som_KamStrategyProfileTopic(Boolean isAfter, Boolean isBefore,
        Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    
    protected override void runAfterInsert() { 
        createStrategyProfilesForAccPlansAccDetailPlans((Map<Id, Som_KamStrategyProfileTopic__c>) mapNewItems);
    }

    
    protected override void runBeforeDelete() { 
        deleteStrategyProfilesFromAccPlansAccDetailPlans((Map<Id, Som_KamStrategyProfileTopic__c>) mapOldItems);
    }

    // after insert if Som_IsTemplate__c = true => create strategy profile topics for every account plan, account plan detail current year
    private static void createStrategyProfilesForAccPlansAccDetailPlans(Map<Id, Som_KamStrategyProfileTopic__c> mapNewItems){
        Set<Id> accPlanIds = new Set<Id>();

        List<Som_KamStrategyProfileTopic__c> newTopics = new List<Som_KamStrategyProfileTopic__c>();

        for(Som_Kam__c accPlan : [SELECT Id FROM Som_Kam__c WHERE Som_Year__c = :System.today().year()]){
            accPlanIds.add(accPlan.Id);

            for(Som_KamStrategyProfileTopic__c spt : mapNewItems.values()){
                if(spt.Som_IsTemplate__c){
                    newTopics.add(new Som_KamStrategyProfileTopic__c(Name = spt.Name, Som_isTemplate__c = false, Som_Kam__c = accPlan.Id, Som_Template__c = spt.Id));
                }                
            }
        }

        for(Som_KamDetail__c accPlanDetail : [SELECT Id FROM Som_KamDetail__c WHERE Som_Kam__c IN :accPlanIds]){
            for(Som_KamStrategyProfileTopic__c spt : mapNewItems.values()){
                if(spt.Som_IsTemplate__c){
                    newTopics.add(new Som_KamStrategyProfileTopic__c(Name = spt.Name, Som_isTemplate__c = false, Som_KamDetail__c = accPlanDetail.Id, Som_Template__c = spt.Id));
                }                
            }
        }

        insert newTopics;
    }

    // before delete if Som_IsTemplate__c = true => delete all strategy profile topcs associated to this template
    private static void deleteStrategyProfilesFromAccPlansAccDetailPlans(Map<Id, Som_KamStrategyProfileTopic__c> mapOldItems){
        Set<Id> sptIds = new Set<Id>();

        for(Som_KamStrategyProfileTopic__c spt : mapOldItems.values()){
            if(spt.Som_IsTemplate__c){
                sptIds.add(spt.Id);
            }
        }

        delete [SELECT Id FROM Som_KamStrategyProfileTopic__c WHERE Som_Template__c In :sptIds];
    }
}