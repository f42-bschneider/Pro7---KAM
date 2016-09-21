trigger Adv_OptimizingVersion on ADvendio__OptimizingVersion__c (after update, after insert) {

        
    if(Trigger.isAfter && Trigger.isUpdate)
        Adv_OptimizingVersion_Activate.activated(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate,
                                               Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

}