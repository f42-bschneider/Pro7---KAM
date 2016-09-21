/*
KV 02453.
Called when the user presses the "X" on the optimization and a cancelled Position is created.
*/
public class Adv_OptimizingChange_Cancel{
    public static void cancelPosition(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){

        // Get Optimization Version
        Id optiVersionID = (ID)lstNewItems[0].get('ADvendio__OptimizingVersion__c');
        
        // Map CampaignItemID with Map of Fieldname & Optimizing change
        Map<ID, Map<String, ADvendio__OptimizingChange__c>> mapCIOpti = Adv_OptimizingChange_Handler.getCIOptiMap((List<ADvendio__OptimizingChange__c>) lstNewItems);
                
        
        // Get Positions where the "X" was pressed
        Set<ID> setCancelledPositions = new Set<ID>();
        for(ID cID : mapCIOpti.keySet()){
             Map<String, ADvendio__OptimizingChange__c> mapFields = mapCIOpti.get(cID);  
             
             if(mapFields.containsKey('advendio__billingstatus__c'))
                 if(mapFields.get('advendio__billingstatus__c').ADvendio__OptimizedValue__c == 'canceled')
                     setCancelledPositions.add(cID);
        }        


        // For those which are cancelled create a "Storno ohne Leistungsfluss" OC    
        if(!setCancelledPositions.isEmpty()){
        
            List<ADvendio__OptimizingChange__c> listNewOC = new List<ADvendio__OptimizingChange__c>();
            Map<ID, ADvendio__Campaign_Item__c> mapCI = new Map<ID, ADvendio__Campaign_Item__c>([SELECT advendio__rate_discount_4_name__c FROM ADvendio__Campaign_Item__c WHERE ID IN :setCancelledPositions]);                

            for(ID cID : setCancelledPositions)
                listNewOC.add(Adv_OptimizingChange_Handler.createOC(cID, optiVersionID, 'advendio__rate_discount_4_name__c', String.valueOf(mapCI.get(cID).advendio__rate_discount_4_name__c), 'Storno ohne Leistungsfluss'));                     

            insert listNewOC;
        }            
    }
}