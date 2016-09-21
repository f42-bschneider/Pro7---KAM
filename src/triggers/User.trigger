trigger User on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    new cls_P7S1_GroupMember_SphereProfile(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

}