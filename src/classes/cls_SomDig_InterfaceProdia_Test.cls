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
private class cls_SomDig_InterfaceProdia_Test {

	static {
    // setup test data

     	Account acc=new Account();
   		acc.name='Test';
   		// acc.ProRexId__c='1234567890';
			acc.AccountNumber='1234567890';
        acc.BillingStreet='Street 123';
        acc.BillingCity='City';
        acc.BillingPostalCode='12345';
        acc.BillingCountry='France';
        acc.ShippingStreet='Street 123';
        acc.ShippingPostalCode='12345';
        acc.ShippingCountry='France';

        insert acc;

        P7S1_ExternalId__c p7s1 = new P7S1_ExternalId__c();
        p7s1.Name = '1234567890';
        p7s1.P7S1_Account__c = acc.Id;
        p7s1.P7S1_Source__c='ProSa/ProSedi';

        insert p7s1;

        Contact con = new Contact();
        con.FirstName ='Test';
        con.LastName = 'Test';
        con.ProRexId__c = '1234567890';
        con.AccountId = acc.Id;

        insert con;


  }


    static testMethod void getCompanyByNameTest() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetCompanyByName';  //Request URL
	   req.addParameter('Name', 'Test*');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetCompanyByName.doGet();

	   System.debug('>>>> getCompanyByNameTest JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Account acc= new Account();
       acc.Name = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Account'))).get(0))).get('Name');
       acc.AccountNumber = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Account'))).get(0))).get('ProRexId__c');
       System.assertEquals('Test', acc.Name);
       System.assertEquals('1234567890', acc.AccountNumber);




    }

     static testMethod void getCompanyByNameTest2() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetCompanyByName';  //Request URL

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetCompanyByName.doGet();

	   System.debug('>>>> getCompanyByNameTest JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapStatus = (Map<String, Object>) mapResponse.get('status');
       System.assertEquals('param Name is missing', mapStatus.get('error'));
       System.assertEquals('false', mapStatus.get('success'));

    }

    static testMethod void getAddressesByCompanyID() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetAddressesByCompanyID';  //Request URL
	   req.addParameter('ProRexId__c', '1234567890');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetAddressesByCompanyID.doGet();

	   System.debug('>>>> getAddressesByCompanyID JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');
       system.debug('>>>>>>>>>>>mapResult.get(Account):'+mapResult.get('Account'));
       Account acc= new Account();
       acc.BillingStreet = (String)((Map<String, Object>)(mapResult.get('Account'))).get('BillingStreet');
       acc.AccountNumber = (String)((Map<String, Object>)(mapResult.get('Account'))).get('ProRexId__c');
       System.assertEquals(acc.BillingStreet, 'Street 123');
       System.assertEquals(acc.AccountNumber, '1234567890');

    }

     static testMethod void getAddressesByCompanyID2() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetAddressesByCompanyID';  //Request URL

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetAddressesByCompanyID.doGet();

	   System.debug('>>>> getAddressesByCompanyID JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapStatus = (Map<String, Object>) mapResponse.get('status');
       System.assertEquals(mapStatus.get('error'), 'param ProRexId__c is missing');
       System.assertEquals(mapStatus.get('success'), 'false');
    }


     static testMethod void getEMailByPersonID() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetEMailByPersonID';  //Request URL
	   req.addParameter('ProRexId__c', '1234567890');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetEMailByPersonID.doGet();

	   System.debug('>>>> GetEMailByPersonID JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Contact con= new Contact();

       con.ProRexId__c = (String)((Map<String, Object>)(mapResult.get('Contact'))).get('ProRexId__c');
       System.assertEquals(con.ProRexId__c, '1234567890');
    }

      static testMethod void getEMailByPersonID2() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetEMailByPersonID';  //Request URL

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetEMailByPersonID.doGet();

	   System.debug('>>>> GetEMailByPersonID JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapStatus = (Map<String, Object>) mapResponse.get('status');
       System.assertEquals(mapStatus.get('error'), 'param ProRexId__c is missing');
       System.assertEquals(mapStatus.get('success'), 'false');
    }

     static testMethod void getGetPersonByID() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetPersonByID';  //Request URL
	   req.addParameter('ProRexId__c', '1234567890');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetPersonByID.doGet();

	   System.debug('>>>> GetPersonByID JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Contact con= new Contact();
       con.LastName = (String)((Map<String, Object>)(mapResult.get('Contact'))).get('LastName');
       con.ProRexId__c = (String)((Map<String, Object>)(mapResult.get('Contact'))).get('ProRexId__c');
       System.assertEquals(con.LastName, 'Test');
       System.assertEquals(con.ProRexId__c, '1234567890');
    }

     static testMethod void getGetPersonByID2() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetPersonByID';  //Request URL

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetPersonByID.doGet();

	   System.debug('>>>> GetPersonByID JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapStatus = (Map<String, Object>) mapResponse.get('status');
       System.assertEquals(mapStatus.get('error'), 'param ProRexId__c is missing');
       System.assertEquals(mapStatus.get('success'), 'false');
    }

      static testMethod void getGetPersonByCompanyIDandName() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetPersonByCompanyIDandName';  //Request URL
	   req.addParameter('ProRexId__c', '1234567890');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetPersonByCompanyIDandName.doGet();

	   System.debug('>>>> GetPersonByCompanyIDandName JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Contact con= new Contact();
       con.LastName = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('LastName');
       con.ProRexId__c = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('ProRexId__c');
       System.assertEquals(con.LastName, 'Test');
       System.assertEquals(con.ProRexId__c, '1234567890');
    }

     static testMethod void getGetPersonByCompanyIDandName1() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetPersonByCompanyIDandName';  //Request URL

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetPersonByCompanyIDandName.doGet();

	   System.debug('>>>> GetPersonByCompanyIDandName JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapStatus = (Map<String, Object>) mapResponse.get('status');
       System.assertEquals(mapStatus.get('error'), 'param ProRexId__c is missing');
       System.assertEquals(mapStatus.get('success'), 'false');
    }
     static testMethod void getGetPersonByCompanyIDandName2() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();

	   req.requestURI = '/services/apexrest/GetPersonByCompanyIDandName';  //Request URL
	   req.addParameter('ProRexId__c', '1234567890');
	   req.addParameter('LastName', 'Test');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetPersonByCompanyIDandName.doGet();

	   System.debug('>>>> GetPersonByCompanyIDandName JSON result = ' + RestContext.response.responseBody.toString());


	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Contact con= new Contact();
       con.LastName = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('LastName');
       con.ProRexId__c = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('ProRexId__c');
       System.assertEquals(con.LastName, 'Test');
       System.assertEquals(con.ProRexId__c, '1234567890');

    }

     static testMethod void getGetPersonByCompanyIDandName3() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetPersonByCompanyIDandName';  //Request URL
	   req.addParameter('ProRexId__c', '1234567890');
	   req.addParameter('FirstName', 'Test');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetPersonByCompanyIDandName.doGet();

	   System.debug('>>>> GetPersonByCompanyIDandName JSON result = ' + RestContext.response.responseBody.toString());

	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Contact con= new Contact();
       con.LastName = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('LastName');
       con.ProRexId__c = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('ProRexId__c');
       System.assertEquals(con.LastName, 'Test');
       System.assertEquals(con.ProRexId__c, '1234567890');
    }

     static testMethod void getGetPersonByCompanyIDandName4() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();

	   req.requestURI = '/services/apexrest/GetPersonByCompanyIDandName';  //Request URL
	   req.addParameter('ProRexId__c', '1234567890');
	   req.addParameter('LastName', 'Test*');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetPersonByCompanyIDandName.doGet();

	   System.debug('>>>> GetPersonByCompanyIDandName JSON result = ' + RestContext.response.responseBody.toString());


	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Contact con= new Contact();
       con.LastName = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('LastName');
       con.ProRexId__c = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('ProRexId__c');
       System.assertEquals(con.LastName, 'Test');
       System.assertEquals(con.ProRexId__c, '1234567890');
    }

     static testMethod void getGetPersonByCompanyIDandName5() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetPersonByCompanyIDandName';  //Request URL
	   req.addParameter('ProRexId__c', '1234567890');
	   req.addParameter('FirstName', 'Test*');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetPersonByCompanyIDandName.doGet();

	   System.debug('>>>> GetPersonByCompanyIDandName JSON result = ' + RestContext.response.responseBody.toString());


	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Contact con= new Contact();
       con.LastName = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('LastName');
       con.ProRexId__c = (String)((Map<String, Object>)(((List<Object>)(mapResult.get('Contact'))).get(0))).get('ProRexId__c');
       System.assertEquals(con.LastName, 'Test');
       System.assertEquals(con.ProRexId__c, '1234567890');
    }

     static testMethod void getGetCompanyByID() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetCompanyByID';  //Request URL
	   req.addParameter('ProRexId__c', '1234567890');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetCompanyByID.doGet();

	   System.debug('>>>> getGetCompanyByID JSON result = ' + RestContext.response.responseBody.toString());




	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Account acc= new Account();
       acc.Name = (String)((Map<String, Object>)(mapResult.get('Account'))).get('Name');
       acc.AccountNumber = (String)((Map<String, Object>)(mapResult.get('Account'))).get('ProRexId__c');
       System.assertEquals(acc.Name, 'Test');
       System.assertEquals(acc.AccountNumber, '1234567890');
    }
     static testMethod void getGetCompanyByID2() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetCompanyByID';  //Request URL

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetCompanyByID.doGet();

	   System.debug('>>>> getGetCompanyByID JSON result = ' + RestContext.response.responseBody.toString());




	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapStatus = (Map<String, Object>) mapResponse.get('status');
       System.assertEquals(mapStatus.get('error'), 'param ProRexId__c is missing');
       System.assertEquals(mapStatus.get('success'), 'false');
    }

     static testMethod void getDefaultByPersonID() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetDefaultByPersonID';  //Request URL
	   req.addParameter('ProRex-Person-ID', '1234567890');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetDefaultByPersonID.doGet();

	   System.debug('>>>> GetDefaultByPersonID JSON result = ' + RestContext.response.responseBody.toString());




	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Account acc= new Account();
       acc.Name = (String)((Map<String, Object>)(mapResult.get('Account-Data '))).get('Name');
       acc.AccountNumber = (String)((Map<String, Object>)(mapResult.get('Account-Data '))).get('ProRexId__c');
       System.assertEquals(acc.Name, 'Test');
       System.assertEquals(acc.AccountNumber, '1234567890');

       Contact con= new Contact();
       con.LastName = (String)((Map<String, Object>)(mapResult.get('Contact-Data'))).get('LastName');
       con.ProRexId__c = (String)((Map<String, Object>)(mapResult.get('Contact-Data'))).get('ProRexId__c');
       System.assertEquals(con.LastName, 'Test');
       System.assertEquals(con.ProRexId__c, '1234567890');

       System.assertEquals(((Map<String, Object>)(mapResult.get('Address-Data '))).get('BillingStreet'), 'Street 123');
       System.assertEquals(((Map<String, Object>)(mapResult.get('Address-Data '))).get('ShippingPostalCode'), '12345');
    }
     static testMethod void getDefaultByPersonID2() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetDefaultByPersonID';  //Request URL

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetDefaultByPersonID.doGet();

	   System.debug('>>>> GetDefaultByPersonID JSON result = ' + RestContext.response.responseBody.toString());




	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapStatus = (Map<String, Object>) mapResponse.get('status');
       System.assertEquals('param pProRexPersonID is missing', mapStatus.get('error'));
       System.assertEquals('false', mapStatus.get('success'));
    }

      static testMethod void getCompletDataByID() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetCompletDataByID';  //Request URL
	   req.addParameter('ProRex-Person-ID', '1234567890');
	   req.addParameter('ProRex-Company-ID', '1234567890');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetCompletDataByID.doGet();

	   System.debug('>>>> GetCompletDataByID JSON result = ' + RestContext.response.responseBody.toString());




	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapResult = (Map<String, Object>) mapResponse.get('results');

       Account acc= new Account();
       acc.Name = (String)((Map<String, Object>)(mapResult.get('Account-Data '))).get('Name');
       acc.AccountNumber = (String)((Map<String, Object>)(mapResult.get('Account-Data '))).get('ProRexId__c');
       System.assertEquals(acc.Name, 'Test');
       System.assertEquals(acc.AccountNumber, '1234567890');

       Contact con= new Contact();
       con.LastName = (String)((Map<String, Object>)(mapResult.get('Contact-Data'))).get('LastName');
       con.ProRexId__c = (String)((Map<String, Object>)(mapResult.get('Contact-Data'))).get('ProRexId__c');
       System.assertEquals(con.LastName, 'Test');
       System.assertEquals(con.ProRexId__c, '1234567890');

       System.assertEquals(((Map<String, Object>)(mapResult.get('Address-Data '))).get('BillingStreet'), 'Street 123');
       System.assertEquals(((Map<String, Object>)(mapResult.get('Address-Data '))).get('ShippingPostalCode'), '12345');
    }
     static testMethod void getCompletDataByID2() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetCompletDataByID';  //Request URL

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetCompletDataByID.doGet();

	   System.debug('>>>> GetCompletDataByID JSON result = ' + RestContext.response.responseBody.toString());




	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapStatus = (Map<String, Object>) mapResponse.get('status');
       System.assertEquals(mapStatus.get('error'), 'param ProRex-Company-ID,Person are missing');
       System.assertEquals('false', mapStatus.get('success'));
    }
      static testMethod void getCompletDataByID3() {

         Test.startTest();

	   RestRequest req = new RestRequest();
	   RestResponse res = new RestResponse();


	   req.requestURI = '/services/apexrest/GetCompletDataByID';  //Request URL
	   req.addParameter('ProRex-Person-ID', '0000');
	   req.addParameter('ProRex-Company-ID', '000');

	   req.httpMethod = 'GET';//HTTP Request Type

	   RestContext.request = req;
	   RestContext.response= res;

	   GetCompletDataByID.doGet();

	   System.debug('>>>> GetCompletDataByID JSON result = ' + RestContext.response.responseBody.toString());




	   Test.stopTest();

       Map<String, Object>mapResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
       Map<String, Object> mapStatus = (Map<String, Object>) mapResponse.get('status');
       System.assertEquals(mapStatus.get('error'), 'No data found');
       System.assertEquals(mapStatus.get('success'), 'false');
    }
}