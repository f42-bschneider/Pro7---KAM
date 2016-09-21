/**
* APEX Representaion of the RegistrationFormBean form the Liferay Java class to deserialies the incomming json sting.
*
* @author  Sebastian Listl
* @version 0.1, 2014-08-27
*/
global with sharing class P7S1_Liferay_RegistrationFormBean {

    public Boolean male {get;set;}
    public Long id {get;set;}
    public String portal {get; set;}
    public String activationLink {get;set;}
    public String title {get;set;}
    public String firstName {get;set;}
    public String lastName {get;set;}
    public String jobTitle {get;set;}
    public String area {get;set;}
    public String companyName {get;set;}
    public P7S1_Liferay_EnumCompanyType companyType {get;set;}
    public Boolean companyAddressPOBox {get;set;}
    public String companyStreetAddress {get;set;}
    public String companyStreetNumber {get;set;}
    public String companyCity {get;set;}
    public String companyZip {get;set;}
    public String companyPOBox {get;set;}
    public String companyPhone {get;set;}
    public String dateOfBirth {get;set;}
    public String companyFax {get; set;}
    public String email {get;set;}
    public String password {get;set;}
    public String passwordRepeat {get;set;}
    public Boolean requestObs {get;set;}
    public Boolean acceptTerms {get;set;}
    public Boolean acceptPrivacyTerms {get;set;}
    public long companyCountry {get;set;}
    public String mobile {get;set;}
    public Boolean newsletter {get;set;}

    public static P7S1_Liferay_RegistrationFormBean parse(String json) {
        return (P7S1_Liferay_RegistrationFormBean) System.JSON.deserialize(json, P7S1_Liferay_RegistrationFormBean.class);
    }
    /**
    * converts a APEX Class Object to a Salesforce Custom Object
    * @since 0.1
    */
    public P7S1_PortalLogin__c toSfPortalLogin(){
        P7S1_PortalLogin__c portalLogin = new P7S1_PortalLogin__c();

        portalLogin.P7S1_Portal_Status__c = 'Neu'; //Picklist Neu / Aktiv / Gesperrt / Gelöscht
        portalLogin.P7S1_Titel__c = this.title;
        portalLogin.P7S1_Nachname__c = this.lastName;
        portalLogin.P7S1_Vorname__c = this.firstName;
        portalLogin.P7S1_Anrede__c = (this.male ? 'Herr' : 'Frau'); // Picklist Herr / Frau
        portalLogin.P7S1_EMail__c = this.email;

        portalLogin.P7S1_Firma__c = this.companyName;
        portalLogin.P7S1_Fax__c = this.companyFax;
        portalLogin.P7S1_Telefon__c = this.companyPhone;
        portalLogin.P7S1_Mobil__c  = this.mobile;
        portalLogin.P7S1_Strasse__c = this.companyStreetAddress;
        portalLogin.P7S1_Hausnummer__c = this.companyStreetNumber;
        portalLogin.P7S1_Ort__c = this.companyCity;
        portalLogin.P7S1_PortalId__c = String.valueOf( this.id );
        portalLogin.P7S1_ActivationLink__c= this.activationLink;
        portalLogin.P7S1_Postleitzahl__c = this.companyZip;
        portalLogin.P7S1_AGB__c = this.acceptTerms;
        portalLogin.P7S1_Funktion__c =  this.jobTitle;
        portalLogin.P7S1_Bereich__c = this.area;
        portalLogin.P7S1_Unternehmensart__c = getP7S1_UnternehmensartFromEnum(this.companyType);
        portalLogin.P7S1_Newsletter__c = (this.newsletter != null ? this.newsletter : false);
		
        if ( this.portal != null  ){
            portalLogin.P7S1_Portal__c = this.portal; //Picklist value sevenonemedia.de /sevenonemedia.ch / sevenonemedia.com / sevenone-adfactory.de
        }
        if ( this.dateOfBirth != null && this.dateOfBirth != ''){
            portalLogin.P7S1_Geburtstag__c = Date.valueOf( this.dateOfBirth );
        }
        portalLogin.P7S1_Land__c = getCountryLabelForLiferayCountryId( this.companyCountry );

        return portalLogin;
    }

    private static String getP7S1_UnternehmensartFromEnum(P7S1_Liferay_EnumCompanyType companyType){
        String unternahemnsArt = P7S1_Liferay_Constants.PORTAL_COMPANY_TYPE_SF_NO_MATCH;

        if (companyType == P7S1_Liferay_EnumCompanyType.ADVERTISER ){
            unternahemnsArt = P7S1_Liferay_Constants.PORTAL_COMPANY_TYPE_SF_ADVERTISER;
        }
        if (companyType == P7S1_Liferay_EnumCompanyType.ADVERTISING_AGENCY ){
            unternahemnsArt = P7S1_Liferay_Constants.PORTAL_COMPANY_TYPE_SF_ADVERTISING_AGENCY;
        }
        if (companyType == P7S1_Liferay_EnumCompanyType.MEDIA_AGENCY ){
            unternahemnsArt = P7S1_Liferay_Constants.PORTAL_COMPANY_TYPE_SF_MEDIA_AGENCY;
        }
        return unternahemnsArt;
    }

    public static String getP7S1_UnternehmensartFromString(String companyType){
        if (companyType.equals( P7S1_Liferay_EnumCompanyType.ADVERTISER.name() ) ){
            return getP7S1_UnternehmensartFromEnum( P7S1_Liferay_EnumCompanyType.ADVERTISER );
        }
        if (companyType.equals( P7S1_Liferay_EnumCompanyType.ADVERTISING_AGENCY.name() ) ){
            return getP7S1_UnternehmensartFromEnum( P7S1_Liferay_EnumCompanyType.ADVERTISING_AGENCY );
        }
        if (companyType.equals( P7S1_Liferay_EnumCompanyType.MEDIA_AGENCY.name() ) ){
            return getP7S1_UnternehmensartFromEnum( P7S1_Liferay_EnumCompanyType.MEDIA_AGENCY );
        }
        return null;
    }

    public static String getCountryLabelForLiferayCountryId(long liferayCountryId) {
        P7S1_Liferay_Countrylist__c countryList = P7S1_Liferay_Countrylist__c.getInstance( String.valueOf( liferayCountryId ) );
        return ( countryList != null ? countryList.P7S1_CountryLabel__c : 'ID-' + liferayCountryId + '-NOMATCH' );
    }

}