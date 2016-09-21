/**
 * Implementation of {@link P7S1_Liferay_EmailService}
 *
 * @author Sebastian Listl
 */
public with sharing class P7S1_Liferay_EmailServiceImpl implements P7S1_Liferay_EmailService {

    public static String SENDER_EMAIL_ADFACTORY = LABEL.P7S1_PORTAL_ADFACTORY_EMAIL;
    public static String SENDER_EMAIL_LIFERAY = LABEL.P7S1_PORTAL_LIFERAY_EMAIL;

    /**
    * {@inheritDoc}
    */
    public Id templateIdByName( String developerName ){
        return [SELECT Id, DeveloperName FROM EmailTemplate where DeveloperName =:developerName].Id;
    }
    /**
    * {@inheritDoc}
    */
    public String getEmailTemplatePrefix( P7S1_PortalLogin__c portalLogin ){
        return ( portalLogin.P7S1_Portal__c.equals(P7S1_Liferay_Constants.PORTAL_ADFACTORY) ? P7S1_Liferay_Constants.PORTAL_EMAIL_TEMPLATE_PREFIX_ADFACTORY : P7S1_Liferay_Constants.PORTAL_EMAIL_TEMPLATE_PREFIX_LIFERAY  );
    }
    /**
    * {@inheritDoc}
    */
    public P7S1_PortalLoginEvent__c sendEmailFromTemplate(P7S1_PortalLogin__c portalLogin, P7S1_PortalLoginEvent__c portalLoginEvent, Id emailTemplateId, String emailAddress ){
        system.debug('#LOG#DEBUG entering sendEmailFromTemplate@P7S1_Liferay_EmailServiceImpl');
        Contact tempContact;

        try {
            tempContact = new Contact(email = emailAddress, firstName = 'TempUser', lastName = 'Mail');
            insert tempContact;
            Messaging.SingleEmailMessage email = createEmail(emailTemplateId, tempContact.Id, portalLogin.Id, portalLogin.P7S1_Portal__c );

            Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            portalLoginEvent.P7S1_Successful__c = sendEmailResults[0].isSuccess();
            portalLoginEvent.P7S1_EventMessage__c = sendEmailResults[0].isSuccess() ? null : sendEmailResults[0].getErrors()+'';

        } catch (Exception e){
            portalLoginEvent.P7S1_EventMessage__c = '#LOG#ERROR Exception in class P7S1_Liferay_EmailServiceImpl' + e;
            portalLoginEvent.P7S1_Successful__c = false;
            system.debug(Logginglevel.ERROR, portalLoginEvent.P7S1_EventMessage__c );
        } finally {
            if (tempContact != null) {
                delete tempContact;
            }
        }
        system.debug('#LOG#DEBUG entering sendEmailFromTemplate@P7S1_Liferay_EmailServiceImpl ple ' + portalLoginEvent);
        return portalLoginEvent;
    }

    /**
    * {@inheritDoc}
    */
    public P7S1_PortalLoginEvent__c sendEmailFromTemplate(P7S1_PortalLogin__c portalLogin, Id emailTemplateId, P7S1_PortalLoginEvent__c portalLoginEvent ){
        return sendEmailFromTemplate( portalLogin, portalLoginEvent, emailTemplateId, portalLogin.P7S1_EMail__c );
    }

    private Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id tempContactId, Id portalLoginId, String portal){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId( emailTemplateId );
        email.setTargetObjectId( tempContactId );
        email.setSaveAsActivity( false );
        email.setWhatId( portalLoginId );
		setSenderMail( email, portal );
        return email;
    }
    
    private void setSenderMail(Messaging.SingleEmailMessage email, String portal) {
    	
    	//WEICHE
    	String senderMail = portal.equals(P7S1_Liferay_Constants.PORTAL_ADFACTORY) ? SENDER_EMAIL_ADFACTORY : SENDER_EMAIL_LIFERAY;
        email.setReplyTo(senderMail);
    	List<OrgWideEmailAddress> orgWideEmailList = [select Id, Address from OrgWideEmailAddress where address = :senderMail];
    	if ( orgWideEmailList != null && orgWideEmailList.size() > 0) {
    		email.setOrgWideEmailAddressId( orgWideEmailList.get(0).id );
    	} else {
    		email.setSenderDisplayName( senderMail );
    	}
    }
}