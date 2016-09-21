@isTest
private class Adv_MediaCampaign_Owner_Test {

    static testmethod void owner_Should_Be_Current_User_On_Insert() {
        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        l_oMediaCampaign.SomDig_BetreuerSales__c = null;
        l_oMediaCampaign.SomDig_BetreuerPam__c = null;

        Test.startTest();

        insert l_oMediaCampaign;

        Test.stopTest();

        reload_MediaCampaign_And_Assert_OwnerId(l_oMediaCampaign, UserInfo.getUserId());
    }

    static testmethod void owner_Should_Be_Betreuer_PAM_On_Insert() {
        Id PAM_UserId = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomDig_PAM');

        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        l_oMediaCampaign.SomDig_BetreuerSales__c = null;
        l_oMediaCampaign.SomDig_BetreuerPam__c = PAM_UserId;
        l_oMediaCampaign.ADvendio__Stage__c = 'Booked';

        Test.startTest();

        insert l_oMediaCampaign;

        Test.stopTest();

        reload_MediaCampaign_And_Assert_OwnerId(l_oMediaCampaign, PAM_UserId);
    }

    static testmethod void owner_Should_Be_Betreuer_Sales_On_Insert() {
        Id SalesUserId = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomDig_Sales');

        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        l_oMediaCampaign.SomDig_BetreuerSales__c = SalesUserId;
        l_oMediaCampaign.SomDig_BetreuerPam__c = null;

        Test.startTest();

        insert l_oMediaCampaign;

        Test.stopTest();

        reload_MediaCampaign_And_Assert_OwnerId(l_oMediaCampaign, SalesUserId);
    }

    static testmethod void owner_Should_Be_Betreuer_PAM_On_Update() {
        Id PAM_UserId = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomDig_PAM');
        Id SalesUserId = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomDig_Sales');

        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        l_oMediaCampaign.SomDig_BetreuerSales__c = SalesUserId;
        l_oMediaCampaign.SomDig_BetreuerPam__c = PAM_UserId;
        insert l_oMediaCampaign;

        reload_MediaCampaign_And_Assert_OwnerId(l_oMediaCampaign, SalesUserId);

        Test.startTest();

        l_oMediaCampaign.ADvendio__Stage__c = 'Booked';
        update l_oMediaCampaign;

        Test.stopTest();

        reload_MediaCampaign_And_Assert_OwnerId(l_oMediaCampaign, PAM_UserId);
    }

    private static void reload_MediaCampaign_And_Assert_OwnerId(ADvendio__MediaCampaign__c p_oMediaCampaign, Id p_sOwnerId) {
        ADvendio__MediaCampaign__c l_oMediaCampaign = [SELECT Id, OwnerId FROM ADvendio__MediaCampaign__c WHERE Id = :p_oMediaCampaign.Id];
        System.assertEquals(p_sOwnerId, l_oMediaCampaign.OwnerId);
    }
}