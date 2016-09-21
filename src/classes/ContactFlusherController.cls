global with sharing class ContactFlusherController implements Database.Batchable<sObject>, Schedulable {

	static ID recordTypeAusgeschiedenId;

	static { //Query for the Account record types

		String developerName = 'Som_InaktiverKontakt';

		List < RecordType > recordTypes = [
		Select Name, Id From RecordType
		where sObjectType = 'Contact'
		and developerName = :developerName
			and isActive = true
		LIMIT 1
		];

		System.assertNotEquals(0, recordTypes.size(), 'Couldnot find record type with the required name, which is: ' + developerName);

		recordTypeAusgeschiedenId = recordTypes.get(0).id;
	}

	String log = '';

	static final String CONTACT_BASE_QUERY = 'SELECT id, Austrittsdatum__c, P7S1_Konzernmitarbeiter__c, Email, Lastname FROM Contact ';

	static final String TO_BE_FLUSHED_QUERY_STR
		= CONTACT_BASE_QUERY
		+ ' WHERE Austrittsdatum__c<LAST_90_DAYS' // this means "Austrittsdatum__c was somewhere before the last 3 month
		+' AND SomTv_KontaktdatenGeloescht__c=null'
		;

    /**
     * Everything logged with this will be mailed after the batch is finished.
     */
	void log(String str) {
		System.debug(LoggingLevel.DEBUG, str);
		log += str + '\n';
	}

	global Database.querylocator start(Database.BatchableContext BC){
		log(DateTime.now().format('yyyy_MM_dd HH:MM:ss:SSS', 'UTC') + ': ContactFlusherController batch starts.');
		return Database.getQueryLocator(TO_BE_FLUSHED_QUERY_STR);
	}

	global void execute(SchedulableContext SC) {
		Database.executeBatch(new ContactFlusherController());
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		for (Contact c : (List<Contact>) scope) {
			flushContact(c);
		}
		update scope;
	}


    /**
     * finish: The finish method is called after all batches are processed. Use this method to send confirmation emails or execute post-processing operations.
     *
     * @param  variable Description
     * @return Description
     */
	global void finish(Database.BatchableContext BC){
	}

	public class ContactFlusherException extends Exception {}

	Id contactId;

	public ContactFlusherController(ApexPages.StandardController stdController) {
		contactId = ((Contact) stdController.getRecord()).id;
	}

	public ContactFlusherController(Id contactIdParam) {
		this.contactId = contactIdParam;
	}

	public ContactFlusherController() {
	}

	/** Called by the button */
	public PageReference flush() {

		String fieldCsv = 'id';
		for (String fieldName : fieldNames) {
			fieldCsv += ',' + fieldName;
		}

		Contact c = (Contact) Database.query(CONTACT_BASE_QUERY + ' WHERE id=\'' + this.contactId + '\' LIMIT 1').get(0)
			;
		flushContact(c);
		update c;

		return new PageReference('/' + contactId);
	}

	/** Called by the button */
	public PageReference backToContact() {
		return new PageReference('/' + contactId);
	}

	private static void flushContact(Contact c) {
		String log = '\n';

		system.debug('### P7S1_Konzernmitarbeiter__c: ' + c.P7S1_Konzernmitarbeiter__c);
		system.debug('### Email: ' + c.Email);
		system.debug('### Lastname: ' + c.Lastname);

		if (c.P7S1_Konzernmitarbeiter__c == false) {
			c.Email = null;
		}

		for (String fieldName : fieldNames) {
			try {
				c.put(fieldName, null);
                /* debug code:
                Contact cTemp = c.clone(true);
                cTemp.put(fieldName,null);
                update cTemp;
                */
			} catch(SObjectException e) {
				log += fieldName + ' : ' + e.getMessage() + '\n';
			} catch(DmlException e) {
				log += fieldName + ' : ' + e.getMessage() + '\n';
			}
		}



		// Checkbox fields. Trying to fill these with null would fail.
		c.HasOptedOutOfEmail = true;
		c.HasOptedOutOfFax = true;
		c.DoNotCall = true;
		c.Funktion_inaktiv__c = true;
		c.keine_Werbesendungen__c = true;
		c.SomTv_ZuUeberpruefenCon__c = false;
		c.ausgeschieden__c = true;

		if (c.Austrittsdatum__c == null) {
			c.Austrittsdatum__c = System.today();
		}

		c.RecordTypeId = recordTypeAusgeschiedenId;

		System.debug('These Exceptions occured:\n' + log);

		if(String.isNotBlank(log) && Test.isRunningTest()) {
			throw new ContactFlusherException(log);
		}

		// Log deletion:
		c.SomTv_KontaktdatenGeloescht__c = DateTime.now();
	}

	public static void logErrors() {
		String log = '\n';

		Contact c = new Contact();

		for (String fieldName : fieldNames) {
			try {
				c.put(fieldName, null);
			} catch(System.SObjectException e) {
				log += e.getMessage() + '\n';
			}
		}

		System.debug(log);
	}


    /**
     * Don't put checkbox fields in here. It would make flush() fail.
     */
	private final static List<String> fieldNames = new List<String> {
			'ADvendio__Function__c'
			,'AssistantName'
			,'AssistantPhone'
			,'ausgeschieden__c'
			//,'Austrittsdatum__c' //NICHT löschen!
			,'Birthdate'
			,'Department'
			,'Description'
			//,'DoNotCall'
			,'Eintrittsdatum__c'
			// ,'Email'
			,'EmailBouncedDate'
			,'EmailBouncedReason'
			,'Fax'
			//,'Funktion_inaktiv__c'
			,'Geburtstag_Jahr__c'
			,'Geburtstag_Monat__c'
			,'Geburtstag_Tag__c'
			//,'HasOptedOutOfEmail'
			//,'HasOptedOutOfFax'
			,'HomePhone'
			//,'InhaberACC__c'
			//,'keine_Werbesendungen__c'
			,'Kontaktdublette__c'
			//,'LastCURequestDate'
			//,'LastCUUpdateDate'
			,'LeadSource'
			//,'LifeRay_Benutzer_ID__c' //Commented out because of CR 24.05.2013
			,'MailingCity'
			,'MailingCountry'
			,'MailingPostalCode'
			,'MailingState'
			,'MailingStreet'
			,'MobilePhone'
			,'Notizen_Kommentare__c'
			,'OtherCity'
			,'OtherCountry'
			,'OtherPhone'
			,'OtherPostalCode'
			,'OtherState'
			,'OtherStreet'
			,'P7S1_IdOld__c'
			,'P7S1_OtherInfos__c'
			//,'P7S1_Sphere__c'
			,'P7S1_SphereCopy__c'
			,'Phone'
			,'Position_funktion__c'
			,'Position_Funktion_extern__c'
			//,'ProRex_Funktions_Id__c' //Commented out because of CR 2013_05_22
			//,'ProRexId__c' //Commented out because of CR 24.05.2013
			//,'Som_Benutzer__c'
			,'SomTv_AboNewsletterEmail__c'
			,'SomTv_Assistenz__c'
			,'SomTv_DvdBestellungen__c'
			,'SomTv_ErreichbarkeitPraefKommWege__c'
			//,'SomTv_EvalancheId__c' //Commented out because of CR 2013_05_22
			,'SomTv_FanVon__c'
			,'SomTv_Foto__c'
			,'SomTv_Geburtsname__c'
			,'Som_Geschlecht__c'
			,'SomTv_InteresseMediengattungMD__c'
			,'SomTv_Kategorie__c'
			,'SomTv_Kommunikationssprache__c'
			,'SomTv_Kuenstlername__c'
			,'SomTv_LetzterKontaktpunkt__c'
			,'SomTv_MarketingPrioritaetAdFactory__c'
			,'SomTv_MarketingPrioritaetAT__c'
			,'SomTv_MarketingPrioritaetOnline__c'
			,'SomTv_MarketingPrioritaetTv__c'
			,'SomTv_PotentielleVeranstaltungen__c'
			//,'SomTv_QuelleKontakt__c'
			,'SomTv_SenderMarken__c'
			,'SomTv_Spitzname__c'
			//,'Titel__c'
			,'SomTv_TitelAkademischerGrad__c'
			,'SomTv_Zustaendigkeiten__c'
			//,'SomTv_ZuUeberpruefenCon__c'
			//,'SomTv_ZuverlaessigkeitEvents__c'
			,'Title'
			,'UseSalesforce'


			// CRMSALES-2300
			//,'SomTv_Nationalitaet__c',

			// CRMSALES-1852
			,'ReportsToId'

			};

	@isTest //(SeeAllData=true)
	static void test() {
		logErrors();

		Account acc = newTestAccount(System.UserInfo.getUserId(), 'Test account 1');

		Contact c = new Contact(lastname = 'Frank Underwood', AccountId = acc.Id, Fax = '1234567', Email = 'Test@test.com', MobilePhone = '1346975');
		insert c;

		ContactFlusherController controller = new ContactFlusherController(c.id);

		controller.flush();
	}

	@isTest //(SeeAllData=true)
	static void testBatch() {

		Account acc = newTestAccount(System.UserInfo.getUserId(), 'Test account 1');

		Contact c1 = new Contact(lastname = 'Frank Underwood', AccountId = acc.Id, Fax = '1234', Email = 'Test@test.com', MobilePhone = '1346975'
			, Austrittsdatum__c = System.today().addMonths(-1), ausgeschieden__c = true
			);
		insert c1;

		Contact c2 = new Contact(lastname = 'Delli Delete', AccountId = acc.Id, Fax = '1234567', Email = 'Test@test.com', MobilePhone = '1346975'
			, Austrittsdatum__c = System.today().addMonths(-4), ausgeschieden__c = true
			);
		insert c2;

		List < Contact > cList1 = [SELECT id FROM Contact WHERE id=:c1.id OR id=:c2.id];
		System.assertEquals(2, cList1.size());

		ContactFlusherController c = new ContactFlusherController();
		Database.BatchableContext bc;
		c.start(bc);
        /*
        List<sObject> scope = new List<sObject>();
        Account acc1 = insertTestAccount(insertTestUser());
        scope.add((sObject) acc1);
        */
		c.execute(bc, Database.query(TO_BE_FLUSHED_QUERY_STR));
		c.finish(bc);

		System.assertEquals('1234', ((Contact) queryOne('Contact', 'lastname', 'Frank Underwood', 'Fax')).fax);
		System.assertEquals(null, ((Contact) queryOne('Contact', 'lastname', 'Delli Delete', 'Fax')).fax);
	}

    /**
    This should NOT be moved to ClsHelper because the Schedulable for this class would then block editing of ClsHelper.

    Test with SeeAllData=true you need to take precautions if an account with this name already exists,
    which would make the test fail!

    Examples:
    Account acc = newTestAccount(System.UserInfo.getUserId(), 'Test account 1');
    Account acc = newTestAccount(insertTestUser().id, 'Test account 1');
    insert acc;
    */
	public static Account newTestAccount(ID userId, final String name) {
		Account acc = new Account();
		acc.Name = name;
		acc.OwnerId = userId;
		acc.BillingStreet = '12345';
		acc.BillingCity = 'Test';
		acc.Phone = '12456796';
		acc.BillingCountry = 'test';
		acc.BillingPostalCode = '134697';
		acc.BillingState = 'test';

		return acc; // It is better to return the object instead of an ID in order to enable the user to update the object with more values.
	}

    /**<pre>
    This should NOT be moved to ClsHelper because the Schedulable for this class would then block editing of ClsHelper.

    @param extrafields: null or a comma separated list of extra fields
    @return: If anything is found, the first match is returned.
    This is trivial, but often needed.
    Example:
    System.assertEquals(true,((User)queryOne('User','id',u.id,'isActive')).isActive);
    </pre>*/
	public static SObject queryOne(final String sObjectName, final String fieldname, final String searchedContent, String extrafields) {
		final String queryStr = 'SELECT ' + fieldname
			+ (extraFields == null ? '' : (',' + extraFields))
			+ ' FROM ' + sObjectName + ' WHERE ' + fieldname + '=:searchedContent LIMIT 1';
		List<SObject> sObjectList = Database.query(queryStr);

		if (sObjectList.size() == 0) {
			return null;
		} else {
			return sObjectList.get(0);
		}
	}
}