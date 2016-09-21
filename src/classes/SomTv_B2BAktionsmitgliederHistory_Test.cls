@isTest
private class SomTv_B2BAktionsmitgliederHistory_Test {

    static testMethod void testCampaignTrigger() {
        Test.startTest();

        // An Account
        Account acc1 = cls_P7S1_TestData.createTestAccount(true);

        // Contacts to create campaignmembers
        Contact con1 = cls_P7S1_TestData.createTestContact(true, acc1);
        Contact con2 = cls_P7S1_TestData.createTestContact(true, acc1);
        Contact con3 = cls_P7S1_TestData.createTestContact(true, acc1);
        Contact con4 = cls_P7S1_TestData.createTestContact(true, acc1);
        Contact con5 = cls_P7S1_TestData.createTestContact(true, acc1);


        // A Campaign
        Campaign cam1 = createTestCampaign(true);
        Campaign cam2 = createTestCampaign(true);



        // CampaignMemberStatus
        // For Campaign 1
        CampaignMemberStatus cms1 = createTestCampaignMemberStatus(true, cam1, 'Zusage', 3, true);
        CampaignMemberStatus cms2 = createTestCampaignMemberStatus(true, cam1, 'Absage', 4, false);

        // For Campaign 2
        CampaignMemberStatus cms3 = createTestCampaignMemberStatus(true, cam2, 'Bitte einladen', 5, true);
        CampaignMemberStatus cms4 = createTestCampaignMemberStatus(true, cam2, 'Bitte nachladen', 6, false);




        // Add CampaignMembers with different Statuses for different Campaigns
        List<CampaignMember> listCM = new List<CampaignMember>();

        // For Campaign 1
        CampaignMember cm1 = createTestCampaignMember(false, cam1, con1, 'Zusage');
        cm1.SomTv_AnzahlGaeste__c = '1';
        listCM.add(cm1);

        CampaignMember cm2 = createTestCampaignMember(false, cam1, con2, 'Zusage');
        cm2.SomTv_AnzahlGaeste__c = '2';
        listCM.add(cm2);

        CampaignMember cm3 = createTestCampaignMember(false, cam1, con3, 'Zusage');
        cm3.SomTv_AnzahlGaeste__c = '3';
        listCM.add(cm3);

        CampaignMember cm4 = createTestCampaignMember(false, cam1, con4, 'Absage');
        cm4.SomTv_AnzahlGaeste__c = '4';
        listCM.add(cm4);

        CampaignMember cm5 = createTestCampaignMember(false, cam1, con5, 'Absage');
        cm5.SomTv_AnzahlGaeste__c = '5';
        listCM.add(cm5);


        // For Campaign 2
        CampaignMember cm6 = createTestCampaignMember(false, cam2, con1, 'Bitte einladen');
        cm6.SomTv_AnzahlGaeste__c = '2';
        listCM.add(cm6);

        CampaignMember cm7 = createTestCampaignMember(false, cam2, con2, 'Bitte nachladen');
        cm7.SomTv_AnzahlGaeste__c = '2';
        listCM.add(cm7);

        CampaignMember cm8 = createTestCampaignMember(false, cam2, con3, 'Bitte nachladen');
        cm8.SomTv_AnzahlGaeste__c = '2';
        listCM.add(cm8);

        CampaignMember cm9 = createTestCampaignMember(false, cam2, con4, 'Bitte nachladen');
        cm9.SomTv_AnzahlGaeste__c = '2';
        listCM.add(cm9);

        CampaignMember cm10 = createTestCampaignMember(false, cam2, con5, 'Bitte nachladen');
        cm10.SomTv_AnzahlGaeste__c = '2';
        listCM.add(cm10);

        insert listCM;


        ///////// Test after insert
        // Sums for Campaign 1
        cam1 = [SELECT SomTv_GesamteGaeste__c , SomTv_Zusage__c, SomTv_Absage__c, SomTv_BitteEinladen__c, SomTv_BitteNachladen__c FROM Campaign WHERE Id = :cam1.Id LIMIT 1];
        System.assertEquals(3, cam1.SomTv_Zusage__c);
        System.assertEquals(2, cam1.SomTv_Absage__c);
        System.assertEquals(15, cam1.SomTv_GesamteGaeste__c);


        // Sums for Campaign 2
        cam2 = [SELECT SomTv_GesamteGaeste__c , SomTv_Zusage__c, SomTv_Absage__c, SomTv_BitteEinladen__c, SomTv_BitteNachladen__c FROM Campaign WHERE Id = :cam2.Id LIMIT 1];
        System.assertEquals(1, cam2.SomTv_BitteEinladen__c);
        System.assertEquals(4, cam2.SomTv_BitteNachladen__c);
        System.assertEquals(10, cam2.SomTv_GesamteGaeste__c);


        ////////// Test after update

        // Do update
        cm1.Status = 'Absage';
        cm2.SomTv_AnzahlGaeste__c = '4';
        cm6.Status = 'Bitte nachladen';
        List<CampaignMember> listCMUpdate = new List<CampaignMember>();
        listCMUpdate.add(cm1);
        listCMUpdate.add(cm2);
        listCMUpdate.add(cm6);
        update  listCMUpdate;


        // Sums for campaign 1
        cam1 = [SELECT SomTv_GesamteGaeste__c, SomTv_Zusage__c, SomTv_Absage__c, SomTv_BitteEinladen__c, SomTv_BitteNachladen__c FROM Campaign WHERE Id = :cam1.Id LIMIT 1];
        System.assertEquals(2, cam1.SomTv_Zusage__c);
        System.assertEquals(3, cam1.SomTv_Absage__c);
        System.assertEquals(17, cam1.SomTv_GesamteGaeste__c);


        // Sums for Campaign 2
        cam2 = [SELECT SomTv_Zusage__c, SomTv_Absage__c, SomTv_BitteEinladen__c, SomTv_BitteNachladen__c FROM Campaign WHERE Id = :cam2.Id LIMIT 1];
        System.assertEquals(0, cam2.SomTv_BitteEinladen__c);
        System.assertEquals(5, cam2.SomTv_BitteNachladen__c);


        ///////// Tests after delete
        // Do delete
        List<CampaignMember> listCMdel = new List<CampaignMember>();
        listCMdel.add(cm3);
        listCMdel.add(cm7);
        delete  listCMdel;


        // Sums for campaign 1
        cam1 = [SELECT SomTv_Zusage__c, SomTv_Absage__c, SomTv_BitteEinladen__c, SomTv_BitteNachladen__c FROM Campaign WHERE Id = :cam1.Id LIMIT 1];
        System.assertEquals(1, cam1.SomTv_Zusage__c);
        System.assertEquals(3, cam1.SomTv_Absage__c);

        // Sums for campaign 2
        cam2 = [SELECT SomTv_Zusage__c, SomTv_Absage__c, SomTv_BitteEinladen__c, SomTv_BitteNachladen__c FROM Campaign WHERE Id = :cam2.Id LIMIT 1];
        System.assertEquals(0, cam2.SomTv_BitteEinladen__c);
        System.assertEquals(4, cam2.SomTv_BitteNachladen__c);


        Test.stopTest();
    }


    // TODO: Move to testclass
    public static Campaign createTestCampaign(Boolean insertObject) {
        Campaign testCampaign = new Campaign();
        testCampaign.Name = 'TestCampaign';
        if (insertObject) insert testCampaign;
        return testCampaign;
    }

    public static CampaignMember createTestCampaignMember(Boolean insertObject, Campaign campaign, Contact contact, String status) {
        CampaignMember testCampaignMember = new CampaignMember();
        testCampaignMember.CampaignId = campaign.Id;
        testCampaignMember.ContactId = contact.Id;
        testCampaignMember.Status = status;

        if (insertObject) insert testCampaignMember;
        return testCampaignMember;
    }

    public static CampaignMemberStatus createTestCampaignMemberStatus(Boolean insertObject, Campaign campaign, String label, Integer sortOrder, Boolean isDefault) {
        CampaignMemberStatus testCampaignMemberStatus = new CampaignMemberStatus();
        testCampaignMemberStatus.CampaignId = campaign.Id;
        testCampaignMemberStatus.Label = label;
        testCampaignMemberStatus.SortOrder = sortOrder;
        testCampaignMemberStatus.IsDefault = isDefault;
        testCampaignMemberStatus.HasResponded = false;


        if (insertObject) insert testCampaignMemberStatus;
        return testCampaignMemberStatus;
    }
}