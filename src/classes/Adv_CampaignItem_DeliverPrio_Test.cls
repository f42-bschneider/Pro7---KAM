@isTest
private with sharing class Adv_CampaignItem_DeliverPrio_Test {

    static testMethod void testDeliverPriority() {
        SomDig_MediagattungsDifferenzierung__c md = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true);

        SomDig_Auftragstyp__c auftragstyp = cls_P7S1_TestData.createTestAuftragstyp(true);

        SomDig_DeliverPrio__c p1 = cls_P7S1_TestData.createTestAuslieferungsprioritaet(false, md, auftragstyp);
        p1.SomDig_Gueltig_ab__c = Date.today();
        p1.SomDig_Gueltig_bis__c = Date.today().addDays(1);
        p1.SomDig_Werbeform_Kurzform__c = 'PR1/MR';
        p1.SomDig_Rotationstyp__c = 'Umfeld';
        p1.SomDig_Prio__c ='3';
        insert p1;

        SomDig_DeliverPrio__c p2 = cls_P7S1_TestData.createTestAuslieferungsprioritaet(false, md, auftragstyp);
        p2.SomDig_Gueltig_ab__c = Date.today().addDays(1);
        p2.SomDig_Gueltig_bis__c = Date.today().addDays(2);
        p2.SomDig_Werbeform_Kurzform__c = '';
        p2.SomDig_Rotationstyp__c = 'Umfeld';
        p2.SomDig_Prio__c ='4';
        insert p2;

        SomDig_DeliverPrio__c p3 = cls_P7S1_TestData.createTestAuslieferungsprioritaet(false, md, auftragstyp);
        p3.SomDig_Gueltig_ab__c = Date.today().addDays(2);
        p3.SomDig_Gueltig_bis__c = Date.today().addDays(3);
        p3.SomDig_Werbeform_Kurzform__c = '';
        p3.SomDig_Rotationstyp__c = '';
        p3.SomDig_Prio__c ='5';
        insert p3;

        ADvendio__Pricelist__c rateCard1 = cls_P7S1_TestData.createTestPricelist(true, auftragstyp);

        ADvendio__Site__c site1 = cls_P7S1_TestData.createTestSite(true);

        ADvendio__Placement__c placement1 = cls_P7S1_TestData.createTestPlacement(false, site1);
        placement1.SomDig_Rotationstyp__c = 'Umfeld';
        placement1.SomDig_Typ__c = '71m intern';
        insert placement1;

        ADvendio__Ad_Type__c type1 = cls_P7S1_TestData.createTestAdType(false, md);
        type1.ADvendio__Advertising_Form_Shortform__c = 'PR1/MR';
        insert type1;

        ADvendio__Ad_Specs__c adspecs1 = cls_P7S1_TestData.createTestAdSpec(true, placement1, type1);

        ADvendio__Ad_price__c price1 = cls_P7S1_TestData.createTestAdPrice(true, adspecs1, rateCard1);

        ADvendio__MediaCampaign__c mc1 = cls_P7S1_TestData.createTestMediaCampaign(true, null, rateCard1, null);

        ADvendio__Campaign_Item__c ci1 = cls_P7S1_TestData.createTestCampaignItem(false, mc1, price1);
        ci1.ADvendio__from_Date__c=Date.today();
        ci1.ADvendio__until_Date__c=Date.today().addDays(1);
        insert ci1;

        List<ADvendio__Campaign_Item__c> ciList = new List<ADvendio__Campaign_Item__c>();
        ciList.add(ci1);

        Test.startTest();

        // Test für STEP1
        ADvendio__Campaign_Item__c item1 = [
            SELECT ADvendio__from_Date__c, ADvendio__Billing_category__c,
                   SomDig_MediagattungsDifferenzierung__c, ADvendio__until_Date__c,
                   ADvendio__Ad_price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.ADvendio__Advertising_Form_Shortform__c,
                   ADvendio__Media_Campaign__r.ADvendio__Pricelist__r.SomDig_AuftragstypId__c,
                   ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Rotationstyp__c,
                   ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Typ__c, ADvendio__Priority__c
              FROM ADvendio__Campaign_Item__c
             WHERE Id = :ci1.Id
        ];

        SomDig_DeliverPrio__c prio = [
            SELECT Id, SomDig_Gueltig_ab__c, SomDig_Gueltig_bis__c, SomDig_Abrechungsart__c, SomDig_Ad_Type__c,
                   SomDig_Belegungseinheitstyp__c, SomDig_Mediagattungsdifferenzierung__c, SomDig_Rotationstyp__c,
                   SomDig_Werbeform_Kurzform__c, SomDig_Auftragstyp__c, SomDig_Prio__c
              FROM SomDig_DeliverPrio__c
             WHERE Id = :p1.Id
        ];

        System.assertEquals(item1.ADvendio__from_Date__c, prio.SomDig_Gueltig_ab__c);
        System.assertEquals(item1.ADvendio__until_Date__c, prio.SomDig_Gueltig_bis__c);
        System.assertEquals(item1.ADvendio__Billing_category__c, prio.SomDig_Abrechungsart__c);
        System.assertEquals(item1.ADvendio__Media_Campaign__r.ADvendio__Pricelist__r.SomDig_AuftragstypId__c, prio.SomDig_Auftragstyp__c);
        System.assertEquals((String)item1.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Typ__c.toLowerCase(), (String)prio.SomDig_Belegungseinheitstyp__c.toLowerCase());
        System.assertEquals(item1.SomDig_MediagattungsDifferenzierung__c, prio.SomDig_Mediagattungsdifferenzierung__c);
        System.assertEquals(item1.ADvendio__Ad_price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.ADvendio__Advertising_Form_Shortform__c, prio.SomDig_Werbeform_Kurzform__c);
        System.assertEquals(item1.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Rotationstyp__c, prio.SomDig_Rotationstyp__c);
        System.assertEquals(item1.ADvendio__Priority__c, prio.SomDig_Prio__c);

        // Reset cached list of SomDig_DeliverPrio__c datasets because everything in this test method is run in a single execution context
        Adv_CampaignItem_DeliverPrio.cachedPrioDatasets = null;

        // Test für STEP2
        p1.SomDig_Werbeform_Kurzform__c = '';
        p1.SomDig_Prio__c = '5';
        update p1;
        ci1.ADvendio__Priority__c = '5';
        update ci1;

        item1 = [SELECT ADvendio__Priority__c FROM ADvendio__Campaign_Item__c WHERE Id = :ci1.Id];
        prio = [SELECT SomDig_Prio__c FROM SomDig_DeliverPrio__c WHERE Id = :p1.Id];

        System.assertEquals(item1.ADvendio__Priority__c, prio.SomDig_Prio__c);

        // Reset cached list of SomDig_DeliverPrio__c datasets because everything in this test method is run in a single execution context
        Adv_CampaignItem_DeliverPrio.cachedPrioDatasets = null;

        // Test für STEP3
        p1.SomDig_Rotationstyp__c = '';
        update p1;
        ci1.ADvendio__Priority__c = '9';
        update ci1;

        item1 = [SELECT ADvendio__Priority__c FROM ADvendio__Campaign_Item__c WHERE Id = :ci1.Id];
        prio = [SELECT SomDig_Prio__c FROM SomDig_DeliverPrio__c WHERE Id = :p1.Id];

        System.assertEquals(item1.ADvendio__Priority__c, prio.SomDig_Prio__c);

        Adv_CampaignItem_DeliverPrio cls = new Adv_CampaignItem_DeliverPrio();
        cls.sendNoPriorityFoundNotification(ciList);
        cls.sendToManyElementsNotification(ciList);

        Test.stopTest();
    }

}