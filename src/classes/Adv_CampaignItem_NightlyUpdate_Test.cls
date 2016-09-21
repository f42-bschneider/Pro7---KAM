@isTest
private class Adv_CampaignItem_NightlyUpdate_Test {

    public static Account l_oAccount;
    public static SomDig_WtAgBeziehung__c l_oWtAgBeziehung;
    public static ADvendio__MediaCampaign__c l_oMediaCampaign;
    public static ADvendio__Ad_Specs__c l_oAdSpecs;
    public static ADvendio__Ad_price__c l_oAdPrice;

    private static void createData() {
        l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        l_oMediaCampaign.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Auftrag'].Id;
        //l_oMediaCampaign.SomDig_StatusPAMCockpit__c = 'neu';
        insert l_oMediaCampaign;

        l_oAdPrice = cls_P7S1_TestData.createTestAdPrice(true, null, null);
    }

    static void testCampaignItemStatus(String StatusPAM){
        Test.startTest();

        List <ADvendio__Campaign_Item__c> CampaignItemList = new List <ADvendio__Campaign_Item__c>();
        ADvendio__Campaign_Item__c l_oCampaignItem1 = new ADvendio__Campaign_Item__c();
        l_oCampaignItem1.ADvendio__Media_Campaign__c = l_oMediaCampaign.Id;
        l_oCampaignItem1.ADvendio__Quantity__c = 10000;
        l_oCampaignItem1.ADvendio__from_Date__c = system.today();
        l_oCampaignItem1.ADvendio__until_Date__c = system.today()+2;
        l_oCampaignItem1.ADvendio__Sales_Price__c = 30;
        l_oCampaignItem1.ADvendio__Billing_category__c = 'CPM';
        l_oCampaignItem1.ADvendio__Ad_Price__c = l_oAdPrice.Id;
        l_oCampaignItem1.SomDig_PositionStatus__c = 'Entwurf';
        CampaignItemList.add(l_oCampaignItem1);

        ADvendio__Campaign_Item__c l_oCampaignItem2 = new ADvendio__Campaign_Item__c();
        l_oCampaignItem2.ADvendio__Media_Campaign__c = l_oMediaCampaign.Id;
        l_oCampaignItem2.ADvendio__Quantity__c = 10000;
        l_oCampaignItem2.ADvendio__from_Date__c = system.today();
        l_oCampaignItem2.ADvendio__until_Date__c = system.today()+2;
        l_oCampaignItem2.ADvendio__Sales_Price__c = 30;
        l_oCampaignItem2.ADvendio__Billing_category__c = 'CPM';
        l_oCampaignItem2.ADvendio__Ad_Price__c = l_oAdPrice.Id;
        l_oCampaignItem2.SomDig_PositionStatus__c = 'Entwurf';
        CampaignItemList.add(l_oCampaignItem2);
        insert CampaignItemList;

        l_oMediaCampaign.SomDig_StatusPAMCockpit__c = StatusPAM;
        update l_oMediaCampaign;

        Id campItemId = CampaignItemList[0].Id;
        String l_sQuery = 'SELECT Id, SomDig_PositionStatus__c, ADvendio__Media_Campaign__c, ADvendio__until_Date__c, ADvendio__from_Date__c ' +
                            'FROM ADvendio__Campaign_Item__c ' +
                           'WHERE Id = ' + '\'' + campItemId + '\'';
        System.debug('l_sQuery '+l_sQuery +' -- l_oCampaignItem1.Id ' + '\'' + campItemId + '\'' );
        Adv_CampaignItem_NightlyUpdate l_oBatchInst= new Adv_CampaignItem_NightlyUpdate(l_sQuery);
        Id l_ibatchInstanceId = Database.executeBatch(l_oBatchInst);

        Test.stopTest();
    }

    static testMethod void schedule_batch() {
        Test.startTest();

        string l_sCronExp = '0 0 0 15 3 ? 2022';
        // Schedule the test job
        string jobid = system.schedule('test batch job', l_sCronExp, new Adv_CampaignItem_NightlyUpdate() );

        Test.stopTest();
    }

    static testMethod void testCampaignItemStatusExec() {
        createData();
        testCampaignItemStatus('to do');
    }

    static testMethod void testCampaignItemStatusExec1() {
        createData();
        testCampaignItemStatus('NonAdServer');
    }

    static testMethod void testCampaignItemStatusExec2() {
        createData();
        testCampaignItemStatus('Auslieferung-normal');
    }

    static testMethod void testCampaignItemStatusExec3() {
        createData();
        testCampaignItemStatus('bereit');
    }

    static testMethod void testCampaignItemStatusExec4() {
        createData();
        testCampaignItemStatus('abgelaufen-erfüllt');
    }

    static testMethod void testCampaignItemStatusExec5() {
        createData();
        testCampaignItemStatus('pausiert');
    }
}