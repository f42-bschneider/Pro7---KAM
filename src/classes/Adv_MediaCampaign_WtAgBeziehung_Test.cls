@isTest
private class Adv_MediaCampaign_WtAgBeziehung_Test {

    static testMethod void media_Campaign_Should_Receive_Wt_Ag_Lookups_On_Insert() {
        Account l_oWerbetreibender = cls_P7S1_TestData.createTestAccount(false);
        Account l_oAgentur = cls_P7S1_TestData.createTestAccount(false);
        insert new List<Account>{l_oWerbetreibender, l_oAgentur};
        SomDig_WtAgBeziehung__c l_oWtAgBeziehung = cls_P7S1_TestData.createTestWTAG(true, l_oWerbetreibender, l_oAgentur);
        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false, l_oWtAgBeziehung);

        Test.startTest();

        insert l_oMediaCampaign;

        Test.stopTest();

        reload_MediaCampaign_And_Assert_WtAg_Lookups(l_oMediaCampaign, l_oWerbetreibender, l_oAgentur);
    }

    static testMethod void media_Campaign_Should_Receive_Wt_Ag_Lookups_On_Update() {
        Account l_oWerbetreibender_1 = cls_P7S1_TestData.createTestAccount(false);
        Account l_oWerbetreibender_2 = cls_P7S1_TestData.createTestAccount(false);
        Account l_oAgentur_1 = cls_P7S1_TestData.createTestAccount(false);
        Account l_oAgentur_2 = cls_P7S1_TestData.createTestAccount(false);
        insert new List<Account>{l_oWerbetreibender_1, l_oWerbetreibender_2, l_oAgentur_1, l_oAgentur_2};
        SomDig_WtAgBeziehung__c l_oWtAgBeziehung_1 = cls_P7S1_TestData.createTestWTAG(false, l_oWerbetreibender_1, l_oAgentur_1);
        SomDig_WtAgBeziehung__c l_oWtAgBeziehung_2 = cls_P7S1_TestData.createTestWTAG(false, l_oWerbetreibender_2, l_oAgentur_2);
        insert new List<SomDig_WtAgBeziehung__c>{l_oWtAgBeziehung_1, l_oWtAgBeziehung_2};

        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(true, l_oWtAgBeziehung_1);

        Test.startTest();

        reload_MediaCampaign_And_Assert_WtAg_Lookups(l_oMediaCampaign, l_oWerbetreibender_1, l_oAgentur_1);

        // Update the MediaCampaign's WT-AG-Beziehung
        // Lookups should change
        l_oMediaCampaign.SomDig_WtAgBeziehung__c = l_oWtAgBeziehung_2.Id;
        update l_oMediaCampaign;

        Test.stopTest();

        reload_MediaCampaign_And_Assert_WtAg_Lookups(l_oMediaCampaign, l_oWerbetreibender_2, l_oAgentur_2);
    }


    // HELPER METHOD
    // Reload MediaCampaign and assert that ADvendio__Account__c and ADvendio__Agency__c were updated from the corresponding fields of the SomDig_WtAgBeziehung__c
    static void reload_MediaCampaign_And_Assert_WtAg_Lookups(ADvendio__MediaCampaign__c p_oMediaCampaign, Account p_oWerbetreibender, Account p_oAgentur) {
        ADvendio__MediaCampaign__c l_oMediaCampaign = [
            SELECT Id, ADvendio__Account__c, ADvendio__Agency__c
              FROM ADvendio__MediaCampaign__c
             WHERE Id = :p_oMediaCampaign.Id
        ];
        System.assertEquals(p_oWerbetreibender.Id, l_oMediaCampaign.ADvendio__Account__c);
        System.assertEquals(p_oAgentur.Id, l_oMediaCampaign.ADvendio__Agency__c);
    }

}