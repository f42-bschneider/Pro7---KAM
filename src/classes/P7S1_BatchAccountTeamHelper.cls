/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_BatchAccountTeamHelper
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.1
* @ date         2015/01/28 
* @description  
* @last change  
* @objects      
* =================================================================
*/
public without sharing class P7S1_BatchAccountTeamHelper {
    /* Constructor */
    /*********************/
    public P7S1_BatchAccountTeamHelper(){  
    } 
    

	/****************************
	Batch_Execute
	*/    
    public void Batch_Execute(List<sObject> lstObjects){    	
		List<SomDig_WtAgBeziehung__c> updWtAgList = new List<SomDig_WtAgBeziehung__c>(); 
        if( !(lstObjects == null || lstObjects.isEmpty())){
			for(sObject objA :lstObjects){
				Account a = (Account)objA;
				system.debug('### in Account: ' + a.id);
				for(SomDig_WtAgBeziehung__c wtag: a.WT_Beziehungen__r){
					system.debug(wtag);
					updWtAgList.add(wtag);
				}
			}            
        }
        if(!updWtAgList.isEmpty()) update updWtAgList;
    }   
    
    
    /****************************
	Batch_Finish
	*/
    public void Batch_Finish(){
       // %    
    }     
                
        
    /* BuildSearchString() */
    /********************/
    public String buildSearchString(){    
    	// WHERE part of SOQL
    	String wherePart = '';
    	        
        // build soql search string              
        return 'SELECT ' + getFieldnamesFromObject('Account') + 
        		', (Select ' + getFieldnamesFromObject('SomDig_WtAgBeziehung__c') + ' from WT_Beziehungen__r limit 1) ' + 
        		' FROM Account ' +
        		' WHERE ' + 'SomDig_UmsatzMedDiffRestAJ__c !=NULL OR SomDig_PrognoseMedDiffRestAJ__c !=NULL';
    }
    
	/********************
	* getFieldnamesFromObject()
	********************/
    String getFieldnamesFromObject(String objName){
        Map<String, Schema.SObjectField> mapFields = getFieldMapFromObject(objName);              
        String strFields = '';                
        for(Schema.Sobjectfield f : mapFields.values()){
            strFields += String.valueOf(f);
            strFields += ',';
        }                
        strFields = strFields.subString(0,strFields.Length() -1);
        return strFields;
    }
    
    /********************
	* getFieldMapFromObject()
	********************/
    Map<String, Schema.SObjectField> getFieldMapFromObject(String objName){
        return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
    }    
}