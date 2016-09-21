/**
* Rest Resource controller for PortalLogin Operations
*
* PATH /services/apexrest/portalLogin
*
* @author  Sebastian Listl
* @version 0.1
* @since   0.1, 2014-08-27
*/
@RestResource(urlMapping='/portalLogin/*')
global without sharing class P7S1_Liferay_PortalLoginResource {
    global static List<String> ALLOWED_PORTALS = new List<String> { P7S1_Liferay_Constants.PORTAL_SEVEN_ONE_MEDIA, P7S1_Liferay_Constants.PORTAL_SEVEN_ONE_MEDIA_CH, P7S1_Liferay_Constants.PORTAL_SEVEN_ONE_MEDIA_COM, P7S1_Liferay_Constants.PORTAL_ADFACTORY };
    global static P7S1_Liferay_PortalLoginServiceImpl plservice = new P7S1_Liferay_PortalLoginServiceImpl();
    global static P7S1_Newsletter_NewsletterServcie newsletterService = new P7S1_Newsletter_NewsletterServcieImpl();
    
    /**
    * REST Resource serves the Portal Login object by an id
    *
    * HTTP-METHOD GET
    *
    * @since 0.1
    * @see P7S1_Liferay_RegistrationFormBean, P7S1_PortalLogin__c, P7S1_PortalLoginEvent__c
    *
    * @param portalLoginId request parameter
    * @return portalLogin object from database
    */
    @HttpGet
    global static P7S1_Liferay_RestResponse getPortalLogin() {
         System.debug('#LOG#DEBUG entering getPortalLogin@P7S1_Liferay_PortalLoginResource : ');

         P7S1_PortalLogin__c portalLogin = null;
         String portalLoginId = RestContext.request.params.get('portalLoginId');
         P7S1_Liferay_RestResponse response = new P7S1_Liferay_RestResponse();

         try {
            portalLogin = plservice.getPortalLogin(portalLoginId);
            response.result = portalLogin;
            response.success = true;
            response.errors = new String[]{};
         } catch (Exception e){
            system.debug(Logginglevel.ERROR, '#LOG#ERROR getting Portal_Login__c @ getPortalLogin in class P7S1_Liferay_PortalLoginResource' + e);
            response.success = false;
            response.errors = new String[]{e.getMessage()};
         }

         return response;
    }

    /**
    * REST Resource creates an Portaluser object from an incoming json representation of the P7S1_Liferay_RegistrationFormBean.
    * After succefull Database insert an email is sent to the email address
    * Two objects of P7S1_PortalLoginEvent__c with stauts "created" and "email-sent-optin-link" created
    *
    * HTTP-METHOD POST
    *
    * @since 0.1
    * @return response P7S1_Liferay_RestResponse contains the json representaion of the created objeect
    * @see P7S1_Liferay_RegistrationFormBean, P7S1_PortalLogin__c, P7S1_PortalLoginEvent__c
    */
    @HttpPost
    global static P7S1_Liferay_RestResponse createPortalLogin() {
        system.debug('#LOG#DEBUG entering createPortalLogin@P7S1_Liferay_PortalLoginResource');
        P7S1_Liferay_RestResponse response = new P7S1_Liferay_RestResponse();
        P7S1_PortalLogin__c portalLogin = null;
        P7S1_PortalLoginEvent__c portalLoginEvent = new P7S1_PortalLoginEvent__c( P7S1_EventType__c= P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_CREATED ,P7S1_EventTimestamp__c=Datetime.now(), P7S1_Successful__c=false );

        RestRequest request = RestContext.request;
        String restRequestBody = (request.requestBody != null ? request.requestBody.toString() : '');
        Savepoint sp = Database.setSavepoint();
        system.debug(Logginglevel.DEBUG, '#LOG#DEBUG before try createPortalLogin@P7S1_Liferay_PortalLoginResource restRequestBody : ' +restRequestBody );
        try {
            P7S1_Liferay_RegistrationFormBean registrationFormBean = P7S1_Liferay_RegistrationFormBean.parse( restRequestBody );
            validateCreatePortalLogin( registrationFormBean );
            portalLogin = registrationFormBean.toSfPortalLogin();
            portalLogin = setPortalLoginContactByEmail( portalLogin );
            system.debug(Logginglevel.DEBUG, '#LOG#DEBUG createPortalLogin@P7S1_Liferay_PortalLoginResource portalLogin : ' + portalLogin );
            
            Database.SaveResult saveResult = Database.insert( portalLogin, false );
            system.debug(Logginglevel.DEBUG, '#LOG#DEBUG saveResult in createPortalLogin@P7S1_Liferay_PortalLoginResource :' + saveResult );
            portalLoginEvent.P7S1_PortalLogin__c = portalLogin.Id;
            portalLoginEvent.P7S1_Successful__c = saveResult.isSuccess();
            portalLoginEvent.P7S1_EventMessage__c = ( saveResult.isSuccess() ? restRequestBody : saveResult.getErrors()+'' );
            
            setAbonnementForPortalLoginCreate(portalLogin);
            
        } catch (Exception e){
            portalLoginEvent.P7S1_EventMessage__c = ''+e;
            system.debug(Logginglevel.ERROR, '#LOG#ERROR saving Portal_Login__c @ createPortalLogin in class P7S1_Liferay_PortalLoginResource ' + portalLoginEvent.P7S1_EventMessage__c );
        } finally {
            if (!portalLoginEvent.P7S1_Successful__c){
                Database.rollback( sp );
            }
            Database.insert( portalLoginEvent );
            system.debug(Logginglevel.DEBUG, '#LOG#DEBUG event should be there createPortalLogin@P7S1_Liferay_PortalLoginResource portalLoginEvent :' + portalLoginEvent );
        }

        if (portalLoginEvent.P7S1_Successful__c){
            plservice.sendOptInLinkEmailEmail( portalLogin );
        }
        return createResponse (portalLogin, portalLoginEvent);
    }

    private static void validateCreatePortalLogin( P7S1_Liferay_RegistrationFormBean registrationFormBean ){
        if (registrationFormBean.email == null || registrationFormBean.email.equals('') ){
            throw new LiferayRestValidationException('missing requiered field email');
        }
        if (registrationFormBean.portal == null || !contains(ALLOWED_PORTALS, registrationFormBean.portal) ){
            throw new LiferayRestValidationException('invalid or missing requiered field portal');
        }
        if (registrationFormBean.id == null){
            throw new LiferayRestValidationException('missing requiered field id');
        }
        if (registrationFormBean.activationLink == null){
            throw new LiferayRestValidationException('missing requiered field activationLink');
        }
        String portalId = String.valueOf(registrationFormBean.id);
        List<P7S1_PortalLogin__c> portalLogins= [Select P7S1_Portal__c, P7S1_EMail__c, P7S1_PortalId__c, Id From P7S1_PortalLogin__c WHERE P7S1_EMail__c = :registrationFormBean.email AND  P7S1_Portal__c = :registrationFormBean.portal AND P7S1_PortalId__c =:portalId AND P7S1_Portal_Status__c != :P7S1_Liferay_Constants.PORTAL_STATUS_DELETED];
        if ( portalLogins != null  && portalLogins.size() > 0){
            throw new LiferayRestValidationException('portaluser already exist');
        }
    }

    private static boolean contains(List<String> allStrings, String stringToCompare){
        boolean contains = false;
        for (String stringFromList : allStrings){
            if (stringFromList.equals(stringToCompare)){
                contains = true;
                break;
            }
        }
        return contains;
    }

    private static P7S1_Liferay_RestResponse createResponse ( P7S1_PortalLogin__c portalLogin, P7S1_PortalLoginEvent__c portalLoginEvent){

        P7S1_Liferay_RestResponse response = new P7S1_Liferay_RestResponse();
        response.result = portalLogin;
        response.success = portalLoginEvent.P7S1_Successful__c;
        response.errors = new String[]{portalLoginEvent.P7S1_EventMessage__c};

        return response;
    }

    /**
    * REST Resource modifies the portalLogin object belongs to the action
    *
    * posible actions update/activate/confirm
    * HTTP-METHOD PUT
    * PATH /services/apexrest/portalLogin/{action}/{portalLoginId}
    *
    * @since 0.1
    * @see P7S1_Liferay_RegistrationFormBean, P7S1_PortalLogin__c, P7S1_PortalLoginEvent__c
    * @param portalLoginId id of the portal login object in salesforce
    * @param action
    * @return response P7S1_Liferay_RestResponse contains the json representaion of the updated objeect
    */
    @HttpPut
    global static P7S1_Liferay_RestResponse updatePortalLogin(){
        System.debug('#LOG#DEBUG entering updatePortalLogin@P7S1_Liferay_PortalLoginResource : ');

        P7S1_Liferay_RestResponse response = new P7S1_Liferay_RestResponse();
        P7S1_PortalLogin__c portalLogin = null;
        response.success = false;
        String message = '';

        String portalLoginId = P7S1_Liferay_ResourceUtil.getIdFromURI( RestContext.request.requestURI );
        String action = P7S1_Liferay_ResourceUtil.getActionFromURI( RestContext.request.requestURI );

        Savepoint sp = Database.setSavepoint();
        P7S1_PortalLoginEvent__c portalLoginEvent = null;
        try {
            portalLoginEvent = new P7S1_PortalLoginEvent__c( P7S1_EventTimestamp__c=Datetime.now(),P7S1_PortalLogin__c= portalLoginId );
            validateActionUpdateConfirmActivatePortalLogin(action, portalLoginId);
            
            if ( action.equals ( P7S1_Liferay_Constants.ACTION_CONFIRM ) ){
                system.debug(Logginglevel.DEBUG, '#LOG#DEBUG entering confirm action updatePortalLogin@P7S1_Liferay_PortalLoginResource' );
                portalLoginEvent.P7S1_EventType__c = P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_CONFIRMED;
                portalLogin = setPortalLoginStatus(portalLogin, P7S1_Liferay_Constants.PORTAL_STATUS_INACTIVE, portalLoginId);
                system.debug(Logginglevel.DEBUG, '#LOG#DEBUG updatePortalLogin@P7S1_Liferay_PortalLoginResource ' + portalLogin  );
            }
            if ( action.equals ( P7S1_Liferay_Constants.ACTION_ACTIVATE ) ){
                system.debug(Logginglevel.DEBUG, '#LOG#DEBUG entering activate action updatePortalLogin@P7S1_Liferay_PortalLoginResource' );
                portalLoginEvent.P7S1_EventType__c = P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_ACTIVATED_SF;
                portalLogin = setPortalLoginStatus( portalLogin, P7S1_Liferay_Constants.PORTAL_STATUS_ACTIVE, portalLoginId);
            }
            if ( action.equals ( P7S1_Liferay_Constants.ACTION_UPDATE ) ){
                system.debug(Logginglevel.DEBUG, '#LOG#DEBUG entering update action updatePortalLogin@P7S1_Liferay_PortalLoginResource' );
                portalLoginEvent.P7S1_EventType__c=P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_UPDATED;
                String restRequestBody = (RestContext.request.requestBody != null ? RestContext.request.requestBody.toString() : '');
                portalLogin = getPortalLoginById(portalLoginId);
                portalLogin = P7S1_Liferay_ResourceUtil.dynamicJsonUpdate( portalLogin, restRequestBody );
                validateActionUpdatePortalLogin( portalLogin );
                portalLogin = setPortalLoginContactByEmail( portalLogin );
                setAbonnementForPortalLoginUpdate(portalLogin, restRequestBody);
            }

            Database.Upsertresult upsertResult = Database.upsert( portalLogin, false );
            system.debug(Logginglevel.DEBUG, '#LOG#DEBUG upsertResult in updatePortalLogin@P7S1_Liferay_PortalLoginResource :' + upsertResult );
            response.success = upsertResult.isSuccess();
            //response.success = isSuccess;

            if ( action.equals ( P7S1_Liferay_Constants.ACTION_UPDATE ) ){
                response.result = getPortalLoginById(upsertResult.id);
            } else {
                response.result = [SELECT Name, P7S1_Portal_Status__c FROM P7S1_PortalLogin__c Where id = :upsertResult.id];
            }

        } catch (Exception e){
            portalLoginEvent.P7S1_EventMessage__c = ''+e;
            response.errors = new String[]{e.getMessage()};
            response.success = false;
            system.debug(Logginglevel.ERROR, '#LOG#ERROR saving Portal_Login__c @ updatePortalLogin in class P7S1_Liferay_PortalLoginResource' + e);
        } finally {
            if (!response.success){
                Database.rollback( sp );
            }
            portalLoginEvent.P7S1_Successful__c = response.success;
            Database.insert( portalLoginEvent );
            if ( action.equals( P7S1_Liferay_Constants.ACTION_CONFIRM ) && response.success )
                plservice.sendActivationEmailToAdmin(portalLogin);
        }

        return response;
    }

    private static P7S1_PortalLogin__c getPortalLoginById(String portalLoginId){
        try {
            return [Select Id, Name, P7S1_Titel__c, P7S1_Nachname__c,P7S1_Portal_Status__c, P7S1_Vorname__c, P7S1_Anrede__c, P7S1_EMail__c, P7S1_Firma__c, P7S1_Fax__c,P7S1_Telefon__c, P7S1_Strasse__c, P7S1_Hausnummer__c, P7S1_Postleitzahl__c, P7S1_Ort__c, P7S1_Land__c, P7S1_Geburtstag__c, P7S1_Portal__c, P7S1_PortalId__c, P7S1_Unternehmensart__c
                    FROM P7S1_PortalLogin__c
                    WHERE Id = :portalLoginId];
        } catch (Exception e){
            throw e;
        }
    }

    private static P7S1_PortalLogin__c setPortalLoginStatus(P7S1_PortalLogin__c portalLogin, String status, String portalLoginId){
        try {
            portalLogin = [SELECT Id, P7S1_Portal_Status__c,P7S1_Portal__c FROM P7S1_PortalLogin__c WHERE id = :portalLoginId];
            portalLogin.P7S1_Portal_Status__c = status;
        } catch (Exception e){
            throw e;
        }
        return portalLogin;
    }
    
     private static P7S1_PortalLogin__c setPortalLoginContactByEmail( P7S1_PortalLogin__c portalLogin ){
        try {
            String currentPortalLoginEmail = portalLogin.P7S1_EMail__c;
            List<Contact> contactList = [SELECT Id, Email FROM Contact WHERE Email = :currentPortalLoginEmail LIMIT 1];
            if (contactList.size() > 0) {
                portalLogin.P7S1_Contact__c = contactList.get(0).id;
            } else { 
                portalLogin.P7S1_Contact__c = null;
            }
        } catch (Exception e){
            throw e;
        }
        return portalLogin;
    }
    
    private static boolean setAbonnementForPortalLoginCreate( P7S1_PortalLogin__c portalLogin ){
        try {
            //creates an P7S1_Abonnement__c object 
            if (portalLogin.P7S1_Newsletter__c){
                P7S1_Abonnement__c abonnement = newsletterService.createOrGetNewsletterAbo(portalLogin);
                return newsletterService.subscribe(abonnement);
                //TODO create newsletter event object for better error handling
            }
        } catch (Exception e){
            throw e;
        }
        return false;
    }
    
    private static boolean setAbonnementForPortalLoginUpdate( P7S1_PortalLogin__c portalLogin, String restRequestBody ){
        try {
            Boolean newsletter = P7S1_Liferay_ResourceUtil.getBooleanValueByKey(P7S1_Liferay_ResourceUtil.JSON_FIELD_NEWSLETTER, restRequestBody );
            
            if ( newsletter != null ){
                P7S1_Abonnement__c abonnement = newsletterService.createOrGetNewsletterAbo(portalLogin);
                if (portalLogin.P7S1_Newsletter__c){
                    //TODO create newsletter event object for better error handling
                    return newsletterService.subscribe(abonnement);
                } else {
                    //TODO create newsletter event object for better error handling
                    return newsletterService.unsubscribe(abonnement);
                }
            }
            //creates an P7S1_Abonnement__c object 
        } catch (Exception e){
            throw e;
        }
        return false;
    }
    
    private static void validateActionUpdatePortalLogin( P7S1_PortalLogin__c portalLogin ){
        List<P7S1_PortalLogin__c> portalLogins= [Select P7S1_Portal__c, P7S1_EMail__c, P7S1_PortalId__c, Id From P7S1_PortalLogin__c WHERE P7S1_EMail__c = :portalLogin.P7S1_EMail__c AND  P7S1_Portal__c = :portalLogin.P7S1_Portal__c AND P7S1_PortalId__c =:portalLogin.P7S1_PortalId__c AND P7S1_Portal_Status__c != :P7S1_Liferay_Constants.PORTAL_STATUS_DELETED AND id != :portalLogin.Id];
        if ( portalLogins != null  && portalLogins.size() > 0){
            throw new LiferayRestValidationException('another portaluser already exist with this email');
        }
    }
    
    private static void validateActionUpdateConfirmActivatePortalLogin( String action, String portalLoginId ){
        P7S1_PortalLogin__c portalLogin = [SELECT Id, P7S1_Portal_Status__c FROM P7S1_PortalLogin__c WHERE id = :portalLoginId];
        if ( portalLogin == null || P7S1_Liferay_Constants.PORTAL_STATUS_DELETED.equals( portalLogin.P7S1_Portal_Status__c ) ) {
            throw new LiferayRestValidationException('action ' + action + ' is not possible, portaluser is already deleted');
        }
    }
    private static void validateActionDeleteConfirm(RestRequest req, P7S1_PortalLogin__c portalLogin){
        String restRequestBody = (req.requestBody != null ? req.requestBody.toString() : '');
        if (req.requestBody == null || req.requestBody.toString() == ''){
            throw new LiferayRestValidationException('no content in request body where is confirmDeleteUrl');
        }
       
        String value = P7S1_Liferay_ResourceUtil.getStringValueByKey(P7S1_Liferay_ResourceUtil.JSON_FIELD_CONFIRM_DELETE_URL, restRequestBody );
        if ( value == null || value == ''){
            throw new LiferayRestValidationException('No or invalid for field : confirmDeleteUrl'); 
        }
        if (value != null && value.length() > 255 ){
        	system.debug('### value confirmDeleteUrl: ' + value + ' value.length(): ' + value.length());
            throw new LiferayRestValidationException('confirmDeleteUrl too long just 255 characters');    
        }
        if (portalLogin.P7S1_Portal_Status__c == P7S1_Liferay_Constants.PORTAL_STATUS_DELETED ){
            throw new LiferayRestValidationException('portalLogin status is already deleted');
        }
    }
    
    /**
    * REST Resource sets the status of the portalLogin object to "Gelöscht"
    * HTTP-METHOD DELETE
    * PATH /services/apexrest/portalLogin/{action}/{portalLoginId}
    *
    * @since 0.1
    * @see P7S1_Liferay_RegistrationFormBean, P7S1_PortalLogin__c, P7S1_PortalLoginEvent__c
    * @param portalLoginId id of the portal login object in salesforce
    * @return response P7S1_Liferay_RestResponse contains the json representaion of the updated objeect
    */
    @HttpDelete
    global static P7S1_Liferay_RestResponse deletePortalLogin(){
        system.debug('entering deletePortalLogin@P7S1_Liferay_PortalLoginResource');
        
        P7S1_Liferay_RestResponse response = new P7S1_Liferay_RestResponse();
        P7S1_PortalLogin__c portalLogin = null;
        response.success = false;
        
        /*** PATH PARAMS ***/
        String portalLoginId = P7S1_Liferay_ResourceUtil.getIdFromURI( RestContext.request.requestURI );
        String action = P7S1_Liferay_ResourceUtil.getActionFromURI( RestContext.request.requestURI );


        Savepoint sp = Database.setSavepoint();
        try {
            portalLogin = getPortalLoginById(portalLoginId);
            if ( action.equals ( P7S1_Liferay_Constants.ACTION_DELETE ) ){
                portalLogin = setPortalLoginStatus(portalLogin, P7S1_Liferay_Constants.PORTAL_STATUS_DELETED, portalLoginId);
                Database.Saveresult upsertResult = Database.update( portalLogin, false );
                system.debug(Logginglevel.DEBUG, '#LOG#DEBUG upsertResult in deletePortalLogin@P7S1_Liferay_PortalLoginResource :' + upsertResult );
                response.success = upsertResult.isSuccess();
                //create response
                response.result = portalLogin;
            }
            if ( action.equals ( P7S1_Liferay_Constants.ACTION_CONFIRM ) ){
                system.debug(Logginglevel.DEBUG, 'deletePortalLogin@P7S1_Liferay_PortalLoginResource  :' + P7S1_Liferay_Constants.ACTION_CONFIRM );
                validateActionDeleteConfirm(RestContext.request, portalLogin);
                
                String restRequestBody = RestContext.request.requestBody.toString();
                system.debug(Logginglevel.DEBUG, 'deletePortalLogin@P7S1_Liferay_PortalLoginResource  restRequestBody :' + restRequestBody );

                String confirmationUrl = P7S1_Liferay_ResourceUtil.getStringValueByKey(P7S1_Liferay_ResourceUtil.JSON_FIELD_CONFIRM_DELETE_URL, restRequestBody );
                system.debug(Logginglevel.DEBUG, 'deletePortalLogin@P7S1_Liferay_PortalLoginResource  confirmationUrl :' + confirmationUrl );

                portalLogin.P7S1_DeleteConfirmLink__c = confirmationUrl;
                system.debug(Logginglevel.DEBUG, 'after Dele deletePortalLogin@P7S1_Liferay_PortalLoginResource  confirmationUrl');
                Database.Saveresult upsertResult = Database.update( portalLogin, false );

                P7S1_PortalLoginEvent__c ple = plservice.sendDeleteConfirmEmail(portalLogin);
                
                response.success = ple.P7S1_Successful__c;
                if (!response.success){
                    response.errors = new String[]{ple.P7S1_EventMessage__c};
                }
                
            } 
         } catch (Exception e){
            response.errors = new String[]{e.getMessage()};
            system.debug(Logginglevel.ERROR, 'deletePortalLogin in class P7S1_Liferay_PortalLoginResource' + e);
         } finally {
            if (!response.success){
                Database.rollback( sp );
            }
            if (!action.equals ( P7S1_Liferay_Constants.ACTION_CONFIRM )){
                Database.insert( new P7S1_PortalLoginEvent__c(P7S1_Successful__c = response.success, P7S1_EventType__c= P7S1_Liferay_Constants.PORTAL_EVENT_STATUS_DELETED_API ,P7S1_EventTimestamp__c=Datetime.now(), P7S1_EventMessage__c = ( response.errors != null && response.errors.size() > 0 ? response.errors +'' : null),P7S1_PortalLogin__c = portalLogin !=null ? portalLogin.Id : null) );
            }
         }
         return response;
    }

    public class LiferayRestValidationException extends Exception {

    }
}