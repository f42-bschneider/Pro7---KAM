public with sharing class Adv_MediaCampaign_Dienstleistung {

    public static void handlePopUpFieldsBeforeUpdate(List<ADvendio__MediaCampaign__c> newList, Map<Id, ADvendio__MediaCampaign__c> oldMap){
       for (ADvendio__MediaCampaign__c I_oMC : newList) {
           I_oMC.SomDig_DienstleistungbezogeneHelp__c = oldMap.get(I_oMC.Id).SomDig_DienstleistungbezogenePositionen__c;
           I_oMC.SomDig_DienstleistungspositionenHelp__c = oldMap.get(I_oMC.Id).SomDig_Dienstleistungspositionen__c;
       }
    }
}