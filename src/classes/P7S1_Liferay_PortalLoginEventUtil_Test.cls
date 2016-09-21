/**
* This is the Testclass for P7S1_Liferay_PortalLoginEventUtil.cls 

*
* @author  Sebastian Listl
* @version 0.1
* @since   2016-02-02
* @see P7S1_Liferay_PortalLoginEventUtil.cls
* @see P7S1_PortalLoginEvent__c
*/
@isTest
private class P7S1_Liferay_PortalLoginEventUtil_Test {
	
	static testmethod void createPortalLoginEvent(){
        
        P7S1_PortalLogin__c portalLogin = P7S1_Liferay_TestDataGenerator.createPortalLogin(true);
		system.assert(portalLogin != null);
		system.assert(portalLogin.Id != null);
		
		P7S1_PortalLoginEvent__c portalLoginEvent = P7S1_Liferay_PortalLoginEventUtil.createPortalLoginEvent( portalLogin, P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_DELETED );
		system.assert(portalLoginEvent != null);
		system.assertEquals(false, portalLoginEvent.P7S1_Successful__c);
		system.assertEquals(P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_DELETED, portalLoginEvent.P7S1_EventType__c);
	
	}
}