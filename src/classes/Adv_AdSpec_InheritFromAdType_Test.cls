@isTest
private with sharing class Adv_AdSpec_InheritFromAdType_Test {

    static testMethod void adSpecInsertShouldInheritValues() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(false);
        adType.SomDig_FcMenge__c = 1;
        adType.SomDig_FcPeriode__c = 'Tag';
        insert adType;

        Test.startTest();

        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.stopTest();

        adSpec = [SELECT ADvendio__FC_Quantity__c, ADvendio__FC_Period__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        System.assertEquals(1, adSpec.ADvendio__FC_Quantity__c);
        System.assertEquals('day', adSpec.ADvendio__FC_Period__c);
    }

    static testMethod void adSpecUpdateShouldNotInheritValues() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(false);
        adType.SomDig_FcMenge__c = 1;
        adType.SomDig_FcPeriode__c = 'Tag';
        insert adType;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.startTest();

        adSpec = [SELECT ADvendio__FC_Quantity__c, ADvendio__FC_Period__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        adSpec.ADvendio__FC_Quantity__c = 3;
        adSpec.ADvendio__FC_Period__c = 'week';
        update adSpec;

        Test.stopTest();

        adSpec = [SELECT ADvendio__FC_Quantity__c, ADvendio__FC_Period__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        System.assertEquals(3, adSpec.ADvendio__FC_Quantity__c);
        System.assertEquals('week', adSpec.ADvendio__FC_Period__c);
    }

    static testMethod void adTypeUpdateShouldUpdateValues() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(false);
        adType.SomDig_FcMenge__c = 1;
        adType.SomDig_FcPeriode__c = 'Tag';
        insert adType;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.startTest();

        adType.SomDig_FcMenge__c = 2;
        adType.SomDig_FcPeriode__c = 'Stunde';
        update adType;

        Test.stopTest();

        adSpec = [SELECT ADvendio__FC_Quantity__c, ADvendio__FC_Period__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        System.assertEquals(2, adSpec.ADvendio__FC_Quantity__c);
        System.assertEquals('hour', adSpec.ADvendio__FC_Period__c);
    }

    static testMethod void adTypeUpdateShouldOnlyUpdateChangedValues() {
        ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(true);
        ADvendio__Ad_Type__c adType = cls_P7S1_TestData.createTestAdType(false);
        adType.SomDig_FcMenge__c = 1;
        adType.SomDig_FcPeriode__c = 'Tag';
        insert adType;
        ADvendio__Ad_Specs__c adSpec = cls_P7S1_TestData.createTestAdSpec(true, placement, adType);

        Test.startTest();

        adSpec = [SELECT ADvendio__FC_Quantity__c, ADvendio__FC_Period__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        adSpec.ADvendio__FC_Quantity__c = 5;
        update adSpec;

        adType.SomDig_FcPeriode__c = 'Woche';
        update adType;

        Test.stopTest();

        adSpec = [SELECT ADvendio__FC_Quantity__c, ADvendio__FC_Period__c FROM ADvendio__Ad_Specs__c WHERE Id = :adSpec.Id];
        System.assertEquals(5, adSpec.ADvendio__FC_Quantity__c);
        System.assertEquals('week', adSpec.ADvendio__FC_Period__c);
    }

}