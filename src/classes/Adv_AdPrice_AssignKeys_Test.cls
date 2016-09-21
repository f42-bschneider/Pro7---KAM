@isTest
public with sharing class Adv_AdPrice_AssignKeys_Test {

    static testMethod void adPriceInsert() {
        ADvendio__Key__c key1 = cls_P7S1_TestData.createTestKey(false);
        key1.SomDig_TargetingProvider__c = 'nugg.ad';
        ADvendio__Key__c key2 = cls_P7S1_TestData.createTestKey(false);
        key2.SomDig_TargetingProvider__c = 'Rotationsausschluss';
        ADvendio__Key__c key3 = cls_P7S1_TestData.createTestKey(false);
        key3.SomDig_TargetingProvider__c = 'non-existent targeting provider';
        insert new List<ADvendio__Key__c>{ key1, key2, key3 };

        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = 'nugg.ad;Rotationsausschluss';
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement);

        System.assertEquals(0, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        insert adPrice;

        Test.stopTest();

        System.assertEquals(2, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);
    }

    static testMethod void adPriceInsertWithInvalidBillingCategory() {
        ADvendio__Key__c key1 = cls_P7S1_TestData.createTestKey(false);
        key1.SomDig_TargetingProvider__c = 'nugg.ad';
        ADvendio__Key__c key2 = cls_P7S1_TestData.createTestKey(false);
        key2.SomDig_TargetingProvider__c = 'Rotationsausschluss';
        ADvendio__Key__c key3 = cls_P7S1_TestData.createTestKey(false);
        key3.SomDig_TargetingProvider__c = 'non-existent targeting provider';
        insert new List<ADvendio__Key__c>{ key1, key2, key3 };

        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = 'nugg.ad;Rotationsausschluss';
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement);

        System.assertEquals(0, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec);
        adPrice.ADvendio__Billing_Category__c = 'CPD';
        insert adPrice;

        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);
    }

    static testMethod void adPriceBulk() {
        ADvendio__Key__c key = cls_P7S1_TestData.createTestKey(false);
        key.SomDig_TargetingProvider__c = 'nugg.ad';
        insert key;

        SomDig_MediagattungsDifferenzierung__c mgdiff = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true, mgdiff);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = 'nugg.ad';
        insert placement;

        List<ADvendio__Ad_Specs__c> adSpecsList = new List<ADvendio__Ad_Specs__c>();
        for (Integer i = 0; i < 200; i++) {
            adSpecsList.add(cls_P7S1_TestData.createTestAdSpec(false, placement, adType));
        }
        insert adSpecsList;

        SomDig_Auftragstyp__c auftragstyp = cls_P7S1_TestData.createTestAuftragstyp(true);
        ADvendio__Pricelist__c pricelist = cls_P7S1_TestData.createTestPricelist(true, auftragstyp);

        System.assertEquals(0, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);

        Test.startTest();

        List<ADvendio__Ad_price__c> adPricesList = new List<ADvendio__Ad_price__c>();
        for (Integer i = 0; i < 200; i++) {
            ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpecsList[i], pricelist);
            if (Math.mod(i, 2) == 0) {
                adPrice.ADvendio__Billing_Category__c = 'CPM';
            } else {
                adPrice.ADvendio__Billing_Category__c = 'CPD';
            }
            adPricesList.add(adPrice);
        }
        insert adPricesList;

        Test.stopTest();

        System.assertEquals(100, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);
    }

    static testMethod void adPriceUpdate() {
        ADvendio__Key__c key1 = cls_P7S1_TestData.createTestKey(false);
        key1.SomDig_TargetingProvider__c = 'nugg.ad';
        ADvendio__Key__c key2 = cls_P7S1_TestData.createTestKey(false);
        key2.SomDig_TargetingProvider__c = 'Rotationsausschluss';
        ADvendio__Key__c key3 = cls_P7S1_TestData.createTestKey(false);
        key3.SomDig_TargetingProvider__c = 'non-existent targeting provider';
        insert new List<ADvendio__Key__c>{ key1, key2, key3 };

        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = 'nugg.ad;Rotationsausschluss';
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement);

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec);
        adPrice.ADvendio__Billing_Category__c = 'CPD';
        insert adPrice;

        System.assertEquals(1, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);

        Test.startTest();

        adPrice.ADvendio__Billing_Category__c = 'CPM';
        update adPrice;

        Test.stopTest();

        System.assertEquals(2, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);
    }

    static testMethod void placementUpdate() {
        ADvendio__Key__c key1 = cls_P7S1_TestData.createTestKey(false);
        key1.SomDig_TargetingProvider__c = 'nugg.ad';
        ADvendio__Key__c key2 = cls_P7S1_TestData.createTestKey(false);
        key2.SomDig_TargetingProvider__c = 'Rotationsausschluss';
        insert new List<ADvendio__Key__c>{ key1, key2 };

        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Targeting_Provider__c = 'nugg.ad;Rotationsausschluss';
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement);

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        insert adPrice;

        System.assertEquals(2, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);

        Test.startTest();

        placement.Targeting_Provider__c = 'nugg.ad';
        update placement;

        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);
    }

    static testMethod void placementBulk() {
        ADvendio__Key__c key1 = cls_P7S1_TestData.createTestKey(false);
        key1.SomDig_TargetingProvider__c = 'nugg.ad';
        ADvendio__Key__c key2 = cls_P7S1_TestData.createTestKey(false);
        key2.SomDig_TargetingProvider__c = 'Rotationsausschluss';
        insert new List<ADvendio__Key__c>{ key1, key2 };

        SomDig_MediagattungsDifferenzierung__c mgdiff = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true, mgdiff);
        ADvendio__Site__c site = cls_P7S1_TestData.createTestSite(true);

        List<ADvendio__Placement__c> placementsList = new List<ADvendio__Placement__c>();
        for (Integer i = 0; i < 50; i++) {
            ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false, site);
            placement.Targeting_Provider__c = 'nugg.ad';
            placementsList.add(placement);
        }
        insert placementsList;

        List<ADvendio__Ad_Specs__c> adSpecsList = new List<ADvendio__Ad_Specs__c>();
        for (Integer i = 0; i < 50; i++) {
            adSpecsList.add(cls_P7S1_TestData.createTestAdSpec(false, placementsList[i], adType));
        }
        insert adSpecsList;

        SomDig_Auftragstyp__c auftragstyp = cls_P7S1_TestData.createTestAuftragstyp(true);
        ADvendio__Pricelist__c pricelist = cls_P7S1_TestData.createTestPricelist(true, auftragstyp);

        List<ADvendio__Ad_price__c> adPricesList = new List<ADvendio__Ad_price__c>();
        for (Integer i = 0; i < 50; i++) {
            ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpecsList[i], pricelist);
            adPrice.ADvendio__Billing_Category__c = 'CPM';
            adPricesList.add(adPrice);
        }
        insert adPricesList;

        System.assertEquals(50, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);

        Test.startTest();

        for (ADvendio__Placement__c placement : placementsList) {
            placement.Targeting_Provider__c = 'nugg.ad;Rotationsausschluss';
        }
        update placementsList;

        Test.stopTest();

        System.assertEquals(100, [SELECT count() FROM ADvendio__KeyAdPriceAssignment__c]);
    }

}