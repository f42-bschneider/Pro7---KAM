trigger SomDig_DeliverPrio on SomDig_DeliverPrio__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    SomDig_DeliverPrio_Check dc = new SomDig_DeliverPrio_Check(trigger.isAfter, trigger.isBefore, trigger.isDelete, trigger.isInsert, trigger.isUnDelete, trigger.isUpdate,
                                            trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
    
    /* Run the controller. */
    dc.run();
}