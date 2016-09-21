trigger SomDig_RtbDataAggr on SomDig_RtbDataAggr__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    P7S1_Rollup.startRollup('SomDig_RtbDataAggr__c', trigger.old, trigger.new,  trigger.oldMap, trigger.newmap,  trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isAfter);

}