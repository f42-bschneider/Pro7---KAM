@isTest
private class Ven_KPI_StrategicReport_Test {

    static testMethod void testVenKPIStrategicReport() {
        Account testAccount = cls_P7S1_TestData.createTestAccount(false);
        testAccount.Ven_Target__c = true;
        testAccount.Ven_Customer__c = false;
        insert testAccount;

        Opportunity testOpp = cls_P7S1_TestData.createTestOpportunity(true, testAccount);
        Ven_Key_Performance_Indicator__c testKpi = cls_P7S1_TestData.createTestKPI(true);
        Ven_KeyPerformanceIndicatorBlock__c testKpiBlock = cls_P7S1_TestData.createTestKPIBlock(false);
        testKpiBlock.Ven_YearToDateView__c = true;
        testKpiBlock.Ven_MonthlyView__c = true;
        testKpiBlock.Ven_FullYearView__c = true;
        testKpiBlock.Ven_Last6MonthsView__c = true;
        insert testKpiBlock;
        Ven_KeyPerformanceIndicatorBlockEntry__c testKpiBlockEntry = cls_P7S1_TestData.createTestKPIBlockEntry(true, testKpi, testKpiBlock);
        Ven_KeyPerformanceIndicatorTemplate__c testKpiTemplate = cls_P7S1_TestData.createTestKPITemplate(true);
        Ven_KeyPerformanceIndicatorTemplateEntry__c testKpiTemplateEntry = cls_P7S1_TestData.createTestKPITemplateEntry(true, testKpiTemplate, testKpiBlock);

        Id venActualDataId;
        Id venBudgetDataId;
        Id venPlanDataId;

        for (RecordType recordType : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Ven_Financial_Model_Version__c']) {
            if (recordType.DeveloperName == 'Ven_Actual_Data') {
                venActualDataId = recordType.Id;
            } else if (recordType.DeveloperName == 'Ven_Budget_Data') {
                venBudgetDataId = recordType.Id;
            } else if (recordType.DeveloperName == 'Ven_Plan_Data') {
                venPlanDataId = recordType.Id;
            }
        }

        if (venActualDataId != null) {
            Ven_Financial_Model_Version__c testFinancialModelVersionActualData = cls_P7S1_TestData.createTestFinancialModelVersion(true, venActualDataId, testOpp);

            Ven_Financial_Model_Data__c testFinancialModelDataActualData = cls_P7S1_TestData.createTestFinancialModelData(false, testKpi);
            testFinancialModelDataActualData.Financial_Model_Version__c = testFinancialModelVersionActualData.Id;
            testFinancialModelDataActualData.Ven_Value__c = 10;
            insert testFinancialModelDataActualData;
        }

        if (venBudgetDataId != null) {
            Ven_Financial_Model_Version__c testFinancialModelVersionBudgetData = cls_P7S1_TestData.createTestFinancialModelVersion(true, venBudgetDataId, testOpp);

            Ven_Financial_Model_Data__c testFinancialModelDataBudgetData = cls_P7S1_TestData.createTestFinancialModelData(false, testKpi);
            testFinancialModelDataBudgetData.Financial_Model_Version__c = testFinancialModelVersionBudgetData.Id;
            testFinancialModelDataBudgetData.Ven_Value__c = 20;
            insert testFinancialModelDataBudgetData;
        }

        if (venPlanDataId != null) {
            Ven_Financial_Model_Version__c testFinancialModelVersionPlanData = cls_P7S1_TestData.createTestFinancialModelVersion(true, venPlanDataId, testOpp);

            Ven_Financial_Model_Data__c testFinancialModelDataPlanData = cls_P7S1_TestData.createTestFinancialModelData(false, testKpi);
            testFinancialModelDataPlanData.Financial_Model_Version__c = testFinancialModelVersionPlanData.Id;
            testFinancialModelDataPlanData.Ven_Value__c = 30;
            insert testFinancialModelDataPlanData;
        }

        Task testTask = cls_P7S1_TestData.createTestTask(false);
        testTask.WhatId = testOpp.Id;
        insert testTask;

        Test.startTest();

        Test.setCurrentPage(new PageReference('/apex/Ven_KPI_StrategicReport?oppid=' + testOpp.Id + '&kpiTemplateId=' + testKpiTemplate.Id + '&date=' + system.today().format() + '&renderAs=pdf'));

        Ven_KPI_StrategicReport venStrategicReportController = new Ven_KPI_StrategicReport(new ApexPages.StandardController(new Opportunity()));

        Test.stopTest();
    }

}