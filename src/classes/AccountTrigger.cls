/**
 *  The trigger controller class for sObject Account.
 */
public with sharing class AccountTrigger extends TriggerController {
    /**
     * Constructor.
     * @see TriggerController   The base class of trigger controller.
     */
	public AccountTrigger(Boolean isAfter, Boolean isBefore,
		Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
		List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
	{
		super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
	}

    /**
     * Override method to perform action after an insert operation was fired.
     * @see TriggerController#runAfterInsert
     */
	protected override void runAfterInsert() {
		checkParentAccount();
	}

    /**
     * Override method to perform action after an update operation was fired.
     * @see TriggerController#runAfterUpdate
     */
	protected override void runAfterUpdate() {
		checkParentAccount();

	}

    /**
     * Override method to perform action after a delete operation was fired.
     * @see TriggerController#runAfterDelete
     */
	protected override void runAfterDelete() {
		checkParentAccount();
	}

    /**
     * Override method to perform action after an undelete operation was fired.
     * @see TriggerController#runAfterUndelete
     */
	protected override void runAfterUndelete() {
		checkParentAccount();
	}

    /**
     * Override method to perform action before an update operation was fired.
     * @see TriggerController#runBeforeUpdate
     */
	protected override void runBeforeUpdate() {
		checkName((List<Account>) lstNewItems, (Map<Id, Account>) mapOldItems);
		checkProRexRolle((List<Account>) lstNewItems, (Map<Id, Account>) mapOldItems);
		serializeProrexRolle((List<Account>) lstNewItems, (Map<Id, Account>) mapOldItems);
	}

    /**
     * Override method to perform action before an update operation was fired.
     * @see TriggerController#runBeforeInsert
     */
	protected override void runBeforeInsert() {
		checkProRexRolle((List<Account>) lstNewItems, (Map<Id, Account>) mapOldItems);
		serializeProrexRolle((List<Account>) lstNewItems, null);
	}

    /**
    * set SomTv_HilfsfeldProRexRolle__c (Text) with value from ProRex_Rolle__c (Multiselect)
    * @param List<Account> Trigger.new
    * @param Map<Id, Account> Trigger.oldMap
    **/
	private void serializeProrexRolle(List<Account> newAccs, Map<Id, Account> oldMapAccs) {
		for (Account acc : newAccs) {
			if (isInsert ||
				acc.SomTv_HilfsfeldProRexRolle__c != oldMapAccs.get(acc.Id).SomTv_HilfsfeldProRexRolle__c ||
			acc.ProRex_Rolle__c != oldMapAccs.get(acc.Id).ProRex_Rolle__c ) {
				acc.SomTv_HilfsfeldProRexRolle__c = acc.ProRex_Rolle__c;
			}
		}
	}

	private void checkProRexRolle(List<Account> p_oListNewAccs, Map<Id, Account> p_oMapOldAccs) {
		// Add values Kunde and Agentur automatically to ProRex_Rolle__c, depending on rules based on field SomTv_Accounttypen__c
		// https://jira.sim-technik.de/browse/CRMSALES-2378
		
		for (Account l_oAcc : p_oListNewAccs) {
			if (isInsert ||
				l_oAcc.SomTv_Accounttypen__c != p_oMapOldAccs.get(l_oAcc.Id).SomTv_Accounttypen__c ||
				l_oAcc.SomTv_HilfsfeldProRexRolle__c != p_oMapOldAccs.get(l_oAcc.Id).SomTv_HilfsfeldProRexRolle__c ||
			l_oAcc.ProRex_Rolle__c != p_oMapOldAccs.get(l_oAcc.Id).ProRex_Rolle__c ) {

				if (l_oAcc.SomTv_Accounttypen__c != null) {
					if (l_oAcc.SomTv_Accounttypen__c == 'Agentur') {
						l_oAcc.ProRex_Rolle__c = cls_P7S1_Utils.multiPicklist_AddValue(l_oAcc.ProRex_Rolle__c, 'Agentur');
					}
					
					if (l_oAcc.SomTv_Accounttypen__c == 'Konzern') {
						l_oAcc.ProRex_Rolle__c = cls_P7S1_Utils.multiPicklist_AddValue(l_oAcc.ProRex_Rolle__c, 'Konzern');
					}

					if (l_oAcc.SomTv_Accounttypen__c == 'Agenturverbund') {
						l_oAcc.ProRex_Rolle__c = cls_P7S1_Utils.multiPicklist_AddValue(l_oAcc.ProRex_Rolle__c, 'Agenturverbund');
					}
					
					if (l_oAcc.SomTv_Accounttypen__c.contains('Bestand') || l_oAcc.SomTv_Accounttypen__c.contains('Winback') || l_oAcc.SomTv_Accounttypen__c.contains('Neugeschäft')) {
						l_oAcc.ProRex_Rolle__c = cls_P7S1_Utils.multiPicklist_AddValue(l_oAcc.ProRex_Rolle__c, 'Kunde');
					}
					
				}
			}
		}
		
	}

	
	
    /**
     * Check whether the pararent Account of newly changed accounts is changed and whether parent Accounts need to be updated.
     *
     */
	private void checkParentAccount() {
		List<Account> lstRecords = null;

		if (isAfter && (isInsert || isUpdate || isUndelete)) {
			lstRecords = (List<Account>) lstNewItems;
		} else if (isAfter && isDelete) {
			lstRecords = (List<Account>) lstOldItems;
		}

		if (lstRecords == null || lstRecords.isEmpty()) {
			return;
		}

		Set<Id> parentGotChild = new Set<Id>();
		Set<Id> parentLostChild = new Set<Id>();

		for (Account acc : lstRecords) {
			if (acc.ParentId != null) {
				if (isInsert || isUndelete) {
					parentGotChild.add(acc.ParentId);
				} else if (isDelete) {
					parentLostChild.add(acc.ParentId);
				} else if (isUpdate) {
					Account acc_old = mapOldItems == null ? null : (Account) mapOldItems.get(acc.Id);

					if (acc_old != null && acc.ParentId != acc_old.ParentId) {
						parentGotChild.add(acc.ParentId);
						parentLostChild.add(acc_old.ParentId);
					}
				}
			} else {
				if (isUpdate) {
					Account acc_old = mapOldItems == null ? null : (Account) mapOldItems.get(acc.Id);

					if (acc_old != null && acc_old.ParentId != null) {
						parentLostChild.add(acc_old.ParentId);
					}
				}
			}
		}

		if (!parentGotChild.isEmpty()) {
			for (List<Account> accs : [SELECT Id, HasChildAccount__c FROM Account WHERE isDeleted = false AND HasChildAccount__c = false AND Id IN :parentGotChild ORDER BY Id]) {
			for (Account acc : accs) {
				acc.HasChildAccount__c = true;
			}
			update accs;
		}
			}

		if (!parentLostChild.isEmpty()) {
			Set<Id> tmp = new Set<Id>();
			for (List<Account> accs : [SELECT Id, ParentId FROM Account WHERE isDeleted = false AND ParentId IN :parentLostChild ORDER BY ParentId]) {
			for (Account acc : accs) {
				tmp.add(acc.ParentId);
			}
		}

			parentLostChild.removeAll(tmp);

			if (!parentLostChild.isEmpty()) {
				for (List<Account> accs : [SELECT Id, HasChildAccount__c FROM Account WHERE isDeleted = false AND HasChildAccount__c = true AND Id IN :parentLostChild ORDER BY Id]) {
				for (Account acc : accs) {
					acc.HasChildAccount__c = false;
				}
				update accs;
			}
				}
			}
	}

    /**
     * Check whether the name of Account is changed thus to perform further actions.
     *
     */
	private void checkName(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {

		Map<Id, Account> accById = new Map<Id, Account> ();

		for (Account acc : newAccounts) {
			if (acc.Name != oldAccountMap.get(acc.Id).Name) {
				accById.put(acc.Id, acc);
			}
		}

		if (!accById.isEmpty()) {
			// Get those Accounts that have extern IDs with Quelle__c = 'Debitorennr TV' and Name != null.

			for (Account acc : [SELECT Id, (SELECT Id FROM P7S1_ExternalId__r WHERE isDeleted = false AND P7S1_Source__c = 'Debitorennr TV' AND Name != null)
			FROM Account WHERE Id IN :accById.keySet()]) {

			if (!acc.P7S1_ExternalId__r.isEmpty()) {

				if (accById.get(acc.Id).SomTv_DebCheckerEmailVersendet__c == false) {
					accById.get(acc.Id).SomTv_DebitorennummerChecker__c = true;
				} else {
					accById.get(acc.Id).SomTv_DebitorennummerChecker__c = false;
					accById.get(acc.Id).SomTv_DebCheckerEmailVersendet__c = false;
				}
			}
		}

			for (Account acc : newAccounts) {
				if (accById.containsKey(acc.Id)) {
					acc.SomTv_DebCheckerEmailVersendet__c = accById.get(acc.Id).SomTv_DebCheckerEmailVersendet__c;
					acc.SomTv_DebitorennummerChecker__c = accById.get(acc.Id).SomTv_DebitorennummerChecker__c;
				}
			}
			}
	}

    /**
     * A Test Methode.
     */
	public static testMethod void testAccountTrigger() {
		Test.startTest();

		// A (parent) Account
		Account acc1 = new Account(Name = 'A test account 1');
		insert acc1;

		// acc1 should not have child
		Account acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc1.Id];
		System.assert(!acc.HasChildAccount__c);

		// Another (parent) Account
		Account acc2 = new Account(Name = 'A test account 2');
		insert acc2;

		// acc2 should not have child
		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc2.Id];
		System.assert(!acc.HasChildAccount__c);

		// A (child) Account, parent is acc1
		Account acc3 = new Account(Name = 'A test account 3', ParentId = acc1.Id);
		insert acc3;

		// acc1 should have child, acc2 not.
		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc1.Id];
		System.assert(acc.HasChildAccount__c);

		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc2.Id];
		System.assert(!acc.HasChildAccount__c);

		// Change parent of acc3 to acc2.
		acc3.ParentId = acc2.Id;
		update acc3;

		// acc1 should not have child, acc2 have.
		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc1.Id];
		System.assert(!acc.HasChildAccount__c);

		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc2.Id];
		System.assert(acc.HasChildAccount__c);

		// delete acc3.
		delete acc3;

		// both acc1 and acc2 should not have child.
		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc1.Id];
		System.assert(!acc.HasChildAccount__c);

		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc2.Id];
		System.assert(!acc.HasChildAccount__c);

		// undelete acc3.
		undelete acc3;

		// acc1 should not have child, acc2 have.
		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc1.Id];
		System.assert(!acc.HasChildAccount__c);

		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc2.Id];
		System.assert(acc.HasChildAccount__c);

		// set acc3 without parent.
		acc3.ParentId = null;
		update acc3;

		// both acc1 and acc2 should not have child.
		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc1.Id];
		System.assert(!acc.HasChildAccount__c);

		acc = [SELECT Id, HasChildAccount__c FROM Account WHERE Id = :acc2.Id];
		System.assert(!acc.HasChildAccount__c);

		P7S1_ExternalId__c extId = new P7S1_ExternalId__c(P7S1_Account__c = acc3.Id, P7S1_Source__c = 'Debitorennr TV', Name = '12345');
		insert extId;

		acc3.Name = 'A test account 3_1';
		update acc3;

		Test.stopTest();
	}

}