public with sharing class P7S1_Liferay_ResourceUtil {

	public static String ACTION_UPDATE = 'update';
	public static String ACTION_ACTIVATE = 'activate';
	public static String ACTION_CONFIRM = 'confirm';
	
	public static String JSON_FIELD_TITLE = 'title';
	public static String JSON_FIELD_LASTNAME = 'lastName';
	public static String JSON_FIELD_FIRSTNAME = 'firstName';
	public static String JSON_FIELD_MALE = 'male';
	public static String JSON_FIELD_EMAIL = 'email';
	public static String JSON_FIELD_COMPANYNAME =  'companyName';
	public static String JSON_FIELD_COMPANYFAX =  'companyFax';
	public static String JSON_FIELD_COMPANYPHONE =  'companyPhone';
	public static String JSON_FIELD_COMPANYSTREETADDRESS=  'companyStreetAddress';
	public static String JSON_FIELD_COMPANYSTREETNUMBER =  'companyStreetNumber';
	public static String JSON_FIELD_COMPANYZIP =  'companyZip';
	public static String JSON_FIELD_COMPANYCITY =  'companyCity';
	public static String JSON_FIELD_COMPANYCOUNTRY =  'companyCountry';
	public static String JSON_FIELD_DATEOFBIRTH =  'dateOfBirth';
	public static String JSON_FIELD_MOBILE =  'mobile';
	public static String JSON_FIELD_AREA =  'area';
	public static String JSON_FIELD_JOBTITLE =  'jobTitle';
	public static String JSON_FIELD_COMPANYTYPE =  'companyType';
	public static String JSON_FIELD_NEWSLETTER =  'newsletter';
	
	/*** FOR DELETE ***/	
	public static String JSON_FIELD_CONFIRM_DELETE_URL = 'confirmDeleteUrl';
	/*** FOR NEWSLETTER ***/
	public static String JSON_FIELD_NEWSLETTER_SUBSCRIBE_URL =  'newsletterSubscribeUrl';
	
  	public static String getIdFromURI(String requestURI){
    	return requestURI.substring(requestURI.lastIndexOf('/')+1);
  	}

  public static String getActionFromURI(String requestURI){
    String actionAndId = requestURI.substring( requestURI.lastIndexOf('/', requestURI.lastIndexOf('/') - 1  ) +1);
    return actionAndId.substring ( 0, actionAndId.lastIndexOf('/') );
  }

  public static P7S1_PortalLogin__c dynamicJsonUpdate(P7S1_PortalLogin__c portalLoginToUpdate, String jsonFieldsToUpdate ){
    JSONParser parser = JSON.createParser(jsonFieldsToUpdate);
    while (parser.nextToken() != null) {
      if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
        String fieldName = parser.getText();
            system.debug('fieldName: ' + fieldName);
            parser.nextToken();
            if (fieldName == JSON_FIELD_TITLE){
              portalLoginToUpdate.P7S1_Titel__c = parser.getText();
            } else if (fieldName == JSON_FIELD_LASTNAME){
              portalLoginToUpdate.P7S1_Nachname__c = parser.getText();
            } else if (fieldName == JSON_FIELD_FIRSTNAME){
              portalLoginToUpdate.P7S1_Vorname__c = parser.getText();
            } else if (fieldName == JSON_FIELD_MALE){
              portalLoginToUpdate.P7S1_Anrede__c = ( parser.getBooleanValue() ? 'Herr' : 'Frau');
            } else if (fieldName == JSON_FIELD_EMAIL){
              portalLoginToUpdate.P7S1_EMail__c = parser.getText();
            } else if (fieldName == JSON_FIELD_COMPANYNAME){
              portalLoginToUpdate.P7S1_Firma__c = parser.getText();
            } else if (fieldName == JSON_FIELD_COMPANYFAX){
              portalLoginToUpdate.P7S1_Fax__c = parser.getText();
            } else if (fieldName == JSON_FIELD_COMPANYPHONE){
              portalLoginToUpdate.P7S1_Telefon__c = parser.getText();
            } else if (fieldName == JSON_FIELD_COMPANYSTREETADDRESS){
              portalLoginToUpdate.P7S1_Strasse__c = parser.getText();
            } else if (fieldName == JSON_FIELD_COMPANYSTREETNUMBER){
              portalLoginToUpdate.P7S1_Hausnummer__c = parser.getText();
            } else if (fieldName == JSON_FIELD_COMPANYZIP){
              portalLoginToUpdate.P7S1_Postleitzahl__c = parser.getText();
            } else if (fieldName == JSON_FIELD_COMPANYCITY){
              portalLoginToUpdate.P7S1_Ort__c = parser.getText();
            } else if (fieldName == JSON_FIELD_MOBILE){
              portalLoginToUpdate.P7S1_Mobil__c = parser.getText();
            } else if (fieldName == JSON_FIELD_AREA){
              portalLoginToUpdate.P7S1_Bereich__c = parser.getText();
            } else if (fieldName == JSON_FIELD_JOBTITLE){
              portalLoginToUpdate.P7S1_Funktion__c = parser.getText();
            } else if (fieldName == JSON_FIELD_COMPANYCOUNTRY){
              portalLoginToUpdate.P7S1_Land__c = P7S1_Liferay_RegistrationFormBean.getCountryLabelForLiferayCountryId(parser.getLongValue());
            } else if (fieldName == JSON_FIELD_COMPANYTYPE){
              	portalLoginToUpdate.P7S1_Unternehmensart__c = P7S1_Liferay_RegistrationFormBean.getP7S1_UnternehmensartFromString( parser.getText() );
            } else if (fieldName == JSON_FIELD_DATEOFBIRTH ){
           		portalLoginToUpdate.P7S1_Geburtstag__c = (parser.getText() != null && parser.getText() != 'null' && parser.getText() != '') ? parser.getDateValue() : null;
            } else if (fieldName == JSON_FIELD_NEWSLETTER){
            	portalLoginToUpdate.P7S1_Newsletter__c = parser.getBooleanValue();
            } else {
				throw new LiferayRestDynamicUpdateException('not allowed to update field : ' + fieldName);
            }
      }
    }
    return portalLoginToUpdate;
  }
  
	public static String getStringValueByKey(String key, String requestBody){
 		String fieldValue = null;
 		JSONParser parser = JSON.createParser(requestBody);
    	while (parser.nextToken() != null) {
      		if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
				String fieldName = parser.getText();
            	system.debug('fieldName: ' + fieldName);
            	parser.nextToken();
            	if (fieldName == key){
              		fieldValue = parser.getText();
              	}
      		}
    	}
 		return fieldValue;
	}
	public static Boolean getBooleanValueByKey(String key, String requestBody){
 		Boolean fieldValue = null;
 		JSONParser parser = JSON.createParser(requestBody);
    	while (parser.nextToken() != null) {
      		if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
				String fieldName = parser.getText();
            	parser.nextToken();
            	if (fieldName == key){
	       			fieldValue = parser.getBooleanValue();
            	}
      		}
		}
		return fieldValue;
	}
	
  	public class LiferayRestDynamicUpdateException extends Exception {
	
    }
}