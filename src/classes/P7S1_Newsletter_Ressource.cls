/**
* This class generates the common testdata
*
* @author  Sebastian Listl
* @version 0.1
* @since   2014-11-19
*/
@RestResource(urlMapping='/newsletter/*')
global without sharing class P7S1_Newsletter_Ressource {
	
	global static P7S1_Newsletter_NewsletterServcie newsletterService = new P7S1_Newsletter_NewsletterServcieImpl();
	
	/**
    * method to send the subscibe emails
    * 
    * HTTP-METHOD POST
    * posible actions subscribe-email
    * PATH /services/apexrest/newsletter/subscribe-email/{portalLoginId}
    * @since 0.1
    * @return success of failed
    */
    @HttpPost
    global static String postNewsletter() {
    	system.debug('entering postNewsletter@P7S1_Newsletter_Ressource');
    	String status = 'failed';
    	
    	/*** PATH PARAMS ***/
        String portalLoginId = P7S1_Liferay_ResourceUtil.getIdFromURI( RestContext.request.requestURI );
        String action = P7S1_Liferay_ResourceUtil.getActionFromURI( RestContext.request.requestURI );
    	
    	if (action.equals(P7S1_Liferay_Constants.NEWSLETTER_ACTION_SUBSCRIBE_EMAIL)){
    		P7S1_PortalLogin__c portalLogin = getPortalLoginById(portalLoginId);
    		system.debug(Logginglevel.DEBUG, 'postNewsletter@P7S1_Newsletter_Ressource  :' + P7S1_Liferay_Constants.NEWSLETTER_ACTION_SUBSCRIBE_EMAIL );
			
			String restRequestBody = RestContext.request.requestBody.toString();
			system.debug(Logginglevel.DEBUG, 'postNewsletter@P7S1_Newsletter_Ressource  restRequestBody :' + restRequestBody );

        	String newsLetterSubscribeUrl = P7S1_Liferay_ResourceUtil.getStringValueByKey(P7S1_Liferay_ResourceUtil.JSON_FIELD_NEWSLETTER_SUBSCRIBE_URL, restRequestBody );
        	system.debug('postNewsletter@P7S1_Newsletter_Ressource  newsLetterSubscribeUrl :' + newsLetterSubscribeUrl );
			portalLogin.P7S1_NewsletterSubscribeLink__c = newsLetterSubscribeUrl;
        	Database.Saveresult upsertResult = Database.update( portalLogin, false );
        	system.debug('upsertResult postNewsletter@P7S1_Newsletter_Ressource  confirmationUrl : '+ upsertResult);
			
			if (upsertResult.isSuccess()){
				P7S1_PortalLoginEvent__c portalLoginEvent = newsletterService.sendNewsletterSubscribeEmail(portalLogin);
				status = (portalLoginEvent.P7S1_Successful__c ? 'success' : 'failed');
    		} else {
    			status = 'uspert faield ' + upsertResult; 
    		}
    		
    	} else {
			status = 'unknown action'; 
    	}
    	return status;
    }
    
    private static P7S1_PortalLogin__c getPortalLoginById(String portalLoginId){
       	P7S1_PortalLogin__c portalLogin = null; 
		try {
			portalLogin = [Select Id, Name, P7S1_NewsletterSubscribeLink__c, P7S1_Anrede__c, P7S1_EMail__c, P7S1_Portal__c, P7S1_PortalId__c 
	        		FROM P7S1_PortalLogin__c
	                WHERE Id = :portalLoginId];
        } catch (Exception e){
        	system.debug(Logginglevel.ERROR, 'ERROR query portal login maybe not in db ' + portalLoginId + ' | ' + e);
        }
        return portalLogin; 
    }
}