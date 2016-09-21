trigger SomTv_KundeAgenturBeziehung on SomTv_KundeAgenturBeziehung__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    new SomTv_KundeAgenturBez_ValidateData(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

}