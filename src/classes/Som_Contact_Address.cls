global with sharing class Som_Contact_Address implements Database.Batchable<sObject> {

    public static String SYNC_SHIPPING_OR_BILLING_ADDRESS = 'mit gültiger Besuchsadresse oder Rechnungsadresse synchronisieren';
    public static String SYNC_BILLING_ADDRESS             = 'mit Rechnungsadresse synchronisieren';

    /* Runs in Contact.beforeInsert and Contact.beforeUpdate context
     *
     * Fetch Billing or Shipping Address from Account if:
     * - Sphere is SomDe/SomAt, and
     * - the contact is inserted, or the contact is updated and either SomTv_AdressePflegen__c or Account has changed
     */
    public static void runFromContactTrigger(List<Contact> listNewContacts, Map<Id, Contact> mapOldContacts) {
        List<Contact> listContacts = new List<Contact>();
        for (Contact con : listNewContacts) {
            if (con.P7S1_Sphere__c != 'SomDe' && con.P7S1_Sphere__c != 'SomAt') continue;

            if ((con.SomTv_AdressePflegen__c == SYNC_SHIPPING_OR_BILLING_ADDRESS || con.SomTv_AdressePflegen__c == SYNC_BILLING_ADDRESS) &&
                (mapOldContacts == null ||
                 (con.SomTv_AdressePflegen__c != mapOldContacts.get(con.Id).SomTv_AdressePflegen__c) ||
                 (con.AccountId != mapOldContacts.get(con.Id).AccountId)
                )
            ) {
                listContacts.add(con);
            }
        }
        
        if (!listContacts.isEmpty()) {
            retrieveMailingAddressFromAccount(listContacts);
        }
    }

    /* Runs in Account.afterUpdate context
     *
     * Initialize a batch update of contacts if:
     * - Sphere is SomDe/SomAt, and
     * - at least one of the address fields has changed
     */
    public static void runFromAccountTrigger(List<Account> listNewAccounts, Map<Id, Account> mapOldAccounts) {
        Set<Id> setAccountIds = new Set<Id>();
        for (Account acc : listNewAccounts) {
            if (acc.P7S1_Sphere__c != 'SomDe' && acc.P7S1_Sphere__c != 'SomAt') continue;

            if (
                acc.ShippingStreet     != mapOldAccounts.get(acc.Id).ShippingStreet     ||
                acc.ShippingPostalCode != mapOldAccounts.get(acc.Id).ShippingPostalCode ||
                acc.ShippingState 	   != mapOldAccounts.get(acc.Id).ShippingState	    ||
                acc.ShippingCity       != mapOldAccounts.get(acc.Id).ShippingCity       ||
                acc.ShippingCountry    != mapOldAccounts.get(acc.Id).ShippingCountry    ||
                acc.BillingStreet      != mapOldAccounts.get(acc.Id).BillingStreet      ||
                acc.BillingPostalCode  != mapOldAccounts.get(acc.Id).BillingPostalCode  ||
                acc.BillingState	   != mapOldAccounts.get(acc.Id).BillingState	    ||
                acc.BillingCity        != mapOldAccounts.get(acc.Id).BillingCity        ||
                acc.BillingCountry     != mapOldAccounts.get(acc.Id).BillingCountry
            ) {
                setAccountIds.add(acc.Id);
            }
        }

        if (!setAccountIds.isEmpty()) {
            Som_Contact_Address batch = new Som_Contact_Address(setAccountIds);
            Database.executeBatch(batch, 50);
        }
    }

    /* From a given list of contacts, build a <Account, List<Contact>> map (if the account has sphere SomDe/SomAt)
     * Pass the map to the setMailingAddress method where the address is actually transferred from account to contact
     */
    public static void retrieveMailingAddressFromAccount(List<Contact> listContacts) {
        if (!listContacts.isEmpty()) {
            Set<Id> setAccountIds = new Set<Id>();
            for (Contact con : listContacts) {
                setAccountIds.add(con.AccountId);
            }

            Map<Id, Account> mapAccounts = new Map<Id, Account>([
                SELECT BillingStreet, BillingState, BillingPostalCode, BillingCity, BillingCountry,
                       ShippingStreet, ShippingState, ShippingPostalCode, ShippingCity, ShippingCountry,
                       P7S1_Sphere__c
                  FROM Account
                 WHERE P7S1_Sphere__c IN ('SomDe', 'SomAt')
                   AND Id IN :setAccountIds
            ]);

            Map<Account, List<Contact>> mapAccountContacts = new Map<Account, List<Contact>>();

            for (Contact con : listContacts) {
                Account acc = mapAccounts.get(con.AccountId);
                if (acc != null) {
                    if (mapAccountContacts.get(acc) == null)
                        mapAccountContacts.put(acc, new List<Contact>());
                    mapAccountContacts.get(acc).add(con);
                }
            }

            setMailingAddress(mapAccountContacts);
        }
    }

    /* For each account and its list of contacts:
     * - check if ShippingAddress (i.e. 'Besuchsadresse') is complete
     * - decide whether to fetch ShippingAddress or BillingAddress data, depending on contact.SomTv_AdressePflegen__c value and ShippingAddress completeness
     * - there's no DML statement, i.e. an 'update contacts' command has to be run after calling this method (see Batch.execute below)
     */
    public static void setMailingAddress(Map<Account, List<Contact>> mapAccountContacts) {
        for (Account acc : mapAccountContacts.keySet()) {
            Boolean besuchsadresseGepflegt = (
                acc.ShippingStreet     != null &&
                acc.ShippingPostalCode != null &&
                acc.ShippingCity       != null &&
                acc.ShippingCountry    != null);

            for (Contact con : mapAccountContacts.get(acc)) {
                if (con.SomTv_AdressePflegen__c == SYNC_BILLING_ADDRESS) {
                    con.MailingStreet     = acc.BillingStreet;
                    con.MailingPostalCode = acc.BillingPostalCode;
                    con.MailingState 	  = acc.BillingState;
                    con.MailingCity       = acc.BillingCity;
                    con.MailingCountry    = acc.BillingCountry;
                } else if (con.SomTv_AdressePflegen__c == SYNC_SHIPPING_OR_BILLING_ADDRESS) {
                    if (besuchsadresseGepflegt) {
                        con.MailingStreet     = acc.ShippingStreet;
                        con.MailingPostalCode = acc.ShippingPostalCode;
                        con.MailingState 	  = acc.ShippingState;
                        con.MailingCity       = acc.ShippingCity;
                        con.MailingCountry    = acc.ShippingCountry;
                    } else {
                        con.MailingStreet     = acc.BillingStreet;
                        con.MailingPostalCode = acc.BillingPostalCode;
                        con.MailingState 	  = acc.BillingState;
                        con.MailingCity       = acc.BillingCity;
                        con.MailingCountry    = acc.BillingCountry;
                    }
                }
            }
        }
    }



    /* Batchable Interface */

    Set<Id> setAccountIdsBatch;

    global Som_Contact_Address(Set<Id> setIds) {
        setAccountIdsBatch = setIds;
    }

    /* Start batch
     * - build a query of accounts in sphere SomDe/SomAt
     * - if passed on class initialization, filter query with a set of account Ids
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT BillingStreet,  BillingPostalCode,  BillingState, BillingCity,  BillingCountry, ' +
                       '       ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, ShippingCountry ' +
                       '  FROM Account ' +
                       ' WHERE P7S1_Sphere__c IN (\'SomDe\', \'SomAt\') ';

        if (setAccountIdsBatch != null)
            query += ' AND Id IN :setAccountIdsBatch ';

        return Database.getQueryLocator(query.normalizeSpace());
    }

    /* Execute batch
     * - build a map of <Account, List<Contact>> from the batch scope
     * - contacts are filtered for SomTv_AdressePflegen__c values
     * - pass the map to the setMailingAddress method
     * - update the contacts after the address data has been fetched
     */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<Id, Account> mapAccounts = new Map<Id, Account>((List<Account>)scope);
        Map<Account, List<Contact>> mapAccountContacts = new Map<Account, List<Contact>>();

        List<Contact> listContacts = [
            SELECT AccountId, SomTv_AdressePflegen__c
              FROM Contact
             WHERE AccountId IN :mapAccounts.keySet()
               AND SomTv_AdressePflegen__c IN (:SYNC_SHIPPING_OR_BILLING_ADDRESS, :SYNC_BILLING_ADDRESS)
        ];

        if (!listContacts.isEmpty()) {
            for (Contact con : listContacts) {
                Account acc = mapAccounts.get(con.AccountId);
                if (mapAccountContacts.get(acc) == null)
                    mapAccountContacts.put(acc, new List<Contact>());
                mapAccountContacts.get(acc).add(con);
            }

            setMailingAddress(mapAccountContacts);
            update listContacts;
        }
    }

    global void finish(Database.BatchableContext BC) {
    }

}