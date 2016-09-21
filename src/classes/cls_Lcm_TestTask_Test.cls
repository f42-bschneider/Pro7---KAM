/*
@isTest(SeeAllData=true)

private class cls_Lcm_TestTask_Test
{
    static testMethod void RunTest() 
    {
    Lcm_TestTask__c l_oTestTask = [SELECT Id, Lcm_ResultState__c FROM Lcm_TestTask__c LIMIT 1];
    
    l_oTestTask.Lcm_ResultState__c = 'erfolgreich';
    update l_oTestTask;
    
    }
}

*/




@isTest(SeeAllData=false)

private class cls_Lcm_TestTask_Test
{
	
	public static Lcm_Module__c Lcm_Module_TestData;
	public static Lcm_Version__c Lcm_Version_TestData;
	public static Lcm_Requirement__c Lcm_Requirement_TestData;
	public static Lcm_TestCase__c Lcm_TestCase_TestData;
	public static Lcm_TestPhase__c Lcm_TestPhase_TestData;
	public static Lcm_TestTask__c Lcm_TestTask_TestData;
	
	 
	public static Lcm_Module__c createTestLcmModule(Boolean p_bInsertObject) {
		Lcm_Module_TestData = new Lcm_Module__c();
        
		Lcm_Module_TestData.Lcm_ModuleName__c = 'Test Modul';
		Lcm_Module_TestData.Lcm_Description__c = 'Dies ist das neue Testmodul';
		Lcm_Module_TestData.Lcm_TestSphere__c = 'SomDig';
		
		if (p_bInsertObject) insert Lcm_Module_TestData;
		return Lcm_Module_TestData;
	}
	public static Lcm_Version__c createTestLcmVersion(Boolean p_bInsertObject, Lcm_Module__c p_oLcmModule) {
		Lcm_Version_TestData = new Lcm_Version__c();
        
		Lcm_Version_TestData.Lcm_Module__c = (p_oLcmModule == null) ? createTestLcmModule(true).Id : p_oLcmModule.Id;
		Lcm_Version_TestData.Lcm_VersionName__c = 'V 0.9';
		Lcm_Version_TestData.Lcm_State__c = 'Geplant';
		Lcm_Version_TestData.Lcm_Description__c = 'first beta';
		
		
		if (p_bInsertObject) insert Lcm_Version_TestData;
		return Lcm_Version_TestData;
	}
	public static Lcm_Requirement__c createTestLcmRequirement(Boolean p_bInsertObject, Lcm_Version__c p_oLcmVersion) {
		Lcm_Requirement_TestData = new Lcm_Requirement__c();
        
		Lcm_Requirement_TestData.Lcm_Version__c = (p_oLcmVersion == null) ? createTestLcmVersion(true, null).Id : p_oLcmVersion.Id;
        
		Lcm_Requirement_TestData.Lcm_RequirementName__c = 'Validierung abc';
		Lcm_Requirement_TestData.Lcm_Status__c = 'to specify';
		Lcm_Requirement_TestData.Lcm_Description__c = 'asdf asdf asdf asd fa sd fasd f asd f as fas dfas dfasd fasd fas dfas dfas dfas dfas df';
		
		if (p_bInsertObject) insert Lcm_Requirement_TestData;
		return Lcm_Requirement_TestData;
	}
	public static Lcm_TestCase__c createTestLcmTestCase(Boolean p_bInsertObject, Lcm_Requirement__c p_oLcmRequiremnt) {
		Lcm_TestCase_TestData = new Lcm_TestCase__c();
		
		Lcm_TestCase_TestData.Lcm_Requirement__c = (p_oLcmRequiremnt == null) ? createTestLcmRequirement(true, null).Id : p_oLcmRequiremnt.Id;
		Lcm_TestCase_TestData.Lcm_Description__c = 'Fehlerghafte Eingaben führen zu Fehlermeldung';
		Lcm_TestCase_TestData.Lcm_ExpResult__c = 'Validierung schlägt an';
		Lcm_TestCase_TestData.Lcm_Precondition__c = 'Account ausgewählt';
		Lcm_TestCase_TestData.Lcm_State__c = '1 in Bearbeitung';
		Lcm_TestCase_TestData.Lcm_Step01__c = 'ausfüllen';
		Lcm_TestCase_TestData.Lcm_Step02__c = 'speichern';
		Lcm_TestCase_TestData.Lcm_Testdata__c = 'Account BMW';
		
		if (p_bInsertObject) insert Lcm_TestCase_TestData;
		return Lcm_TestCase_TestData;
	}
	public static Lcm_TestPhase__c createTestLcmTestPhase(Boolean p_bInsertObject, Lcm_Version__c p_oLcmVersion) {
		Lcm_TestPhase_TestData = new Lcm_TestPhase__c();
		
		Lcm_TestPhase_TestData.Lcm_Version__c = (p_oLcmVersion == null) ? createTestLcmVersion(true, null).Id : p_oLcmVersion.Id;
		Lcm_TestPhase_TestData.Lcm_TestphaseName__c = 'Pretest';
		Lcm_TestPhase_TestData.Lcm_Start__c = date.newInstance(2015, 2, 2); 
		Lcm_TestPhase_TestData.Lcm_Ende__c = date.newInstance(2015, 3, 3);
		
		if (p_bInsertObject) insert Lcm_TestPhase_TestData;
		return Lcm_TestPhase_TestData;
	}
	public static Lcm_TestTask__c createTestLcmTestTask(Boolean p_bInsertObject, Lcm_TestCase__c p_oTestCase, Lcm_TestPhase__c p_oTestPhase) {
		Lcm_TestTask_TestData = new Lcm_TestTask__c();

		Lcm_TestTask_TestData.Lcm_TestCase__c = (p_oTestCase == null) ? createTestLcmTestCase(true, null).Id : p_oTestCase.Id;
		Lcm_TestTask_TestData.Lcm_TestPhase__c = (p_oTestPhase == null) ? createTestLcmTestPhase(true, null).Id : p_oTestPhase.Id;

		if (p_bInsertObject) insert Lcm_TestTask_TestData;
		return Lcm_TestTask_TestData;
	}
	
	static testMethod void RunTest() 
	{

		createTestLcmModule(true);
		
		createTestLcmVersion(true, null);
		createTestLcmVersion(true, Lcm_Module_TestData);
				
		createTestLcmRequirement(true, null);
		createTestLcmRequirement(true, Lcm_Version_TestData);
		
		createTestLcmTestCase(true, null);
		createTestLcmTestCase(true, Lcm_Requirement_TestData);
		
		createTestLcmTestPhase(true, null);
		createTestLcmTestPhase(true, Lcm_Version_TestData);
		
		createTestLcmTestTask(true, Lcm_TestCase_TestData, Lcm_TestPhase_TestData);
		

		createTestLcmTestTask(true, null, null);
		Lcm_TestTask__c l_oTestTask = [SELECT Id, Lcm_TestCasePrecondition__c, Lcm_testCase__r.Lcm_Precondition__c FROM Lcm_TestTask__c LIMIT 1];
		system.assert( l_oTestTask.Lcm_TestCasePrecondition__c == l_oTestTask.Lcm_testCase__r.Lcm_Precondition__c , 'Precondition nicht übernommen');
		
		//  l_oTestTask.Lcm_ResultState__c = 'erfolgreich';
        
	}
}