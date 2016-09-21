/**
* This is the Testclass for P7S1_Liferay_PortalLoginController methods
*
* @author  Sebastian Listl
* @version 0.1, 2014-10-12
* @see P7S1_Liferay_PortalLoginController
*/
@isTest
private class P7S1_Liferay_PortalLoginController_Test {

	static testMethod void init() {
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
    	P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);

    	Test.startTest();
        	P7S1_Liferay_PortalLoginController controller = new P7S1_Liferay_PortalLoginController(new ApexPages.StandardController(portalLogin));
          	system.assert(controller != null);
        Test.stopTest();
    }

    /**
     * Tests the actions from action button 'active' on the objects visualforce page.
     * The action button calls a vf-page with js calls this method
     * @since 0.1
     */
    static testMethod void activatePortalLoginUserSF() {
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);

	    Test.startTest();
	        P7S1_Liferay_PortalLoginController controller = new P7S1_Liferay_PortalLoginController(new ApexPages.StandardController(portalLogin));
	      	system.assert(controller != null);
			controller.activatePortalLoginUserSF();
	        system.assertEquals(null, controller.output);
	
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
     * Tests the actions from action button 'active' on the objects visualforce page.
     * The action button calls a vf-page with js calls this method
     * @since 0.1
     * Mocks Exception
     */
    static testMethod void activatePortalLoginUserSFException() {
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      	P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);

    	Test.startTest();

        P7S1_Liferay_PortalLoginController controller = new P7S1_Liferay_PortalLoginController(new ApexPages.StandardController(portalLogin));
      	system.assert(controller != null);

      	delete portalLogin;

        controller.activatePortalLoginUserSF();
		system.assertEquals('activatePortalLoginUserLiferay in catch System.DmlException: Insert failed. First exception on row 0; first error: ENTITY_IS_DELETED, entity is deleted: []', controller.output);
        system.assertEquals ( 0, [Select Id, P7S1_EventType__c, P7S1_PortalLogin__c,P7S1_Successful__c FROM P7S1_PortalLoginEvent__c ORDER BY P7S1_EventTimestamp__c].size() );

    }

    /**
     * Tests the actions from action button 'active' on the objects visualforce page.
     * Is call from js after activatePortalLoginUserSF and redirects do pageReference
     *
     * @since 0.1
     */
    static testMethod void activatePortalLoginUserLiferay() {
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
		system.assert(portalLogin != null);
		system.assert(portalLogin.Id != null);
		system.debug(Logginglevel.DEBUG, '#####portalLogin#### ' + portalLogin);

    	Test.startTest();
      		Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(P7S1_Liferay_RestService_Test.LIFERAY_USER_JSON_ACTIVATE, P7S1_Liferay_RestService_Test.LIFERAY_RESP_SUCCESS ));

          	P7S1_Liferay_PortalLoginController controller = new P7S1_Liferay_PortalLoginController(new ApexPages.StandardController(portalLogin));
        	system.assert(controller != null);

			PageReference pr = controller.activatePortalLoginUserLiferay();
	        system.assert(pr != null);
	        system.assertEquals(new PageReference('/'+portalLogin.Id).getUrl(), pr.getUrl());
	        system.assertEquals(null, controller.output);

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
     * Tests the actions from action button 'active' on the objects visualforce page.
     * Is call from js after activatePortalLoginUserSF and redirects do pageReference
     * Mocks an Exception
     * @since 0.1
     */
    static testMethod void activatePortalLoginUserLiferayException() {
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      	P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);

    	Test.startTest();
      	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(P7S1_Liferay_RestService_Test.LIFERAY_USER_JSON_ACTIVATE, P7S1_Liferay_RestService_Test.LIFERAY_RESP_SUCCESS ));

        P7S1_Liferay_PortalLoginController controller = new P7S1_Liferay_PortalLoginController(new ApexPages.StandardController(portalLogin));
        system.assert(controller != null);

        delete portalLogin;
		
		PageReference pr = controller.activatePortalLoginUserLiferay();
  		system.assert(pr != null);
  		system.assertEquals(new PageReference('/'+portalLogin.Id).getUrl(), pr.getUrl());
  		system.assertEquals('activatePortalLoginUserLiferay in catch System.DmlException: Insert failed. First exception on row 0; first error: ENTITY_IS_DELETED, entity is deleted: []',controller.output);
      	system.assertEquals ( 0, [Select Id, P7S1_EventType__c, P7S1_PortalLogin__c,P7S1_Successful__c FROM P7S1_PortalLoginEvent__c ORDER BY P7S1_EventTimestamp__c].size() );

      	Test.stopTest();
    }
    
    /**
     * Tests that the welcome mail after activation is not being sent twice  
     *
     * @since 0.1
     */
    static testMethod void activatePortalLoginUserAdfactoryTwice() {
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
		portalLogin.P7S1_Portal__c = P7S1_Liferay_Constants.PORTAL_ADFACTORY;
		insert portalLogin;

    	Test.startTest();
      	//Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(P7S1_Liferay_RestService_Test.LIFERAY_USER_JSON_ACTIVATE, P7S1_Liferay_RestService_Test.LIFERAY_RESP_SUCCESS ));

        P7S1_Liferay_PortalLoginController controller = new P7S1_Liferay_PortalLoginController(new ApexPages.StandardController(portalLogin));
        system.assert(controller != null);

        PageReference pr = controller.activatePortalLoginUserLiferay();
        system.assert(pr != null);
        system.assertEquals(new PageReference('/'+portalLogin.Id).getUrl(), pr.getUrl());
        system.assertEquals(null, controller.output);

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
        
        pr = controller.activatePortalLoginUserLiferay();
        
        portalLoginEvents = [Select Id, P7S1_EventType__c, P7S1_PortalLogin__c,P7S1_Successful__c FROM P7S1_PortalLoginEvent__c ORDER BY P7S1_EventTimestamp__c];

        system.assert ( portalLoginEvents != null);
        system.assertEquals ( 3, portalLoginEvents.size() );

        system.assertEquals ( portalLogin.Id, portalLoginEvents.get(0).P7S1_PortalLogin__c );
        system.assertEquals ( portalLogin.Id, portalLoginEvents.get(1).P7S1_PortalLogin__c );
        system.assertEquals ( portalLogin.Id, portalLoginEvents.get(2).P7S1_PortalLogin__c );

        system.assert( portalLoginEvents.get(0).P7S1_Successful__c );
        system.assert( portalLoginEvents.get(1).P7S1_Successful__c );
        system.assert( portalLoginEvents.get(2).P7S1_Successful__c );

        system.assertEquals ( P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_AF, portalLoginEvents.get(0).P7S1_EventType__c );
        system.assertEquals ( P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_WELCOME, portalLoginEvents.get(1).P7S1_EventType__c );
        system.assertEquals ( P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_AF, portalLoginEvents.get(2).P7S1_EventType__c );
      	Test.stopTest();
    }
    
    /**
     * Tests that the welcome mail after activation is not being sent twice  
     *
     * @since 0.1
     */
    static testMethod void deletePortalLoginUserLiferay() {
		//public static String LIFERAY_USER_JSON_DELETE = '{"status": 5,"userId": 20199,"deleted": true}';
		//public static String LIFERAY_USER_JSON_DELETE_FAILED = '{"status": 0,"userId": 20199,"deleted": false}';
		
		
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);

    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(P7S1_Liferay_RestService_Test.LIFERAY_USER_JSON_DELETE, P7S1_Liferay_RestService_Test.LIFERAY_RESP_SUCCESS ));
        
        String result = P7S1_Liferay_PortalLoginController.deletePortalLogin(portalLogin.Id);
        system.assertEquals('success',result);
        Test.stopTest();
        
    }
    static testMethod void deletePortalLoginUserLiferayFailed() {
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
		
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(P7S1_Liferay_RestService_Test.LIFERAY_USER_JSON_DELETE_FAILED, P7S1_Liferay_RestService_Test.LIFERAY_RESP_SUCCESS ));
        	
        	String result = P7S1_Liferay_PortalLoginController.deletePortalLogin(portalLogin.Id);
        	system.assertEquals('Löschen des users in liferay fehlgeschlagen bitte kontaktieren sie den Administrator',result);
        
        Test.stopTest();
    }
    /**
     * Tests that the welcome mail after activation is not being sent twice  
     *
     * @since 0.1
     */
    static testMethod void deletePortalLoginUserLiferayException() {
    	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
    	Test.startTest();
	        system.assertEquals('Löschen des users in liferay fehlgeschlagen bitte kontaktieren sie den Administrator', P7S1_Liferay_PortalLoginController.deletePortalLogin('augustiner'));
        Test.stopTest();
    }

}