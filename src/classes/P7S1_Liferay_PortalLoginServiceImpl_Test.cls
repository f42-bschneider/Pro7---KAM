/**
* This is the Testclass for P7S1_Liferay_PortalLoginService
*
* @author  Sebastian Listl
* @version 0.1, 2014-08-31
* @see  P7S1_Liferay_PortalLoginService
*/
@isTest
private class P7S1_Liferay_PortalLoginServiceImpl_Test {

    /**
  	* Tests the initialization of the APEX class
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
    static testMethod void init(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      	P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();
      	system.assert ( portalLoginService != null );
    }

    /**
  * Tests the activation of the portalLoginUser in salesforce.
  * @since 0.1
   */
    static testMethod void activatePortalLoginUserSF(){
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();
      P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);

      Test.startTest();

        portalLoginService.activatePortalLoginUserSF( portalLogin );

        P7S1_PortalLogin__c portalLoginFromDb =  [Select Id, P7S1_Portal_Status__c FROM P7S1_PortalLogin__c WHERE id = :portalLogin.id];
        system.assert ( portalLoginFromDb != null);
        system.assertEquals( P7S1_Liferay_Constants.PORTAL_STATUS_ACTIVE, portalLoginFromDb.P7S1_Portal_Status__c );

        P7S1_PortalLoginEvent__c portalLoginEvent = [Select Id, P7S1_EventType__c, P7S1_PortalLogin__c,P7S1_Successful__c, P7S1_EventTimestamp__c FROM P7S1_PortalLoginEvent__c];
        system.assert ( portalLoginEvent != null);
        system.assertEquals ( portalLogin.Id, portalLoginEvent.P7S1_PortalLogin__c );
        system.assert( portalLoginEvent.P7S1_Successful__c );
        system.assertEquals ( P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_SF, portalLoginEvent.P7S1_EventType__c );


      Test.stopTest();

    }

    /**
  * Tests the activation of the portalLoginUser for sevenonmedia
  * @since 0.1
   */
    static testMethod void activatePortalLoginUserLiferay(){
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();

      P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
      portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_ACTIVE;
      insert portalLogin;
      system.assert ( portalLogin != null);
      system.assertEquals( P7S1_Liferay_Constants.PORTAL_STATUS_ACTIVE, portalLogin.P7S1_Portal_Status__c );

      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(P7S1_Liferay_RestService_Test.LIFERAY_USER_JSON_ACTIVATE, P7S1_Liferay_RestService_Test.LIFERAY_RESP_SUCCESS ));

        portalLoginService.activatePortalLoginUserLiferay( portalLogin );
        P7S1_PortalLogin__c portalLoginFromDb =  [Select Id, P7S1_Portal_Status__c FROM P7S1_PortalLogin__c WHERE id = :portalLogin.id];
        system.assert ( portalLoginFromDb != null);
        system.assertEquals( P7S1_Liferay_Constants.PORTAL_STATUS_LIFERAY_ACTIVE, portalLoginFromDb.P7S1_Portal_Status__c );

        List<P7S1_PortalLoginEvent__c> portalLoginEvents = [Select Id, P7S1_EventType__c, P7S1_PortalLogin__c,P7S1_Successful__c FROM P7S1_PortalLoginEvent__c ORDER BY P7S1_EventTimestamp__c];

        system.assert ( portalLoginEvents != null);
        system.assertEquals ( 2, portalLoginEvents.size() );

        system.assertEquals ( portalLogin.Id, portalLoginEvents.get(0).P7S1_PortalLogin__c );
        system.assertEquals ( portalLogin.Id, portalLoginEvents.get(1).P7S1_PortalLogin__c );

        system.assert( portalLoginEvents.get(0).P7S1_Successful__c );
        system.assert( portalLoginEvents.get(1).P7S1_Successful__c );

        system.assertEquals ( P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_LR, portalLoginEvents.get(0).P7S1_EventType__c );
        system.assertEquals ( P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_WELCOME, portalLoginEvents.get(1).P7S1_EventType__c );
      Test.stopTest();
    }

    /**
  * Tests the activation of the portalLoginUser for adfactory
  * @since 0.1
   */
    static testMethod void activatePortalLoginUserAdfactory(){
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();

      P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
      portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_ACTIVE;
      portalLogin.P7S1_Portal__c=P7S1_Liferay_Constants.PORTAL_ADFACTORY;
      insert portalLogin;
      system.assert ( portalLogin != null);
      system.assertEquals( P7S1_Liferay_Constants.PORTAL_STATUS_ACTIVE, portalLogin.P7S1_Portal_Status__c );
      system.assertEquals( P7S1_Liferay_Constants.PORTAL_ADFACTORY, portalLogin.P7S1_Portal__c );
      Test.startTest();
      //Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(P7S1_Liferay_RestService_Test.LIFERAY_USER_JSON_ACTIVATE, P7S1_Liferay_RestService_Test.LIFERAY_RESP_SUCCESS ));

        portalLoginService.activatePortalLoginUserLiferay( portalLogin );
        P7S1_PortalLogin__c portalLoginFromDb =  [Select Id, P7S1_Portal_Status__c FROM P7S1_PortalLogin__c WHERE id = :portalLogin.id];
        system.assert ( portalLoginFromDb != null);
        system.assertEquals( P7S1_Liferay_Constants.PORTAL_STATUS_ADFACTORY_ACTIVE, portalLoginFromDb.P7S1_Portal_Status__c );

        List<P7S1_PortalLoginEvent__c> portalLoginEvents = [Select Id, P7S1_EventType__c, P7S1_PortalLogin__c,P7S1_Successful__c FROM P7S1_PortalLoginEvent__c ORDER BY P7S1_EventTimestamp__c];

        system.assert ( portalLoginEvents != null);
        system.assertEquals ( 2, portalLoginEvents.size() );

        system.assertEquals ( portalLogin.Id, portalLoginEvents.get(0).P7S1_PortalLogin__c );
        system.assertEquals ( portalLogin.Id, portalLoginEvents.get(1).P7S1_PortalLogin__c );

        system.assert( portalLoginEvents.get(0).P7S1_Successful__c );
        system.assert( portalLoginEvents.get(1).P7S1_Successful__c );

        system.assertEquals ( P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_AF, portalLoginEvents.get(0).P7S1_EventType__c );
        system.assertEquals ( P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_WELCOME, portalLoginEvents.get(1).P7S1_EventType__c );
      Test.stopTest();
    }



    /**
  * Tests the activation mail to salesforce admin
  * @since 0.1
   */
    static testMethod void sendActivationEmailToAdmin(){
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();

      P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);

      Test.startTest();

      portalLoginService.sendActivationEmailToAdmin( portalLogin );

      P7S1_PortalLoginEvent__c portalLoginEvent = [Select Id, P7S1_EventType__c,P7S1_Successful__c, P7S1_PortalLogin__c,P7S1_EventMessage__c FROM P7S1_PortalLoginEvent__c WHERE P7S1_PortalLogin__c = :portalLogin.Id];
      system.assert ( portalLoginEvent != null);
      system.assertEquals (true, portalLoginEvent.P7S1_Successful__c );
      system.assertEquals ( portalLogin.Id , portalLoginEvent.P7S1_PortalLogin__c );
      system.assertEquals (P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_ADMIN_ACTIVATION, portalLoginEvent.P7S1_EventType__c);

      Test.stopTest();

    }



    /**
  * Tests the welcome mail to the liferay user
  * @since 0.1
   */
    static testMethod void sendWelcomeEmailToLiferayUser(){
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();

      P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);

      Test.startTest();

      portalLoginService.sendWelcomeEmailToLiferayUser( portalLogin );

      P7S1_PortalLoginEvent__c portalLoginEvent = [Select Id, P7S1_EventType__c,P7S1_Successful__c, P7S1_PortalLogin__c,P7S1_EventMessage__c FROM P7S1_PortalLoginEvent__c WHERE P7S1_PortalLogin__c = :portalLogin.Id];
      system.assert ( portalLoginEvent != null);
      system.assertEquals (true, portalLoginEvent.P7S1_Successful__c );
      system.assertEquals ( portalLogin.Id , portalLoginEvent.P7S1_PortalLogin__c );
      system.assertEquals (P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_WELCOME, portalLoginEvent.P7S1_EventType__c);

      Test.stopTest();

    }
        /**
  * Tests the welcome mail to the liferay user
  * @since 0.1
   */
    static testMethod void sendDeleteConfirmEmail(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      	P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();

      	P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
		portalLogin.P7S1_DeleteConfirmLink__c='https://www.sevenonemedia.de/confim-delete';
      Test.startTest();

      portalLoginService.sendDeleteConfirmEmail( portalLogin );

      P7S1_PortalLoginEvent__c portalLoginEvent = [Select Id, P7S1_EventType__c,P7S1_Successful__c, P7S1_PortalLogin__c,P7S1_EventMessage__c FROM P7S1_PortalLoginEvent__c WHERE P7S1_PortalLogin__c = :portalLogin.Id];
      system.assert ( portalLoginEvent != null);
      system.assertEquals (true, portalLoginEvent.P7S1_Successful__c );
      system.assertEquals ( portalLogin.Id , portalLoginEvent.P7S1_PortalLogin__c );
      system.assertEquals (P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_DELETE_CONFIRM, portalLoginEvent.P7S1_EventType__c);

      Test.stopTest();

    }

    /**
  * Tests the welcome mail to the liferay user goes wrong
  * @since 0.1
   */
    static testMethod void sendWelcomeEmailToLiferayUserException(){
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();

      P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
      insert portalLogin;
      portalLogin.P7S1_EMail__c=null;

      Test.startTest();
      portalLoginService.sendWelcomeEmailToLiferayUser( portalLogin );

      P7S1_PortalLoginEvent__c portalLoginEvent = [Select Id, P7S1_EventType__c,P7S1_Successful__c, P7S1_PortalLogin__c,P7S1_EventMessage__c FROM P7S1_PortalLoginEvent__c WHERE P7S1_PortalLogin__c = :portalLogin.Id];
      system.assert ( portalLoginEvent != null);
      system.debug('     : ' + portalLoginEvent);
      system.assertEquals (false, portalLoginEvent.P7S1_Successful__c );
      system.assertEquals ( portalLogin.Id , portalLoginEvent.P7S1_PortalLogin__c );
      system.assertEquals (P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_WELCOME, portalLoginEvent.P7S1_EventType__c);

      system.assertEquals(true, portalLoginEvent.P7S1_EventMessage__c.startsWith('#LOG#ERROR Exception in class P7S1_Liferay_EmailServiceImplSystem.EmailException: SendEmail failed. First exception on row 0'));

      Test.stopTest();

    }

    /**
  * Test sending OptInLink mail
  * @since 0.1
   */

    static testMethod void sendOptInLinkEmail(){
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();
      P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
      Test.startTest();
        portalLoginService.sendOptInLinkEmailEmail( portalLogin );

        P7S1_PortalLoginEvent__c portalLoginEvent = [Select Id, P7S1_EventType__c,P7S1_Successful__c, P7S1_PortalLogin__c,P7S1_EventMessage__c FROM P7S1_PortalLoginEvent__c WHERE P7S1_PortalLogin__c = :portalLogin.Id];
        system.assert ( portalLoginEvent != null);
        system.assertEquals (true, portalLoginEvent.P7S1_Successful__c );
        system.assertEquals ( portalLogin.Id , portalLoginEvent.P7S1_PortalLogin__c );
        system.assertEquals (P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_OPTIN, portalLoginEvent.P7S1_EventType__c);
        system.assertEquals(null, portalLoginEvent.P7S1_EventMessage__c);

      Test.stopTest();

    }

    /**
  * Test sending OptInLink mail exception handling
  * @since 0.1
   */
    static testMethod void sendOptInLinkEmailEmailWithException(){
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      	P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
      	portalLogin.P7S1_EMail__c=null;

      	Test.startTest();
	        portalLoginService.sendOptInLinkEmailEmail( portalLogin );
	
	        List<P7S1_PortalLoginEvent__c> portalLoginEvents = [Select Id, P7S1_EventType__c,P7S1_Successful__c, P7S1_PortalLogin__c,P7S1_EventMessage__c FROM P7S1_PortalLoginEvent__c];
	        system.assert ( portalLoginEvents != null);
	        system.assertEquals (1, portalLoginEvents.size());
	        system.assertEquals (false, portalLoginEvents.get(0).P7S1_Successful__c );
	        system.assertEquals ( portalLogin.Id , portalLoginEvents.get(0).P7S1_PortalLogin__c );
	        system.assertEquals (P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_OPTIN, portalLoginEvents.get(0).P7S1_EventType__c);
	        system.assertEquals(true, portalLoginEvents.get(0).P7S1_EventMessage__c.startsWith('#LOG#ERROR Exception in class P7S1_Liferay_EmailServiceImplSystem.EmailException: SendEmail failed. First exception on row 0'));

      	Test.stopTest();

    }

}