/**
 * A batch, schedulabel job to check the AccountHistory__c and set the aktual ParentAccount.
 */
global with sharing class AccountParentAccountBatch implements Database.Batchable<SObject>, Schedulable {

	/** Batch size. */
	private Integer batchSize = 50;

	/** Flag, whether in Test-Mode. */
	private Boolean isTest = false;

	/** Id of AccountId to use in Test-Mode. */
	private Id accId = null;

	/**
	 * Set the isTest flag.
	 */
	public void setIsTest(Boolean flag) {
		isTest = flag;
	}

	/**
	 * Set the Id of AccountId to use for test.
	 */
	public void setAccountId(Id aid) {
		accId = aid;
	}

	/**
	 * Batch job start routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String now = Datetime.now().format('yyyy-MM-dd');

		// CR: SOTV-28, 2014-04-11: Der Job soll nur für Sphäre SomDe.
		// 2014-07-28 Job soll f�r SomDe und SomAt laufen
		String query =	'SELECT Id, ParentId, ' +
						' (SELECT Id, UntergeordneterAccount__c, UebergeordneterAccount__c, GueltigVon__c, GueltigBis__c, Som_NrRolleDwh__c FROM AccountHistoriesChild__r ' +
						'  WHERE isDeleted = false AND UebergeordneterAccount__c != null AND GueltigVon__c <= ' + now + ' AND (GueltigBis__c = null OR GueltigBis__c >= ' + now + ') ORDER BY GueltigVon__c DESC) ' +
						'FROM Account ' +
						'WHERE isDeleted = false AND ungueltiger_Account__c = false AND P7S1_Sphere__c IN ( \'SomDe\', \'SomAt\' )  ';

		if (isTest) {
			if (accId != null) {
				query += ' AND Id = \'' + accid + '\'';
			}
			query += ' LIMIT 1';
		}

		return Database.getQueryLocator(query);
	}

	/**
	 * Batch job excution routine.
	 *
	 * @param	bc		Context of the batchable job.
	 * @param	records	List of sObject to process.
	 */
	global void execute(Database.BatchableContext bc, List<sObject> records) {
		// Accounts to update.
		List<Account> toUpd = new List<Account>();
		for (Account acc : (List<Account>)records) {
			// CR: SOTV-28, 2014-04-11: Sollten zwei gültige Zeiträume überlappen, nur gilt Rolle 2 (Kunde).
			AccountHistory__c lastAccountHistory = null;
			if (acc.AccountHistoriesChild__r != null) {
				for (AccountHistory__c a : acc.AccountHistoriesChild__r) {
					if (a.UntergeordneterAccount__c == acc.Id && a.UebergeordneterAccount__c != null) {
						if (lastAccountHistory == null) {
							lastAccountHistory = a;
						} else {
							// Check mögliche zeitliche Überlappung.
							// Ähnliche wie die in SomTv_AccountHistoryTrigger.isValidData()
		    				if (a.GueltigVon__c < lastAccountHistory.GueltigVon__c && (a.GueltigBis__c != null && a.GueltigBis__c < lastAccountHistory.GueltigVon__c)) {
		    					// left out side of curGueltigVon
		    				} else if (lastAccountHistory.GueltigBis__c != null && a.GueltigVon__c > lastAccountHistory.GueltigBis__c) {
		    					// right out side of curGueltigBis
		    				} else {
		    					// Overlapped
		    					if ('1'.equals(lastAccountHistory.Som_NrRolleDwh__c) && '2'.equals(a.Som_NrRolleDwh__c)) {
		    						lastAccountHistory = a;
		    					}
		    				}
						}
					}
				}
			}

			Id parentId = null;
			if (lastAccountHistory != null) {
				parentId = lastAccountHistory.UebergeordneterAccount__c;
			}

			/* CR: 2014-04-02, SOTV-28. Self-reference allowed, but here need to set to null. */
			if (parentId == acc.Id) {
				parentId = null;
			}

			if (acc.ParentId != parentId) {
				acc.ParentId = parentId;
				toUpd.add(acc);
			}
		}

		if (!toUpd.isEmpty()) {
			update toUpd;
		}
	}

	/**
	 * Batch job completion routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global void finish(Database.BatchableContext bc){
	}

	/**
	 * Schedule excution routine.
	 *
	 * @param	sc	Context of the schedule job.
	 */
	global void execute(SchedulableContext sc) {
		Database.executeBatch(this, batchSize);
	}

	/**
	 *	A test method.
	 */
	@isTest(SeeAllData=true)
	public static void testAccountTeamMemberBatch() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Systemadministrator' Limit 1];
        User    u = new User(Username='testAZT@test.com', LastName='testAZT',
                             Email='testAZT@test.com', Alias='test', CommunityNickname='testAZT',
                             TimeZoneSidKey='Europe/Berlin', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                             ProfileId=p.Id, LanguageLocaleKey='en_US', P7S1_Sphere__c='SomDe');
        insert u;

        System.runAs(u) {
        	Account acc1 = new Account(Name='TestAccount1');
        	insert acc1;

        	Account acc2 = new Account(Name='TestAccount2');
        	insert acc2;

			AccountHistory__c ah = new AccountHistory__c(UebergeordneterAccount__c = acc1.id,
														 UntergeordneterAccount__c = acc2.id,
														 GueltigVon__c = system.today(),
														 GueltigBis__c = system.today());
			insert ah;

			Test.StartTest();

			AccountParentAccountBatch apab = new AccountParentAccountBatch();
			apab.setIsTest(true);
			apab.setAccountId(acc2.id);
			SchedulableContext sc;
			apab.execute(sc);

			Test.StopTest();
        }
	}

}