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
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_WtAgBeziehung_DigitalOwner_Test.cls
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.1
* @ date        21.01.2016 
* @description  
* @last change  
* @objects     Account, SomDig_WtAgBeziehung__c
* =================================================================
*/ 
@isTest
private class P7S1_WtAgBeziehung_DigitalOwner_Test {
	
	static Account wt = new Account();
	static Final string WTNAME = 'Werbetreibender';
	static Final string AGNAME = 'Agentur';
		
	static testMethod void testAccountWtAgBeziehung() {
        Test.starttest();                
		generateTestData(); 
		set<ID> accIDs = new set<ID>();
		List<Account> testAccounts = new List<Account>();
		for(Account a:[select id from Account]){
			accIDs.add(a.id);
			testAccounts.add(a);
		}   
		system.debug('WT Account: ' + wt.id);
		list<AggregateResult>groupedResults = new list<AggregateResult>();  
		groupedResults= [SELECT P7S1_GroupedId__c, SUM(SomDig_PrognoseGesamtAj__c),SUM(SomDig_UmsatzGesamtAj__c) FROM SomDig_WtAgBeziehung__c  where SomDig_Werbetreibender__c in :accIDs and P7S1_GroupedId__c !=NULL AND P7S1_GroupedId__c !='' GROUP BY P7S1_GroupedId__c];
		system.assertNotEquals(0,groupedResults.size());
		system.assertEquals(Userinfo.getUserID(),[select id,SOM_DigitalSales__c from Account where name = :WTNAME].SOM_DigitalSales__c);
		List<AccountTeamMember> atm = [select id from AccountTeamMember where AccountId = :wt.id];
		system.assertEquals(1,atm.size());					
        Test.stopTest();
	}
	
	public static void generateTestData(){
		wt = P7S1_TestdatageneratorAtmWtAg.generateTestData();
	}	
        
        
}