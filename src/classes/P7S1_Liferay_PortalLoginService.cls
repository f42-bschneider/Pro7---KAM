/**
* Interface thats describes the methods for handling liferay portal operations
* Email operations
* PortalLogin Object operations
*
* @author  Sebastian Listl
* @version 0.1, 2014-10-15
* @see P7S1_PortalLoginEvent__c, P7S1_Liferay_EmailServiceImpl, P7S1_Liferay_PortalLoginServiceImpl
*/
public interface P7S1_Liferay_PortalLoginService {

  /**
     * Gets the object by id
     *
     * @param portalLoginId id from the portal login object
     * @return portalLogin object from database
     *
     */
  P7S1_PortalLogin__c getPortalLogin(String portalLoginId);

  /**
  * @Deprecated
  */
  //void sendEmail(P7S1_PortalLogin__c portalLogin);

  /**
     * Sends a email to the liferay user after liferay-plugin calls the rest Service with the RegistraionBean data and the portalLogin object is  successfully stored in salesforce
     *
     * @param portalLogin object to populate email tempalte
     */
  void sendOptInLinkEmailEmail(P7S1_PortalLogin__c portalLogin);

  /**
     * Sends a email to the salesforce admin after liferay has submit the activation link form the activation mail
     *
     * @param portalLogin object to populate email tempalte
     */
  void sendActivationEmailToAdmin(P7S1_PortalLogin__c portalLogin);

  /**
     * Sends the welcome mail to the liferay user after admin had active them
     *
     * @param portalLogin object to populate email tempalte
     */
  void sendWelcomeEmailToLiferayUser(P7S1_PortalLogin__c portalLogin);
    /**
     * Sends the confirm email to portal user
     *
     * @param portalLogin object to populate email tempalte
     * @Return P7S1_PortalLoginEvent__c
     */
	P7S1_PortalLoginEvent__c sendDeleteConfirmEmail(P7S1_PortalLogin__c portalLogin);

  /**
     * Activates user in salesforce and liferay and afterwards sending a welcome email to the useremail
     * Includes activatePortalLoginUserSF, activatePortalLoginUserLiferay and sendWelcomeEmailToLiferayUser
     *
     * @param portalLogin object to populate email tempalte
     * @Deprecated
     */
  //void activatePortalLoginUser(P7S1_PortalLogin__c portalLogin);

  /**
     * Activates user in salesforce
     * Includes activatePortalLoginUserSF, activatePortalLoginUserLiferay and sendWelcomeEmailToLiferayUser
     *
     * @param portalLogin object to populate email tempalte
     */
  void activatePortalLoginUserSF(P7S1_PortalLogin__c portalLogin);

  /**
     * Activates user in liferay using the rest api
     * Includes activatePortalLoginUserSF, activatePortalLoginUserLiferay and sendWelcomeEmailToLiferayUser
     *
     * @param portalLogin object to populate email tempalte
     */
  void activatePortalLoginUserLiferay(P7S1_PortalLogin__c portalLogin);
  
  	/**
  	 * connects to liferay api and sets user eleted after successfull response setting status to deleted 
     *
     * @param portalLogin object to delete
	*/
  	P7S1_PortalLoginEvent__c deletePortalLogin( P7S1_PortalLogin__c portalLogin );
   
}