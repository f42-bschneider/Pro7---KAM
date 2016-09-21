/**
* This is the Testclass for P7S1_Liferay_PortalLoginResource .cls its tests
*
* createPortalLogin     -   tests the creation of a P7S1_PortalLogin__c Custom object based on the json sting in POST Body
* updatePortalLogin     -   tests the update of a P7S1_PortalLogin__c Custom Object bast on the json string in PUT Body
*
* @author  Sebastian Listl
* @version 0.1
* @since   2015-09-01
* @see P7S1_Liferay_PortalLoginResource.cls
* @see P7S1_PortalLogin__c
*/
@isTest
private class P7S1_Liferay_PortalLoginResource_Test {

    /**
    * Tests if a P7S1_PortalLogin__c PortalLogin Object is created and the Opt-In Email is sent.
    * For both actions there must me created be created a P7S1_PortalLoginEvent__c object with the status.
    */
    static testmethod void createPortalLogin(){
    	
        /*** Mock Restrequest ***/
        RestRequest restRequestCreate = new RestRequest();
        P7S1_Liferay_TestDataGenerator.createAll();

        restRequestCreate.addHeader( 'Content-Type' , 'application/json' );
        restRequestCreate.httpMethod = 'POST';
        restRequestCreate.requestBody = Blob.valueof( P7S1_Liferay_RegistrationFormBean_Test.getJsonStringForObject() ); // Add JSON Message as a POST
        System.assert( restRequestCreate != null );
        RestContext.request = restRequestCreate;

        P7S1_Liferay_RegistrationFormBean obj = P7S1_Liferay_RegistrationFormBean_Test.createNewLifeRayRegistrationFormBean();
        P7S1_Liferay_RestResponse createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.createPortalLogin();
        system.assert(createPortalLoginResponse.result != null);
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_UNCONFIRMEND , createPortalLoginResponse.result.get('P7S1_Portal_Status__c'));

        system.assert( createPortalLoginResponse != null );
        if ( !createPortalLoginResponse.success ){
            system.debug(logginglevel.error, createPortalLoginResponse);
        }
        system.assert( createPortalLoginResponse.success );
        P7S1_PortalLogin__c portalLogin = (P7S1_PortalLogin__c) createPortalLoginResponse.result;

        System.assert( portalLogin != null );
        System.assertEquals( portalLogin.P7S1_Titel__c , obj.title );

        List<P7S1_PortalLogin__c> portalLoginsFromDb = [Select Id,P7S1_Portal_Status__c, P7S1_Titel__c From P7S1_PortalLogin__c];
        System.assert( portalLoginsFromDb != null );
        System.assert( portalLoginsFromDb.size() > 0 );
        System.assertEquals( portalLoginsFromDb.size() , 1 );
        System.assert( portalLoginsFromDb.get(0).Id != null );
        System.assertEquals( portalLoginsFromDb.get(0).P7S1_Titel__c , obj.title );
        System.assertEquals( portalLoginsFromDb.get(0).P7S1_Portal_Status__c , P7S1_Liferay_Constants.PORTAL_STATUS_UNCONFIRMEND );

        List<P7S1_PortalLoginEvent__c> portalLoginEvents =  [   SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c
                                                                WHERE P7S1_PortalLogin__c = :portalLogin.Id];

        system.assert(portalLoginEvents != null);
        system.assertEquals(2, portalLoginEvents.size());

        /*** portal login is created ***/
        system.assert(portalLoginEvents.get(0) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(0).P7S1_PortalLogin__c);
        system.assertEquals(portalLoginEvents.get(0).P7S1_Successful__c, true);
        system.assertEquals(portalLoginEvents.get(0).P7S1_EventType__c, P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_CREATED);
        system.assert(portalLoginEvents.get(0).P7S1_EventTimestamp__c != null);
        system.assertEquals('{"id":20199,"activationLink":"http://mydomain.de","acceptPrivacyTerms":true,"acceptTerms":true,"area":"Einkauf","class":"de.silpion.ahead.portlet.registration.controller.RegistrationFormBean","companyAddressPOBox":null,"companyCity":"Musterstadt","companyCountry":4,"companyFax":"111-11-11-111","companyFaxCountry":"111","companyFaxExtension":"111","companyFaxNumber":"11","companyFaxRegion":"11","companyName":"Musterfirma","companyPOBox":null,"companyPhone":"111-111-111-111","companyPhoneCountry":"111","companyPhoneExtension":"111","companyPhoneNumber":"111","companyPhoneRegion":"111","companyStreetAddress":"Musterstrasse","companyStreetNumber":"11","companyType":"ADVERTISING_AGENCY","companyTypeId":2,"companyZip":"11111","email":"salow_test1@silpion.de","firstName":"Max","jobTitle":"Einkaufsleiter","lastName":"Mustermann","male":true,"password":"Test1234","passwordRepeat":"Test1234","requestObs":null,"title":"Dr.","portal":"sevenonemedia.de","dateOfBirth":"2015-01-01","newsletter":true }',portalLoginEvents.get(0).P7S1_EventMessage__c);

        /*** opt-in email is sent ***/
        system.assert(portalLoginEvents.get(1) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(1).P7S1_PortalLogin__c);
        system.assertEquals(portalLoginEvents.get(1).P7S1_Successful__c, true);
        system.assertEquals(portalLoginEvents.get(1).P7S1_EventType__c, P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_OPTIN);
        system.assert(portalLoginEvents.get(1).P7S1_EventTimestamp__c != null);
        system.assertEquals(null,portalLoginEvents.get(1).P7S1_EventMessage__c);

        /*** testing insert same user again ***/

        createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.createPortalLogin();
        system.debug( createPortalLoginResponse );
        system.assert(createPortalLoginResponse != null);
        system.assert(!createPortalLoginResponse.success);
        system.assertEquals(new String[]{'LiferayRestValidationException:[]: portaluser already exist'},createPortalLoginResponse.errors);

    }
    /**
    * Tests the validation for the  createPortalLogin API-CAll
    * Validates if requiered fields are available and the user doesn't exist in the Database
    *
    */
    static testmethod void createPortalLoginValidation(){
    	P7S1_Liferay_TestDataGenerator.createAll();
        /*** Mock Restrequest ***/
        RestRequest restRequestCreate = new RestRequest();
        restRequestCreate.addHeader( 'Content-Type' , 'application/json' );
        restRequestCreate.httpMethod = 'POST';
        restRequestCreate.requestBody = Blob.valueof( '{"id":"4711"}' ); // Add JSON Message as a POST
        System.assert( restRequestCreate != null );
        RestContext.request = restRequestCreate;

        system.debug( '*** test email field is not empty ***' );

        P7S1_Liferay_RegistrationFormBean obj = P7S1_Liferay_RegistrationFormBean_Test.createNewLifeRayRegistrationFormBean();
        P7S1_Liferay_RestResponse createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.createPortalLogin();

        system.assert( createPortalLoginResponse != null );
        system.assert( !createPortalLoginResponse.success );
        system.assertEquals( new String[]{'LiferayRestValidationException:[]: missing requiered field email'}, createPortalLoginResponse.errors );

        system.debug( '*** test portal field is not empty ***' );
        restRequestCreate.requestBody = Blob.valueof( '{"id":"4711","email":"listl@ambuorg.de"}' ); // Add JSON Message as a POST
        createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.createPortalLogin();
        system.assert( createPortalLoginResponse != null );
        system.assert( !createPortalLoginResponse.success );
        system.assertEquals( new String[]{'LiferayRestValidationException:[]: invalid or missing requiered field portal'}, createPortalLoginResponse.errors );

        system.debug( '*** test portal field is wrong empty ***' );
        restRequestCreate.requestBody = Blob.valueof( '{"id":"4711","email":"listl@ambuorg.de","portal":"bla bla"}' );
        createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.createPortalLogin();
        system.assert( createPortalLoginResponse != null );
        system.assert( !createPortalLoginResponse.success );
        system.assertEquals( new String[]{'LiferayRestValidationException:[]: invalid or missing requiered field portal'}, createPortalLoginResponse.errors );

        system.debug( '*** test id field is missing ***' );
        restRequestCreate.requestBody = Blob.valueof( '{"email":"listl@ambuorg.de","portal":"sevenonemedia.de"}' );
        createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.createPortalLogin();
        system.assert( createPortalLoginResponse != null );
        system.assert( !createPortalLoginResponse.success );
        system.assertEquals( new String[]{'LiferayRestValidationException:[]: missing requiered field id'}, createPortalLoginResponse.errors );

        system.debug( '*** test activationLink field is missing ***' );
        restRequestCreate.requestBody = Blob.valueof( '{"id":4711, "email":"listl@ambuorg.de","portal":"sevenonemedia.de"}' );
        createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.createPortalLogin();
        system.assert( createPortalLoginResponse != null );
        system.assert( !createPortalLoginResponse.success );
        system.assertEquals( new String[]{'LiferayRestValidationException:[]: missing requiered field activationLink'}, createPortalLoginResponse.errors );

    }

    static testmethod void getPortalLogin(){
    	P7S1_Liferay_TestDataGenerator.createAll();
        RestRequest restRequestGet = new RestRequest();
        restRequestGet.addHeader( 'Content-Type' , 'application/json' );
        restRequestGet.httpMethod = 'GET';

        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c(P7S1_EMail__c='test@p7s1.de');
        insert portalLogin;

        restRequestGet.addParameter('portalLoginId', portalLogin.Id);
        System.assert( restRequestGet != null );

        RestContext.request = restRequestGet;

        P7S1_Liferay_RestResponse response = P7S1_Liferay_PortalLoginResource.getPortalLogin();

        System.assert( response != null );
        System.assert( response.result != null );
        System.assertEquals( response.result.Id, portalLogin.Id );
        System.assertEquals( response.success, true );

        System.debug('### create portal login first time with success ###');
        P7S1_PortalLogin__c portalLoginFromDB = [SELECT Name FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
        System.assertEquals( response.result.get('Name'), portalLoginFromDB.Name );
        System.assertEquals( response.errors, new String[]{} );

    }
    /**
    * Tests to get a P7S1_PortalLogin__c object which was deleted
    *
    */
    static testmethod void getPortalLoginException(){
    	P7S1_Liferay_TestDataGenerator.createAll();
        RestRequest restRequestGet = new RestRequest();
        restRequestGet.addHeader( 'Content-Type' , 'application/json' );
        restRequestGet.httpMethod = 'GET';

        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c(P7S1_EMail__c='test@p7s1.de');
        insert portalLogin;

        restRequestGet.addParameter('portalLoginId', portalLogin.Id);
        System.assert( restRequestGet != null );

        RestContext.request = restRequestGet;

        delete portalLogin;

        P7S1_Liferay_RestResponse response = P7S1_Liferay_PortalLoginResource.getPortalLogin();

        System.assert( response != null );
        System.assert( response.result == null );
        System.assertEquals( false, response.success );
        System.assertEquals( new String[]{'List has no rows for assignment to SObject'}, response.errors );
    }

    static testmethod void updatePortalLoginConfirm(){

        P7S1_Liferay_TestDataGenerator.createAll();

        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c (P7S1_Email__c = 'test@ambuorg.de', P7S1_Portal__c = P7S1_Liferay_Constants.PORTAL_ADFACTORY, P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_UNCONFIRMEND);
        insert portalLogin;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'PUT';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/'+ P7S1_Liferay_Constants.ACTION_CONFIRM + '/'+ portalLogin.Id;

        RestContext.request = restRequest;

        /*** liferay set new status to portal login after user has confirmed the optin link  ***/
        P7S1_Liferay_RegistrationFormBean obj = P7S1_Liferay_RegistrationFormBean_Test.createNewLifeRayRegistrationFormBean();
        P7S1_Liferay_RestResponse createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
        system.assert(createPortalLoginResponse.result != null);
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_INACTIVE , createPortalLoginResponse.result.get('P7S1_Portal_Status__c'));

        /*** check new status is set in database ***/
        P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_Portal_Status__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_INACTIVE, portalLoginFromDB.P7S1_Portal_Status__c);

        /*** check if the right event objects are written ***/
        List<P7S1_PortalLoginEvent__c> portalLoginEvents =  [   SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c
                                                                WHERE P7S1_PortalLogin__c = :portalLogin.Id];

        system.assert(portalLoginEvents != null);
        system.assertEquals(2, portalLoginEvents.size());

        /*** portal login is created ***/
        system.assert(portalLoginEvents.get(0) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(0).P7S1_PortalLogin__c);
        system.assertEquals(portalLoginEvents.get(0).P7S1_Successful__c, true);
        system.assertEquals(portalLoginEvents.get(0).P7S1_EventType__c, P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_CONFIRMED);
        system.assert(portalLoginEvents.get(0).P7S1_EventTimestamp__c != null);
        system.assertEquals(null,portalLoginEvents.get(0).P7S1_EventMessage__c);

        /***  activation email to admin is sent ***/
        system.assert(portalLoginEvents.get(1) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(1).P7S1_PortalLogin__c);
        system.debug('portalloging events ' + portalLoginEvents);
        system.assertEquals(portalLoginEvents.get(1).P7S1_Successful__c, true);
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_ADMIN_ACTIVATION, portalLoginEvents.get(1).P7S1_EventType__c);
        system.assert(portalLoginEvents.get(1).P7S1_EventTimestamp__c != null);
        system.assertEquals(null,portalLoginEvents.get(1).P7S1_EventMessage__c);

    }
    
    static testmethod void updatePortalLoginValidation(){
		P7S1_Liferay_TestDataGenerator.createAll();
        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
        system.assert(portalLogin != null);
        P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_EMail__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
        system.assertEquals( 'salow_test1@silpion.de', portalLoginFromDB.P7S1_Email__c );
        
        P7S1_PortalLogin__c portalLogin2 = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
        portalLogin2.P7S1_EMail__c = 'salow_test2@silpion.de';
        insert portalLogin2;
        P7S1_PortalLogin__c portalLoginFromDB2 = [SELECT P7S1_EMail__c FROM P7S1_PortalLogin__c Where id = :portalLogin2.Id];
        system.assertEquals( 'salow_test2@silpion.de', portalLoginFromDB2.P7S1_Email__c );

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'PUT';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/'+ P7S1_Liferay_Constants.ACTION_UPDATE + '/'+ portalLogin2.Id;
        restRequest.requestBody = Blob.valueof( '{"email":"'+portalLoginFromDB.P7S1_EMail__c+'"}' );

        RestContext.request = restRequest;

        Test.startTest();

        P7S1_Liferay_RestResponse restResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
        
        system.assert( restResponse.result == null );
        system.assertEquals( false, restResponse.success );
        system.assertEquals( new String[]{'another portaluser already exist with this email'}, restResponse.errors );
        
        Test.stopTest();    	
    }

    static testmethod void updatePortalLoginConfirmWithEmailException(){
		P7S1_Liferay_TestDataGenerator.createAll();
        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c (P7S1_Email__c = 'test@ambuorg.de', P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_UNCONFIRMEND);
        insert portalLogin;
        //portalLogin.P7S1_Email__c = null;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'PUT';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/'+ P7S1_Liferay_Constants.ACTION_CONFIRM + '/'+ portalLogin.Id;

        RestContext.request = restRequest;

        /*** liferay set new status to portal login after user has confirmed the optin link  ***/
        P7S1_Liferay_RegistrationFormBean obj = P7S1_Liferay_RegistrationFormBean_Test.createNewLifeRayRegistrationFormBean();
        P7S1_Liferay_RestResponse createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
        system.debug('### createPortalLoginResponse : ' + createPortalLoginResponse);
        
        system.assert(createPortalLoginResponse.result != null);
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_INACTIVE , createPortalLoginResponse.result.get('P7S1_Portal_Status__c'));

        /*** check new status is set in database ***/
        P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_Portal_Status__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_INACTIVE, portalLoginFromDB.P7S1_Portal_Status__c);

        /*** check if the right event objects are written ***/
        List<P7S1_PortalLoginEvent__c> portalLoginEvents =  [   SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c
                                                                WHERE P7S1_PortalLogin__c = :portalLogin.Id];
		
		system.debug('### portalLoginEvents : ' + portalLoginEvents);
		
        system.assert(portalLoginEvents != null);
        system.assertEquals(2, portalLoginEvents.size());

        /*** portal login is created ***/
        system.assert(portalLoginEvents.get(0) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(0).P7S1_PortalLogin__c);
        system.assertEquals(portalLoginEvents.get(0).P7S1_Successful__c, true);
        system.assertEquals(portalLoginEvents.get(0).P7S1_EventType__c, P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_CONFIRMED);
        system.assert(portalLoginEvents.get(0).P7S1_EventTimestamp__c != null);
        system.assertEquals(null,portalLoginEvents.get(0).P7S1_EventMessage__c);

        /***  activation email to admin is sent with exception ***/
/** TODO FIND WAY TO MOCK THIS AGAIN
        system.assert(portalLoginEvents.get(1) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(1).P7S1_PortalLogin__c);
        system.debug('portalloging events ' + portalLoginEvents);
        system.assertEquals(false, portalLoginEvents.get(1).P7S1_Successful__c);
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_ADMIN_ACTIVATION, portalLoginEvents.get(1).P7S1_EventType__c);
        system.assert(portalLoginEvents.get(1).P7S1_EventTimestamp__c != null);
        system.assertEquals('Attempt to de-reference a null object no admin email set',portalLoginEvents.get(1).P7S1_EventMessage__c);
**/
    }
    /*
    * Testing update portal login for specific fields
    */
    static testmethod void updatePortalLoginUpdate(){
        P7S1_Liferay_TestDataGenerator.createAll();
        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
        system.assert(portalLogin != null);
        String newEmailToUpdate = 'salow_test2@silpion.de';

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'PUT';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/'+ P7S1_Liferay_Constants.ACTION_UPDATE + '/'+ portalLogin.Id;
        restRequest.requestBody = Blob.valueof( '{"email":"'+newEmailToUpdate+'", "companyType":"MEDIA_AGENCY"}' );

        RestContext.request = restRequest;

        Test.startTest();

            P7S1_Liferay_RestResponse restResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
            system.assert( restResponse != null );
            system.assert( restResponse.success );
            system.assert( restResponse.result != null );
            system.assertEquals( newEmailToUpdate, restResponse.result.get('P7S1_EMail__c') );
            system.assertEquals( 'Mediaagentur', restResponse.result.get('P7S1_Unternehmensart__c') );

            P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_Portal_Status__c, P7S1_EMail__c, P7S1_Unternehmensart__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
            system.assertEquals( newEmailToUpdate, portalLoginFromDB.P7S1_Email__c );
            system.assertEquals( 'Mediaagentur', portalLoginFromDB.P7S1_Unternehmensart__c );

            P7S1_PortalLoginEvent__c portalLoginEvent = [SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c
                                                                WHERE P7S1_PortalLogin__c = :portalLogin.Id];

            system.assert(portalLoginEvent != null );
            system.assertEquals(true,  portalLoginEvent.P7S1_Successful__c);
            system.assertEquals(portalLogin.Id , portalLoginEvent.P7S1_PortalLogin__c );
            system.assertEquals(P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_UPDATED ,  portalLoginEvent.P7S1_EventType__c);
            system.assertEquals(null,  portalLoginEvent.P7S1_EventMessage__c);
            system.assert(portalLoginEvent.P7S1_EventTimestamp__c != null);

            /*** test all posible fields to test SOQL's
            RestContext.request.requestBody = Blob.valueof( P7S1_Liferay_RegistrationFormBean_Test.getJsonStringForObject() );
            restResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
            system.assertEquals(true, restResponse.success);
            ***/

        Test.stopTest();
    }

    /*
    * Testing update portal login for specific fields
    */
    static testmethod void updatePortalLoginUpdateNotAllowedFields(){
        P7S1_Liferay_TestDataGenerator.createAll();
        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
        system.assert(portalLogin != null);

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'PUT';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/'+ P7S1_Liferay_Constants.ACTION_UPDATE + '/'+ portalLogin.Id;
        restRequest.requestBody = Blob.valueof( '{"companyCity":"Musterstadt","companyCountry":4,"companyFax":"111-11-11-111","companyPhone":"111-111-111-111","companyStreetAddress":"Musterstrasse","companyStreetNumber":"11","companyZip":"11111","email":"salow_test1@silpion.de","firstName":"Max","lastName":"Mustermann","male":true,"title":"Dr.","dateOfBirth":"2015-01-01","id":3029, "mobile":"01711234567", "area":"testBereich", "jobTitle":"testFunktion"}' );

        RestContext.request = restRequest;

        Test.startTest();

            P7S1_Liferay_RestResponse restResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
            system.debug('restResponse : ' + restResponse);
            system.assert( restResponse != null );
            system.assertEquals(false, restResponse.success );
            system.assertEquals(new String[]{'not allowed to update field : id'}, restResponse.errors);

            P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_Portal_Status__c, P7S1_EMail__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];

            P7S1_PortalLoginEvent__c portalLoginEvent = [SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c
                                                                WHERE P7S1_PortalLogin__c = :portalLogin.Id];

            system.assert(portalLoginEvent != null );
            system.assertEquals(false,  portalLoginEvent.P7S1_Successful__c);
            system.assertEquals(portalLogin.Id , portalLoginEvent.P7S1_PortalLogin__c );
            system.assertEquals(P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_UPDATED ,  portalLoginEvent.P7S1_EventType__c);
            system.assertEquals('LiferayRestDynamicUpdateException:[]: not allowed to update field : id',  portalLoginEvent.P7S1_EventMessage__c);
            system.assert(portalLoginEvent.P7S1_EventTimestamp__c != null);

        Test.stopTest();
    }


    /*
    * Testing update portal login exception handling
    */

    static testmethod void updatePortalLoginUpdateException(){
        P7S1_Liferay_TestDataGenerator.createAll();
        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
        system.assert(portalLogin != null);
        String portalLoginId = portalLogin.Id;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'PUT';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/'+ P7S1_Liferay_Constants.ACTION_UPDATE + '/'+ portalLogin.Id;
        restRequest.requestBody = Blob.valueof( '{"email":null}' );

        RestContext.request = restRequest;

        Test.startTest();
            P7S1_Liferay_RestResponse restResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
            system.assert( restResponse != null );
            system.assert( !restResponse.success );
            system.assert( restResponse.result == null );
            system.assertEquals( new String[]{'List has no rows for assignment to SObject'}, restResponse.errors );

            P7S1_PortalLoginEvent__c portalLoginEvent = [SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c LIMIT 1];

            system.assert(portalLoginEvent != null );
            system.assertEquals(false,  portalLoginEvent.P7S1_Successful__c);
            system.assertEquals(portalLoginId, portalLoginEvent.P7S1_PortalLogin__c );
            system.assertEquals(P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_UPDATED ,  portalLoginEvent.P7S1_EventType__c);
            system.assertEquals('System.QueryException: List has no rows for assignment to SObject',  portalLoginEvent.P7S1_EventMessage__c);
            system.assert(portalLoginEvent.P7S1_EventTimestamp__c != null);

        Test.stopTest();
    }

    /*
    * Not used in current setup activation is going through Controller
    */
    static testmethod void updatePortalLoginActivate(){

        P7S1_Liferay_TestDataGenerator.createAll();

        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c (P7S1_Email__c = 'test@ambuorg.de', P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_UNCONFIRMEND);
        insert portalLogin;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'PUT';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/'+ P7S1_Liferay_Constants.ACTION_ACTIVATE + '/'+ portalLogin.Id;

        RestContext.request = restRequest;

        P7S1_Liferay_RestResponse createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
        system.assert(createPortalLoginResponse.result != null);
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_ACTIVE , createPortalLoginResponse.result.get('P7S1_Portal_Status__c'));

        /*** check new status is set in database ***/
        P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_Portal_Status__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_ACTIVE, portalLoginFromDB.P7S1_Portal_Status__c);

        /*** check if the right event objects are written ***/
        List<P7S1_PortalLoginEvent__c> portalLoginEvents =  [   SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c
                                                                WHERE P7S1_PortalLogin__c = :portalLogin.Id];

        system.assert(portalLoginEvents != null);
        system.assertEquals(1, portalLoginEvents.size());

        /*** portal login is changed ***/
        system.assert(portalLoginEvents.get(0) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(0).P7S1_PortalLogin__c);
        system.assertEquals(portalLoginEvents.get(0).P7S1_Successful__c, true);
        system.assertEquals(portalLoginEvents.get(0).P7S1_EventType__c, P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_SF);
        system.assert(portalLoginEvents.get(0).P7S1_EventTimestamp__c != null);
        system.assertEquals(null,portalLoginEvents.get(0).P7S1_EventMessage__c);

    }


    /*
    * Not used in current setup activation is going through Controller
    */
    static testmethod void deletePortalLogin(){

        P7S1_Liferay_TestDataGenerator.createAll();

        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c (P7S1_Email__c = 'test@ambuorg.de', P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_UNCONFIRMEND);
        insert portalLogin;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'DELETE';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/delete/'+ portalLogin.Id;

        RestContext.request = restRequest;

        P7S1_Liferay_RestResponse portalLoginResponse = P7S1_Liferay_PortalLoginResource.deletePortalLogin();
        system.debug('response : ' + portalLoginResponse);

        system.assert(portalLoginResponse.success);
        system.assertEquals( null, portalLoginResponse.errors);
        system.assert(portalLoginResponse.result != null);
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_DELETED , portalLoginResponse.result.get('P7S1_Portal_Status__c'));

        /*** check new status is the old in database ***/
        P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_Portal_Status__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_DELETED , portalLoginFromDB.P7S1_Portal_Status__c);

        /*** check if the right event objects are written ***/
        List<P7S1_PortalLoginEvent__c> portalLoginEvents =  [   SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c
                                                                WHERE P7S1_PortalLogin__c = :portalLogin.Id];

        system.assert(portalLoginEvents != null);
        system.assertEquals(1, portalLoginEvents.size());

        /*** portal login is not changed ***/
        system.assert(portalLoginEvents.get(0) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(0).P7S1_PortalLogin__c);
        system.assertEquals(portalLoginEvents.get(0).P7S1_Successful__c, true);
        system.assertEquals(portalLoginEvents.get(0).P7S1_EventType__c, P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_DELETED_API);
        system.assert(portalLoginEvents.get(0).P7S1_EventTimestamp__c != null);
        system.assertEquals(null,portalLoginEvents.get(0).P7S1_EventMessage__c);

    }
    
    /*
    * Not used in current setup activation is going through Controller
    */
    static testmethod void portalLoginDeleteConfirmation(){

        P7S1_Liferay_TestDataGenerator.createAll();

        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
        portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_LIFERAY_ACTIVE;
        insert portalLogin;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'DELETE';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/confirm/'+ portalLogin.Id;
        restRequest.requestBody = Blob.valueOf('{"confirmDeleteUrl":"https://sevenonemedia.de/confirm-del"}');

        RestContext.request = restRequest;

        P7S1_Liferay_RestResponse portalLoginResponse = P7S1_Liferay_PortalLoginResource.deletePortalLogin();
        system.debug('### portalLoginDeleteConfirmation response : ' + portalLoginResponse);

        system.assertEquals( null, portalLoginResponse.errors);
        system.assertEquals(null, portalLoginResponse.result);
        system.assert(portalLoginResponse.success);

        /*** check new status is the old in database confirm should not change this ***/
        P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_Portal_Status__c,P7S1_DeleteConfirmLink__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
        system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_LIFERAY_ACTIVE , portalLoginFromDB.P7S1_Portal_Status__c);
        system.assertEquals('https://sevenonemedia.de/confirm-del', portalLoginFromDB.P7S1_DeleteConfirmLink__c);

        /*** check if the right event objects are written ***/
        List<P7S1_PortalLoginEvent__c> portalLoginEvents =  [   SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c
                                                                WHERE P7S1_PortalLogin__c = :portalLogin.Id];

        system.assert(portalLoginEvents != null);
        system.assertEquals(1, portalLoginEvents.size());

        /*** portal login is not changed ***/
        system.assert(portalLoginEvents.get(0) != null);
        system.assertEquals(portalLogin.Id,portalLoginEvents.get(0).P7S1_PortalLogin__c);
        system.assertEquals(portalLoginEvents.get(0).P7S1_Successful__c, true);
        system.assertEquals(portalLoginEvents.get(0).P7S1_EventType__c, P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_DELETE_CONFIRM);
        system.assert(portalLoginEvents.get(0).P7S1_EventTimestamp__c != null);
        system.assertEquals(null,portalLoginEvents.get(0).P7S1_EventMessage__c);

    }
    /*
    * Testing nullpointer
    */
    static testmethod void portalLoginDeleteConfirmationException(){

        P7S1_Liferay_TestDataGenerator.createAll();

        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c (P7S1_Email__c = 'test@ambuorg.de', P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_LIFERAY_ACTIVE);
        insert portalLogin;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'DELETE';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/confirm/'+ portalLogin.Id;
        restRequest.requestBody = Blob.valueOf('{"confirmDeleteUrl":"https://sevenonemedia.de/confirm-del"}');

        RestContext.request = restRequest;

        P7S1_Liferay_RestResponse portalLoginResponse = P7S1_Liferay_PortalLoginResource.deletePortalLogin();
        system.debug('### portalLoginDeleteConfirmation response : ' + portalLoginResponse);

        system.assertEquals( new String[]{'Attempt to de-reference a null object'}, portalLoginResponse.errors);
        system.assertEquals(null, portalLoginResponse.result);
        system.assert(!portalLoginResponse.success);

    }
    
    /*
    * Testing Validation
    */
    static testmethod void portalLoginConfirmDeleteValidation(){

        P7S1_Liferay_TestDataGenerator.createAll();

        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(false);
        portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_LIFERAY_ACTIVE;
        insert portalLogin;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'DELETE';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/confirm/'+ portalLogin.Id;

        RestContext.request = restRequest;
		
		/*** No Requestbody set ***/
        P7S1_Liferay_RestResponse portalLoginResponse = P7S1_Liferay_PortalLoginResource.deletePortalLogin();
        system.debug('### portalLoginDeleteConfirmation response : ' + portalLoginResponse);

        system.assertEquals( new String[]{'no content in request body where is confirmDeleteUrl'}, portalLoginResponse.errors);
        system.assertEquals(null, portalLoginResponse.result);
        system.assert(portalLoginResponse.success != null);
        system.assertEquals(false, portalLoginResponse.success);
        
        /*** no url set ***/
        restRequest.requestBody = Blob.valueOf('{"foo":"bar"}');
        portalLoginResponse = P7S1_Liferay_PortalLoginResource.deletePortalLogin();

        system.assertEquals( new String[]{'No or invalid for field : confirmDeleteUrl'}, portalLoginResponse.errors);
        system.assertEquals(null, portalLoginResponse.result);
        system.assertEquals(false, portalLoginResponse.success);
        
        /*** user already deleted ***/
        portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_DELETED;
        upsert portalLogin;
        
        restRequest.requestBody = Blob.valueOf('{"confirmDeleteUrl":"https://sevenonemedia.de/conrif-delete"}');
        portalLoginResponse = P7S1_Liferay_PortalLoginResource.deletePortalLogin();

        system.assertEquals( new String[]{'portalLogin status is already deleted'}, portalLoginResponse.errors);
        system.assertEquals(null, portalLoginResponse.result);
        system.assertEquals(false,portalLoginResponse.success);     
        
    }

    static testmethod void deletePortalLoginException(){
        String portalLoginId = 'XXXWWWSSS';
        P7S1_Liferay_TestDataGenerator.createAll();
        /*
        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c (P7S1_Email__c = 'test@ambuorg.de', P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_UNCONFIRMEND);
        insert portalLogin;
        */
        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'DELETE';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/delete/'+ portalLoginId;

        RestContext.request = restRequest;

        P7S1_Liferay_RestResponse portalLoginResponse = P7S1_Liferay_PortalLoginResource.deletePortalLogin();
        system.debug('response : ' + portalLoginResponse);

        system.assert(!portalLoginResponse.success);
        system.assert(portalLoginResponse.result == null);
        system.assertEquals( new String[] { 'List has no rows for assignment to SObject' }, portalLoginResponse.errors);
        //system.assertEquals(P7S1_Liferay_Constants.PORTAL_STATUS_DELETED , portalLoginResponse.result.get('P7S1_Portal_Status__c'));

        /*** check new status is the old in database ***/
        List<P7S1_PortalLogin__c> portalLoginsFromDB = [SELECT P7S1_Portal_Status__c FROM P7S1_PortalLogin__c];
        system.assertEquals(0 , portalLoginsFromDB.size());

        /*** check if the right event objects are written ***/
        List<P7S1_PortalLoginEvent__c> portalLoginEvents =  [   SELECT Id, P7S1_EventType__c, P7S1_Successful__c, P7S1_EventTimestamp__c, P7S1_PortalLogin__c, P7S1_EventMessage__c
                                                                FROM P7S1_PortalLoginEvent__c];

        system.assert(portalLoginEvents != null);
        system.assertEquals(1, portalLoginEvents.size());

        /*** portal login is not changed ***/
        system.assert(portalLoginEvents.get(0) != null);
        system.assertEquals(null,portalLoginEvents.get(0).P7S1_PortalLogin__c);
        system.assertEquals(portalLoginEvents.get(0).P7S1_Successful__c, false);
        system.assertEquals(portalLoginEvents.get(0).P7S1_EventType__c, P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_DELETED_API);
        system.assert(portalLoginEvents.get(0).P7S1_EventTimestamp__c != null);
        system.assertEquals('(List has no rows for assignment to SObject)',portalLoginEvents.get(0).P7S1_EventMessage__c);

    }

    /*** util stuff **/
    static testmethod void getIdAndActionFromRequestURI(){
        String requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/update/a3e250000004DZo';

        String id = P7S1_Liferay_ResourceUtil.getIdFromURI( requestURI );
        String action = P7S1_Liferay_ResourceUtil.getActionFromURI( requestURI );

        System.assertEquals( 'a3e250000004DZo' ,  id);
        System.assertEquals( 'update', action );

    }

    public static testmethod void dynamicJsonUpdate(){

        P7S1_Liferay_TestDataGenerator.createAll();
        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
        system.assert(portalLogin != null);

        Test.startTest();

        portalLogin = P7S1_Liferay_ResourceUtil.dynamicJsonUpdate( portalLogin, '{"companyName":"Musterfirma","companyCity":"Musterstadt","companyCountry":4,"companyFax":"111-11-11-111","companyPhone":"111-111-111-111","companyStreetAddress":"Musterstrasse","companyStreetNumber":"11","companyZip":"11111","email":"salow_test1@silpion.de","firstName":"Max","lastName":"Mustermann","male":true,"title":"Dr.","dateOfBirth":"2015-01-01", "mobile":"01791233456", "area":"Einkauf", "jobTitle":"Einkaufsleiter", "newsletter":true}' );

        system.assertEquals( 'Dr.', portalLogin.P7S1_Titel__c);
        system.assertEquals( 'Mustermann', portalLogin.P7S1_Nachname__c);
        system.assertEquals( 'Max', portalLogin.P7S1_Vorname__c);
        system.assertEquals( 'Herr', portalLogin.P7S1_Anrede__c  );
        system.assertEquals( 'salow_test1@silpion.de',portalLogin.P7S1_EMail__c );
        system.assertEquals( 'Musterfirma' , portalLogin.P7S1_Firma__c);
        system.assertEquals( '111-11-11-111', portalLogin.P7S1_Fax__c);
        system.assertEquals( '111-111-111-111' , portalLogin.P7S1_Telefon__c);
        system.assertEquals( 'Musterstrasse', portalLogin.P7S1_Strasse__c );
        system.assertEquals( '11', portalLogin.P7S1_Hausnummer__c );
        system.assertEquals( '11111', portalLogin.P7S1_Postleitzahl__c );
        system.assertEquals( 'Musterstadt' , portalLogin.P7S1_Ort__c);
        system.assertEquals( 'germany' , portalLogin.P7S1_Land__c);
        system.assertEquals( date.newInstance(2015,01,01), portalLogin.P7S1_Geburtstag__c  );
        system.assertEquals( '01791233456', portalLogin.P7S1_Mobil__c  );
        system.assertEquals( 'Einkauf', portalLogin.P7S1_Bereich__c  );
        system.assertEquals( 'Einkaufsleiter', portalLogin.P7S1_Funktion__c  );
        system.assertEquals( true, portalLogin.P7S1_Newsletter__c  );

        Test.stopTest();

    }
    
    public static testmethod void getStringValueByKey(){
    	system.assertEquals('https://foobar.com/delete-confirm',P7S1_Liferay_ResourceUtil.getStringValueByKey(P7S1_Liferay_ResourceUtil.JSON_FIELD_CONFIRM_DELETE_URL, '{"confirmDeleteUrl":"https://foobar.com/delete-confirm"}' ));
    }

	static testmethod void testContactReferencingCreate(){
		/*** Mock Restrequest ***/
        RestRequest restRequestCreate = new RestRequest();
        P7S1_Liferay_TestDataGenerator.createAll();

        restRequestCreate.addHeader( 'Content-Type' , 'application/json' );
        restRequestCreate.httpMethod = 'POST';
        restRequestCreate.requestBody = Blob.valueof( P7S1_Liferay_RegistrationFormBean_Test.getJsonStringForObject() ); // Add JSON Message as a POST
        System.assert( restRequestCreate != null );
        RestContext.request = restRequestCreate;

        P7S1_Liferay_RegistrationFormBean obj = P7S1_Liferay_RegistrationFormBean_Test.createNewLifeRayRegistrationFormBean();
		Contact c = P7S1_Liferay_TestDataGenerator.createDummyContact();
        P7S1_Liferay_RestResponse createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.createPortalLogin();

        system.assert( createPortalLoginResponse != null );
        system.assert( createPortalLoginResponse.result != null );
        system.assert( createPortalLoginResponse.success );
        
        P7S1_PortalLogin__c portalLogin = (P7S1_PortalLogin__c) createPortalLoginResponse.result;

        system.assert( portalLogin != null );
        system.assertEquals( portalLogin.P7S1_EMail__c , obj.email );
        
		P7S1_PortalLogin__c pl = [SELECT P7S1_Contact__c, P7S1_EMail__c FROM P7S1_PortalLogin__c WHERE id =: portalLogin.id];
		system.assertEquals( c.id, pl.P7S1_Contact__c );
		system.assertEquals( c.Email, pl.P7S1_EMail__c );
	}
	
	static testmethod void testContactReferencingUpdate(){
        P7S1_Liferay_TestDataGenerator.createAll();
        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
        system.assert(portalLogin != null);
        system.assertEquals('salow_test1@silpion.de', portalLogin.P7S1_EMail__c);
        
        String newEmailToUpdate = 'salow_test2@silpion.de';
        Contact c = new Contact(LastName = 'TestContactLastName', Email = newEmailToUpdate);
		insert c;

        RestRequest restRequest = new RestRequest();
        restRequest.addHeader( 'Content-Type' , 'application/json' );
        restRequest.httpMethod = 'PUT';
        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/'+ P7S1_Liferay_Constants.ACTION_UPDATE + '/'+ portalLogin.Id;
        restRequest.requestBody = Blob.valueof( '{"email":"'+newEmailToUpdate+'"}' );

        RestContext.request = restRequest;

        Test.startTest();

        P7S1_Liferay_RestResponse restResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
        system.assert( restResponse != null );
        system.assert( restResponse.success );
        system.assert( restResponse.result != null );

        P7S1_PortalLogin__c portalLoginFromDB = [SELECT P7S1_Portal_Status__c, P7S1_EMail__c, P7S1_Contact__c FROM P7S1_PortalLogin__c Where id = :portalLogin.Id];
        system.assertEquals( newEmailToUpdate, portalLoginFromDB.P7S1_Email__c, c.Email );
        system.assertEquals( c.Id, portalLoginFromDB.P7S1_Contact__c );

        Test.stopTest();
    }
	
	static testmethod void testAvoidUpdateDeletedPortalLogins(){
		P7S1_Liferay_TestDataGenerator.createAll();
        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin( false );
        portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_DELETED;
        insert portalLogin;

		for ( string action : new String[]{ P7S1_Liferay_Constants.ACTION_CONFIRM, P7S1_Liferay_Constants.ACTION_ACTIVATE, P7S1_Liferay_Constants.ACTION_UPDATE } ) {
	        RestRequest restRequest = new RestRequest();
	        restRequest.addHeader( 'Content-Type' , 'application/json' );
	        restRequest.httpMethod = 'PUT';
	        restRequest.requestURI = 'https://p7s1--LR2SF.cs80.my.salesforce.com/services/apexrest/portalLogin/'+ action + '/'+ portalLogin.Id;
	        if ( action.equals( P7S1_Liferay_Constants.ACTION_UPDATE ) )
		        restRequest.requestBody = Blob.valueof( '{"firstName":"someNewFirstName"}' );
	        RestContext.request = restRequest;
	
	        P7S1_Liferay_RestResponse createPortalLoginResponse = P7S1_Liferay_PortalLoginResource.updatePortalLogin();
	        system.assertEquals(new String[]{'action ' + action + ' is not possible, portaluser is already deleted'}, createPortalLoginResponse.errors);
		}
	}
	
	public static testmethod void dynamicJsonUpdateDateOfBirth(){

        P7S1_Liferay_TestDataGenerator.createAll();
        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
        system.assert(portalLogin != null);

        Test.startTest();

        portalLogin = P7S1_Liferay_ResourceUtil.dynamicJsonUpdate( portalLogin, '{"dateOfBirth":null}' );
        system.assertEquals( null, portalLogin.P7S1_Geburtstag__c  );
		
		portalLogin = P7S1_Liferay_ResourceUtil.dynamicJsonUpdate( portalLogin, '{"dateOfBirth":""}' );
        system.assertEquals( null, portalLogin.P7S1_Geburtstag__c  );
		
        Test.stopTest();

    }

}