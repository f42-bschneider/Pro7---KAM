@isTest
private class Adv_CampaignItem_Performance_Test {

    static testMethod void testAdv_CampaignItem_Performance_Test() {
        ADvendio__Campaign_Item__c ci1 = cls_P7S1_TestData.createTestCampaignItem(true);

        Test.startTest();

        ADvendio__Campaign_Item__c ci = [SELECT Id, ADvendio__PerformanceIndicator__c, SomDig_LeistungskennzahlVortag__c FROM ADvendio__Campaign_Item__c WHERE Id = :ci1.Id];

        // Here should have no SomDig_LeistungskennzahlVortag__c!
        System.assertEquals(0.0, ci.SomDig_LeistungskennzahlVortag__c != null ? ci.SomDig_LeistungskennzahlVortag__c : 0.0);

        ci1.ADvendio__Delivered_Impressions__c = 900;
        update ci1;

        // Now test the class.
        Adv_CampaignItem_Performance c = new Adv_CampaignItem_Performance();

        c.setRecordIds(null);

        c.addRecordId(ci1.Id);

        Database.executeBatch(c, 1);

        String sch = '0 0 23 * * ?';

        System.schedule('Test LeistungskennzahlVortag', sch, c);

        ci = [SELECT Id, ADvendio__PerformanceIndicator__c, SomDig_LeistungskennzahlVortag__c FROM ADvendio__Campaign_Item__c WHERE Id = :ci1.Id];

        c.execute(null, new List<SObject>{ ci });

        Test.stopTest();

        ci = [SELECT Id, ADvendio__PerformanceIndicator__c, SomDig_LeistungskennzahlVortag__c FROM ADvendio__Campaign_Item__c WHERE Id = :ci1.Id];

        //System.assertNotEquals(0.0, ci.SomDig_LeistungskennzahlVortag__c != null ? ci.SomDig_LeistungskennzahlVortag__c : 0.0);
        System.assertEquals(ci.ADvendio__PerformanceIndicator__c, ci.SomDig_LeistungskennzahlVortag__c);

    }
}