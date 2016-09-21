/**
 * Implementation of {@link P7S1_Liferay_PortalLoginService}
 *
 * @author Sebastian Listl
 */ 
public with sharing class P7S1_Liferay_PortalLoginServiceImpl implements P7S1_Liferay_PortalLoginService {
	
	P7S1_Liferay_RestService liferayRestService = new  P7S1_Liferay_RestServiceImpl();
  	P7S1_Liferay_EmailService mailService = new  P7S1_Liferay_EmailServiceImpl(); 

	String liferayAdminEmail = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayAdminEmail__c;
	String adFactoryAdminEmail = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_AdfactoryAdminEmail__c;
  	
  	/*
     * {@inheritDoc}
     */
    public P7S1_PortalLogin__c getPortalLogin(String portalLoginId) {
         System.debug('#LOG#DEBUG entering getPortalLogin@P7S1_Liferay_PortalLoginServiceImpl : ');

         P7S1_PortalLogin__c portalLogin = [SELECT Name FROM P7S1_PortalLogin__c WHERE Id =: portalLoginId];
         return portalLogin;
    }

	    /**
	     * {@inheritDoc}
	     */
		public void sendOptInLinkEmailEmail(P7S1_PortalLogin__c portalLogin){
		system.debug('#LOG#DEBUG entering sendOptInLinkEmailEmail@P7S1_Liferay_PortalLoginServiceImpl');
		P7S1_PortalLoginEvent__c portalLoginEvent = createBasePleForOptInLinkMail( portalLogin );

		try {
	      	String templateName = mailService.getEmailTemplatePrefix(portalLogin) + P7S1_Liferay_Constants.PORTAL_EMAIL_TEMPLATE_OPTIN_LINK;
			portalLoginEvent = mailService.sendEmailFromTemplate(portalLogin, mailService.templateIdByName( templateName ), portalLoginEvent );
	    } catch(Exception e){
	            portalLoginEvent.P7S1_EventMessage__c = e.getMessage();
	      system.debug(Logginglevel.ERROR, portalLoginEvent.P7S1_EventMessage__c );
	    } finally {
	      Database.insert( portalLoginEvent );
	    }
    }

    /**
     * {@inheritDoc}
     */
    public void sendActivationEmailToAdmin(P7S1_PortalLogin__c portalLogin) {
		system.debug('#LOG#DEBUG entering sendActivationEmailToAdmin@P7S1_Liferay_PortalLoginServiceImpl');
      	P7S1_PortalLoginEvent__c portalLoginEvent = createBasePleForAdminActivationMail( portalLogin );

        system.debug('#LOG#DEBUG sendActivationEmailToAdmin@P7S1_Liferay_PortalLoginServiceImpl portalLoginEvent ' + portalLoginEvent );
    	String mailaddress = null;
	    try {
	    	
	      	mailaddress = portalLogin.P7S1_Portal__c.equals(P7S1_Liferay_Constants.PORTAL_ADFACTORY) ? adFactoryAdminEmail : liferayAdminEmail;
			
			String templateName = mailService.getEmailTemplatePrefix(portalLogin) + P7S1_Liferay_Constants.PORTAL_EMAIL_TEMPLATE_ADMIN_ACTIVATION;
	      	system.debug('#LOG#DEBUG sendActivationEmailToAdmin@P7S1_Liferay_PortalLoginServiceImpl templateName  ' + templateName );
			portalLoginEvent = mailService.sendEmailFromTemplate( portalLogin, portalLoginEvent, mailService.templateIdByName( templateName  ), mailaddress );
	      	system.debug('#LOG#DEBUG sendActivationEmailToAdmin@P7S1_Liferay_PortalLoginServiceImpl portalLoginEvent after send ' + portalLoginEvent );
	    } catch(Exception e){
	        portalLoginEvent.P7S1_Successful__c = false;
	        portalLoginEvent.P7S1_EventMessage__c = e.getMessage() + (mailaddress == null ? ' no admin email set' : '');
	      system.debug(Logginglevel.ERROR, portalLoginEvent.P7S1_EventMessage__c );
	    } finally {
	      	Database.insert( portalLoginEvent );
	    }
    }

    /**
     * {@inheritDoc}
     */
	public void sendWelcomeEmailToLiferayUser(P7S1_PortalLogin__c portalLogin){
        system.debug('#LOG#DEBUG entering sendWelcomeEmailToLiferayUser@P7S1_Liferay_PortalLoginServiceImpl');

        P7S1_PortalLoginEvent__c ple = createBasePleForWelcomeMail( portalLogin );
        system.debug('#LOG#DEBUG sendWelcomeEmailToLiferayUser@P7S1_Liferay_PortalLoginServiceImpl ple ' + ple);
    	
    	try {
          String templateName = mailService.getEmailTemplatePrefix(portalLogin) + P7S1_Liferay_Constants.PORTAL_EMAIL_TEMPLATE_WELCOME;
          system.debug('#LOG#DEBUG sendWelcomeEmailToLiferayUser@P7S1_Liferay_PortalLoginServiceImpl templateName ' + templateName);
          ple = mailService.sendEmailFromTemplate(portalLogin, mailService.templateIdByName( templateName ), ple );
    	} catch(Exception e){
            ple.P7S1_EventMessage__c=e.getMessage();
            system.debug(LOGGINGLEVEL.ERROR,'#LOG#ERROR sendWelcomeEmailToLiferayUser@P7S1_Liferay_PortalLoginServiceImpl ple ' + ple);
    	} finally {
			Database.insert( ple );
    	}
  	}

	private P7S1_PortalLoginEvent__c createBasePleForOptInLinkMail( P7S1_PortalLogin__c portalLogin ){
		return new P7S1_PortalLoginEvent__c(P7S1_EventType__c = P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_OPTIN,
	                              P7S1_EventTimestamp__c=Datetime.now(),
	                              P7S1_PortalLogin__c=portalLogin.id,
	                              P7S1_Successful__c = false );
	}
	
	private P7S1_PortalLoginEvent__c createBasePleForWelcomeMail( P7S1_PortalLogin__c portalLogin ){
	    return new P7S1_PortalLoginEvent__c(P7S1_EventType__c = P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_WELCOME,
	                              P7S1_EventTimestamp__c=Datetime.now(),
	                              P7S1_PortalLogin__c=portalLogin.id,
	                              P7S1_Successful__c = false );
	}
	
	private P7S1_PortalLoginEvent__c createBasePleForAdminActivationMail( P7S1_PortalLogin__c portalLogin ){
	    return new P7S1_PortalLoginEvent__c(P7S1_EventType__c = P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_ADMIN_ACTIVATION,
	                              P7S1_EventTimestamp__c=Datetime.now(),
	                              P7S1_PortalLogin__c=portalLogin.id );
	}

    /**
     * {@inheritDoc}
     */
    public void activatePortalLoginUserSF(P7S1_PortalLogin__c portalLogin){
      	system.debug('#LOG#DEBUG entering activatePortalLoginUserSF@P7S1_Liferay_PortalLoginServiceImpl');
    	P7S1_PortalLoginEvent__c pleforSalesforceActivation = activateForSalesforce( portalLogin );
    }
    /**
     * {@inheritDoc}
     */
	public void activatePortalLoginUserLiferay(P7S1_PortalLogin__c portalLogin){
		System.debug('#LOG#DEBUG entering activatePortalLoginUserLiferay@P7S1_Liferay_PortalLoginServiceImpl');
    	P7S1_PortalLoginEvent__c pleforLiferayActivation = null;
    	//P7S1_PortalLoginEvent__c pleforLiferayActivation = activateForLiferay( portalLogin );

	    if (!portalLogin.P7S1_Portal__c.equals(P7S1_Liferay_Constants.PORTAL_ADFACTORY)){
	      system.debug('activate for Liferay activatePortalLoginUserLiferay@P7S1_Liferay_PortalLoginServiceImpl');
	      pleforLiferayActivation = activateForLiferay( portalLogin );
	    } else {
	      system.debug('activate for adfactory activatePortalLoginUserLiferay@P7S1_Liferay_PortalLoginServiceImpl');
	      pleforLiferayActivation = activateForAdfactory( portalLogin );
	    }

		system.debug('pleforLiferayActivation activatePortalLoginUserLiferay@P7S1_Liferay_PortalLoginServiceImpl ' + pleforLiferayActivation);
     	if ( pleforLiferayActivation.P7S1_Successful__c ){
			if ( isWelcomeEmailToSend( portalLogin ) ) {
				sendWelcomeEmailToLiferayUser( portalLogin );
			}
		} else {
			system.debug('#LOG#DEBUG entering activatePortalLoginUserLiferay@P7S1_Liferay_PortalLoginServiceImpl TODO: send error mail to admin');
 		}
	}
	
	private boolean isWelcomeEmailToSend( P7S1_PortalLogin__c portalLogin ){
		List<P7S1_PortalLoginEvent__c> pleList = [SELECT P7S1_EventType__c FROM P7S1_PortalLoginEvent__c WHERE P7S1_PortalLogin__c =: portalLogin.id AND P7S1_EventType__c = :P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_WELCOME];
		return pleList.size() > 0 ? false : true;
	}

    private P7S1_PortalLoginEvent__c createPortalLoginEventForSfActivation( P7S1_PortalLogin__c portalLogin ){

      P7S1_PortalLoginEvent__c portalLoginEvent = new P7S1_PortalLoginEvent__c();
        portalLoginEvent.P7S1_EventType__c = P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_SF;
        portalLoginEvent.P7S1_Successful__c = false;
        portalLoginEvent.P7S1_EventTimestamp__c=Datetime.now();
        portalLoginEvent.P7S1_PortalLogin__c=portalLogin.id;

        return portalLoginEvent;
    }

    private P7S1_PortalLoginEvent__c activateForSalesforce ( P7S1_PortalLogin__c portalLogin ) {
      P7S1_PortalLoginEvent__c pleforSalesforceActivation = createPortalLoginEventForSfActivation( portalLogin );
      try {
        portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_ACTIVE;
        Database.upsert( portalLogin );
        pleforSalesforceActivation.P7S1_Successful__c = true;
        system.debug('#LOG#DEBUG activateForSalesforce@P7S1_Liferay_PortalLoginServiceImpl set active for salesforce successful');
      } catch ( Exception e ) {
        system.debug(logginglevel.error, '#LOG#ERROR activateForSalesforce@P7S1_Liferay_PortalLoginServiceImpl set ative for salesforce successful');
          pleforSalesforceActivation.P7S1_EventMessage__c = e.getMessage();
      } finally {
        Database.insert( pleforSalesforceActivation );
      }

      return pleforSalesforceActivation;
  }

    private P7S1_PortalLoginEvent__c activateForLiferay ( P7S1_PortalLogin__c portalLogin ) {
		system.debug(logginglevel.INFO, 'entering activateForLiferay@P7S1_Liferay_PortalLoginServiceImpl');
      	//P7S1_PortalLoginEvent__c pleforLiferayActivation = createPortalLoginEventForLrActivation( portalLogin );
      	P7S1_PortalLoginEvent__c pleforLiferayActivation = P7S1_Liferay_PortalLoginEventUtil.createPortalLoginEvent( portalLogin,P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_LR );

      	try {
      		system.debug(logginglevel.DEBUG, 'activateForLiferay@P7S1_Liferay_PortalLoginServiceImpl#1 portalLogin' + portalLogin);
        	//check field maybe we need another field or a second param in method
       		P7S1_Liferay_RestStatus liferayRestStatus = liferayRestService.liferayUserActivate( Long.valueOf( portalLogin.P7S1_PortalId__c ) );
        	system.debug(logginglevel.DEBUG, 'activateForLiferay@P7S1_Liferay_PortalLoginServiceImpl#2 liferayRestStatus' + liferayRestStatus);
        	if ( liferayRestStatus.success ){
          		portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_LIFERAY_ACTIVE;
          		Database.upsert( portalLogin );
       			pleforLiferayActivation.P7S1_Successful__c = true;
          		system.debug('activateForLiferay@P7S1_Liferay_PortalLoginServiceImpl#3 set active for liferay successful');
        	} else {
        		pleforLiferayActivation.P7S1_EventMessage__c = liferayRestStatus.message;
        		system.debug(logginglevel.ERROR, 'activateForLiferay@P7S1_Liferay_PortalLoginServiceImpl#3 set active for liferay failed');
        	}
      	} catch ( Exception e ) {
        	system.debug(logginglevel.error, 'activateForLiferay@P7S1_Liferay_PortalLoginServiceImpl set active for salesforce successful');
          	pleforLiferayActivation.P7S1_EventMessage__c = e.getMessage();
      	} finally {
        	Database.insert( pleforLiferayActivation );
      	}
      	system.debug(logginglevel.DEBUG,'portalLogin activateForLiferay ' + portalLogin);
      	return pleforLiferayActivation;
  	}

  	private P7S1_PortalLoginEvent__c activateForAdfactory ( P7S1_PortalLogin__c portalLogin ) {
    	system.debug(logginglevel.DEBUG,'entering activateForAdfactory');
    	//P7S1_PortalLoginEvent__c pleforAdfactory = createPortalLoginEventForAFActivation( portalLogin );
    	P7S1_PortalLoginEvent__c pleforAdfactory = P7S1_Liferay_PortalLoginEventUtil.createPortalLoginEvent( portalLogin,P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_AF );

    	try {
      		portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_ADFACTORY_ACTIVE;
        	Database.upsert( portalLogin );
        	pleforAdfactory.P7S1_Successful__c = true;
    	} catch ( Exception e ) {
        	system.debug(logginglevel.error, 'activateForAdfactory@P7S1_Liferay_PortalLoginServiceImpl set ative for salesforce successful');
          	pleforAdfactory.P7S1_EventMessage__c = e.getMessage();
      	} finally {
        	Database.insert( pleforAdfactory );
      	}
      	system.debug(logginglevel.DEBUG,'portalLogin activateForAdfactory ' + portalLogin);
      	return pleforAdfactory;
  	}
  	/**
     * {@inheritDoc}
     */
  	public P7S1_PortalLoginEvent__c deletePortalLogin( P7S1_PortalLogin__c portalLogin ) {
  		system.debug(logginglevel.INFO, 'deletePortalLogin@P7S1_Liferay_PortalLoginServiceImpl');
      	P7S1_PortalLoginEvent__c pleforLiferayUserDelete = P7S1_Liferay_PortalLoginEventUtil.createPortalLoginEvent( portalLogin,P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_DELETED );
      	
      	try {
        	P7S1_Liferay_RestStatus liferayRestStatus = liferayRestService.liferayUserDelete( Long.valueOf( portalLogin.P7S1_PortalId__c ) );
        	system.debug(logginglevel.DEBUG, '#LOG#DEBUG entering deletePortalLogin@P7S1_Liferay_PortalLoginServiceImpl liferayRestStatus' + liferayRestStatus);
        	//check field maybe we need another field or a second param in method
	        if ( liferayRestStatus.success ){
				portalLogin.P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_DELETED;
	          	Database.upsert( portalLogin );
	          	pleforLiferayUserDelete.P7S1_Successful__c = true;
	          	system.debug('pleforLiferayUserDelete@P7S1_Liferay_PortalLoginServiceImpl deleted succesfull');
	        } else {
	        	pleforLiferayUserDelete.P7S1_EventMessage__c = liferayRestStatus.message;
	        	system.debug('pleforLiferayUserDelete@P7S1_Liferay_PortalLoginServiceImpl deleted failed ' + liferayRestStatus.message);	
	        }
      	} catch ( Exception e ) {
        	system.debug(logginglevel.error, '#LOG#ERROR activateForLiferay@P7S1_Liferay_PortalLoginServiceImpl set ative for salesforce successful');
          	pleforLiferayUserDelete.P7S1_EventMessage__c = e.getMessage();
      	} finally {
        	Database.insert( pleforLiferayUserDelete );
      	}
      	system.debug(logginglevel.DEBUG,'portalLogin deletePortalLogin ' + portalLogin);
		/*
      	return pleforLiferayActivation;
      	*/
      	return pleforLiferayUserDelete;
  	}
  	
  	/**
     * {@inheritDoc}
     */
	public P7S1_PortalLoginEvent__c sendDeleteConfirmEmail(P7S1_PortalLogin__c portalLogin){
		system.debug('entering sendDeleteConfirmEmail@P7S1_Liferay_PortalLoginServiceImpl');
		P7S1_PortalLoginEvent__c portalLoginEvent = P7S1_Liferay_PortalLoginEventUtil.createPortalLoginEvent( portalLogin, P7S1_Liferay_Constants.PORTAL_EVENT_EMAIL_SENT_DELETE_CONFIRM );
		system.debug('portalLoginEvent sendDeleteConfirmEmail@P7S1_Liferay_PortalLoginServiceImpl' + portalLoginEvent);
		try {
			system.debug('portalLogin sendDeleteConfirmEmail@P7S1_Liferay_PortalLoginServiceImpl' + portalLogin);
			String templateName = mailService.getEmailTemplatePrefix(portalLogin) + P7S1_Liferay_Constants.PORTAL_EMAIL_TEMPLATE_DEL_CONFIRM;
	        system.debug('templateName sendDeleteConfirmEmail@P7S1_Liferay_PortalLoginServiceImpl' + templateName);
	        portalLoginEvent = mailService.sendEmailFromTemplate(portalLogin, mailService.templateIdByName( templateName ), portalLoginEvent );
	    } catch(Exception e){
			portalLoginEvent.P7S1_EventMessage__c = e.getMessage();
	      	system.debug(Logginglevel.ERROR, portalLoginEvent.P7S1_EventMessage__c );
	    } finally {
			Database.insert( portalLoginEvent );
	    }
	     system.debug('portalLoginEvent sendDeleteConfirmEmail@P7S1_Liferay_PortalLoginServiceImpl' + portalLoginEvent);
	    return portalLoginEvent;
	}


}