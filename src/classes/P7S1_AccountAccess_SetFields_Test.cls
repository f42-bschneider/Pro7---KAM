@isTest
private with sharing class P7S1_AccountAccess_SetFields_Test {

    static testMethod void setOwnerAndIndex() {
        User user = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomDig_Sales');
        user.P7S1_Unit__c = '71M';
        update user;

        Account acc = cls_P7S1_TestData.createTestAccount(false);
        acc.OwnerId = user.Id;
        insert acc;

        P7S1_AccountIndex__c accountIndex = [SELECT Id FROM P7S1_AccountIndex__c WHERE P7S1_Account__c = :acc.Id].get(0);

        Test.startTest();

        P7S1_AccountAccess__c accountAccess = createTestAccountAccess(false);
        accountAccess.P7S1_Account__c = acc.Id;
        insert accountAccess;

        accountAccess = [SELECT P7S1_AccountOwner__c, P7S1_AccountIndex__c FROM P7S1_AccountAccess__c WHERE Id = :accountAccess.Id].get(0);
        System.assertEquals(user.Id, accountAccess.P7S1_AccountOwner__c);
        System.assertEquals(accountIndex.Id, accountAccess.P7S1_AccountIndex__c);

        Test.stopTest();
    }

    static testMethod void setOwnerAndAccount() {
        User user = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomTv_TeamCRM');
        user.P7S1_Unit__c = '71M';
        update user;

        Account acc = cls_P7S1_TestData.createTestAccount(false);
        acc.OwnerId = user.Id;
        insert acc;

        P7S1_AccountIndex__c accountIndex = [SELECT Id FROM P7S1_AccountIndex__c WHERE P7S1_Account__c = :acc.Id].get(0);

        Test.startTest();

        P7S1_AccountAccess__c accountAccess = createTestAccountAccess(false);
        accountAccess.P7S1_AccountIndex__c = accountIndex.Id;
        insert accountAccess;

        accountAccess = [SELECT P7S1_AccountOwner__c, P7S1_Account__c FROM P7S1_AccountAccess__c WHERE Id = :accountAccess.Id].get(0);
        System.assertEquals(user.Id, accountAccess.P7S1_AccountOwner__c);
        System.assertEquals(acc.Id, accountAccess.P7S1_Account__c);

        Test.stopTest();
    }



    // TODO: in TestData auslagern
    public static P7S1_AccountAccess__c accountAccess_TestData;
    public static P7S1_AccountAccess__c createTestAccountAccess(Boolean insertObject) {
        accountAccess_TestData = new P7S1_AccountAccess__c();
        if (insertObject) insert accountAccess_TestData;
        return accountAccess_TestData;
    }

}