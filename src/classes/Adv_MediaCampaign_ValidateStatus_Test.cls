@isTest
public class Adv_MediaCampaign_ValidateStatus_Test{

    public static testMethod void MediaCampaignValidateStatusTest(){

        // Create Objects
        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(true);
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(true, objMC);

        // Set Mediacampaign to Closed Won
        objMC.ADvendio__Stage__c = 'Booked';
        update objMC;
    }
    
}