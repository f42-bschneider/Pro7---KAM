/*
Used in Trigger "Adv_OptimizingChange".
Create an Optimization Change Record to negate MB3
KV: 02702
*/
public class Adv_OptimizingChange_MB3{
    
    public static void negateMB3(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        Id optiVersionID = (ID)lstNewItems[0].get('ADvendio__OptimizingVersion__c');
        List<ADvendio__OptimizingChange__c> listNewOC = new List<ADvendio__OptimizingChange__c>();
        
        // First check for which Campaign Item there will already one OC for the "advendio__sales_price__c"
        Set<ID> setCIWithB3 = new Set<ID>();
        for(sObject o : lstNewItems){
            ADvendio__OptimizingChange__c objOC = (ADvendio__OptimizingChange__c) o;
            if(objOC.ADvendio__FieldName__c == 'advendio__surchargeb3__c')
                setCIWithB3.add(objOC.ADvendio__CampaignItem__c);
        }
    
                                                
        // Check for Which CampaignItems an Optimizing Change needs to be created
        Set<ID> setCampaignItemID = new Set<ID>();
        for(sObject o : lstNewItems){
            
            // For existing CIs
            ADvendio__OptimizingChange__c objOC = (ADvendio__OptimizingChange__c) o;
            if(objOC.ADvendio__OptimizedValue__c == 'Positionsrabatt Natural' &&objOC.ADvendio__FieldName__c == 'advendio__rate_discount_4_name__c' && !setCIWithB3.contains(objOC.ADvendio__CampaignItem__c))
                    setCampaignItemID.add(objOC.ADvendio__CampaignItem__c);
            
            
            // For not existing CIs (Campaign-Identifier is filled)
            if(objOC.ADvendio__OptimizedValue__c == 'Positionsrabatt Natural' && objOC.ADvendio__NewCiIdentifier__c != null && objOC.ADvendio__FieldName__c == 'advendio__rate_discount_4_name__c'){
                ADvendio__OptimizingChange__c objNewOC = Adv_OptimizingChange_Handler.createOC(objOC.ADvendio__CampaignItem__c, optiVersionID, 'advendio__surchargeb3__c', '', '-100');
                objNewOC.ADvendio__NewCiIdentifier__c = objOC.ADvendio__NewCiIdentifier__c;
                listNewOC.add(objNewOC);
            }   
        }
      
      
        // For each campaignItem create a new OC Record        
        if(!setCampaignItemID.isEmpty()){                
            for(ADvendio__Campaign_Item__c o : [SELECT ADvendio__SurchargeB3__c FROM ADvendio__Campaign_Item__c WHERE ID IN :setCampaignItemID])
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(o.ID, optiVersionID, 'advendio__surchargeb3__c', String.valueOf(o.advendio__surchargeb3__c), '-100'));

        }
        
        if(!listNewOC.isEmpty())
            insert listNewOC;        
    }
    
    
    public static void deleteOCs(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        Id optiVersionID = (ID)lstNewItems[0].get('ADvendio__OptimizingVersion__c');
        List<ADvendio__OptimizingChange__c> listAllOCs  = new List<ADvendio__OptimizingChange__c>([SELECT ADvendio__CampaignItem__c, ADvendio__NewCiIdentifier__c, ADvendio__FieldName__c, ADvendio__OptimizedValue__c FROM ADvendio__OptimizingChange__c WHERE ADvendio__OptimizingVersion__c = :optiVersionID]);
        
        Map<ID, Map<String, ADvendio__OptimizingChange__c>>  mapCIOC = Adv_OptimizingChange_Handler.getCIOptiMapAll(listAllOCs);        
        List<ADvendio__OptimizingChange__c> listOCsToDelete  = new List<ADvendio__OptimizingChange__c>();
        
        for(ID cID : mapCIOC.keySet()){
            Boolean bDel = false;
            Map<String, ADvendio__OptimizingChange__c> mapFields = mapCIOC.get(cID);        
            
            if(mapFields.containsKey('advendio__surchargeb3__c')){
                if(mapFields.get('advendio__surchargeb3__c').ADvendio__OptimizedValue__c == '-100'){
                    if(!mapFields.containsKey('advendio__rate_discount_4_name__c'))
                        bDel = true;
                    else if(mapFields.get('advendio__rate_discount_4_name__c').ADvendio__OptimizedValue__c != 'Positionsrabatt Natural')
                        bDel = true;                
                }
            }
            
            if(bDel){
                listOCsToDelete.add(mapFields.get('advendio__surchargeb3__c'));

                if(mapFields.containsKey('advendio__amountapex__c')) listOCsToDelete.add(mapFields.get('advendio__amountapex__c'));
                if(mapFields.containsKey('advendio__amount_b2apex__c')) listOCsToDelete.add(mapFields.get('advendio__amount_b2apex__c'));
                if(mapFields.containsKey('advendio__amount_net3apex__c')) listOCsToDelete.add(mapFields.get('advendio__amount_net3apex__c'));
                if(mapFields.containsKey('advendio__amount_netapex__c')) listOCsToDelete.add(mapFields.get('advendio__amount_netapex__c'));
                if(mapFields.containsKey('advendio__amount_net_netapex__c')) listOCsToDelete.add(mapFields.get('advendio__amount_net_netapex__c'));
            }
        }    
        
        if(!listOCsToDelete.isEmpty())    
            delete listOCsToDelete;
    }
}