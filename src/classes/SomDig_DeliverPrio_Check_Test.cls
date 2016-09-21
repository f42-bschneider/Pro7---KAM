@isTest(seeAllData=false)
private class SomDig_DeliverPrio_Check_Test {

    public class Prio_DoubleChecker_Test{
        
        public SomDig_DeliverPrio__c priority;
        public SomDig_MediagattungsDifferenzierung__c mediaDiff;
        public SomDig_Auftragstyp__c auftragstyp;
        public List<SomDig_DeliverPrio__c> sameAuslieferungsprioritaeten;
        public List<SomDig_DeliverPrio__c> differentAuslieferungsprioritaeten;
        public List<SomDig_DeliverPrio__c> sameAuslieferungsprioritaetenDifferentDates;
            
        public void insertTestData() {
        
            SomDig_MediagattungsDifferenzierung__c md1 = new SomDig_MediagattungsDifferenzierung__c();
            md1.Name = 'Test MediagattungsDifferenzierung';
            insert md1;
            this.mediaDiff = md1;
            
            SomDig_Auftragstyp__c auftrag = new SomDig_Auftragstyp__c();
            auftrag.Name = 'Testauftrag';
            insert auftrag;
            this.auftragstyp = auftrag;
            
            SomDig_DeliverPrio__c p1 = new SomDig_DeliverPrio__c();
            p1.SomDig_Gueltig_ab__c = Date.today();
            p1.SomDig_Gueltig_bis__c = Date.today().addDays(1);
            p1.SomDig_Mediagattungsdifferenzierung__c = md1.Id;
            p1.SomDig_Werbeform_Kurzform__c = 'PreMid';
            p1.SomDig_Auftragstyp__c = auftrag.id;
            p1.SomDig_Abrechungsart__c = 'Festpreis';
            p1.SomDig_Rotationstyp__c = 'Umfeld';
            p1.SomDig_Belegungseinheitstyp__c = 'YouTube';
            p1.SomDig_Ad_Type__c = 'Sponsorship';
            p1.SomDig_Prio__c ='3';
            p1.SomDig_Preistyp_zur_Auslieferung__c = 'Evenly';
            this.priority = p1;
            
            SomDig_DeliverPrio__c p2 = new SomDig_DeliverPrio__c();
            p2.SomDig_Gueltig_ab__c = Date.today();
            p2.SomDig_Gueltig_bis__c = Date.today().addDays(1);
            p2.SomDig_Mediagattungsdifferenzierung__c = md1.Id;
            p2.SomDig_Werbeform_Kurzform__c = 'PreMid';
            p2.SomDig_Auftragstyp__c = auftrag.id;
            p2.SomDig_Abrechungsart__c = 'Festpreis';
            p2.SomDig_Rotationstyp__c = 'Umfeld';
            p2.SomDig_Belegungseinheitstyp__c = 'YouTube';
            p2.SomDig_Ad_Type__c = 'Sponsorship';
            p2.SomDig_Prio__c ='3';
            p2.SomDig_Preistyp_zur_Auslieferung__c = 'Evenly';

            
            sameAuslieferungsprioritaeten = new List<SomDig_DeliverPrio__c>();
            sameAuslieferungsprioritaeten.add(p1);
            sameAuslieferungsprioritaeten.add(p2);
            
            
            SomDig_DeliverPrio__c p3 = new SomDig_DeliverPrio__c();
            p3.SomDig_Gueltig_ab__c = Date.today();
            p3.SomDig_Gueltig_bis__c = Date.today().addDays(1);
            p3.SomDig_Mediagattungsdifferenzierung__c = md1.Id;
            p3.SomDig_Werbeform_Kurzform__c = 'PreMid';
            p3.SomDig_Auftragstyp__c = auftrag.id;
            p3.SomDig_Abrechungsart__c = 'Festpreis';
            p3.SomDig_Rotationstyp__c = 'Umfeld';
            p3.SomDig_Belegungseinheitstyp__c = 'YouTube';
            p3.SomDig_Ad_Type__c = 'Sponsorship';
            p3.SomDig_Prio__c ='3';
            p3.SomDig_Preistyp_zur_Auslieferung__c = 'Evenly';

            //this.priority = p1;
            
            SomDig_DeliverPrio__c p4 = new SomDig_DeliverPrio__c();
            p4.SomDig_Gueltig_ab__c = Date.today();
            p4.SomDig_Gueltig_bis__c = Date.today().addDays(1);
            p4.SomDig_Mediagattungsdifferenzierung__c = md1.Id;
            p4.SomDig_Werbeform_Kurzform__c = 'PreMid';
            p4.SomDig_Auftragstyp__c = auftrag.id;
            p4.SomDig_Abrechungsart__c = 'Festpreis';
            p4.SomDig_Rotationstyp__c = 'Umfeld';
            p4.SomDig_Belegungseinheitstyp__c = 'YouTube';
            p4.SomDig_Ad_Type__c = 'Standard'; //This value differs to p3
            p4.SomDig_Prio__c ='3';
            p4.SomDig_Preistyp_zur_Auslieferung__c = 'Evenly';
            
            differentAuslieferungsprioritaeten = new List<SomDig_DeliverPrio__c>();
            differentAuslieferungsprioritaeten.add(p3);
            differentAuslieferungsprioritaeten.add(p4);
            
            
            SomDig_DeliverPrio__c p5 = new SomDig_DeliverPrio__c();
            p5.SomDig_Gueltig_ab__c = Date.today().addDays(2);
            p5.SomDig_Gueltig_bis__c = Date.today().addMonths(6);
            p5.SomDig_Mediagattungsdifferenzierung__c = md1.Id;
            p5.SomDig_Werbeform_Kurzform__c = 'PreMid';
            p5.SomDig_Auftragstyp__c = auftrag.id;
            p5.SomDig_Abrechungsart__c = 'Festpreis';
            p5.SomDig_Rotationstyp__c = 'Umfeld';
            p5.SomDig_Belegungseinheitstyp__c = 'YouTube';
            p5.SomDig_Ad_Type__c = 'Sponsorship';
            p5.SomDig_Prio__c ='3';
            p5.SomDig_Preistyp_zur_Auslieferung__c = 'Evenly';
            
            SomDig_DeliverPrio__c p6 = new SomDig_DeliverPrio__c();
            p6.SomDig_Gueltig_ab__c = Date.today().addMonths(6).addDays(1);
            p6.SomDig_Gueltig_bis__c = Date.today().addMonths(6).addDays(30);
            p6.SomDig_Mediagattungsdifferenzierung__c = md1.Id;
            p6.SomDig_Werbeform_Kurzform__c = 'PreMid';
            p6.SomDig_Auftragstyp__c = auftrag.id;
            p6.SomDig_Abrechungsart__c = 'Festpreis';
            p6.SomDig_Rotationstyp__c = 'Umfeld';
            p6.SomDig_Belegungseinheitstyp__c = 'YouTube';
            p6.SomDig_Ad_Type__c = 'Sponsorship'; 
            p6.SomDig_Prio__c ='3';
            p6.SomDig_Preistyp_zur_Auslieferung__c = 'Evenly';
            
            sameAuslieferungsprioritaetenDifferentDates = new List<SomDig_DeliverPrio__c>();
            sameAuslieferungsprioritaetenDifferentDates.add(p5);
            sameAuslieferungsprioritaetenDifferentDates.add(p6);
        }
    }
    
    @isTest
    static void testDoubleEntry() {
        Prio_DoubleChecker_Test testClass = new Prio_DoubleChecker_Test();
        testClass.insertTestData();
        //insert testClass.sameAuslieferungsprioritaeten;
        Test.startTest();
        
        /*
        SomDig_DeliverPrio__c ap1 = [ Select SomDig_UniqueKey__c from SomDig_DeliverPrio__c Where id =: testClass.priority.Id ];
        String valueOfUniqueKey = testClass.priority.SomDig_Abrechungsart__c + '|' + testClass.priority.SomDig_Ad_Type__c + '|' + testClass.priority.SomDig_Auftragstyp__c + '|' + testClass.priority.SomDig_Belegungseinheitstyp__c + '|' 
                            + testClass.priority.SomDig_Gueltig_ab__c + '|'+ testClass.priority.SomDig_Gueltig_bis__c + '|'+ testClass.priority.SomDig_Mediagattungsdifferenzierung__c + '|'
                            + testClass.priority.SomDig_Preistyp_zur_Auslieferung__c + '|'+ testClass.priority.SomDig_Prio__c + '|' + testClass.priority.SomDig_Rotationstyp__c + '|' 
                            + testClass.priority.SomDig_Werbeform_Kurzform__c;
        System.assertEquals(ap1.SomDig_UniqueKey__c, valueOfUniqueKey);
        */
        insert testClass.differentAuslieferungsprioritaeten;
        
        insert testClass.sameAuslieferungsprioritaetenDifferentDates;
        Test.stopTest();
    }
    
}