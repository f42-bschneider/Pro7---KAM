trigger SomTv_Angebot on SomTv_Angebot__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    new SomTv_Opportunity_UpdateFromAngebot(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

}