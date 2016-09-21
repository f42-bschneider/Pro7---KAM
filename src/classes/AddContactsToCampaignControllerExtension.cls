public with sharing class AddContactsToCampaignControllerExtension {
	
	//** This list contains all rows which will be displayed on the page */
	public List<ContactWrapper> tableRows {get;set;}
	
	Campaign thisCampaign;
	
	void refresh() {
		try {
			// Get all Zielgruppe_B2B_Aktion__c-objects which belong to this campaign
			List<Zielgruppe_B2B_Aktion__c> zielgruppe_B2B_Aktionen 
				= [SELECT Account__c FROM Zielgruppe_B2B_Aktion__c WHERE Kampagne__c=:thisCampaign.id];
			
			// Collect IDs of all accounts which belong to the campaign.
			List<Id> campaignAccIds = new List<Id>();
			for (Zielgruppe_B2B_Aktion__c zielgruppe_B2B_Aktion : zielgruppe_B2B_Aktionen) {
				campaignAccIds.add(zielgruppe_B2B_Aktion.Account__c);
			}
	
			// Collect IDs of all contacts which already belong to the campaign:
			Set<Id> preexistingCampaignContactIds = new Set<Id>();
			for (CampaignMember campaignMember : [SELECT id, contactId FROM CampaignMember WHERE campaignID=:thisCampaign.id]) {
				preexistingCampaignContactIds.add(campaignMember.contactId);
			}
	
			// Populate the list of all rows which will be displayed on the page
			List<Account> campaignAccounts 
				= [SELECT id, name, (SELECT id, name FROM Contacts ORDER BY name) 
				   FROM Account WHERE id IN :campaignAccIds
				   ORDER BY name
				]
			;
			tableRows = new List<ContactWrapper>();
			for (Account acc : campaignAccounts) {
				for (Contact c : acc.contacts) {
					if ( ! preexistingCampaignContactIds.contains(c.id) )
						tableRows.add(new ContactWrapper(acc, c));
				}
			}
		} catch (Exception e) {
			addExceptionAsMessage(e);
		}			
		
	}
	
	public AddContactsToCampaignControllerExtension(ApexPages.StandardController controller) {
		try {
			thisCampaign = (Campaign) controller.getRecord();

			refresh();
		} catch (Exception e) {
			addExceptionAsMessage(e);
		}			
	} // end method

	
	public PageReference addToCampaign() {
		try {
			List<CampaignMember> campaignMembersToInsert = new List<CampaignMember> (); 
			
			for (ContactWrapper wrapper : tableRows) {
				System.assertNotEquals(null, wrapper);
				if (wrapper.selected) {
                    CampaignMember cm = new CampaignMember();
                    cm.campaignId = thisCampaign.id;
                    cm.contactId = wrapper.contact.id;
                    cm.CurrencyISOCode = wrapper.contact.CurrencyISOCode;
                    campaignMembersToInsert.add(cm);
				}
			}
			
			insert campaignMembersToInsert;
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Die Kontakte wurden hinzugefügt.')); 
		} catch (Exception e) {
			addExceptionAsMessage(e);
		}

		refresh();
		
		return null;
	}
	
	static void addExceptionAsMessage(Exception e) {
		String msg = 'Exception: getTypeName(): '+e.getTypeName()+', getMessage(): '+e.getMessage()
				+', getLineNumber: '+e.getLineNumber()+', getStackTraceString: '+e.getStackTraceString() ;
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
		//System.debug(LoggingLevel.ERROR, msg);
		throw e;
	}
	
	class ContactWrapper {
		public Account acc { get; private set; }
		public Contact contact { get; private set; }
		public Boolean selected { get; set; }
		public ContactWrapper(Account accParam, Contact contactParam) {
			this.acc = accParam;
			this.contact = contactParam;
			this.selected = false;
		}
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
		Campaign campaign1 = new Campaign(name='asdf');
		insert campaign1;
		
		Account account1 = insertTestAccount(insertTestUser());

		Contact contact1 = new Contact(firstName = 'Douglas', LastName='Adams', accountId = account1.id);
		insert contact1;
		
		//CampaignMember campaignMember1 = new CampaignMember(campaignId = campaign1.id, contactId = contact1.id);
		//insert campaignMember1;
		
		
		Zielgruppe_B2B_Aktion__c z = new Zielgruppe_B2B_Aktion__c(kampagne__c = campaign1.id, account__c = account1.id );
		insert z;
		
		AddContactsToCampaignControllerExtension controller 
			= new AddContactsToCampaignControllerExtension(new ApexPages.StandardController(campaign1));
		
		controller.addToCampaign();
	}
}