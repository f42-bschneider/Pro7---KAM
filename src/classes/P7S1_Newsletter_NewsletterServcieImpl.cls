public with sharing class P7S1_Newsletter_NewsletterServcieImpl implements P7S1_Newsletter_NewsletterServcie {
    
    String newsletterIdAdfactory = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_AdfactoryDefaultNewsletter__c;
    String newsletterIdLiferay = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayDefaultNewsletter__c; 
    String newsletterUnsubscribe_Url = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_Newsletter_Unsubscribe_Url__c;
    
    P7S1_Liferay_EmailService mailService = new  P7S1_Liferay_EmailServiceImpl(); 
    
    public P7S1_Newsletter__c getStandardNewsletter(P7S1_PortalLogin__c portalLogin){
        system.debug('### newsletterIdAdfactory : '+newsletterIdAdfactory);
        system.debug('### newsletterIdLiferay : '+newsletterIdLiferay);
        String newsletterId = (portalLogin.P7S1_Portal__c.equals(P7S1_Liferay_Constants.PORTAL_ADFACTORY) ? newsletterIdAdfactory : newsletterIdLiferay );
        system.debug('getStandardNewsletter ' + newsletterId);
        return [Select Id FROM P7S1_Newsletter__c WHERE Id = :newsletterId LIMIT 1];
    }
    
    /**
    * searching for an existing ect if non exist one will be created
    * @see P7S1_Abonnement__c
    * @param portalLogin object to populate email tempalte
    */
    public P7S1_Abonnement__c createOrGetNewsletterAbo(P7S1_PortalLogin__c portalLogin){
        system.debug('createOrGetNewsletterAbo ' + portalLogin.Id);
        P7S1_Abonnement__c abo;
        try {
            List<P7S1_Abonnement__c> abos = [Select Id, P7S1_PortalLogin__c,P7S1_Contact__c ,P7S1_AbgeschlossenAm__c, P7S1_Kuendigungsdatum__c FROM P7S1_Abonnement__c WHERE P7S1_PortalLogin__c = :portalLogin.Id];//(P7S1_PortalLogin__c=portalLogin.Id,P7S1_AbgeschlossenAm__c=Datetime.now());
            if (abos != null && abos.size() > 0){
                abo = abos.get(0);
            } else {
                abo= createNewNewsletterAbo(portalLogin);               
            }
        } catch(Exception e){
        }
        return abo;
    }
    /**
    * creates new P7S1_Abonnement__c object
    * @see P7S1_Abonnement__c
    * @param portalLogin object to populate email tempalte
    */
    public P7S1_Abonnement__c createNewNewsletterAbo(P7S1_PortalLogin__c portalLogin){
        system.debug('createNewNewsletterAbo ' + portalLogin.Id);
        P7S1_Newsletter__c newsletter= getStandardNewsletter(portalLogin);
        return createNewNewsletterAbo(portalLogin, newsletter);
    }
        
    private P7S1_Abonnement__c createNewNewsletterAbo(P7S1_PortalLogin__c portalLogin, P7S1_Newsletter__c newsletter){
        system.debug('createNewNewsletterAbo portalLogin.Id : ' + portalLogin.Id + 'newsletter.Id: ' + newsletter.Id);
        P7S1_Abonnement__c abo;
        Savepoint sp = Database.setSavepoint();
        try {
            abo = new P7S1_Abonnement__c(P7S1_PortalLogin__c=portalLogin.Id,P7S1_AbgeschlossenAm__c=Datetime.now(), P7S1_Contact__c =portalLogin.P7S1_Contact__c, P7S1_Newsletter__c=newsletter.Id,P7S1_Newsletter_Unsubscribe_Endpoint__c = newsletterUnsubscribe_Url);
            Database.SaveResult saveResult = Database.insert(abo);  
        } catch(Exception e){
            system.debug(LOGGINGLEVEL.ERROR,'ERROR creating P7S1_Abonnement__c object ' + e);
            Database.rollback(sp);
        }
        return abo;
    }
    
    public Boolean subscribe(P7S1_Abonnement__c abo){
        system.debug('subscribe P7S1_Abonnement__c ' + abo.Id);
        boolean success = false;
        
        Savepoint sp = Database.setSavepoint();
        try {   
            abo.P7S1_AbgeschlossenAm__c=Datetime.now();
            abo.P7S1_Newsletter_Unsubscribe_Endpoint__c = newsletterUnsubscribe_Url;
            Database.UpsertResult upsertResult = Database.upsert(abo);
            success = upsertResult.isSuccess();
        } catch(Exception e){
            system.debug(LOGGINGLEVEL.ERROR,'unsubscribe P7S1_Abonnement__c ' + e);
            Database.rollback (sp);
        }
        
        return success;
    }
    
    public Boolean unsubscribe(P7S1_Abonnement__c abo){
        system.debug('unsubscribe P7S1_Abonnement__c ' + abo.Id);
        boolean success = false;
        
        Savepoint sp = Database.setSavepoint();
        try {
            abo.P7S1_Kuendigungsdatum__c=Datetime.now();
            Database.UpsertResult upsertResult = Database.upsert(abo);
            success = upsertResult.isSuccess();
        } catch(Exception e){
            system.debug(LOGGINGLEVEL.ERROR,'unsubscribe P7S1_Abonnement__c ' + e);
            Database.rollback (sp);
        }
        
        return success;
    }
    
    public P7S1_PortalLoginEvent__c sendNewsletterSubscribeEmail(P7S1_PortalLogin__c portalLogin) {
        system.debug('entering sendNewsletterSubscribeEmail@P7S1_Newsletter_NewsletterServiceImpl');
        //just for method
        P7S1_PortalLoginEvent__c portalLoginEvent = P7S1_Liferay_PortalLoginEventUtil.createPortalLoginEvent(portalLogin, P7S1_Liferay_Constants.PORTAL_EVENT_NEWSLETTER_SUBSCRIBE_CONFIRM_SEND);

        try {
            String templateName = mailService.getEmailTemplatePrefix(portalLogin) + P7S1_Liferay_Constants.NEWSLETTER_TEMPLATE_SUBSCRIBE_EMAIL;
            system.debug('templateName@P7S1_Newsletter_NewsletterServiceImpl: ' + templateName);
            portalLoginEvent = mailService.sendEmailFromTemplate(portalLogin, mailService.templateIdByName( templateName ), portalLoginEvent );
        } catch(Exception e){
            system.debug(Logginglevel.ERROR, 'exception sendNewsletterSubscribeEmail@P7S1_Newsletter_NewsletterServiceImpl' );
            portalLoginEvent.P7S1_Successful__c = false;
            portalLoginEvent.P7S1_EventMessage__c = e.getMessage();
        } finally {
            Database.insert( portalLoginEvent );
        }
        return portalLoginEvent;
    }
    
}