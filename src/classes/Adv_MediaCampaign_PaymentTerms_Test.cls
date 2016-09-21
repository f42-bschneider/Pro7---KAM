@isTest
private class Adv_MediaCampaign_PaymentTerms_Test {

    private static testmethod void testAdv_MediaCampaign_PaymentTerms_InsertTest_01() {
        ADvendio__MediaCampaign__c mediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);

        Test.StartTest();

        insert mediaCampaign;

        Test.stopTest();

        mediaCampaign = [SELECT SomDig_Zahlungsbedingung__c FROM ADvendio__MediaCampaign__c WHERE Id = :mediaCampaign.Id];

        System.assertNotEquals(null, mediaCampaign.SomDig_Zahlungsbedingung__c);
        System.assertEquals(cls_P7S1_TestData.Zahlungsbedingung_TestData.Id, mediaCampaign.SomDig_Zahlungsbedingung__c);
    }

    private static testmethod void testAdv_MediaCampaign_PaymentTerms_InsertTest_02() {
        SomDig_Zahlungsbedingung__c zahlungsbedingung0 = cls_P7S1_TestData.createTestZahlungsbedingung(false);
        SomDig_Zahlungsbedingung__c zahlungsbedingung1 = cls_P7S1_TestData.createTestZahlungsbedingung(false);
        zahlungsbedingung1.SomDig_SAPCode__c = '1234';
        insert new List<SomDig_Zahlungsbedingung__c>{zahlungsbedingung0, zahlungsbedingung1};

        ADvendio__MediaCampaign__c mediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        mediaCampaign.SomDig_Zahlungsbedingung__c = zahlungsbedingung1.Id;

        Test.StartTest();

        insert mediaCampaign;

        Test.stopTest();

        mediaCampaign = [SELECT SomDig_Zahlungsbedingung__c FROM ADvendio__MediaCampaign__c WHERE Id = :mediaCampaign.Id];

        System.assertNotEquals(null, mediaCampaign.SomDig_Zahlungsbedingung__c);
        System.assertEquals(zahlungsbedingung1.Id, mediaCampaign.SomDig_Zahlungsbedingung__c);
    }

    private static testmethod void testAdv_MediaCampaign_PaymentTerms_UpdateTest_01() {
        SomDig_Zahlungsbedingung__c zahlungsbedingung0 = cls_P7S1_TestData.createTestZahlungsbedingung(false);
        SomDig_Zahlungsbedingung__c zahlungsbedingung1 = cls_P7S1_TestData.createTestZahlungsbedingung(false);
        zahlungsbedingung1.SomDig_SAPCode__c = '1234';
        insert new List<SomDig_Zahlungsbedingung__c>{zahlungsbedingung0, zahlungsbedingung1};

        ADvendio__MediaCampaign__c mediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        mediaCampaign.SomDig_Zahlungsbedingung__c = zahlungsbedingung1.Id;
        insert mediaCampaign;

        mediaCampaign = [SELECT SomDig_Zahlungsbedingung__c FROM ADvendio__MediaCampaign__c WHERE Id = :mediaCampaign.Id];

        System.assertNotEquals(null, mediaCampaign.SomDig_Zahlungsbedingung__c);
        System.assertEquals(zahlungsbedingung1.Id, mediaCampaign.SomDig_Zahlungsbedingung__c);

        Test.StartTest();

        mediaCampaign.SomDig_Zahlungsbedingung__c = null;
        update mediaCampaign;

        Test.stopTest();

        mediaCampaign = [SELECT SomDig_Zahlungsbedingung__c FROM ADvendio__MediaCampaign__c WHERE Id = :mediaCampaign.Id];

        System.assertNotEquals(null, mediaCampaign.SomDig_Zahlungsbedingung__c);
        System.assertEquals(zahlungsbedingung0.Id, mediaCampaign.SomDig_Zahlungsbedingung__c);
    }

}