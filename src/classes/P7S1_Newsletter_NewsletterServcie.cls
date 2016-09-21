/**
* Interface thats describes the methods for handling newsletter operations
* newsletter operations
*
* @author  Sebastian Listl
* @version 0.1, 2016-02-15
*/
public interface P7S1_Newsletter_NewsletterServcie {
	
	P7S1_Newsletter__c getStandardNewsletter(P7S1_PortalLogin__c portalLogin);
  	P7S1_Abonnement__c createOrGetNewsletterAbo(P7S1_PortalLogin__c portalLogin);
  	P7S1_Abonnement__c createNewNewsletterAbo(P7S1_PortalLogin__c portalLogin);
	Boolean subscribe(P7S1_Abonnement__c abo);
  	Boolean unsubscribe(P7S1_Abonnement__c abo);
  	P7S1_PortalLoginEvent__c sendNewsletterSubscribeEmail(P7S1_PortalLogin__c portalLogin);
  	
}