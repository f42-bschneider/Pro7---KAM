@isTest
public with sharing class Adv_MediaCampaign_Status_Test {

    // TODO: write REAL tests

    static testMethod void testMediaCampaignStatusUpdate() {
        ADvendio__Campaign_Item__c l_oCampaignItem1 = cls_P7S1_TestData.createTestCampaignItem(false);

        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.MediaCampaign_TestData;

        ADvendio__Campaign_Item__c l_oCampaignItem2 = cls_P7S1_TestData.createTestCampaignItem(false, l_oMediaCampaign, cls_P7S1_TestData.AdPrice_TestData);

        List<ADvendio__Campaign_Item__c> cil = new List<ADvendio__Campaign_Item__c>();
        cil.add(l_oCampaignItem1);
        cil.add(l_oCampaignItem2);
        insert cil;

        cil = new List<ADvendio__Campaign_Item__c>();

        Test.startTest();

        l_oMediaCampaign.SomDig_StatusPAMCockpit__c = 'to do';
        update l_oMediaCampaign;

        l_oCampaignItem1.SomDig_PositionStatus__c = 'Auslieferung-normal';
        //update l_oCampaignItem1;
        cil.add(l_oCampaignItem1);

        l_oCampaignItem2.SomDig_PositionStatus__c = 'bereit';
        //update l_oCampaignItem2;
        cil.add(l_oCampaignItem2);
        update cil;

        Test.stopTest();
    }

}