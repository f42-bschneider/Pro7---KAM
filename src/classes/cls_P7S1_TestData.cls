/****************************************************************************
/*  NAME        cls_P7S1_TestData
/*  CREATED     2014-11-18
/*  AUTHOR      P7S1 for0001t
/*  DESCRIPTION Provides Testdata for ALL Testclasses
/*              All needed fields for valid data are provided
/*              Maintenance is done by P7S1 APP
/*              Testclasses must not create their own testdata !!!
/*  USAGE       To create a specific object call the createXXXXX method
/*              With parameters you can control the insert and related data
/*              if no parameters for related data are selected,
/*              a default set of onjects is created automatically
/*  CHANGES     2014-xx-xx usr0123x: ...
/*
/*****************************************************************************/

public with sharing class cls_P7S1_TestData {

    /***** Basisdaten *****/
    public static Account Account_TestData;
    public static SomDig_WtAgBeziehung__c WTAGBeziehung_TestData;
        public static SomDig_Commitment__c SomDigCommitment_TestData;
    public static P7S1_ExternalId__c ExternalId_TestData;
    public static Contact Contact_TestData;
    public static Case Case_TestData;
    public static SomDig_BetreuerTeam__c BetreuerTeam_TestData;
    public static Task task_TestData;

    /***** Firma, Mitarbeiter, Kontaktbericht *****/
    public static P7S1_Comp__c Firma_TestData;
    public static P7S1_Emp__c Mitarbeiter_TestData;
    public static Som_Kontaktbericht__c Kontaktbericht_TestData;
    public static Som_KontaktberichtContact__c KontaktberichtTeilnehmer_TestData;

    /***** Products, Opportunities *****/
    public static Product2 Product2_TestData;
    public static PricebookEntry PricebookEntry_TestData;
    public static Opportunity Opportunity_TestData;
    public static OpportunityLineItem OpportunityLineItem_TestData;

    /***** Konfiguration *****/
    public static SomDig_Zahlungsbedingung__c Zahlungsbedingung_TestData;
    public static SomDig_Auftragstyp__c Auftragstyp_TestData;
    public static ADvendio__Pricelist__c Pricelist_TestData;
    public static SomDig_DeliverPrio__c Auslieferungsprioritaet_TestData;

    /***** Klassifizierung *****/
    public static SomDig_Mediagattung__c Mediagattung_TestData;
    public static SomDig_MediagattungsSegment__c MediagattungsSegment_TestData;
    public static SomDig_MediagattungsDifferenzierung__c MediagattungsDifferenzierung_TestData;

    /***** Inventar, Kampagnen, Positionen, Rechnungen *****/
    public static ADvendio__MediaCampaign__c MediaCampaign_TestData;
    public static ADvendio__Site__c Site_TestData;
    public static ADvendio__Placement__c Placement_TestData;
    public static ADvendio__Ad_Type__c AdType_TestData;
    public static ADvendio__Ad_Specs__c AdSpec_TestData;
    public static ADvendio__Ad_price__c AdPrice_TestData;
    public static ADvendio__Campaign_Item__c CampaignItem_TestData;
    public static ADvendio__Invoice__c Invoice_TestData;
    public static ADvendio__InvoiceItem__c InvoiceItem_TestData;

    /***** Keys, Values, AdServer *****/
    public static ADvendio__AdServer_Logins__c AdServerLogin_TestData;
    public static ADvendio__AdServer_ID__c AdServerID_TestData;
    public static ADvendio__KeyLine__c KeyLine_TestData;
    public static ADvendio__Key__c Key_TestData;
    public static ADvendio__KeyValue__c KeyValue_TestData;
    public static ADvendio__KeyAdPriceAssignment__c KeyAdPriceAssignment_TestData;

    /***** GeoTargeting *****/
    public static Advendio__Country__c Country_TestData;
    public static Advendio__Region__c Region_TestData;
    public static Advendio__City__c City_TestData;
    public static Advendio__Areacode__c Areacode_TestData;
    public static Advendio__Selected_Country__c SelectedCountry_TestData;
    public static Advendio__Selected_Region__c SelectedRegion_TestData;
    public static Advendio__Selected_City__c SelectedCity_TestData;
    public static Advendio__Selected_Areacode__c SelectedAreacode_TestData;

    /***** Ventures *****/
    public static Ven_Key_Performance_Indicator__c kpi_TestData;
    public static Ven_KeyPerformanceIndicatorBlock__c kpiBlock_TestData;
    public static Ven_KeyPerformanceIndicatorBlockEntry__c kpiBlockEntry_TestData;
    public static Ven_KeyPerformanceIndicatorTemplate__c kpiTemplate_TestData;
    public static Ven_KeyPerformanceIndicatorTemplateEntry__c kpiTemplateEntry_TestData;
    public static Ven_Financial_Model_Version__c financialModelVersion_TestData;
    public static Ven_Financial_Model_Data__c financialModelData_TestData;

    /****** SOM KAM******/
    public static Som_Kam__c AccountPlan_TestData;
    public static Som_KamDetail__c AccountPlanDetail_TestData;
    public static Som_KamDetailCashIn__c AccountPlanDetailCashIn_TestData;
    public static Som_KamTeam__c AccountPlanTeam_TestData;
    public static Som_KamAccountCashIn__c AnnualAccountCashIn_TestData;
    public static Som_KamAccountCashInDetail__c AnnualAccountCashInDetail_TestData;
    public static Som_KamStrategyProfileTopic__c StrategyProfileTopic_TestData;

    // Map with user ids generated from active testusers - one per profile and sphere - which work in all Instances
    public static Map<String, Id> USER_MAP_PROFILE = new Map<String, Id>();
    public static Map<String, Id> USER_MAP_SPHERE = new Map<String, Id>();
    public static Map<String, User> USER_FOR_PROFILE = new Map<String, User>();
    public static Map<String, User> USER_FOR_SPHERE = new Map<String, User>();
    static {
        for (User u : [Select Id, IsActive, Name, P7S1_Sphere__c, ProfileId, Profile.Name, Username from User where isActive = true and P7S1_UserType__c = 'system_tester']) {
            USER_MAP_PROFILE.put(u.Profile.Name, u.Id);
            USER_MAP_SPHERE.put(u.P7S1_Sphere__c, u.Id);
            USER_FOR_PROFILE.put(u.Profile.Name, u);
            USER_FOR_SPHERE.put(u.P7S1_Sphere__c, u);
        }
    }



    /***** Basisdaten *****/
    public static Account createTestAccount(Boolean insertObject) {
        return createTestAccount(insertObject, null, null);
    }
    public static Account createTestAccount(Boolean insertObject, String P7S1_Sphere) {
        return createTestAccount(insertObject, P7S1_Sphere, null);
    }
    public static Account createTestAccount(Boolean insertObject, String P7S1_Sphere, Id recordTypeId) {
        Account_TestData = new Account();
        Account_TestData.Name = 'Test Account';
        Account_TestData.BillingCountry = 'Germany';
        Account_TestData.BillingCity = 'Unterföhring';
        Account_TestData.BillingPostalCode = '85774';
        Account_TestData.Phone = '+49 89 9507 1234';
        if (P7S1_Sphere != null) Account_TestData.OwnerId = [Select Id from User where P7S1_Sphere__c = :P7S1_Sphere and isActive = true limit 1].Id;
        if (recordTypeId != null) Account_TestData.RecordTypeId = recordTypeId;
        if (insertObject) {
            insert Account_TestData;
            createTestExternalId(true, Account_TestData);
        }
        return Account_TestData;
    }

    public static SomDig_WtAgBeziehung__c createTestWTAG(Boolean insertObject, Account WT, Account AG) {
        WTAGBeziehung_TestData = new SomDig_WtAgBeziehung__c();
        WTAGBeziehung_TestData.SomDig_Werbetreibender__c = (WT == null) ? createTestAccount(true).Id : WT.Id;
        WTAGBeziehung_TestData.SomDig_Agentur__c = (AG == null) ? createTestAccount(true).Id : AG.Id;
        WTAGBeziehung_TestData.SomDig_BeziehungInhaber__c = Userinfo.getUserId();
        if (insertObject) insert WTAGBeziehung_TestData;
        return WTAGBeziehung_TestData;
    }

      public static SomDig_Commitment__c createSomDigCommitment(Boolean insertObject, SomDig_WtAgBeziehung__c p_oWtAg) {
        SomDigCommitment_TestData = new SomDig_Commitment__c();
                SomDigCommitment_TestData.SomDig_UmsatzGesamtMN2__c = 123456;

        SomDigCommitment_TestData.SomDig_WtAgBeziehung__c = p_oWtAg.Id;
        if (insertObject) insert SomDigCommitment_TestData;
        return SomDigCommitment_TestData;
    }

    public static P7S1_ExternalId__c createTestExternalId(Boolean insertObject, Account account) {
        ExternalId_TestData = new P7S1_ExternalId__c();
        ExternalId_TestData.Name = '9'+(Math.random()*1000000).round();
        ExternalId_TestData.P7S1_Account__c = (account == null) ? createTestAccount(true).Id : account.Id;
        ExternalId_TestData.P7S1_Source__c = 'Debitorennr BK 29';
        ExternalId_TestData.P7S1_Description__c = 'Test External Id for Account as Debitor';
        ExternalId_TestData.P7S1_ExtIdUniqueKey__c = ExternalId_TestData.Som_DwhSource__c + ExternalId_TestData.Name;
        if (insertObject) insert ExternalId_TestData;
        return ExternalId_TestData;
    }

    public static Contact createTestContact(Boolean insertObject) {
        return createTestContact(insertObject, null);
    }
    public static Contact createTestContact(Boolean insertObject, Account account) {
        Contact_TestData = new Contact();
        Contact_TestData.LastName = 'Contact-Test';
        Contact_TestData.LeadSource = 'Email';
        Contact_TestData.AccountId = (account == null) ? createTestAccount(true).Id : account.Id;
        if (insertObject) insert Contact_TestData;
        return Contact_TestData;
    }

    public static Case createTestCase(Boolean insertObject) {
        return createTestCase(insertObject, null);
    }
    public static Case createTestCase(Boolean insertObject, Id recordTypeId) {
        Case_TestData = new Case();
        Case_TestData.Subject = 'Test Case';
        Case_TestData.Description = 'Just for Testing Purposes';
        Case_TestData.Status = 'Neu';
        Case_TestData.Type = 'Problem';
        if (recordTypeId != null) Case_TestData.RecordTypeId = recordTypeId;
        if (insertObject) insert Case_TestData;
        return Case_TestData;
    }

    public static SomDig_BetreuerTeam__c createTestBetreuerTeam(Boolean insertObject) {
        BetreuerTeam_TestData = new SomDig_BetreuerTeam__c();
        BetreuerTeam_TestData.Name = 'Test Team 1';
        BetreuerTeam_TestData.SomDig_BetreuerVermarkter__c = '71M';
        if (insertObject) insert BetreuerTeam_TestData;
        return BetreuerTeam_TestData;
    }

    public static Task createTestTask(Boolean insertObject){
        task_TestData = new Task();
        task_TestData.Subject = 'Test Task';
        task_TestData.Description = 'Test Description';
        task_TestData.ActivityDate = System.today();
        if (insertObject) insert task_TestData;
        return task_TestData;
    }
    /***** Basisdaten *****/



    /***** Firma, Mitarbeiter, Kontaktbericht *****/
    public static P7S1_Comp__c createTestFirma(Boolean insertObject) {
        return createTestFirma(insertObject, null);
    }
    public static P7S1_Comp__c createTestFirma(Boolean insertObject, Account account) {
        Firma_TestData = new P7S1_Comp__c();
        Firma_TestData.P7S1_Account__c = (account == null) ? createTestAccount(true).Id : account.Id;
        if (insertObject) insert Firma_TestData;
        return Firma_TestData;
    }

    public static P7S1_Emp__c createTestMitarbeiter(Boolean insertObject, User user) {
        return createTestMitarbeiter(insertObject, null, user);
    }
    public static P7S1_Emp__c createTestMitarbeiter(Boolean insertObject, P7S1_Comp__c firma) {
        return createTestMitarbeiter(insertObject, firma, null);
    }
    public static P7S1_Emp__c createTestMitarbeiter(Boolean insertObject, P7S1_Comp__c firma, User user) {
        Mitarbeiter_TestData = new P7S1_Emp__c();
        Mitarbeiter_TestData.P7S1_Comp__c = (firma != null) ? firma.Id : createTestFirma(true).Id;
        Mitarbeiter_TestData.P7S1_User__c = (user != null) ? user.Id : null;
        Mitarbeiter_TestData.P7S1_Profile__c = (user != null) ? user.Profile.Name : 'P7S1_NoRights';
        Mitarbeiter_TestData.P7S1_IsActive__c = true;
        Mitarbeiter_TestData.P7S1_Sync__c = false;
        Mitarbeiter_TestData.P7S1_Username__c = 'joe.tester' + String.valueOf(Math.random()) + '@p7s1applications.de';
        Mitarbeiter_TestData.P7S1_Email__c = Mitarbeiter_TestData.P7S1_Username__c;
        Mitarbeiter_TestData.P7S1_Firstname__c = 'Joe';
        Mitarbeiter_TestData.P7S1_Lastname__c = 'Tester';
        if (insertObject) insert Mitarbeiter_TestData;
        return Mitarbeiter_TestData;
    }

    public static P7S1_Emp__c createTestMitarbeiterWithContact(Contact contact) {
        return createTestMitarbeiterWithUserAndContact(null, null, contact);
    }
    public static P7S1_Emp__c createTestMitarbeiterWithUserAndContact(User user, Contact contact) {
        return createTestMitarbeiterWithUserAndContact(null, user, contact);
    }
    public static P7S1_Emp__c createTestMitarbeiterWithUserAndContact(P7S1_Comp__c firma, User user, Contact contact) {
        Mitarbeiter_TestData = createTestMitarbeiter(false, firma, user);
        Mitarbeiter_TestData.P7S1_Comp__c = (firma != null) ? firma.Id : createTestFirma(true).Id;
        Mitarbeiter_TestData.P7S1_Contact__c = contact.Id;
        if (contact.Email != null) {
            Mitarbeiter_TestData.P7S1_Username__c = contact.Email;
            Mitarbeiter_TestData.P7S1_Email__c = contact.Email;
        }
        if (contact.LastName != null)
            Mitarbeiter_TestData.P7S1_Lastname__c = contact.LastName;
        insert Mitarbeiter_TestData;
        contact.P7S1_Emp__c = Mitarbeiter_TestData.Id;
        update contact;
        return Mitarbeiter_TestData;
    }

    public static Som_Kontaktbericht__c createTestKontaktbericht(Boolean insertObject, Contact contact, User user, String reason, Datetime timestamp) {
        if (contact == null) contact = createTestContact(true);
        if (reason == null) reason = 'Telefonat';
        if (timestamp == null) timestamp = Datetime.now();
        Kontaktbericht_TestData = new Som_Kontaktbericht__c();
        Kontaktbericht_TestData.Som_Contact__c = contact.Id;
        Kontaktbericht_TestData.Som_Account__c = contact.AccountId;
        Kontaktbericht_TestData.Som_GrundDesKontakts__c = reason;
        Kontaktbericht_TestData.Som_Datum__c = timestamp;
        Kontaktbericht_TestData.Som_Beschreibung__c = reason + ' / ' + timestamp.format();
        Kontaktbericht_TestData.OwnerId = (user == null) ? USER_FOR_SPHERE.get('SomDe').Id : user.Id;
        if (insertObject) insert Kontaktbericht_TestData;
        return Kontaktbericht_TestData;
    }

    public static Som_KontaktberichtContact__c createTestKontaktberichtTeilnehmer(Boolean insertObject, Som_Kontaktbericht__c kb, Contact contact) {
        KontaktberichtTeilnehmer_TestData = new Som_KontaktberichtContact__c();
        KontaktberichtTeilnehmer_TestData.Som_Kontaktbericht__c = kb.Id;
        KontaktberichtTeilnehmer_TestData.Som_Contact__c = contact.Id;
        if (insertObject) insert KontaktberichtTeilnehmer_TestData;
        return KontaktberichtTeilnehmer_TestData;
    }
    /***** Firma, Mitarbeiter, Kontaktbericht *****/



    /***** Products, Opportunities *****/
    public static Product2 createTestProduct2(Boolean insertObject) {
        Product2_TestData = new Product2();
        Product2_TestData.Name = 'Test Product2';
        Product2_TestData.IsActive = true;
        Product2_TestData.SomTv_GAinnerhalbCommitment__c = '1104';
        Product2_TestData.SomTv_GAausserhalbCommitment__c = '1130';
        if (insertObject) insert Product2_TestData;
        return Product2_TestData;
    }

    public static PricebookEntry createTestPricebookEntry(Boolean insertObject) {
        return createTestPricebookEntry(insertObject, null);
    }
    public static PricebookEntry createTestPricebookEntry(Boolean insertObject, Product2 product2) {
        PricebookEntry_TestData = new PricebookEntry();
        PricebookEntry_TestData.Pricebook2Id = Test.getStandardPricebookId();
        PricebookEntry_TestData.Product2Id = (product2 == null) ? createTestProduct2(true).Id : product2.Id;
        PricebookEntry_TestData.UnitPrice = 20;
        PricebookEntry_TestData.IsActive = true;
        if (insertObject) insert PricebookEntry_TestData;
        return PricebookEntry_TestData;
    }

    public static Opportunity createTestOpportunity(Boolean insertObject) {
        return createTestOpportunity(insertObject, null, null);
    }
    public static Opportunity createTestOpportunity(Boolean insertObject, Account account) {
        return createTestOpportunity(insertObject, account, null);
    }
    public static Opportunity createTestOpportunity(Boolean insertObject, RecordType recordtype) {
        return createTestOpportunity(insertObject, null, recordtype);
    }
    public static Opportunity createTestOpportunity(Boolean insertObject, Account account, RecordType recordtype) {
        Opportunity_TestData = new Opportunity();
        Opportunity_TestData.Name = 'Test Opportunity';
        Opportunity_TestData.AccountId = (account == null) ? createTestAccount(true).Id : account.Id;
        Opportunity_TestData.CloseDate = Date.today();
        Opportunity_TestData.StageName = 'Potential';
        if (recordtype != null) Opportunity_TestData.RecordTypeId = recordtype.Id;
        if (insertObject) insert Opportunity_TestData;
        return Opportunity_TestData;
    }

    public static OpportunityLineItem createTestOpportunityLineItem(Boolean insertObject) {
        return createTestOpportunityLineItem(insertObject, null, null);
    }
    public static OpportunityLineItem createTestOpportunityLineItem(Boolean insertObject, Opportunity opportunity) {
        return createTestOpportunityLineItem(insertObject, opportunity, null);
    }
    public static OpportunityLineItem createTestOpportunityLineItem(Boolean insertObject, PricebookEntry pricebook_entry) {
        return createTestOpportunityLineItem(insertObject, null, pricebook_entry);
    }
    public static OpportunityLineItem createTestOpportunityLineItem(Boolean insertObject, Opportunity opportunity, PricebookEntry pricebook_entry) {
        OpportunityLineItem_TestData = new OpportunityLineItem();
        OpportunityLineItem_TestData.OpportunityId = (opportunity == null) ? createTestOpportunity(true).Id : opportunity.Id;
        OpportunityLineItem_TestData.PricebookEntryId = (pricebook_entry == null) ? createTestPricebookEntry(true).Id : pricebook_entry.Id;
        OpportunityLineItem_TestData.Quantity = 1;
        OpportunityLineItem_TestData.UnitPrice = 30;
        OpportunityLineItem_TestData.SomTv_DispoPreisprozent__c = 0.0;
        OpportunityLineItem_TestData.SomTv_MN3_1FS__c = 25;
        if (insertObject) insert OpportunityLineItem_TestData;
        return OpportunityLineItem_TestData;
    }
    /***** Products, Opportunities *****/



    /***** Konfiguration *****/
    public static SomDig_Zahlungsbedingung__c createTestZahlungsbedingung(Boolean insertObject) {
        Zahlungsbedingung_TestData = new SomDig_Zahlungsbedingung__c();
        Zahlungsbedingung_TestData.Name = 'Test innerhalb von 14 Tagen 2 %, innerhalb von 30 Tagen ohne Abzug';
        Zahlungsbedingung_TestData.SomDig_SAPCode__c = 'ZB01';
        Zahlungsbedingung_TestData.SomDig_Skontowert__c = 1.0;
        if (insertObject) insert Zahlungsbedingung_TestData;
        return Zahlungsbedingung_TestData;
    }

    public static SomDig_Auftragstyp__c createTestAuftragstyp(Boolean insertObject) {
        return createTestAuftragstyp(true, 'Test Auftragstyp 1');
    }
    public static SomDig_Auftragstyp__c createTestAuftragstyp(Boolean insertObject, String name) {
        Auftragstyp_TestData = new SomDig_Auftragstyp__c();
        Auftragstyp_TestData.Name = name;
        Auftragstyp_TestData.SomDig_Rechnungstellung__c = true;
        Auftragstyp_TestData.SomDig_Agenturprovision__c = true;
        Auftragstyp_TestData.SomDig_NullwertMediakampagne__c = false;
        Auftragstyp_TestData.SomDig_StrukturierteUeberlieferung__c = false;
        if (insertObject) insert Auftragstyp_TestData;
        return Auftragstyp_TestData;
    }

    public static ADvendio__Pricelist__c createTestPricelist(Boolean insertObject) {
        return createTestPricelist(insertObject, null);
    }
    public static ADvendio__Pricelist__c createTestPricelist(Boolean insertObject, SomDig_Auftragstyp__c auftragstyp) {
        Pricelist_TestData = new ADvendio__Pricelist__c();
        Pricelist_TestData.Name = 'Test Digital Standard ' + Date.Today().year();
        Pricelist_TestData.SomDig_AuftragstypId__c = (auftragstyp == null) ? createTestAuftragstyp(true).Id : auftragstyp.Id;
        Pricelist_TestData.SomDig_DWHGeschaeftsart__c = '';
        Pricelist_TestData.ADvendio__Valid_from__c = Date.valueOf(Datetime.now().format('YYYY') + '-01-01');
        Pricelist_TestData.ADvendio__Valid_to__c = Date.valueOf(Datetime.now().format('YYYY') + '-12-31');
        if (insertObject) insert Pricelist_TestData;
        return Pricelist_TestData;
    }

    public static SomDig_DeliverPrio__c createTestAuslieferungsprioritaet(Boolean insertObject, SomDig_Mediagattungsdifferenzierung__c mediagattungsDifferenzierung, SomDig_Auftragstyp__c auftragstyp) {
        Auslieferungsprioritaet_TestData = new SomDig_DeliverPrio__c();
        Auslieferungsprioritaet_TestData.SomDig_Mediagattungsdifferenzierung__c = (mediagattungsDifferenzierung == null) ? createTestMediagattungsDifferenzierung(true).Id : mediagattungsDifferenzierung.Id;
        Auslieferungsprioritaet_TestData.SomDig_Auftragstyp__c = (auftragstyp == null) ? createTestAuftragstyp(true).Id : auftragstyp.Id;
        Auslieferungsprioritaet_TestData.SomDig_Gueltig_ab__c = Date.today();
        Auslieferungsprioritaet_TestData.SomDig_Gueltig_bis__c = Date.today().addDays(1);
        Auslieferungsprioritaet_TestData.SomDig_Abrechungsart__c = 'CPM';
        Auslieferungsprioritaet_TestData.SomDig_Belegungseinheitstyp__c = '71m intern';
        Auslieferungsprioritaet_TestData.SomDig_Ad_Type__c = 'Sponsorship';
        Auslieferungsprioritaet_TestData.SomDig_Preistyp_zur_Auslieferung__c = 'Evenly';
        if (insertObject) insert Auslieferungsprioritaet_TestData;
        return Auslieferungsprioritaet_TestData;
    }
    /***** Konfiguration *****/



    /***** Klassifizierung *****/
    public static SomDig_Mediagattung__c createTestMediagattung(Boolean insertObject) {
        return createTestMediagattung(insertObject, 'Test Mediagattung 1');
    }
    public static SomDig_Mediagattung__c createTestMediagattung(Boolean insertObject, String name) {
        Mediagattung_TestData = new SomDig_Mediagattung__c();
        Mediagattung_TestData.Name = name;
        if (insertObject) insert Mediagattung_TestData;
        return Mediagattung_TestData;
    }
    public static SomDig_MediagattungsDifferenzierung__c createTestMediagattungsDifferenzierung(Boolean insertObject) {
        return createTestMediagattungsDifferenzierung(insertObject, 'Test MgDiff 1');
    }
    public static SomDig_MediagattungsDifferenzierung__c createTestMediagattungsDifferenzierung(Boolean insertObject, String name) {
        MediagattungsDifferenzierung_TestData = new SomDig_MediagattungsDifferenzierung__c();
        MediagattungsDifferenzierung_TestData.Name = name;
        if (insertObject) insert MediagattungsDifferenzierung_TestData;
        return MediagattungsDifferenzierung_TestData;
    }
    public static SomDig_MediagattungsSegment__c createTestMediagattungsSegment(Boolean insertObject) {
        return createTestMediagattungsSegment(insertObject, 'Test MediagattungsSegment 1');
    }
    public static SomDig_MediagattungsSegment__c createTestMediagattungsSegment(Boolean insertObject, String name) {
        MediagattungsSegment_TestData = new SomDig_MediagattungsSegment__c();
        MediagattungsSegment_TestData.Name = name;
        if (insertObject) insert MediagattungsSegment_TestData;
        return MediagattungsSegment_TestData;
    }
    /***** Klassifizierung *****/



    /***** Inventar, Kampagnen, Positionen, Rechnungen *****/
    public static ADvendio__MediaCampaign__c createTestMediaCampaign(Boolean insertObject) {
        return createTestMediaCampaign(insertObject, null, null, null);
    }
    public static ADvendio__MediaCampaign__c createTestMediaCampaign(Boolean insertObject, SomDig_WtAgBeziehung__c WTAG) {
        return createTestMediaCampaign(insertObject, null, null, WTAG);
    }
    public static ADvendio__MediaCampaign__c createTestMediaCampaign(Boolean insertObject, Account invoiceAccount, ADvendio__Pricelist__c pricelist) {
        return createTestMediaCampaign(insertObject, invoiceAccount, pricelist, null);
    }
    public static ADvendio__MediaCampaign__c createTestMediaCampaign(Boolean insertObject, Account invoiceAccount, ADvendio__Pricelist__c pricelist, SomDig_WtAgBeziehung__c WTAG) {
        if (Zahlungsbedingung_TestData == null) createTestZahlungsbedingung(true);
        MediaCampaign_TestData = new ADvendio__MediaCampaign__c();
        MediaCampaign_TestData.Name = 'Test MediaCampaign 1' + (Math.random()*1000).round();
        MediaCampaign_TestData.ADvendio__invoice_recipient__c = (invoiceAccount == null) ? createTestAccount(true).Id : invoiceAccount.Id;
        MediaCampaign_TestData.ADvendio__Pricelist__c = (pricelist == null) ? createTestPricelist(true, null).Id : pricelist.Id;
        MediaCampaign_TestData.ADvendio__Stage__c = 'First contact';
        MediaCampaign_TestData.ADvendio__PaymentInterval__c = 'monthly (1 month)';
        MediaCampaign_TestData.ADvendio__PaymentStart__c = 'before / during Billingperiod';
        MediaCampaign_TestData.ADvendio__PaymentDueDate__c = 'due to the end of interval';
        MediaCampaign_TestData.SomDig_BetreuerSales__c = USER_MAP_PROFILE.get('SomDig_Sales');
        MediaCampaign_TestData.SomDig_BetreuerPam__c = USER_MAP_PROFILE.get('SomDig_PAM');
        MediaCampaign_TestData.SomDig_BetreuerTeam__c = (BetreuerTeam_TestData == null) ? createTestBetreuerTeam(true).Id : BetreuerTeam_TestData.Id;
        MediaCampaign_TestData.SomDig_WtAgBeziehung__c = (WTAG == null) ? createTestWTAG(true, null, null).Id : WTAG.Id;
        MediaCampaign_TestData.SomDig_StatusPAMCockpit__c = 'neu';
        if (insertObject) insert MediaCampaign_TestData;
        return MediaCampaign_TestData;
    }

    public static ADvendio__Site__c createTestSite(Boolean insertObject) {
        Site_TestData = new ADvendio__Site__c();
        Site_TestData.Name = 'Test Site ' + (Math.random()*1000000).round();
        if (insertObject) insert Site_TestData;
        return Site_TestData;
    }

    public static ADvendio__Placement__c createTestPlacement(Boolean insertObject) {
        return createTestPlacement(insertObject, null);
    }
    public static ADvendio__Placement__c createTestPlacement(Boolean insertObject, ADvendio__Site__c site) {
        Placement_TestData = new ADvendio__Placement__c();
        Placement_TestData.Name = 'Test Placement 1';
        Placement_TestData.SomDig_BT__c = true;
        Placement_TestData.ADvendio__Site__c = (site == null) ? createTestSite(true).Id : site.Id;
        if (insertObject) insert Placement_TestData;
        return Placement_TestData;
    }

    public static ADvendio__Ad_Type__c createTestAdType(Boolean insertObject) {
        return createTestAdType(insertObject, null);
    }
    public static ADvendio__Ad_Type__c createTestAdType(Boolean insertObject, SomDig_MediagattungsDifferenzierung__c mediagattungsDifferenzierung) {
        AdType_TestData = new ADvendio__Ad_Type__c();
        AdType_TestData.Name = 'Test Ad Type ' + (Math.random()*1000000).round();
        AdType_TestData.SomDig_MediagattungsDifferenzierung__c = (mediagattungsDifferenzierung == null) ? createTestMediagattungsDifferenzierung(true).Id : mediagattungsDifferenzierung.Id;
        if (insertObject) insert AdType_TestData;
        return AdType_TestData;
    }

    public static ADvendio__Ad_Specs__c createTestAdSpec(Boolean insertObject) {
        return createTestAdSpec(insertObject, null, null);
    }
    public static ADvendio__Ad_Specs__c createTestAdSpec(Boolean insertObject, ADvendio__Placement__c placement) {
        return createTestAdSpec(insertObject, placement, null);
    }
    public static ADvendio__Ad_Specs__c createTestAdSpec(Boolean insertObject, ADvendio__Ad_Type__c adType) {
        return createTestAdSpec(insertObject, null, adType);
    }
    public static ADvendio__Ad_Specs__c createTestAdSpec(Boolean insertObject, ADvendio__Placement__c placement, ADvendio__Ad_Type__c adType) {
        AdSpec_TestData = new ADvendio__Ad_Specs__c();
        AdSpec_TestData.Name = 'Test Ad Spec ' + (Math.random()*1000000).round();
        AdSpec_TestData.ADvendio__Placement__c = (placement == null) ? createTestPlacement(true, null).Id : placement.Id;
        AdSpec_TestData.ADvendio__Ad_Type__c = (adType == null) ? createTestAdType(true, null).Id : adType.Id;
        if (insertObject) insert AdSpec_TestData;
        return AdSpec_TestData;
    }

    public static ADvendio__Ad_price__c createTestAdPrice(Boolean insertObject, ADvendio__Ad_Specs__c adSpec) {
        return createTestAdPrice(insertObject, adSpec, null);
    }
    public static ADvendio__Ad_price__c createTestAdPrice(Boolean insertObject, ADvendio__Pricelist__c pricelist) {
        return createTestAdPrice(insertObject, null, pricelist);
    }
    public static ADvendio__Ad_price__c createTestAdPrice(Boolean insertObject, ADvendio__Ad_Specs__c adSpec, ADvendio__Pricelist__c pricelist) {
        AdPrice_TestData = new ADvendio__Ad_price__c();
        AdPrice_TestData.ADvendio__List_price__c = 30;
        AdPrice_TestData.ADvendio__Ad_Spec__c = (adSpec == null) ? createTestAdSpec(true, null, null).Id : adSpec.Id;
        AdPrice_TestData.ADvendio__Pricelist__c = (pricelist == null) ? createTestPricelist(true, null).Id : pricelist.Id;
        AdPrice_TestData.ADvendio__Active__c = true;
        if (insertObject) insert AdPrice_TestData;
        return AdPrice_TestData;
    }

    public static ADvendio__Campaign_Item__c createTestCampaignItem(Boolean insertObject) {
        return createTestCampaignItem(insertObject, null, null);
    }
    public static ADvendio__Campaign_Item__c createTestCampaignItem(Boolean insertObject, ADvendio__MediaCampaign__c mediaCampaign) {
        return createTestCampaignItem(insertObject, mediaCampaign, null);
    }
    public static ADvendio__Campaign_Item__c createTestCampaignItem(Boolean insertObject, ADvendio__Ad_price__c adPrice) {
        return createTestCampaignItem(insertObject, null, adPrice);
    }
    public static ADvendio__Campaign_Item__c createTestCampaignItem(Boolean insertObject, ADvendio__MediaCampaign__c mediaCampaign, ADvendio__Ad_price__c adPrice) {
        CampaignItem_TestData = new ADvendio__Campaign_Item__c();
        CampaignItem_TestData.Name = 'Test Campaign Item ' + (Math.random()*1000000).round();
        CampaignItem_TestData.ADvendio__Media_Campaign__c = (mediaCampaign == null) ? createTestMediaCampaign(true, null, null, null).Id : mediaCampaign.Id;
        CampaignItem_TestData.ADvendio__Ad_Price__c = (adPrice == null) ? createTestAdPrice(true, null, Pricelist_TestData).Id : adPrice.Id;
        CampaignItem_TestData.ADvendio__from_Date__c = Date.today();
        CampaignItem_TestData.ADvendio__until_Date__c = Date.today().addDays(2);
        CampaignItem_TestData.ADvendio__Quantity__c = 10000;
        CampaignItem_TestData.ADvendio__Sales_Price__c = 30;
        CampaignItem_TestData.ADvendio__Billing_category__c = 'CPM';
        if (insertObject) insert CampaignItem_TestData;
        return CampaignItem_TestData;
    }

    public static ADvendio__Invoice__c createTestInvoice(Boolean insertObject, ADvendio__MediaCampaign__c mediaCampaign) {
        Invoice_TestData = new ADvendio__Invoice__c();
        Invoice_TestData.Name = 'TstInvoice';
        Invoice_TestData.ADvendio__MediaCampaign__c = (mediaCampaign == null) ? createTestMediaCampaign(true).Id : mediaCampaign.Id;
        Invoice_TestData.ADvendio__AccountingDate__c = system.today().toStartOfMonth();
        Invoice_TestData.ADvendio__Status__c = 'Created';
        if (insertObject) insert Invoice_TestData;
        return Invoice_TestData;
    }

    public static ADvendio__InvoiceItem__c createTestInvoiceItem(Boolean insertObject, ADvendio__Invoice__c invoice, ADvendio__Campaign_Item__c campaignItem) {
        InvoiceItem_TestData = new ADvendio__InvoiceItem__c();
        InvoiceItem_TestData.Name = 'Test Invoice Item';
        InvoiceItem_TestData.ADvendio__Invoice__c = invoice.Id;
        InvoiceItem_TestData.ADvendio__CampaignItem__c = campaignItem.Id;
        InvoiceItem_TestData.ADvendio__InvoiceItemStartDate__c = System.today();
        InvoiceItem_TestData.ADvendio__InvoiceItemEndDate__c = System.today();
        if (insertObject) insert InvoiceItem_TestData;
        return InvoiceItem_TestData;
    }
    /***** Inventar, Kampagnen, Positionen, Rechnungen *****/



    /***** Keys, Values, AdServer *****/
    public static ADvendio__AdServer_Logins__c createTestAdServerLogin(Boolean insertObject) {
        return createTestAdServerLogin(insertObject, null);
    }
    public static ADvendio__AdServer_Logins__c createTestAdServerLogin(Boolean insertObject, RecordType recordtype) {
        AdServerLogin_TestData = new ADvendio__AdServer_Logins__c();
        AdServerLogin_TestData.ADvendio__User_Name__c = 'Test Username';
        AdServerLogin_TestData.ADvendio__Active__c = true;
        if (recordtype != null) AdServerLogin_TestData.RecordTypeId = recordtype.Id;
        if (insertObject) insert AdServerLogin_TestData;
        return AdServerLogin_TestData;
    }

    public static ADvendio__AdServer_ID__c createTestAdServerID(Boolean insertObject) {
        AdServerID_TestData = new ADvendio__AdServer_ID__c();
        AdServerID_TestData.Name = 'Test AdServerID ' + (Math.random()*1000000).round();
        if (insertObject) insert AdServerID_TestData;
        return AdServerID_TestData;
    }

    public static ADvendio__KeyLine__c createTestKeyLine(Boolean insertObject, ADvendio__Campaign_Item__c campaignItem) {
        KeyLine_TestData = new ADvendio__KeyLine__c();
        KeyLine_TestData.Name = 'Test KeyLine ' + (Math.random()*1000000).round();
        KeyLine_TestData.ADvendio__CampaignItem__c = (campaignItem == null) ? createTestCampaignItem(true, null, null).Id : campaignItem.Id;
        if (insertObject) insert KeyLine_TestData;
        return KeyLine_TestData;
    }

    public static ADvendio__Key__c createTestKey(Boolean insertObject) {
        return createTestKey(insertObject, null, null);
    }
    public static ADvendio__Key__c createTestKey(Boolean insertObject, ADvendio__AdServer_ID__c adServerID) {
        return createTestKey(insertObject, adServerID, null);
    }
    public static ADvendio__Key__c createTestKey(Boolean insertObject, String targetingType) {
        return createTestKey(insertObject, null, targetingType);
    }
    public static ADvendio__Key__c createTestKey(Boolean insertObject, ADvendio__AdServer_ID__c adServerID, String targetingType) {
        Key_TestData = new ADvendio__Key__c();
        Key_TestData.Name = 'Test Key ' + (Math.random()*1000000).round();
        Key_TestData.ADvendio__AdServerId__c = (adServerID == null) ? createTestAdServerID(true).Id : adServerID.Id;
        Key_TestData.SomDig_TargetingType__c = (targetingType == null) ? 'Targeting Type ' + (Math.random()*1000000).round() : targetingType;
        if (insertObject) insert Key_TestData;
        return Key_TestData;
    }

    public static ADvendio__KeyValue__c createTestKeyValue(Boolean insertObject, ADvendio__KeyLine__c keyLine, ADvendio__Key__c key) {
        KeyValue_TestData = new ADvendio__KeyValue__c();
        KeyValue_TestData.Name = 'Test KeyValue ' + (Math.random()*1000000).round();
        KeyValue_TestData.ADvendio__KeyLine__c = (keyLine == null) ? createTestKeyLine(true, null).Id : keyLine.Id;
        KeyValue_TestData.ADvendio__Key__c = (key == null) ? createTestKey(true).Id : key.Id;
        if (insertObject) insert KeyValue_TestData;
        return KeyValue_TestData;
    }

    public static ADvendio__KeyAdPriceAssignment__c createTestKeyAdPriceAssignment(Boolean insertObject, ADvendio__Key__c key, ADvendio__Ad_price__c adPrice) {
        KeyAdPriceAssignment_TestData = new ADvendio__KeyAdPriceAssignment__c();
        KeyAdPriceAssignment_TestData.ADvendio__Key__c = (key == null) ? createTestKey(true).Id : key.Id;
        KeyAdPriceAssignment_TestData.ADvendio__AdPrice__c = (adPrice == null) ? createTestAdPrice(true, null, null).Id : adPrice.Id;
        if (insertObject) insert KeyAdPriceAssignment_TestData;
        return KeyAdPriceAssignment_TestData;
    }
    /***** Keys, Values, AdServer *****/



    /***** GeoTargeting *****/
    public static Advendio__Country__c createTestCountry(Boolean insertObject) {
        Country_TestData = new Advendio__Country__c();
        Country_TestData.Name = 'Test Country ' + (Math.random()*1000000).round();
        if (insertObject) insert Country_TestData;
        return Country_TestData;
    }

    public static Advendio__Region__c createTestRegion(Boolean insertObject) {
        return createTestRegion(insertObject, null);
    }
    public static Advendio__Region__c createTestRegion(Boolean insertObject, Advendio__Country__c country) {
        Region_TestData = new Advendio__Region__c();
        Region_TestData.Name = 'Test Region ' + (Math.random()*1000000).round();
        Region_TestData.Advendio__Country__c = (country == null) ? createTestCountry(true).Id : country.Id;
        if (insertObject) insert Region_TestData;
        return Region_TestData;
    }

    public static Advendio__City__c createTestCity(Boolean insertObject) {
        City_TestData = new Advendio__City__c();
        City_TestData.Name = 'Test City ' + (Math.random()*1000000).round();
        if (insertObject) insert City_TestData;
        return City_TestData;
    }

    public static Advendio__Areacode__c createTestAreacode(Boolean insertObject) {
        Areacode_TestData = new Advendio__Areacode__c();
        Areacode_TestData.Name = 'Test Areacode ' + (Math.random()*1000000).round();
        if (insertObject) insert Areacode_TestData;
        return Areacode_TestData;
    }

    public static Advendio__Selected_Country__c createTestSelectedCountry(Boolean insertObject, ADvendio__Campaign_Item__c campaignItem, Advendio__Country__c country) {
        SelectedCountry_TestData = new Advendio__Selected_Country__c();
        SelectedCountry_TestData.ADvendio__Campaign_Item__c = (campaignItem == null) ? createTestCampaignItem(true, null, null).Id : campaignItem.Id;
        SelectedCountry_TestData.Advendio__Country__c = (country == null) ? createTestCountry(true).Id : country.Id;
        if (insertObject) insert SelectedCountry_TestData;
        return SelectedCountry_TestData;
    }

    public static Advendio__Selected_Region__c createTestSelectedRegion(Boolean insertObject, ADvendio__Campaign_Item__c campaignItem, Advendio__Region__c region) {
        SelectedRegion_TestData = new Advendio__Selected_Region__c();
        SelectedRegion_TestData.ADvendio__Campaign_Item__c = (campaignItem == null) ? createTestCampaignItem(true, null, null).Id : campaignItem.Id;
        SelectedRegion_TestData.Advendio__Region__c = (region == null) ? createTestRegion(true, null).Id : region.Id;
        if (insertObject) insert SelectedRegion_TestData;
        return SelectedRegion_TestData;
    }

    public static Advendio__Selected_City__c createTestSelectedCity(Boolean insertObject, ADvendio__Campaign_Item__c campaignItem, Advendio__City__c city) {
        SelectedCity_TestData = new Advendio__Selected_City__c();
        SelectedCity_TestData.ADvendio__Campaign_Item__c = (campaignItem == null) ? createTestCampaignItem(true, null, null).Id : campaignItem.Id;
        SelectedCity_TestData.Advendio__City__c = (city == null) ? createTestCity(true).Id : city.Id;
        if (insertObject) insert SelectedCity_TestData;
        return SelectedCity_TestData;
    }

    public static Advendio__Selected_Areacode__c createTestSelectedAreacode(Boolean insertObject, ADvendio__Campaign_Item__c campaignItem, Advendio__Areacode__c areacode) {
        SelectedAreacode_TestData = new Advendio__Selected_Areacode__c();
        SelectedAreacode_TestData.ADvendio__Campaign_Item__c = (campaignItem == null) ? createTestCampaignItem(true, null, null).Id : campaignItem.Id;
        SelectedAreacode_TestData.Advendio__Areacode__c = (areacode == null) ? createTestAreacode(true).Id : areacode.Id;
        if (insertObject) insert SelectedAreacode_TestData;
        return SelectedAreacode_TestData;
    }
    /***** GeoTargeting *****/



    /***** Ventures *****/
    public static Ven_Key_Performance_Indicator__c createTestKPI(Boolean insertObject){
        kpi_TestData = new Ven_Key_Performance_Indicator__c();
        kpi_TestData.Name = 'Test KPI';
        if (insertObject) insert kpi_TestData;
        return kpi_TestData;
    }

    public static Ven_KeyPerformanceIndicatorBlock__c createTestKPIBlock(Boolean insertObject){
        kpiBlock_TestData = new Ven_KeyPerformanceIndicatorBlock__c();
        kpiBlock_TestData.Name = 'Test KPI Block';
        if (insertObject) insert kpiBlock_TestData;
        return kpiBlock_TestData;
    }

    public static Ven_KeyPerformanceIndicatorBlockEntry__c createTestKPIBlockEntry(Boolean insertObject, Ven_Key_Performance_Indicator__c testKpi, Ven_KeyPerformanceIndicatorBlock__c testKpiBlock){
        kpiBlockEntry_TestData = new Ven_KeyPerformanceIndicatorBlockEntry__c();
        kpiBlockEntry_TestData.Ven_KeyPerformanceIndicator__c = testKpi.Id;
        kpiBlockEntry_TestData.Ven_KeyPerformanceIndicatorBlock__c = testKpiBlock.Id;
        if (insertObject) insert kpiBlockEntry_TestData;
        return kpiBlockEntry_TestData;
    }

    public static Ven_KeyPerformanceIndicatorTemplate__c createTestKPITemplate(Boolean insertObject){
        kpiTemplate_TestData = new Ven_KeyPerformanceIndicatorTemplate__c();
        kpiTemplate_TestData.Name = 'Test KPI Template';
        if (insertObject) insert kpiTemplate_TestData;
        return kpiTemplate_TestData;
    }

    public static Ven_KeyPerformanceIndicatorTemplateEntry__c createTestKPITemplateEntry(Boolean insertObject, Ven_KeyPerformanceIndicatorTemplate__c testKpiTemplate, Ven_KeyPerformanceIndicatorBlock__c testKpiBlock){
        kpiTemplateEntry_TestData = new Ven_KeyPerformanceIndicatorTemplateEntry__c();
        kpiTemplateEntry_TestData.Ven_KeyPerformanceIndicatorTemplate__c = testKpiTemplate.Id;
        kpiTemplateEntry_TestData.Ven_KeyPerformanceIndicatorBlock__c = testKpiBlock.Id;
        if (insertObject) insert kpiTemplateEntry_TestData;
        return kpiTemplateEntry_TestData;
    }

    public static Ven_Financial_Model_Version__c createTestFinancialModelVersion(Boolean insertObject, ID recordTypeID, Opportunity testOpp){
        financialModelVersion_TestData = new Ven_Financial_Model_Version__c();
        financialModelVersion_TestData.RecordTypeId = recordTypeID;
        financialModelVersion_TestData.Ven_Opportunity__c = testOpp.Id;
        if (insertObject) insert financialModelVersion_TestData;
        return financialModelVersion_TestData;
    }

    public static Ven_Financial_Model_Data__c createTestFinancialModelData(Boolean insertObject, Ven_Key_Performance_Indicator__c testKpi){
        financialModelData_TestData = new Ven_Financial_Model_Data__c();
        financialModelData_TestData.Name = 'Test Financial Model Data';
        financialModelData_TestData.Ven_Datum__c = System.today();
        financialModelData_TestData.Key_Performance_Indicator__c = testKpi.Id;
        if (insertObject) insert financialModelData_TestData;
        return financialModelData_TestData;
    }
    /***** Ventures *****/


    /***** SOM KAM*****/

    /*************
    *
    *************/
    public static User createTestUser(Boolean insertObject, Id profileId, Integer i){
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='test'+i+'@accPlan.com');
 
        if(insertObject) insert u;
        return u;
    }


    /*************
    *
    *************/
    public static AccountTeamMember createTestAccountTeamMember(Boolean insertObject, Id accId, String role, Id userId){
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = accId;
        atm.TeamMemberRole = role;
        atm.UserId = userId;

        if(insertObject) insert atm;
        return atm;
    }


    /*************
    *
    *************/
    public static Som_Kam__c createTestAccountPlan(Boolean insertObject, Id accId){
        AccountPlan_TestData = new Som_Kam__c();
        AccountPlan_TestData.Som_Account__c = accId;
        AccountPlan_TestData.Som_Year__c = Date.today().year();
        AccountPlan_TestData.Som_EmailText__c = 'Test';
        AccountPlan_TestData.Som_Kickoff__c = Date.today();
        AccountPlan_TestData.Som_Review__c = Date.today();

        if(insertObject) insert AccountPlan_TestData;
        return AccountPlan_TestData;
    }

    /*************
    *
    *************/
    public static Som_KamDetail__c createTestAccountPlanDetail(Boolean insertObject, Id accPlanId){
        AccountPlanDetail_TestData = new Som_KamDetail__c();
        AccountPlanDetail_TestData.Som_Kam__c = accPlanId;

        if(insertObject) insert AccountPlanDetail_TestData;
        return AccountPlanDetail_TestData;
    }


    /*************
    *
    *************/
    public static Som_KamTeam__c createTestAccountPlanTeam(Boolean insertObject, String teamName, Id defaultUserId, String teamRoles){
        AccountPlanTeam_TestData = new Som_KamTeam__c();
        AccountPlanTeam_TestData.Name = teamName;
        AccountPlanTeam_TestData.Som_DefaultAccountTeamMember__c = defaultUserId;
        AccountPlanTeam_TestData.Som_TeamMemberRoles__c  = teamRoles;   

        if(insertObject) insert AccountPlanTeam_TestData;
        return AccountPlanTeam_TestData;
    }


    /*************
    *
    *************/
    public static Som_KamAccountCashIn__c createTestAnnualAccountCashIn(Boolean insertObject, Id accId, Id accPlanTeamId, Decimal year){
        AnnualAccountCashIn_TestData = new Som_KamAccountCashIn__c();
        AnnualAccountCashIn_TestData.Som_Account__c = accId;
        AnnualAccountCashIn_TestData.Som_KamTeam__c = accPlanTeamId;
        AnnualAccountCashIn_TestData.Som_CashExternalYield__c = 100;
        AnnualAccountCashIn_TestData.Som_CashIn__c = 200;
        AnnualAccountCashIn_TestData.Som_Year__c = year;

        if(insertObject) insert AnnualAccountCashIn_TestData;
        return AnnualAccountCashIn_TestData;
    }

    /*************
    *
    *************/
    public static Som_KamAccountCashInDetail__c createTestAnnualAccountCashInDetail(Boolean insertObject, Id annualAccCashInId){
        AnnualAccountCashInDetail_TestData = new Som_KamAccountCashInDetail__c();
        AnnualAccountCashInDetail_TestData.Som_KamAccountCashIn__c = annualAccCashInId;
        AnnualAccountCashInDetail_TestData.Som_CashExternalYield__c = 10;
        AnnualAccountCashInDetail_TestData.Som_CashIn__c = 20;        

        if(insertObject) insert AnnualAccountCashInDetail_TestData;
        return AnnualAccountCashInDetail_TestData;
    }

    /*************
    *
    *************/
    public static Som_KamStrategyProfileTopic__c createTestStrategyProfileTopic(Boolean insertObject, Boolean isTemplate, String name){
        StrategyProfileTopic_TestData = new Som_KamStrategyProfileTopic__c();
        StrategyProfileTopic_TestData.Som_IsTemplate__c = isTemplate;
        StrategyProfileTopic_TestData.Name = name;        

        if(insertObject) insert StrategyProfileTopic_TestData;
        return StrategyProfileTopic_TestData;
    }

}