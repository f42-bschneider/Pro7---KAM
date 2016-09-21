trigger Adv_OptimizingChange on ADvendio__OptimizingChange__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore && Trigger.isInsert) {
        Adv_OptimizingChange_Storno.setVKToNullForNewPositions(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

        Adv_OptimizingChange_ReduceAmount.checkAmountReduced(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }


    if (Trigger.isAfter && Trigger.isInsert) {
        Adv_OptimizingChange_Storno.setVKToNull(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

        Adv_OptimizingChange_Storno.deleteOCs(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

        Adv_OptimizingChange_LineDesc.setLineDescription(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

        Adv_OptimizingChange_FC.setFC(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

        Adv_OptimizingChange_FC.deleteOCs(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

        Adv_OptimizingChange_Cancel.cancelPosition(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

        Adv_OptimizingChange_MB3.negateMB3(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

        Adv_OptimizingChange_MB3.deleteOCs(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }


    new Adv_OptimizingChange_DynamicQuantity(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

}