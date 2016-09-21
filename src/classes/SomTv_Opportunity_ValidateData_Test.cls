/**
 * Test class for SomTv_Opportunity_ValidateData.
 */
@IsTest
private class SomTv_Opportunity_ValidateData_Test {

  @isTest
    public static void testSomTv_Opportunity_ValidateData_Test() {
        Test.startTest();
        
        Id childRecordTypeId = null;
        Id parentRecordTypeId = null;
        
        for (RecordType r : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND (DeveloperName = 'SomTv_AdFactory' OR DeveloperName = 'SomTv_Paket')]) {
            if ('SomTv_AdFactory'.equals(r.DeveloperName)) {
                childRecordTypeId = r.Id;
            } else if ('SomTv_Paket'.equals(r.DeveloperName)) {
                parentRecordTypeId = r.Id;
            }
        }
        System.assert(childRecordTypeId!=null, 'No RecordType \'SomTv_AdFactory\' for Opportunity found!');
        System.assert(parentRecordTypeId!=null, 'No RecordType \'SomTv_Paket\' for Opportunity found!');
        
        Account acc = new Account(Name='Test Account', ProRex_Rolle__c='Kunde', SomTv_HilfsfeldProRexRolle__c='Kunde');
        insert acc;
        
        Opportunity childopp = new Opportunity(Name='Test Child Opportunity', AccountId=acc.Id, RecordTypeId=childRecordTypeId, StageName='Angebot abgegeben', CloseDate=System.today(), Amount = 1000);
        insert childopp;

        childopp = [SELECT Id, Amount FROM Opportunity WHERE Id = :childopp.Id];

        Opportunity parentopp = new Opportunity(Name='Test Parent Opportunity', AccountId=acc.Id, RecordTypeId=parentRecordTypeId, StageName='Angebot abgegeben', CloseDate=System.today(), Amount = 1000);
        insert parentopp;
        
        parentopp = [SELECT Id, SomTv_AdfactoryAnteilAbsolut__c FROM Opportunity WHERE Id = :parentopp.Id];
        System.assertEquals(null, parentopp.SomTv_AdfactoryAnteilAbsolut__c);
        
        childopp.SomTv_MutterOpportunity__c = parentopp.Id;
        update childopp;
        
        childopp = [SELECT Id, Amount FROM Opportunity WHERE Id = :childopp.Id];

        parentopp = [SELECT Id, SomTv_AdfactoryAnteilAbsolut__c FROM Opportunity WHERE Id = :parentopp.Id];
        System.assertEquals(childopp.Amount, parentopp.SomTv_AdfactoryAnteilAbsolut__c);

        delete childopp;
        
        parentopp = [SELECT Id, SomTv_AdfactoryAnteilAbsolut__c FROM Opportunity WHERE Id = :parentopp.Id];
        System.assertEquals(0.0, parentopp.SomTv_AdfactoryAnteilAbsolut__c);
        
        undelete childopp;
        
        childopp = [SELECT Id, Amount FROM Opportunity WHERE Id = :childopp.Id];

        parentopp = [SELECT Id, SomTv_AdfactoryAnteilAbsolut__c FROM Opportunity WHERE Id = :parentopp.Id];
        System.assertEquals(childopp.Amount, parentopp.SomTv_AdfactoryAnteilAbsolut__c);
        
        childopp.StageName = 'Geschlossene und gewonnene';
        update childopp;
        
        Test.stopTest();
    }
}