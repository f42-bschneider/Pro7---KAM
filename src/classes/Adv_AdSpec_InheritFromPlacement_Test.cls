@isTest
private with sharing class Adv_AdSpec_InheritFromPlacement_Test {

    static testMethod void adSpecInsertShouldInheritValues() {
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.SomDig_Auftragstypen__c = 'Forschung;Standard';
        placement.SomDig_FC__c = true;
        placement.SomDig_BT__c = true;
        placement.SomDig_GtFaehig__c = true;
        placement.SomDig_iAdFaehig__c = true;
        placement.Targeting_Provider__c = 'Autosites;nugg.ad';
        insert placement;

        Test.startTest();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.stopTest();

        adSpec = [SELECT SomDig_Auftragstypen__c, SomDig_BT__c, SomDig_FC__c, SomDig_GtFaehig__c, SomDig_iAdFaehig__c, SomDig_Targeting_Provider__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        System.assertEquals(new Set<String>('Forschung;Standard'.split(';')), new Set<String>(adSpec.SomDig_Auftragstypen__c.split(';')));
        System.assertEquals(true, adSpec.SomDig_BT__c);
        System.assertEquals(true, adSpec.SomDig_FC__c);
        System.assertEquals(true, adSpec.SomDig_GtFaehig__c);
        System.assertEquals(true, adSpec.SomDig_iAdFaehig__c);
        System.assertEquals(new Set<String>('Autosites;nugg.ad'.split(';')), new Set<String>(adSpec.SomDig_Targeting_Provider__c.split(';')));
    }

    static testMethod void adSpecUpdateShouldNotInheritValues() {
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.SomDig_Auftragstypen__c = 'Forschung;Standard';
        placement.SomDig_BT__c = true;
        placement.SomDig_FC__c = true;
        placement.SomDig_GtFaehig__c = true;
        placement.SomDig_iAdFaehig__c = true;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.startTest();

        adSpec = [SELECT SomDig_Auftragstypen__c, SomDig_BT__c, SomDig_FC__c, SomDig_GtFaehig__c, SomDig_iAdFaehig__c, SomDig_Targeting_Provider__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        adSpec.SomDig_Auftragstypen__c = 'Barter;Performance';
        adSpec.SomDig_BT__c = false;
        adSpec.SomDig_FC__c = false;
        adSpec.SomDig_GtFaehig__c = false;
        adSpec.SomDig_iAdFaehig__c = false;
        update adSpec;

        Test.stopTest();

        adSpec = [SELECT SomDig_Auftragstypen__c, SomDig_BT__c, SomDig_FC__c, SomDig_GtFaehig__c, SomDig_iAdFaehig__c, SomDig_Targeting_Provider__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        System.assertEquals(new Set<String>('Barter;Performance'.split(';')), new Set<String>(adSpec.SomDig_Auftragstypen__c.split(';')));
        System.assertEquals(false, adSpec.SomDig_BT__c);
        System.assertEquals(false, adSpec.SomDig_FC__c);
        System.assertEquals(false, adSpec.SomDig_GtFaehig__c);
        System.assertEquals(false, adSpec.SomDig_iAdFaehig__c);
    }

    static testMethod void placementUpdateShouldUpdateValues() {
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.SomDig_Auftragstypen__c = 'Eigenwerbung';
        placement.SomDig_BT__c = false;
        placement.SomDig_FC__c = false;
        placement.SomDig_GtFaehig__c = false;
        placement.SomDig_iAdFaehig__c = false;
        placement.Targeting_Provider__c = 'Bundesliga;wetter.com';
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.startTest();

        placement.SomDig_Auftragstypen__c = 'Barter;Standard';
        placement.SomDig_BT__c = true;
        placement.SomDig_FC__c = true;
        placement.SomDig_GtFaehig__c = true;
        placement.SomDig_iAdFaehig__c = true;
        placement.Targeting_Provider__c = 'Gesundheit.de;ICQ';
        update placement;

        Test.stopTest();

        adSpec = [SELECT SomDig_Auftragstypen__c, SomDig_BT__c, SomDig_FC__c, SomDig_GtFaehig__c, SomDig_iAdFaehig__c, SomDig_Targeting_Provider__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        System.assertEquals(new Set<String>('Barter;Standard'.split(';')), new Set<String>(adSpec.SomDig_Auftragstypen__c.split(';')));
        System.assertEquals(true, adSpec.SomDig_BT__c);
        System.assertEquals(true, adSpec.SomDig_FC__c);
        System.assertEquals(true, adSpec.SomDig_GtFaehig__c);
        System.assertEquals(true, adSpec.SomDig_iAdFaehig__c);
        System.assertEquals(new Set<String>('Gesundheit.de;ICQ'.split(';')), new Set<String>(adSpec.SomDig_Targeting_Provider__c.split(';')));
    }

    static testMethod void placementUpdateShouldOnlyUpdateChangedValues() {
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.SomDig_Auftragstypen__c = 'Eigenwerbung';
        placement.SomDig_BT__c = false;
        placement.SomDig_FC__c = false;
        placement.SomDig_GtFaehig__c = false;
        placement.SomDig_iAdFaehig__c = false;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.startTest();

        adSpec = [SELECT SomDig_Auftragstypen__c, SomDig_BT__c, SomDig_FC__c, SomDig_GtFaehig__c, SomDig_iAdFaehig__c, SomDig_Targeting_Provider__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        adSpec.SomDig_Auftragstypen__c = 'Eigenwerbung;Standard';
        adSpec.SomDig_iAdFaehig__c = true;
        update adSpec;

        placement.SomDig_BT__c = true;
        placement.SomDig_GtFaehig__c = true;
        update placement;

        Test.stopTest();

        adSpec = [SELECT SomDig_Auftragstypen__c, SomDig_BT__c, SomDig_FC__c, SomDig_GtFaehig__c, SomDig_iAdFaehig__c, SomDig_Targeting_Provider__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        System.assertEquals(new Set<String>('Eigenwerbung;Standard'.split(';')), new Set<String>(adSpec.SomDig_Auftragstypen__c.split(';')));
        System.assertEquals(true, adSpec.SomDig_BT__c);
        System.assertEquals(false, adSpec.SomDig_FC__c);
        System.assertEquals(true, adSpec.SomDig_GtFaehig__c);
        System.assertEquals(true, adSpec.SomDig_iAdFaehig__c);
    }

    static testMethod void adSpecInsertShouldInsertAdServerIdAssignments() {
        ADvendio__AdServer_ID__c adServerID = cls_P7S1_TestData.createTestAdServerID(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.SomDig_AdServerID__c = adServerID.Id;
        insert placement;

        Test.startTest();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.stopTest();

        List<ADvendio__AdServer_ID_AdSpec_Assigment__c> assignments = [
            SELECT Id, ADvendio__AdServer_ID__c
              FROM ADvendio__AdServer_ID_AdSpec_Assigment__c
             WHERE ADvendio__Ad_Spec__c = :adSpec.Id];
        System.assertEquals(1, assignments.size());
        System.assertEquals(adServerID.Id, assignments[0].ADvendio__AdServer_ID__c);
    }

    static testMethod void adSpecInsertShouldNotInsertAdServerIdAssignments() {
        ADvendio__AdServer_ID__c adServerID = cls_P7S1_TestData.createTestAdServerID(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(true);

        Test.startTest();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM ADvendio__AdServer_ID_AdSpec_Assigment__c WHERE ADvendio__Ad_Spec__c = :adSpec.Id]);
    }

    static testMethod void placementUpdateShouldInsertAdServerIdAssignments() {
        ADvendio__AdServer_ID__c adServerID = cls_P7S1_TestData.createTestAdServerID(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(true);
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.startTest();

        System.assertEquals(0, [SELECT count() FROM ADvendio__AdServer_ID_AdSpec_Assigment__c WHERE ADvendio__Ad_Spec__c = :adSpec.Id]);

        placement.SomDig_AdServerID__c = adServerID.Id;
        update placement;

        Test.stopTest();

        List<ADvendio__AdServer_ID_AdSpec_Assigment__c> assignments = [
            SELECT Id, ADvendio__AdServer_ID__c
              FROM ADvendio__AdServer_ID_AdSpec_Assigment__c
             WHERE ADvendio__Ad_Spec__c = :adSpec.Id];
        System.assertEquals(1, assignments.size());
        System.assertEquals(adServerID.Id, assignments[0].ADvendio__AdServer_ID__c);
    }

    static testMethod void placementUpdateShouldUpdateAdServerIdAssignments() {
        ADvendio__AdServer_ID__c adServerID = cls_P7S1_TestData.createTestAdServerID(true);
        ADvendio__AdServer_ID__c adServerID_2 = cls_P7S1_TestData.createTestAdServerID(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.SomDig_AdServerID__c = adServerID.Id;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.startTest();

        List<ADvendio__AdServer_ID_AdSpec_Assigment__c> oldAssignments = [
            SELECT Id, ADvendio__AdServer_ID__c
              FROM ADvendio__AdServer_ID_AdSpec_Assigment__c
             WHERE ADvendio__Ad_Spec__c = :adSpec.Id];
        System.assertEquals(1, oldAssignments.size());
        System.assertEquals(adServerID.Id, oldAssignments[0].ADvendio__AdServer_ID__c);

        placement.SomDig_AdServerID__c = adServerID_2.Id;
        update placement;

        Test.stopTest();

        List<ADvendio__AdServer_ID_AdSpec_Assigment__c> newAssignments = [
            SELECT Id, ADvendio__AdServer_ID__c
              FROM ADvendio__AdServer_ID_AdSpec_Assigment__c
             WHERE ADvendio__Ad_Spec__c = :adSpec.Id];
        System.assertEquals(1, newAssignments.size());
        System.assertEquals(adServerID_2.Id, newAssignments[0].ADvendio__AdServer_ID__c);
    }

    static testMethod void placementUpdateShouldDeleteAdServerIdAssignments() {
        ADvendio__AdServer_ID__c adServerID = cls_P7S1_TestData.createTestAdServerID(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(true);
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
        placement.SomDig_AdServerID__c = adServerID.Id;
        insert placement;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.startTest();

        List<ADvendio__AdServer_ID_AdSpec_Assigment__c> assignments = [
            SELECT Id, ADvendio__AdServer_ID__c
              FROM ADvendio__AdServer_ID_AdSpec_Assigment__c
             WHERE ADvendio__Ad_Spec__c = :adSpec.Id];
        System.assertEquals(1, assignments.size());
        System.assertEquals(adServerID.Id, assignments[0].ADvendio__AdServer_ID__c);

        placement.SomDig_AdServerID__c = null;
        update placement;

        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM ADvendio__AdServer_ID_AdSpec_Assigment__c WHERE ADvendio__Ad_Spec__c = :adSpec.Id]);
    }

}