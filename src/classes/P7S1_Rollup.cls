public class P7S1_Rollup{

    static List<P7S1_Rollup__c> cachedRollupsList {
        get {
            if (cachedRollupsList == null) {
                cachedRollupsList = [
                    SELECT ChildCalculationField__c, ChildObject__c, ParentObject__c, ParentResultField__c,
                           RelationshipField__c, Type__c, WhereCondition__c
                      FROM P7S1_Rollup__c
                     WHERE Active__c = true
                ];
            }
            return cachedRollupsList;
        }
        set;
    }

    public static void startRollup(String sObjectName, List<sObject> triggerOld, List<sObject> triggerNew,  Map<ID, sObject> oldMap,Map<ID, sObject> newMap,  Boolean bIsInsert, Boolean bIsUpdate, Boolean bIsDelete, Boolean bIsUndelete, Boolean bIsAfter){

        system.debug('** Start P7S1_Rollup for sObjectName: ' +sObjectName);

        // Get Object Metadata
        List<SObject> listTrigger = bIsDelete ? triggerOld : triggerNew;

        // Get all Fields from Child Object
        Set<String> setFieldsOfObject = getFieldsFromObject(sObjectName);

        if (!bIsAfter && bIsInsert) {
            // Get Rollup for parent objects only
            List<P7S1_Rollup__c> listParentRollups = getRollupsForParent(sObjectName);

            for (SObject o : triggerNew) {
                for (P7S1_Rollup__c objRollup: listParentRollups) {
                    o.put(objRollup.ParentResultField__c, 0);
                }
            }
        }


        if (!bIsAfter) return;


        List<P7S1_Rollup__c> listChildRollups = getRollupsForChild(sObjectName);

        // Check which rollups are nessecary to calculate
        // Map Rollup with fields, which are used in it
        Map<ID, Set<String>> mapRollupFields = mapRollupsWithFields(listChildRollups, setFieldsOfObject);


        // Check which fields changed and put them in the set
        Set<String> fieldsChanged = new Set<String>();
        if(bIsUpdate)
          for(SObject o : triggerNew)
             for(String s : setFieldsOfObject)
                if(o.get(s) != oldMap.get(o.Id).get(s))
                   fieldsChanged.add(s);

       // Do calculations
       for (P7S1_Rollup__c r : listChildRollups) {


           // If it is an update, and none of the fields used in the rollup has changed, skip this rollup
           if(System.Label.P7S1_RollupOptimize == 'true')
               if(bIsUpdate && r.Type__c == 'Sum')
                   if(!bFieldChanged(fieldsChanged, mapRollupFields.get(r.ID)))
                       continue;



          // List of parent record ids to update
          Set<Id> parentIds = new Set<Id>();
          Map<Id,sObject> parentRecords = new Map<Id,sObject>();



          // Get parents of old and new values, in case the parent has changed
          if(!bIsInsert)
              for(sObject c : triggerOld)
                parentIds.add((ID) c.get(r.RelationshipField__c));

          if(!bIsDelete)
              for(sObject c : triggerNew)
                parentIds.add((ID) c.get(r.RelationshipField__c));



          // Avoid null ID values
          parentIds.remove(null);



          // Create in-memory copy of parents
          for(Id parentId:parentIds){
            sObject objParent = Schema.getGlobalDescribe().get(r.ParentObject__c).newSObject();
            objParent.put('ID' , parentId);
            objParent.put(r.ParentResultField__c , 0);

            parentRecords.put(parentId, objParent);
          }



          // Loop through children
          for(sObject c : Database.query(createQuery(r))){

                // Get Value from Parent
                Double dValue = Double.valueOf(parentRecords.get((ID)c.get(r.RelationshipField__c)).get(r.ParentResultField__c));

                if(r.Type__c == 'Sum')
                    if(c.get(r.ChildCalculationField__c) != null)
                        dValue += Double.valueOf(c.get(r.ChildCalculationField__c));


                if(r.Type__c == 'Count')
                    dValue++;


                parentRecords.get((ID)c.get(r.RelationshipField__c)).put(r.ParentResultField__c, dValue);
          }


          Database.update(parentRecords.values());
        }
    }

    /** Get all rollups where the child object is a certain sObject */
    public static List<P7S1_Rollup__c> getRollupsForChild(String sObjectName) {
        List<P7S1_Rollup__c> rollupsList = new List<P7S1_Rollup__c>();
        for (P7S1_Rollup__c rollup : cachedRollupsList) {
            if (rollup.ChildObject__c == sObjectName) rollupsList.add(rollup);
        }
        return rollupsList;
    }

    /** Get all rollups where the parent object is a certain sObject */
    public static List<P7S1_Rollup__c> getRollupsForParent(String sObjectName) {
        List<P7S1_Rollup__c> rollupsList = new List<P7S1_Rollup__c>();
        for (P7S1_Rollup__c rollup : cachedRollupsList) {
            if (rollup.ParentObject__c == sObjectName) rollupsList.add(rollup);
        }
        return rollupsList;
    }

    // Create Query
    public static String createQuery(P7S1_Rollup__c objRollup){
          String sQuery = 'SELECT ID, ';

          if(objRollup.ChildCalculationField__c != null)
              sQuery += objRollup.ChildCalculationField__c + ', ';

           sQuery += objRollup.RelationshipField__c + ' FROM ' + objRollup.ChildObject__c + ' WHERE ' + objRollup.RelationshipField__c + ' IN :parentIds';

          if(objRollup.WhereCondition__c != null)
              sQuery += ' AND (' + objRollup.WhereCondition__c + ')';

          return sQuery;
    }



    // Get all Fields from the Object
    public static Set<String> getFieldsFromObject(String objectName){

        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Set<String> selectFields = new Set<String>();

        for(Schema.SObjectField f : fMap.values())
            selectFields.add(f.getDescribe().getName());


        return selectFields;
    }



    // Map RollupID with fields which are used in it
    public static Map<ID, Set<String>> mapRollupsWithFields(List<P7S1_Rollup__c> listAllRollups, Set<String> setFieldsOfObject){

        Map<ID, Set<String>> mapRollupFields = new Map<ID, Set<String>>();

        for(P7S1_Rollup__c r : listAllRollups){

            mapRollupFields.put(r.ID, new Set<String>{r.RelationshipField__c});

            if(r.ChildCalculationField__c != null)
                mapRollupFields.get(r.ID).add(r.ChildCalculationField__c);


            // Run through all fields of object and get fields from the where condition
            if(r.WhereCondition__c == null)
                continue;


            for(String s : setFieldsOfObject)
                if(r.WhereCondition__c.contains(s))
                    mapRollupFields.get(r.ID).add(s);

        }

        return mapRollupFields;
    }


    public static Boolean bFieldChanged(Set<String> setChangedFields, Set<String> setUsedFieldsFromRollup){
         Boolean bFieldChanged = false;

         for(String s : setUsedFieldsFromRollup)
             if(setChangedFields.contains(s)){
                 bFieldChanged = true;
                 break;
             }


         return bFieldChanged;
    }



    //** Method for recalculation
    public PageReference recalculate(){

        Id rollupID = Apexpages.currentpage().getparameters().get('id');


        P7S1_Rollup__c objRollup = [SELECT ID FROM P7S1_Rollup__c WHERE ID = :rollupID];
        objRollup.P7S1_BatchResult__c = 'Scheduled...';
        update objRollup;


        Id batchInstanceId = Database.executeBatch(new P7S1_RollupBatch(rollupID), 200);

        PageReference p1 = new PageReference('/' + rollupID);
        p1.setRedirect(true);
        return p1;
    }
}