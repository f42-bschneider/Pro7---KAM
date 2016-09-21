/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_BatchAccountTeam
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.1
* @ date        2016/01/28 
* @description  
* @last change  
* @objects      
* =================================================================
*/
global class P7S1_BatchAccountTeam implements Database.Stateful, Database.Batchable<SObject>, Schedulable{
 	public P7S1_BatchAccountTeamHelper batchHelper;
	public String soql;
	
 	/* Constructor */
	/*********************/
	public P7S1_BatchAccountTeam(){		
		batchHelper = new P7S1_BatchAccountTeamHelper();							
 	} 
 	
 	
 	/* execute SchedulableContext */
	/******************************/
 	global void execute(SchedulableContext SC) {	
		P7S1_BatchAccountTeam b = new P7S1_BatchAccountTeam();
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