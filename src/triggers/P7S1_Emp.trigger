trigger P7S1_Emp on P7S1_Emp__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        P7S1_Emp_Contact.sync(Trigger.newMap, Trigger.oldMap);
        P7S1_Emp_User.setName(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isInsert) {
        P7S1_Emp_User.syncInsert(Trigger.new);
        P7S1_Emp_User.setName(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        P7S1_Emp_User.sync(Trigger.newMap);
    }
}