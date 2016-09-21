/**
* @Author : Chea
* @Date : 19/05/2014
*
* Helper class for query and cloning sobject
*
*/
public with sharing class cls_P7S1_CloneUtils {

    /**
    * Dynamic query based on objectname and filter
    *
    * @param sObjectName    sobject name
    * @param filter         condition in where clause, filter must be in form of Id='123'
                            <code>null</code> where condition will not append
    * @return List<sObject>
    */
    public static List<sObject> selectSObject(String sObjectName, String filter) {
        try {
            
            String query = getSelectedField(sObjectName, false);

            //Remove the last , unnecessary comma
            query = query.substring(0,query.length()-1);

            //Append the FROM and WHERE clause
            query += ' from ' + sObjectName;
            
            // where condition
            if (filter!=null) {
                query += ' Where ' + filter;
            }
            
            //Execute SOQL
            //System.debug('>>> Utils.selectSObject' + query);
            return Database.query(query);
            
        }
        catch(Exception e) {
            return null;
        }
    }
    
    /**
    * Dynamic query based on objectname and filter
    *
    * @param sObjectName            sobject name
    * @param moreFields             set of additional field to select, e.g RecordType.DeveloperName...
    *                               <code>null</code> select string willl not append
    * @param filter                 condition in where clause.
    *                               if query children base set of parent-ids, filter must be in from field-refference__c IN:parentIds.
    *                               <code>null</code> where condition will not append
    * @param setParentId            set of parent id to query related children
    * @return List<sObject>
    */
    public static List<sObject> selectSObject(String sObjectName, Set<String> moreFields,String filter,Set<ID> setParentId) {
        try {
            
            //System.debug('>>>Utils.selectSObject>sObjectName: '+sObjectName+' >setParentId: '+setParentId);
            
            Set<ID> parentIds=setParentId;
            
            String query =getSelectedField(sObjectName,true);
            
            //ex: RelationName.Field...
            if(moreFields!=null){
                for(String f: moreFields){
                   if(!query.containsIgnoreCase(f))query+=(f+',');
                }
            }

            if (query != 'Select ') {
                //Remove the last , unnecessary comma
                query = query.substring(0,query.length()-1);

                //Append the FROM and WHERE clause
                query += ' from ' + sObjectName;

                // where condition
                if (filter!=null) {
                    query += ' Where ' + filter;
                }

                //Execute SOQL
                //System.debug('>>> Utils.selectSObject' + query);
                return Database.query(query);
            } else {
                return null;
            }

        }
        catch(Exception e) {
            return null;
        }
    }
    
    /**
    * Describe sObject and generate selecect statement
    *
    * @param sObjectName    sobject name
    * @param addFieldCreateable     true/false, it true append the 
    *                               <code>true</code> selecect statement appends field updatable and reference which is only createable (ex: field reference to master object)
                                    <code>false</code> selecect statement appendsappend only field updatable
    * @retrun String
    */
    private static String getSelectedField(String sObjectName, boolean addFieldCreateable){
        
        //Field is hidden can't describe
        
        // Make the describe call
        Schema.DescribeSobjectResult describeResult = Schema.describeSObjects(new String[] {sObjectName}).get(0);
        //Generate a Map of the fields
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        
        //Now loop through the list of Field Names and concatenate the SOQL query string
        String query = 'Select '; 
        for (String fieldName : fieldsMap.keySet()){
            
            Schema.DescribeFieldResult f = fieldsMap.get(fieldName).getDescribe();
            
            //Some field can create but not updatable, except field-reference to master object
            if(f.isUpdateable() || (addFieldCreateable && (f.getType()==Schema.DisplayType.REFERENCE && f.isCreateable() && !f.isUpdateable()))) {
                // should by pass all readonly field
                query += fieldName + ',';
            }
            
        }
        
        //System.debug('>>>Utils.getSelectedField>sObjectName: '+sObjectName+'>addFieldCreateable: '+addFieldCreateable+'>DONE');
        
        return query;
    }
    
    /**
    * Dynamic count record on objectname and filter
    *
    * @param sObjectName    sobject name
    * @param filter         condition in where clouase (e.g ADvendio__Media_Campaign__c='123'), 
    *                       It is require, Otherwise salesforce query exception.
    * @return integer       number of record
    */
    public static integer countSObject(String sObjectName, String filter) {
        try {
            
            //Now loop through the list of Field Names and concatenate the SOQL query string
            String query = 'Select count(id) total  from ' + sObjectName +  ' Where ' + filter;
                    
            //Execute SOQL
            ///System.debug('>>> Utils.countSObject' + query);
            
            AggregateResult[] ars =  Database.query(query);
            for(AggregateResult ar : ars) {   
                return Integer.valueOf(ar.get('total'));
            }
            
            return null;
            
        }
        catch(Exception e) {
            return null;
        }
    }
    
    
    /*
    * This method is doing deepClone a list of Sobject and initialize with initial data passed in the parameters
    *
    * @param  sobjects      list of original sObject
    * @param initialData    map of initial data (sf-field/value)for cloned sobject
    * @return List<Sobject>
    */
    public static List<Sobject> clone(List<SObject> sobjects, Map<String,Object> initialData) {
        
            
        List<SObject> cloned = sobjects.deepClone(false);
            
        if (initialData!=null) {
            for (SObject o : cloned) {
                
                // init data
                for (String key : initialData.keySet()) {
                    o.put(key,initialData.get(key));
                }
            }
        }
        return cloned;
                
    }
    

}