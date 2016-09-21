trigger Adv_RTBAccount on ADvendio__RTBAccount__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    P7S1_Rollup.startRollup('ADvendio__RTBAccount__c', trigger.old, trigger.new,  trigger.oldMap, trigger.newmap,  trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isAfter);

}