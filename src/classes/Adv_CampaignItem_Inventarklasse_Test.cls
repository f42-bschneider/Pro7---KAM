@isTest
private with sharing class Adv_CampaignItem_Inventarklasse_Test {

    @testSetup
    static void createTestData() {
        SomDig_Auftragstyp__c auftragstyp = cls_P7S1_TestData.createTestAuftragstyp(true, 'Standard');
        ADvendio__Pricelist__c pricelist = cls_P7S1_TestData.createTestPricelist(true, auftragstyp);
        cls_P7S1_TestData.createTestMediaCampaign(true, null, pricelist);

        SomDig_MediagattungsDifferenzierung__c mgDiff = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true, 'InPage/Display');
        ADvendio__RateCategory__c preismerkmal = createTestRateCategory(true, 'Preisgruppe 1');
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(false);
        adType.SomDig_MediagattungsDifferenzierung__c = mgDiff.Id;
        insert adType;
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.ADvendio__RateCategory__c = preismerkmal.Id;
        placement.SomDig_Rotationstyp__c = 'Brand-Rotation';
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);
        cls_P7S1_TestData.createTestAdPrice(true, adSpec, pricelist);

        createTestInventarklasse(true, 'X');
    }

    static testMethod void addingPreismerkmal() {
        ADvendio__MediaCampaign__c mediaCampaign = [SELECT Id FROM ADvendio__MediaCampaign__c LIMIT 1];
        ADvendio__Ad_price__c adPrice = [SELECT Id FROM ADvendio__Ad_price__c LIMIT 1];

        ADvendio__Campaign_Item__c campaignItem1 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem1 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem1.Id];
        System.assertEquals('X', campaignItem1.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.startTest();

        ADvendio__RateCategory__c preismerkmal = [SELECT Id FROM ADvendio__RateCategory__c LIMIT 1];
        SomDig_Inventarklasse__c inventarklasse = createTestInventarklasse(false, 'A1');
        inventarklasse.SomDig_Preismerkmal__c = preismerkmal.Id;
        insert inventarklasse;

        ADvendio__Campaign_Item__c campaignItem2 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem2 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem2.Id];
        System.assertEquals('A1', campaignItem2.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.stopTest();
    }

    static testMethod void addingMediagattungsDifferenzierung() {
        ADvendio__MediaCampaign__c mediaCampaign = [SELECT Id FROM ADvendio__MediaCampaign__c LIMIT 1];
        ADvendio__Ad_price__c adPrice = [SELECT Id FROM ADvendio__Ad_price__c LIMIT 1];

        ADvendio__Campaign_Item__c campaignItem1 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem1 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem1.Id];
        System.assertEquals('X', campaignItem1.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.startTest();

        SomDig_MediagattungsDifferenzierung__c mgDiff = [SELECT Id FROM SomDig_MediagattungsDifferenzierung__c LIMIT 1];
        SomDig_Inventarklasse__c inventarklasse = createTestInventarklasse(false, 'A2');
        inventarklasse.SomDig_MediagattungsDifferenzierung__c = mgDiff.Id;
        insert inventarklasse;

        ADvendio__Campaign_Item__c campaignItem2 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem2 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem2.Id];
        System.assertEquals('A2', campaignItem2.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.stopTest();
    }

    static testMethod void addingAuftragstyp() {
        ADvendio__MediaCampaign__c mediaCampaign = [SELECT Id FROM ADvendio__MediaCampaign__c LIMIT 1];
        ADvendio__Ad_price__c adPrice = [SELECT Id FROM ADvendio__Ad_price__c LIMIT 1];

        ADvendio__Campaign_Item__c campaignItem1 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem1 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem1.Id];
        System.assertEquals('X', campaignItem1.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.startTest();

        SomDig_Auftragstyp__c auftragstyp = [SELECT Id FROM SomDig_Auftragstyp__c LIMIT 1];
        SomDig_Inventarklasse__c inventarklasse = createTestInventarklasse(false, 'A3');
        inventarklasse.SomDig_AuftragstypId__c = auftragstyp.Id;
        insert inventarklasse;

        ADvendio__Campaign_Item__c campaignItem2 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem2 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem2.Id];
        System.assertEquals('A3', campaignItem2.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.stopTest();
    }

    static testMethod void addingRotationstyp() {
        ADvendio__MediaCampaign__c mediaCampaign = [SELECT Id FROM ADvendio__MediaCampaign__c LIMIT 1];
        ADvendio__Ad_price__c adPrice = [SELECT Id FROM ADvendio__Ad_price__c LIMIT 1];

        ADvendio__Campaign_Item__c campaignItem1 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem1 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem1.Id];
        System.assertEquals('X', campaignItem1.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.startTest();

        SomDig_Inventarklasse__c inventarklasse = createTestInventarklasse(false, 'A4');
        inventarklasse.SomDig_Rotationstyp__c = 'Brand-Rotation';
        insert inventarklasse;

        ADvendio__Campaign_Item__c campaignItem2 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem2 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem2.Id];
        System.assertEquals('A4', campaignItem2.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.stopTest();
    }

    static testMethod void addingWerbeformdatensatztyp() {
        ADvendio__MediaCampaign__c mediaCampaign = [SELECT Id FROM ADvendio__MediaCampaign__c LIMIT 1];
        ADvendio__Ad_price__c adPrice = [SELECT Id FROM ADvendio__Ad_price__c LIMIT 1];

        ADvendio__Campaign_Item__c campaignItem1 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem1 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem1.Id];
        System.assertEquals('X', campaignItem1.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.startTest();

        SomDig_Inventarklasse__c inventarklasse = createTestInventarklasse(false, 'A5');
        inventarklasse.SomDig_WerbeformDatensatztyp__c = 'DFP';
        insert inventarklasse;

        ADvendio__Campaign_Item__c campaignItem2 = cls_P7S1_TestData.createTestCampaignItem(true, mediaCampaign, adPrice);
        campaignItem2 = [SELECT SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c FROM ADvendio__Campaign_Item__c WHERE Id = :campaignItem2.Id];
        System.assertEquals('A5', campaignItem2.SomDig_Inventarklasse__r.SomDig_InventarklasseNummer__c);

        Test.stopTest();
    }



    // TODO: move to TestData
    public static SomDig_Inventarklasse__c Inventarklasse_TestData;
    public static SomDig_Inventarklasse__c createTestInventarklasse(Boolean insertObject, String nummer) {
        Inventarklasse_TestData = new SomDig_Inventarklasse__c();
        Inventarklasse_TestData.SomDig_InventarklasseNummer__c = nummer;
        if (insertObject) insert Inventarklasse_TestData;
        return Inventarklasse_TestData;
    }

    // TODO: move to TestData
    public static ADvendio__RateCategory__c RateCategory_TestData;
    public static ADvendio__RateCategory__c createTestRateCategory(Boolean insertObject, String name) {
        RateCategory_TestData = new ADvendio__RateCategory__c();
        RateCategory_TestData.Name = name;
        if (insertObject) insert RateCategory_TestData;
        return RateCategory_TestData;
    }

}