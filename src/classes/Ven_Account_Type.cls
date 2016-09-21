public with sharing class Ven_Account_Type {

    /* Methods for Opportunity trigger */

    public static void setAccountTypeBoxes(List<Opportunity> opps, Set<Id> oppIds, Map<Id, Opportunity> mapOldItems, Boolean isUpdate) {
        Set<Id> accountIdsCustomer = new Set<Id>();
        Set<Id> accountIdsTarget = new Set<Id>();

        Set<Id> venRecordTypeIds = getVenRecordTypeIds();

        for (Opportunity opp : opps) {
            if (venRecordTypeIds.contains(opp.RecordTypeId)) {
                if (isUpdate) {
                    if (mapOldItems.get(opp.Id).AccountId != opp.AccountId) {
                        if (mapOldItems.get(opp.Id).AccountId == null && opp.AccountId != null) {
                            if (opp.Probability >= 100) {
                                accountIdsCustomer.add(opp.AccountId);
                            }
                        } else if (mapOldItems.get(opp.Id).AccountId != null && opp.AccountId == null) {
                            accountIdsTarget.add(mapOldItems.get(opp.Id).AccountId);
                        } else {
                            if (opp.Probability >= 100) {
                                accountIdsCustomer.add(opp.AccountId);
                            }

                            accountIdsTarget.add(mapOldItems.get(opp.Id).AccountId);
                        }
                    } else if (opp.AccountId != null && mapOldItems.get(opp.Id).Probability != opp.Probability) {
                        if (mapOldItems.get(opp.Id).Probability < 100 && opp.Probability >= 100) {
                            accountIdsCustomer.add(opp.AccountId);
                        } else if (mapOldItems.get(opp.Id).Probability >= 100 && opp.Probability < 100) {
                            accountIdsTarget.add(opp.AccountId);
                        }
                    } else if (opp.AccountId != null && opp.Probability >= 100 && !venRecordTypeIds.contains(mapOldItems.get(opp.Id).RecordTypeId)) {
                        accountIdsCustomer.add(opp.AccountId);
                    }
                } else if (opp.AccountId != null && opp.Probability >= 100) {
                    accountIdsCustomer.add(opp.AccountId);
                }
            } else {
                if (isUpdate) {
                    if (opp.AccountId != null && opp.Probability >= 100 && venRecordTypeIds.contains(mapOldItems.get(opp.Id).RecordTypeId)) {
                        accountIdsTarget.add(opp.AccountId);
                    }
                }
            }
        }

        Set<Id> accountIds = new Set<Id>();

        if (!accountIdsCustomer.isEmpty()) {
            accountIds.addAll(accountIdsCustomer);
        }

        if (!accountIdsTarget.isEmpty()) {
            Set<Id> accountIdsTargetV2 = new Set<Id>();

            for (Id accountIdTarget : accountIdsTarget) {
                if (!accountIdsCustomer.contains(accountIdTarget)) {
                    accountIdsTargetV2.add(accountIdTarget);
                }
            }

            accountIdsTarget = checkOtherOpps(oppIds, accountIdsTargetV2);

            if (!accountIdsTarget.isEmpty()) {
                accountIds.addAll(accountIdsTarget);
            }
        }

        List<Account> accountsToUpdate = getAccountsToUpdate(accountIds, accountIdsCustomer, accountIdsTarget);

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    public static void setAccountTypeBoxToTarget(List<Opportunity> opps, Set<Id> oppIds) {
        Set<Id> accountIdsTarget = new Set<Id>();

        Set<Id> venRecordTypeIds = getVenRecordTypeIds();

        for (Opportunity opp : opps) {
            if (venRecordTypeIds.contains(opp.RecordTypeId) && opp.AccountId != null && opp.Probability >= 100) {
                accountIdsTarget.add(opp.AccountId);
            }
        }

        if (!accountIdsTarget.isEmpty()) {
            accountIdsTarget = checkOtherOpps(oppIds, accountIdsTarget);
        }

        List<Account> accountsToUpdate = getAccountsToUpdate(accountIdsTarget);

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    private static Set<Id> getVenRecordTypeIds() {
        Set<Id> venRecordTypeIds = new Set<Id>();

        for (RecordType venRecordType : [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName LIKE 'Ven_%']) {
            venRecordTypeIds.add(venRecordType.Id);
        }

        return venRecordTypeIds;
    }

    private static Set<Id> checkOtherOpps(Set<Id> oppIds, Set<Id> accountIdsTarget) {
        Set<Id> accountIdsToRemove = new Set<Id>();

        for (Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id NOT IN :oppIds AND AccountId IN :accountIdsTarget AND Probability >= 100]) {
            accountIdsToRemove.add(opp.AccountId);
        }

        if (!accountIdsToRemove.isEmpty()) {
            for (Id accountIdToRemove : accountIdsToRemove) {
                accountIdsTarget.remove(accountIdToRemove);
            }
        }

        return accountIdsTarget;
    }

    private static List<Account> getAccountsToUpdate(Set<Id> accountIds, Set<Id> accountIdsCustomer, Set<Id> accountIdsTarget) {
        List<Account> accountsToUpdate = new List<Account>();

        if (!accountIds.isEmpty()) {
            for (Account account : [SELECT Id, Ven_Target__c, Ven_Customer__c FROM Account WHERE Id IN :accountIds]) {
                if (accountIdsCustomer.contains(account.Id) && account.Ven_Customer__c != true) {
                    account.Ven_Target__c = false;
                    account.Ven_Customer__c = true;
                    accountsToUpdate.add(account);
                } else if (accountIdsTarget.contains(account.Id)) {
                    account.Ven_Target__c = true;
                    account.Ven_Customer__c = false;
                    accountsToUpdate.add(account);
                }
            }
        }

        return accountsToUpdate;
    }

    private static List<Account> getAccountsToUpdate(Set<Id> accountIdsTarget) {
        List<Account> accountsToUpdate = new List<Account>();

        if (!accountIdsTarget.isEmpty()) {
            for (Account account : [SELECT Id, Ven_Target__c, Ven_Customer__c FROM Account WHERE Id IN :accountIdsTarget]) {
                account.Ven_Target__c = true;
                account.Ven_Customer__c = false;
                accountsToUpdate.add(account);
            }
        }

        return accountsToUpdate;
    }



    /* Methods for Ven_Share trigger */

    public static void setAccountTypeBoxInvestorTrue(List<Ven_Share__c> venCapTables) {
        Set<Id> accountIdsInvestorTrue = new Set<Id>();

        for (Ven_Share__c venCapTable : venCapTables) {
            if (venCapTable.Ven_Shareholder__c != null) {
                accountIdsInvestorTrue.add(venCapTable.Ven_Shareholder__c);
            }
        }

        List<Account> accountsToUpdate = getAccountsToUpdateTrue(accountIdsInvestorTrue);

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    public static void setAccountTypeBoxInvestorFalse(List<Ven_Share__c> venCapTables) {
        Set<Id> accountIdsInvestorFalse = new Set<Id>();

        for (Ven_Share__c venCapTable : venCapTables) {
            if (venCapTable.Ven_Shareholder__c != null) {
                accountIdsInvestorFalse.add(venCapTable.Ven_Shareholder__c);
            }
        }

        List<Account> accountsToUpdate = getAccountsToUpdateFalse(accountIdsInvestorFalse);

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    private static List<Account> getAccountsToUpdateTrue(Set<Id> accountIdsInvestorTrue) {
        List<Account> accountsToUpdate = new List<Account>();

        if (!accountIdsInvestorTrue.isEmpty()) {
            for (Account account : [SELECT Id, Ven_Investor__c FROM Account WHERE Id IN :accountIdsInvestorTrue AND Ven_Investor__c = false]) {
                account.Ven_Investor__c = true;
                accountsToUpdate.add(account);
            }
        }

        return accountsToUpdate;
    }

    private static List<Account> getAccountsToUpdateFalse(Set<Id> accountIdsInvestorFalse) {
        List<Account> accountsToUpdate = new List<Account>();

        if (!accountIdsInvestorFalse.isEmpty()) {
            for (Account account : [SELECT Id, Ven_Investor__c, (SELECT Id FROM Shareholder__r LIMIT 1) FROM Account WHERE Id IN :accountIdsInvestorFalse]) {
                if (account.Shareholder__r.isEmpty()) {
                    account.Ven_Investor__c = false;
                    accountsToUpdate.add(account);
                }
            }
        }

        return accountsToUpdate;
    }

}