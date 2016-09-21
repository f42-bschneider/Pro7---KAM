public class P7S1_Account_Visibility{

    // This Method sets the P7S1_AccountVisibility__c for Account & Contact
    public static void updateVisibility(Map <Id, Account> mapAccount, List<Account> listAccount, Boolean bIsInsert, Boolean bIsUpdate){

        Map<ID, Integer> mapChangedAccounts = new Map<ID, Integer>();
        for (Account o : listAccount) {
            if (o.SomTv_CleanUp_Delete__c)
                o.P7S1_AccountVisibility__c = 0;
            else if(o.ungueltiger_Account__c)
                o.P7S1_AccountVisibility__c = 50;
            else
                o.P7S1_AccountVisibility__c = 100;


            // Check if it changed, to update the contacts
            if (bIsUpdate)
                if (mapAccount.get(o.ID).P7S1_AccountVisibility__c != o.P7S1_AccountVisibility__c)
                    mapChangedAccounts.put(o.ID, (Integer)o.P7S1_AccountVisibility__c);
        }


        if (bIsUpdate && !mapChangedAccounts.isEmpty()){
            // Update Contacts
            List<Contact> listContacts = new List<Contact>([SELECT AccountID FROM Contact WHERE AccountID IN :mapChangedAccounts.keySet()]);
            for (Contact c : listContacts)
                c.P7S1_AccountVisibility__c = mapChangedAccounts.get(c.AccountID);


            if (!listContacts.isEmpty())
                update listContacts;
        }
    }
}