trigger Adv_KeyValue on ADvendio__KeyValue__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter && Trigger.isInsert) {
        SomDig_SalesPriceProxy_KeyValue.handleInsertOrUpdate(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        SomDig_SalesPriceProxy_KeyValue.handleInsertOrUpdate(Trigger.old);
    }

}