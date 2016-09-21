@isTest
public class SomTv_Opportunity_UpdateFromAngebot_Test{

    public static testMethod void testSomTvOpportunityUpdateFromAngebot() {
        Test.startTest();
        
        RecordType rt = null;
        for (RecordType r : [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'SomTv_Paket' LIMIT 1]) {
            rt = r;
            break;
        }
        System.assert(rt!=null, 'No RecordType \'SomTv_Paket\' for Opportunity found!');
        
        Account acc = new Account(Name='Test Account', ProRex_Rolle__c='Kunde', SomTv_HilfsfeldProRexRolle__c='Kunde');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity', AccountId=acc.Id, RecordTypeId=rt.Id, StageName='Potential', CloseDate=System.today());
        insert opp;
        
        SomTv_Angebot__c angebot1 = new SomTv_Angebot__c(SomTv_Opportunity__c=opp.Id, SomTv_Status__c='Angeboten', SomTv_IPEinschaetzungMN3inEUR__c=1000, SomTv_RealisticCaseAngebot__c=true, SomTv_Stufe__c='1', SomTv_MB1__c=1000);
        insert angebot1;
        
        opp = [SELECT Id, StageName, Amount, SomTv_MN3__c FROM Opportunity WHERE Id = :opp.Id];
        //System.assert(opp.Amount == angebot1.SomTv_MB1__c);
        System.assert(opp.StageName == 'Angebot abgegeben');
        
        // Test validation: Feld SomTv_RealisticCaseAngebot__c darf MAXIMAL nur bei einem Datensatz = true sein.
        SomTv_Angebot__c angebot2 = new SomTv_Angebot__c(SomTv_Opportunity__c=opp.Id, SomTv_Status__c='Angeboten', SomTv_IPEinschaetzungMN3inEUR__c=1000, SomTv_RealisticCaseAngebot__c=true, SomTv_Stufe__c='1', SomTv_MB1__c=1000);
        try {
            insert angebot2;
            // Attention: API version 26.0 or above doesn't throw exception anymore in case of Object.(Field.)addError().
            System.assert(false, 'An Exception should be thrown!');
        } catch (DMLException e) {
            System.debug('\n\nException caught. OK!\n');
        }

        // Test validation: Feld SomTv_Stufe__c (Picklist) muss eindeutig sein.
        angebot2 = new SomTv_Angebot__c(SomTv_Opportunity__c=opp.Id, SomTv_Status__c='Angeboten', SomTv_IPEinschaetzungMN3inEUR__c=1000, SomTv_RealisticCaseAngebot__c=false, SomTv_Stufe__c='1', SomTv_MB1__c=1000);
        try {
            insert angebot2;
            // Attention: API version 26.0 or above doesn't throw exception anymore in case of Object.(Field.)addError().
            System.assert(false, 'An Exception should be thrown!');
        } catch (DMLException e) {
            System.debug('\n\nException caught. OK!\n');
        }

        angebot2 = new SomTv_Angebot__c(SomTv_Opportunity__c=opp.Id, SomTv_Status__c='Angeboten', SomTv_IPEinschaetzungMN3inEUR__c=1000, SomTv_RealisticCaseAngebot__c=false, SomTv_Stufe__c='2', SomTv_MB1__c=1000);
        insert angebot2;

        delete angebot1;
        
        angebot2.SomTv_RealisticCaseAngebot__c = true;
        angebot2.SomTv_MB1__c = 2000;
        angebot2.SomTv_Status__c = 'Angenommen';
        update angebot2;
        
        opp = [SELECT Id, StageName, Amount, SomTv_MN3__c FROM Opportunity WHERE Id = :opp.Id];
        //System.assert(opp.Amount == angebot2.SomTv_MB1__c);
        System.assert(opp.StageName == 'Geschlossene und gewonnene');
        
        try {
            undelete angebot1;
            // Attention: API version 26.0 or above doesn't throw exception anymore in case of Object.(Field.)addError().
            System.assert(false, 'An Exception should be thrown!');
        } catch (DMLException e) {
            System.debug('\n\nException caught. OK!\n');
        }

        delete angebot2;

        undelete angebot1;

        opp = [SELECT Id, StageName, Amount, SomTv_MN3__c FROM Opportunity WHERE Id = :opp.Id];
        //System.assert(opp.Amount == angebot1.SomTv_MB1__c);
        System.assert(opp.StageName == 'Angebot abgegeben');
        
        Test.stopTest();
    }
    
}