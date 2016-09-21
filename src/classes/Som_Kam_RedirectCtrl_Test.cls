/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* Som_Kam_RedirectCtrl_Test
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         6-4-2016
* @description
* @lastchange
* @objects
* =================================================================
*/
@isTest
public without sharing class Som_Kam_RedirectCtrl_Test {
	@isTest
    private static void testBackToAccount(){
        Test.startTest();

        Account acc = cls_P7S1_TestData.createTestAccount(true);

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Som_Kam_RedirectCtrl ctrl = new Som_Kam_RedirectCtrl(sc);

        PageReference pageRef = Page.Som_Kam_Redirect;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);

        ctrl.backToAccount();

        Test.stopTest();
    }


    /************
    * user is kam but there is no acc plan yet
    ************/
    @isTest
    private static void testRedirectIsKamAndNoAccPlanYet(){
        Test.startTest();

        Account acc = cls_P7S1_TestData.createTestAccount(false);
        acc.Som_Kam__c = UserInfo.getUserId();
        insert acc;

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Som_Kam_RedirectCtrl ctrl = new Som_Kam_RedirectCtrl(sc);

        PageReference pageRef = Page.Som_Kam_Redirect;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);

        List<User> users = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        ctrl.redirect();

        system.assertEquals(ctrl.parameter, 'accId='+acc.Id, 'account parameter is set only => new account plan');
        system.assertEquals(ctrl.msg, null, 'msg is not set');

        Test.stopTest();
    }

    /************
    * user is kam and there is a acc plan
    ************/
    @isTest
    private static void testRedirectIsKamAccPlanExists(){
        Test.startTest();

        Account acc = cls_P7S1_TestData.createTestAccount(false);
        acc.Som_Kam__c = UserInfo.getUserId();
        insert acc;

        Som_Kam__c accPlan = cls_P7S1_TestData.createTestAccountPlan(true, acc.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Som_Kam_RedirectCtrl ctrl = new Som_Kam_RedirectCtrl(sc);

        PageReference pageRef = Page.Som_Kam_Redirect;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);

        ctrl.redirect();

        system.assertEquals(ctrl.parameter, 'accId='+acc.Id +'&accPlanId='+accPlan.Id, 'account plan id is set as parameter');

        Test.stopTest();
    }


    /************
    * user is kam and detail planner
    ************/
    @isTest
    private static void testRedirectIsKamAccPlanAndDetailPlanExists(){
        Test.startTest();

        Account acc = cls_P7S1_TestData.createTestAccount(false);
        acc.Som_Kam__c = UserInfo.getUserId();
        insert acc;

        Som_Kam__c accPlan = cls_P7S1_TestData.createTestAccountPlan(true, acc.Id);
        Som_KamDetail__c accPlanDetail = cls_P7S1_TestData.createTestAccountPlanDetail(false, accPlan.Id);
        accPlanDetail.Som_KamTeamMember__c = UserInfo.getUserId();
        insert accPlanDetail;

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Som_Kam_RedirectCtrl ctrl = new Som_Kam_RedirectCtrl(sc);

        PageReference pageRef = Page.Som_Kam_Redirect;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);

        ctrl.redirect();

        system.assertEquals(ctrl.parameter, 'accId='+acc.Id, 'no parameter set but accId');
        system.assertNotEquals(ctrl.accountPlan, null, 'account plan set');
        system.assertNotEquals(ctrl.accountPlanDetails, null, 'account plan details set');

        Test.stopTest();
    }


    /************
    * user isnt kam and there is no acc plan yet
    ************/
    @isTest
    private static void testRedirectIsntKamNoAccPlan(){
        Test.startTest();

        Account acc = cls_P7S1_TestData.createTestAccount(true);

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Som_Kam_RedirectCtrl ctrl = new Som_Kam_RedirectCtrl(sc);

        PageReference pageRef = Page.Som_Kam_Redirect;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);

        ctrl.redirect();

        system.assertEquals(ctrl.msg, Label.Som_lbl_AccPlanRedirectNoPlan, 'OK => '+Label.Som_lbl_AccPlanRedirectNoPlan);

        Test.stopTest();
    }


    /************
    * user isnt kam acc plan exists but no matching detail
    ************/
    @isTest
    private static void testRedirectIsntKamNoAccPlanDetail(){
        Test.startTest();

        Account acc = cls_P7S1_TestData.createTestAccount(true);

        Som_Kam__c accPlan = cls_P7S1_TestData.createTestAccountPlan(true, acc.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Som_Kam_RedirectCtrl ctrl = new Som_Kam_RedirectCtrl(sc);

        PageReference pageRef = Page.Som_Kam_Redirect;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);

        ctrl.redirect();

        system.assertEquals(ctrl.msg, Label.Som_lbl_AccPlanRedirectNoAccess, 'OK => '+Label.Som_lbl_AccPlanRedirectNoAccess);

        Test.stopTest();
    }


    /************
    * user isnt kam acc plan exists and matching detail
    ************/
    @isTest
    private static void testRedirectIsntKamAndAccPlanDetail(){
        Test.startTest();

        Account acc = cls_P7S1_TestData.createTestAccount(true);

        Som_Kam__c accPlan = cls_P7S1_TestData.createTestAccountPlan(true, acc.Id);
        Som_KamDetail__c accPlanDetail = cls_P7S1_TestData.createTestAccountPlanDetail(false, accPlan.Id);
        accPlanDetail.Som_KamTeamMember__c = UserInfo.getUserId();
        insert accPlanDetail;

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Som_Kam_RedirectCtrl ctrl = new Som_Kam_RedirectCtrl(sc);

        PageReference pageRef = Page.Som_Kam_Redirect;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);

        ctrl.redirect();

        system.assertEquals('accId='+acc.Id, ctrl.parameter, 'account plan detail id is set');
        system.assertEquals(1, ctrl.accountPlanDetails.size());

        Test.stopTest();
    }


    /************
    * user isnt kam acc plan exists and several matching details
    ************/
    @isTest
    private static void testRedirectIsntKamAndSeveralAccPlanDetails(){
        Test.startTest();

        Account acc = cls_P7S1_TestData.createTestAccount(true);

        Som_Kam__c accPlan = cls_P7S1_TestData.createTestAccountPlan(true, acc.Id);

        Som_KamDetail__c accPlanDetail = cls_P7S1_TestData.createTestAccountPlanDetail(false, accPlan.Id);
        accPlanDetail.Som_KamTeamMember__c = UserInfo.getUserId();
        insert accPlanDetail;

        accPlanDetail = cls_P7S1_TestData.createTestAccountPlanDetail(false, accPlan.Id);
        accPlanDetail.Som_KamTeamMember__c = UserInfo.getUserId();
        insert accPlanDetail;

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Som_Kam_RedirectCtrl ctrl = new Som_Kam_RedirectCtrl(sc);

        PageReference pageRef = Page.Som_Kam_Redirect;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);

        ctrl.redirect();

        system.assertEquals('accId='+acc.Id, ctrl.parameter, 'no parameter set but accId');
        system.assertNotEquals(null, ctrl.accountPlan, 'account plan not set');
        system.assertEquals(2, ctrl.accountPlanDetails.size(), 'account plan details set');

        Test.stopTest();
    }
}