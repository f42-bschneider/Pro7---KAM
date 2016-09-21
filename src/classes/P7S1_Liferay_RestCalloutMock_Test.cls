/**
* This class mocks the HTTP callout to liferay rest api
*
* @author  Sebastian Listl
* @version 0.1, 2014-10-07
* @see P7S1_Liferay_RestService
*/
@isTest
global class P7S1_Liferay_RestCalloutMock_Test implements HttpCalloutMock  {

  global static String body {get;set;}
  global static Integer status {get;set;}

  global P7S1_Liferay_RestCalloutMock_Test(String bodyString, Integer statusInt){
    body = bodyString;
    status = statusInt;
  }

  global static HTTPResponse respond(HttpRequest request) {

       HTTPResponse response = new HTTPResponse();
    response.setHeader('Content-Type', 'application/json');
    response.setBody( body );
        response.setStatusCode( status );

       return response;
  }

}