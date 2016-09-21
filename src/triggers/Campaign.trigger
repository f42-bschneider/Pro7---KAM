trigger Campaign on Campaign (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    new cls_SomTv_Campaign(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    if (Trigger.isAfter && Trigger.isUpdate)
	    SomTv_CampaignShare_SetReadOnly.updateSharingRecords(Trigger.new, Trigger.oldMap);
}