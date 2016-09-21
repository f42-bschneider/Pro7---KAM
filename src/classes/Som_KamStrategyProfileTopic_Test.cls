/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* Som_KamStrategyProfileTopic_Test
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         25-4-2016
* @description  
* @lastchange   16-06-2016 VS: Optimized Testclass
* @objects      
* =================================================================
*/
@isTest
public without sharing class Som_KamStrategyProfileTopic_Test {

	@TestSetup
	private static void createData(){
        Test.startTest();
        //Create 1 Som_KamDetail and 3 Som_KamStrategyProfileTopic
        Som_Kam_CmpCtrl_Test.createAccountPlan(true, true);

		Test.stopTest();
	}
	
    @isTest
    private static void test_insertDelete(){
        Test.startTest();

        //Check if dataentries where created
        system.assertEquals(1,[select count() from Som_Kam__c]);
        system.assertEquals(3,[SELECT count() FROM Som_KamStrategyProfileTopic__c]);

        //Delete Som_KamDetail
        delete [SELECT Id FROM Som_KamStrategyProfileTopic__c WHERE Som_IsTemplate__c = true LIMIT 1];
        //Check if depending Parents are also deleted
        system.assertEquals(0,[SELECT count() FROM Som_KamStrategyProfileTopic__c]);

        Test.stopTest();
    }
}