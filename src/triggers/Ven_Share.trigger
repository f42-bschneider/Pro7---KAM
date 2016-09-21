trigger Ven_Share on Ven_Share__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Ven_Account_Type.setAccountTypeBoxInvestorTrue(Trigger.new);
        } else if (Trigger.isDelete) {
            Ven_Account_Type.setAccountTypeBoxInvestorFalse(Trigger.old);
        }
    }

}