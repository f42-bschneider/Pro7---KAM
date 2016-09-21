/*
Used in Trigger "Adv_OptimizingChange".

KV: 02833
Creates a record on OC, for "ADvendio__FC_Ad_served_every__c" (FC Anzahl Periode) when a record for ADvendio__FC_Period__c and ADvendio__FC_Quantity__c is created
*/
public class Adv_OptimizingChange_FC{

    public static void setFC(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){

        // TODO: in Handler auslagern?
        Set<Id> ovIdsSet = new Set<Id>();
        for (ADvendio__OptimizingChange__c oc : (List<ADvendio__OptimizingChange__c>)lstNewItems) {
            ovIdsSet.add(oc.ADvendio__OptimizingVersion__c);
        }
        // stop here if trigger context includes OptimizingChanges for more than 1 OptimizingVersion
        if (ovIdsSet.size() != 1) return;


        // Get Optimization Version
        Id optiVersionID = (ID)lstNewItems[0].get('ADvendio__OptimizingVersion__c');


        Map<ID, Map<String, ADvendio__OptimizingChange__c>> mapCIOpti = Adv_OptimizingChange_Handler.getCIOptiMapAll(lstNewItems);

        List<ADvendio__OptimizingChange__c> listNewOC = new List<ADvendio__OptimizingChange__c>();

        // Check for which OC both records exist, and put the CampaignID into a set
        for(ID identifier : mapCIOpti.keySet()){

            Map<String, ADvendio__OptimizingChange__c> mapFields = mapCIOpti.get(identifier);

            if (mapFields.containsKey('advendio__fc_ad_served_every__c') && mapFields.get('advendio__fc_ad_served_every__c').ADvendio__OptimizedValue__c == '1') continue;

            if(mapFields.containsKey('advendio__fc_period__c') && mapFields.containsKey('advendio__fc_quantity__c')){
                Id cID = mapFields.get('advendio__fc_period__c').ADvendio__CampaignItem__c;
                Id newCIIdentifier = mapFields.get('advendio__fc_period__c').ADvendio__NewCiIdentifier__c;

                if(mapFields.get('advendio__fc_period__c').ADvendio__OptimizedValue__c != null && mapFields.get('advendio__fc_quantity__c').ADvendio__OptimizedValue__c != null){
                    listNewOC.add(Adv_OptimizingChange_Handler.createOC (cID, optiVersionID, 'advendio__fc_ad_served_every__c', null, '1', newCIIdentifier));
                }
            }
        }

        if(!listNewOC.isEmpty()) insert listNewOC;
    }



    public static void deleteOCs(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        Id optiVersionID = (ID)lstNewItems[0].get('ADvendio__OptimizingVersion__c');
        
        List<ADvendio__OptimizingChange__c> listOC = new List<ADvendio__OptimizingChange__c>([SELECT ADvendio__CampaignItem__c, ADvendio__NewCiIdentifier__c, ADvendio__FieldName__c, ADvendio__OptimizedValue__c FROM ADvendio__OptimizingChange__c WHERE ADvendio__OptimizingVersion__c = :optiVersionID]);    
        Map<ID, Map<String, ADvendio__OptimizingChange__c>> mapCIOpti = Adv_OptimizingChange_Handler.getCIOptiMapAll(listOC);        

        List<ADvendio__OptimizingChange__c> listDelOCs  = new List<ADvendio__OptimizingChange__c>();
        for(ID cID : mapCIOpti.keySet()){
            if(mapCIOpti.get(cID).containsKey('advendio__fc_ad_served_every__c')){
                if(!mapCIOpti.get(cID).containsKey('advendio__fc_period__c') && !mapCIOpti.get(cID).containsKey('advendio__fc_quantity__c')){
                    listDelOCs.add(mapCIOpti.get(cID).get('advendio__fc_ad_served_every__c'));
                }
            }
        }

        if(!listDelOCs.isEmpty()) delete listDelOCs;
    }
}