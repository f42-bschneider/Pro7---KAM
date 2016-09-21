trigger Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        Som_Contact_Address.runFromContactTrigger(Trigger.new, Trigger.oldMap);
    }


    new P7S1_Contact_Sphere(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();


}