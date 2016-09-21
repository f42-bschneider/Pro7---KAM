/**
* This is the Testclass for P7S1_Liferay_RegistrationFormBean its tests
*
* init         -  tests the initialization
*
* @author  Sebastian Listl
* @version 0.1, 2014-08-31
* @see P7S1_Liferay_RestService
*/
@isTest
public class P7S1_Liferay_RestService_Test {

	public static long USERID = 20199L;
	public static String LIFERAY_USER_JSON_ACTIVATE = '{"userId":20199,"status":0}';
	public static String LIFERAY_USER_JSON_DELETE = '{"status": 5,"userId": 20199,"deleted": true}';
	public static String LIFERAY_USER_JSON_DELETE_FAILED = '{"status": 0,"userId": 20199,"deleted": false}';
	//public static String LIFERAY_USER_JSON_ACTIVATE = '{"agreedToTermsOfUse":true,"comments":"","companyId":20155,"contactId":20200,"createDate":1439902840000,"defaultUser":false,"emailAddress":"test@liferay.com","emailAddressVerified":true,"facebookId":0,"failedLoginAttempts":0,"firstName":"Test","graceLoginCount":0,"greeting":"Welcome Test Test!","jobTitle":"","languageId":"en_US","lastFailedLoginDate":null,"lastLoginDate":1444239724000,"lastLoginIP":"85.182.255.249","lastName":"Test","ldapServerId":-1,"lockout":false,"lockoutDate":null,"loginDate":1444293280063,"loginIP":"85.182.255.249","middleName":"","modifiedDate":1439902840000,"openId":"","portraitId":0,"reminderQueryAnswer":"test","reminderQueryQuestion":"what-is-your-father\'s-middle-name","screenName":"test","status":0,"timeZoneId":"UTC","userId":20199,"uuid":"96202658-7475-47c7-bf41-0634ce454607"}';
	public static String LIFERAY_USER_JSON_FAILED = '"com.liferay.portal.security.auth.PrincipalException"';
	public static String LIFERAY_AUTH_FAILED = '{"exception": "Authenticated access required"}';
	public static Integer LIFERAY_RESP_SUCCESS = 200;
	public static Integer LIFERAY_RESP_FAILED = 500;

  	/**
  	* Tests the initialization of the APEX class
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
	static testMethod void init() {
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		Test.startTest();
		P7S1_Liferay_RestService liferayRestService = new P7S1_Liferay_RestServiceImpl();
		system.assert( liferayRestService != null );
		Test.stopTest();
	}
    /**
  	* Tests the successful activation of a liferay user
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
    static testMethod void liferayUserActivateSuccess(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
		Test.startTest();
			P7S1_Liferay_RestService liferayRestService = new P7S1_Liferay_RestServiceImpl();
        	system.assert( liferayRestService != null );
			
        	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(LIFERAY_USER_JSON_ACTIVATE, LIFERAY_RESP_SUCCESS ));
      		P7S1_Liferay_RestStatus restStatus = liferayRestService.liferayUserActivate( USERID );
      		system.assert( restStatus != null );
      		system.assert( restStatus.success );
      		system.assertEquals('statusCode : 200 body : {"userId":20199,"status":0}', restStatus.message );
      	Test.stopTest();
    }
    /**
  	* Tests the successful deletion of a liferay user
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
   	
    static testMethod void liferayUserDeleteSuccess(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();

		Test.startTest();
			P7S1_Liferay_RestService liferayRestService = new P7S1_Liferay_RestServiceImpl();
        	system.assert( liferayRestService != null );

        	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(LIFERAY_USER_JSON_DELETE, LIFERAY_RESP_SUCCESS ));
      		P7S1_Liferay_RestStatus restStatus = liferayRestService.liferayUserDelete( USERID );
      		system.debug('###liferayUserDeleteSuccess restStatus### : ' + restStatus);
      		system.assert( restStatus != null );
      		system.assert( restStatus.success );
      		system.assertEquals( 'statusCode : 200 body : {"status": 5,"userId": 20199,"deleted": true}', restStatus.message );
      	Test.stopTest();
      	
    }
    /**
  	* Tests the successful deletion of a liferay user
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
    static testMethod void liferayUserDeleteFailed(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();

		Test.startTest();
			P7S1_Liferay_RestService liferayRestService = new P7S1_Liferay_RestServiceImpl();
        	system.assert( liferayRestService != null );

        	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(LIFERAY_USER_JSON_DELETE_FAILED, LIFERAY_RESP_SUCCESS ));
      		P7S1_Liferay_RestStatus restStatus = liferayRestService.liferayUserDelete( USERID );
      		system.debug('###liferayUserDeleteSuccess restStatus### : ' + restStatus);
      		system.assert( restStatus != null );
      		system.assert( !restStatus.success );
      		system.assertEquals( 'statusCode : 200 body : {"status": 0,"userId": 20199,"deleted": false}', restStatus.message );
      	Test.stopTest();
      	
    }
    /**
  	* Tests the successful deletion of a liferay user
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
    static testMethod void liferayUserDeleteAuthFailed(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();

		Test.startTest();
			P7S1_Liferay_RestService liferayRestService = new P7S1_Liferay_RestServiceImpl();
        	system.assert( liferayRestService != null );

        	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(LIFERAY_AUTH_FAILED, LIFERAY_RESP_SUCCESS ));
      		P7S1_Liferay_RestStatus restStatus = liferayRestService.liferayUserDelete( USERID );
      		system.assert( restStatus != null );
      		system.assert( !restStatus.success );
      		system.assertEquals('statusCode : 200 body : {"exception": "Authenticated access required"}', restStatus.message );
      	Test.stopTest();
      	
    }
    /**
  	* Tests the successful deletion of a liferay user
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
    static testMethod void liferayUserActivationAuthFailed(){
		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();

		Test.startTest();
			P7S1_Liferay_RestService liferayRestService = new P7S1_Liferay_RestServiceImpl();
        	system.assert( liferayRestService != null );

        	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(LIFERAY_AUTH_FAILED, LIFERAY_RESP_SUCCESS ));
      		P7S1_Liferay_RestStatus restStatus = liferayRestService.liferayUserActivate( USERID );
      		system.assert( restStatus != null );
      		system.assert( !restStatus.success );
      		system.assertEquals( 'statusCode : 200 body : {"exception": "Authenticated access required"}', restStatus.message );
      	Test.stopTest();
    }

	/**
  	* Tests the failed activation of a liferay user
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
	static testMethod void liferayUserActivateFailed(){
      	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      	Test.startTest();
      		P7S1_Liferay_RestService liferayRestService = new P7S1_Liferay_RestServiceImpl();
			system.assert( liferayRestService != null );

        	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test(LIFERAY_USER_JSON_FAILED, LIFERAY_RESP_FAILED ));

      		P7S1_Liferay_RestStatus restStatus = liferayRestService.liferayUserActivate( USERID );
      		system.assert( restStatus != null );
      		system.assert( !restStatus.success );
      		system.assertEquals( restStatus.message, 'statusCode : 500 body : "com.liferay.portal.security.auth.PrincipalException"' );
		Test.stopTest();
    }
    /**
  	* Tests execption handling
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
	static testMethod void liferayUserActivateException(){
      	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      	Test.startTest();
      		P7S1_Liferay_RestService liferayRestService = new P7S1_Liferay_RestServiceImpl();
			system.assert( liferayRestService != null );

        	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test('{[}()]', LIFERAY_RESP_SUCCESS ));

      		P7S1_Liferay_RestStatus restStatus = liferayRestService.liferayUserActivate( USERID );
      		system.assert( restStatus != null );
      		system.assert( !restStatus.success );
      		system.assertEquals('Exception liferayUserActivate@P7S1_Liferay_RestServiceImpl: Unexpected character (\'[line:1, column:3]', restStatus.message);
		Test.stopTest();
    }
    /**
  	* Tests execption handling
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
	static testMethod void liferayUserDeleteException(){
      	P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
      	Test.startTest();
      		P7S1_Liferay_RestService liferayRestService = new P7S1_Liferay_RestServiceImpl();
			system.assert( liferayRestService != null );

        	Test.setMock(HttpCalloutMock.class, new P7S1_Liferay_RestCalloutMock_Test('{[}()]', LIFERAY_RESP_SUCCESS ));

      		P7S1_Liferay_RestStatus restStatus = liferayRestService.liferayUserDelete( USERID );
      		system.assert( restStatus != null );
      		system.assert( !restStatus.success );
      		system.assertEquals('Exception liferayUserDelete@P7S1_Liferay_RestServiceImpl: Unexpected character (\'[line:1, column:3]', restStatus.message);
		Test.stopTest();
    }
	/**
  	* Test to get more coverage for this small class
  	* @since 0.1
   	* @see P7S1_Liferay_RestService
   	*/
	static testMethod void testInitLiferayRestStatus(){
   		
   		P7S1_Liferay_TestDataGenerator.setLiferayConfigSettings();
     	Test.startTest();
     	P7S1_Liferay_RestStatus lifeRayRestStatus = new P7S1_Liferay_RestStatus();
     	system.assert( lifeRayRestStatus != null );
     	system.assertEquals(null , lifeRayRestStatus.success );
     	system.assertEquals(null , lifeRayRestStatus.message );

     	system.assertEquals(true , new P7S1_Liferay_RestStatus(true).success );
     	system.assertEquals(false , new P7S1_Liferay_RestStatus(false).success );
     	Test.stopTest();
   }
   
}