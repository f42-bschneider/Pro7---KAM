trigger Adv_KeyLine on ADvendio__KeyLine__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter && Trigger.isDelete) {
        SomDig_SalesPriceProxy_KeyValue.handleInsertOrUpdate(Trigger.old);
    }

}