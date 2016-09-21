/**
 * This class contains unit tests for validating the behavior of Apex classe SomTv_OLI_Clone
 */
@isTest(SeeAllData=true)
private class SomTv_OLI_Clone_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        Date closeDate = Date.today();

        Opportunity opp= new Opportunity(Amount=1234.00,Description='testdesc',Name='testOpp', StageName='Prospecting',CloseDate = System.Today(), CurrencyIsoCode='EUR');
         insert opp;

         PricebookEntry priceBookEntryNew = new PricebookEntry();
        Product2 product = new Product2();
        PriceBook2 pb2 = new PriceBook2 (Name='Standard priceBook', Description = 'test');
        insert pb2;

        List<PriceBook2> pricebookList = [Select id from PriceBook2 where  IsStandard = TRUE ];
        PriceBook2 pricebooktest = new PriceBook2 ();
        if(pricebookList != null && pricebookList.size()>0)
            pricebooktest = pricebookList.get(0);

        product.name = 'Test';
        product.IsActive = true;
        insert product;

        priceBookEntryNew.Product2Id = product.Id;
        priceBookEntryNew.PriceBook2Id = pricebooktest.Id;
        priceBookEntryNew.UnitPrice = 20.00;
        priceBookEntryNew.UseStandardPrice = false;
        priceBookEntryNew.isactive = true;
        insert priceBookEntryNew;

        OpportunityLineItem oli = new OpportunityLineItem
            (
                OpportunityId = opp.Id,
                PricebookEntryId = priceBookEntryNew.Id,
                Quantity = 1,
                UnitPrice = priceBookEntryNew.UnitPrice,
                SomTv_DispoPreisprozent__c=20,
                SomTv_MN3_1FS__c=1,
                ServiceDate = System.today()
            );
        insert oli;

        PageReference pgRef = Page.SomTv_OLI_Clone;
        pgRef.getParameters().put('retURL', '%2F'+opp.Id);
        pgRef.getParameters().put('opptIds', oli.Id);
        pgRef.getParameters().put('p', 's');
       Test.setCurrentPageReference (pgRef);
       SomTv_OLI_Clone cOppt = new SomTv_OLI_Clone();

       cOppt.back();
       cOppt.startClone();

        pgRef.getParameters().put('p', 'l');
       Test.setCurrentPageReference (pgRef);
       cOppt = new SomTv_OLI_Clone();

       cOppt.startClone();
       cOppt.displayErrMsg('Test Error Msg');

       List<OpportunityLineItem> listOppLineItem = [select Id, Quantity, UnitPrice, ServiceDate, OpportunityId, PricebookEntryId from OpportunityLineItem where OpportunityId =:opp.Id and PricebookEntryId =:priceBookEntryNew.Id];

       system.assertEquals(listOppLineItem.size(), 3);

       for( OpportunityLineItem oppt :listOppLineItem ){
         system.assertEquals(oppt.Quantity, 1);
         system.assertEquals(oppt.PricebookEntryId, priceBookEntryNew.Id);
         system.assertEquals(oppt.UnitPrice, priceBookEntryNew.UnitPrice);
         system.assertEquals(oppt.ServiceDate, System.today());
       }

        Test.stopTest();
    }
}