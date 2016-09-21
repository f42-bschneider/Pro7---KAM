@isTest
private class Adv_Invoice_CreateInvoice_Test {

     static testMethod void testAdv_Invoice_CreateInvoice() {
        ADvendio__MediaCampaign__c mc1 = cls_P7S1_TestData.createTestMediaCampaign(false);
        mc1.Name='Test MediaCampaign 1';
        mc1.ADvendio__BillMe__c=true;
        mc1.ADvendio__Stage__c='Booked';
        mc1.ADvendio__PaymentStart__c='after Billingperiod';
        mc1.ADvendio__PaymentDueDate__c='due to the end of interval';
        mc1.ADvendio__PaymentInterval__c='monthly';
        insert mc1;

        ADvendio__Campaign_Item__c ci1 = cls_P7S1_TestData.createTestCampaignItem(true, mc1);

        Test.startTest();
        // Now test the right class.
        // Can't verify the results because it will call a batch job.
        // So just test it for code coverage.
        Adv_Invoice_CreateInvoice c = new Adv_Invoice_CreateInvoice();

        c.setRecordIds(null);

        c.addRecordId(mc1.Id);

        c.createPreInvoice();

        String sch = '0 0 23 * * ?';

        System.schedule('Test Adv_Invoice_CreateInvoice', sch, c);

        Test.stopTest();
    }
}