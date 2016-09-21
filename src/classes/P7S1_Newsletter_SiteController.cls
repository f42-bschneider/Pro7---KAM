/**
* Implementaion of the P7S1_Newsletter_SiteController inteface
*
* @author  Sebastian Listl
* @version 0.1, 2014-10-12
*/
global class P7S1_Newsletter_SiteController {
    
    public P7S1_Abonnement__c abonnement;
    public String msg {get;set;}
    public String errorCode {get;set;}
    private String abonnementId;
    private String newsletterUnsubscribeSuccessUrl = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_Newsletter_Unsubscribe_Success_Url__c;
    
    public P7S1_Newsletter_SiteController( ) {
        msg = Label.P7S1_SITE_NEWSLETTER_UNSUBSCRIBE_FAILED;
        Map<String, String> params = Apexpages.currentPage().getParameters();
        system.debug(logginglevel.INFO, 'entering P7S1_Newsletter_SiteController@P7S1_Liferay_PortalLoginController');
        abonnementId = params.containsKey('abonnementId') ? params.get('abonnementId') : '';
    }
    
    public PageReference unsubscibeNewsletter() {
        system.debug(logginglevel.INFO, 'entering unsubscibeNewsletter@P7S1_Liferay_PortalLoginController');
        PageReference pr = null;
        
        try {
            abonnement = [SELECT Id, P7S1_Kuendigungsdatum__c, P7S1_PortalLogin__c, Name FROM P7S1_Abonnement__c WHERE Id = :abonnementId];    
            abonnement.P7S1_Kuendigungsdatum__c = system.now();
            Database.UpsertResult usrAbo = Database.upsert(abonnement);
            
            P7S1_PortalLogin__c pl = [SELECT P7S1_Newsletter__c, P7S1_Portal__c FROM P7S1_PortalLogin__c WHERE Id = :abonnement.P7S1_PortalLogin__c];
            Database.UpsertResult usrPl = null;
            if (pl.P7S1_Portal__c.equals(P7S1_Liferay_Constants.PORTAL_ADFACTORY)){
	            pl.P7S1_Newsletter__c = false;
	            usrPl = Database.upsert(pl);
            }
            
            if (usrAbo.isSuccess() && usrPl != null && usrPl.isSuccess()){
                pr = new PageReference(newsletterUnsubscribeSuccessUrl);
            } else {
                msg += ' upsert result Abo: ' + usrAbo + ' upsert result Portal Login: ' + usrPl;
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
                ApexPages.addMessage(errorMsg);
            }
            
       } catch(Exception e){
           msg += abonnementId;
           errorCode = e+'';
           ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorCode);
           ApexPages.addMessage(errorMsg);
       } 
        
        
        return pr;
    }

}