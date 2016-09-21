/**
* This is the Testclass for P7S1_Liferay_User APEX class
*
* @author  Sebastian Listl
* @version 0.1, 2015-10-01
*/
@isTest
private class P7S1_Liferay_User_Test {

	public static String LIFERAY_USER_JSON = '{"userId":123,"status":0,"deleted":true}';

	static testMethod void init() {
      	P7S1_Liferay_User liferayUser = new P7S1_Liferay_User( 123L, 0 );
    	system.assert(liferayUser != null);
    	liferayUser = new P7S1_Liferay_User( );
    	system.assert(liferayUser != null);
    }

    static testMethod void deserialize() {
	    P7S1_Liferay_User liferayUser = P7S1_Liferay_User.parse(LIFERAY_USER_JSON);
	    system.assert(liferayUser != null);
	    system.assertEquals(liferayUser.userId, 123);
	    system.assertEquals(liferayUser.status, 0);
	    system.assertEquals(true, liferayUser.deleted);
    }

    static testMethod void serialize1() {
		P7S1_Liferay_User liferayUser = new P7S1_Liferay_User( 123L, 0 );
		system.assertEquals('{"userId":123,"status":0,"deleted":false}', liferayUser.toJson());
    }
    static testMethod void serialize2() {
		P7S1_Liferay_User liferayUser = new P7S1_Liferay_User( 123L, 0, true );
		system.assertEquals(LIFERAY_USER_JSON, liferayUser.toJson());
	}

}