@isTest
public with sharing class Adv_CampaignItem_SalesPrice_Test {

    static testMethod void dataTransferredOnProxyInsert() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_OtpAufschlag__c = 10.0;
        insert adSpec;
        ADvendio__Ad_Price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec);
        adPrice.ADvendio__List_price__c = 20.0;
        insert adPrice;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, adPrice);
        campaignItem.SomDig_OtpAufschlag__c = true;
        campaignItem.ADvendio__Sales_Price__c = 20.0;
        insert campaignItem;

        Test.stopTest();

        campaignItem = loadCampaignItem(campaignItem);
        System.assertEquals(10.0, campaignItem.ADvendio__SurchargeSalesPrice__c);
        System.assertEquals(20.0, campaignItem.ADvendio__Sales_Price__c);
    }

    static testMethod void dataTransferredOnProxyUpdate() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_OtpAufschlag__c = 7.5;
        insert adSpec;
        ADvendio__Ad_Price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec);
        adPrice.ADvendio__List_price__c = 40.0;
        insert adPrice;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, adPrice);
        campaignItem.ADvendio__Sales_Price__c = 40.0;
        insert campaignItem;

        campaignItem = loadCampaignItem(campaignItem);
        System.assertEquals(0.0, campaignItem.ADvendio__SurchargeSalesPrice__c);
        System.assertEquals(40.0, campaignItem.ADvendio__Sales_Price__c);

        campaignItem.SomDig_OtpAufschlag__c = true;
        update campaignItem;

        Test.stopTest();

        campaignItem = loadCampaignItem(campaignItem);
        System.assertEquals(7.5, campaignItem.ADvendio__SurchargeSalesPrice__c);
        System.assertEquals(40.0, campaignItem.ADvendio__Sales_Price__c);
    }



    /** Helper */
    private static ADvendio__Campaign_Item__c loadCampaignItem(ADvendio__Campaign_Item__c campaignItem) {
        return [
            SELECT ADvendio__Sales_Price__c, ADvendio__SurchargeSalesPrice__c
              FROM ADvendio__Campaign_Item__c
             WHERE Id = :campaignItem.Id
        ];
    }

}