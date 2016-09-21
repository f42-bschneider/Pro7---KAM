@isTest
private class Adv_MediaCampaign_Dienstleistung_Test {

    /*************************************
    OLD Test deactivated because of NO FUNCTIONALITY!!!
    2014-11-20 P7S1 for0001t

    CHANGES:
    Testclass functionality
    1. insert CampaignItems with SomDig_Produktion_Erforderlich__c = true and AdType "Motiverstellung"
    2. update the number of CampaignItems with both criterias
    3. check if value of rollups is copied to helper fields on update at MediaCampaign:
        SomDig_DienstleistungbezogenePositionen__c  ==> SomDig_DienstleistungbezogeneHelp__c
        SomDig_Dienstleistungspositionen__c  ==> SomDig_DienstleistungspositionenHelp__c

    *************************************/

    static testmethod void copyToHelperFieldsOnUpdate() {
        ADvendio__MediaCampaign__c mediaCampaign1 = cls_P7S1_TestData.createTestMediaCampaign(true);

        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(false);
        adType.Name = 'Motiverstellung';
        insert adType;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, adType);
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec, mediaCampaign1.ADvendio__Pricelist__r);

        ADvendio__Campaign_Item__c campaignItem1 = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign1);
        ADvendio__Campaign_Item__c campaignItem2 = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign1);
        campaignItem2.SomDig_Produktion_Erforderlich__c = true;
        ADvendio__Campaign_Item__c campaignItem3 = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign1, adPrice);

        List<ADvendio__Campaign_Item__c> cil1 = new List<ADvendio__Campaign_Item__c>{campaignItem1, campaignItem2, campaignItem3};
        insert cil1;

        ADvendio__MediaCampaign__c mediaCampaign2 = [Select id, SomDig_DienstleistungbezogenePositionen__c, SomDig_DienstleistungbezogeneHelp__c, SomDig_Dienstleistungspositionen__c, SomDig_DienstleistungspositionenHelp__c from ADvendio__MediaCampaign__c where id = :mediaCampaign1.Id];
        System.assertEquals(1, mediaCampaign2.SomDig_DienstleistungbezogenePositionen__c);
        System.assertEquals(0, mediaCampaign2.SomDig_DienstleistungbezogeneHelp__c);
        System.assertEquals(1, mediaCampaign2.SomDig_Dienstleistungspositionen__c);
        System.assertEquals(0, mediaCampaign2.SomDig_DienstleistungspositionenHelp__c);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem4 = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign1);
        ADvendio__Campaign_Item__c campaignItem5 = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign1);
        campaignItem5.SomDig_Produktion_Erforderlich__c = true;
        ADvendio__Campaign_Item__c campaignItem6 = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign1);
        campaignItem6.SomDig_Produktion_Erforderlich__c = true;
        ADvendio__Campaign_Item__c campaignItem7 = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign1, adPrice);

        List<ADvendio__Campaign_Item__c> cil2 = new List<ADvendio__Campaign_Item__c>{campaignItem4, campaignItem5, campaignItem6, campaignItem7};
        insert cil2;

        Test.stopTest();

        ADvendio__MediaCampaign__c mediaCampaign3 = [Select id, SomDig_DienstleistungbezogenePositionen__c, SomDig_DienstleistungbezogeneHelp__c, SomDig_Dienstleistungspositionen__c, SomDig_DienstleistungspositionenHelp__c from ADvendio__MediaCampaign__c where id = :mediaCampaign1.Id];
        System.assertEquals(3, mediaCampaign3.SomDig_DienstleistungbezogenePositionen__c);
        System.assertEquals(1, mediaCampaign3.SomDig_DienstleistungbezogeneHelp__c);
        System.assertEquals(2, mediaCampaign3.SomDig_Dienstleistungspositionen__c);
        System.assertEquals(1, mediaCampaign3.SomDig_DienstleistungspositionenHelp__c);
    }

}