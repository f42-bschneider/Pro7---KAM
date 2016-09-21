trigger Adv_Placement on ADvendio__Placement__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        Adv_AdSpec_InheritFromPlacement.runFromPlacementTrigger(Trigger.newMap, Trigger.oldMap);
        Adv_AdPrice_AssignKeys.runFromPlacementTrigger(Trigger.newMap, Trigger.oldMap);
    }

}