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
private class P7S1_Newsletter_SiteController_Test {

    static testMethod void unsubscibeNewsletter() {
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
    	P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
    	portalLogin.P7S1_Portal__c = P7S1_Liferay_Constants.PORTAL_ADFACTORY;
    	insert portalLogin;
    	
		String newsletterIdLiferay = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayDefaultNewsletter__c; 
    	String newsletterUnsubscribe_Url = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_Newsletter_Unsubscribe_Url__c;
		P7S1_Abonnement__c abo = P7S1_Liferay_TestDataGenerator.createAbonnement(portalLogin, newsletterIdLiferay, newsletterUnsubscribe_Url, true);
		ApexPages.currentPage().getParameters().put('abonnementId', abo.Id);
		
		Test.startTest();
    	P7S1_Newsletter_SiteController controller = new P7S1_Newsletter_SiteController();
    	system.assertEquals(Label.P7S1_SITE_NEWSLETTER_UNSUBSCRIBE_FAILED, controller.msg);
    	system.assertEquals(null, controller.abonnement.P7S1_Kuendigungsdatum__c);
    	system.assertEquals(null, controller.errorCode);
    	controller.unsubscibeNewsletter();
    	system.assertEquals(Label.P7S1_SITE_NEWSLETTER_UNSUBSCRIBE_FAILED, controller.msg);
    	system.assert(null != controller.abonnement.P7S1_Kuendigungsdatum__c);
    	system.assertEquals(null, controller.errorCode);
        Test.stopTest();
    }
    
    static testMethod void unsubscibeNewsletterFail() {
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
    	P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
    	portalLogin.P7S1_Portal__c = P7S1_Liferay_Constants.PORTAL_ADFACTORY;
    	insert portalLogin;
		String newsletterIdLiferay = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayDefaultNewsletter__c; 
    	String newsletterUnsubscribe_Url = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_Newsletter_Unsubscribe_Url__c;
		ApexPages.currentPage().getParameters().put('abonnementId', '123456789');
		
		Test.startTest();
    	P7S1_Newsletter_SiteController controller = new P7S1_Newsletter_SiteController();
    	system.assertEquals(Label.P7S1_SITE_NEWSLETTER_UNSUBSCRIBE_FAILED, controller.msg);
    	system.assertEquals(null, controller.abonnement.P7S1_Kuendigungsdatum__c);
    	system.assertEquals(null, controller.errorCode);
    	controller.unsubscibeNewsletter();
    	system.assertEquals(Label.P7S1_SITE_NEWSLETTER_UNSUBSCRIBE_FAILED+'123456789', controller.msg);
    	system.assertEquals(null, controller.abonnement);
    	system.assert(null != controller.errorCode);
        Test.stopTest();
    }
    
}