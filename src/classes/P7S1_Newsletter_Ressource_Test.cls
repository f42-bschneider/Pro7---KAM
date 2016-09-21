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
private class P7S1_Newsletter_Ressource_Test {

    static testmethod void subscribeEmail(){

        P7S1_Liferay_TestDataGenerator.createAll();

        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c (P7S1_Email__c = 'test@ambuorg.de', P7S1_Portal__c = P7S1_Liferay_Constants.PORTAL_ADFACTORY, P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_ADFACTORY_ACTIVE);
        insert portalLogin;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueof( '{"newsletterSubscribeUrl":"https://foobar.com/subscibeUrl"}' ); // Add JSON Message as a POST
        restRequest.requestURI = 'https://p7s1--LR2SF.cs83.my.salesforce.com/services/apexrest/newsletter/'+ P7S1_Liferay_Constants.NEWSLETTER_ACTION_SUBSCRIBE_EMAIL + '/'+ portalLogin.Id;

        RestContext.request = restRequest;

        String postNewsletterResponse = P7S1_Newsletter_Ressource.postNewsletter();
        system.assert(postNewsletterResponse != null);
        system.assertEquals('success', postNewsletterResponse);

        /*** check new status is set in database ***/
        P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_NewsletterSubscribeLink__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
        system.assertEquals('https://foobar.com/subscibeUrl', portalLoginFromDB.P7S1_NewsletterSubscribeLink__c);

        /*** check if the right event objects are written ***/
        List<P7S1_PortalLoginEvent__c> portalLoginEvents =  [   SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c
                                                                WHERE P7S1_PortalLogin__c = :portalLogin.Id];

        system.assert(portalLoginEvents != null);
        system.assertEquals(1, portalLoginEvents.size());

        /*** subscibed to newsletter ***/
        system.assert(portalLoginEvents.get(0) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(0).P7S1_PortalLogin__c);
        system.assertEquals(portalLoginEvents.get(0).P7S1_Successful__c, true);
        system.assertEquals(portalLoginEvents.get(0).P7S1_EventType__c, P7S1_Liferay_Constants.PORTAL_EVENT_NEWSLETTER_SUBSCRIBE_CONFIRM_SEND);
        system.assert(portalLoginEvents.get(0).P7S1_EventTimestamp__c != null);
        system.assertEquals(null,portalLoginEvents.get(0).P7S1_EventMessage__c);

    }
}