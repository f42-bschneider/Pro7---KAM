/**
 * A batch, schedulabel job to check the validity of user as salesperon.
 */
global with sharing class UserSalespersonValidityChecker implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
	/** Batch size. */
	private Integer batchSize = 50;
	
	/** UserIds to force to check. */
	private Set<Id>	userIds = null;

	/* stateful parameters for statistics. */
	global 	Integer 			totalBatchs		= 0;
	global 	Integer 			totalRecords	= 0;

	/**
	 * Set the Id of Users to check.
	 */
	public void setUserIds(Set<Id> uIds) {
		this.userIds = uIds;
	}
	
	/**
	 * Add an ID of User to check.
	 */
	public void addUserId(Id uId) {
		if (this.userIds == null) {
			this.userIds = new Set<Id>();
		}
		this.userIds.add(uId);
	}

	/**
	 * Batch job start routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String query =	'SELECT Id, SomTv_BetreuerGueltigVon__c, SomTv_BetreuerGueltigBis__c FROM User WHERE IsActive = true';
		
		if (userIds != null) {			 
			userIds.remove(null);
			if (!userIds.isEmpty()) {
				query += ' AND Id IN :userIds';
			}
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
		totalBatchs++;
		totalRecords += records.size();

    	System.debug('\n\nUserSalespersonValidityChecker: Execute: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', SizeOfBatchRecords = ' + records.size() + ', BatchJobId = ' + (bc == null ? '' : bc.getJobId()));    	

		Set<Id> uIds = new Set<Id>();
		
		for (User u : (List<User>)records) {
			uIds.add(u.Id);
		}
		
		map<Id, SomTv_Verkaeuferzuordnung__c> mVerkaeuferzuordnung = new map<Id, SomTv_Verkaeuferzuordnung__c>();
		
		String query = 'SELECT Id, SomTv_Verkaeufer__c, SomTv_GueltigVon__c, SomTv_GueltigBis__c FROM SomTv_Verkaeuferzuordnung__c '
					 + 'WHERE isDeleted = false AND SomTv_Verkaeufer__c IN :uIds '
					 + 'ORDER BY SomTv_Verkaeufer__c';
	
		for (SomTv_Verkaeuferzuordnung__c walker : Database.query(query)) {
			SomTv_Verkaeuferzuordnung__c zuordnung = mVerkaeuferzuordnung.get(walker.SomTv_Verkaeufer__c);
			if (zuordnung == null) {
				mVerkaeuferzuordnung.put(walker.SomTv_Verkaeufer__c, walker);
			} else {
				if (zuordnung.SomTv_GueltigVon__c != null && (walker.SomTv_GueltigVon__c == null || walker.SomTv_GueltigVon__c < zuordnung.SomTv_GueltigVon__c)) {
					zuordnung.SomTv_GueltigVon__c = walker.SomTv_GueltigVon__c;
				}
				if (zuordnung.SomTv_GueltigBis__c != null && (walker.SomTv_GueltigBis__c == null || walker.SomTv_GueltigBis__c > zuordnung.SomTv_GueltigBis__c)) {
					zuordnung.SomTv_GueltigVon__c = walker.SomTv_GueltigVon__c;
				}
			}
		}
		
		List<User> toUpdate = new List<User>();
		
		for (User u : (List<User>)records) {
			if (mVerkaeuferzuordnung.containsKey(u.Id) && (u.SomTv_BetreuerGueltigVon__c != mVerkaeuferzuordnung.get(u.Id).SomTv_GueltigVon__c || u.SomTv_BetreuerGueltigBis__c != mVerkaeuferzuordnung.get(u.Id).SomTv_GueltigBis__c)) {
				u.SomTv_BetreuerGueltigVon__c = mVerkaeuferzuordnung.get(u.Id).SomTv_GueltigVon__c;
				u.SomTv_BetreuerGueltigBis__c = mVerkaeuferzuordnung.get(u.Id).SomTv_GueltigBis__c;
				toUpdate.add(u);
			}
		}
		
		if (!toUpdate.isEmpty()) {
			update toUpdate;
		}		
	}
	
	/**
	 * Batch job completion routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global void finish(Database.BatchableContext bc){
    	AsyncApexJob a = null;
    	
    	if (bc != null) {
    		a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
    	}

    	System.debug('\n\nUserSalespersonValidityChecker: Finish: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', ' + a);    	
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
	@isTest
	public static void testUserSalespersonValidityChecker() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Systemadministrator' Limit 1];
        User    u = new User(Username='testUSVC@test.com', LastName='testUSVC', 
                             Email='testUSVC@test.com', Alias='test', CommunityNickname='testUSVC',
                             TimeZoneSidKey='Europe/Berlin', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                             ProfileId=p.Id, LanguageLocaleKey='en_US');
        insert u;

        System.runAs(u) {
			Test.StartTest();

			Account acc1 = new Account(Name='Test Account 1', SomTv_Gruendungsjahr__c='2013');
			insert acc1;

			SomTV_KundeAgenturBeziehung__c kab1 = new SomTV_KundeAgenturBeziehung__c(Kunde__c=acc1.Id, GueltigVon__c=system.today(), Gueltigbis__c=system.today()+2);
			insert kab1;
			
			SomTv_Verkaeuferzuordnung__c vz1 = new SomTv_Verkaeuferzuordnung__c(SomTv_KdAgenturBeziehung__c=kab1.Id, SomTv_Verkaeufer__c=u.Id, SomTv_Verkaeuferrolle__c='TV_Leadverkäufer', SomTv_GueltigVon__c=system.today(), SomTv_GueltigBis__c=system.today()+2);
			insert vz1;
			
			SchedulableContext sc;

			UserSalespersonValidityChecker usvc = new UserSalespersonValidityChecker();

			usvc.setUserIds(null);
			
			usvc.addUserId(u.id);

			usvc.execute(sc);

			Test.StopTest();
        }
	}
	

}