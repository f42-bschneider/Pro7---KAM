@isTest
private class Ven_FinancialModelData_Upload_Test {

    static testMethod void testFinancialModelDataUpload() {

        Ven_Key_Performance_Indicator__c testKPI = cls_P7S1_TestData.createTestKPI(true);

        Opportunity opp  = cls_P7S1_TestData.createTestOpportunity(true);

        Test.startTest();

        PageReference pageRef = Page.Ven_FinancialModelData_Upload;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller ctrl  = new ApexPages.Standardcontroller(opp);
        Ven_FinancialModelData_Upload vFMUC  = new Ven_FinancialModelData_Upload(ctrl);
        vFMUC.fileContent  = Blob.valueOf('BlaBlub');
        vFMUC.upload();
        vFMUC.updateSF();
        vFMUC.backToOpp();

        Test.stopTest();
    }

}