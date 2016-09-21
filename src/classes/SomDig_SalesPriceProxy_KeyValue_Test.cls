@isTest
public with sharing class SomDig_SalesPriceProxy_KeyValue_Test {

    static testmethod void campaignItemInsert() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, placement);
        adSpec.SomDig_Targetingaufschlag__c = 10.0;
        adSpec.SomDig_RotationExclusionSurcharge__c = 15.0;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_KeyValueTargetingSurcharge__c);
        System.assertEquals(null, proxy.SomDig_RotationExclusionSurcharge__c);
    }

    static testmethod void adSpecWithoutSurcharges() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement);
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Key__c key1 = cls_P7S1_TestData.createTestKey(false);
        key1.SomDig_TargetingProvider__c = 'nugg.ad';
        Advendio__Key__c key2 = cls_P7S1_TestData.createTestKey(false);
        key2.SomDig_TargetingProvider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert new List<Advendio__Key__c>{ key1, key2 };

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);

        ADvendio__KeyValue__c keyValue1 = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key1);
        ADvendio__KeyValue__c keyValue2 = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key2);
        keyValue2.ADvendio__Values__c = SomDig_SalesPriceProxy_KeyValue.FUTURETV + ',' + SomDig_SalesPriceProxy_KeyValue.VIDEOVALIS;
        insert new List<ADvendio__KeyValue__c> { keyValue1, keyValue2 };

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_KeyValueTargetingSurcharge__c);
        System.assertEquals(null, proxy.SomDig_RotationExclusionSurcharge__c);
    }

    static testmethod void keysForTargetingAndRotationExclusion() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, placement);
        adSpec.SomDig_Targetingaufschlag__c = 5.0;
        adSpec.SomDig_RotationExclusionSurcharge__c = 10.0;
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Key__c key1 = cls_P7S1_TestData.createTestKey(false);
        key1.SomDig_TargetingProvider__c = 'nugg.ad';
        Advendio__Key__c key2 = cls_P7S1_TestData.createTestKey(false);
        key2.SomDig_TargetingProvider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert new List<Advendio__Key__c>{ key1, key2 };

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);

        ADvendio__KeyValue__c keyValue1 = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key1);
        ADvendio__KeyValue__c keyValue2 = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key2);
        keyValue2.ADvendio__Values__c = SomDig_SalesPriceProxy_KeyValue.FUTURETV + ',' + SomDig_SalesPriceProxy_KeyValue.VIDEOVALIS;
        insert new List<ADvendio__KeyValue__c> { keyValue1, keyValue2 };

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(5.0, proxy.SomDig_KeyValueTargetingSurcharge__c);
        System.assertEquals(10.0, proxy.SomDig_RotationExclusionSurcharge__c);
    }

    static testmethod void keyValuesDeleted() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, placement);
        adSpec.SomDig_Targetingaufschlag__c = 5.0;
        adSpec.SomDig_RotationExclusionSurcharge__c = 10.0;
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Key__c key1 = cls_P7S1_TestData.createTestKey(false);
        key1.SomDig_TargetingProvider__c = 'nugg.ad';
        Advendio__Key__c key2 = cls_P7S1_TestData.createTestKey(false);
        key2.SomDig_TargetingProvider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert new List<Advendio__Key__c>{ key1, key2 };

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);

        ADvendio__KeyValue__c keyValue1 = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key1);
        ADvendio__KeyValue__c keyValue2 = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key2);
        keyValue2.ADvendio__Values__c = SomDig_SalesPriceProxy_KeyValue.FUTURETV + ',' + SomDig_SalesPriceProxy_KeyValue.VIDEOVALIS;
        insert new List<ADvendio__KeyValue__c> { keyValue1, keyValue2 };

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(5.0, proxy.SomDig_KeyValueTargetingSurcharge__c);
        System.assertEquals(10.0, proxy.SomDig_RotationExclusionSurcharge__c);

        delete keyValue1;

        proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_KeyValueTargetingSurcharge__c);
        System.assertEquals(10.0, proxy.SomDig_RotationExclusionSurcharge__c);

        delete keyLine;

        Test.stopTest();

        proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_KeyValueTargetingSurcharge__c);
        System.assertEquals(null, proxy.SomDig_RotationExclusionSurcharge__c);
    }

    static testmethod void singleKeyValue() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = 12.0;
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Key__c key = cls_P7S1_TestData.createTestKey(false);
        key.SomDig_TargetingProvider__c = 'nugg.ad';
        insert key;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);
        cls_P7S1_TestData.createTestKeyValue(true, keyLine, key);

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(12.0, proxy.SomDig_KeyValueTargetingSurcharge__c);
    }

    static testmethod void multipleKeyValues() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = 7.50;
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Key__c key1 = cls_P7S1_TestData.createTestKey(false);
        key1.SomDig_TargetingProvider__c = 'nugg.ad';
        Advendio__Key__c key2 = cls_P7S1_TestData.createTestKey(false);
        key2.SomDig_TargetingProvider__c = 'ICQ';
        insert new List<Advendio__Key__c>{ key1, key2 };

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);
        ADvendio__KeyValue__c keyValue1 = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key1);
        ADvendio__KeyValue__c keyValue2 = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key2);
        insert new List<ADvendio__KeyValue__c> { keyValue1, keyValue2 };

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(7.50, proxy.SomDig_KeyValueTargetingSurcharge__c);
    }

    static testmethod void singleKeyValueWithoutTargetingProvider() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = 3.90;
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);
        Advendio__Key__c key = cls_P7S1_TestData.createTestKey(true);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);
        cls_P7S1_TestData.createTestKeyValue(true, keyLine, key);

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_KeyValueTargetingSurcharge__c);
    }

    static testmethod void rotationExclusionWithFutureTvAndVideovalis() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, placement);
        adSpec.SomDig_RotationExclusionSurcharge__c = 20.0;
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Key__c key = cls_P7S1_TestData.createTestKey(false);
        key.SomDig_TargetingProvider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert key;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);
        ADvendio__KeyValue__c keyValue = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key);
        keyValue.ADvendio__Values__c = SomDig_SalesPriceProxy_KeyValue.FUTURETV + ',' + SomDig_SalesPriceProxy_KeyValue.VIDEOVALIS;
        insert keyValue;

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(20.0, proxy.SomDig_RotationExclusionSurcharge__c);
    }

    static testmethod void rotationExclusionWithOnlyFutureTv() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, placement);
        adSpec.SomDig_RotationExclusionSurcharge__c = 18.0;
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Key__c key = cls_P7S1_TestData.createTestKey(false);
        key.SomDig_TargetingProvider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert key;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);
        ADvendio__KeyValue__c keyValue = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key);
        keyValue.ADvendio__Values__c = 'randomsite1.de, randomsite2.de, ' + SomDig_SalesPriceProxy_KeyValue.FUTURETV;
        insert keyValue;

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_RotationExclusionSurcharge__c);
    }

    static testmethod void rotationExclusionWith4Exclusions() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, placement);
        adSpec.SomDig_RotationExclusionSurcharge__c = 11.50;
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Key__c key = cls_P7S1_TestData.createTestKey(false);
        key.SomDig_TargetingProvider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert key;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);
        ADvendio__KeyValue__c keyValue = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key);
        keyValue.ADvendio__Values__c = 'randomsite1.de, randomsite2.de, randomsite3.de, randomsite4.de';
        insert keyValue;

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(11.50, proxy.SomDig_RotationExclusionSurcharge__c);
    }

    static testmethod void rotationExclusionWith3Exclusions() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, placement);
        adSpec.SomDig_RotationExclusionSurcharge__c = 13.0;
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Key__c key = cls_P7S1_TestData.createTestKey(false);
        key.SomDig_TargetingProvider__c = SomDig_SalesPriceProxy_KeyValue.ROTATIONSAUSSCHLUSS;
        insert key;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        ADvendio__KeyLine__c keyLine = cls_P7S1_TestData.createTestKeyLine(true, campaignItem);
        ADvendio__KeyValue__c keyValue = cls_P7S1_TestData.createTestKeyValue(false, keyLine, key);
        keyValue.ADvendio__Values__c = 'randomsite1.de, randomsite2.de, randomsite3.de';
        insert keyValue;

        Test.stopTest();

        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_RotationExclusionSurcharge__c);
    }



    // Helper
    private static SomDig_SalesPriceProxy__c loadProxy(ADvendio__Campaign_Item__c campaignItem) {
        return [
            SELECT SomDig_KeyValueTargetingSurcharge__c, SomDig_RotationExclusionSurcharge__c
              FROM SomDig_SalesPriceProxy__c
             WHERE SomDig_CampaignItemID__c = :campaignItem.Id];
    }

}