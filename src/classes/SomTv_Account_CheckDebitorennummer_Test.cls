@isTest
public class SomTv_Account_CheckDebitorennummer_Test{

    public static testMethod void testAccountDebitorenNummerChecker() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Systemadministrator' Limit 1];
        User    u = new User(Username='testADNC@test.com', LastName='testADNC', 
                             Email='testADNC@test.com', Alias='test', CommunityNickname='testADNC',
                             TimeZoneSidKey='Europe/Berlin', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                             ProfileId=p.Id, LanguageLocaleKey='en_US');
        insert u;

        System.runAs(u) {
            Test.StartTest();

            Account acc1 = new Account(Name='Test Account 1', SomTv_Gruendungsjahr__c='2013');
            insert acc1;

            Account acc2 = new Account(Name='Test Account 2', SomTv_Gruendungsjahr__c='2013');
            insert acc2;

            Account acc3 = new Account(Name='Test Account 3', SomTv_Gruendungsjahr__c='2013');
            insert acc3;
            
            P7S1_ExternalId__c ext2 = new P7S1_ExternalId__c(name='1', P7S1_Account__c=acc2.id, P7S1_Source__c='DebitorenNr', P7S1_ExtIdUniqueKey__c='1234');
            insert ext2;

            P7S1_ExternalId__c ext3 = new P7S1_ExternalId__c(name='2', P7S1_Account__c=acc3.id, P7S1_Source__c='DebitorenNr', P7S1_ExtIdUniqueKey__c=null);
            insert ext3;
            
            SchedulableContext sc;

            SomTv_Account_CheckDebitorennummer adnc = new SomTv_Account_CheckDebitorennummer();

            adnc.setRecipient(null);
            adnc.setAccountIds(null);
            
            adnc.addAccountId(acc1.id);
            adnc.addAccountId(acc2.id);
            adnc.addAccountId(acc3.id);

            adnc.execute(sc);

            Test.StopTest();
        }
    }
    
}