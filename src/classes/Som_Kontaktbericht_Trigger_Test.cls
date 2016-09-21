@isTest
public with sharing class Som_Kontaktbericht_Trigger_Test {

    // Tests for Kontaktbericht

    static testMethod void insertKontaktbericht() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.Email = 'hulk@the-avengers.com';
        Contact conTv = cls_P7S1_TestData.createTestContact(false);
        conTv.Email = 'somtv_sales@p7s1applications.de';
        insert new List<Contact>{ con, conTv };
        User user = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomTv_Sales');
        System.assert(user != null);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(user, conTv);
        Datetime timestamp = Datetime.now().addDays(-1);

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_TV_LetzterTelefonTermin__c);

        Test.startTest();

        Som_Kontaktbericht__c kb = cls_P7S1_TestData.createTestKontaktbericht(true, con, user, 'Telefonat', timestamp);

        acc = reloadAccount(acc);
        System.assertEquals(timestamp, acc.Som_TV_LetzterTelefonTermin__c);

        List<Som_KontaktberichtContact__c> teilnehmer = [SELECT Som_Contact__r.Email FROM Som_KontaktberichtContact__c WHERE Som_Kontaktbericht__c = :kb.Id];
        teilnehmer.sort();
        System.assertEquals('hulk@the-avengers.com', teilnehmer[0].Som_Contact__r.Email);
        System.assertEquals('somtv_sales@p7s1applications.de', teilnehmer[1].Som_Contact__r.Email);

        Test.stopTest();
    }

    static testMethod void insertKontaktberichtWithDuplicateTeilnehmer() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(true, acc);
        User user = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomDig_Sales');
        System.assert(user != null);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(user, con);
        Datetime timestamp = Datetime.now().addDays(-12);

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_DIG_LetzterVeranstaltungsTermin__c);

        Test.startTest();

        Som_Kontaktbericht__c kb = cls_P7S1_TestData.createTestKontaktbericht(true, con, user, 'Veranstaltung/Messe', timestamp);

        acc = reloadAccount(acc);
        System.assertEquals(timestamp, acc.Som_DIG_LetzterVeranstaltungsTermin__c);
        System.assertEquals(1, [SELECT COUNT() FROM Som_KontaktberichtContact__c]);

        Test.stopTest();
    }

    static testMethod void insertMultipleKontaktberichte() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con1 = cls_P7S1_TestData.createTestContact(false, acc);
        Contact con2 = cls_P7S1_TestData.createTestContact(false, acc);
        Contact conTv = cls_P7S1_TestData.createTestContact(false);
        Contact conAt = cls_P7S1_TestData.createTestContact(false);
        insert new List<Contact>{ con1, con2, conTv, conAt };
        User userTv = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomTv_Sales');
        User userAt = cls_P7S1_TestData.USER_FOR_SPHERE.get('SomAt');
        System.assert(userTv != null);
        System.assert(userAt != null);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(userTv, conTv);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(userAt, conAt);
        Datetime timestamp1 = Datetime.now().addDays(-7);
        Datetime timestamp2 = Datetime.now().addDays(-8);

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_TV_LetzterTelefonTermin__c);
        System.assertEquals(null, acc.Som_AT_LetzterPersoenlicherTermin__c);

        Test.startTest();

        Som_Kontaktbericht__c kb1 = cls_P7S1_TestData.createTestKontaktbericht(false, con1, userTv, 'Telefonat', timestamp1);
        Som_Kontaktbericht__c kb2 = cls_P7S1_TestData.createTestKontaktbericht(false, con2, userAt, 'persönlicher Termin', timestamp2);
        insert new List<Som_Kontaktbericht__c>{ kb1, kb2 };

        System.assertEquals(4, [SELECT COUNT() FROM Som_KontaktberichtContact__c]);

        acc = reloadAccount(acc);
        System.assertEquals(timestamp1, acc.Som_TV_LetzterTelefonTermin__c);
        System.assertEquals(timestamp2, acc.Som_AT_LetzterPersoenlicherTermin__c);

        Test.stopTest();
    }

    static testMethod void insertKontaktberichtWithoutMitarbeiter() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(true, acc);
        User user = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomDig_Sales');
        System.assert(user != null);

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_Dig_LetzterTelefonTermin__c);

        Test.startTest();

        Som_Kontaktbericht__c kb = cls_P7S1_TestData.createTestKontaktbericht(true, con, user, 'Telefonat', Datetime.now().addDays(-2));

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_Dig_LetzterTelefonTermin__c);

        List<Som_KontaktberichtContact__c> kbContacts = [SELECT Som_Contact__c FROM Som_KontaktberichtContact__c WHERE Som_Kontaktbericht__c = :kb.Id];
        System.assertEquals(1, kbContacts.size());
        System.assertEquals(con.Id, kbContacts[0].Som_Contact__c);

        Test.stopTest();
    }

    static testMethod void insertKontaktberichtWithoutBereich() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        Contact conSgn = cls_P7S1_TestData.createTestContact(false);
        insert new List<Contact>{ con, conSgn };
        User user = cls_P7S1_TestData.USER_FOR_PROFILE.get('Sgn_Default');
        System.assert(user != null);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(user, conSgn);

        acc = reloadAccount(acc);
        Datetime modified = acc.LastModifiedDate;

        Test.startTest();

        Som_Kontaktbericht__c kb = cls_P7S1_TestData.createTestKontaktbericht(true, con, user, 'Telefonat', Datetime.now().addDays(-9));

        acc = reloadAccount(acc);
        System.assertEquals(modified, acc.LastModifiedDate);
        System.assertEquals(2, [SELECT COUNT() FROM Som_KontaktberichtContact__c]);

        Test.stopTest();
    }

    static testMethod void updateKontaktberichtGrundDesKontakts() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        Contact conAt = cls_P7S1_TestData.createTestContact(false);
        insert new List<Contact>{ con, conAt };
        User user = cls_P7S1_TestData.USER_FOR_SPHERE.get('SomAt');
        System.assert(user != null);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(user, conAt);
        Datetime timestamp = Datetime.now().addDays(-3);
        Som_Kontaktbericht__c kb = cls_P7S1_TestData.createTestKontaktbericht(true, con, user, 'persönlicher Termin', timestamp);

        acc = reloadAccount(acc);
        System.assertEquals(timestamp, acc.Som_AT_LetzterPersoenlicherTermin__c);
        System.assertEquals(null, acc.Som_AT_LetzterTelefonTermin__c);
        System.assertEquals(null, acc.Som_AT_LetzterVeranstaltungsTermin__c);

        Test.startTest();

        kb.Som_GrundDesKontakts__c = 'Telefonat';
        update kb;

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_AT_LetzterPersoenlicherTermin__c);
        System.assertEquals(timestamp, acc.Som_AT_LetzterTelefonTermin__c);
        System.assertEquals(null, acc.Som_AT_LetzterVeranstaltungsTermin__c);

        kb.Som_GrundDesKontakts__c = 'Veranstaltung/Messe';
        update kb;

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_AT_LetzterPersoenlicherTermin__c);
        System.assertEquals(null, acc.Som_AT_LetzterTelefonTermin__c);
        System.assertEquals(timestamp, acc.Som_AT_LetzterVeranstaltungsTermin__c);

        Test.stopTest();
    }

    static testMethod void deleteKontaktbericht() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        Contact conDig = cls_P7S1_TestData.createTestContact(false);
        insert new List<Contact>{ con, conDig };
        User user = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomDig_Sales');
        System.assert(user != null);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(user, conDig);
        Datetime timestamp = Datetime.now().addDays(-20);
        Som_Kontaktbericht__c kb = cls_P7S1_TestData.createTestKontaktbericht(true, con, user, 'Telefonat', timestamp);

        acc = reloadAccount(acc);
        System.assertEquals(timestamp, acc.Som_DIG_LetzterTelefonTermin__c);

        Test.startTest();

        delete kb;
        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_DIG_LetzterTelefonTermin__c);
        System.assertEquals(0, [SELECT COUNT() FROM Som_KontaktberichtContact__c]);

        Test.stopTest();
    }



    // Tests for KontaktberichtTeilnehmer

    static testMethod void insertKontaktberichtTeilnehmer() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        Contact conDig = cls_P7S1_TestData.createTestContact(false);
        Contact conTv = cls_P7S1_TestData.createTestContact(false);
        insert new List<Contact>{ con, conDig, conTv };
        User userDig = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomDig_Sales');
        User userTv = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomTv_Sales');
        System.assert(userDig != null);
        System.assert(userTv != null);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(userDig, conDig);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(userTv, conTv);
        Datetime timestamp = Datetime.now().addDays(-4);
        Som_Kontaktbericht__c kb = cls_P7S1_TestData.createTestKontaktbericht(true, con, userDig, 'Telefonat', timestamp);

        acc = reloadAccount(acc);
        System.assertEquals(timestamp, acc.Som_Dig_LetzterTelefonTermin__c);
        System.assertEquals(null, acc.Som_TV_LetzterTelefonTermin__c);

        Test.startTest();

        cls_P7S1_TestData.createTestKontaktberichtTeilnehmer(true, kb, conTv);

        acc = reloadAccount(acc);
        System.assertEquals(timestamp, acc.Som_Dig_LetzterTelefonTermin__c);
        System.assertEquals(timestamp, acc.Som_TV_LetzterTelefonTermin__c);

        Test.stopTest();
    }

    static testMethod void insertKontaktberichtTeilnehmerWithoutMitarbeiter() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        Contact conWithoutEmp = cls_P7S1_TestData.createTestContact(false);
        insert new List<Contact>{ con, conWithoutEmp };
        User userAdF = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomTv_ADFactory');
        System.assert(userAdF != null);
        Datetime timestamp = Datetime.now().addDays(-5);
        Som_Kontaktbericht__c kb = cls_P7S1_TestData.createTestKontaktbericht(true, con, userAdF, 'Telefonat', timestamp);

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_AdF_LetzterTelefonTermin__c);

        Test.startTest();

        cls_P7S1_TestData.createTestKontaktberichtTeilnehmer(true, kb, conWithoutEmp);

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_AdF_LetzterTelefonTermin__c);

        Test.stopTest();
    }

    static testMethod void deleteKontaktberichtTeilnehmer() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        Contact conTv = cls_P7S1_TestData.createTestContact(false);
        Contact conDig = cls_P7S1_TestData.createTestContact(false);
        insert new List<Contact>{ con, conTv, conDig };
        User userTv = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomTv_Sales');
        User userDig = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomDig_Sales');
        System.assert(userTv != null);
        System.assert(userDig != null);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(userTv, conTv);
        cls_P7S1_TestData.createTestMitarbeiterWithUserAndContact(userDig, conDig);
        Datetime timestamp = Datetime.now().addDays(-6);
        Som_Kontaktbericht__c kb = cls_P7S1_TestData.createTestKontaktbericht(true, con, userDig, 'Veranstaltung/Messe', timestamp);
        Som_KontaktberichtContact__c tn = cls_P7S1_TestData.createTestKontaktberichtTeilnehmer(true, kb, conTv);

        acc = reloadAccount(acc);
        System.assertEquals(timestamp, acc.Som_Tv_LetzterVeranstaltungsTermin__c);
        System.assertEquals(timestamp, acc.Som_Dig_LetzterVeranstaltungsTermin__c);

        Test.startTest();

        delete tn;

        acc = reloadAccount(acc);
        System.assertEquals(null, acc.Som_Tv_LetzterVeranstaltungsTermin__c);
        System.assertEquals(timestamp, acc.Som_Dig_LetzterVeranstaltungsTermin__c);

        Test.stopTest();
    }



    private static Account reloadAccount(Account acc) {
        return [SELECT LastModifiedDate,
                       Som_AdF_LetzterPersoenlicherTermin__c, Som_AdF_LetzterTelefonTermin__c, Som_AdF_LetzterVeranstaltungsTermin__c,
                       Som_DIG_LetzterPersoenlicherTermin__c, Som_DIG_LetzterTelefonTermin__c, Som_DIG_LetzterVeranstaltungsTermin__c,
                       Som_TV_LetzterPersoenlicherTermin__c, Som_TV_LetzterTelefonTermin__c, Som_TV_LetzterVeranstaltungsTermin__c,
                       Som_AT_LetzterPersoenlicherTermin__c, Som_AT_LetzterTelefonTermin__c, Som_AT_LetzterVeranstaltungsTermin__c
                  FROM Account
                 WHERE Id = :acc.Id];
    }

}