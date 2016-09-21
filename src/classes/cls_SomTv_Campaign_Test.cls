/**
 * Test class for cls_SomTv_Campaign.
 */
@IsTest
private class cls_SomTv_Campaign_Test {

    @IsTest
    public static void testCls_SomTv_Campaign() {
        Test.startTest();

        Id rtId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName ='SomTv_Event' LIMIT 1].Id;

        DateTime now = Datetime.now();

        // A (parent) Campaign
        Campaign cam1 = new Campaign(Name='A test campaign 1', RecordTypeId=rtId);
        insert cam1;

        // Another (parent) Campaign
        Campaign cam2 = new Campaign(Name='A test campaign 2', RecordTypeId=rtId);
        insert cam2;

        // A (child) Campaign, parent is cam1
        Campaign cam3 = new Campaign(Name='A test campaign 3', ParentId=cam1.Id, SomTv_UhrzeitStart__c=now, SomTv_UhrzeitEnde__c=now, RecordTypeId=rtId);
        insert cam3;

        // cam1 should SomTv_UhrzeitStart__c and SomTv_UhrzeitEnde__c set.
        Campaign cam = [SELECT Id, SomTv_UhrzeitStart__c, SomTv_UhrzeitEnde__c FROM Campaign WHERE Id = :cam1.Id];
        System.assert(cam.SomTv_UhrzeitStart__c.format('yyyy-MM-dd HH:mm:ss')==now.format('yyyy-MM-dd HH:mm:ss'));
        System.assert(cam.SomTv_UhrzeitEnde__c.format('yyyy-MM-dd HH:mm:ss')==now.format('yyyy-MM-dd HH:mm:ss'));

        cam3.ParentId=cam2.Id;
        update cam3;

        // cam1 should SomTv_UhrzeitStart__c and SomTv_UhrzeitEnde__c set to null.
        cam = [SELECT Id, SomTv_UhrzeitStart__c, SomTv_UhrzeitEnde__c FROM Campaign WHERE Id = :cam1.Id];
        System.assert(cam.SomTv_UhrzeitStart__c==null);
        System.assert(cam.SomTv_UhrzeitEnde__c==null);

        // cam2 should SomTv_UhrzeitStart__c and SomTv_UhrzeitEnde__c set.
        cam = [SELECT Id, SomTv_UhrzeitStart__c, SomTv_UhrzeitEnde__c FROM Campaign WHERE Id = :cam2.Id];
        System.assert(cam.SomTv_UhrzeitStart__c.format('yyyy-MM-dd HH:mm:ss')==now.format('yyyy-MM-dd HH:mm:ss'));
        System.assert(cam.SomTv_UhrzeitEnde__c.format('yyyy-MM-dd HH:mm:ss')==now.format('yyyy-MM-dd HH:mm:ss'));

        delete cam3;

        // cam2 should SomTv_UhrzeitStart__c and SomTv_UhrzeitEnde__c set to null.
        cam = [SELECT Id, SomTv_UhrzeitStart__c, SomTv_UhrzeitEnde__c FROM Campaign WHERE Id = :cam2.Id];
        System.assert(cam.SomTv_UhrzeitStart__c==null);
        System.assert(cam.SomTv_UhrzeitEnde__c==null);

        undelete cam3;

        // cam2 should SomTv_UhrzeitStart__c and SomTv_UhrzeitEnde__c set.
        cam = [SELECT Id, SomTv_UhrzeitStart__c, SomTv_UhrzeitEnde__c FROM Campaign WHERE Id = :cam2.Id];
        System.assert(cam.SomTv_UhrzeitStart__c.format('yyyy-MM-dd HH:mm:ss')==now.format('yyyy-MM-dd HH:mm:ss'));
        System.assert(cam.SomTv_UhrzeitEnde__c.format('yyyy-MM-dd HH:mm:ss')==now.format('yyyy-MM-dd HH:mm:ss'));


        // Create custom Setting
        P7S1_CampaignMemberStatusDefaultValues__c camDefaultVal = new P7S1_CampaignMemberStatusDefaultValues__c(Name = 'Zusage', SomTv_Medien__c = true, SomTv_Mailing__c = true, SomTv_Event__c = true);
        insert camDefaultVal;


        Id  eventCampaignId = null;
        Id  medienCampaignId = null;
        for (RecordType rt :  [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Campaign']) {
            if ('SomTv_Event'.equals(rt.DeveloperName)) {
                eventCampaignId = rt.Id;
            } else if ('SomTv_Medien'.equals(rt.DeveloperName)) {
                medienCampaignId = rt.Id;
            }
        }

        if (eventCampaignId != null) {
            Campaign cam4 = new Campaign(Name='A test campaign 4', RecordTypeId=eventCampaignId);
            insert cam4;

            System.Debug('#####' + cam4);

            List<CampaignMemberStatus> lst = [SELECT Id, Label FROM CampaignMemberStatus WHERE CampaignId = :cam4.Id];
            System.assertEquals(1, lst.size());    // 2 system default labels not included
        }

        if (medienCampaignId != null) {
            Campaign cam5 = new Campaign(Name='A test campaign 5', RecordTypeId=medienCampaignId);
            insert cam5;

            List<CampaignMemberStatus> lst = [SELECT Id, Label FROM CampaignMemberStatus WHERE CampaignId = :cam5.Id];
            System.assertEquals(1, lst.size());     // 2 system default labels not included
        }

        Test.stopTest();
    }

    @IsTest
    public static void testCls_SomTv_Campaign_MN3() {
        Test.startTest();

        Id rtId = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName ='SomTv_Event' LIMIT 1].Id;

        // A Campaign
        Campaign cam = new Campaign(Name='A test campaign 1', RecordTypeId=rtId);
        insert cam;

        // Test MN3 of Opportunity & Campaign
        Account acc = new Account(Name='Test Account', ProRex_Rolle__c='Kunde', SomTv_HilfsfeldProRexRolle__c='Kunde');
        insert acc;

        rtId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'SomTv_Commitment' LIMIT 1].Id;

        Opportunity opp = new Opportunity(Name='Test Opportunity', AccountId=acc.Id, CampaignId=cam.Id, RecordTypeId=rtId, StageName='Identifiziert', Probability=10, CloseDate=System.today(), Amount = 1000, SomTV_MN3__c=1000);
        insert opp;

        opp = [SELECT Id, SomTV_MN3__c FROM Opportunity WHERE Id = :opp.Id];
        cam = [SELECT Id, SomTv_OpportunitiesMN3Gesamt__c, SomTv_OpportunitiesMN3Gewonnen__c FROM Campaign WHERE Id = :cam.Id];

        System.assertEquals(opp.SomTV_MN3__c, cam.SomTv_OpportunitiesMN3Gesamt__c);
        System.assertEquals(0, cam.SomTv_OpportunitiesMN3Gewonnen__c);

        opp.StageName = 'Geschlossene und gewonnene';
        opp.Probability = 100;
        update opp;

        cam = [SELECT Id, SomTv_OpportunitiesMN3Gesamt__c, SomTv_OpportunitiesMN3Gewonnen__c FROM Campaign WHERE Id = :cam.Id];
        System.assertEquals(opp.SomTV_MN3__c, cam.SomTv_OpportunitiesMN3Gesamt__c);
        System.assertEquals(opp.SomTV_MN3__c, cam.SomTv_OpportunitiesMN3Gewonnen__c);

        Test.stopTest();
    }
}