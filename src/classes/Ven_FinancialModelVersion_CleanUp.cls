public with sharing class Ven_FinancialModelVersion_CleanUp {

    public static void deleteOldVersions(List<Ven_Financial_Model_Version__c> listFMVs) {
        Set<Id> types = new Set<Id>();
        Set<Id> opps  = new Set<Id>();
        Set<Id> ids   = new Set<Id>();
        
        for (Ven_Financial_Model_Version__c fmv : listFMVs) {
            types.add(fmv.RecordTypeId);
            opps.add(fmv.Ven_Opportunity__c);
            ids.add(fmv.Id);
        }

        List<Ven_Financial_Model_Version__c> fmvsToDelete  = new List<Ven_Financial_Model_Version__c>();
        if (!opps.isEmpty()) {
            for (Ven_Financial_Model_Version__c fmv : [
                SELECT Id
                  FROM Ven_Financial_Model_Version__c
                 WHERE Ven_Opportunity__c IN :opps
                   AND RecordTypeId IN :types
                   AND Ven_write_protection__c = false
            ]) {
                if (!ids.contains(fmv.Id)) fmvsToDelete.add(fmv);
            }

            if (!fmvsToDelete.isEmpty()) delete fmvsToDelete;
        }
    }
}