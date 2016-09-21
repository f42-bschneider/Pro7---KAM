trigger Adv_MediaCampaign on ADvendio__MediaCampaign__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if(Trigger.isBefore && Trigger.isUpdate){
        Adv_MediaCampaign_FieldValidation.validate(Trigger.new, Trigger.oldMap);
    }

    new Adv_MediaCampaign_WtAgBeziehung(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    new Adv_MediaCampaign_Owner(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    new Adv_MediaCampaign_PaymentTerms(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    new Adv_MediaCampaign_Debitorennr(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    // KV 02920
    if(Trigger.isBefore && !Trigger.isDelete){
        Adv_MediaCampaign_Conception.validate(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate,Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }


    // KV 01476
    if (Trigger.isBefore && Trigger.isUpdate) {
        Adv_MediaCampaign_Dienstleistung.handlePopUpFieldsBeforeUpdate(Trigger.new, Trigger.oldMap);
    }


    // KV 02794
    if (Trigger.isBefore && Trigger.isUpdate) {
        Adv_MediaCampaign_ValidateStatus.validate(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate,
                                               Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }


    // KV 02512
    if(Trigger.isAfter && Trigger.isUpdate) {
        Adv_MediaCampaign_Storno.setToStorno(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate,
                                               Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }


    // KV 02260
    if(Trigger.isAfter && Trigger.isInsert) {
        Adv_MediaCampaign_SomEntities.createAdServerTeamAssignment(Trigger.new);
    }


    P7S1_Rollup.startRollup('ADvendio__MediaCampaign__c', trigger.old, trigger.new,  trigger.oldMap, trigger.newmap,  trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isAfter);


        if (Trigger.isAfter && Trigger.isUpdate) {
        Adv_CampaignItem_Commitment.setRabatteFreigegebenCheckOnApproved(Trigger.oldMap, Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        Adv_CampaignItem_Commitment.copyDiscountsToItems(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
        Adv_CampaignItem_Commitment.removeApprovalFromCampaign(Trigger.new, Trigger.oldMap, Trigger.isInsert);
    }

     new Adv_MediaCampaign_LineareVerteilung(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

}