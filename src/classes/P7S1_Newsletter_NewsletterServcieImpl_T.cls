/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class P7S1_Newsletter_NewsletterServcieImpl_T {

	static testMethod void init(){
		Test.startTest();
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      	P7S1_Newsletter_NewsletterServcie newsletterService = new P7S1_Newsletter_NewsletterServcieImpl();
      	system.assert( newsletterService != null );
      	Test.stopTest();
    }
    
	static testMethod void getStandardNewsletter(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		String newsletterIdLiferay = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayDefaultNewsletter__c;
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
		
		Test.startTest();
      	P7S1_Newsletter_NewsletterServcie newsletterService = new P7S1_Newsletter_NewsletterServcieImpl();
      	system.assertEquals( newsletterIdLiferay, newsletterService.getStandardNewsletter(portalLogin).Id );
      	
      	Test.stopTest();
    }
    
	static testMethod void createOrGetNewsletterAbo(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		String newsletterIdLiferay = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayDefaultNewsletter__c;
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
		
		Test.startTest();
      	P7S1_Newsletter_NewsletterServcie newsletterService = new P7S1_Newsletter_NewsletterServcieImpl();
      	P7S1_Abonnement__c abo = newsletterService.createOrGetNewsletterAbo(portalLogin);
      	system.assert( abo != null );
      	system.assert( abo.Id != null );
      	system.assert( abo.P7S1_AbgeschlossenAm__c != null );
      	
      	Test.stopTest();
    }
    
	static testMethod void subscribe(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		String newsletterIdLiferay = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayDefaultNewsletter__c;
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
		
		Test.startTest();
      	P7S1_Newsletter_NewsletterServcie newsletterService = new P7S1_Newsletter_NewsletterServcieImpl();
      	P7S1_Abonnement__c abo = newsletterService.createOrGetNewsletterAbo(portalLogin);
      	system.assert( abo != null );
      	system.assert( abo.Id != null );
      	system.assert( abo.P7S1_AbgeschlossenAm__c != null );
      	Datetime oldDate = abo.P7S1_AbgeschlossenAm__c;
      	
      	system.assertEquals( true, newsletterService.subscribe(abo) );
      	system.assert( abo.P7S1_AbgeschlossenAm__c > oldDate );
      	
      	Test.stopTest();
    }
    
	static testMethod void unsubscribe(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		String newsletterIdLiferay = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayDefaultNewsletter__c;
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
		
		Test.startTest();
      	P7S1_Newsletter_NewsletterServcie newsletterService = new P7S1_Newsletter_NewsletterServcieImpl();
      	P7S1_Abonnement__c abo = newsletterService.createOrGetNewsletterAbo(portalLogin);
      	system.assert( abo != null );
      	system.assert( abo.Id != null );
      	system.assert( abo.P7S1_AbgeschlossenAm__c != null );
      	system.assertEquals( null, abo.P7S1_Kuendigungsdatum__c );
      	
      	system.assertEquals( true, newsletterService.unsubscribe(abo) );
      	system.assert( null != abo.P7S1_Kuendigungsdatum__c );
      	
      	Test.stopTest();
    }
    
	static testMethod void sendNewsletterSubscribeEmail(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		String newsletterIdLiferay = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayDefaultNewsletter__c;
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
		portalLogin.P7S1_Portal__c = P7S1_Liferay_Constants.PORTAL_ADFACTORY;
		insert portalLogin;
		
		Test.startTest();
      	P7S1_Newsletter_NewsletterServcie newsletterService = new P7S1_Newsletter_NewsletterServcieImpl();
      	P7S1_PortalLoginEvent__c ple = newsletterService.sendNewsletterSubscribeEmail(portalLogin);
      	system.assert( ple != null );
      	system.assertEquals( true, ple.P7S1_Successful__c );
      	
      	Test.stopTest();
    }
}