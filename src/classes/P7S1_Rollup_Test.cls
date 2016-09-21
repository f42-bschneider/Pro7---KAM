@isTest
public class P7S1_Rollup_Test{


    public static testMethod void testSomDig_Commitment()
    {
        Account l_oAccWt = cls_P7S1_TestData.createTestAccount(true);
        Account l_oAccAg = cls_P7S1_TestData.createTestAccount(true);
        SomDig_WtAgBeziehung__c l_oWtAg = cls_P7S1_TestData.createTestWTAG(true,l_oAccWt,l_oAccAg);
        SomDig_Commitment__c l_oComm = cls_P7S1_TestData.createSomDigCommitment(true,l_oWtAg );
    }

    public static testMethod void testSomDigRtbDataAggr() {
        createTestRtbDataAggr(true);
    }

    public static testMethod void testAdvRtbAccount() {
        createTestAdvRtbAccount(true);
    }

    @isTest
	public static void testAccountForecast()
    {
		
        Account acc = cls_P7S1_TestData.createTestAccount(true);
        
        SomTv_ForecastTV__c fc1 = new SomTv_ForecastTV__c ();
        fc1.SomTv_ForecastPro7MAXXMN3__c = 5.74;
        fc1.SomTV_Account__c =  acc.id;

        insert new List<SomTv_ForecastTV__c>{fc1};
    }    
    
    public static testmethod void testRollup(){

        // Sum Rollup
        createRollup(true, 'Opportunity', 'SomTv_Agentursplit__c', 'SomTv_Opportunity__c', 'SomTv_MN3__c', 'SomTv_MN3__c', 'SomTv_MN3__c > 0', 'Sum');

        // Count Rollup
        createRollup(true, 'Opportunity', 'SomTv_Agentursplit__c', 'SomTv_Opportunity__c', null, 'TotalOpportunityQuantity', null, 'Count');

        Account objAcc = cls_P7S1_TestData.createTestAccount(true);
        Opportunity objOpp = cls_P7S1_TestData.createTestOpportunity(true, objAcc, null);


        // TESTINSERT: Create Agentursplits and add them together
        List<SomTv_Agentursplit__c> listAS = new List<SomTv_Agentursplit__c>();


        SomTv_Agentursplit__c objAS1 = createTestAgenturSplit(false, objOpp, objAcc, 10);
        objAS1.SomTv_MN3__c = 10;
        listAS.add(objAS1);


        SomTv_Agentursplit__c objAS2 = createTestAgenturSplit(false, objOpp, objAcc, 30);
        objAS2.SomTv_MN3__c = 20;
        listAS.add(objAS2);


        SomTv_Agentursplit__c objAS3 = createTestAgenturSplit(false, objOpp, objAcc, 60);
        objAS3.SomTv_MN3__c = 30;
        listAS.add(objAS3);

        insert listAS;


        // Prepare newMap for insert
        Map<ID, sObject> newMap = new Map<ID, sObject>();
        for(SomTv_Agentursplit__c o : listAS)
            newMap.put(o.ID, o);


        // Test insert
        P7S1_Rollup.startRollup('SomTv_Agentursplit__c', null, listAS,  null, newMap,  true, false, false, false, true);


        // Check sum on Opp
        objOpp = [SELECT SomTv_MN3__c, TotalOpportunityQuantity FROM Opportunity WHERE ID = :objOpp.ID];
        Double dSum = objAS1.SomTv_MN3__c + objAS2.SomTv_MN3__c + objAS3.SomTv_MN3__c;

        System.assert(dSum == objOpp.SomTv_MN3__c);
        System.assert(listAS.size() == objOpp.TotalOpportunityQuantity);



        // TESTUPDATE
        // Prepare listOld
        List<SomTv_Agentursplit__c> listASOld = new List<SomTv_Agentursplit__c>();
        for(SomTv_Agentursplit__c o : listAS)
            listASOld.add(o);



        // Prepare oldmap
        Map<ID, sObject> oldMapUpdate = new Map<ID, sObject>();
        for(SomTv_Agentursplit__c o : listASOld)
            oldMapUpdate.put(o.ID, o);


        // Do an update
        objAS3.SomTv_MN3__c = 20;
        update objAS3;

        SomTv_Agentursplit__c objAS3AfterUpdate = objAS3.clone(true);


        // Prepare listNew
        List<SomTv_Agentursplit__c> listASNew = new List<SomTv_Agentursplit__c>();
        listASNew.add(objAS1);
        listASNew.add(objAS2);
        listASNew.add(objAS3AfterUpdate);


        // Prepare newMap
        Map<ID, sObject> newMapUpdate = new Map<ID, sObject>();
        for(SomTv_Agentursplit__c o : listASNew)
            newMapUpdate.put(o.ID, o);


        P7S1_Rollup.startRollup('SomTv_Agentursplit__c', listASOld, listASNew,  oldMapUpdate, newMapUpdate,  false, true, false, false, true);

        Opportunity objNewOpp = [SELECT SomTv_MN3__c FROM Opportunity WHERE ID = :objOpp.ID];
        dSum = objAS1.SomTv_MN3__c + objAS2.SomTv_MN3__c + objAS3.SomTv_MN3__c;
    }






    public static testmethod void testRollupBatch(){

        Account objAcc = cls_P7S1_TestData.createTestAccount(true);
        Opportunity objOpp = cls_P7S1_TestData.createTestOpportunity(true, objAcc, null);


        // TESTINSERT: Create Agentursplits and add them together
        List<SomTv_Agentursplit__c> listAS = new List<SomTv_Agentursplit__c>();


        SomTv_Agentursplit__c objAS1 = createTestAgenturSplit(false, objOpp, objAcc, 10);
        objAS1.SomTv_MN3__c = 10;
        listAS.add(objAS1);


        SomTv_Agentursplit__c objAS2 = createTestAgenturSplit(false, objOpp, objAcc, 30);
        objAS2.SomTv_MN3__c = 20;
        listAS.add(objAS2);


        SomTv_Agentursplit__c objAS3 = createTestAgenturSplit(false, objOpp, objAcc, 60);
        objAS3.SomTv_MN3__c = 30;
        listAS.add(objAS3);

        insert listAS;


        // Count Rollup
        P7S1_Rollup__c objRollup = createRollup(true, 'Opportunity', 'SomTv_Agentursplit__c', 'SomTv_Opportunity__c', null, 'TotalOpportunityQuantity', null, 'Count');



        // Create Class and StandardController
        PageReference pageRef = Page.P7S1_RollupBatch;
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('id', objRollup.Id);


        Test.startTest();

        P7S1_Rollup con = new P7S1_Rollup();
        con.recalculate();


        Test.stopTest();
    }


    public static P7S1_Rollup__c createRollup(Boolean insertObject, String sParentObject, String sChildObject, String sRelationfield, String sChildCalculationField, String sParentResultField, String sWhereCondition, String sType) {
        P7S1_Rollup__c rollup   = new P7S1_Rollup__c();
        rollup.Active__c        = true;
        rollup.ChildCalculationField__c  = sChildCalculationField;
        rollup.ChildObject__c            = sChildObject;
        rollup.ParentObject__c           = sParentObject;
        rollup.ParentResultField__c      = sParentResultField;
        rollup.RelationshipField__c      = sRelationfield;
        rollup.Type__c                   = sType;
        rollup.WhereCondition__c         = sWhereCondition;

        if (insertObject) insert rollup;
        return rollup;
    }


    // TODO : Auslagern
    public static SomTv_Agentursplit__c createTestAgenturSplit(Boolean insertObject, Opportunity opportunity,Account account, Integer anteil) {
        SomTv_Agentursplit__c AgenturSplit_TestData = new SomTv_Agentursplit__c();
        AgenturSplit_TestData.SomTv_Prozent_Anteil__c = anteil;
        AgenturSplit_TestData.SomTv_Opportunity__c = opportunity.ID;
        AgenturSplit_TestData.SomTv_Agentur__c = account.ID;

        if (insertObject) insert AgenturSplit_TestData;
        return AgenturSplit_TestData;
    }

    public static SomDig_RtbDataAggr__c createTestRtbDataAggr(Boolean insertObject) {
        SomDig_RtbDataAggr__c RtbDataAggr_TestData = new SomDig_RtbDataAggr__c();
        RtbDataAggr_TestData.SomDig_NetRevenue__c = 123;
        if (insertObject) insert RtbDataAggr_TestData;
        return RtbDataAggr_TestData;
    }

    public static ADvendio__RTBAccount__c createTestAdvRtbAccount(Boolean insertObject) {
        ADvendio__RTBAccount__c RtbAccount_TestData = new ADvendio__RTBAccount__c();
        RtbAccount_TestData.Name = 'abc-test';
        RtbAccount_TestData.ADvendio__AdServerLogin__c = cls_P7S1_TestData.createTestAdServerLogin(true).Id;
        if (insertObject) insert RtbAccount_TestData;
        return RtbAccount_TestData;
    }

}