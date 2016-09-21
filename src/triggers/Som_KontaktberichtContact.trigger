trigger Som_KontaktberichtContact on Som_KontaktberichtContact__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter) {
        Set<Id> kb_ids = new Set<id>();
        for (Som_KontaktberichtContact__c kbc : (Trigger.isDelete ? Trigger.old : Trigger.new) ) {
            if (!Trigger.isUpdate || Trigger.oldMap.get(kbc.id).Som_Contact__c != Trigger.newMap.get(kbc.id).Som_Contact__c) {
                kb_ids.add(kbc.Som_Kontaktbericht__c);
            }
        }

        if (!kb_ids.isEmpty()) {
            Som_Kontaktbericht_Trigger.UpdateKBdates(kb_ids, 'kb');
        }
    }

}