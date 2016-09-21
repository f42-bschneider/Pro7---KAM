/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_BatchAccountTeamMember
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.1
* @ date        2016/02/16 
* @description  
* @last change  
* @objects      
* =================================================================
*/
global class P7S1_BatchAccountTeamMember implements Database.Stateful, Database.Batchable<SObject>, Schedulable{
 	public P7S1_BatchAccountTeamMemberHelper batchHelper;
	public String soql;
	
 	/* Constructor */
	/*********************/
	public P7S1_BatchAccountTeamMember(){		
		batchHelper = new P7S1_BatchAccountTeamMemberHelper();							
 	} 
 	
 	
 	/* execute SchedulableContext */
	/******************************/
 	global void execute(SchedulableContext SC) {	
		P7S1_BatchAccountTeamMember b = new P7S1_BatchAccountTeamMember();
		Database.executeBatch(b);				
	}
	
 	
 	/* start */
	/*********************/
    global Database.QueryLocator start(Database.BatchableContext bc){   
    	String soql = batchHelper.buildSearchString();	  	  	
       	return Database.getQueryLocator(soql);
    }
	 
	 
	/* execute */
	/*********************/
    global void execute(Database.BatchableContext bc, List<sObject> lstObjects){
		batchHelper.Batch_Execute(lstObjects);
    }
	
	/* finish */
	/*********************/ 
	global void finish(Database.BatchableContext bc){
		batchHelper.Batch_Finish();
	}}