trigger SomTv_AccountHistory on AccountHistory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    new SomTv_AccountHistory_ValidateData(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

}