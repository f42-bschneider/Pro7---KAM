trigger Adv_DeliveryData on ADvendio__DeliveryData__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Adv_DeliveryData(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();
}