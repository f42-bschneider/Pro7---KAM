trigger SomDig_SalesPriceProxy on SomDig_SalesPriceProxy__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        Adv_CampaignItem_SalesPrice.transferDataFromProxy();
    }

}