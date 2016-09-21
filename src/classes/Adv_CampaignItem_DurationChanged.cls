/*
KV: 02506
Called from Trigger
When Duration Changed on Campaign Item delete open Optimizing Versions
*/
public class Adv_CampaignItem_DurationChanged {

    public static void deleteOtherOVs(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){

        // Check for which campaign Items the duration has been changed
        Set<ID> setChangedCIs = new Set<ID>();
        for(sObject o : lstNewItems){
            ADvendio__Campaign_Item__c objCI = (ADvendio__Campaign_Item__c) o;
            if(objCI.ADvendio__from_Date__c != mapOldItems.get(objCI.Id).get('ADvendio__from_Date__c') || objCI.ADvendio__until_Date__c != mapOldItems.get(objCI.Id).get('ADvendio__until_Date__c'))
                setChangedCIs.add(o.Id);
        }

        if (!setChangedCIs.isEmpty()) {
            // Get all Optimizing Changes, from same campaign and other OVs and check if there are campaign items which has been optimized.
            Set<ID> setDelOVIDs = new Set<ID>();
            for(ADvendio__OptimizingChange__c o : [SELECT ADvendio__CampaignItem__c, ADvendio__OptimizingVersion__c FROM ADvendio__OptimizingChange__c WHERE ADvendio__OptimizingVersion__r.ADvendio__DateOfActivation__c = null])
                if(setChangedCIs.contains(o.ADvendio__CampaignItem__c))
                    setDelOVIDs.add(o.ADvendio__OptimizingVersion__c);

            if (!setDelOVIDs.isEmpty()) {
                List<ADvendio__OptimizingVersion__c> listOV = new List<ADvendio__OptimizingVersion__c>([SELECT ID FROM ADvendio__OptimizingVersion__c WHERE ID IN :setDelOVIDs AND ADvendio__DateOfActivation__c = null AND SomDig_ActivationStarting__c = false]);
                delete listOV;
            }
        }

    }

}