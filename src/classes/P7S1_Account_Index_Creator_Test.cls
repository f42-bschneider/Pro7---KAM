/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_Account_Index_Creator_Test.cls
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.2
* @ date        26.10.2015 
* @description  
* @last change  01.12.2015 VVR: Updated Testcase for new logic on creating Accountindex
*               03.12.2015 VVR: Updated Testcase for deleting AccountIndex after owner change
* @objects     Account, P7S1_AccountIndex__c
* =================================================================
*/ 
@isTest
private class P7S1_Account_Index_Creator_Test {

    static testMethod void testAccountIndexUpsert() {
        Test.starttest();                
        Account a = cls_P7S1_TestData.createTestAccount(false);
        a.ownerID = updUser('71M').id;
        //Set flag to avoid update after insert
        P7S1_Account_Index_Creator.doUpdate = false;
        insert a;
        List<P7S1_AccountIndex__c> aiList = [select id,name,P7S1_External_ID__c from P7S1_AccountIndex__c];
        system.assertEquals(1,aiList.size());
        system.assertEquals(a.name,aiList[0].name);
        system.assertEquals(a.id,aiList[0].P7S1_External_ID__c);
        Account checkAccount = [select id,P7S1_AccountIndexErzeugen__c from Account where id = :a.id];
        system.assertEquals(true,checkAccount.P7S1_AccountIndexErzeugen__c);
        //Do update with different user and no acitve unit
        P7S1_Account_Index_Creator.doUpdate = true;
        User u = [select id from User where isactive = true Limit 1];
        u.P7S1_Unit__c = 'f42';
        update u;
        a.ownerID = u.id;
        update a;        
        //Check if flag is set to false
        checkAccount = [select id,P7S1_AccountIndexErzeugen__c from Account where id = :a.id];
        system.assertEquals(false,checkAccount.P7S1_AccountIndexErzeugen__c);       
        //Check if depending account index is deleted
        aiList = [select id,name,P7S1_External_ID__c from P7S1_AccountIndex__c];
        system.assertEquals(0,aiList.size());               
        Test.stopTest();
    }
    
    static testMethod void testAccountIndexUpsertBulk() {
        final integer BULKVALUE = 250; 
        Test.starttest();
        List<Account> accBulkList = new List<Account>();
        User u = updUser('71M');
        for(integer i=0;i <=BULKVALUE;i++){
            Account a = cls_P7S1_TestData.createTestAccount(false);
            a.ownerID = u.id;
            accBulkList.add(a);
        }
        insert accBulkList;
        
        List<P7S1_AccountIndex__c> aiList = [select id,name,P7S1_External_ID__c from P7S1_AccountIndex__c];
        system.assertEquals(accBulkList.size(),aiList.size());
        update accBulkList;
        delete accBulkList; 
        aiList = [select id,name,P7S1_External_ID__c from P7S1_AccountIndex__c];
        system.assertEquals(0,aiList.size());                
        Test.stopTest();
    } 

    //Update user to get unit for account. Deppending in unit, P7S1_AccountIndexErzeugen__c is set to true
    static user updUser(string unitname){
        User u = new User(id= UserInfo.getUserId(),P7S1_Unit__c = unitname);
        update u;
        return u;
    }   
}