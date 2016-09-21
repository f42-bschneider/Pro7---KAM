@isTest
public with sharing class SomDig_SalesPriceProxy_CampaignItem_Test {

    static testMethod void fcComplimentary() {
        SomDig_MediagattungsDifferenzierung__c mediagattungsDifferenzierung = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true, 'InStream/Video');
        Advendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true, mediagattungsDifferenzierung);
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, adType);
        adSpec.SomDig_FcAufschlag__c = 2.0;
        adSpec.SomDig_OtpAufschlag__c = 3.0;
        insert adSpec;
        ADvendio__Ad_Price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, adPrice);
        campaignItem.SomDig_OtpAufschlag__c = true;
        campaignItem.ADvendio__FC_Ad_served_every__c = 1.0;
        campaignItem.ADvendio__FC_Period__c = 'month';
        campaignItem.ADvendio__FC_Quantity__c = 1.0;
        insert campaignItem;

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_FcSurcharge__c);
        System.assertEquals(3.0, proxy.SomDig_OtpSurcharge__c);
    }

    static testMethod void fcNotConsideredForInPage() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_FcAufschlag__c = 5.0;
        adSpec.SomDig_OtpAufschlag__c = 6.50;
        insert adSpec;
        ADvendio__Ad_Price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, adPrice);
        campaignItem.SomDig_OtpAufschlag__c = false;
        campaignItem.ADvendio__FC_Ad_served_every__c = 1.0;
        campaignItem.ADvendio__FC_Period__c = 'month';
        campaignItem.ADvendio__FC_Quantity__c = 1.0;
        insert campaignItem;

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_FcSurcharge__c);
        System.assertEquals(null, proxy.SomDig_OtpSurcharge__c);
    }

    static testMethod void emptyFcValues() {
        SomDig_MediagattungsDifferenzierung__c mediagattungsDifferenzierung = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true, 'InStream/Video');
        Advendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true, mediagattungsDifferenzierung);
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, adType);
        adSpec.SomDig_FcAufschlag__c = 10.0;
        adSpec.SomDig_OtpAufschlag__c = 7.50;
        insert adSpec;
        ADvendio__Ad_Price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, adPrice);
        campaignItem.SomDig_OtpAufschlag__c = true;
        insert campaignItem;

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_FcSurcharge__c);
        System.assertEquals(7.50, proxy.SomDig_OtpSurcharge__c);
    }

    static testMethod void fcPeriodIsLessThanWeek() {
        SomDig_MediagattungsDifferenzierung__c mediagattungsDifferenzierung = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true, 'InStream/Video');
        Advendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true, mediagattungsDifferenzierung);
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, adType);
        adSpec.SomDig_FcAufschlag__c = 10.0;
        insert adSpec;
        ADvendio__Ad_Price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, adPrice);
        campaignItem.SomDig_OtpAufschlag__c = false;
        campaignItem.ADvendio__FC_Ad_served_every__c = 1.0;
        campaignItem.ADvendio__FC_Period__c = 'minute';
        campaignItem.ADvendio__FC_Quantity__c = 1.0;
        insert campaignItem;

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_FcSurcharge__c);

        campaignItem.ADvendio__FC_Period__c = 'session';
        update campaignItem;

        proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_FcSurcharge__c);

        campaignItem.ADvendio__FC_Period__c = 'hour';
        update campaignItem;

        proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_FcSurcharge__c);

        campaignItem.ADvendio__FC_Period__c = 'day';
        update campaignItem;

        Test.stopTest();

        proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_FcSurcharge__c);
    }

    static testMethod void allFcConditionsAreMet() {
        SomDig_MediagattungsDifferenzierung__c mediagattungsDifferenzierung = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true, 'InStream/Video');
        Advendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true, mediagattungsDifferenzierung);
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, adType);
        adSpec.SomDig_FcAufschlag__c = 4.0;
        adSpec.SomDig_OtpAufschlag__c = 3.0;
        insert adSpec;
        ADvendio__Ad_Price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, adPrice);
        campaignItem.SomDig_OtpAufschlag__c = false;
        campaignItem.ADvendio__FC_Ad_served_every__c = 1.0;
        campaignItem.ADvendio__FC_Period__c = 'week';
        campaignItem.ADvendio__FC_Quantity__c = 1.0;
        insert campaignItem;

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(4.0, proxy.SomDig_FcSurcharge__c);
        System.assertEquals(null, proxy.SomDig_OtpSurcharge__c);

        campaignItem.ADvendio__FC_Period__c = 'month';
        update campaignItem;

        proxy = loadProxy(campaignItem);
        System.assertEquals(4.0, proxy.SomDig_FcSurcharge__c);
        System.assertEquals(null, proxy.SomDig_OtpSurcharge__c);

        campaignItem.ADvendio__FC_Period__c = 'campaign';
        update campaignItem;

        Test.stopTest();

        proxy = loadProxy(campaignItem);
        System.assertEquals(4.0, proxy.SomDig_FcSurcharge__c);
        System.assertEquals(null, proxy.SomDig_OtpSurcharge__c);
    }

    static testMethod void retargetingSurchargeSetOnInsert() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_RetargetingSurcharge__c = 12.0;
        insert adSpec;
        ADvendio__Ad_Price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(false, adPrice);
        campaignItem.SomDig_Retargeting__c = true;
        insert campaignItem;

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(12.0, proxy.SomDig_RetargetingSurcharge__c);
    }

    static testMethod void retargetingSurchargeSetOnUpdate() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_RetargetingSurcharge__c = 17.0;
        insert adSpec;
        ADvendio__Ad_Price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);
        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        Test.startTest();

        campaignItem.SomDig_Retargeting__c = true;
        update campaignItem;

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(17.0, proxy.SomDig_RetargetingSurcharge__c);
    }



    // HELPER
    private static SomDig_SalesPriceProxy__c loadProxy(ADvendio__Campaign_Item__c campaignItem) {
        return [
            SELECT SomDig_FcSurcharge__c, SomDig_OtpSurcharge__c, SomDig_RetargetingSurcharge__c
              FROM SomDig_SalesPriceProxy__c
             WHERE SomDig_CampaignItemID__c = :campaignItem.Id
        ];
    }

}