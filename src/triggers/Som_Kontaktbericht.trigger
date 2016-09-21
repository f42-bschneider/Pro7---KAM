trigger Som_Kontaktbericht on Som_Kontaktbericht__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Som_Kontaktbericht_Trigger.InsertTn(Trigger.newMap);
        }
        if (!Trigger.isInsert) {
            Set<Id> acc_ids = new Set<id>();
            for (Som_Kontaktbericht__c kb : (Trigger.isDelete ? Trigger.old : Trigger.new) ) {
                if (!Trigger.isUpdate || 
                    (Trigger.oldMap.get(kb.id).Som_GrundDesKontakts__c != Trigger.newMap.get(kb.id).Som_GrundDesKontakts__c) ||
                    (Trigger.oldMap.get(kb.id).Som_Datum__c  != Trigger.newMap.get(kb.id).Som_Datum__c )){
                    acc_ids.add(kb.Som_Account__c);
                }
            }
            if (!acc_ids.isEmpty()) {
                Som_Kontaktbericht_Trigger.UpdateKBdates(acc_ids, 'acc');
            }
        }
    }
}