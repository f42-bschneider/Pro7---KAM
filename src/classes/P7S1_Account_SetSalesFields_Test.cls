/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_Account_SetSalesFields_Test
* @author:		BS factory42
* @email:		bschneider@factory42.com
* @version:		V0.1
* @date:		Nov 25, 2015
* @last change:	
* @description:	
* @objects:		
* =================================================================
*/
@isTest
private class P7S1_Account_SetSalesFields_Test {
	
	private static User insertUser;
	private static String currentUserId = UserInfo.getUserId();
	private static Integer cnt = 30;

	/***********************
    * Test Account update
    ***/
    static testMethod void testAccountUpdate() {
    	
    	//Testdata
    	createTestData();
    	
    	Test.startTest();
    	//*********************************
		
		P7S1_Account_SetSalesFields.runTwice = false;
    	update [SELECT Id FROM Account];
    	
    	for(Account acc : [SELECT SOM_TVKundenverkaeufer__c FROM Account]){
    		system.assertEquals(currentUserId,acc.SOM_TVKundenverkaeufer__c);
    	}
    	
    	//*********************************
    	Test.stopTest();
		
    }
    
    /***********************
    * Test AccountAccess update
    ***/
    static testMethod void testAccountAccessUpdate() {
		
		//Testdata
    	createTestData();
    	
    	Test.startTest();
    	//*********************************
    	
    	P7S1_Account_SetSalesFields.runTwice = false;
    	update [SELECT Id FROM P7S1_AccountAccess__c];
    	
    	for(Account acc : [SELECT SOM_TVKundenverkaeufer__c FROM Account]){
    		system.assertEquals(currentUserId,acc.SOM_TVKundenverkaeufer__c);
    	}
    	
    	//*********************************
    	Test.stopTest();
        
    }
    
    /***********************
    * Test Opportunity Approval update
    ***/
    static testMethod void testOpportunityApprovalUpdate() {
		
		//Testdata
    	createTestData();
    	
    	Test.startTest();
    	//*********************************
    	
    	P7S1_Account_SetSalesFields.runTwice = false;
    	update [SELECT Id FROM P7S1_OpportunityApproval__c];
    	
    	for(Account acc : [SELECT SOM_TVKundenverkaeufer__c FROM Account]){
    		system.assertEquals(currentUserId,acc.SOM_TVKundenverkaeufer__c);
    	}
    	
    	//*********************************
    	Test.stopTest();
        
    }
    
    /***********************
    * Test data
    ***/
    private static void createTestData(){
    	
    	insertUser = createTestUser(999, null, null, '71M', true);
    	
    	system.runAs(insertUser){
    		//Account
    		list<Account> lstAcc = new list<Account>();
    		for(Integer i=0; i<cnt; i++){
	    		lstAcc.add(cls_P7S1_TestData.createTestAccount(false));
    		}
    		insert lstAcc;
	    	
	    	//AccountTeamMember, AccountAccess, OpportunityApproval
	    	list<AccountTeamMember> lstAtm = new list<AccountTeamMember>();
	    	list<P7S1_AccountAccess__c> lstAccAccess = new list<P7S1_AccountAccess__c>();
	    	list<Opportunity> lstOpp = new list<Opportunity>();
	    	for(Integer i=0; i<cnt; i++){
	    		lstAtm.add(new AccountTeamMember(AccountId = lstAcc[i].Id, TeamMemberRole = 'TV_Kundenverkäufer', UserId = currentUserId));
                lstAccAccess.add(new P7S1_AccountAccess__c(P7S1_Account__c = lstAcc[i].Id,OwnerId = currentUserId));
                lstOpp.add(cls_P7S1_TestData.createTestOpportunity(false, lstAcc[i]));
	    	}
	    	insert lstAtm;
	    	insert lstAccAccess;
	    	insert lstOpp;
	    	
	    	list<P7S1_OpportunityApproval__c> lstOppApproval = new list<P7S1_OpportunityApproval__c>();
	    	for(Integer i=0; i<cnt; i++){
	    		lstOppApproval.add(new P7S1_OpportunityApproval__c(P7S1_Opportunity__c = lstOpp[i].Id, P7S1_AccountOwner__c = insertUser.Id));
	    	}
	    	insert lstOppApproval;
    	}
    
    }
    
    //User
    public static User createTestUser(Integer i, Id idProfile, String idRole, String unit, Boolean insertObject){
        User obj = new User();
        if(idProfile == NULL) idProfile = [Select Id from Profile where Name = 'System Administrator' or Name='Systemadministrator' limit 1].id;
        obj.ProfileId = idProfile;
        obj.FirstName = 'First' + i;
        obj.LastName = 'Last' + i;
        obj.Username = 'test@email' + i + '.de';
        obj.Email = 'test@email' + i + '.de';
        obj.Alias = 'fila' + i;
        obj.CommunityNickname = 'test@email' + i + '.de';
        obj.TimeZoneSidKey = 'America/Los_Angeles';
        obj.LocaleSidKey = 'en_US';
        obj.EmailEncodingKey = 'ISO-8859-1';
        obj.LanguageLocaleKey = 'en_US';
        obj.IsActive = true;
        obj.UserRoleId = idRole;
        obj.P7S1_Unit__c = unit;
        
        if(insertObject)           insert obj;
        return obj;
    }
    
}