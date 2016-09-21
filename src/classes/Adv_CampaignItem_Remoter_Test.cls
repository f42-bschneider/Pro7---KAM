@isTest
public class Adv_CampaignItem_Remoter_Test{

    public static testMethod void CampaignItemRemoterTest(){
        
        // Create Objects
        SomDig_Auftragstyp__c objAT = cls_P7S1_TestData.createTestAuftragstyp(false, 'Test');
        objAT.SomDig_Verfuegbarkeitsrelevant__c = true;
        insert objAT;
        
        
        ADvendio__Pricelist__c objPL = cls_P7S1_TestData.createTestPricelist(true, objAT);
        
        
        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(false);
        objMC.ADvendio__Pricelist__c = objPL.ID;
        insert objMC;
        
        
        // Campaign Item
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(false, objMC);
        objCI.ADvendio__LastAvailabilityForecast__c = System.now();
        insert objCI;
        
        objCI.ADvendio__until_Date__c = objCI.ADvendio__until_Date__c.addDays(2);
        objCI.ADvendio__from_Date__c = objCI.ADvendio__from_Date__c.addDays(1);
        update objCI;
        
        objCI.ADvendio__Availability__c = 1;        
        update objCI;        
        
        
        
        // Call Method
        Adv_CampaignItem_Remoter.checkAvailability(objCI.ID);
    }
}