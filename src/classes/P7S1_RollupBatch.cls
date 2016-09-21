global class P7S1_RollupBatch implements Database.Batchable<sObject>, Database.Stateful{

   global P7S1_Rollup__c r;
   global Integer iUpdates;
   global Integer iTotal;   
   
   
   global P7S1_RollupBatch(ID rID){      
      r = [SELECT Type__c, P7S1_BatchFilter__c, P7S1_BatchResult__c, WhereCondition__c, ChildCalculationField__c, RelationshipField__c, ParentResultField__c, ParentObject__c, ChildObject__c FROM P7S1_Rollup__c WHERE ID = :rID];
   }



   global Database.QueryLocator start(Database.BatchableContext BC){
       
      // Init values for results
      iUpdates = 0;
      iTotal = 0;   
   
      // Get all Objects from the Parent
      String sQuery = 'SELECT ID, ' + r.ParentResultField__c +  ' FROM ' + r.ParentObject__c;
      
      // Add Filter
      if(r.P7S1_BatchFilter__c != null)
          sQuery += ' WHERE ' + r.P7S1_BatchFilter__c;
          
          
      // Set status to Processing
      r.P7S1_BatchResult__c = 'Processing...';
      update r;                  
      
      
      return Database.getQueryLocator(sQuery);
   }



   global void execute(Database.BatchableContext BC, List<sObject> scope){
       
       // Map ID with old value to check in the end if it changed
       Map<ID, Double> mapOldValues = new Map<ID, Double>();
       
       // Copy of objects
       Map<Id,sObject> parentRecords = new Map<Id,sObject>();
       
       // Set of Parent IDs
       Set<Id> parentIds = new Set<Id>();
       
       for(sObject o : scope){
           parentIds.add(o.Id);
           mapOldValues.put(o.ID, (Double)o.get(r.ParentResultField__c));
           
           
          // Create in-memory copy of parents 
          sObject objParent = Schema.getGlobalDescribe().get(r.ParentObject__c).newSObject();
          objParent.put('ID' , o.Id);            
          objParent.put(r.ParentResultField__c , 0);
        
          parentRecords.put(o.Id, objParent);           
       }    
            
       

      // Loop through children
      for(sObject c : Database.query(P7S1_Rollup.createQuery(r))){
            
            // Get Value from Parent
            Double dValue = Double.valueOf(parentRecords.get((ID)c.get(r.RelationshipField__c)).get(r.ParentResultField__c));

            if(r.Type__c == 'Sum')
                if(c.get(r.ChildCalculationField__c) != null)
                    dValue += Double.valueOf(c.get(r.ChildCalculationField__c));
            
            
            if(r.Type__c == 'Count')
                dValue++;
            
            parentRecords.get((ID)c.get(r.RelationshipField__c)).put(r.ParentResultField__c, dValue);
      }
      
      
      List<sObject> listUpdateRecords = new List<sObject>();
      
      // Only update if values changed!      
      for(sObject o : parentRecords.values())
          if(mapOldValues.get(o.ID) != parentRecords.get(o.ID).get(r.ParentResultField__c))
              listUpdateRecords.add(o);

      
      update listUpdateRecords;
      
      
      // Numbers for Batch result
      iUpdates += listUpdateRecords.size();
      iTotal += scope.size();
   }



   global void finish(Database.BatchableContext BC){
      
      // Write the endresult
      r.P7S1_BatchResult__c = iUpdates + ' / ' + iTotal;
      r.P7S1_BatchResult__c += ' - ' + Datetime.now().format('dd.MM.yyyy HH:mm');
      
      
      update r;
 
   } 
}