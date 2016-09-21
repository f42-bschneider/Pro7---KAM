/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_Lookup_CmpCtrl_Test
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         2016/02/29
* @description  
* @lastchange  
* @objects      
* =================================================================
*/
@isTest
public with sharing class P7S1_Lookup_CmpCtrl_Test {
	
    @isTest
    private static void test_lookup(){
        Test.startTest();

        Account acc = cls_P7S1_TestData.createTestAccount(true);

        P7S1_Lookup_CmpCtrl.getLookups('Account', 'Name', 'Name');

        Test.stopTest();
    }
}