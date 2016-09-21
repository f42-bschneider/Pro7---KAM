trigger Adv_AdType on ADvendio__Ad_Type__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        Adv_AdSpec_InheritFromAdType.runFromAdTypeTrigger(Trigger.newMap, Trigger.oldMap);
    }

}