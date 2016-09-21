@isTest
private with sharing class Adv_InvoiceItem_DeliveryDataImport_Test {

    static testMethod void testDeliveryDataImport() {
        // A Zahlungsbedingung__c
        SomDig_Zahlungsbedingung__c zb1 = cls_P7S1_TestData.createTestZahlungsbedingung(true);

        // An Account
        Account acc1 = cls_P7S1_TestData.createTestAccount(true);

        // A Pricelist
        ADvendio__Pricelist__c pl1 = cls_P7S1_TestData.createTestPricelist(true, null);

        // An AdServerLogin
        RecordType rt = [Select Id From RecordType where SobjectType = 'ADvendio__AdServer_Logins__c' and DeveloperName = 'DFP'];
        ADvendio__AdServer_Logins__c login1 = cls_P7S1_TestData.createTestAdServerLogin(true, rt);

        // An AdType
        rt = [Select Id From RecordType where SobjectType = 'ADvendio__Ad_Type__c' and DeveloperName = 'DFP'];
        ADvendio__Ad_Type__c adtype1 = cls_P7S1_TestData.createTestAdType(false);
        adtype1.ADvendio__AdServer_Login__c=login1.Id;
        adtype1.RecordTypeId=rt.Id;
        insert adtype1;

        // An AdSpec
        ADvendio__Ad_Specs__c spec1 = cls_P7S1_TestData.createTestAdSpec(true, adtype1);

        // An AdPrice
        ADvendio__Ad_price__c price1 = cls_P7S1_TestData.createTestAdPrice(false, spec1, pl1);
        price1.ADvendio__Billing_Category__c='CPM';
        insert price1;

        // A MediaCampaign
        ADvendio__MediaCampaign__c mc1 = cls_P7S1_TestData.createTestMediaCampaign(false, acc1, pl1);
        mc1.ADvendio__Stage__c='Booked';
        mc1.ADvendio__BillMe__c=true;
        insert mc1;

        // A CampaignItem
        ADvendio__Campaign_Item__c ci1 = cls_P7S1_TestData.createTestCampaignItem(false, mc1, price1);
        ci1.ADvendio__Billing_category__c='CPM';
        ci1.ADvendio__LinearDistribution__c=false;
        ci1.ADvendio__from_Date__c=System.today();
        ci1.ADvendio__until_Date__c=System.today();
        insert ci1;

        // Should have only one RS, because start and end-date of CampaignItem is same.
        List<ADvendio__Revenue_Schedule__c> rss = [SELECT Id, ADvendio__InvoiceQuantity__c FROM ADvendio__Revenue_Schedule__c WHERE ADvendio__Campaign_Item__c = :ci1.Id];
        System.assertEquals(1, rss.size());

        for (ADvendio__Revenue_Schedule__c rs : rss) {
            rs.ADvendio__Delivered_AIs__c = 100;
        }
        update rss;

        // Create the pre invoice
        ADvendio__Invoice__c invoice1 = cls_P7S1_TestData.createTestInvoice(false, mc1);
        invoice1.ADvendio__Status__c='Draft';
        insert invoice1;

        ADvendio__InvoiceItem__c invoiceItem1 = cls_P7S1_TestData.createTestInvoiceItem(false, invoice1, ci1);
        invoiceItem1.ADvendio__Salesprice__c = ci1.ADvendio__Sales_Price__c;
        invoiceItem1.ADvendio__BookedQuantity__c = 1;
        invoiceItem1.ADvendio__FromDate__c = ci1.ADvendio__from_Date__c;
        invoiceItem1.ADvendio__UntilDate__c = ci1.ADvendio__until_Date__c;
        insert invoiceItem1;

        Test.startTest();

        //
        // Now test the class.
        //
        Adv_InvoiceItem_DeliveryDataImport ddi = new Adv_InvoiceItem_DeliveryDataImport();
        ddi.setRecordIds(null);
        ddi.addRecordId(invoiceItem1.Id);

        List<ADvendio__InvoiceItem__c> invoiceItems = [SELECT Id, ADvendio__CampaignItem__c, ADvendio__InvoiceItemStartDate__c, ADvendio__InvoiceItemEndDate__c, ADvendio__QuantityDelivered__c FROM ADvendio__InvoiceItem__c WHERE ADvendio__CampaignItem__c = :ci1.Id];
        ddi.execute(null, invoiceItems);

        // Verify
        invoiceItems = [SELECT Id, ADvendio__QuantityDelivered__c FROM ADvendio__InvoiceItem__c WHERE ADvendio__CampaignItem__c = :ci1.Id];

        // Should have only one invoiceItem, and ADvendio__QuantityDelivered__c is set correctly.
        System.assertEquals(1, invoiceItems.size());
        System.assertEquals(100, invoiceItems[0].ADvendio__QuantityDelivered__c);

        Test.stopTest();
    }

    static testMethod void testDeliveryDataImportBatchSchedule() {
        Test.startTest();

        Adv_InvoiceItem_DeliveryDataImport ddi = new Adv_InvoiceItem_DeliveryDataImport();
        ddi.addRecordId(null);

        Database.executeBatch(ddi, 1);

        String sch = '0 0 23 * * ?';

        System.schedule('Test DeliveryDataImport', sch, ddi);

        Test.stopTest();
    }

}