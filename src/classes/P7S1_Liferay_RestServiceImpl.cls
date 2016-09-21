/**
* Implementaion of the P7S1_Liferay_RestService inteface
* @author  Sebastian Listl
* @version 0.1, 2014-10-1
* @see P7S1_Liferay_RestService
*/
public with sharing class P7S1_Liferay_RestServiceImpl implements P7S1_Liferay_RestService {

  P7S1_Liferay_OAuthService oAuthService = new P7S1_Liferay_OAuthServiceImpl();

  //public static String ENDPOINT_LIFERAY = 'https://liferay.silpion.de';
  //public static String API_PATH_USER_UPDATE_STATUS = '/api/jsonws/user/update-status';
  public static String ENDPOINT_LIFERAY = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayRestApiHost__c;
  public static String API_PATH_USER_UPDATE = '/JsonWebService-portlet.user/update-user';
  public static String API_PATH_USER_DELETE = '/JsonWebService-portlet.user/delete-user';
  
  public static String HTTP_METHOD_POST = 'POST' ;
  //public static String P_AUTH = 'dEsloCsr';

    /*
     * {@inheritDoc}
     */
    public P7S1_Liferay_RestStatus liferayUserActivate(Long userId) {
        system.debug(Logginglevel.DEBUG, 'entering liferayUserActivate@P7S1_Liferay_RestServiceImpl');

        P7S1_Liferay_RestStatus restStatus = new P7S1_Liferay_RestStatus( false );
        system.debug(Logginglevel.DEBUG, 'liferayUserActivate@P7S1_Liferay_RestServiceImpl restStatus ' + restStatus);
        try {
            /*
            Http httpHtAccess = new Http();
            HttpRequest reqHtAccess = new HttpRequest();
            reqHtAccess.setEndpoint( endpoint );
            reqHtAccess.setHeader( 'Authorization', 'BASIC '+Blob.valueOf('liferay-relaunch-dev' + ':' + 'Yywww75n') );
            reqHtAccess.setHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
            reqHtAccess.setHeader('Accept', 'application/json');
            reqHtAccess.setMethod( HTTP_METHOD_POST );
            reqHtAccess.setBody( body );
            HttpResponse respHtAccess  = httpHtAccess.send(reqHtAccess);
            system.debug(Logginglevel.DEBUG, '##### - respHtAccess: ' + respHtAccess);
            */
            
            Http http = new Http();
            //P7S1_Liferay_User liferayUser = new P7S1_Liferay_User(userId, 0);
            //system.debug(Logginglevel.DEBUG, '#LOG#DEBUG entering liferayUserActivate@P7S1_Liferay_RestServiceImpl liferayUser ' + liferayUser);
            //HttpRequest request = getHttpRequest( userId );
            HttpRequest request = getHttpRequestUpdateUser( userId );
            system.debug(Logginglevel.DEBUG, 'liferayUserActivate@P7S1_Liferay_RestServiceImpl request ' + request );
            system.debug(Logginglevel.DEBUG, 'liferayUserActivate@P7S1_Liferay_RestServiceImpl getBody() ' + request.getBody() );
            //system.debug(Logginglevel.DEBUG, 'liferayUserActivate@P7S1_Liferay_RestServiceImpl getHeader() ' + request.getHeader('Authentication') );
            HttpResponse response = http.send(request);
            system.debug(Logginglevel.DEBUG, 'liferayUserActivate@P7S1_Liferay_RestServiceImpl response.getBody() ' + response.getBody() );
    
            if ( response.getStatusCode() == 200 ){
                P7S1_Liferay_User liferayUserReceived = P7S1_Liferay_User.parse( response.getBody() );
                if (liferayUserReceived.status == 0 ){
                  restStatus.success = true;
                }
            } 
            restStatus.message = 'statusCode : ' + response.getStatusCode() + ' body : ' + response.getBody();
            
        } catch (Exception e){
            restStatus.message = 'Exception liferayUserActivate@P7S1_Liferay_RestServiceImpl: ' + e.getMessage();
            system.debug(Logginglevel.ERROR, restStatus.message );
        }

        return restStatus;
    }
    
    /*
     * {@inheritDoc}
     */
    public P7S1_Liferay_RestStatus liferayUserDelete(Long userId) {
        system.debug(Logginglevel.INFO, 'entering liferayUserDelete@P7S1_Liferay_RestServiceImpl');
        P7S1_Liferay_RestStatus restStatus = new P7S1_Liferay_RestStatus( false );
        try{
            Http http = new Http();
            HttpRequest request = getHttpRequestDeleteUser( userId );
            system.debug(Logginglevel.DEBUG, 'liferayUserDelete@P7S1_Liferay_RestServiceImpl request ' + request );
            
            HttpResponse response = http.send(request);
            system.debug(Logginglevel.DEBUG, 'liferayUserDelete@P7S1_Liferay_RestServiceImpl response.getBody() ' + response.getBody() );
    
            if ( response.getStatusCode() == 200 ){
                P7S1_Liferay_User liferayUserReceived = P7S1_Liferay_User.parse( response.getBody() );
                system.debug(Logginglevel.DEBUG, 'liferayUserDelete@P7S1_Liferay_RestServiceImpl liferayUserReceived' + liferayUserReceived );
                if (liferayUserReceived.status != 0 && liferayUserReceived.deleted != null && liferayUserReceived.deleted){
                  restStatus.success = true;
                }
            } 
            restStatus.message = 'statusCode : ' + response.getStatusCode() + ' body : ' + response.getBody();
            
        } catch (Exception e){
            restStatus.message = 'Exception liferayUserDelete@P7S1_Liferay_RestServiceImpl: ' + e.getMessage();
            system.debug(Logginglevel.ERROR, restStatus.message );
        }
        return restStatus;
    }
    
  //TODO create a Liefray_RestLientObject to handle all this stuff
    private HttpRequest getHttpRequestUpdateUser(Long userId) {
        String body = 'userId='+userId+'&status=0';
        return getHttpRequest(ENDPOINT_LIFERAY + API_PATH_USER_UPDATE, body);
    }
    
    private HttpRequest getHttpRequestDeleteUser(Long userId) {
        String body = 'userId='+userId;
        return getHttpRequest(ENDPOINT_LIFERAY + API_PATH_USER_DELETE, body);
    }
    
    
    private HttpRequest getHttpRequest(String enpoint, String body) {
        HttpRequest request = oAuthService.getBasicAuthRequest(enpoint );
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        request.setHeader('Accept', 'application/json');
        request.setMethod( HTTP_METHOD_POST );
        request.setBody( body );
        return request;
  }

}