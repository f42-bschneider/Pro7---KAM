trigger Adv_AdSpec on ADvendio__Ad_Specs__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    //KV 02551
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate )){
        Adv_AdSpec_MediagattungFields.updateFields(Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUndelete, Trigger.isUpdate,
                                               Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);   
    }
    
    
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            Adv_AdSpec_InheritFromPlacement.runFromAdSpecTrigger(Trigger.new);
            Adv_AdSpec_InheritFromAdType.runFromAdSpecTrigger(Trigger.new);
        } else if (Trigger.isAfter) {
            Adv_AdSpec_InheritFromPlacement.runFromAdSpecTrigger(Trigger.newMap);
        }
    }
     if (Trigger.isUpdate) {
          if (Trigger.isAfter) {
//                    Mig_CreatePrice5.createPricesForSpec(Trigger.new);
    }}

}