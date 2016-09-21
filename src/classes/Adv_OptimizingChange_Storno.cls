/*
Used in Trigger "Adv_OptimizingChange".
Creates an Optimizing change record which sets the "Verkaufspreis" to 0, if the user chose "Storno mit Leistungsfluss" or "Kompensation"
KV 2517
*/
public class Adv_OptimizingChange_Storno{

    public static void setVKToNull(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        Id optiVersionID = (ID)lstNewItems[0].get('ADvendio__OptimizingVersion__c');
        List<ADvendio__OptimizingChange__c> listNewOC = new List<ADvendio__OptimizingChange__c>();
        
        // First check for which Campaign Item there will already one OC for the "advendio__sales_price__c"
        Set<ID> setCIWithVK = new Set<ID>();
        for(sObject o : lstNewItems){
            ADvendio__OptimizingChange__c objOC = (ADvendio__OptimizingChange__c) o;
            if(objOC.ADvendio__FieldName__c == 'advendio__sales_price__c')
                setCIWithVK.add(objOC.ADvendio__CampaignItem__c);
        }
                                                
        // Check for Which CampaignItems an Optimizing Change needs to be created
        Set<ID> setCampaignItemID = new Set<ID>();
        for(sObject o : lstNewItems){
            // For existing CIs
            ADvendio__OptimizingChange__c objOC = (ADvendio__OptimizingChange__c) o;
            if(objOC.ADvendio__FieldName__c == 'advendio__rate_discount_4_name__c' && !setCIWithVK.contains(objOC.ADvendio__CampaignItem__c))
                if(objOC.ADvendio__OptimizedValue__c == 'Storno mit Leistungsfluss' || objOC.ADvendio__OptimizedValue__c == 'Kompensation' || objOC.ADvendio__OptimizedValue__c == 'Nachlieferung')
                    setCampaignItemID.add(objOC.ADvendio__CampaignItem__c);
        }

        
        if(!setCampaignItemID.isEmpty()){
            // For existing CIs
            for(ADvendio__Campaign_Item__c o : [SELECT ADvendio__Sales_Price__c,ADvendio__SurchargeSalesPrice__c,advendio__amount_netapex__c,advendio__amount_net_netapex__c,advendio__amount_net3apex__c,advendio__amountapex__c,advendio__amount_b2apex__c,advendio__amount_b3apex__c FROM ADvendio__Campaign_Item__c WHERE ID IN :setCampaignItemID]){
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(o.ID, optiVersionID, 'advendio__sales_price__c', String.valueOf(o.ADvendio__Sales_Price__c), '0'));
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(o.ID, optiVersionID, 'advendio__amountapex__c', String.valueOf(o.advendio__amountapex__c), '0'));
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(o.ID, optiVersionID, 'advendio__amount_b2apex__c', String.valueOf(o.advendio__amount_b2apex__c), '0'));
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(o.ID, optiVersionID, 'advendio__amount_b3apex__c', String.valueOf(o.advendio__amount_b3apex__c), '0'));
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(o.ID, optiVersionID, 'advendio__amount_net3apex__c', String.valueOf(o.advendio__amount_net3apex__c), '0'));
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(o.ID, optiVersionID, 'advendio__amount_netapex__c', String.valueOf(o.advendio__amount_netapex__c), '0'));
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(o.ID, optiVersionID, 'advendio__amount_net_netapex__c', String.valueOf(o.advendio__amount_net_netapex__c), '0'));
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(o.ID, optiVersionID, 'advendio__surchargesalesprice__c', String.valueOf(o.ADvendio__SurchargeSalesPrice__c), '0'));                                                                        
            }            
    
            if(!listNewOC.isEmpty()) insert listNewOC;         
        }
    }
    
    
    /*
    KV 02517
    After OCs are inserted, check , if OCs which set the VK to 0 need to be deleted
    */
    public static void deleteOCs(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        Id optiVersionID = (ID)lstNewItems[0].get('ADvendio__OptimizingVersion__c');
        List<ADvendio__OptimizingChange__c> listOCsToDelete  = new List<ADvendio__OptimizingChange__c>();

        List<ADvendio__OptimizingChange__c> listAllOCs  = new List<ADvendio__OptimizingChange__c>([SELECT ADvendio__CampaignItem__c, ADvendio__NewCiIdentifier__c, ADvendio__FieldName__c, ADvendio__OptimizedValue__c FROM ADvendio__OptimizingChange__c WHERE ADvendio__OptimizingVersion__c = :optiVersionID AND ADvendio__NewCiIdentifier__c = null]);
        Map<ID, Map<String, ADvendio__OptimizingChange__c>>  mapCIOC = Adv_OptimizingChange_Handler.getCIOptiMap(listAllOCs);

        // For existing CIs
        for(ID cID : mapCIOC.keySet()){
            Boolean bDel = false;
            Map<String, ADvendio__OptimizingChange__c> mapFields = mapCIOC.get(cID);

            // OC which sets VK to 0 exists
            if(mapFields.containsKey('advendio__sales_price__c')){
                if(Double.valueOf(mapFields.get('advendio__sales_price__c').ADvendio__OptimizedValue__c) != 0) continue;

                    // OC with 'Kompensation' or 'Nachlieferung' does not exist 
                    if(!mapFields.containsKey('advendio__rate_discount_4_name__c')){
                        bDel = true;
                    }else if(mapFields.get('advendio__rate_discount_4_name__c').ADvendio__OptimizedValue__c != 'Kompensation' 
                            && mapFields.get('advendio__rate_discount_4_name__c').ADvendio__OptimizedValue__c != 'Nachlieferung'  
                            && mapFields.get('advendio__rate_discount_4_name__c').ADvendio__OptimizedValue__c != 'Storno mit Leistungsfluss'){
                        bDel = true;    
                    }

                    if(bDel){
                        if(mapFields.containsKey('advendio__sales_price__c')) listOCsToDelete.add(mapFields.get('advendio__sales_price__c'));
                        if(mapFields.containsKey('advendio__amountapex__c')) listOCsToDelete.add(mapFields.get('advendio__amountapex__c'));
                        if(mapFields.containsKey('advendio__amount_b2apex__c')) listOCsToDelete.add(mapFields.get('advendio__amount_b2apex__c'));
                        if(mapFields.containsKey('advendio__amount_b3apex__c')) listOCsToDelete.add(mapFields.get('advendio__amount_b3apex__c'));
                        if(mapFields.containsKey('advendio__amount_net3apex__c')) listOCsToDelete.add(mapFields.get('advendio__amount_net3apex__c'));
                        if(mapFields.containsKey('advendio__amount_netapex__c')) listOCsToDelete.add(mapFields.get('advendio__amount_netapex__c'));
                        if(mapFields.containsKey('advendio__amount_net_netapex__c')) listOCsToDelete.add(mapFields.get('advendio__amount_net_netapex__c'));
                        if(mapFields.containsKey('advendio__surchargesalesprice__c')) listOCsToDelete.add(mapFields.get('advendio__surchargesalesprice__c'));
                    }   
            }
        }
        delete listOCsToDelete;
    }
    
 
    // Similar to setVKToNull. Only for new positions. before insert
    public static void setVKToNullForNewPositions(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        Map<ID, Map<String, ADvendio__OptimizingChange__c>>  mapCIOC = Adv_OptimizingChange_Handler.getCIOptiMapNewOnly((List<ADvendio__OptimizingChange__c>) lstNewItems); 
        for(ID cID : mapCIOC.keySet()){    
            Map<String, ADvendio__OptimizingChange__c> mapFields = mapCIOC.get(cID);        
            if(mapFields.containsKey('advendio__rate_discount_4_name__c')){
                String sRateDiscount = mapFields.get('advendio__rate_discount_4_name__c').ADvendio__OptimizedValue__c;
                
                if(sRateDiscount == 'Kompensation' || sRateDiscount == 'Nachlieferung' || sRateDiscount == 'Storno mit Leistungsfluss'){
                    nullValue(mapFields, 'advendio__sales_price__c');
                    nullValue(mapFields, 'advendio__amountapex__c');                    
                    nullValue(mapFields, 'advendio__amount_b2apex__c');                    
                    nullValue(mapFields, 'advendio__amount_b3apex__c');                    
                    nullValue(mapFields, 'advendio__amount_net3apex__c');                    
                    nullValue(mapFields, 'advendio__amount_netapex__c');                    
                    nullValue(mapFields, 'advendio__amount_net_netapex__c');                                                                                                                        
                    nullValue(mapFields, 'advendio__surchargesalesprice__c');                                                                                                                                            
                }                                
            }   
        }
    }
    
    // Helper Method
    public static void nullValue(Map<String, ADvendio__OptimizingChange__c> mapFields, String sFieldName){
        if(mapFields.containsKey(sFieldName))
            mapFields.get(sFieldName).ADvendio__OptimizedValue__c = '0';
    }
}