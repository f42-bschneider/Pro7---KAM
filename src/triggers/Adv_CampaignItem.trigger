trigger Adv_CampaignItem on ADvendio__Campaign_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        Adv_CampaignItem_PDFCheckboxes.setPDFCheckboxes(Trigger.new);

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        Adv_CampaignItem_FieldChanges.setLineDescription(Trigger.new, Trigger.oldMap);
        Adv_CampaignItem_FieldChanges.setAdServerStatus(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isUpdate)
        Adv_CampaignItem_ResetAvailability.setAvailability(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

    if (Trigger.isBefore && Trigger.isUpdate)
        Adv_CampaignItem_PositionStatus.setStatus(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

    if (Trigger.isAfter && Trigger.isUpdate)
        Adv_CampaignItem_DurationChanged.deleteOtherOVs(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

    if (Trigger.isBefore && Trigger.isInsert) {
        Adv_CampaignItem_Inventarklasse.setInventarklassen(Trigger.new);
    }

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        SomDig_SalesPriceProxy_CampaignItem.handleInsertOrUpdate(Trigger.new, Trigger.oldMap);
    }

    new Adv_MediaCampaign_Status(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    new Adv_MediaCampaign_Dates(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    new Adv_CampaignItem_DeliverPrio(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    new Adv_CampaignItem_DynamicQuantity(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();


    if(Trigger.isBefore && Trigger.isInsert) {
        Adv_CampaignItem_Commitment.setCampaignItemDiscounts(Trigger.new);
    }

    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
        Adv_CampaignItem_Commitment.commitmentDiscountsTracking(Trigger.oldMap, Trigger.new);
    }


    new Adv_CampaignItem_LineareVerteilung(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    if (Trigger.isInsert)
        Adv_CampaignItem_Storno.updateFields(Trigger.new, Trigger.isAfter);

    new Adv_CampaignItem_PackageSumDeliveries(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

}