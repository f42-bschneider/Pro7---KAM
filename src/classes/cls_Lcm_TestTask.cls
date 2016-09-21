public with sharing class cls_Lcm_TestTask {

	// #########################################################
	public void RunTrigger(
		Boolean p_bIsBefore, Boolean p_bIsAfter,
		Boolean p_bIsInsert, Boolean p_bIsUpdate,
		Boolean p_bIsDelete, Boolean p_bIsUnDelete,
		List<Lcm_TestTask__c> p_olNew, Map<Id, Lcm_TestTask__c> p_mNewMap,
	List<Lcm_TestTask__c> p_olOld, Map<Id, Lcm_TestTask__c> p_mOldMap) {

		Lcm_TestCase__c l_oTestCase;

		// Kopiere Wert aus Lcm_State__c nach Lcm_StateCopy__c
		if (p_bIsBefore && (p_bIsInsert || p_bIsUpdate || p_bIsUnDelete)) {
			for (Lcm_TestTask__c l_oTask: p_olNew) { //Trigger.new
				l_oTask.Lcm_StateCopy__c = l_oTask.Lcm_State__c;

			} //for
		} //if

		// Kopiere Werte aus TestCase bei Insert
		if (p_bIsBefore && (p_bIsInsert)) {
			Map < Id, Lcm_TestCase__c > l_oMapTestCase = getTestCases(p_olNew);

			for (Lcm_TestTask__c l_oTask: p_olNew) {
				l_oTestCase = l_oMapTestCase.get(l_oTask.Lcm_TestCase__c);

				l_oTask.Lcm_RequirementName__c = l_oTestCase.Lcm_RequirementName__c;
				l_oTask.Lcm_RequirementDescription__c = l_oTestCase.Lcm_RequirementDescription__c;
				l_oTask.Lcm_TestCaseName__c = l_oTestCase.Lcm_TestCaseName__c;
				l_oTask.Lcm_TestCaseDescription__c = l_oTestCase.Lcm_Description__c;
				l_oTask.Lcm_TestCasePrecondition__c = l_oTestCase.Lcm_Precondition__c;
				l_oTask.Lcm_TestCaseTestdata__c = l_oTestCase.Lcm_Testdata__c;
				l_oTask.Lcm_TestCaseExpResult__c = l_oTestCase.Lcm_ExpResult__c;
				l_oTask.Lcm_TestCaseSteps__c = l_oTestCase.Lcm_Steps__c;

			} //for
		} //if


	} //RunTrigger

	private Map<Id, Lcm_TestCase__c> getTestCases (List <Lcm_TestTask__c> p_oListTestTasks) {

		Set<Id> l_oSetTestCaseIds = new Set<Id>();
		For(Lcm_TestTask__c l_oTestTask :p_oListTestTasks) {
		system.debug('### l_oTestTask: ' + l_oTestTask.Id);
		system.debug('### l_oTestCase: ' + l_oTestTask.Lcm_TestCase__c);
		l_oSetTestCaseIds.add(l_oTestTask.Lcm_TestCase__c);
	}

		Map < Id, Lcm_TestCase__c > l_oMapTestCases = new Map<Id, Lcm_TestCase__c>
			([SELECT Id, Lcm_RequirementName__c, Lcm_RequirementDescription__c, Lcm_TestCaseName__c, Lcm_Description__c, Lcm_Precondition__c, Lcm_Testdata__c, Lcm_ExpResult__c, Lcm_Steps__c FROM Lcm_TestCase__c WHERE Id IN :l_oSetTestCaseIds ]);
		Return l_oMapTestCases;

		}

}