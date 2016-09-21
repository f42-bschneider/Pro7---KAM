@isTest
private class Adv_AdServerId_AdUnitHierarchy_Test {

    static testMethod void testAdv_AdServerId_AdUnitHierarchy() {
        Test.startTest();

        ADvendio__Site__c site = cls_P7S1_TestData.createTestSite(true);
        SomDig_MediagattungsSegment__c mg = cls_P7S1_TestData.createTestMediagattungsSegment(true);

        ADvendio__AdServer_ID__c adserv1 = cls_P7S1_TestData.createTestAdServerID(true);

        ADvendio__AdServer_ID__c adserv2 = cls_P7S1_TestData.createTestAdServerID(false);
        adserv2.ADvendio__Parent_AdServer_ID__c = adserv1.Id;
        insert adserv2;

        ADvendio__AdServer_ID__c adserv3 = cls_P7S1_TestData.createTestAdServerID(false);
        adserv3.ADvendio__Parent_AdServer_ID__c = adserv2.Id;
        insert adserv3;

        // Now test the class.
        Adv_AdServerId_AdUnitHierarchy c = new Adv_AdServerId_AdUnitHierarchy();
        c.setRecordIds(null);
        c.addRecordId(adserv2.Id);

        Database.executeBatch(c, 1);

        String sch = '0 0 23 * * ?';
        System.schedule('Test RechnungsproduktErstellen', sch, c);

        // Test logic and etc.
        ADvendio__AdServer_ID__c adserv = [SELECT ADvendio__Site__c, SomDig_MediagattungsSegment__c FROM ADvendio__AdServer_ID__c WHERE Id = :adserv3.Id];

        System.assertEquals(null, adserv.ADvendio__Site__c);
        System.assertEquals(null, adserv.SomDig_MediagattungsSegment__c);

        adserv2.ADvendio__Site__c = site.Id;
        adserv2.SomDig_MediagattungsSegment__c = mg.Id;
        update adserv2;

        adserv = [SELECT ADvendio__Site__c, SomDig_MediagattungsSegment__c, SomDig_TopSite__c, SomDig_TopMediagattungsSegment__c FROM ADvendio__AdServer_ID__c WHERE Id = :adserv3.Id];

        System.assertEquals(null, adserv.ADvendio__Site__c);
        System.assertEquals(null, adserv.SomDig_MediagattungsSegment__c);
        System.assertNotEquals(null, adserv.SomDig_TopSite__c);
        System.assertNotEquals(null, adserv.SomDig_TopMediagattungsSegment__c);

        c.execute(null, new List<ADvendio__AdServer_ID__c> {adserv});

        adserv = [SELECT ADvendio__Site__c, SomDig_MediagattungsSegment__c FROM ADvendio__AdServer_ID__c WHERE Id = :adserv3.Id];

        System.assertEquals(site.Id, adserv.ADvendio__Site__c);
        System.assertEquals(mg.Id, adserv.SomDig_MediagattungsSegment__c);

        Test.stopTest();
    }
}