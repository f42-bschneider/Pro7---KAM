@isTest
public class P7S1_Account_Visibility_Test{

    
    public static testMethod void testAccountVisibility(){
    
        // Test insert, P7S1_AccountVisibility__c must be 0
        Account objAccount = cls_P7S1_TestData.createTestAccount(false);
        objAccount.SomTv_CleanUp_Delete__c = true;
        insert objAccount;
        
        
        objAccount = [SELECT P7S1_AccountVisibility__c FROM Account WHERE ID = :objAccount.ID];
        System.assertEquals(objAccount.P7S1_AccountVisibility__c, 0);
        
        
        
        // Insert Contact
        Contact objContact = cls_P7S1_TestData.createTestContact(true, objAccount);    
        
        
        
        // Change value on Account, P7S1_AccountVisibility__c must be 50 on Account and Contact
        objAccount.SomTv_CleanUp_Delete__c = false;
        objAccount.ungueltiger_Account__c = true;
        update objAccount;
        
        
        objAccount = [SELECT P7S1_AccountVisibility__c FROM Account WHERE ID = :objAccount.ID];
        objContact = [SELECT P7S1_AccountVisibility__c FROM Contact WHERE ID = :objContact.ID];        
        System.assertEquals(objAccount.P7S1_AccountVisibility__c, 50);        
        System.assertEquals(objContact.P7S1_AccountVisibility__c, 50);                
        
        
        
        // Test for 100 value
        objAccount.ungueltiger_Account__c = false;
        update objAccount;
        
        
        objAccount = [SELECT P7S1_AccountVisibility__c FROM Account WHERE ID = :objAccount.ID];
        objContact = [SELECT P7S1_AccountVisibility__c FROM Contact WHERE ID = :objContact.ID];        
        System.assertEquals(objAccount.P7S1_AccountVisibility__c, 100);        
        System.assertEquals(objContact.P7S1_AccountVisibility__c, 100);                        
    }
}