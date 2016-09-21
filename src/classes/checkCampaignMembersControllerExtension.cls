public with sharing class checkCampaignMembersControllerExtension {
	
	/** T1 is a test with a campaign without Accounts but with Contacts */
	private enum TestCase {NONE,T1}
	static final TestCase testCaseSelector = TestCase.NONE;

	static final Boolean DEBUG = true;
	static final LoggingLevel lll;
	{
		if (DEBUG) {
			lll = LoggingLevel.ERROR;
		} else {
			lll = LoggingLevel.FINEST;
		}
	}

	//** This list contains all rows which will be displayed on the page */
	public List<TableRow> tableRows {get;set;}
	
	final Campaign thisCampaign;

	Map<Id, CampaignMember> CampaignMembersByContactId;
	Set<Id> campaignAccIds;
	
	public checkCampaignMembersControllerExtension(ApexPages.StandardController controller) {
		thisCampaign = (Campaign) controller.getRecord();
		refreshData();
	}

	void refreshData() {
		try { 
			tableRows = new List<TableRow>();
			CampaignMembersByContactId = new Map<Id, CampaignMember>();
			campaignAccIds = new Set<Id>();

			
			// All Zielgruppe_B2B_Aktion__c-objects which belong to this campaign
			final List<Zielgruppe_B2B_Aktion__c> zielgruppe_B2B_Aktionen 
				= [SELECT Account__c FROM Zielgruppe_B2B_Aktion__c WHERE Kampagne__c=:thisCampaign.id]
			;
		
			// Collect IDs of all accounts which belong to the campaign.
			for (Zielgruppe_B2B_Aktion__c zielgruppe_B2B_Aktion : zielgruppe_B2B_Aktionen) {
				campaignAccIds.add(zielgruppe_B2B_Aktion.Account__c);
			}
	
			final List<Account> campaignAccounts = 
			[
				SELECT id, name, (SELECT id, name FROM Contacts ORDER BY name) 
				FROM Account WHERE id IN :campaignAccIds
				ORDER BY name
			];

			// Collect IDs of all contacts which already belong to the campaign:
			for (CampaignMember campaignMember : [SELECT id, contactId FROM CampaignMember WHERE campaignID=:thisCampaign.id]) {
				CampaignMembersByContactId.put(campaignMember.contactId, campaignMember);
			}

			final Set<Id> preexistingCampaignContactIds = CampaignMembersByContactId.keySet();

			/** In this map we collect all contacts which do not belong to an Account of the campaign */
			
			final Map<Id, Set<Contact>> offendingContactsByAccountId = new Map<Id, Set<Contact>>();
			{ // offendingContactsByAccountId	
				List<Contact> preexistingCampaignContacts 
					= [SELECT id, name, AccountId FROM Contact WHERE id IN : new List<Id>(preexistingCampaignContactIds)];
				
				if(testCaseSelector == TestCase.T1) {
					System.assertNotEquals(0, preexistingCampaignContacts.size());
				}
				
				for (Contact c : preexistingCampaignContacts) { // preexistingCampaignContactsLoop
					
					if ( ! campaignAccIds.contains(c.AccountId) ) { // notContainedInCampaign
						// => This is a contact which doesn't belong to any Account of the Campaign.
						// => Let's remember this to display to the user later.
						final Set<Contact> thisAccountsOffendingContacts = offendingContactsByAccountId.get(c.AccountId);
						if ( thisAccountsOffendingContacts==null ) {
							thisAccountsOffendingContacts = new Set<Contact>();
							offendingContactsByAccountId.put(c.AccountId, thisAccountsOffendingContacts);
						} 
						
						thisAccountsOffendingContacts.add(c);
					} // endif notContainedInCampaign
				} // end preexistingCampaignContactsLoop
			} // end offendingContactsByAccountId
			
			final List<Account> nonCampaignAccounts 
				= [SELECT id, name FROM Account WHERE id IN :offendingContactsByAccountId.keySet()]; 

			// fill table rows with data
			tableRows.clear();
			for (Account nonCampaignAccount : nonCampaignAccounts ) {
				Set<Contact> offendingContacts = new Set<Contact>();
				offendingContacts =  offendingContactsByAccountId.get(nonCampaignAccount.id);
				String contactListString = '';
				for (Contact c : offendingContacts) {
					contactListString += c.name + ', ';
				}
				if (contactListString.length()>=2)
					contactListString = contactListString.substring(0,contactListString.length()-2); // Remove the last comma
				
				tableRows.add(new TableRow(nonCampaignAccount, contactListString, offendingContacts));
			}
		} catch (Exception e) {
			addExceptionAsMessage(e);
		}
	}	
	
	// This is called when the button is pressed.
	public PageReference addAccounts() {
		try {
			final List<Zielgruppe_B2B_Aktion__c> zielgruppe_B2B_AktionenToInsert = new List<Zielgruppe_B2B_Aktion__c> (); 
			
			for (TableRow tableRow : tableRows) {
				if (tableRow.selected) {
					// Add account as zielgruppe_B2B_Aktion to the campaign
					zielgruppe_B2B_AktionenToInsert.add(new Zielgruppe_B2B_Aktion__c(
							Kampagne__c = thisCampaign.id
							, Account__c = tableRow.acc.id
					));
				} 
			}
			
			insert Zielgruppe_B2B_AktionenToInsert;
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Die gewünschten Änderungen wurden durchgeführt.')); 
			refreshData();
		} catch (Exception e) {
			addExceptionAsMessage(e);
		}
		return null;
	}

	// This is called when the button is pressed.
	public PageReference removeContacts() {
		try {
			// contacts to remove from the campaign
			final List<CampaignMember> campaignMembersToDelete = new List<CampaignMember>();
			
			for (TableRow tableRow : tableRows) {
				if (tableRow.selected) {
					for (Contact contact : tableRow.contacts) {
						campaignMembersToDelete.add(CampaignMembersByContactId.get(contact.id));
					}
				}
			}
			
			delete campaignMembersToDelete;
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Die gewünschten Änderungen wurden durchgeführt.'));
			refreshData();
		} catch (Exception e) {
			addExceptionAsMessage(e);
		}
		return null;
	}
		
	
	static void addExceptionAsMessage(Exception e) {
		String msg = 'Exception: getTypeName(): '+e.getTypeName()+', getMessage(): '+e.getMessage()
				+', getLineNumber: '+e.getLineNumber()+', getStackTraceString: '+e.getStackTraceString() ;
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
		//System.debug(LoggingLevel.ERROR, msg);
		throw e;
	}
	
	static Account insertTestAccount(User user) {
	    Account acc = new Account();
	    acc.Name='Test Account Quote';
	    acc.OwnerId=user.id;
	    acc.BillingStreet='12345';
	    acc.BillingCity='Test';
	    acc.Phone='12456796';
	    acc.BillingCountry='test';
	    acc.BillingPostalCode='134697';
	    acc.BillingState='test';
	    acc.Website='www.test.de';
	    insert acc;
	
	    return acc;  	
	} // end insertTestAccount()
	  
	static User insertTestUser() {
	    Profile p=[Select Id From Profile Where Name='System Administrator'  or Name='Systemadministrator' Limit 1];
	    User u=new User();
	    u.Username='testUser1@jskdfh.jhalksjd';
	    u.LastName='testLastName1';
	    u.Email='testEmail1@bocoasdfasdf.akjshdfl';
	    u.Alias='test1';
	    u.CommunityNickname='testCommun1';
	    u.TimeZoneSidKey='Pacific/kiritimati';
	    u.LocaleSidKey='ar';
	    u.EmailEncodingKey='UTF-8';
	    u.ProfileId=p.Id;
	    u.LanguageLocaleKey='en_US';
	    insert u;  	
	    return u;
	} // end insertTestUser()	
	
	@isTest //(SeeAllData=true) 
	static void test1(){
		Campaign testCampaign1 = new Campaign(name='asdf');
		insert testCampaign1;
		
		User user1 = insertTestUser();
		
		Account zielgruppenTestAccount1 = insertTestAccount(user1);

		Zielgruppe_B2B_Aktion__c z = new Zielgruppe_B2B_Aktion__c(kampagne__c = testCampaign1.id, account__c = zielgruppenTestAccount1.id );
		insert z;
		
		Contact zielgruppenTestContact1 = new Contact(firstName = 'Douglas', LastName='Adams', accountId = zielgruppenTestAccount1.id);
		insert zielgruppenTestContact1;

		CampaignMember zielgruppenCampaignMember1 = new CampaignMember(campaignId = testCampaign1.id, contactId = zielgruppenTestContact1.id);
		insert zielgruppenCampaignMember1;

		Account notZielgruppenTestAccount = insertTestAccount(user1);

		Contact notZielgruppenTestContact1 = new Contact(firstName = 'Douglasus', LastName='Adamsus', accountId = notZielgruppenTestAccount.id);
		insert notZielgruppenTestContact1;

		CampaignMember notZielgruppenCampaignMember1 = new CampaignMember(campaignId = testCampaign1.id, contactId = notZielgruppenTestContact1.id);
		insert notZielgruppenCampaignMember1;
		
		CheckCampaignMembersControllerExtension controller 
		= new CheckCampaignMembersControllerExtension(new ApexPages.StandardController(testCampaign1));

		controller.addAccounts();
		controller.removeContacts();
		
		// Now one CampaignMember should be removed, because it was not part of a Zielgruppe_B2B_Aktion__c: 
		List<CampaignMember> requeryCMs = [SELECT id FROM CampaignMember WHERE campaignId = :testCampaign1.id];
		System.assertEquals(2, requeryCMs.size());	// Actually no add / remove, so should be 2.
	} 

	class TableRow {
		public Account acc { get; private set; }
		public String contactsString { get; private set; }
		public Set<Contact> contacts { get; private set; }
		public Boolean selected { get; set; }
		
		public TableRow(Account accParam, String contactsStringParam, Set<Contact> contactsParam) {
			this.acc = accParam;
			this.contacts = contactsParam;
			this.contactsString = contactsStringParam;
			this.selected = false;
		}
	}		
}