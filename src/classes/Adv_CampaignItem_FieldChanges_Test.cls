@isTest
public with sharing class Adv_CampaignItem_FieldChanges_Test {

    static testMethod void setLineDescriptionOnInsert() {
        ADvendio__Pricelist__c pricelist = cls_P7S1_TestData.createTestPricelist(true);
        ADvendio__MediaCampaign__c mediaCampaign = createTestMediaCampaign(true, pricelist);
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, pricelist);
        adPrice.ADvendio__RateCriterion__c = 'bis 15 Sekunden';
        insert adPrice;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign, adPrice);
        campaignItem.ADvendio__Rate_Discount_4_Name__c = 'Positionsrabatt Natural';
        campaignItem.SomDig_Freitextnotiz__c = 'random text';
        campaignItem.SomDig_Retargeting__c = true;
        insert campaignItem;

        Test.stopTest();

        campaignItem = reloadCampaignItem(campaignItem);
        System.assertEquals('-random text -NR -Re-Targeting-Aufschlag -Videolänge: bis 15 Sekunden', campaignItem.ADvendio__Line_Description__c);
    }

    static testMethod void setLineDescriptionOnUpdate() {
        ADvendio__Pricelist__c pricelist = cls_P7S1_TestData.createTestPricelist(true);
        ADvendio__MediaCampaign__c mediaCampaign = createTestMediaCampaign(true, pricelist);
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, pricelist);
        adPrice.ADvendio__RateCriterion__c = 'bis 20 Sekunden';
        insert adPrice;

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign, adPrice);
        campaignItem.ADvendio__Rate_Discount_4_Name__c = 'Nachlieferung';
        campaignItem.SomDig_Freitextnotiz__c = 'random text 1';
        campaignItem.SomDig_Retargeting__c = true;
        insert campaignItem;

        campaignItem = reloadCampaignItem(campaignItem);
        System.assertEquals('-random text 1 -Nachlieferung -Re-Targeting-Aufschlag -Videolänge: bis 20 Sekunden', campaignItem.ADvendio__Line_Description__c);

        Test.startTest();

        adPrice.ADvendio__RateCriterion__c = 'bis 30 Sekunden';
        update adPrice;

        campaignItem.ADvendio__Rate_Discount_4_Name__c = 'Storno mit Leistungsfluss';
        campaignItem.SomDig_Freitextnotiz__c = 'random text 2';
        campaignItem.SomDig_Retargeting__c = false;
        update campaignItem;

        Test.stopTest();

        campaignItem = reloadCampaignItem(campaignItem);
        System.assertEquals('-random text 2 -Storno -Videolänge: bis 30 Sekunden', campaignItem.ADvendio__Line_Description__c);
    }

    static testMethod void setAdServerStatusOnInsert() {
        ADvendio__Pricelist__c pricelist = cls_P7S1_TestData.createTestPricelist(true);
        ADvendio__MediaCampaign__c mediaCampaign = createTestMediaCampaign(true, pricelist);
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, pricelist);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign, adPrice);
        campaignItem.ADvendio__Rate_Discount_4_Name__c = 'Storno mit Leistungsfluss';
        insert campaignItem;

        Test.stopTest();

        campaignItem = reloadCampaignItem(campaignItem);
        System.assertEquals('Released', campaignItem.ADvendio__AdserverStatus__c);
    }

    static testMethod void setAdServerStatusOnUpdate() {
        ADvendio__Pricelist__c pricelist = cls_P7S1_TestData.createTestPricelist(true);
        ADvendio__MediaCampaign__c mediaCampaign = createTestMediaCampaign(true, pricelist);
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, pricelist);

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign, adPrice);
        campaignItem.ADvendio__Rate_Discount_4_Name__c = 'Nachlieferung';
        insert campaignItem;

        campaignItem = reloadCampaignItem(campaignItem);
        System.assertEquals('Active', campaignItem.ADvendio__AdserverStatus__c);

        Test.startTest();

        campaignItem.ADvendio__Rate_Discount_4_Name__c = 'Storno ohne Leistungsfluss';
        update campaignItem;

        Test.stopTest();

        campaignItem = reloadCampaignItem(campaignItem);
        System.assertEquals('Released', campaignItem.ADvendio__AdserverStatus__c);
    }


    private static ADvendio__Campaign_Item__c reloadCampaignItem(ADvendio__Campaign_Item__c campaignItem) {
        return [
            SELECT ADvendio__AdserverStatus__c, ADvendio__Line_Description__c
              FROM ADvendio__Campaign_Item__c
             WHERE Id = :campaignItem.Id
        ];
    }



    // TODO: in TestData auslagern
    public static ADvendio__MediaCampaign__c createTestMediaCampaign(Boolean insertObject, ADvendio__Pricelist__c pricelist) {
        return cls_P7S1_TestData.createTestMediaCampaign(insertObject, null, pricelist, null);
    }


}