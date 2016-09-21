@isTest
private with sharing class Adv_AdPrice_Metabuchungslogik_Test {

    static testMethod void inactiveMblProhibitsValidAdPrice() {
        createTestInventory();

        SomDig_Metabuchungslogik__c mbl = [SELECT SomDig_IsActive__c FROM SomDig_Metabuchungslogik__c WHERE Mig_ProdiaKey__c = '123'][0];
        mbl.SomDig_IsActive__c = false;
        update mbl;

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void validAdPriceConformsToMbl() {
        createTestInventory();

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(result.isSuccess());
        adPrice = [SELECT SomDig_Metabuchungslogik__c FROM ADvendio__Ad_price__c WHERE Id = :adPrice.Id][0];
        SomDig_Metabuchungslogik__c mbl = [SELECT Id FROM SomDig_Metabuchungslogik__c WHERE Mig_ProdiaKey__c = '123'][0];
        System.assertEquals(mbl.Id, adPrice.SomDig_Metabuchungslogik__c);
    }

    static testMethod void invalidAbrechnungsartBreaksMbl() {
        createTestInventory();

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPW';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidAuftragstypBreaksMbl() {
        createTestInventory();

        SomDig_Auftragstyp__c standard = cls_P7S1_TestData.createTestAuftragstyp(true, 'Standard');

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];
        pricelist.SomDig_AuftragstypId__c = standard.Id;
        update pricelist;

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidBtFaehigkeitBreaksMbl() {
        createTestInventory();

        ADvendio__Placement__c placement = [SELECT Id, Name FROM ADvendio__Placement__c WHERE Name = 'MBL Test Placement'][0];
        placement.SomDig_BT__c = false;
        update placement;

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidCpxFaehigkeitBreaksMbl() {
        createTestInventory();

        ADvendio__Placement__c placement = [SELECT Id, Name FROM ADvendio__Placement__c WHERE Name = 'MBL Test Placement'][0];
        placement.SomDig_CpxFaehig__c = false;
        update placement;

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidFcFaehigkeitBreaksMbl() {
        createTestInventory();

        ADvendio__Placement__c placement = [SELECT Id, Name FROM ADvendio__Placement__c WHERE Name = 'MBL Test Placement'][0];
        placement.SomDig_FC__c = false;
        update placement;

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidGtFaehigkeitBreaksMbl() {
        createTestInventory();

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        adSpec.SomDig_GtFaehig__c = false;
        update adSpec;
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidMediagattungsDifferenzierungBreaksMbl() {
        createTestInventory();

        SomDig_MediagattungsDifferenzierung__c instream = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true, 'InStream/Video');

        ADvendio__Ad_Type__c adType = [SELECT Id, Name FROM ADvendio__Ad_Type__c WHERE Name = 'MBL Test AdType'][0];
        adType.SomDig_MediagattungsDifferenzierung__c = instream.Id;
        update adType;

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        update adSpec; // dummy update to fetch new MediagattungsDifferenzierung
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidRotationstypBreaksMbl() {
        createTestInventory();

        ADvendio__Placement__c placement = [SELECT Id, Name FROM ADvendio__Placement__c WHERE Name = 'MBL Test Placement'][0];
        placement.SomDig_Rotationstyp__c = 'Themen-Rotation';
        update placement;

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidTkpFaehigkeitBreaksMbl() {
        createTestInventory();

        ADvendio__Placement__c placement = [SELECT Id, Name FROM ADvendio__Placement__c WHERE Name = 'MBL Test Placement'][0];
        placement.SomDig_TkpFaehig__c = false;
        update placement;

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidWbFaehigkeitBreaksMbl() {
        createTestInventory();

        ADvendio__Ad_Type__c adType = [SELECT Id, Name FROM ADvendio__Ad_Type__c WHERE Name = 'MBL Test AdType'][0];
        adType.SomDig_WbFaehig__c = false;
        update adType;

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void invalidWerbeformgruppeBreaksMbl() {
        createTestInventory();

        ADvendio__Ad_Type__c adType = [SELECT Id, Name FROM ADvendio__Ad_Type__c WHERE Name = 'MBL Test AdType'][0];
        adType.SomDig_Werbeformgruppe__c = 'Sonderwerbeform';
        update adType;

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPM';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(!result.isSuccess());
        System.assertEquals(result.getErrors()[0].getMessage(), Adv_AdPrice_Metabuchungslogik.ERROR_MSG);
    }

    static testMethod void debuggingModeAllowsAdPriceCreation() {
        insert new SomDig_Settings__c(SomDig_MetabuchungslogikDebugMode__c = true);

        createTestInventory();

        ADvendio__Ad_Specs__c adSpec = [SELECT Id, Name FROM ADvendio__Ad_Specs__c WHERE Name = 'MBL Test AdSpec'][0];
        ADvendio__Pricelist__c pricelist = [SELECT Id, Name FROM ADvendio__Pricelist__c WHERE Name = 'MBL Test Pricelist'][0];

        Test.startTest();

        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(false, adSpec, pricelist);
        adPrice.ADvendio__Billing_Category__c = 'CPW';
        Database.SaveResult result = Database.insert(adPrice, false);

        Test.stopTest();

        System.assert(result.isSuccess());
        adPrice = [SELECT SomDig_Metabuchungslogik__c FROM ADvendio__Ad_price__c WHERE Id = :adPrice.Id][0];
        System.assertEquals(null, adPrice.SomDig_Metabuchungslogik__c);
    }



    static void createTestInventory() {
        SomDig_MediagattungsDifferenzierung__c inpage = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true, 'InPage/Display');
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.Name = 'MBL Test Placement';
        placement.SomDig_BT__c = true;
        placement.SomDig_CpxFaehig__c = true;
        placement.SomDig_FC__c = true;
        placement.SomDig_GtFaehig__c = true;
        placement.SomDig_Rotationstyp__c = 'Brand-Rotation';
        placement.SomDig_TkpFaehig__c = true;
        insert placement;
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(false, inpage);
        adType.Name = 'MBL Test AdType';
        adType.SomDig_WbFaehig__c = true;
        adType.SomDig_Werbeformgruppe__c = 'Standard';
        insert adType;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(false, placement, adType);
        adSpec.Name = 'MBL Test AdSpec';
        insert adSpec;
        SomDig_Auftragstyp__c forschung = cls_P7S1_TestData.createTestAuftragstyp(true, 'Forschung');
        ADvendio__Pricelist__c pricelist = cls_P7S1_TestData.createTestPricelist(false, forschung);
        pricelist.Name = 'MBL Test Pricelist';
        insert pricelist;

        SomDig_Metabuchungslogik__c mbl = createTestMetabuchungslogik(false);
        mbl.Mig_ProdiaKey__c = '123';
        mbl.SomDig_Abrechnungsart__c = 'CPM;CPD';
        mbl.SomDig_Auftragstyp__c = forschung.Id;
        mbl.SomDig_BtFaehig__c = true;
        mbl.SomDig_CpxFaehig__c = true;
        mbl.SomDig_FcFaehig__c = true;
        mbl.SomDig_GtFaehig__c = true;
        mbl.SomDig_Mediagattungsdifferenzierung__c = inpage.Id;
        mbl.SomDig_Rotationstyp__c = 'Network-Rotation;Brand-Rotation';
        mbl.SomDig_TkpFaehig__c = true;
        mbl.SomDig_WbFaehig__c = true;
        mbl.SomDig_Werbeformgruppe__c = 'Standard';
        insert mbl;

        Adv_AdPrice_Metabuchungslogik.manuallyEnabledForTesting = true;
    }

    // TODO: move to cls_P7S1_TestData/P7S1_TestData
    public static SomDig_Metabuchungslogik__c Metabuchungslogik_TestData;
    public static SomDig_Metabuchungslogik__c createTestMetabuchungslogik(Boolean insertObject) {
        Metabuchungslogik_TestData = new SomDig_Metabuchungslogik__c();
        Metabuchungslogik_TestData.SomDig_IsActive__c = true;
        if (insertObject) insert Metabuchungslogik_TestData;
        return Metabuchungslogik_TestData;
    }

}