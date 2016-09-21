@isTest
private class P7S1_AccountDashboardsCmpCtrl_Test {

    private static Account acc;
    private static Integer cntRecords = 10;


    /*************************
    * Test dashboard header
    ************/
    static testMethod void testAccAccess() {

        //Create data
        createTestData(0);

        Test.startTest();
        //*****************************************

        P7S1_AccountDashboardCmpCtrl.AccessData ad = P7S1_AccountDashboardCmpCtrl.getAccessData(acc.Id, null);
        system.assertEquals(true, ad.hasAccAccess);
        system.assertEquals('', ad.imgId);

        //*****************************************
        Test.stopTest();

    }

    /*************************
    * Test overview component
    ************/
    static testMethod void testOverviewCmp() {

        //Create data
        createTestData(1);

        Test.startTest();
        //*****************************************

        list<P7S1_AccountDashboardCmpCtrl.OvData> lstOV = P7S1_AccountDashboardCmpCtrl.getOverviewData(acc.Id);
        system.assertEquals(3, lstOV.size());

        //*****************************************
        Test.stopTest();

    }

    /*************************
    * Test opportunity view component
    ************/
    static testMethod void testOpportunityViewCmp() {
        //Create data
        createTestData(2);

        Test.startTest();
        //*****************************************

        P7S1_AccountDashboardCmpCtrl.OppData oppData = P7S1_AccountDashboardCmpCtrl.getOpportunityData(acc.Id, false);
        system.assertEquals(1, oppData.tableData.size());
        system.assertEquals((cntRecords/2) * 10000, oppData.sumClosed);
        system.assertEquals((cntRecords/2) * 10000, oppData.sumOpen);


        //*****************************************
        Test.stopTest();
    }

    /*************************
    * Test media view component
    ************/
    static testMethod void testMediaViewCmp() {
        //Create data
        createTestData(3);

        Test.startTest();
        //*****************************************

        P7S1_AccountDashboardCmpCtrl.NielsenData nielsen = P7S1_AccountDashboardCmpCtrl.getMediaData(acc.Id);
        system.assertEquals(16, nielsen.mediaData.size());

        for(P7S1_AccountDashboardCmpCtrl.MediaData md : nielsen.mediaData){
            system.assertEquals(25, md.percent);
        }

        //*****************************************
        Test.stopTest();
    }

    /*************************
    * Test data
    ************/
    private static void createTestData(Integer i){

        //Account
        acc = cls_P7S1_TestData.createTestAccount(false);
        acc.P7S1_TopAccount__c = true;
        acc.Som_AT_LetzterTelefonTermin__c = DateTime.now();
        acc.SomTv_Accounttypen__c = 'Test';
        insert acc;

        //Overview
        if(i==1){

            //Fill custom setting
            createTestAccountDashboardFields(true, 'Owner', 'OwnerEn', true, false, 'Owner.Name', 'Owner.Id', 1);
            createTestAccountDashboardFields(true, 'Kundenstatus', 'Customer status', false, true, 'SomTv_Accounttypen__c', null, 3);
            //Last Contacted (special)
            P7S1_AccountDashboardFields__c adf = createTestAccountDashboardFields(false, 'Zuletzt kontaktiert', 'Customer status', false, false, null, null, 4);
            adf.Name = 'LastContacted';
            insert adf;
        }

        //Opportunities
        if(i==2){

            list<Opportunity> lstOpp = new list<Opportunity>();
            Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Gam_Standard').getRecordTypeId();
            for(Integer j=0; j<cntRecords; j++){
                Opportunity opp = cls_P7S1_TestData.createTestOpportunity(false, acc);
                opp.RecordTypeId = recordTypeId;
                if(Math.mod(j, 2) == 0) opp.StageName = 'Closed Won';
                else opp.StageName = 'Contacted';
                opp.Amount = 10000;
                lstOpp.add(opp);
            }
            insert lstOpp;

        }

        //Nielsen
        if(i==3){

            Integer year = Date.today().year();

            //NielsenData
            list<P7S1_NielsenDataAggr__c> lstNielsenDaten = new list<P7S1_NielsenDataAggr__c>();
            lstNielsenDaten.add(createTestNielsenDaten(false, acc.Id, String.valueOf(year), 'YTM'));
            lstNielsenDaten.add(createTestNielsenDaten(false, acc.Id, String.valueOf(year-1), 'YTM'));
            lstNielsenDaten.add(createTestNielsenDaten(false, acc.Id, String.valueOf(year-1), 'GJ'));
            insert lstNielsenDaten;

        }
    }

    /*************************
    * Create NielsenDataDetail
    ************/
    public static P7S1_NielsenDataAggr__c createTestNielsenDaten(Boolean inserObject, String accId, String year, String period){
        P7S1_NielsenDataAggr__c nda = new P7S1_NielsenDataAggr__c();
        nda.P7S1_Account__c = accId;
        nda.P7S1_Year__c = year;
        nda.P7S1_ZeitraumTyp__c = period;
        nda.P7S1_MklGruppeTv__c = 10000;
        nda.P7S1_MklGruppeDigital__c = 10000;
        nda.P7S1_MklGruppePrint__c = 10000;
        nda.P7S1_MklGruppeRest__c = 10000;
        nda.P7S1_MklSoaTV__c = 10000;   // 2015-12-16
        nda.P7S1_MklSoaDigital__c = 10000;
        nda.P7S1_MklSoaPrint__c = 10000;
        nda.P7S1_MklSoaRest__c = 10000;
        nda.P7S1_Last_Entry_Date__c = Date.today();

        if(inserObject){
            insert nda;
        }
        return nda;
    }

    /*************************
    * Create NielsenDataDetail
    ************/
    public static P7S1_AccountDashboardFields__c createTestAccountDashboardFields(Boolean insertObject, String label, String labelEn, Boolean isLink, Boolean needsAuth, String field, String linkField, Integer cnt){
        P7S1_AccountDashboardFields__c adf = new P7S1_AccountDashboardFields__c();
        adf.Name = 'Test ADF ' + cnt;
        adf.P7S1_Custom_Label__c = label;
        adf.P7S1_Custom_Label_EN__c = labelEn;
        adf.P7S1_Is_Link__c = isLink;
        adf.P7S1_Needs_Authorization__c = needsAuth;
        adf.P7S1_API_Field_on_Account__c = field;
        adf.P7S1_Parent_ID_Field__c = linkField;
        adf.P7S1_Order__c = cnt;
        adf.P7S1_Group__c = 1;

        if(insertObject){
            insert adf;
        }
        return adf;
    }
}