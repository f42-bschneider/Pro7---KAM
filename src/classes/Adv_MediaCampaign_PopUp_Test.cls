@isTest
private with sharing class Adv_MediaCampaign_PopUp_Test {

    static testmethod void testMedia() {
        ADvendio__Campaign_Item__c ci1 = cls_P7S1_TestData.createTestCampaignItem(true);
        ADvendio__MediaCampaign__c I_otestMediaCampaign = cls_P7S1_TestData.MediaCampaign_TestData;

        Test.startTest();

        ApexPages.StandardController I_osc = new ApexPages.StandardController(I_otestMediaCampaign);
        Adv_MediaCampaign_PopUp I_oMCC = new Adv_MediaCampaign_PopUp(I_osc);

        ADvendio__MediaCampaign__c I_otestMediaCampaign1 = cls_P7S1_TestData.createTestMediaCampaign(false);
        I_otestMediaCampaign.ADvendio__Stage__c = 'Booked';
        I_otestMediaCampaign1.SomDig_DienstleistungbezogeneHelp__c = 0;
        I_otestMediaCampaign1.SomDig_DienstleistungspositionenHelp__c = 0;
        insert I_otestMediaCampaign1;

        ApexPages.StandardController I_osc1 = new ApexPages.StandardController(I_otestMediaCampaign1);
        Adv_MediaCampaign_PopUp I_oMCC1 = new Adv_MediaCampaign_PopUp(I_osc1);

        Test.stopTest();
    }

}