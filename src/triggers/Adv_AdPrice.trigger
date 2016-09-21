trigger Adv_AdPrice on ADvendio__Ad_price__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isInsert || Trigger.isUpdate) {
        if (Trigger.isAfter) {
            Adv_AdPrice_AssignKeys.runFromAdPriceTrigger(Trigger.newMap, Trigger.oldMap);
        } else if (Trigger.isBefore) {
            Adv_AdPrice_Metabuchungslogik.checkAdPriceConfiguration(Trigger.new);
        }
    }

}