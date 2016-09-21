@isTest
public with sharing class SomDig_SalesPriceProxy_Geo_Test {

    static testmethod void campaignItemInsert() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = (Math.random() * 100).round();
        insert adSpec;
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void singleRegion() {
        Decimal surcharge = (Math.random() * 100).round();
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = surcharge;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Region__c region = cls_P7S1_TestData.createTestRegion(false);
        region.SomDig_Zuschlagspflichtig__c = true;
        insert region;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        cls_P7S1_TestData.createTestSelectedRegion(true, campaignItem, region);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void singleCityWithoutSurcharge() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = (Math.random() * 100).round();
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__City__c city = cls_P7S1_TestData.createTestCity(false);
        city.SomDig_Zuschlagspflichtig__c = false;
        insert city;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        cls_P7S1_TestData.createTestSelectedCity(true, campaignItem, city);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void adSpecWithoutSurcharge() {
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true);
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Region__c region = cls_P7S1_TestData.createTestRegion(false);
        region.SomDig_Zuschlagspflichtig__c = true;
        insert region;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);
        cls_P7S1_TestData.createTestSelectedRegion(true, campaignItem, region);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void regionGainsSurchargeRelevance() {
        Decimal surcharge = (Math.random() * 100).round();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = surcharge;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Region__c region = cls_P7S1_TestData.createTestRegion(false);
        region.SomDig_Zuschlagspflichtig__c = true;
        insert region;

        Advendio__Country__c country = cls_P7S1_TestData.createTestCountry(false);
        country.SomDig_Zuschlagspflichtig__c = false;
        insert country;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        cls_P7S1_TestData.createTestSelectedRegion(true, campaignItem, region);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        region.SomDig_Zuschlagspflichtig__c = false;
        update region;
        cls_P7S1_TestData.createTestSelectedCountry(true, campaignItem, country);
        proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void cityLosesSurchargeRelevance() {
        Decimal surcharge = (Math.random() * 100).round();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = surcharge;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__City__c city = cls_P7S1_TestData.createTestCity(false);
        city.SomDig_Zuschlagspflichtig__c = false;
        insert city;

        Advendio__Country__c country = cls_P7S1_TestData.createTestCountry(false);
        country.SomDig_Zuschlagspflichtig__c = false;
        insert country;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        cls_P7S1_TestData.createTestSelectedCity(true, campaignItem, city);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_GeoTargetingSurcharge__c);

        city.SomDig_Zuschlagspflichtig__c = true;
        update city;
        cls_P7S1_TestData.createTestSelectedCountry(true, campaignItem, country);
        proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void adSpecSurchargeChanges() {
        Decimal surcharge = (Math.random() * 100).round();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = surcharge;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Region__c region = cls_P7S1_TestData.createTestRegion(false);
        region.SomDig_Zuschlagspflichtig__c = true;
        insert region;

        Advendio__Country__c country = cls_P7S1_TestData.createTestCountry(false);
        country.SomDig_Zuschlagspflichtig__c = false;
        insert country;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        cls_P7S1_TestData.createTestSelectedRegion(true, campaignItem, region);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        Decimal differentSurcharge = (Math.random() * 100).round();
        adSpec.SomDig_Targetingaufschlag__c = differentSurcharge;
        update adSpec;
        cls_P7S1_TestData.createTestSelectedCountry(true, campaignItem, country);
        proxy = loadProxy(campaignItem);
        System.assertEquals(differentSurcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void adSpecSurchargeChanges2() {
        Decimal surcharge = (Math.random() * 100).round();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = surcharge;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Region__c region = cls_P7S1_TestData.createTestRegion(false);
        region.SomDig_Zuschlagspflichtig__c = true;
        insert region;

        Advendio__Country__c country = cls_P7S1_TestData.createTestCountry(false);
        country.SomDig_Zuschlagspflichtig__c = false;
        insert country;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        // Initial surcharge should be surcharge
        cls_P7S1_TestData.createTestSelectedRegion(true, campaignItem, region);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        // Update AdSpec, insert SelectedCountry, surcharge should be null
        adSpec.SomDig_Targetingaufschlag__c = null;
        update adSpec;
        cls_P7S1_TestData.createTestSelectedCountry(true, campaignItem, country);
        proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void multipleGeoTargetings1() {
        Decimal surcharge = (Math.random() * 100).round();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = surcharge;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Region__c region = cls_P7S1_TestData.createTestRegion(false);
        region.SomDig_Zuschlagspflichtig__c = false;
        insert region;

        Advendio__Country__c country = cls_P7S1_TestData.createTestCountry(false);
        country.SomDig_Zuschlagspflichtig__c = true;
        insert country;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        cls_P7S1_TestData.createTestSelectedRegion(true, campaignItem, region);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_GeoTargetingSurcharge__c);

        // Insert SelectedCountry, surcharge should be surcharge
        cls_P7S1_TestData.createTestSelectedCountry(true, campaignItem, country);
        proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void multipleGeoTargetings2() {
        Decimal surcharge = (Math.random() * 100).round();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = surcharge;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Region__c region = cls_P7S1_TestData.createTestRegion(false);
        region.SomDig_Zuschlagspflichtig__c = true;
        insert region;

        Advendio__Country__c country = cls_P7S1_TestData.createTestCountry(false);
        country.SomDig_Zuschlagspflichtig__c = false;
        insert country;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        cls_P7S1_TestData.createTestSelectedRegion(true, campaignItem, region);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        // Insert SelectedCountry, surcharge should still be surcharge although the Country for the SelectedCountry has SomDig_Zuschlagspflichtig__c = false
        cls_P7S1_TestData.createTestSelectedCountry(true, campaignItem, country);
        proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void countryIsDeletedAndSurchargeChanges() {
        Decimal surcharge = (Math.random() * 100).round();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = surcharge;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Region__c region = cls_P7S1_TestData.createTestRegion(false);
        region.SomDig_Zuschlagspflichtig__c = false;
        insert region;

        Advendio__Country__c country = cls_P7S1_TestData.createTestCountry(false);
        country.SomDig_Zuschlagspflichtig__c = true;
        insert country;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        cls_P7S1_TestData.createTestSelectedRegion(true, campaignItem, region);
        ADvendio__Selected_Country__c selectedCountry = cls_P7S1_TestData.createTestSelectedCountry(true, campaignItem, country);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        // Delete SelectedCountry, surcharge should be null because no Geo objects with SomDig_Zuschlagspflichtig__c = true are remaining
        delete selectedCountry;
        proxy = loadProxy(campaignItem);
        System.assertEquals(null, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }

    static testmethod void countryIsDeletedAndSurchargeDoesntChange() {
        Decimal surcharge = (Math.random() * 100).round();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false);
        adSpec.SomDig_Targetingaufschlag__c = surcharge;
        insert adSpec;

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, adSpec);

        Advendio__Region__c region = cls_P7S1_TestData.createTestRegion(false);
        region.SomDig_Zuschlagspflichtig__c = true;
        insert region;

        Advendio__Country__c country = cls_P7S1_TestData.createTestCountry(false);
        country.SomDig_Zuschlagspflichtig__c = false;
        insert country;

        Test.startTest();

        ADvendio__Campaign_Item__c campaignItem = cls_P7S1_TestData.createTestCampaignItem(true, adPrice);

        cls_P7S1_TestData.createTestSelectedRegion(true, campaignItem, region);
        ADvendio__Selected_Country__c selectedCountry = cls_P7S1_TestData.createTestSelectedCountry(true, campaignItem, country);
        SomDig_SalesPriceProxy__c proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        delete selectedCountry;
        proxy = loadProxy(campaignItem);
        System.assertEquals(surcharge, proxy.SomDig_GeoTargetingSurcharge__c);

        Test.stopTest();
    }



    // Helper
    private static SomDig_SalesPriceProxy__c loadProxy(ADvendio__Campaign_Item__c campaignItem) {
        return [
            SELECT SomDig_GeoTargetingSurcharge__c
              FROM SomDig_SalesPriceProxy__c
             WHERE SomDig_CampaignItemID__c = :campaignItem.Id
        ];
    }

}