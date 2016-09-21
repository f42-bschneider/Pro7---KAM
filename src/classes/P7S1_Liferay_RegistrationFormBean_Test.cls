/**
* This is the Testclass for P7S1_Liferay_RegistrationFormBean its tests
*
* testSerialize   -  tests the serialization
* testParse     -  tests the deserialization
*
* @author  Sebastian Listl
* @version 0.1
* @since   2014-08-31
* @see P7S1_Liferay_RegistrationFormBean
*/
@isTest
global class P7S1_Liferay_RegistrationFormBean_Test {

    static testMethod void testSerialize(){

    P7S1_Liferay_RegistrationFormBean lifeRayRegistrationFormBean = createNewLifeRayRegistrationFormBean();

    system.debug ('--- serialize P7S1_Liferay_RegistrationFormBean ---' );
    system.debug ( JSON.serialize( lifeRayRegistrationFormBean ) );
    system.debug ('--- serialize P7S1_Liferay_RegistrationFormBean ---' );
  }

  static testMethod void testParse() {

    String jsonObjectRepresentation = getJsonStringForObject();
    System.assert( jsonObjectRepresentation != null );

    P7S1_Liferay_RegistrationFormBean obj = P7S1_Liferay_RegistrationFormBean.parse(jsonObjectRepresentation);
    System.assert( obj != null );

    System.assertEquals( obj.acceptPrivacyTerms , true );
    System.assertEquals( obj.acceptTerms , true );
    System.assertEquals( obj.area , 'Einkauf');
    //class
    System.assertEquals( obj.companyAddressPOBox , null );
    System.assertEquals( obj.companyCity , 'Musterstadt' );
    System.assertEquals( obj.companyCountry , 4 );
    System.assertEquals( obj.companyFax , '111-11-11-111');
    System.assertEquals( obj.companyName , 'Musterfirma' );
    System.assertEquals( obj.companyPOBox , null );
    System.assertEquals( obj.companyPhone , '111-111-111-111' );
    System.assertEquals( obj.companyStreetAddress , 'Musterstrasse' );
    System.assertEquals( obj.companyStreetNumber , '11' );
    System.assertEquals( obj.companyType , P7S1_Liferay_EnumCompanyType.ADVERTISING_AGENCY );
    System.assertEquals( obj.companyZip , '11111' );
    System.assertEquals( obj.email , 'salow_test1@silpion.de' );
    System.assertEquals( obj.firstName , 'Max');
    System.assertEquals( obj.jobTitle , 'Einkaufsleiter');
    System.assertEquals( obj.lastName , 'Mustermann');
    System.assertEquals( obj.male, true  );
    System.assertEquals( obj.password , 'Test1234' );
    System.assertEquals( obj.passwordRepeat , 'Test1234' );
    System.assertEquals( obj.requestObs , null );
    System.assertEquals( obj.title , 'Dr.');
    System.assertEquals( obj.portal , P7S1_Liferay_Constants.PORTAL_SEVEN_ONE_MEDIA );
    System.assertEquals( obj.dateOfBirth , '2015-01-01' );
    System.assertEquals( 20199L, obj.id  );
    System.assertEquals( obj.newsletter, true );


    //Fix Enum parsing with orginal JSON

    obj = P7S1_Liferay_RegistrationFormBean.parse('{"title":"Dr."}');
    System.assert( obj != null );

  }

  static testmethod void testObjectConversion(){
    P7S1_Liferay_RegistrationFormBean obj = createNewLifeRayRegistrationFormBean();
    System.assert( obj != null );

    P7S1_Liferay_TestDataGenerator.createAll();

    P7S1_PortalLogin__c portalLogin = obj.toSfPortalLogin();
    System.assert( portalLogin != null );

    system.assertEquals( portalLogin.P7S1_Titel__c,  obj.title );
    system.assertEquals( portalLogin.P7S1_Nachname__c,  obj.lastName );
    system.assertEquals( portalLogin.P7S1_Vorname__c,  obj.firstName );
    system.assertEquals( portalLogin.P7S1_Anrede__c,  'Herr' );
    system.assertEquals( portalLogin.P7S1_EMail__c,  obj.email );
    system.assertEquals( portalLogin.P7S1_Firma__c,  obj.companyName );
    system.assertEquals( portalLogin.P7S1_Fax__c,  obj.companyFax );
    system.assertEquals( portalLogin.P7S1_Strasse__c,  obj.companyStreetAddress );
    system.assertEquals( portalLogin.P7S1_Hausnummer__c,  obj.companyStreetNumber );
    system.assertEquals( portalLogin.P7S1_Ort__c,  obj.companyCity );
    system.assertEquals( portalLogin.P7S1_Land__c,  P7S1_Liferay_TestDataGenerator.COUNTRY_LABEL );
    system.assertEquals( portalLogin.P7S1_Portal__c , P7S1_Liferay_Constants.PORTAL_SEVEN_ONE_MEDIA );
    system.assertEquals( portalLogin.P7S1_Geburtstag__c , date.newInstance(2015,01,01) );
    system.assertEquals( portalLogin.P7S1_Newsletter__c , obj.newsletter );
  }
  
  static testmethod void getP7S1_UnternehmensartFromEnum(){    
      /* method is private change test
      system.assertEquals( 'Werbungtreibender', P7S1_Liferay_RegistrationFormBean.getP7S1_UnternehmensartFromEnum(P7S1_Liferay_EnumCompanyType.ADVERTISER) );
      system.assertEquals( 'Werbeagentur', P7S1_Liferay_RegistrationFormBean.getP7S1_UnternehmensartFromEnum(P7S1_Liferay_EnumCompanyType.ADVERTISING_AGENCY) );
      system.assertEquals( 'Mediaagentur', P7S1_Liferay_RegistrationFormBean.getP7S1_UnternehmensartFromEnum(P7S1_Liferay_EnumCompanyType.MEDIA_AGENCY) );
      */
  }

  public static P7S1_Liferay_RegistrationFormBean createNewLifeRayRegistrationFormBean(){
    P7S1_Liferay_RegistrationFormBean lifeRayRegistrationFormBean = new P7S1_Liferay_RegistrationFormBean();
    return P7S1_Liferay_RegistrationFormBean.parse( getJsonStringForObject() );
  }

//  public static String getJsonStringForObject(){
//    return   '{"area":"area","companyAddressPOBox":true,"companyType":"MEDIA_AGENCY","companyCity":"companyCity","companyCountry":4,"companyFaxCountry":"companyFaxCountry","companyFaxExtension":"companyFaxExtension","companyFaxNumber":"companyFaxNumber","companyFaxRegion":"companyFaxRegion","companyName":"companyName","companyPhoneCountry":"companyPhoneCountry","companyPhoneExtension":"companyPhoneExtension","companyPhoneNumber":"companyPhoneNumber","companyPhoneRegion":"companyPhoneRegion","companyPOBox":"companyPOBox","companyStreetAddress":"companyStreetAddress","companyStreetNumber":"companyStreetNumber","companyZip":"companyZip","email":"email","firstName":"firstName","jobTitle":"jobTitle","lastName":"lastName","male":true,"password":"password","passwordRepeat":"passwordRepeat","requestObs":true,"acceptTerms":true,"acceptPrivacyTerms":true,"title":"title"}';
//  }

  /*
  public static String getJsonStringForObject(){
    return   '{"id":20199,"acceptPrivacyTerms":true,"acceptTerms":true,"area":"Einkauf","class":"de.silpion.ahead.portlet.registration.controller.RegistrationFormBean","companyAddressPOBox":null,"companyCity":"Musterstadt","companyCountry":4,"companyFax":"111-11-11-111","companyFaxCountry":"111","companyFaxExtension":"111","companyFaxNumber":"11","companyFaxRegion":"11","companyName":"Musterfirma","companyPOBox":null,"companyPhone":"111-111-111-111","companyPhoneCountry":"111","companyPhoneExtension":"111","companyPhoneNumber":"111","companyPhoneRegion":"111","companyStreetAddress":"Musterstrasse","companyStreetNumber":"11","companyType":"ADVERTISING_AGENCY","companyTypeId":2,"companyZip":"11111","email":"salow_test1@silpion.de","firstName":"Max","jobTitle":"Einkaufsleiter","lastName":"Mustermann","male":true,"password":"Test1234","passwordRepeat":"Test1234","requestObs":null,"title":"Dr.","portal":"sevenonemedia.de","dateOfBirth":"2015-01-01" }';
  }
  */
  public static String getJsonStringForObject(){
    return   '{"id":20199,"activationLink":"http://mydomain.de","acceptPrivacyTerms":true,"acceptTerms":true,"area":"Einkauf","class":"de.silpion.ahead.portlet.registration.controller.RegistrationFormBean","companyAddressPOBox":null,"companyCity":"Musterstadt","companyCountry":4,"companyFax":"111-11-11-111","companyFaxCountry":"111","companyFaxExtension":"111","companyFaxNumber":"11","companyFaxRegion":"11","companyName":"Musterfirma","companyPOBox":null,"companyPhone":"111-111-111-111","companyPhoneCountry":"111","companyPhoneExtension":"111","companyPhoneNumber":"111","companyPhoneRegion":"111","companyStreetAddress":"Musterstrasse","companyStreetNumber":"11","companyType":"ADVERTISING_AGENCY","companyTypeId":2,"companyZip":"11111","email":"salow_test1@silpion.de","firstName":"Max","jobTitle":"Einkaufsleiter","lastName":"Mustermann","male":true,"password":"Test1234","passwordRepeat":"Test1234","requestObs":null,"title":"Dr.","portal":"sevenonemedia.de","dateOfBirth":"2015-01-01","newsletter":true }';
  }


}