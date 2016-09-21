trigger Cases on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if (Trigger.isUpdate && Trigger.isBefore) {
        Lcm_CaseTeamMember_Assignment.setCaseTeamMembers(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    
    P7S1_Rollup.startRollup('Case', trigger.old, trigger.new,  trigger.oldMap, trigger.newmap,  trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isAfter);
}