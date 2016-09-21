/**
 * Test class for Adv_MediaCampaign_Debitorennr
 */
@isTest
private class Adv_MediaCampaign_Debitorennr_Test {

    static testmethod void test_MediaCampaign_Debitor_Test() {
        Account account = cls_P7S1_TestData.createTestAccount(true);

        SomDig_Auftragstyp__c auftragsTyp = cls_P7S1_TestData.createTestAuftragstyp(true, 'Barter');

        ADvendio__Pricelist__c pricelist = cls_P7S1_TestData.createTestPricelist(true, auftragsTyp);

        P7S1_ExternalId__c externalId1 = cls_P7S1_TestData.createTestExternalId(false, account);
        externalId1.Name = '9874000815';
        P7S1_ExternalId__c externalId2 = cls_P7S1_TestData.createTestExternalId(false, account);
        externalId2.Name = '2894004712';
        externalId2.P7S1_Source__c = 'Debitorennr BK 29 - Barter';
        insert new List<P7S1_ExternalId__c> {externalId1, externalId2};

        for (P7S1_ExternalId__c eid : [Select Id, Name, P7S1_Source__c FROM P7S1_ExternalId__c]) {
            if (eid.P7S1_Source__c != 'Debitorennr BK 29 - Barter') externalId1 = eid;
            if (eid.P7S1_Source__c == 'Debitorennr BK 29 - Barter') externalId2 = eid;
        }

        SomDig_Zahlungsbedingung__c zahlungsbedingung =  cls_P7S1_TestData.createTestZahlungsbedingung(false);
        zahlungsbedingung.SomDig_Skontowert__c = 0;
        insert zahlungsbedingung;

        ADvendio__MediaCampaign__c mediaCampaign1 = cls_P7S1_TestData.createTestMediaCampaign(false, null, pricelist);
        ADvendio__MediaCampaign__c mediaCampaign2 = cls_P7S1_TestData.createTestMediaCampaign(false, account, pricelist);
        ADvendio__MediaCampaign__c mediaCampaign3 = cls_P7S1_TestData.createTestMediaCampaign(false, account, pricelist);
        mediaCampaign3.ADvendio__Stage__c = 'Stage 75%';
        List<ADvendio__MediaCampaign__c> mediaCampaigns = new List<ADvendio__MediaCampaign__c>{mediaCampaign1, mediaCampaign2, mediaCampaign3};

        Test.StartTest();

        insert mediaCampaigns;

        for (ADvendio__MediaCampaign__c mediaCampaign : [SELECT Id, SomDig_Debitorennr__c FROM ADvendio__MediaCampaign__c WHERE Id IN :mediaCampaigns]) {
            if (mediaCampaign.Id == mediaCampaign1.Id) {
                System.assertEquals(null, mediaCampaign.SomDig_Debitorennr__c);
            }
            if (mediaCampaign.Id == mediaCampaign2.Id) {
                System.assertEquals(null, mediaCampaign.SomDig_Debitorennr__c);
            }
            if (mediaCampaign.Id == mediaCampaign3.Id) {
                System.assertEquals(externalId2.Name, mediaCampaign.SomDig_Debitorennr__c);
            }
        }

        mediaCampaign1.ADvendio__invoice_recipient__c  = account.Id;
        mediaCampaign1.ADvendio__Stage__c              = 'Booked';
        mediaCampaign2.ADvendio__Stage__c              = 'Booked';
        update mediaCampaigns;

        Test.StopTest();

        for (ADvendio__MediaCampaign__c mediaCampaign : [SELECT Id, SomDig_Debitorennr__c FROM ADvendio__MediaCampaign__c WHERE Id IN :mediaCampaigns]) {
            if (mediaCampaign.Id == mediaCampaign1.Id) {
                System.assertEquals(externalId2.Name, mediaCampaign.SomDig_Debitorennr__c);
            }
            if (mediaCampaign.Id == mediaCampaign2.Id) {
                System.assertEquals(externalId2.Name, mediaCampaign.SomDig_Debitorennr__c);
            }
            if (mediaCampaign.Id == mediaCampaign3.Id) {
                System.assertEquals(externalId2.Name, mediaCampaign.SomDig_Debitorennr__c);
            }
        }

    }
}