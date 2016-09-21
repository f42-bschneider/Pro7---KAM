@isTest
private class Ven_Account_Type_Test {

    static testMethod void testVenAccountType() {
        Account testAccount = cls_P7S1_TestData.createTestAccount(false);
        testAccount.Ven_Target__c = true;
        testAccount.Ven_Customer__c = false;
        insert testAccount;

        Account testAccount2 = cls_P7S1_TestData.createTestAccount(false);
        testAccount2.Ven_Target__c = true;
        testAccount2.Ven_Customer__c = false;
        insert testAccount2;

        List<RecordType> venRecordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName LIKE 'Ven_%' AND IsActive = true LIMIT 1];
        List<RecordType> notVenRecordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND (NOT DeveloperName LIKE 'Ven_%') AND IsActive = true LIMIT 1];

        Id venRecordTypeId;

        if (!venRecordTypes.isEmpty()) {
            venRecordTypeId = venRecordTypes.get(0).Id;
        }

        Id notVenRecordTypeId;

        if (!notVenRecordTypes.isEmpty()) {
            notVenRecordTypeId = notVenRecordTypes.get(0).Id;
        }

        Test.startTest();

        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opp';
        testOpp.StageName = 'Finished';
        testOpp.CloseDate = Date.today().addDays(7);
        testOpp.AccountId = testAccount.Id;

        if (venRecordTypeId != null) {
            testOpp.RecordTypeId = venRecordTypeId;
        }

        insert testOpp;

        testOpp.StageName = 'Contact';
        update testOpp;

        Opportunity testOpp2 = new Opportunity();
        testOpp2.Name = 'Test Opp 2';
        testOpp2.StageName = 'Contact';
        testOpp2.CloseDate = Date.today().addDays(7);
        testOpp2.AccountId = testAccount.Id;

        if (venRecordTypeId != null) {
            testOpp2.RecordTypeId = venRecordTypeId;
        }

        insert testOpp2;

        testOpp2.StageName = 'Finished';
        update testOpp2;

        testOpp2.AccountId = testAccount2.Id;
        update testOpp2;

        delete testOpp2;

        Test.stopTest();
    }

    static testMethod void testVenCapTableTrigger() {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.Phone = '123456789-1';
        testAccount.Fax = '123456789-0';
        testAccount.Website = 'www.testWebsite.com';
        insert testAccount;

        Account testAccount2 = new Account();
        testAccount2.Name = 'Test Account 2';
        testAccount2.Ven_Investor__c = false;
        testAccount2.Phone = '123456789-1';
        testAccount2.Fax = '123456789-0';
        testAccount2.Website = 'www.test2Website.com';
        insert testAccount2;

        Test.startTest();

        delete ClsHelper.insertRounds1And2AndShares(testAccount.Id);

        Test.stopTest();
    }

}