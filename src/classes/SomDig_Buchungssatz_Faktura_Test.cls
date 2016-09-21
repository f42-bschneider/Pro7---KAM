@isTest
public with sharing class SomDig_Buchungssatz_Faktura_Test {

    static SomDig_Sachkonto__c getSachkonto(String typ) {
        SomDig_Sachkonto__c sk  = new SomDig_Sachkonto__c();
        if ('barter'.equalsIgnoreCase(typ)) {
            sk.Name                             = 'Barter K';
            sk.SomDig_SammelIA__c               = 'Barter IA';
            sk.SomDig_SachkontoTyp__c			= SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_BARTER;
        }
        if ('intern'.equalsIgnoreCase(typ)) {
            sk.Name                             = 'Intern K';
            sk.SomDig_SammelIA__c               = 'Intern IA';
            sk.SomDig_SachkontoTyp__c			= SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_IC;
        }
        if ('media'.equalsIgnoreCase(typ)) {
            sk.Name                             = 'Media K';
            sk.SomDig_SammelIA__c               = 'Media IA';
            sk.SomDig_SachkontoTyp__c			= SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_INTERNET;
        }
        if ('nonmedia'.equalsIgnoreCase(typ)) {
            sk.Name                             = 'NonMediaK';
            sk.SomDig_SammelIA__c               = 'NonMediIA';
            sk.SomDig_SachkontoTyp__c			= SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_DIENSTLEISTUNGEN;
        }
        return sk;
    }

    static SomDig_MediagattungsSegment__c getMediagattungsSegment(String typ) {
        SomDig_MediagattungsSegment__c  mgs = cls_P7S1_TestData.createTestMediagattungsSegment(false, 'nonmedia'.equalsIgnoreCase(typ) ? 'Nonmedia' : 'Media Segment');
        return mgs;
    }

    static SomDig_Zahlungsbedingung__c getZahlungsbedingung() {
        SomDig_Zahlungsbedingung__c  zb = cls_P7S1_TestData.createTestZahlungsbedingung(false);
        return zb;
    }

    static Account getAccount(Boolean intern) {
        Account acc = new Account();
        acc.Name    = 'TestAccount'+String.valueOf(math.random()*1000);
        acc.P7S1_Konzernmitglied__c = intern;
        return acc;
    }

    static SomDig_Auftragstyp__c getAuftragstyp(String name) {
        return cls_P7S1_TestData.createTestAuftragstyp(false, name);
    }

    static ADvendio__Pricelist__c getPricelist(SomDig_Auftragstyp__c auftragstyp) {
        ADvendio__Pricelist__c plist    = cls_P7S1_TestData.createTestPricelist(false, auftragstyp);
        return plist;
    }

    static ADvendio__MediaCampaign__c getMediaCampaign(Account acc, ADvendio__Pricelist__c plist, SomDig_Zahlungsbedingung__c zahlungsbedingung) {
        ADvendio__MediaCampaign__c mc   = cls_P7S1_TestData.createTestMediaCampaign(false, acc, plist);
        mc.SomDig_Zahlungsbedingung__c  = zahlungsbedingung.Id;
        return mc;
    }

    static ADvendio__Placement__c getPlacement(SomDig_MediagattungsSegment__c mgs) {
        ADvendio__Placement__c pl   = cls_P7S1_TestData.createTestPlacement(false);
        pl.SomDig_Mediagattungssegment__c   = mgs.Id;
        return pl;
    }

    static ADvendio__Ad_Specs__c getAdSpec(ADvendio__Placement__c pl) {
        return cls_P7S1_TestData.createTestAdSpec(false, pl);
    }

    static ADvendio__Ad_price__c getAdPrice(ADvendio__Ad_Specs__c asp, ADvendio__Pricelist__c plist) {
        return cls_P7S1_TestData.createTestAdPrice(false, asp, plist);
    }

    static ADvendio__Campaign_Item__c getCampaignItem(ADvendio__MediaCampaign__c mc, ADvendio__Ad_Price__c ap) {
        ADvendio__Campaign_Item__c ci   = cls_P7S1_TestData.createTestCampaignItem(false, mc, ap);
        // ci.ADvendio__from_Date__c    = system.today().addMonths(1).toStartOfMonth();
        // ci.ADvendio__until_Date__c   = ci.ADvendio__from_Date__c.addDays(2);
        return ci;
    }

    static ADvendio__Invoice__c getInvoice(ADvendio__MediaCampaign__c mc) {
        ADvendio__Invoice__c inv    = cls_P7S1_TestData.createTestInvoice(false, mc);
        return inv;
    }

    static ADvendio__InvoiceItem__c getInvoiceItem(ADvendio__Invoice__c inv, ADvendio__Campaign_Item__c ci) {
        ADvendio__InvoiceItem__c ii = cls_P7S1_TestData.createTestInvoiceItem(false, inv, ci);
        ii.ADvendio__BookedQuantity__c		= 100000;
        ii.ADvendio__SalesPrice__c			= 10;
        ii.ADvendio__BillingCategory__c		= 'CPM';
        ii.ADvendio__FromDate__c			= system.today();
        ii.ADvendio__UntilDate__c			= system.today();
        return ii;
    }


    static ADvendio__Placement__c plMedia       = null;
    static ADvendio__Placement__c plNoMedia     = null;
    static Account accIntern    = null;
    static Account accExtern    = null;
    static SomDig_Auftragstyp__c auftBarter     = null;
    static SomDig_Auftragstyp__c auftNoBarter   = null;
    static ADvendio__Pricelist__c plistBarter   = null;
    static ADvendio__Pricelist__c plistNoBarter = null;
    static ADvendio__MediaCampaign__c mcInternBarter1   = null;
    static ADvendio__MediaCampaign__c mcInternNoBarter1 = null;
    static ADvendio__MediaCampaign__c mcExternBarter1   = null;
    static ADvendio__MediaCampaign__c mcExternNoBarter1 = null;
    static ADvendio__MediaCampaign__c mcExternNoBarter2 = null;
    static SomDig_MediagattungsSegment__c mgsMedia      = null;
    static SomDig_MediagattungsSegment__c mgsNoMedia    = null;
    static ADvendio__Ad_Specs__c asMedia        = null;
    static ADvendio__Ad_Specs__c asNoMedia      = null;
    static ADvendio__Ad_price__c priceNoMediaNoBarter   = null;
    static ADvendio__Ad_price__c priceNoMediaBarter     = null;
    static ADvendio__Ad_price__c priceMediaNoBarter     = null;
    static ADvendio__Ad_price__c priceMediaBarter       = null;
    static ADvendio__Campaign_Item__c mcInternBarter1_ciMedia1      = null;
    static ADvendio__Campaign_Item__c mcInternBarter1_ciMedia2      = null;
    static ADvendio__Campaign_Item__c mcInternNoBarter1_ciMedia1    = null;
    static ADvendio__Campaign_Item__c mcInternNoBarter1_ciMedia2    = null;
    static ADvendio__Campaign_Item__c mcExternBarter1_ciMedia1      = null;
    static ADvendio__Campaign_Item__c mcExternBarter1_ciMedia2      = null;
    static ADvendio__Campaign_Item__c mcExternNoBarter1_ciNoMedia1  = null;
    static ADvendio__Campaign_Item__c mcExternNoBarter1_ciNoMedia2  = null;
    static ADvendio__Campaign_Item__c mcExternNoBarter2_ciMedia1    = null;
    static ADvendio__Campaign_Item__c mcExternNoBarter2_ciNoMedia2  = null;

    static ADvendio__Invoice__c invoiceInternBarter     = null;
    static ADvendio__Invoice__c invoiceInternNoBarter   = null;
    static ADvendio__Invoice__c invoiceExternBarter     = null;
    static ADvendio__Invoice__c invoiceExternNoBarter   = null;
    static ADvendio__Invoice__c invoiceExternNoBarter2  = null;
    static ADvendio__InvoiceItem__c invoiceInternItemBarterMedia1       = null;
    static ADvendio__InvoiceItem__c invoiceInternItemBarterMedia2       = null;
    static ADvendio__InvoiceItem__c invoiceItemInternNoBarterMedia1     = null;
    static ADvendio__InvoiceItem__c invoiceItemInternNoBarterMedia2     = null;
    static ADvendio__InvoiceItem__c invoiceExternItemBarterMedia1       = null;
    static ADvendio__InvoiceItem__c invoiceExternItemBarterMedia2       = null;
    static ADvendio__InvoiceItem__c invoiceExternItemNoBarterNoMedia1   = null;
    static ADvendio__InvoiceItem__c invoiceExternItemNoBarterNoMedia2   = null;
    static ADvendio__InvoiceItem__c invoiceExternItemNoBarterMedia      = null;
    static ADvendio__InvoiceItem__c invoiceExternItemNoBarterNoMedia    = null;
    static SomDig_Sachkonto__c skBarter     = null;
    static SomDig_Sachkonto__c skIntern     = null;
    static SomDig_Sachkonto__c skMedia      = null;
    static SomDig_Sachkonto__c skNonMedia   = null;

    static void createTestData() {
        skBarter    = getSachkonto('barter');
        skIntern    = getSachkonto('intern');
        skMedia     = getSachkonto('media');
        skNonMedia  = getSachkonto('nonmedia');
        insert new List<SomDig_Sachkonto__c>{skBarter, skIntern, skMedia, skNonMedia};

        mgsNoMedia  = getMediagattungsSegment('nonmedia');
        mgsMedia    = getMediagattungsSegment('media');
        insert new List<SomDig_MediagattungsSegment__c>{mgsMedia, mgsNoMedia};

        plistBarter     = getPricelist(auftBarter);
        plistNoBarter   = getPricelist(auftNoBarter);
        insert new List<ADvendio__Pricelist__c>{plistBarter, plistNoBarter};

        plNoMedia   = getPlacement(mgsNoMedia);
        plMedia     = getPlacement(mgsMedia);
        insert new List<ADvendio__Placement__c>{plMedia, plNoMedia};

        asMedia     = getAdSpec(plMedia);
        asNoMedia   = getAdSpec(plNoMedia);
        insert new List<ADvendio__Ad_Specs__c>{asMedia, asNoMedia};

        priceMediaBarter        = getAdPrice(asMedia, plistBarter);
        priceMediaNoBarter      = getAdPrice(asMedia, plistNoBarter);
        priceNoMediaBarter      = getAdPrice(asNoMedia, plistBarter);
        priceNoMediaNoBarter    = getAdPrice(asNoMedia, plistNoBarter);
        insert new List<ADvendio__Ad_price__c>{priceMediaBarter, priceMediaNoBarter, priceNoMediaBarter, priceNoMediaNoBarter};

        accIntern   = getAccount(true);
        accExtern   = getAccount(false);
        insert new List<Account>{accIntern, accExtern};

        auftBarter      = getAuftragstyp('Barter');
        auftNoBarter    = getAuftragstyp('NoBarter');
        insert new List<SomDig_Auftragstyp__c>{auftBarter, auftNoBarter};


        SomDig_Zahlungsbedingung__c zahlungsbedingung = getZahlungsbedingung();
        mcInternBarter1     = getMediaCampaign(accIntern, plistBarter, zahlungsbedingung);
        mcInternNoBarter1   = getMediaCampaign(accIntern, plistNoBarter, zahlungsbedingung);
        mcExternBarter1     = getMediaCampaign(accExtern, plistBarter, zahlungsbedingung);
        mcExternNoBarter1   = getMediaCampaign(accExtern, plistNoBarter, zahlungsbedingung);
        mcExternNoBarter2   = getMediaCampaign(accExtern, plistNoBarter, zahlungsbedingung);
        insert new List<ADvendio__MediaCampaign__c>{mcInternBarter1, mcInternNoBarter1, mcExternBarter1, mcExternNoBarter1, mcExternNoBarter2};

        mcInternBarter1_ciMedia1        = getCampaignItem(mcInternBarter1, priceMediaBarter);
        mcInternBarter1_ciMedia2        = getCampaignItem(mcInternBarter1, priceMediaBarter);

        mcInternNoBarter1_ciMedia1      = getCampaignItem(mcInternNoBarter1, priceMediaNoBarter);
        mcInternNoBarter1_ciMedia2      = getCampaignItem(mcInternNoBarter1, priceMediaNoBarter);

        mcExternBarter1_ciMedia1        = getCampaignItem(mcExternBarter1, priceMediaBarter);
        mcExternBarter1_ciMedia2        = getCampaignItem(mcExternBarter1, priceMediaBarter);

        mcExternNoBarter1_ciNoMedia1    = getCampaignItem(mcExternNoBarter1, priceNoMediaNoBarter);
        mcExternNoBarter1_ciNoMedia2    = getCampaignItem(mcExternNoBarter1, priceNoMediaNoBarter);

        mcExternNoBarter2_ciMedia1      = getCampaignItem(mcExternNoBarter2, priceMediaNoBarter);
        mcExternNoBarter2_ciNoMedia2    = getCampaignItem(mcExternNoBarter2, priceNoMediaNoBarter);

        insert new List<ADvendio__Campaign_Item__c>{
                                                    mcInternBarter1_ciMedia1, mcInternBarter1_ciMedia2,
                                                    mcInternNoBarter1_ciMedia1, mcInternNoBarter1_ciMedia2,
                                                    mcExternBarter1_ciMedia1, mcExternBarter1_ciMedia2,
                                                    mcExternNoBarter1_ciNoMedia1, mcExternNoBarter1_ciNoMedia2,
                                                    mcExternNoBarter2_ciMedia1, mcExternNoBarter2_ciNoMedia2
                                                   };

       invoiceInternBarter      = getInvoice(mcInternBarter1);
       invoiceInternNoBarter    = getInvoice(mcInternNoBarter1);
       invoiceExternBarter      = getInvoice(mcExternBarter1);
       invoiceExternNoBarter    = getInvoice(mcExternNoBarter1);
       invoiceExternNoBarter2   = getInvoice(mcExternNoBarter2);
       insert new List<ADvendio__Invoice__c>{
                                                    invoiceInternBarter, invoiceInternNoBarter,
                                                    invoiceExternBarter, invoiceExternNoBarter,
                                                    invoiceExternNoBarter2
                                                   };

       invoiceInternItemBarterMedia1        = getInvoiceItem(invoiceInternBarter, mcInternBarter1_ciMedia1);
       invoiceInternItemBarterMedia2        = getInvoiceItem(invoiceInternBarter, mcInternBarter1_ciMedia2);

       invoiceItemInternNoBarterMedia1      = getInvoiceItem(invoiceInternNoBarter, mcInternNoBarter1_ciMedia1);
       invoiceItemInternNoBarterMedia2      = getInvoiceItem(invoiceInternNoBarter, mcInternNoBarter1_ciMedia2);

       invoiceExternItemBarterMedia1        = getInvoiceItem(invoiceExternBarter, mcExternBarter1_ciMedia1);
       invoiceExternItemBarterMedia2        = getInvoiceItem(invoiceExternBarter, mcExternBarter1_ciMedia2);

       invoiceExternItemNoBarterNoMedia1    = getInvoiceItem(invoiceInternBarter, mcExternNoBarter1_ciNoMedia1);
       invoiceExternItemNoBarterNoMedia2    = getInvoiceItem(invoiceInternBarter, mcExternNoBarter1_ciNoMedia2);

       invoiceExternItemNoBarterMedia       = getInvoiceItem(invoiceInternBarter, mcExternNoBarter2_ciMedia1);
       invoiceExternItemNoBarterNoMedia     = getInvoiceItem(invoiceInternBarter, mcExternNoBarter2_ciNoMedia2);
     
       insert new List<ADvendio__InvoiceItem__c>{
                                                    invoiceInternItemBarterMedia1, invoiceInternItemBarterMedia2,
                                                    invoiceItemInternNoBarterMedia1, invoiceItemInternNoBarterMedia2,
                                                    invoiceExternItemBarterMedia1, invoiceExternItemBarterMedia2,
                                                    invoiceExternItemNoBarterNoMedia1, invoiceExternItemNoBarterNoMedia2,
                                                    invoiceExternItemNoBarterMedia, invoiceExternItemNoBarterNoMedia
                                                   };

       

    }
    @isTest
    static void testBuchungssatzFaktura() {

        createTestData();


        //Account acc = cls_P7S1_TestData.createTestAccount(true);

        P7S1_ExternalId__c ext = new P7S1_ExternalId__c(Name='123', P7S1_Account__c=accExtern.Id, P7S1_Source__c='Debitorennr BK 29');
        insert ext;

        //ADvendio__MediaCampaign__c mc = cls_P7S1_TestData.createTestMediaCampaign(false);
        mcExternNoBarter1.ADvendio__invoice_recipient__c = accExtern.Id;
        update mcExternNoBarter1;

        List<ADvendio__Invoice__c> invs;

        // Invoice 1
        //ADvendio__Invoice__c inv = cls_P7S1_TestData.createTestInvoice(true, mc);
        invoiceInternNoBarter.ADvendio__Status__c = 'Invoiced';
        invoiceInternNoBarter.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c = true;
        update invoiceInternNoBarter;

        // Invoice 2
        //ADvendio__Invoice__c inv2 = cls_P7S1_TestData.createTestInvoice(true, mc);
        invoiceExternBarter.ADvendio__Status__c = 'Canceled';
        invoiceExternBarter.SomDig_Auftragstyp__c = 'Barter';
        update invoiceExternBarter;

        // Invoice 3
        //ADvendio__Invoice__c inv3 = cls_P7S1_TestData.createTestInvoice(true, mc);
        invs = new List<ADvendio__Invoice__c>{invoiceInternNoBarter,invoiceExternBarter,invoiceExternNoBarter};

 
        Test.startTest(); 
        SomDig_Buchungssatz_Faktura faktura = new SomDig_Buchungssatz_Faktura();
        List<ADvendio__Invoice__c> invoices = Database.query(faktura.batchBaseQuery);
        faktura.start(invoices);


        for (ADvendio__Invoice__c invoice : [SELECT Id, SomDig_FakturaBuchungssaetzeEnthalten__c FROM ADvendio__Invoice__c WHERE Id IN (:invoiceInternNoBarter.Id,:invoiceExternBarter.Id,:invoiceExternNoBarter.Id)]) {
            if (invoice.Id == invoiceInternNoBarter.Id || invoice.Id == invoiceExternBarter.Id) {
                System.assert(invoice.SomDig_FakturaBuchungssaetzeEnthalten__c);
            } else {
                System.assert(!invoice.SomDig_FakturaBuchungssaetzeEnthalten__c); // No Buchungssatz for inv3
            }
        }
        System.assertEquals(2, [SELECT Id FROM SomDig_Buchungssatz__c].size());

        // Code Coverage
        Database.executeBatch(faktura);
        Test.stopTest();           
        

    }

    @isTest
    public static void testSAPDateiUpload() {
        createTestData();
        SomDig_Buchungssatz__c bs1 = new SomDig_Buchungssatz__c(
                SomDig_VerrechnungsmonatSAP__c = '1505',
                RecordTypeId=Schema.SObjectType.SomDig_Buchungssatz__c.getRecordTypeInfosByName().get('Faktura').getRecordTypeId(),
                SomDig_Buchungskreis__c = '1234');
        insert new List<SomDig_Buchungssatz__c>{bs1};

        SomDig_SapDatei__c sapDatei0 = new SomDig_SapDatei__c(SomDig_Monat__c='05', SomDig_Jahr__c='2015', SomDig_Buchungskreis__c='1234', SomDig_Nummer__c='0001');
        SomDig_SapDatei__c sapDatei1 = new SomDig_SapDatei__c(SomDig_Monat__c='05', SomDig_Jahr__c='2015', SomDig_Buchungskreis__c='1234');
        insert new List<SomDig_SapDatei__c>{sapDatei0, sapDatei1};

        Test.startTest();
        SomDig_SapDatei.buchungssaetzeZuweisen(sapDatei1.Id);
        SomDig_SapDatei.setUploadStatus(sapDatei1.Id);
        Test.stopTest();

        sapDatei1 = [SELECT Id, SomDig_Status__c, SomDig_Nummer__c FROM SomDig_SapDatei__c WHERE Id = :sapDatei1.Id];
        System.assertEquals('Übermittlung', sapDatei1.SomDig_Status__c);
        System.assertEquals('0002', sapDatei1.SomDig_Nummer__c);
    }

}