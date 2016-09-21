/**
* This class generates the common testdata
*
* @author  Sebastian Listl
* @version 0.1
* @since   2014-11-19
*/
public class P7S1_Liferay_TestDataGenerator {
  	
  	public static String COUNTRY_LABEL = 'germany';

    /**
    * creates a custom setting country mapping object
    * @since 0.1
    */
    public static void createCountryMapping() {
      	P7S1_Liferay_Countrylist__c liferayCountrylist = new P7S1_Liferay_Countrylist__c(Name = '4', P7S1_CountryISO2__c = 'DE', P7S1_CountryISO3__c = 'DEU', P7S1_CountryLabel__c = COUNTRY_LABEL);
      	insert liferayCountrylist;
        system.debug('*** COMMONTESTDATA create P7S1_Liferay_Countrylist__c ' + liferayCountrylist );
    }

    /**
    * creates a custom setting P7S1_Liferay_ConfigSettings__c object
    * @since 0.1
    */
    public static void setLiferayConfigSettings(){
    	
    	P7S1_Newsletter__c newsLetterLiferay = new P7S1_Newsletter__c(P7S1_Kategorie__c='Newsletter',P7S1_Sortierung__c=1,P7S1_Beschreibung__c='');
    	P7S1_Newsletter__c newsLetterAdfacotry = new P7S1_Newsletter__c(P7S1_Kategorie__c='Newsletter',P7S1_Sortierung__c=2,P7S1_Beschreibung__c='');

    	insert newsLetterLiferay;
    	insert newsLetterAdfacotry;
    	
      	P7S1_Liferay_ConfigSettings__c liferayConfigSettings = new P7S1_Liferay_ConfigSettings__c(Name='DefaultSetting',
      		P7S1_LiferayAdminEmail__c='test@ambuorg.de',
      		P7S1_AdfactoryAdminEmail__c='test@ambuorg.de',
      		P7S1_LiferayRestApiUsername__c='test@liferay.com',
      		P7S1_LiferayRestApiPassword__c='silpioN48!',
      		P7S1_LiferayRestApiHost__c='https://liferay.silpion.de/api/jsonws',
      		P7S1_AdfactoryDefaultNewsletter__c=newsLetterAdfacotry.Id,
      		P7S1_LiferayDefaultNewsletter__c=newsLetterLiferay.Id,
      		P7S1_Newsletter_Unsubscribe_Success_Url__c='http://www.sevenone-adfactory.de/newsletter/abmeldebestaetigung/');

      	insert liferayConfigSettings;
        system.debug('*** COMMONTESTDATA create P7S1_Liferay_ConfigSettings__c ' + liferayConfigSettings );
    }
    
    /**
    * creates a custom setting country mapping object
    * @since 0.1
    */
    public static Contact createDummyContact() {
    	String email = createPortalLogin(false).P7S1_EMail__c;
      	Contact c = new Contact(LastName = 'TestContactLastName', Email = email);
		insert c;
        system.debug('*** COMMONTESTDATA create Contact ' + c );
        return c;
    }

    /**
    * invokes all create* methods
    * @since 0.1
    */
    public static void createAll() {
      	createCountryMapping();
      	setLiferayConfigSettings();
    }
    
    /**
     * creates an P7S1_PortalLogin__c object
     *
     * @param insertToDb if true data are stored to db
     * @return P7S1_PortalLogin__c portalLogin object from database
     *
     */
    public static P7S1_PortalLogin__c createPortalLogin(boolean insertToDb) {
		P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c(P7S1_EMail__c='salow_test1@silpion.de', P7S1_Portal_Status__c = P7S1_Liferay_Constants.PORTAL_STATUS_UNCONFIRMEND,P7S1_PortalId__c='20199',P7S1_Portal__c=P7S1_Liferay_Constants.PORTAL_SEVEN_ONE_MEDIA );
      	if ( insertToDb ) {
        	insert portalLogin;
      	}
      	return portalLogin;
    }
    
    public static P7S1_Abonnement__c createAbonnement(P7S1_PortalLogin__c portalLogin, String newsletterId, String newsletterUnsubscribe_Url, boolean insertToDb) {
    	P7S1_Abonnement__c abo = new P7S1_Abonnement__c(P7S1_PortalLogin__c=portalLogin.Id,P7S1_AbgeschlossenAm__c=Datetime.now(), P7S1_Contact__c =portalLogin.P7S1_Contact__c, P7S1_Newsletter__c=newsletterId, P7S1_Newsletter_Unsubscribe_Endpoint__c = newsletterUnsubscribe_Url);
      	if ( insertToDb ) {
        	insert abo;
      	}
      	return abo;
    }

}