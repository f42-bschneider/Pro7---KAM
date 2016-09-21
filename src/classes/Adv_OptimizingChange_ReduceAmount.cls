/*
Used in Trigger "Adv_OptimizingChange".
Checks if Amount was reduced, and prevents user from saving.
KV: 02452
*/
public class Adv_OptimizingChange_ReduceAmount{

    public static void checkAmountReduced(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        
        // Get CIs from OCs
        Set<ID> setCampaignItemID = new Set<ID>();
        for(sObject o : lstNewItems)
            setCampaignItemID.add((ID)o.get('ADvendio__CampaignItem__c'));
                
        Map<ID, ADvendio__Campaign_Item__c> mapCI = new Map<ID, ADvendio__Campaign_Item__c>([SELECT ADvendio__Billing_category__c, ADvendio__Delivered_Impressions__c, ADvendio__Delivered_Clicks__c FROM ADvendio__Campaign_Item__c WHERE ID IN :setCampaignItemID AND ADvendio__PacketItem__c = null]);
        
        for(sObject o : lstNewItems){
            ADvendio__OptimizingChange__c objOC = (ADvendio__OptimizingChange__c) o;

            ADvendio__Campaign_Item__c objCI = new ADvendio__Campaign_Item__c();
            if(mapCI.containsKey(objOC.ADvendio__CampaignItem__c))
                objCI = mapCI.get(objOC.ADvendio__CampaignItem__c);                                                   
    
            
            
            if(objOC.ADvendio__FieldName__c == 'advendio__quantity__c' && objCI != null  && objOC.ADvendio__NewCiIdentifier__c == null){
                
                if(objCI.ADvendio__Billing_category__c == 'CPM')
                    if(objCI.ADvendio__Delivered_Impressions__c != null)
                        if(Double.valueOf(objOC.ADvendio__OptimizedValue__c) < objCI.ADvendio__Delivered_Impressions__c)                
                            o.addError('Die Menge darf nicht unter den bereits ausgelieferten AIs liegen.');                        


                if(objCI.ADvendio__Billing_category__c == 'CPC')
                    if(objCI.ADvendio__Delivered_Clicks__c != null)
                        if(Double.valueOf(objOC.ADvendio__OptimizedValue__c) < objCI.ADvendio__Delivered_Clicks__c)                
                            o.addError('Die Menge darf nicht unter den bereits ausgelieferten AIs liegen.');                        

            }
        }                        
    }
}