/**
* Helperclass for the P7S1_Liferay_PortalLoginEvent__c
* Prepares the PortalLoginEvents for the Service Classes 
* PortalLoginEvent helper methods Object operations
*
* @author  Sebastian Listl
* @version 0.1, 2016-2-2
* @see P7S1_PortalLoginEvent__c, P7S1_Liferay_PortalLoginServiceImpl
*/
public with sharing class P7S1_Liferay_PortalLoginEventUtil {

    public static P7S1_PortalLoginEvent__c createPortalLoginEvent( P7S1_PortalLogin__c portalLogin, String eventType ){
		system.debug('createPortalLoginEvent@P7S1_Liferay_PortalLoginServiceImpl' + portalLogin);
      	
      	P7S1_PortalLoginEvent__c portalLoginEvent = new P7S1_PortalLoginEvent__c();
        portalLoginEvent.P7S1_EventType__c = eventType;
        portalLoginEvent.P7S1_Successful__c = false;
        portalLoginEvent.P7S1_EventTimestamp__c=Datetime.now();
        portalLoginEvent.P7S1_PortalLogin__c=portalLogin.id;

        return portalLoginEvent;
        
    }
    
    
}