@isTest
public class Adv_MediaCampaign_Storno_Test{

    public static testMethod void MediaCampaignStornoTest(){

        // Create Objects
        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(true);
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(false, objMC);
        
        // Set Date in Future
        objCI.ADvendio__from_Date__c = System.today().addDays(30);
        objCI.ADvendio__until_Date__c = System.today().addDays(30);        
        insert objCI;

        // Set Mediacampaign to Storno
        objMC.ADvendio__Reason_for_refusal__c = 'Cancellation';
        objMC.ADvendio__Stage__c = 'Offer denied';
        update objMC;
    }
    
}