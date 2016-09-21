trigger Lcm_TestTask on Lcm_TestTask__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    cls_Lcm_TestTask l_oTask = new cls_Lcm_TestTask();

    l_oTask.RunTrigger(
        Trigger.isBefore, Trigger.isAfter,
        Trigger.isInsert, Trigger.isUpdate,
        Trigger.isDelete, Trigger.isUnDelete,
        Trigger.new, Trigger.newMap,
        Trigger.old, Trigger.oldMap
    );

}