/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* Som_Kam_RedirectCtrl_Test
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         19-4-2016
* @description  
* @lastchange  
* @objects      
* =================================================================
*/
@isTest
public without sharing class Som_Kam_CmpCtrl_Test {
    
    /************
    * test save account plan new
    ************/
    @isTest
    private static void testSaveAccountPlan_New(){
        Test.startTest();

        createAccountPlan(true, false);        

        Test.stopTest();
    }

    /************
    * test save account plan new => use default team member
    ************/
    @isTest
    private static void testSaveAccountPlan_New_DefaultTeamMember(){
        Test.startTest();

        createAccountPlan(false, false);        

        Test.stopTest();
    }


    /************
    * test delete account plan
    ************/
    @isTest
    private static void testDeleteAccountPlan(){
        Test.startTest();

        createAccountPlan(false, false);
        Som_Kam__c ap = [SELECT Id FROM Som_Kam__c LIMIT 1][0];

        Som_Kam_CmpCtrl.deleteAccountPlan(ap.Id);       

        Test.stopTest();
    }


    /************
    * test save account plan new => use default team member
    ************/
    @isTest
    private static void testSaveAccountPlan_New_SeveralTeamMembers(){
        Test.startTest();

        createAccountPlan(true, true);        

        Test.stopTest();
    }


    /************
    * test get account plan
    ************/
    @isTest
    private static void testGetAccountPlanEditData(){
        Test.startTest();

        createAccountPlan(true, false);

        Account acc                     = [SELECT Id FROM Account LIMIT 1][0];
        Som_Kam__c ap           = [SELECT Id FROM Som_Kam__c LIMIT 1][0];

        Som_Kam_CmpCtrl.getAccountPlanEditData(acc.Id, ap.Id);

        Test.stopTest();
    }


    /************
    * test get account plan detail
    ************/
    @isTest
    private static void testGetAccountPlanDetailEditData(){
        Test.startTest();

        createAccountPlan(true, false);

        Som_KamDetail__c apd = [SELECT Id FROM Som_KamDetail__c LIMIT 1][0];

        Som_Kam_CmpCtrl.getAccountPlanDetailEditData(apd.Id);

        Test.stopTest();
    }


    /************
    * test invite for kickoff
    ************/
    @isTest
    private static void testInviteForKickoff(){
        Test.startTest();

        createAccountPlan(true, false);

        Account acc = [SELECT Id FROM Account LIMIT 1][0];
        Som_Kam__c ap = [SELECT Id FROM Som_Kam__c LIMIT 1][0];
        List<String> aptIds = new List<String>();

        for(Som_KamTeam__c apt : [SELECT Id FROM Som_KamTeam__c]){
            aptIds.add(apt.Id);
        }

        Som_Kam_CmpCtrl.inviteForKickoff(aptIds, ap.Id, acc.Id, '');

        Test.stopTest();
    }


    /************
    * test invite for review
    ************/
    @isTest
    private static void testInviteForReview(){
        Test.startTest();

        createAccountPlan(true, false);

        Account acc = [SELECT Id FROM Account LIMIT 1][0];
        Som_Kam__c ap = [SELECT Id FROM Som_Kam__c LIMIT 1][0];
        List<String> aptIds = new List<String>();

        for(Som_KamTeam__c apt : [SELECT Id FROM Som_KamTeam__c]){
            aptIds.add(apt.Id);
        }

        Som_Kam_CmpCtrl.inviteForReview(aptIds, ap.Id, acc.Id, '');

        Test.stopTest();
    }


    /************
    * test save account plan detail
    ************/
    @isTest
    private static void testSaveAccountPlanDetail(){
        Test.startTest();

        createAccountPlan(true, false);

        Som_KamDetail__c apd = [
            SELECT 
                Id,
                Name,
                Som_Kam__c,
                Som_KamTeam__c,
                Som_KamTeamMember__c,
                Som_CashExternalYield__c,
                Som_CashIn__c,
                Som_DaysUnitlKickoff__c,
                Som_DaysUntilReview__c,
                Som_KamAccountCashIn__c,
                Som_PreviousCashExternalYield__c,
                Som_PreviousCashIn__c,
                Som_RatingDealLearnings__c,
                Som_Status__c,
                Som_TargetCashIn__c 
            FROM
                Som_KamDetail__c
            LIMIT
                1][0];

        List<Som_KamStrategyProfileTopic__c> profStrats = [
            SELECT 
                Id, Name, Som_Kam__c, Som_KamDetail__c, Som_Description__c 
            FROM 
                Som_KamStrategyProfileTopic__c 
            WHERE 
                Som_KamDetail__c = :apd.Id];

        List<Som_KamDetailCashIn__c> cashInUpserts = [
            SELECT
                Id,
                Name,
                Som_KamDetail__c,
                Som_KamAccountCashInDetail__c,
                Som_CashExternalYield__c,
                Som_Cashin__c,
     //           Som_PreviousCashExternalYield__c,
                Som_PreviousCashIn__c
            FROM
                Som_KamDetailCashIn__c
            WHERE
                Som_KamDetail__c = :apd.Id];

        List<Som_KamDetailCashIn__c> cashInDeletes = new List<Som_KamDetailCashIn__c>{cashInUpserts.get(0)};

        cashInUpserts.remove(0);

        Som_Kam_CmpCtrl.saveAccountPlanDetail(
            apd, 
            profStrats, 
            cashInUpserts, 
            cashInDeletes);

        Test.stopTest();
    }


    /************
    * test save account plan detail
    ************/
    @isTest
    private static void testSaveAccountPlan_Update(){
        Test.startTest();

        createAccountPlan(true, false);

        Som_Kam__c ap = [
            SELECT
                Id,
                Name,
                Som_Account__c,
                Som_Account__r.Name,
                Som_EmailText__c,
                Som_Kickoff__c,
                Som_Year__c,
                Som_Review__c
            FROM
                Som_Kam__c
            LIMIT
                1][0];


        List<Som_KamStrategyProfileTopic__c> accPlanStrategies = [
            SELECT 
                Id, Name, Som_Kam__c, Som_KamDetail__c, Som_Description__c 
            FROM 
                Som_KamStrategyProfileTopic__c 
            WHERE 
                Som_KamDetail__c = :ap.Id];


        List<Som_KamDetail__c> apds = [
            SELECT 
                Id,
                Name,
                Som_Kam__c,
                Som_KamTeam__c,
                Som_KamTeamMember__c,
                Som_CashExternalYield__c,
                Som_CashIn__c,
                Som_DaysUnitlKickoff__c,
                Som_DaysUntilReview__c,
                Som_KamAccountCashIn__c,
                Som_PreviousCashExternalYield__c,
                Som_PreviousCashIn__c,
                Som_RatingDealLearnings__c,
                Som_Status__c,
                Som_TargetCashIn__c 
            FROM
                Som_KamDetail__c
            WHERE 
                Som_Kam__c = :ap.Id];


        Set<Id> apdIds = new Set<Id>();
        for(Som_KamDetail__c apd : apds){
            apdIds.add(apd.Id);
        }


        List<Som_KamStrategyProfileTopic__c> accPlanDetailStrategies = [
            SELECT 
                Id, Name, Som_Kam__c, Som_KamDetail__c, Som_Description__c 
            FROM 
                Som_KamStrategyProfileTopic__c 
            WHERE 
                Som_KamDetail__c IN :apdIds];


        List<Som_KamDetailCashIn__c> accPlanDetailCashInsUpsert = [
            SELECT
                Id,
                Name,
                Som_KamDetail__c,
                Som_KamAccountCashInDetail__c,
                Som_CashExternalYield__c,
                Som_Cashin__c,
                Som_PreviousCashExternalYield__c,
                Som_PreviousCashIn__c
            FROM
                Som_KamDetailCashIn__c
            WHERE
                Som_KamDetail__c IN :apdIds];

        List<Som_KamDetailCashIn__c> accPlanDetailCashInsDelete = new List<Som_KamDetailCashIn__c>{accPlanDetailCashInsUpsert.get(0)};

        accPlanDetailCashInsUpsert.remove(0);

        Som_Kam_CmpCtrl.saveAccountPlan(
            ap, 
            apds, 
            new List<Som_KamDetail__c>(), 
            accPlanDetailCashInsUpsert,
            accPlanDetailCashInsDelete,
            accPlanStrategies,
            accPlanDetailStrategies);

        Test.stopTest();
    }




    /************
    * 
    ************/
    public static void createAccountPlan(Boolean insertTeamMember, Boolean insert2TeamMembers){      
        Account acc = cls_P7S1_TestData.createTestAccount(true);

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = cls_P7S1_TestData.createTestUser(true, p.Id, 1);
        User u2 = cls_P7S1_TestData.createTestUser(true, p.Id, 2);

        if(insertTeamMember){            
            cls_P7S1_TestData.createTestAccountTeamMember(true, acc.Id, 'Test Role', u.Id);

            if(insert2TeamMembers){                
                cls_P7S1_TestData.createTestAccountTeamMember(true, acc.Id, 'Test Role', u2.Id);
            }
        }

        Som_KamTeam__c apt1 = cls_P7S1_TestData.createTestAccountPlanTeam(true, 'Test 1', UserInfo.getUserId(), 'Test Role');

        Som_KamStrategyProfileTopic__c stratProf = cls_P7S1_TestData.createTestStrategyProfileTopic(true, true, 'Test Strategy Profile');

        Som_KamAccountCashIn__c annualAccCashIn1 = cls_P7S1_TestData.createTestAnnualAccountCashIn(true, acc.Id, apt1.Id, Date.today().year());
        Som_KamAccountCashIn__c annualAccCashIn2 = cls_P7S1_TestData.createTestAnnualAccountCashIn(true, acc.Id, apt1.Id, Date.today().year());

        cls_P7S1_TestData.createTestAnnualAccountCashInDetail(true, annualAccCashIn1.Id);
        cls_P7S1_TestData.createTestAnnualAccountCashInDetail(true, annualAccCashIn2.Id);
        
        Som_Kam__c ap = cls_P7S1_TestData.createTestAccountPlan(false, acc.Id);
        ap.Som_Account__c = acc.Id;

        Som_KamDetail__c apd1 = cls_P7S1_TestData.createTestAccountPlanDetail(false, ap.Id);
        apd1.Som_KamTeam__c = apt1.Id;
        apd1.Som_KamTeamMember__c = u.Id;
        apd1.Som_Status__c = 'Created';

        List<Som_KamDetail__c> apds = new List<Som_KamDetail__c>{apd1};

        Som_Kam_CmpCtrl.saveAccountPlan(
            ap, 
            apds, 
            new List<Som_KamDetail__c>(), 
            new List<Som_KamDetailCashIn__c>(),
            new List<Som_KamDetailCashIn__c>(),
            new List<Som_KamStrategyProfileTopic__c>(),
            new List<Som_KamStrategyProfileTopic__c>());
    }
}