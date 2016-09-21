/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_Lookup_CmpCtrl
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         2015/11/2
* @description  
* @lastchange  
* @objects      
* =================================================================
*/
public with sharing class P7S1_Lookup_CmpCtrl {
    
    private static final Integer RESULT_LIMIT = 20;
    
    /*****************
    *
    *****************/
    @AuraEnabled
    public static List<LookupObj> getLookups(String objType, String searchTerm, String labelApiName){
        String soql = 'SELECT Id, '+ labelApiName + ' FROM '+ objType +' WHERE '+ labelApiName +' LIKE \'%'+ searchTerm +'%\' ORDER BY '+ labelApiName +' LIMIT :RESULT_LIMIT ';

        List<LookupObj> lookupObjs = new List<LookupObj>();

        for(sObject obj : Database.query(soql)){
            lookupObjs.add(new LookupObj(String.valueOf(obj.get(labelApiName)), obj.Id));
        }

        return lookupObjs;
    }


    /*****************
    *
    *****************/
    public class LookupObj{
        @AuraEnabled
        public String label;

        @AuraEnabled
        public String objId;

        public LookupObj(String label, String objId){
            this.label = label;
            this.objId = objId;
        }
    }
}