// KV 01371 && 02491
// 01371: When Optimizing Version is activated write "now()" into "SomDig_LastOptimizationActivationDate" on the Campaign Items

public class Adv_OptimizingVersion_Activate{

    // When Optimizing Version developed, delete the other Optimizing Versions 
    //under the campaign, where the camopaign items from the activated Optimizing Version are also used
    // developed for 02491
    public static void activated(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        
        // Only one OV can be activated at the time                                        
        if(lstNewItems.size() != 1) return;       
        
        ADvendio__OptimizingVersion__c objOV = (ADvendio__OptimizingVersion__c) lstNewItems[0];
        
        if(objOV.ADvendio__DateOfActivation__c != null && lstOldItems[0].get('ADvendio__DateOfActivation__c') == null){
        
            // set of used campaign items in this ov
            Set<ID> setOptimizedCI = new Set<ID>();
            for(ADvendio__OptimizingChange__c o : [SELECT ADvendio__CampaignItem__c FROM ADvendio__OptimizingChange__c WHERE ADvendio__OptimizingVersion__c = :objOV.ID])
                setOptimizedCI.add(o.ADvendio__CampaignItem__c);
                
                
                
            // This part for 01371. Update Campaign Items
            List<ADvendio__Campaign_Item__c> listCI = new List<ADvendio__Campaign_Item__c>([SELECT CreatedDate FROM ADvendio__Campaign_Item__c WHERE ADvendio__Media_Campaign__c = :objOV.ADvendio__MediaCampaign__c]);
            for( ADvendio__Campaign_Item__c o : listCI){ 
                if(setOptimizedCI.contains(o.ID) || (o.CreatedDate < System.now() && o.CreatedDate > System.now().addSeconds(-5)) )
                    o.SomDig_LastOptimizationActivationDate__c = System.now();
            }

            update listCI;        
            // 01371 END        
            
            
            // Get all Optimizing Changes, from same campaign and other OVs and check if there are campaign items which has been optimized.
            Set<ID> setDelOVIDs = new Set<ID>();             
            for(ADvendio__OptimizingChange__c o : [SELECT ADvendio__CampaignItem__c, ADvendio__OptimizingVersion__c FROM ADvendio__OptimizingChange__c WHERE ADvendio__OptimizingVersion__c != :objOV.ID AND ADvendio__OptimizingVersion__r.ADvendio__MediaCampaign__c = :objOV.ADvendio__MediaCampaign__c  AND ADvendio__OptimizingVersion__r.ADvendio__DateOfActivation__c = null])
                if(setOptimizedCI.contains(o.ADvendio__CampaignItem__c))
                    setDelOVIDs.add(o.ADvendio__OptimizingVersion__c);
            
            
            List<ADvendio__OptimizingVersion__c> listOV = new List<ADvendio__OptimizingVersion__c>([SELECT ID FROM ADvendio__OptimizingVersion__c WHERE ID IN :setDelOVIDs AND ADvendio__DateOfActivation__c = null AND ID != :objOV.ID]);
            delete listOV;
        }
    }
}