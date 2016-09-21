trigger CampaignMember on CampaignMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    new SomTv_B2BAktionsmitgliederHistory(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    // The trigger checks if the current user has write access on the parent case record. 
	// It searchs the standard object CampaignShare and if the user has no record on CampaignShare its gives an error with the addError() method.
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        P7S1_CampaignMember_ReadOnlyBlock.CheckSharing(trigger.new);
        
}