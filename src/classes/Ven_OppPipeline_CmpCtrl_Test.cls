/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* Ven_OppPipeline_CmpCtrl_Test
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         2015/11/17
* @description
* @lastchange
* @objects
* =================================================================
*/
@isTest
public without sharing class Ven_OppPipeline_CmpCtrl_Test {

    @isTest
    private static void test_IncreaseCoverage(){
        Test.startTest();
        //******************************************************

        Ven_OppPipeline_CmpCtrl ctrl = new Ven_OppPipeline_CmpCtrl();
        ctrl.redirect();

        //Opportunity
        Opportunity opp = cls_P7S1_TestData.createTestOpportunity(true);

        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        Ven_OppPipeline_CmpCtrl ctrl2 = new Ven_OppPipeline_CmpCtrl(sc);

        //******************************************************
        Test.stopTest();
    }


    @isTest
    private static void test_insertOppPipeDetail(){

        Test.startTest();
        //******************************************************

        //General Data
        Integer year = System.now().year();
        buildSomLikelihoodCustomSetting();

        //Opportunity
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ventures Default').getRecordTypeId();
        Opportunity opp = cls_P7S1_TestData.createTestOpportunity(false);
        opp.RecordTypeId = recTypeId;
        opp.Ven_EffectiveYield__c = 20;
        insert opp;

        //Check Save
        Ven_OppPipeline_CmpCtrl.saveOppPipeDetail(opp, buildOppPipeList(year));
        system.assertEquals(24, [SELECT Id FROM Ven_OppPipeline__c].size());

        Opportunity oppNew = [SELECT Id, Ven_TotalGmvCurrentYear__c, Ven_TotalGmvNextYear__c FROM Opportunity LIMIT 1][0];
        List<Ven_OppPipeline__c> oppPipesNew = [SELECT Id, Name, Ven_Amount__c, Ven_Year__c, Ven_Month__c, Ven_YieldCash__c FROM Ven_OppPipeline__c];

        system.assertEquals(12, oppNew.Ven_TotalGmvCurrentYear__c, 'total gmv current year has been set correctly');
        system.assertEquals(12, oppNew.Ven_TotalGmvNextYear__c, 'total gmv next year has been set correctly');

        //Check Update
        for(Ven_OppPipeline__c op : oppPipesNew){
            op.Ven_Amount__c    = 2;
            op.Ven_YieldCash__c = 2;
        }

        Ven_OppPipeline_CmpCtrl.saveOppPipeDetail(opp, oppPipesNew);

        oppNew = [SELECT Id, Ven_TotalGmvCurrentYear__c, Ven_TotalGmvNextYear__c FROM Opportunity LIMIT 1][0];

        system.assertEquals(24, oppNew.Ven_TotalGmvCurrentYear__c, 'total gmv current year has been set correctly');
        system.assertEquals(24, oppNew.Ven_TotalGmvNextYear__c, 'total gmv next year has been set correctly');

        //Check Save Opportunities
        oppNew.Probability = 66;
        Ven_OppPipeline_CmpCtrl.saveOpps(new List<Opportunity>{oppNew});

        system.assertEquals(66, [SELECT Probability FROM Opportunity].Probability);

        //Check delete
        Ven_OppPipeline_CmpCtrl.deleteOppPipeDetail(oppNew.Id);
        system.assertEquals(0, [SELECT Id FROM Opportunity].size());

        //******************************************************
        Test.stopTest();
    }

    @isTest
    private static void test_LoadOppData(){

        Test.startTest();
        //******************************************************

        //General Data
        Integer year = System.now().year();
        buildSomLikelihoodCustomSetting();

        //Opportunity
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ventures Default').getRecordTypeId();
        Opportunity opp = cls_P7S1_TestData.createTestOpportunity(false);
        opp.RecordTypeId = recTypeId;
        opp.Ven_EffectiveYield__c = 20;
        insert opp;

        //Teammember
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opp.Id, TeamMemberRole = 'Test', UserId = UserInfo.getUserId());

        //Create Ven_OppPipeline__c
        Ven_OppPipeline_CmpCtrl.saveOppPipeDetail(opp, buildOppPipeList(year));
        system.assertEquals(24, [SELECT Id FROM Ven_OppPipeline__c].size());

        Ven_OppPipeline_CmpCtrl.OppPipeData oppPipeData = Ven_OppPipeline_CmpCtrl.getOppPipeData();
        system.assertEquals(1, oppPipeData.summaryItems.size());

        //Get OppPipeDetail
        Ven_OppPipeline_CmpCtrl.OppPipeDetail oppPipeDetail = Ven_OppPipeline_CmpCtrl.getOppPipeDetail(opp);
        system.assertEquals(12, oppPipeDetail.currentYear.oppPipeMonths.size());

        //Get Export Data
        List<Ven_OppPipeline_CmpCtrl.ExportData> lstExData = Ven_OppPipeline_CmpCtrl.getExportData();
        system.assertEquals(1, lstExData.size());

        //******************************************************
        Test.stopTest();
    }


    /*****************
    *
    *****************/
    private static List<Ven_OppPipeline__c> buildOppPipeList(Integer year){

        List<Ven_OppPipeline__c> lstOppPipeline = new List<Ven_OppPipeline__c>();

        for(Integer i=1; i <= 12; i++){
            lstOppPipeline.add(new Ven_OppPipeline__c(Name = 'Test', Ven_Amount__c = 1, Ven_YieldCash__c = 1, Ven_Year__c = year, Ven_Month__c = i));
            lstOppPipeline.add(new Ven_OppPipeline__c(Name = 'Test', Ven_Amount__c = 1, Ven_YieldCash__c = 1, Ven_Year__c = (year+1), Ven_Month__c = i));
        }

        return lstOppPipeline;
    }

    /*****************
    *
    *****************/
    private static void buildSomLikelihoodCustomSetting(){
        Ven_SomLikelihood__c somLikelihood = new Ven_SomLikelihood__c(  Name = 'test',
                                                                        Ven_Min__c = 0,
                                                                        Ven_Max__c = 200,
                                                                        Ven_Jan__c = 1,
                                                                        Ven_Feb__c = 1,
                                                                        Ven_Mar__c = 1,
                                                                        Ven_Apr__c = 1,
                                                                        Ven_May__c = 1,
                                                                        Ven_Jun__c = 1,
                                                                        Ven_Jul__c = 1,
                                                                        Ven_Aug__c = 1,
                                                                        Ven_Sep__c = 1,
                                                                        Ven_Oct__c = 1,
                                                                        Ven_Nov__c = 1,
                                                                        Ven_Dec__c = 1);

        insert somLikelihood;
    }
}