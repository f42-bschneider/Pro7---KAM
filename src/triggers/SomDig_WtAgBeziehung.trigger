trigger SomDig_WtAgBeziehung on SomDig_WtAgBeziehung__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    P7S1_Rollup.startRollup('SomDig_WtAgBeziehung__c', trigger.old, trigger.new,  trigger.oldMap, trigger.newmap,  trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isAfter);

    /*
    Added new Method for Digital Sales Owner on Account
    factory42 - VVR - 20.01.2016
    */
    new P7S1_WtAgBeziehung_DigitalOwner(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run(); 
}