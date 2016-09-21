trigger OpportunityLineItem on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        SomTv_OLI_Geschaeftsart.filterAndUpdate(Trigger.new);
    }

    new OpportunityLineItemTrigger(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

}