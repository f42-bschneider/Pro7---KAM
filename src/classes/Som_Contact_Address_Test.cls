@isTest
private with sharing class Som_Contact_Address_Test {

    static testMethod void insertContactSyncShippingAddress() {
        Account acc = createSuperheroAccount(true);

        Test.startTest();

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
        insert con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('Superhero Blvd. 100', con.MailingStreet);
        System.assertEquals('9000', con.MailingPostalCode);
        System.assertEquals('Gotham City', con.MailingCity);
        System.assertEquals('USA', con.MailingCountry);
    }

    static testMethod void insertContactSyncBillingAddress() {
        Account acc = createSuperheroAccount(false);
        acc.ShippingPostalCode = null; // Set PostalCode to null to force incomplete ShippingAddress
        insert acc;

        Test.startTest();

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
        insert con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('123 Minion Drive', con.MailingStreet);
        System.assertEquals('10000', con.MailingPostalCode);
        System.assertEquals('San Francisco', con.MailingCity);
        System.assertEquals('America', con.MailingCountry);
    }

    static testMethod void insertContactSyncOnlyBillingAddress() {
        Account acc = createSuperheroAccount(true);

        Test.startTest();

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'mit Rechnungsadresse synchronisieren';
        insert con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('123 Minion Drive', con.MailingStreet);
        System.assertEquals('10000', con.MailingPostalCode);
        System.assertEquals('San Francisco', con.MailingCity);
        System.assertEquals('America', con.MailingCountry);
    }

    static testMethod void insertContactSyncNothing() {
        Account acc = createSuperheroAccount(true);

        Test.startTest();

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'individuell pflegen';
        insert con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals(null, con.MailingStreet);
        System.assertEquals(null, con.MailingPostalCode);
        System.assertEquals(null, con.MailingCity);
        System.assertEquals(null, con.MailingCountry);
    }

    static testMethod void bulkInsertContact() {
        Account acc = createSuperheroAccount(true);

        Test.startTest();

        List<Contact> cons = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            Contact con = cls_P7S1_TestData.createTestContact(false, acc);
            con.LastName = 'Superhero #' + i;
            if (i < 50) {
                con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
            } else if (i < 100) {
                con.SomTv_AdressePflegen__c = 'mit Rechnungsadresse synchronisieren';
            } else {
                con.SomTv_AdressePflegen__c = 'individuell pflegen';
            }
            cons.add(con);
        }
        insert cons;

        Test.stopTest();

        System.assertEquals(50, [SELECT COUNT() FROM Contact WHERE MailingCity = 'Gotham City']);
        System.assertEquals(50, [SELECT COUNT() FROM Contact WHERE MailingCity = 'San Francisco']);
        System.assertEquals(100, [SELECT COUNT() FROM Contact WHERE MailingCity = null]);
    }

    static testMethod void updateContactSyncShippingAddress() {
        Account acc = createSuperheroAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'individuell pflegen';
        insert con;

        Test.startTest();

        con.MailingStreet = '567 Avengers Road';
        con.MailingPostalCode = '20000';
        con.MailingCity = 'New York City';
        con.MailingCountry = 'US';
        con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
        update con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('Superhero Blvd. 100', con.MailingStreet);
        System.assertEquals('9000', con.MailingPostalCode);
        System.assertEquals('Gotham City', con.MailingCity);
        System.assertEquals('USA', con.MailingCountry);
    }

    static testMethod void updateContactSyncBillingAddress() {
        Account acc = createSuperheroAccount(false);
        acc.ShippingPostalCode = null; // Set PostalCode to null to force incomplete ShippingAddress
        insert acc;

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'individuell pflegen';
        insert con;

        Test.startTest();

        con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
        update con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('123 Minion Drive', con.MailingStreet);
        System.assertEquals('10000', con.MailingPostalCode);
        System.assertEquals('San Francisco', con.MailingCity);
        System.assertEquals('America', con.MailingCountry);
    }

    static testMethod void updateContactSyncOnlyBillingAddress() {
        Account acc = createSuperheroAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
        insert con;

        Test.startTest();

        con.MailingStreet = '567 Avengers Road';
        con.MailingPostalCode = '20000';
        con.MailingCity = 'New York City';
        con.MailingCountry = 'US';
        con.SomTv_AdressePflegen__c = 'mit Rechnungsadresse synchronisieren';
        update con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('123 Minion Drive', con.MailingStreet);
        System.assertEquals('10000', con.MailingPostalCode);
        System.assertEquals('San Francisco', con.MailingCity);
        System.assertEquals('America', con.MailingCountry);
    }

    static testMethod void updateContactSyncNothing() {
        Account acc = createSuperheroAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        insert con;

        Test.startTest();

        con.MailingStreet = '123 Minion Drive';
        con.MailingPostalCode = '10000';
        con.MailingCity = 'San Francisco';
        con.MailingCountry = 'America';
        con.SomTv_AdressePflegen__c = 'individuell pflegen';
        update con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('123 Minion Drive', con.MailingStreet);
        System.assertEquals('10000', con.MailingPostalCode);
        System.assertEquals('San Francisco', con.MailingCity);
        System.assertEquals('America', con.MailingCountry);
    }

    static testMethod void updateContactEditManually() {
        Account acc = createSuperheroAccount(true);

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
        insert con;

        Test.startTest();

        con.MailingStreet = '123 Minion Drive';
        con.MailingPostalCode = '10000';
        con.MailingCity = 'San Francisco';
        con.MailingCountry = 'America';
        update con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('123 Minion Drive', con.MailingStreet);
        System.assertEquals('10000', con.MailingPostalCode);
        System.assertEquals('San Francisco', con.MailingCity);
        System.assertEquals('America', con.MailingCountry);
    }

    static testMethod void updateContactAccountId() {
        Account acc1 = createSuperheroAccount(false);
        Account acc2 = createSuperheroAccount(false);
        acc2.ShippingStreet = '567 Avengers Road';
        acc2.ShippingPostalCode = '20000';
        acc2.ShippingCity = 'New York City';
        acc2.ShippingCountry = 'US';
        insert new List<Account>{ acc1, acc2 };

        Contact con = cls_P7S1_TestData.createTestContact(false, acc1);
        con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
        insert con;

        Test.startTest();

        con.AccountId = acc2.Id;
        update con;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('567 Avengers Road', con.MailingStreet);
        System.assertEquals('20000', con.MailingPostalCode);
        System.assertEquals('New York City', con.MailingCity);
        System.assertEquals('US', con.MailingCountry);
    }

    static testMethod void bulkUpdateContact() {
        Account acc = createSuperheroAccount(true);

        List<Contact> cons = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            Contact con = cls_P7S1_TestData.createTestContact(false, acc);
            con.SomTv_AdressePflegen__c = 'individuell pflegen';
            con.LastName = 'Superhero #' + i;
            cons.add(con);
        }
        insert cons;

        Test.startTest();

        cons = [SELECT MailingStreet, MailingPostalCode, MailingCity, MailingCountry FROM Contact];
        for (Integer i = 0; i < cons.size(); i++) {
            Contact con = cons[i];
            con.MailingStreet = '567 Avengers Road';
            con.MailingPostalCode = '20000';
            con.MailingCity = 'New York City';
            con.MailingCountry = 'US';
            if (i < 50) {
                con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
            } else if (i < 100) {
                con.SomTv_AdressePflegen__c = 'mit Rechnungsadresse synchronisieren';
            } else {
                con.SomTv_AdressePflegen__c = 'individuell pflegen';
            }
        }
        update cons;

        Test.stopTest();

        System.assertEquals(50, [SELECT COUNT() FROM Contact WHERE MailingCity = 'Gotham City']);
        System.assertEquals(50, [SELECT COUNT() FROM Contact WHERE MailingCity = 'San Francisco']);
        System.assertEquals(100, [SELECT COUNT() FROM Contact WHERE MailingCity = 'New York City']);
    }



    static testMethod void updateAccountSyncShippingAddress() {
        Account acc = createSuperheroAccount(true);

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
        insert con;

        Test.startTest();

        acc.ShippingStreet = '567 Avengers Road';
        acc.ShippingPostalCode = '20000';
        acc.ShippingCity = 'New York City';
        acc.ShippingCountry = 'US';
        update acc;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('567 Avengers Road', con.MailingStreet);
        System.assertEquals('20000', con.MailingPostalCode);
        System.assertEquals('New York City', con.MailingCity);
        System.assertEquals('US', con.MailingCountry);
    }

    static testMethod void updateAccountSyncBillingAddress() {
        Account acc = createSuperheroAccount(true);

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
        insert con;

        Test.startTest();

        acc.ShippingPostalCode = null; // Set PostalCode to null to force incomplete ShippingAddress
        update acc;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('123 Minion Drive', con.MailingStreet);
        System.assertEquals('10000', con.MailingPostalCode);
        System.assertEquals('San Francisco', con.MailingCity);
        System.assertEquals('America', con.MailingCountry);
    }

    static testMethod void updateAccountSyncOnlyBillingAddress() {
        Account acc = createSuperheroAccount(false);
        acc.ShippingPostalCode = null; // Set PostalCode to null to force incomplete ShippingAddress
        insert acc;

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'mit Rechnungsadresse synchronisieren';
        insert con;

        Test.startTest();

        acc.ShippingPostalCode = '30000';
        update acc;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals('123 Minion Drive', con.MailingStreet);
        System.assertEquals('10000', con.MailingPostalCode);
        System.assertEquals('San Francisco', con.MailingCity);
        System.assertEquals('America', con.MailingCountry);
    }

    static testMethod void updateAccountSyncNothing() {
        Account acc = createSuperheroAccount(true);

        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.SomTv_AdressePflegen__c = 'individuell pflegen';
        insert con;

        Test.startTest();

        acc.ShippingPostalCode = '30000';
        update acc;

        Test.stopTest();

        con = reloadContact(con);
        System.assertEquals(null, con.MailingStreet);
        System.assertEquals(null, con.MailingPostalCode);
        System.assertEquals(null, con.MailingCity);
        System.assertEquals(null, con.MailingCountry);
    }

    static testMethod void bulkUpdateAccount() {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < 50; i++) {
            Account acc = createSuperheroAccount(false);
            acc.Name = 'Avengers #' + i;
            accs.add(acc);
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for (Account acc : accs) {
            for (Integer i = 0; i < 5; i++) {
                Contact con = cls_P7S1_TestData.createTestContact(false, acc);
                con.LastName = acc.Name + ' Superhero #' + i;
                con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
                cons.add(con);
            }
        }
        insert cons;

        System.assertEquals(50, [SELECT COUNT() FROM Account]);
        System.assertEquals(250, [SELECT COUNT() FROM Contact WHERE MailingCity = 'Gotham City']);

        Test.startTest();

        for (Integer i = 0; i < accs.size(); i++) {
            Account acc = accs[i];
            acc.ShippingStreet = '567 Avengers Road';
            acc.ShippingPostalCode = '20000';
            acc.ShippingCity = 'New York City';
            acc.ShippingCountry = 'US';
        }
        update accs;

        Test.stopTest();

        System.assertEquals(250, [SELECT COUNT() FROM Contact WHERE MailingCity = 'New York City']);
    }

    static testMethod void syncLogicShouldNotWorkForOtherSphere() {
        System.runAs(cls_P7S1_TestData.USER_FOR_SPHERE.get('Sgn')) {
            Account acc = createSuperheroAccount(true);

            Test.startTest();

            Contact con = cls_P7S1_TestData.createTestContact(false, acc);
            con.SomTv_AdressePflegen__c = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
            insert con;

            Test.stopTest();

            con = reloadContact(con);
            System.assertEquals(null, con.MailingStreet);
            System.assertEquals(null, con.MailingPostalCode);
            System.assertEquals(null, con.MailingCity);
            System.assertEquals(null, con.MailingCountry);
        }
    }



    private static Account createSuperheroAccount(Boolean insertObject) {
        Account acc = cls_P7S1_TestData.createTestAccount(false);
        acc.ShippingStreet = 'Superhero Blvd. 100';
        acc.ShippingPostalCode = '9000';
        acc.ShippingCity = 'Gotham City';
        acc.ShippingCountry = 'USA';
        acc.BillingStreet = '123 Minion Drive';
        acc.BillingPostalCode = '10000';
        acc.BillingCity = 'San Francisco';
        acc.BillingCountry = 'America';
        if (insertObject) insert acc;
        return acc;
    }

    private static Contact reloadContact(Contact con) {
        return [
            SELECT MailingStreet, MailingPostalCode, MailingCity, MailingCountry
              FROM Contact
             WHERE Id = :con.Id
        ];
    }

}