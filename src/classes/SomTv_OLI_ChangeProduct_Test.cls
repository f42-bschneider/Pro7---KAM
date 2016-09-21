@isTest
private class SomTv_OLI_ChangeProduct_Test {

    static testMethod void missing_Id_should_display_error() {
        Test.startTest();

        PageReference changeProduct_page = Page.SomTv_OLI_ChangeProduct;
        Test.setCurrentPage(changeProduct_page);

        SomTv_OLI_ChangeProduct controller = new SomTv_OLI_ChangeProduct();
        PageReference save = controller.changeProduct();

        System.assertEquals(save.getUrl(), changeProduct_page.getUrl());

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.ERROR, messages[0].getSeverity());
        System.assertEquals('Bitte Id eines Opportunity Produkts übergeben.', messages[0].getSummary());

        Test.stopTest();
    }

    static testMethod void inactive_product_should_display_error() {
        Product2 product_1 = cls_P7S1_TestData.createTestProduct2(true);
        Product2 product_2 = cls_P7S1_TestData.createTestProduct2(false);
        product_2.isActive = false;
        insert product_2;

        PricebookEntry pricebook_entry_1 = cls_P7S1_TestData.createTestPricebookEntry(true, product_1);
        PricebookEntry pricebook_entry_2 = cls_P7S1_TestData.createTestPricebookEntry(true, product_2);

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, pricebook_entry_1);

        Test.startTest();

        PageReference changeProduct_page = Page.SomTv_OLI_ChangeProduct;
        Test.setCurrentPage(changeProduct_page);
        ApexPages.currentPage().getParameters().put('id', oli.Id);

        SomTv_OLI_ChangeProduct controller = new SomTv_OLI_ChangeProduct();
        controller.oli.SomTv_AdFProductHelper__c = product_2.Id;
        PageReference save = controller.changeProduct();

        System.assertEquals(null, save);

        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem WHERE Product2Id = :product_1.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.ERROR, messages[0].getSeverity());
        System.assertEquals('Produkt ist nicht aktiv.', messages[0].getSummary());

        Test.stopTest();
    }

    static testMethod void inactive_pricebook_entry_should_display_error() {
        Product2 product_1 = cls_P7S1_TestData.createTestProduct2(true);
        Product2 product_2 = cls_P7S1_TestData.createTestProduct2(true);

        PricebookEntry pricebook_entry_1 = cls_P7S1_TestData.createTestPricebookEntry(true, product_1);
        PricebookEntry pricebook_entry_2 = cls_P7S1_TestData.createTestPricebookEntry(false, product_2);
        pricebook_entry_2.isActive = false;
        insert pricebook_entry_2;

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, pricebook_entry_1);

        Test.startTest();

        PageReference changeProduct_page = Page.SomTv_OLI_ChangeProduct;
        Test.setCurrentPage(changeProduct_page);
        ApexPages.currentPage().getParameters().put('id', oli.Id);

        SomTv_OLI_ChangeProduct controller = new SomTv_OLI_ChangeProduct();
        controller.oli.SomTv_AdFProductHelper__c = product_2.Id;
        PageReference save = controller.changeProduct();

        System.assertEquals(null, save);

        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem WHERE Product2Id = :product_1.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.ERROR, messages[0].getSeverity());
        System.assertEquals('Preisbucheintrag ist nicht aktiv.', messages[0].getSummary());

        Test.stopTest();
    }

    static testMethod void missing_product_should_display_error() {
        Product2 product = cls_P7S1_TestData.createTestProduct2(true);
        PricebookEntry pricebook_entry = cls_P7S1_TestData.createTestPricebookEntry(true, product);
        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, pricebook_entry);

        Test.startTest();

        PageReference changeProduct_page = Page.SomTv_OLI_ChangeProduct;
        Test.setCurrentPage(changeProduct_page);
        ApexPages.currentPage().getParameters().put('id', oli.Id);

        SomTv_OLI_ChangeProduct controller = new SomTv_OLI_ChangeProduct();
        PageReference save = controller.changeProduct();

        System.assertEquals(null, save);

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.ERROR, messages[0].getSeverity());
        System.assertEquals('Bitte Produkt auswählen.', messages[0].getSummary());

        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem WHERE Product2Id = :product.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);

        Test.stopTest();
    }

    static testMethod void choosing_old_product_should_display_error() {
        Product2 product = cls_P7S1_TestData.createTestProduct2(true);
        PricebookEntry pricebook_entry = cls_P7S1_TestData.createTestPricebookEntry(true, product);
        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, pricebook_entry);

        Test.startTest();

        PageReference changeProduct_page = Page.SomTv_OLI_ChangeProduct;
        Test.setCurrentPage(changeProduct_page);
        ApexPages.currentPage().getParameters().put('id', oli.Id);

        SomTv_OLI_ChangeProduct controller = new SomTv_OLI_ChangeProduct();
        controller.oli.SomTv_AdFProductHelper__c = product.Id;
        PageReference save = controller.changeProduct();

        System.assertEquals(null, save);

        ApexPages.Message[] messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size());
        System.assertEquals(ApexPages.Severity.ERROR, messages[0].getSeverity());
        System.assertEquals('Produkt hat sich nicht geändert.', messages[0].getSummary());

        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem WHERE Product2Id = :product.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);

        Test.stopTest();
    }

    static testMethod void changeProduct_should_create_and_delete_OLIs() {
        Product2 product_1 = cls_P7S1_TestData.createTestProduct2(true);
        Product2 product_2 = cls_P7S1_TestData.createTestProduct2(true);

        PricebookEntry pricebook_entry_1 = cls_P7S1_TestData.createTestPricebookEntry(true, product_1);
        PricebookEntry pricebook_entry_2 = cls_P7S1_TestData.createTestPricebookEntry(true, product_2);

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, pricebook_entry_1);

        Test.startTest();

        PageReference changeProduct_page = Page.SomTv_OLI_ChangeProduct;
        Test.setCurrentPage(changeProduct_page);
        ApexPages.currentPage().getParameters().put('id', oli.Id);

        SomTv_OLI_ChangeProduct controller = new SomTv_OLI_ChangeProduct();
        controller.oli.SomTv_AdFProductHelper__c = product_2.Id;
        PageReference save = controller.changeProduct();

        OpportunityLineItem new_oli = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE Product2Id = :product_2.Id];
        PageReference redirect_url = new ApexPages.StandardController(new_oli).edit();
        redirect_url.getParameters().put('retURL', new_oli.Id);

        System.assertEquals(save.getUrl(), redirect_url.getUrl());

        System.assertEquals(0, [SELECT COUNT() FROM OpportunityLineItem WHERE Product2Id = :product_1.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem WHERE Product2Id = :product_2.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);

        Test.stopTest();
    }

    static testMethod void cancel_should_redirect_back() {
        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true);

        Test.startTest();

        PageReference changeProduct_page = Page.SomTv_OLI_ChangeProduct;
        Test.setCurrentPage(changeProduct_page);
        ApexPages.currentPage().getParameters().put('Id', oli.Id);

        SomTv_OLI_ChangeProduct controller = new SomTv_OLI_ChangeProduct();
        PageReference cancel = controller.cancel();

        System.assertEquals(cancel.getUrl(), new ApexPages.StandardController(oli).view().getUrl());

        Test.stopTest();
    }

}