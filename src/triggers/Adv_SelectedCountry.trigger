trigger Adv_SelectedCountry on ADvendio__Selected_Country__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter && Trigger.isInsert) {
        SomDig_SalesPriceProxy_Geo.handleInsertOrUpdate(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        SomDig_SalesPriceProxy_Geo.handleInsertOrUpdate(Trigger.old);
    }

}