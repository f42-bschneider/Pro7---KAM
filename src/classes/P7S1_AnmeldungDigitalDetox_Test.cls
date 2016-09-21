@isTest
private class P7S1_AnmeldungDigitalDetox_Test {

    @testSetup
    public static void  prepareData() {
        Campaign newCampaign = new Campaign();
        newCampaign.Name = 'Campaign 1';
        insert newCampaign;

        Contact aContact = new Contact();
        aContact.FirstName = 'First';
        aContact.LastName = 'Last';
        aContact.email = 'test@test.com';
        insert aContact;

        CampaignMember member = new CampaignMember();
        member.Campaignid = newCampaign.Id;
        member.ContactId = aContact.Id;
        insert member;

        P7S1_B2BAktionsmitgliederFeedback__c feedback = new P7S1_B2BAktionsmitgliederFeedback__c();
        feedback.P7S1_B2BAktionsmitgliedID__c = String.valueOf(member.id).substring(0,15);
        feedback.P7S1_Registrierungscode__c = '12345';
        feedback.P7S1_Anrede__c = 'Dear';
        feedback.P7S1_Contact__c = aContact.Id;
        feedback.P7S1_EMail__c = aContact.Email;
        insert feedback;


    }


    static testmethod void test_P7S1_AnmeldungDigitalDetoxController() {

        Test.setCurrentPage(Page.P7S1_AnmeldungDigitalDetox);

        ApexPages.currentPage().getParameters().put('code', '12345');

        P7S1_AnmeldungDigitalDetox_Controller controller = new P7S1_AnmeldungDigitalDetox_Controller();

        controller.increaseWizardPageNumber();
        controller.decreaseWizardPageNumber();
        System.assertNotEquals(null, controller.feedback);
        System.assertNotEquals(null, controller.wizardpageNumber);
        controller.setCodeNumber();
        System.assertNotEquals(null, controller.code);
        System.assertEquals(null, controller.email);
        System.assertNotEquals(null, controller.language);

        ApexPages.currentPage().getParameters().put('code', '123456');

        controller = new P7S1_AnmeldungDigitalDetox_Controller();

    }

    static testmethod void test_P7S1_AnmeldungDigitalDetoxNienController() {

        Test.setCurrentPage(Page.P7S1_AnmeldungDigitalDetox_Absage);

        ApexPages.currentPage().getParameters().put('code', '12345');

        P7S1_AnmeldungDigitalDetox_Absage controller = new P7S1_AnmeldungDigitalDetox_Absage();

        System.assertNotEquals(null, controller.feedback);
        System.assertNotEquals(null, controller.language);

        ApexPages.currentPage().getParameters().put('code', '123456');

        controller = new P7S1_AnmeldungDigitalDetox_Absage();

    }

    static testmethod void test_P7S1_ComponentController() {

        P7S1_AnmeldungDigitalDetox_Components controller = new P7S1_AnmeldungDigitalDetox_Components();
        controller.code = '12345';
        controller.email = 'test@test.com';

        System.assertNotEquals(null, controller.sobjectRecord);
        System.assertNotEquals(null, controller.language);
        controller.updateRecord();
        controller.searchrecord();

        controller = new P7S1_AnmeldungDigitalDetox_Components();
        System.assertNotEquals(null, controller.sobjectRecord);
    }

}