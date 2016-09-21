//KV 02551
public class Adv_AdSpec_MediagattungFields{

    public static void updateFields(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        
        Set<ID> setBelegungsEinheitIDs = new Set<ID>();
        for(sObject o : Trigger.new)
            setBelegungsEinheitIDs.add((ID)o.get('ADvendio__Placement__c'));
        

        Map<ID, ADvendio__Placement__c> mapPlacements = new Map<ID, ADvendio__Placement__c>([SELECT ADvendio__Site__r.SomDig_Mediagattung__r.Name, SomDig_Mediagattungssegment__r.Name FROM ADvendio__Placement__c WHERE ID IN :setBelegungsEinheitIDs]);
        
        
        Set<ID> setWerbeFormIDs = new Set<ID>();
        for(sObject o : Trigger.new)
            setWerbeFormIDs.add((ID)o.get('ADvendio__Ad_Type__c'));
        
        Map<ID, ADvendio__Ad_Type__c> mapAdTypes = new Map<ID, ADvendio__Ad_Type__c>([SELECT SomDig_MediagattungsDifferenzierung__r.Name FROM ADvendio__Ad_Type__c WHERE ID IN :setWerbeFormIDs]);
                        



        for(sObject o : Trigger.new){
            ADvendio__Ad_Specs__c objSpec = (ADvendio__Ad_Specs__c) o;
            if(mapPlacements.containsKey(objSpec.ADvendio__Placement__c)){
            
                //SomDig_Mediagattung__c            
                if(mapPlacements.get(objSpec.ADvendio__Placement__c).ADvendio__Site__r.SomDig_Mediagattung__r.Name != null)
                    objSpec.SomDig_Mediagattung__c = mapPlacements.get(objSpec.ADvendio__Placement__c).ADvendio__Site__r.SomDig_Mediagattung__r.Name;
                    
                    
                //SomDig_MediagattungsSegment__c                    
                if(mapPlacements.get(objSpec.ADvendio__Placement__c).SomDig_Mediagattungssegment__r.Name != null)
                    objSpec.SomDig_MediagattungsSegment__c = mapPlacements.get(objSpec.ADvendio__Placement__c).SomDig_Mediagattungssegment__r.Name;                    
            }
            
            
            
            // MGD: WM,WF,MGD 
            //SomDig_MediagattungsDifferenzierung__c                    
            if(mapAdTypes.containsKey(objSpec.ADvendio__Ad_Type__c)){
                if(mapAdTypes.get(objSpec.ADvendio__Ad_Type__c).SomDig_MediagattungsDifferenzierung__r.Name != null)
                      objSpec.SomDig_MediagattungsDifferenzierung__c = mapAdTypes.get(objSpec.ADvendio__Ad_Type__c).SomDig_MediagattungsDifferenzierung__r.Name;      
            
            }
        }
    }

}