@isTest
public without sharing class CapTableTests {

	@isTest
	static void test1CoverageOnly() {
		Account sevenVenturesAcc = ClsHelper.newTestAccount(System.UserInfo.getUserId(), 'sevenVenturesAcc');
		sevenVenturesAcc.AccountNumber = '1';
		insert sevenVenturesAcc;

		Account acc = ClsHelper.newTestAccount(System.UserInfo.getUserId(), 'Test account 1');
		insert acc;

		CapTableEditorController controller = new CapTableEditorController(new ApexPages.StandardController(acc));

		controller.getC();
		controller.newestRoundWrapperInstance.getNewestRoundShares();

	}


	@isTest
	static void test1() {
		Account sevenVenturesAcc = ClsHelper.newTestAccount(System.UserInfo.getUserId(), 'sevenVenturesAcc');
		sevenVenturesAcc.AccountNumber = '1';
		insert sevenVenturesAcc;

		Account acc = ClsHelper.newTestAccount(System.UserInfo.getUserId(), 'Test account 1');
		insert acc;

		{
			Savepoint savepoint1 = Database.setSavepoint();

			// Having no rounds at all could fail. Let's test it:
			CapTableEditorController controllerEmpty = new CapTableEditorController(new ApexPages.StandardController(acc));
			controllerEmpty.createFirstRound();
			controllerEmpty.newestRoundWrapperInstance.getNewestRound().Ven_G_ltig_ab__c = Date.today();
			controllerEmpty.saveRoundButton();

			Database.rollback(savepoint1);
		}

		Ven_Share__c share = ClsHelper.insertRounds1And2AndShares(acc.Id);

		{  // The following test this: If the user presses "Neue Runde" the shares of the old round should be copied to the new one.
			// This test test fails in rev7484 if you insert it there.

			Savepoint savepoint1 = Database.setSavepoint();

			CapTableEditorController controller = new CapTableEditorController(new ApexPages.StandardController(acc));

			controller.getOldRoundsExistFlag(); // just for coverage

			controller.newRound();

			System.assertNotEquals(0,controller.newestRoundWrapperInstance.newestRoundShares.size(),'Fail: Shares have not been copied to new round!');

			Database.rollback(savepoint1);
		}

		{  // The following test this: If the user presses "Runde löschen" the next lower should be marked as active.
			// This test test fails in rev7484 if you insert it there.

			Savepoint savepoint1 = Database.setSavepoint();

			CapTableEditorController controller = new CapTableEditorController(new ApexPages.StandardController(acc));

			{
				Ven_Round__c currentRound = controller.getRecordsOfCurrentSetControllerPage()[0];

				System.assertEquals(2.0,currentRound.Ven_Round_Number__c, 'Wrong round number.');
				System.assert(currentRound.Ven_Aktiv__c, 'Ven_Aktiv__c should be true, but is not!');
			}

			controller.deleteRoundButton();

			{
				Ven_Round__c currentRound = controller.getRecordsOfCurrentSetControllerPage()[0];
				System.assertEquals(1.0,currentRound.Ven_Round_Number__c, 'Wrong round number.');
				System.assert(currentRound.Ven_Aktiv__c, 'Ven_Aktiv__c should be true, but is not!');
			}

			System.assertNotEquals(0,controller.newestRoundWrapperInstance.newestRoundShares.size()
				,'Fail: Shares have not been copied to new round!'
			);

			Database.rollback(savepoint1);
		}

		CapTableEditorController controller = new CapTableEditorController(new ApexPages.StandardController(acc));


		Apexpages.currentPage().getParameters().put('shareToBeDeletedId',share.id);
		controller.deleteShare();

		controller.newShare();
		controller.newRound();
		controller.saveRoundButton();

		controller.cancel();
		controller.editFlag = true;
		controller.cancel();

		controller.edit();
	}

}