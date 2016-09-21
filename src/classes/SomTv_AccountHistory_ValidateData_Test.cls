@isTest(SeeAllData=true)
public class SomTv_AccountHistory_ValidateData_Test{
    public static testMethod void testAccountHistoryValidateData(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Systemadministrator' Limit 1];
        User    u = new User(Username='testAZT@test.com', LastName='testAZT', 
                             Email='testAZT@test.com', Alias='test', CommunityNickname='testAZT',
                             TimeZoneSidKey='Europe/Berlin', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                             ProfileId=p.Id, LanguageLocaleKey='en_US');

        insert u;

        System.runAs(u) {
          Account acc1 = new Account(Name = 'TestAccount1');
          insert acc1;
          
          Account acc2 = new Account(Name = 'TestAccount2');
          insert acc2;
          
          AccountHistory__c a1 = new AccountHistory__c();
          a1.UebergeordneterAccount__c = acc1.Id;
          a1.UntergeordneterAccount__c = acc2.Id;
                    
          // Test GueltigVon__c == null
          try {  
            insert a1;
          } catch (Exception e) {
          }
          
          // Test GueltigBis__c < GueltigVon__c
          a1.GueltigVon__c = Date.newinstance(2012, 08, 01);
          a1.GueltigBis__c = Date.newinstance(2012, 07, 01);
          try {  
            insert a1;
          } catch (Exception e) {
          }

          a1.GueltigBis__c = Date.newinstance(2012, 08, 31);
          insert a1;

          // Test UebergeordneterAccount__c == UntergeordneterAccount__c
          a1.UntergeordneterAccount__c = a1.UebergeordneterAccount__c;
          try {  
            update a1;
          } catch (Exception e) {
          }

          a1.UebergeordneterAccount__c = acc2.Id;
          update a1;

      delete a1;
      undelete a1;
      
          AccountHistory__c a2 = new AccountHistory__c(GueltigVon__c = Date.newinstance(2012, 09, 01),
                                 GueltigBis__c = Date.newinstance(2012, 09, 30),
                                 UntergeordneterAccount__c = acc1.Id,
                                 UebergeordneterAccount__c = acc2.Id);

          AccountHistory__c a3 = new AccountHistory__c(GueltigVon__c = Date.newinstance(2012, 09, 01),
                                 GueltigBis__c = Date.newinstance(2012, 09, 30),
                                 UntergeordneterAccount__c = acc1.Id,
                                 UebergeordneterAccount__c = acc2.Id);

          AccountHistory__c a4 = new AccountHistory__c(GueltigVon__c = Date.newinstance(2012, 08, 01),
                                 GueltigBis__c = Date.newinstance(2012, 08, 31),
                                 UntergeordneterAccount__c = acc1.Id,
                                 UebergeordneterAccount__c = acc2.Id);

      List<AccountHistory__c> lst = new List<AccountHistory__c>();
      lst.add(a2);
      lst.add(a3);
      lst.add(a4);
      
      try {
            insert lst;
          } catch (Exception e) {
          }
      
      lst.remove(2);
      lst.remove(1);
      insert lst;      

      try {
            insert a4;
          } catch (Exception e) {
          }
        }
    }
}