trigger Ven_FinancialModelVersion on Ven_Financial_Model_Version__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter && Trigger.isInsert) {
        Ven_FinancialModelVersion_CleanUp.deleteOldVersions(Trigger.new);
    }

}