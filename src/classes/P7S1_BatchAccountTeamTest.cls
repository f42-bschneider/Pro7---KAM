/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_BatchAccountTeamTest
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.1
* @ date        2016/01/28  
* @description  
* @last change  
* @objects      
* =================================================================
*/ 
@isTest
private class P7S1_BatchAccountTeamTest{
	private static Date dateToday = date.today();
    private static Integer maxNumber = 10;  
	private static list<Account> lstAccount = new list<Account>();
	
	/*********************
	EXECUTE BATCH
	*/
    static testMethod void test_Batch() {
        createTestData();
        //--------------- 
		Test.startTest();
    	     
		Account a = [select id,SOM_Planungsagenturverkaeufer__c,SOM_Einkaufsagenturverkaeufer__c,SOM_TVKundenverkaeufer__c from Account limit 1];
		a.SOM_Planungsagenturverkaeufer__c = userinfo.getUserID();
		a.SOM_Einkaufsagenturverkaeufer__c = userinfo.getUserID();
		a.SOM_TVKundenverkaeufer__c = userinfo.getUserID();
		update a;
        P7S1_BatchAccountTeam newBatch = new P7S1_BatchAccountTeam();
        
    	//newBatch.execute(null, lstAccount);
    	Database.executeBatch(newBatch);
    			
		Test.stopTest();
		system.assertEquals(5,[select count() from SomDig_WtAgBeziehung__c]);
		system.assertEquals(2,[select count() from AccountTeamMember]);
    }
        
    
    /*********************
	test BATCH SCHEDULE 
	*/
	static testMethod void testScheduleForBatch(){
		Test.startTest();
		
		Date dtToday = Date.today();
		DateTime dtNextRun = DateTime.newInstance(dtToday.year(), dtToday.month(), dtToday.day(), 1, 0, 0);
		dtNextRun = dtNextRun.addDays(1);
		
		String ss = String.valueOf(dtNextRun.second());
		String mm = String.valueOf(dtNextRun.minute());
		String hh = String.valueOf(dtNextRun.hour());
		String d = String.valueOf(dtNextRun.day());
		String m = String.valueOf(dtNextRun.month());
		String y = String.valueOf(dtNextRun.year());
		
		String jobName = 'TEST Batch: ' + dtNextRun.formatLong();
		String ScheduleParam = '00' + ' ' + mm + ' ' + hh + ' ' + d + ' ' + m + ' ? ' + y;
		
		//Start Scheduled Job
		String jobId = System.schedule(jobName, ScheduleParam, new P7S1_BatchAccountTeam());
		
		//Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		
		// Verify the expressions are the same
		System.assertEquals(ScheduleParam, ct.CronExpression);
		
		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
		
		Test.stopTest();
	}
	
	
    /*********************
    test HELPER EXECUTE
    */
    static testMethod void testBatchMethod_Execute() {    	  	    	
    	createTestData();
    	//-------------------------
		Test.startTest(); 
        		
		P7S1_BatchAccountTeamHelper batchHelper = new P7S1_BatchAccountTeamHelper();
				
		//EXECUTE
		batchHelper.Batch_Execute(lstAccount);
		
		Test.stopTest();
	}
	    
	
	/*********************
	test HELPER FINISH 
	*/
    static testMethod void testBatchMethod_Finish() {      	
		Test.startTest();
        		
		//FINISH
		P7S1_BatchAccountTeamHelper batchHelper = new P7S1_BatchAccountTeamHelper();		
		batchHelper.Batch_Finish();	
		
		Test.stopTest();
	} 
    
	
    /*---------------------------------
    Create Test Data
    ---------------------------------*/
    private static void createTestData(){
    	  P7S1_TestdatageneratorAtmWtAg.generateTestData();
    }
}