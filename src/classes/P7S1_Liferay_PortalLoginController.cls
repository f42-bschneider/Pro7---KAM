/**
* Implementaion of the P7S1_Liferay_RestService inteface
*
* @author  Sebastian Listl
* @version 0.1, 2014-10-12
*/
global class P7S1_Liferay_PortalLoginController {
	private static String MSG_DEL_FAILED = 'Löschen des users in liferay fehlgeschlagen bitte kontaktieren sie den Administrator';
  private P7S1_PortalLogin__c portalLogin;
  private final P7S1_Liferay_PortalLoginService portalLoginService;
  public String output { get; set; }

  /**
     * constructor
     *
     * @param stdController ApexPages.StandardController
     * @since 0.1
     */
  public P7S1_Liferay_PortalLoginController( ApexPages.StandardController stdController ) {
  		system.debug(logginglevel.INFO, 'entering P7S1_Liferay_PortalLoginController@P7S1_Liferay_PortalLoginController');
        portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();
        portalLogin = (P7S1_PortalLogin__c) stdController.getRecord();
        //TODO : workaround for missing email field check for another way
        //portalLogin = getPortalLoginById(portalLogin.Id);
        portalLogin = [Select Id,P7S1_Anrede__c,P7S1_EMail__c,P7S1_Nachname__c,P7S1_PortalId__c,P7S1_Portal__c,P7S1_Portal_Status__c,P7S1_Vorname__c FROM P7S1_PortalLogin__c WHERE Id = :portalLogin.Id];
        system.debug(logginglevel.DEBUG, '#LOG#DEBUG entering P7S1_Liferay_PortalLoginController@P7S1_Liferay_PortalLoginController portalLogin ' + portalLogin);
    }

    /**
     * activates the portal login user
     *
     * @return pageReference portalLogin object from database
     * @since 0.1
     */
     /*@Deprecated
    public PageReference activatePortalLoginUser() {
      system.debug(logginglevel.DEBUG, '#LOG#DEBUG entering activatePortalLoginUser@P7S1_Liferay_PortalLoginController');
      //PageReference pageReference = null;
      try {
        system.debug(logginglevel.DEBUG, '#LOG#DEBUG entering activatePortalLoginUser@P7S1_Liferay_PortalLoginController portalLogin ' + portalLogin);
      portalLoginService.activatePortalLoginUser( portalLogin );
      ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'succefully updated' ) );
      //pageReference = new PageReference('/'+portalLogin.Id); //ApexPages.currentPage();
        } catch(Exception e) {
            output  = 'method passed in catch ' + e;
            ApexPages.addMessages(e);
        }
        return new PageReference('/'+portalLogin.Id);
    }
    */

  	/**
    * Activates the portal login user in salesforce. By calling this method the status of the referenced P7S1_PortalLogin__c object set for the activate for salesforce value.
    * @since 0.1
    */
    public void activatePortalLoginUserSF() {
		system.debug(logginglevel.DEBUG, '#LOG#DEBUG entering activatePortalLoginUserSF@P7S1_Liferay_PortalLoginController');
      	try {
      		portalLoginService.activatePortalLoginUserSF( portalLogin );
		} catch(Exception e) {
			output  = 'activatePortalLoginUserLiferay in catch ' + e;
		}
	}
	
	/**
     * Activates the portal login user in liferay. By calling this method the status of the referenced P7S1_PortalLogin__c object set for the activate for liferay value and sents a welcome email by using the given tamplate.
     * @since 0.1
     */
    public PageReference activatePortalLoginUserLiferay() {
		system.debug(logginglevel.DEBUG, '#LOG#DEBUG entering activatePortalLoginUserLiferay@P7S1_Liferay_PortalLoginController');
      	try {
      		portalLoginService.activatePortalLoginUserLiferay( portalLogin );
		} catch(Exception e) {
			output  = 'activatePortalLoginUserLiferay in catch ' + e;
		}
		return new PageReference('/'+portalLogin.Id);
    }
    /**
     * Deletes the portal login user in liferay. By calling this method the status of the referenced P7S1_PortalLogin__c object set for the activate for liferay value and sents a welcome email by using the given tamplate.
     * @since 0.1
     */
	webservice static String deletePortalLogin(String id){
    	system.debug(logginglevel.INFO, 'entering deletePortalLogin@P7S1_Liferay_PortalLoginController');
      	P7S1_Liferay_PortalLoginService portalLoginService = new P7S1_Liferay_PortalLoginServiceImpl();
      	
      	String msg = MSG_DEL_FAILED;
      	//PageReference pr = null;
      	P7S1_PortalLogin__c portalLogin = null;
      	try {
      		portalLogin = getPortalLoginById(id);
      		system.debug(logginglevel.DEBUG, '### portalLogin' + portalLogin);
      		P7S1_PortalLoginEvent__c ple = portalLoginService.deletePortalLogin( portalLogin );
      		if (ple.P7S1_Successful__c){
      			msg = 'success';
      		} else {
      			system.debug(logginglevel.ERROR, ple.P7S1_EventMessage__c);
      		}
      	} catch(Exception e) {
      		//msg  = 'Exception in deletePortalLogin@P7S1_Liferay_PortalLoginController ' + e;
      		system.debug(logginglevel.ERROR, msg);
		}
		return msg;
    }
    
    private static P7S1_PortalLogin__c getPortalLoginById(String portalLoginId){
    	return [Select Id,P7S1_Anrede__c,P7S1_EMail__c,P7S1_Nachname__c,P7S1_PortalId__c,P7S1_Portal__c,P7S1_Portal_Status__c,P7S1_Vorname__c FROM P7S1_PortalLogin__c WHERE Id = :portalLoginId];
    }

}