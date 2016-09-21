// class for KV: 02794
// This class prevents saving when some criteria are not met.
public class Adv_MediaCampaign_ValidateStatus{

    public static void validate(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){

        if(lstNewItems.size() != 1) return;
        
        ADvendio__MediaCampaign__c objMC = (ADvendio__MediaCampaign__c) lstNewItems[0];
        ADvendio__MediaCampaign__c objMCOld = (ADvendio__MediaCampaign__c) mapOldItems.get(objMC.ID);              
        
        // If Set to Booked, (Geschlossen & Gewonnen)
        if(objMC.ADvendio__Stage__c == 'Booked' && objMCOld.ADvendio__Stage__c != 'Booked'){
            
            Boolean bAllowSaving = true;
            
            for(ADvendio__Campaign_Item__c o : [SELECT ADvendio__Media_Campaign__r.ADvendio__Pricelist__r.SomDig_AuftragstypId__r.SomDig_VerhinderungAuftragssetzung__c FROM ADvendio__Campaign_Item__c WHERE RecordType.DeveloperName != 'Packet' AND ADvendio__Media_Campaign__c = :objMC.ID AND SomDig_AdServerRelevant__c = true AND ADvendio__Ad_Id__c = null])
                if(o.ADvendio__Media_Campaign__r.ADvendio__Pricelist__r.SomDig_AuftragstypId__r.SomDig_VerhinderungAuftragssetzung__c)
                    bAllowSaving = false;

            
            if(!bAllowSaving)
                objMC.addError('Mindestens eine AdServer-Relevante Position wurde noch nicht durchgebucht.');       

        }
    }
}