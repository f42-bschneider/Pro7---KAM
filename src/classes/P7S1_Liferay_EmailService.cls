/**
* Interface thats describes the methods for handling liferay portal mailing
*
* @author  Sebastian Listl
* @version 0.1, 2014-10-15
* @see P7S1_PortalLoginEvent__c, P7S1_Liferay_EmailServiceImpl
*/
public interface P7S1_Liferay_EmailService {

  /**
     * Returns the id for the given developerName of the email template
     *
     * @param developerName field developerName of the EmailTemplate Object
     * @return id of the template
     */
  Id templateIdByName( String developerName );

  /**
     * Returns the email template prefix for the given portal
     *
     * @param portalLogin  Object
     * @return prefix of the template
     */
  String getEmailTemplatePrefix( P7S1_PortalLogin__c portalLogin );

  /**
     * Returns the portal login event with the status information
     *
     * @param portalLogin object to populate email tempalte
     * @param emailTemplateId id from the tempalte witch should use
     * @param ple with action stauts pre-populated protal login event
     * @param email with action stauts pre-populated protal login event
     *
     * @return portalLoginEvent
     */
  P7S1_PortalLoginEvent__c sendEmailFromTemplate(P7S1_PortalLogin__c portalLogin, P7S1_PortalLoginEvent__c portalLoginEvent, Id emailTemplateId, String emailAddress );

  /**
     * Returns the portal login event with the status information
     *
     * @param portalLogin object to populate email tempalte
     * @param emailTemplateId id from the tempalte witch should use
     * @param ple with action stauts pre-populated protal login event
     *
     * @return portalLoginEvent
     */
  P7S1_PortalLoginEvent__c sendEmailFromTemplate(P7S1_PortalLogin__c portalLogin, Id emailTemplateId, P7S1_PortalLoginEvent__c portalLoginEvent );
}