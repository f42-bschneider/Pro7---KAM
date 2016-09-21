@isTest
public without sharing class P7S1_NLP_PortalPageControllerTest {

    public static final Integer numberOfActiveNewsletters = 9;
    public static final String SITE_USER_PROFILE_NAME = 'P7S1 Newsletter Portal Profile';
    public static final User SITE_USER = [SELECT ID FROM User WHERE Profile.Name = :SITE_USER_PROFILE_NAME LIMIT 1];
    
    @TestSetup
    public static void setUpData()
    {
        Account acc = cls_P7S1_TestData.createTestAccount(true, NULL, NULL);
        Contact cont = cls_P7S1_TestData.createTestContact(true, acc);
        P7S1_PortalLogin__c login = new P7S1_PortalLogin__c();
        login.P7S1_EMail__c = 'a@b.c';
        login.P7S1_Contact__c = cont.id;
        insert login;
        
        
        P7S1_Newsletter__c sampleNl = new P7S1_Newsletter__c();
        sampleNl.P7S1_Beschreibung__c = 'A Test Newsletter';
        sampleNl.P7S1_Version__c = 'E-Mail';
        sampleNl.P7S1_Frequenz__c = 'wöchentlich';
        sampleNl.P7S1_Sortierung__c = 1;
        sampleNl.P7S1_StartDatum__c = Date.today().addDays(-14);
        sampleNl.P7S1_EndDatum__c = Date.today().addDays(14);
        sampleNl.P7S1_Textfett__c = false;
        sampleNl.P7S1_Textfarbe__c = '000000';

        
        List<P7S1_Newsletter__c> newsletters = new List<P7S1_Newsletter__c>();
        
		while(newsletters.size() < numberOfActiveNewsletters) 
        {
            P7S1_Newsletter__c nl = sampleNl.clone();
        	nl.P7S1_Sortierung__c = newsletters.size()+1;
            nl.Name = 'Newsletter'+newsletters.size();
            if(Math.mod(newsletters.size(), 3) == 0)
                nl.P7S1_Kategorie__c = 'Newsletter';
            if(Math.mod(newsletters.size(), 3) == 1)
                nl.P7S1_Kategorie__c = 'Specials';
            if(Math.mod(newsletters.size(), 3) == 2)
                nl.P7S1_Kategorie__c = 'Sender';
            newsletters.add(nl);
        }
        
        //already inactive Newsletter => shoud never be returned
        P7S1_Newsletter__c oldNl = sampleNl.clone();
        oldNl.P7S1_EndDatum__c = Date.today().addDays(-7);
        oldNl.P7S1_Sortierung__c = -100;
        oldNl.Name = 'Depricated Newsletter';
        oldNl.P7S1_Kategorie__c = 'Newsletter';
        newsletters.add(oldNl);
        
        //not yet active Newsletter => shoud never be returned
        P7S1_Newsletter__c newNl = sampleNl.clone();
        newNl.P7S1_StartDatum__c = Date.today().addDays(7);
        newNl.P7S1_Sortierung__c = 100;
        newNl.Name = 'Future Newsletter';
        newNl.P7S1_Kategorie__c = 'Newsletter';
        newsletters.add(newNl);
              
        
        insert newsletters;
    }
    
    @isTest
    public static void testEncryptionBidirectional()
    {
        ID poralId = [SELECT id FROM P7S1_PortalLogin__c LIMIT 1].id;
        String encriptedId = P7S1_NLP_PortalPageController.encryptId(poralId);
        ID decryptedId = P7S1_NLP_PortalPageController.decryptId(encriptedId);
        system.assertEquals(poralId,decryptedId);
    }
    
    @isTest
    public static void testLoading()
    {
        P7S1_PortalLogin__c login = [SELECT id, P7S1_Email__c FROM P7S1_PortalLogin__c];
        System.PageReference portalpage = Page.P7S1_NLP_PortalPage;
        portalpage.getParameters().put('pid',P7S1_NLP_PortalPageController.encryptId(login.id));
        Test.startTest();
        P7S1_NLP_PortalPageController ctrl = NULL;
        system.runAs(SITE_USER)
        {
            Test.setCurrentPage(portalpage);
            ctrl =  new P7S1_NLP_PortalPageController();
        }
        Test.stopTest();
        system.assertEquals(login.Id, ctrl.portalLoginId);
        system.assertEquals(login.P7S1_Email__c, ctrl.getLoginEmail());
        
    }
    
    @isTest
    public static void testNewsletterActiveCheck()
    {
        List<P7S1_Newsletter__c> newsletters = [SELECT Id, name, P7S1_Startdatum__c, P7S1_Enddatum__c, P7S1_Kategorie__c, P7S1_Beschreibung__c, P7S1_Frequenz__c, P7S1_Version__c, P7S1_Aktiv__c FROM P7S1_Newsletter__c order by P7S1_EndDatum__c, P7S1_Startdatum__c];
        system.assertEquals(numberOfActiveNewsletters+2, newsletters.size());
        
        P7S1_Newsletter__c oldNl = newsletters[0];
        system.assertEquals(oldNl.P7S1_Enddatum__c, Date.today().addDays(-7));
        system.assert(!P7S1_NLP_PortalPageController.isNewsletterActive(oldNl));
        
        P7S1_Newsletter__c newNl = newsletters[newsletters.size()-1];
        system.assertEquals(newNl.P7S1_Startdatum__c, Date.today().addDays(7));
        system.assert(!P7S1_NLP_PortalPageController.isNewsletterActive(newNl));
        
        
        for(P7S1_Newsletter__c nl : newsletters)
        {
            if(nl.id == oldNl.Id || nl.id == newNl.Id) continue;
            system.assert(P7S1_NLP_PortalPageController.isNewsletterActive(nl));
        }
    }
    
    @isTest
    public static void testGetWrapperListsAreFilled()
    {
        P7S1_PortalLogin__c login = [SELECT id FROM P7S1_PortalLogin__c];
        Test.startTest();
	        P7S1_NLP_PortalPageController ctrl =  new P7S1_NLP_PortalPageController(login.id);
            List<P7S1_NLP_NewsletterWrapper> senderList = ctrl.getSender();
            List<P7S1_NLP_NewsletterWrapper> specialsList = ctrl.getSpecials();
            List<P7S1_NLP_NewsletterWrapper> newsletterList = ctrl.getNewsletters();
        Test.stopTest();
        system.assertEquals(3, senderList.size());
        system.assertEquals(3, specialsList.size());
        system.assertEquals(3, newsletterList.size());
    }
    
    
    private static P7S1_Abonnement__c createAbo(P7S1_Newsletter__c newsletter, P7S1_PortalLogin__c login)
    {
        P7S1_Abonnement__c result = new P7S1_Abonnement__c();
        result.P7S1_Contact__c = login.P7S1_Contact__c;
        result.P7S1_PortalLogin__c = login.Id;
        result.P7S1_Newsletter__c = newsletter.Id;
        return result;
    }
    
    @isTest
    public static void testWrapperAreCheckedCorrectlyAccordingToAbonements()
    {
        
        P7S1_PortalLogin__c login = [SELECT id, P7S1_Contact__c FROM P7S1_PortalLogin__c];
        P7S1_Newsletter__c specialNl = [SELECT ID FROM P7S1_Newsletter__c WHERE P7S1_Kategorie__c = 'Specials' LIMIT 1];
        P7S1_Newsletter__c senderNl = [SELECT ID FROM P7S1_Newsletter__c WHERE P7S1_Kategorie__c = 'Sender' LIMIT 1];
        P7S1_Newsletter__c newsletterNl = [SELECT ID FROM P7S1_Newsletter__c WHERE P7S1_Kategorie__c = 'Newsletter' LIMIT 1];
        
        P7S1_Abonnement__c specialAbo = createAbo(specialNl, login);
        specialAbo.P7S1_AbgeschlossenAm__c = Date.today().addDays(-3);
        
        P7S1_Abonnement__c senderAbo = createAbo(senderNl, login);
        senderAbo.P7S1_AbgeschlossenAm__c = Date.today().addDays(-3);
        senderAbo.P7S1_Kuendigungsdatum__c = Date.today().addDays(-1);
        
        insert new List<P7S1_Abonnement__c>{specialAbo, senderAbo};
        
            
        P7S1_NLP_PortalPageController ctrl = NULL;
        Test.startTest();
        System.runAs(SITE_USER)
        {
            ctrl = new P7S1_NLP_PortalPageController(login.Id);
        }
        Test.stopTest();

        for(P7S1_NLP_NewsletterWrapper wrapper : ctrl.getNewsletters())
        {
            if(wrapper.newsletter.Id != newsletterNl.Id) continue;
            system.assert(wrapper.abonement == NULL);
            system.assert(wrapper.isChecked == FALSE);            
        }
        for(P7S1_NLP_NewsletterWrapper wrapper : ctrl.getSender())
        {
            if(wrapper.newsletter.Id != senderNl.Id) continue;
            system.assert(wrapper.abonement != NULL);
            system.assert(wrapper.isChecked == FALSE);            
        }
        
        P7S1_NLP_NewsletterWrapper testWrapperForGetterMethods;
        for(P7S1_NLP_NewsletterWrapper wrapper : ctrl.getSpecials())
        {
            if(wrapper.newsletter.Id != specialNl.Id) continue;
            
            system.assert(wrapper.abonement != NULL);
            system.assert(wrapper.isChecked == TRUE);
            system.assertNotEquals(NULL, wrapper.toString());
            system.assertNotEquals(NULL, wrapper.Name);
            system.assertNotEquals(NULL, wrapper.Beschreibung);
            system.assertNotEquals(NULL, wrapper.Frequenz);
            system.assertNotEquals(NULL, wrapper.Version);
            system.assertNotEquals(NULL, wrapper.TextFarbe);
            system.assertNotEquals(NULL, wrapper.Textfett);
            
        }
        
    }
    
    @isTest
    public static void testWrappersAddThemselfesToChangeHandler()
    {
        P7S1_PortalLogin__c login = [SELECT id, P7S1_Contact__c FROM P7S1_PortalLogin__c];
        P7S1_NLP_PortalPageController ctrl =  new P7S1_NLP_PortalPageController(login.id);
        
        List<P7S1_NLP_NewsletterWrapper> senderList = ctrl.getSender();
        List<P7S1_NLP_NewsletterWrapper> specialsList = ctrl.getSpecials();
        List<P7S1_NLP_NewsletterWrapper> newsletterList = ctrl.getNewsletters();
        
        P7S1_NLP_NewsletterWrapper senderNlWrapper = senderList[0];
        P7S1_NLP_NewsletterWrapper specialNlWrapper = specialsList[0];
        P7S1_NLP_NewsletterWrapper newsletterNlWrapper = newsletterList[0];
        Test.startTest();
            senderNlWrapper.isChecked = true;
            specialNlWrapper.isChecked = true;
            newsletterNlWrapper.isChecked = true;
            newsletterNlWrapper.isChecked = false;
            newsletterNlWrapper.isChecked = true;
        Test.stopTest();
        
        system.assertEquals(3,ctrl.changeHandler.changedWrappers.size());
        system.assert(ctrl.changeHandler.changedWrappers.contains(senderNlWrapper));
        system.assert(ctrl.changeHandler.changedWrappers.contains(specialNlWrapper));
        system.assert(ctrl.changeHandler.changedWrappers.contains(newsletterNlWrapper));
    }
      
    
    // this Test repesents an End-To-End Test
    @isTest
    public static void testAbonementsAreModified()
    {
        P7S1_PortalLogin__c login = [SELECT id, P7S1_Contact__c FROM P7S1_PortalLogin__c];
        P7S1_Newsletter__c specialNl = [SELECT ID FROM P7S1_Newsletter__c WHERE P7S1_Kategorie__c = 'Specials' LIMIT 1];
        P7S1_Newsletter__c senderNl = [SELECT ID FROM P7S1_Newsletter__c WHERE P7S1_Kategorie__c = 'Sender' LIMIT 1];
        P7S1_Newsletter__c newsletterNl = [SELECT ID FROM P7S1_Newsletter__c WHERE P7S1_Kategorie__c = 'Newsletter' LIMIT 1];
        
        P7S1_Abonnement__c specialAbo = createAbo(specialNl, login);
        specialAbo.P7S1_AbgeschlossenAm__c = Date.today().addDays(-3);
        
        P7S1_Abonnement__c senderAbo = createAbo(senderNl, login);
        senderAbo.P7S1_AbgeschlossenAm__c = Date.today().addDays(-3);
        senderAbo.P7S1_Kuendigungsdatum__c = Date.today().addDays(-1);
        
        insert new List<P7S1_Abonnement__c>{specialAbo, senderAbo};
            
        Datetime savetime;
            
        Test.startTest();
        System.runAs(SITE_USER)
        {
            P7S1_NLP_PortalPageController ctrl = new P7S1_NLP_PortalPageController(login.Id);
            for(P7S1_NLP_NewsletterWrapper wrapper : ctrl.getNewsletters())
            {
                if(wrapper.newsletter.Id != newsletterNl.Id) continue;
                wrapper.isChecked = !wrapper.isChecked;
            }
                
            for(P7S1_NLP_NewsletterWrapper wrapper : ctrl.getSender())
            {
                if(wrapper.newsletter.Id != senderNl.Id) continue;
                wrapper.isChecked = !wrapper.isChecked;
            }
                
            for(P7S1_NLP_NewsletterWrapper wrapper : ctrl.getSpecials())
            {
                if(wrapper.newsletter.Id != specialNl.Id) continue;
                wrapper.isChecked = !wrapper.isChecked;   
            }
            system.assertEquals(3, ctrl.changeHandler.changedWrappers.size());
            savetime = DateTime.now();
            ctrl.save();
        }
        Test.stopTest();
        
        P7S1_Abonnement__c testSenderAbo = NULL;
        P7S1_Abonnement__c testSpecialAbo = NULL;
        P7S1_Abonnement__c testNewsletterAbo = NULL;
        List<P7S1_Abonnement__c> abos = [SELECT Id, P7S1_AbgeschlossenAm__c, P7S1_Kuendigungsdatum__c, P7S1_Newsletter__c FROM P7S1_Abonnement__c WHERE P7S1_PortalLogin__c = :login.id];
        system.assertEquals(3, abos.size());
        for(P7S1_Abonnement__c abo : abos)
        {
            if(abo.P7S1_Newsletter__c == senderNl.id)
                testSenderAbo = abo;
            if(abo.P7S1_Newsletter__c == specialNl.id)
                testSpecialAbo = abo;
            if(abo.P7S1_Newsletter__c == newsletterNl.id)
                testNewsletterAbo = abo;
        }
	
        system.assertNotEquals(NULL, testSenderAbo);
        system.assertEquals(savetime, testSenderAbo.P7S1_AbgeschlossenAm__c);
        system.assertEquals(NULL, testSenderAbo.P7S1_Kuendigungsdatum__c);
        
        system.assertNotEquals(NULL, testSpecialAbo);
        system.assertNotEquals(NULL, testSpecialAbo.P7S1_Kuendigungsdatum__c);
        
        system.assertNotEquals(NULL, testNewsletterAbo);
        system.assertEquals(savetime, testNewsletterAbo.P7S1_AbgeschlossenAm__c);
        system.assertEquals(NULL, testNewsletterAbo.P7S1_Kuendigungsdatum__c);
    }
}