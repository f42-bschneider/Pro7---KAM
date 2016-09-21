trigger Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Ven_Account_Type.setAccountTypeBoxes(Trigger.new, null, null, false);
        } else if (Trigger.isUpdate) {
            Ven_Account_Type.setAccountTypeBoxes(Trigger.new, Trigger.newMap.keySet(), Trigger.oldMap, true);
        } else if (Trigger.isDelete) {
            Ven_Account_Type.setAccountTypeBoxToTarget(Trigger.old, Trigger.oldMap.keySet());
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        SomTv_OLI_Geschaeftsart.updateOpportunityLineItems(Trigger.newMap, Trigger.oldMap);
    }

    new SomTv_Opportunity_ValidateData(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    new cls_P7S1_Opportunity_NewOwner(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();



    new P7S1_Opportunity_Sphere(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    //Added new class to add OpportunityTeamMembers
    new P7S1_OpportunityTeamMember_Handler(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();


    new Ven_Opportunity_PipelineHandler(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();


 // KV03378
    P7S1_Rollup.startRollup('Opportunity', trigger.old, trigger.new,  trigger.oldMap, trigger.newmap,  trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isAfter);




/*
    // KV-02693
    if (Trigger.isAfter && Trigger.isUpdate)
    P7S1_OpportunityLineItem_UpdateBR.Opportunity_Changed(Trigger.new, Trigger.oldMap);

    // We need to store the specific OpportunityIDs in a static set in order to
    // make a soql with this IDs after the records are deleted
    if (Trigger.isBefore && Trigger.isDelete)
        P7S1_OpportunityLineItem_UpdateBR.storeSetDeletedOpportunityIDs(Trigger.oldMap);

    if (Trigger.isAfter && Trigger.isDelete)
       P7S1_OpportunityLineItem_UpdateBR.UpdateOLIsFromChildOpportunityIDs();

    if (Trigger.isAfter && Trigger.isUndelete)
       P7S1_OpportunityLineItem_UpdateBR.MotherOPP_undelete(Trigger.newMap);
*/
}