@isTest
private class SomTv_OLI_Geschaeftsart_Test {

    static testMethod void insertOfOLIShouldNotConsiderMotherOpportunity_1() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity opportunity = cls_P7S1_TestData.createTestOpportunity(true, account);

        Test.startTest();

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, opportunity);
        // Should be '1130' because the OLI has no mother-opp
        System.assertEquals('1130', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }

    static testMethod void insertOfOLIShouldNotConsiderMotherOpportunity_2() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity mother_opportunity = cls_P7S1_TestData.createTestOpportunity(true, account);
        Opportunity child_opportunity = cls_P7S1_TestData.createTestOpportunity(false, account);
        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity.Id;
        insert child_opportunity;

        Test.startTest();

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, child_opportunity);
        // Should be '1130' because the mother-opp does not have recordtype 'SomTv_Commitment' or 'SomTv_Zubuchung'
        System.assertEquals('1130', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }

    static testMethod void insertOfOLIShouldNotConsiderMotherOpportunity_3() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity mother_opportunity = cls_P7S1_TestData.createTestOpportunity(true, account, cls_P7S1_Utils.getRecordType('Opportunity', 'SomTv_Commitment'));
        Opportunity child_opportunity = cls_P7S1_TestData.createTestOpportunity(false, account);
        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity.Id;
        insert child_opportunity;

        Test.startTest();

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(false, child_opportunity);
        oli.SomTv_GaSonder__c = '1194';
        insert oli;
        // Should be '1194' because SomTv_GaSonder__c (set via workflow field update) is considered before Product2.SomTv_GAinnerhalbCommitment__c
        System.assertEquals('1194', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }

    static testMethod void insertOfOLIShouldConsiderMotherOpportunity_1() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity mother_opportunity = cls_P7S1_TestData.createTestOpportunity(true, account, cls_P7S1_Utils.getRecordType('Opportunity', 'SomTv_Commitment'));
        Opportunity child_opportunity = cls_P7S1_TestData.createTestOpportunity(false, account);
        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity.Id;
        insert child_opportunity;

        Test.startTest();

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, child_opportunity);
        // Should be '1104' because there is no workflow update and the mother-opp has recordtype 'SomTv_Commitment'
        System.assertEquals('1104', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }

    static testMethod void insertOfOLIShouldConsiderMotherOpportunity_2() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity mother_opportunity = cls_P7S1_TestData.createTestOpportunity(true, account, cls_P7S1_Utils.getRecordType('Opportunity', 'SomTv_Zubuchung'));
        Opportunity child_opportunity = cls_P7S1_TestData.createTestOpportunity(false, account);
        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity.Id;
        insert child_opportunity;

        Test.startTest();

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, child_opportunity);
        // Should be '1104' because there is no workflow update and the mother-opp has recordtype 'SomTv_Zubuchung'
        System.assertEquals('1104', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }



    static testMethod void updateOfMotherOpportunityShouldNotUpdateOLIs() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity mother_opportunity = cls_P7S1_TestData.createTestOpportunity(true, account);
        Opportunity child_opportunity = cls_P7S1_TestData.createTestOpportunity(false, account);
        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity.Id;
        insert child_opportunity;

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, child_opportunity);
        System.assertEquals('1130', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.startTest();

        mother_opportunity.RecordTypeId = cls_P7S1_Utils.getRecordTypeId('Opportunity', 'SomTv_AdFactory');
        update mother_opportunity;
        // Should be '1130' because the mother-opp's new record type is not relevant for a field update
        System.assertEquals('1130', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }

    static testMethod void updateOfMotherOpportunityShouldUpdateOLIs() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity mother_opportunity = cls_P7S1_TestData.createTestOpportunity(true, account);
        Opportunity child_opportunity = cls_P7S1_TestData.createTestOpportunity(false, account);
        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity.Id;
        insert child_opportunity;

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, child_opportunity);
        System.assertEquals('1130', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.startTest();

        mother_opportunity.RecordTypeId = cls_P7S1_Utils.getRecordTypeId('Opportunity', 'SomTv_Zubuchung');
        update mother_opportunity;
        // Should be '1104' because the mother-opp was updated to have a record type relevant for Product2.SomTv_GAinnerhalbCommitment__c
        System.assertEquals('1104', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }



    static testMethod void switchOfMotherOpportunityShouldNotUpdateOLIs() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity mother_opportunity_1 = cls_P7S1_TestData.createTestOpportunity(true, account);
        Opportunity mother_opportunity_2 = cls_P7S1_TestData.createTestOpportunity(true, account, cls_P7S1_Utils.getRecordType('Opportunity', 'SomTv_AdFactory'));
        Opportunity child_opportunity = cls_P7S1_TestData.createTestOpportunity(false, account);
        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity_1.Id;
        insert child_opportunity;

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, child_opportunity);
        System.assertEquals('1130', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.startTest();

        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity_2.Id;
        update child_opportunity;
        // Should be '1130' because the new mother-opp is not relevant for a field update
        System.assertEquals('1130', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }

    static testMethod void switchOfMotherOpportunityShouldUpdateOLIs_1() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity mother_opportunity_1 = cls_P7S1_TestData.createTestOpportunity(true, account);
        Opportunity mother_opportunity_2 = cls_P7S1_TestData.createTestOpportunity(true, account, cls_P7S1_Utils.getRecordType('Opportunity', 'SomTv_Commitment'));
        Opportunity child_opportunity = cls_P7S1_TestData.createTestOpportunity(false, account);
        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity_1.Id;
        insert child_opportunity;

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, child_opportunity);
        System.assertEquals('1130', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.startTest();

        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity_2.Id;
        update child_opportunity;
        // Should be '1104' because the new mother-opp has a record type relevant for Product2.SomTv_GAinnerhalbCommitment__c
        System.assertEquals('1104', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }

    static testMethod void switchOfMotherOpportunityShouldUpdateOLIs_2() {
        Account account = cls_P7S1_TestData.createTestAccount(true);
        Opportunity mother_opportunity_1 = cls_P7S1_TestData.createTestOpportunity(true, account, cls_P7S1_Utils.getRecordType('Opportunity', 'SomTv_Commitment'));
        Opportunity mother_opportunity_2 = cls_P7S1_TestData.createTestOpportunity(true, account);
        Opportunity child_opportunity = cls_P7S1_TestData.createTestOpportunity(false, account);
        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity_1.Id;
        insert child_opportunity;

        OpportunityLineItem oli = cls_P7S1_TestData.createTestOpportunityLineItem(true, child_opportunity);
        System.assertEquals('1104', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.startTest();

        child_opportunity.SomTv_MutterOpportunity__c = mother_opportunity_2.Id;
        update child_opportunity;
        // Should be '1130' because the old mother-opp had a record type relevant for Product2.SomTv_GAinnerhalbCommitment__c, and the new mother-opp doesn't
        System.assertEquals('1130', [SELECT Id, SomTv_Geschaeftsart__c FROM OpportunityLineItem WHERE Id = :oli.Id].SomTv_Geschaeftsart__c);

        Test.stopTest();
    }

}