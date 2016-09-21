public with sharing class P7S1_AccountAccess_SetFields {

    public static void setOwnerAndIndexOrAccount(List<P7S1_AccountAccess__c> newAccountAccessesList) {
        List<P7S1_AccountAccess__c> accountAccessesWithoutIndexList = new List<P7S1_AccountAccess__c>();
        List<P7S1_AccountAccess__c> accountAccessesWithoutAccountList = new List<P7S1_AccountAccess__c>();

        for (P7S1_AccountAccess__c accountAccess : newAccountAccessesList) {
            if (accountAccess.P7S1_AccountIndex__c == null) {
                accountAccessesWithoutIndexList.add(accountAccess);
            } else if (accountAccess.P7S1_Account__c == null) {
                accountAccessesWithoutAccountList.add(accountAccess);
            }
        }

        setOwnerAndIndex(accountAccessesWithoutIndexList);
        setOwnerAndAccout(accountAccessesWithoutAccountList);
    }


    /**
     * Set AccountOwner-Id and AccountIndex-Id for all AccountAccess record which have no associated AccountIndex
     */
    private static void setOwnerAndIndex(List<P7S1_AccountAccess__c> accountAccessesList) {
        if (!accountAccessesList.isEmpty()) {
            Set<Id> accountIdsSet = new Set<Id>();
            for (P7S1_AccountAccess__c accountAccess : accountAccessesList) {
                accountIdsSet.add(accountAccess.P7S1_Account__c);
            }

            Map<Id, P7S1_AccountIndex__c> accountIdAccountIndexMap = new Map<Id, P7S1_AccountIndex__c>();
            for (P7S1_AccountIndex__c accountIndex : [
                SELECT Id, P7S1_Account__c, P7S1_Account__r.OwnerId
                  FROM P7S1_AccountIndex__c
                 WHERE P7S1_Account__c IN :accountIdsSet
            ]) {
                accountIdAccountIndexMap.put(accountIndex.P7S1_Account__c, accountIndex);
            }

            for (P7S1_AccountAccess__c accountAccess : accountAccessesList) {
                if (accountAccess.P7S1_Account__c != null && accountIdAccountIndexMap.containsKey(accountAccess.P7S1_Account__c)) {
                    accountAccess.P7S1_AccountOwner__c = accountIdAccountIndexMap.get(accountAccess.P7S1_Account__c).P7S1_Account__r.OwnerId;
                    accountAccess.P7S1_AccountIndex__c = accountIdAccountIndexMap.get(accountAccess.P7S1_Account__c).Id;
                }
            }
        }
    }


    /**
     * Set AccountOwner-Id and Account-Id for all AccountAccess record which have no associated Account
     */
    private static void setOwnerAndAccout(List<P7S1_AccountAccess__c> accountAccessesList) {
        if (!accountAccessesList.isEmpty()) {
            Set<Id> accountIndexIdsSet = new Set<Id>();
            for (P7S1_AccountAccess__c accountAccess : accountAccessesList) {
                accountIndexIdsSet.add(accountAccess.P7S1_AccountIndex__c);
            }

            Map<Id, P7S1_AccountIndex__c> accountIndexMap = new Map<Id, P7S1_AccountIndex__c>([
                SELECT Id, P7S1_Account__c, OwnerId
                  FROM P7S1_AccountIndex__c
                 WHERE Id IN :accountIndexIdsSet
            ]);

            for (P7S1_AccountAccess__c accountAccess : accountAccessesList) {
                if (accountAccess.P7S1_AccountIndex__c != null && accountIndexMap.containsKey(accountAccess.P7S1_AccountIndex__c)) {
                    accountAccess.P7S1_AccountOwner__c = accountIndexMap.get(accountAccess.P7S1_AccountIndex__c).OwnerId;
                    accountAccess.P7S1_Account__c = accountIndexMap.get(accountAccess.P7S1_AccountIndex__c).P7S1_Account__c;
                }
            }
        }
    }

}