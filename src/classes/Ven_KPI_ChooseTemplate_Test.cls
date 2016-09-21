@isTest
private class Ven_KPI_ChooseTemplate_Test {

    static testMethod void testVenKPIChooseTemplate() {
        Account testAccount = cls_P7S1_TestData.createTestAccount(false);
        testAccount.Name = 'Test Account';
        testAccount.Ven_Target__c = true;
        testAccount.Ven_Customer__c = false;
        testAccount.Phone = '123456789-1';
        testAccount.Fax = '123456789-0';
        testAccount.Website = 'www.testWebsite.com';
        insert testAccount;

        Opportunity testOpp = cls_P7S1_TestData.createTestOpportunity(false, testAccount);
        testOpp.Name = 'Test Opp';
        testOpp.StageName = 'Finished';
        testOpp.CloseDate = Date.today().addDays(7);
        insert testOpp;

        Ven_KeyPerformanceIndicatorBlock__c testKPIBlock = cls_P7S1_TestData.createTestKPIBlock(true);

        Ven_Key_Performance_Indicator__c testKPI = cls_P7S1_TestData.createTestKPI(true);
        Ven_Key_Performance_Indicator__c testKPI2 = cls_P7S1_TestData.createTestKPI(true);

        Test.startTest();

        Test.setCurrentPage(new PageReference('/apex/Ven_KPI_ChooseTemplate?oppid='+testOpp.Id));

        Ven_KPI_ChooseTemplate venChooseKPITemplateController = new Ven_KPI_ChooseTemplate(new ApexPages.StandardController(new Ven_KeyPerformanceIndicatorTemplate__c()));
        venChooseKPITemplateController.actionNewKPITemplate();
        venChooseKPITemplateController.backToKPITemplatePB();
        venChooseKPITemplateController.actionNewKPITemplate();
        venChooseKPITemplateController.newKPITemplate.Name = 'Test Template 2';
        venChooseKPITemplateController.actionNewKPIBlock();
        venChooseKPITemplateController.getCurrentResultSizeFrom();
        venChooseKPITemplateController.getCurrentResultSizeTo();
        venChooseKPITemplateController.getPageNumberSize();
        venChooseKPITemplateController.newKPIBlock.Name = 'Test Block 2';
        venChooseKPITemplateController.newKPIBlock.Ven_MonthlyView__c = true;
        venChooseKPITemplateController.newKPIBlock.Ven_YearToDateView__c = true;
        venChooseKPITemplateController.newKPIBlock.Ven_FullYearView__c = true;
        venChooseKPITemplateController.newKPIBlock.Ven_Last6MonthsView__c = true;
        venChooseKPITemplateController.inputSelectAllChecked = true;
        venChooseKPITemplateController.toggleCheckboxes();
        venChooseKPITemplateController.pageSize = '1';
        venChooseKPITemplateController.setPageSize();
        venChooseKPITemplateController.next();
        venChooseKPITemplateController.previous();
        venChooseKPITemplateController.last();
        venChooseKPITemplateController.first();
        venChooseKPITemplateController.saveNewKPIBlock();
        venChooseKPITemplateController.actionNewKPIBlock();
        venChooseKPITemplateController.backToNewKPITemplatePB();
        venChooseKPITemplateController.kpiteInputHelper.Ven_KeyPerformanceIndicatorBlock__c = testKPIBlock.Id;
        venChooseKPITemplateController.actionAddToKPITemplate();
        venChooseKPITemplateController.kpiBlockIdToRemove = String.valueOf(testKPIBlock.Id);
        venChooseKPITemplateController.actionRemoveKPIBlock();
        venChooseKPITemplateController.saveNewKPITemplate();
        venChooseKPITemplateController.oppInputHelper.CloseDate = system.today();
        venChooseKPITemplateController.openStrategicReport();

        Test.stopTest();
    }

}