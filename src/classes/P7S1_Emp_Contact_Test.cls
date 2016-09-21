@isTest
private class P7S1_Emp_Contact_Test {

    static testMethod void insertDoesNothing() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        P7S1_Comp__c firma = cls_P7S1_TestData.createTestFirma(true, acc);

        Test.startTest();

        P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiter(false, firma);
        emp.P7S1_Sync__c = true;
        insert emp;

        System.assertEquals(0, [SELECT COUNT() FROM Contact]);
        System.assertEquals(1, [SELECT COUNT() FROM P7S1_Emp__c]);

        emp = reloadEmp(emp);
        System.assertEquals(null, emp.P7S1_Contact__c);

        Test.stopTest();
    }

    static testMethod void updateEmpWithSync() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        P7S1_Comp__c firma = cls_P7S1_TestData.createTestFirma(true, acc);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.FirstName = 'Bruce';
        con.LastName = 'Wayne';
        con.Email = 'superman@p7s1.net';
        insert con;
        P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiter(false, firma);
        emp.P7S1_Firstname__c = 'Clark';
        emp.P7S1_Lastname__c = 'Kent';
        emp.P7S1_Username__c = 'superman@p7s1.net';
        insert emp;

        emp = reloadEmp(emp);
        System.assertEquals(null, emp.P7S1_Contact__c);
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);

        Test.startTest();

        emp.P7S1_Sync__c = true;
        update emp;

        con = reloadContact(con);

        /* TODO: wieder einkommentieren wenn Contact-Sync aktiviert werden soll:
        System.assertEquals('Clark', con.FirstName);
        System.assertEquals('Kent', con.LastName);
        System.assertEquals('superman@p7s1.net', con.Email);
        */

        emp = reloadEmp(emp);
        System.assertEquals(con.Id, emp.P7S1_Contact__c);
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);

        Test.stopTest();
    }

    static testMethod void updateEmpWithoutSync() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.FirstName = 'Bruce';
        con.LastName = 'Wayne';
        con.Email = 'batman@p7s1.net';
        insert con;
        P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiterWithContact(con);

        emp = reloadEmp(emp);
        System.assertEquals(con.Id, emp.P7S1_Contact__c);
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);

        Test.startTest();

        emp.P7S1_Firstname__c = 'Peter';
        emp.P7S1_Lastname__c = 'Parker';
        emp.P7S1_Username__c = 'spiderman@p7s1.net';
        emp.P7S1_Sync__c = false;
        update emp;

        con = reloadContact(con);
        System.assertEquals('Bruce', con.FirstName);
        System.assertEquals('Wayne', con.LastName);
        System.assertEquals('batman@p7s1.net', con.Email);
        emp = reloadEmp(emp);
        System.assertEquals(con.Id, emp.P7S1_Contact__c);
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);

        Test.stopTest();
    }

    /* TODO: wieder einkommentieren wenn Contact-Sync aktiviert werden soll:
    static testMethod void updateEmpWithContact() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        Contact con = cls_P7S1_TestData.createTestContact(false, acc);
        con.FirstName = 'Bruce';
        con.LastName = 'Wayne';
        con.Email = 'batman@p7s1.net';
        insert con;
        P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiterWithContact(con);

        emp = reloadEmp(emp);
        System.assertEquals(con.Id, emp.P7S1_Contact__c);

        List<Contact> cons = loadContacts(emp);
        System.assertEquals(1, cons.size());

        Test.startTest();

        emp.P7S1_Firstname__c = 'Peter';
        emp.P7S1_Lastname__c = 'Parker';
        emp.P7S1_Username__c = 'spiderman@p7s1.net';
        emp.P7S1_Sync__c = true;
        update emp;

        cons = loadContacts(emp);
        System.assertEquals(2, cons.size());

        cons.sort();

        System.assertEquals('Bruce', cons[0].FirstName);
        System.assertEquals('Wayne', cons[0].LastName);
        System.assertEquals('batman@p7s1.net', cons[0].Email);
        System.assertEquals('Peter', cons[1].FirstName);
        System.assertEquals('Parker', cons[1].LastName);
        System.assertEquals('spiderman@p7s1.net', cons[1].Email);

        emp = reloadEmp(emp);
        System.assertEquals(cons[1].Id, emp.P7S1_Contact__c);

        Test.stopTest();
    }

    static testMethod void updateEmpWithouContact() {
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        P7S1_Comp__c firma = cls_P7S1_TestData.createTestFirma(true, acc);
        P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiter(true, firma);

        emp = reloadEmp(emp);
        System.assertEquals(null, emp.P7S1_Contact__c);

        System.assertEquals(0, [SELECT COUNT() FROM Contact]);

        Test.startTest();

        emp.P7S1_Firstname__c = 'Clark';
        emp.P7S1_Lastname__c = 'Kent';
        emp.P7S1_Username__c = 'superman@p7s1.net';
        emp.P7S1_Sync__c = true;
        update emp;

        List<Contact> cons = loadContacts(emp);
        System.assertEquals(1, cons.size());
        System.assertEquals('Clark', cons[0].FirstName);
        System.assertEquals('Kent', cons[0].LastName);
        System.assertEquals('superman@p7s1.net', cons[0].Email);

        emp = reloadEmp(emp);
        System.assertEquals(cons[0].Id, emp.P7S1_Contact__c);

        Test.stopTest();
    }

    static testMethod void bulkUpdate() {
        Account acc1 = cls_P7S1_TestData.createTestAccount(false);
        Account acc2 = cls_P7S1_TestData.createTestAccount(false);
        insert new List<Account>{ acc1, acc2 };
        P7S1_Comp__c firma1 = cls_P7S1_TestData.createTestFirma(false, acc1);
        P7S1_Comp__c firma2 = cls_P7S1_TestData.createTestFirma(false, acc2);
        List<P7S1_Comp__c> firmen = new List<P7S1_Comp__c>{ firma1, firma2 };
        insert firmen;

        List<P7S1_Emp__c> emps = new List<P7S1_Emp__c>();
        for (Integer i = 0; i < 200; i++) {
            P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiter(false, firmen[Math.mod(i, 2)]);
            emp.P7S1_Username__c = 'x-men-' + i + '@p7s1.net';
            emp.P7S1_Lastname__c = 'X-Men #' + i;
            emps.add(emp);
        }
        insert emps;

        System.assertEquals(0, [SELECT COUNT() FROM Contact]);
        System.assertEquals(200, [SELECT COUNT() FROM P7S1_Emp__c]);

        Test.startTest();

        emps = [SELECT P7S1_Username__c FROM P7S1_Emp__c];
        for (Integer i = 0; i < emps.size(); i++) {
            P7S1_Emp__c emp = emps[i];
            emp.P7S1_Username__c = 'avenger-' + i + '@p7s1.net';
            emp.P7S1_Sync__c = true;
        }
        emps[0].P7S1_Username__c = 'hulk@p7s1.net';
        update emps;

        System.assertEquals(200, [SELECT COUNT() FROM Contact]);
        System.assertEquals(200, [SELECT COUNT() FROM P7S1_Emp__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Email = 'hulk@p7s1.net']);
        System.assertEquals(1, [SELECT COUNT() FROM P7S1_Emp__c WHERE P7S1_Username__c = 'hulk@p7s1.net']);

        Test.stopTest();
    }
    */

    private static List<Contact> loadContacts(P7S1_Emp__c emp) {
        return [SELECT Email, FirstName, LastName, P7S1_Emp__c FROM Contact WHERE P7S1_Emp__c = :emp.Id];
    }

    private static P7S1_Emp__c reloadEmp(P7S1_Emp__c emp) {
        return [SELECT P7S1_Username__c, P7S1_Email__c, P7S1_Firstname__c, P7S1_Lastname__c, P7S1_Contact__c FROM P7S1_Emp__c WHERE Id = :emp.Id];
    }

    private static Contact reloadContact(Contact con) {
        return [SELECT Email, FirstName, LastName, P7S1_Emp__c FROM Contact WHERE Id = :con.Id];
    }

}