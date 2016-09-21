public with sharing class cls_P7S1_Utils {

	// TODO: Testklasse mit echten asserts
	

	/*
	get Sandboxname.
	Mechanism depends on existing user sandboxname@p7s1.net
	created 28.03.2014, so exists in every sandbox
	*/
	
	private static String SANDBOXNAME {
		get {
		if (SANDBOXNAME == null) {
			String l_sSearch = 'sandboxname@p7s1.net';
			String l_sUser = [Select Username from User where Username like 'sandboxname@p7s1.net%' LIMIT 1].get(0).Username;
			
			if (l_sSearch == l_sUser) {
				// no sandbox prefix => production
				SANDBOXNAME = '';
			}
			else {
				SANDBOXNAME = l_sUser.right(l_sUser.length() - l_sSearch.length() - 1);
			}
		}
		return SANDBOXNAME;
	}
		set;
	}

    /*
     * Return the Sandbxoname
     */
	public static String getSandboxname(Boolean p_bWithDot) {
		String l_sSandbox = SANDBOXNAME;
		
		if (p_bWithDot && l_sSandbox.length()>0) {
			l_sSandbox = '.' + l_sSandbox;
		}
		return l_sSandbox;
	}

	
	/*
    #########################################################################################
    Helper-Functions for RecordTypes
    */

    /*
     * getter/setter for static constant RECORD_TYPE_MAP
     * Initializes a nested map of SObject Names, RecordType DeveloperNames and RecordType datasets the first time the constant is called.
     * Each consecutive call will return the cached values, thus limiting the number SOQL queries (per class load) to 1.
     * Example for a valid inquiry on the constant: RECORD_TYPE_MAP.get('ADvendio__MediaCampaign__c').get('SomDig_Angebot')
     */
	private static Map<String, Map<String, RecordType>> RECORD_TYPE_MAP {
		get {
		if (RECORD_TYPE_MAP == null) {
			Map<String, Map<String, RecordType>> temp_map = new Map<String, Map<String, RecordType>>();

			List < RecordType > record_types = [
			SELECT BusinessProcessId, CreatedById, CreatedDate, Description, DeveloperName, Id, IsActive,
				LastModifiedById, LastModifiedDate, Name, NamespacePrefix, SobjectType, SystemModstamp
			FROM RecordType
			WHERE isActive = true];

			for (RecordType record_type : record_types) {
				String sObjectType = record_type.sObjectType;
				if (temp_map.get(sObjectType) == null)
					temp_map.put(sObjectType, new Map<String, RecordType>());
				temp_map.get(sObjectType).put(record_type.DeveloperName, record_type);
			}
			RECORD_TYPE_MAP = temp_map;
		}
		return RECORD_TYPE_MAP;
	}
		set;
	}

    /*
     * Return the RecordType dataset for a SObject and a DeveloperName
     * Example: getRecordType('ADvendio__MediaCampaign__c', 'SomDig_Angebot') => RecordType:{Name=Angebot, ...)
     */
	public static RecordType getRecordType(String sObjectType, String developerName) {
		RecordType record_type = null;
		if (RECORD_TYPE_MAP.containsKey(sObjectType))
			record_type = RECORD_TYPE_MAP.get(sObjectType).get(developerName);
		return record_type;
	}

    /*
     * Return the RecordType Id for a SObject and a DeveloperName
     * Example: getRecordTypeId('ADvendio__MediaCampaign__c', 'SomDig_Angebot') => '012D0000000Qj96IAC'
     */
	public static Id getRecordTypeId(String sObjectType, String developerName) {
		RecordType record_type = getRecordType(sObjectType, developerName);
		return (record_type != null) ? record_type.Id : null;
	}

    /*
     * Return the RecordType Name for a SObject and a DeveloperName
     * Example: getRecordTypeName('ADvendio__MediaCampaign__c', 'SomDig_Angebot') => 'Angebot'
     */
	public static String getRecordTypeName(String sObjectType, String developerName) {
		RecordType record_type = getRecordType(sObjectType, developerName);
		return (record_type != null) ? record_type.Name : null;
	}


    /*
    #########################################################################################
    Helper-Functions for Profiles
    */

	    /*
     * getter/setter for static constant PROFILE_MAP
     * Initializes a map of Profile-Names and Ids
     * Each consecutive call will return the cached values, thus limiting the number SOQL queries (per class load) to 1.
     */
	private static Map<String, Id> PROFILE_MAP {
		get {
		if (PROFILE_MAP == null) {
			Map<String, Id> temp_map = new Map<String, Id>();

			for (Profile l_oProfile : [Select Id, Name from Profile]) {
			temp_map.put(l_oProfile.Name, l_oProfile.Id);
		}
			PROFILE_MAP = temp_map;
			}
		return PROFILE_MAP;
	}
		set;
	}

    /*
     * Return the ProfileId for a ProfileName
     * Example: getProfileId('SomDig_Sales') => '00e20000001QBtU'
     */
	public static Id getProfileId(String p_sProfileName) {
		return PROFILE_MAP.get(p_sProfileName);
	}

    /*
    #########################################################################################
    Helper-Functions for Multi-Select Picklists
    */

	public static string  multiPicklist_AddValue (string p_sMultiPick, String p_sAddValue) {
		// Add an value to a picklist (value can still exist, picklist can be null)
		boolean l_bFound = false;

		if (p_sMultiPick == null) {
			p_sMultiPick = p_sAddValue;
		} else {
			List<String> l_oLstElems = p_sMultiPick.split(';');
			for (string l_sElem : l_oLstElems) {
				if (l_sElem == p_sAddValue) {
					l_bFound = true;
				}
			}
			if (!l_bFound ) {
				p_sMultiPick = p_sMultiPick + ';' + p_sAddValue;
			}
		}
		return p_sMultiPick;
	}





    /*
    #########################################################################################
    Helper-Functions for SObject/Field describes and SOQL queries
    */

    /*
     * Returns the Schema.DescribeSObjectResult for a SObject string
     * Example: getSObjectDescribeResult('ADvendio__MediaCampaign__c') => Schema.DescribeSObjectResult[getKeyPrefix=a0o;...)
     */
	public static Schema.DescribeSObjectResult getSObjectDescribeResult(String sObjectType) {
		try {
			return Schema.describeSObjects(new List<String>{ sObjectType })[0];
		} catch (System.InvalidParameterValueException e) {
			return null;
		}
	}

    /*
     * Returns a Map of FieldName => Schema.SObjectField associations for a SObject string
     * Example: getFieldDescribeResults('ADvendio__MediaCampaign__c') => {advendio__account__c=ADvendio__Account__c, ...}
     */
	public static Map<String, Schema.SObjectField> getFieldDescribeResults(String sObjectType) {
		Schema.DescribeSObjectResult describeResult = getSObjectDescribeResult(sObjectType);
		return (describeResult != null) ? describeResult.fields.getMap() : null;
	}

    /*
     * Returns a List of field names for a SObject string
     * Conditionally limit returned fields via the 'modifier' String (can be 'createable' or 'updateable')
     * Example: getFields('ADvendio__MediaCampaign__c')               => (ADvendio__ADTECH_Agency_Role__c, ADvendio__AI_Quantity__c, ...)
     *          getFields('ADvendio__MediaCampaign__c', 'createable') => (ADvendio__ADTECH_Agency_Role__c, ADvendio__Account__c, ...)
     */
	public static List<String> getFields(String sObjectType) {
		return getFields(sObjectType, null);
	}
	public static List<String> getFields(String sObjectType, String modifier) {
		List<String> fields = new List<String>();
		Map<String, Schema.SObjectField> fieldsMap = getFieldDescribeResults(sObjectType);

		if (fieldsMap != null) {
			for (String fieldName : fieldsMap.keySet()){
				Schema.DescribeFieldResult field = fieldsMap.get(fieldName).getDescribe();

				if (modifier == 'createable') {
					if (field.isCreateable()) fields.add(field.getName());

				} else if (modifier == 'updateable') {
					if (field.isUpdateable()) fields.add(field.getName());

				} else {
					fields.add(field.getName());

				}
			}
		}

		fields.sort();
		return fields;
	}

    /*
     * Returns a List of createable fields for a SObject string
     * Example: getCreateableFields('ADvendio__MediaCampaign__c') => (ADvendio__ADTECH_Agency_Role__c, ADvendio__Account__c, ...)
     */
	public static List<String> getCreateableFields(String sObjectType) {
		return getFields(sObjectType, 'createable');
	}

    /*
     * Returns a List of updateable fields for a SObject string
     * Example: getUpdateableFields('ADvendio__MediaCampaign__c') => (ADvendio__ADTECH_Agency_Role__c, ADvendio__Account__c, ...)
     */
	public static List<String> getUpdateableFields(String sObjectType) {
		return getFields(sObjectType, 'updateable');
	}

    /*
     * Returns a List of all fields for a SObject string
     * Example: getFields('ADvendio__MediaCampaign__c') => (ADvendio__ADTECH_Agency_Role__c, ADvendio__AI_Quantity__c, ...)
     */
	public static List<String> getAllFields(String sObjectType) {
		return getFields(sObjectType);
	}

    /*
     * Returns a query string for a SObject
     * Example: getStandardQuery('ADvendio__MediaCampaign__c') => SELECT ADvendio__ADTECH_Agency_Role__c, ... FROM ADvendio__MediaCampaign__c
     *
     * Include a List of strings if you want to retrieve additional fields, e.g. for a relationship
     * Example: getStandardQuery('Opportunity', new List<String>{ 'Account.Name', 'Account.Owner.Email' })
     *
     * Please note: does not include an option for a WHERE clause
     * If you want to use the query with a condition, get the query string first and add an WHERE-condition manually:
     *   String query = cls_P7S1_Utils.getStandardQuery('Opportunity');
     *   query += ' WHERE Id = :opp_id';
     *   Opportunity opp = Database.query(query);
     */
	public static String getStandardQuery(String sObjectType) {
		return getStandardQuery(sObjectType, null);
	}
	public static String getStandardQuery(String sObjectType, List<String> additional_fields) {
		String query = null;
		List<String> fields = cls_P7S1_Utils.getAllFields(sObjectType);

		if (fields != null) {
			query = 'SELECT ';
			query += String.join(fields, ', ');

			if (additional_fields != null) {
				query += ', ';
				query += String.join(additional_fields, ', ');
			}

			query += ' FROM ' + sObjectType;
		}

		return query;
	}

}