@isTest
public class Adv_MediaCampaign_Conception_Test{

    public static testMethod void TestMediaCampaignConception(){
    
        // Create MK
        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(false);
        objMC.SomDig_SACConceptionManager__c = null;    
        insert objMC;

    }
    
}