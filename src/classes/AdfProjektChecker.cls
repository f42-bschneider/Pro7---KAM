/**
 * A batch, schedulabel job to check the sObject SomTv_AdfProjekt__c to keep data updated.
 */
global with sharing class AdfProjektChecker implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    /** Batch size. */
    private Integer batchSize = 100;
    
    /** Ids of SomTv_AdfProjekt__c to force to check. */
    private Set<Id> ids = null;

    /* Stateful parameters, for statistics */
    global  Integer             totalBatchs     = 0;
    global  Integer             totalRecords    = 0;

    /**
     * Constructor.
     */
    global AdfProjektChecker() {
    }

    /**
     * Set the Ids of SomTv_AdfProjekt__c to check.
     *
     * @param   ids Ids of SomTv_AdfProjekt__c to set.
     */
    global void setAdfProjektIds(Set<Id> ids) {
        this.ids = ids;
    }
    
    /**
     * Batch job start routine.
     *
     * @param   bc  Context of the batchable job.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query =  'SELECT Id FROM SomTv_AdfProjekt__c WHERE isDeleted = false';
        
        if (ids != null) {           
            ids.remove(null);
        }

        if (ids != null && !ids.isEmpty()) {
            query += ' AND Id IN :ids';
        }
        
        return Database.getQueryLocator(query);
    }

    /**
     * Batch job excution routine.
     *
     * @param   bc      Context of the batchable job.
     * @param   records List of sObject to process.
     */
    global void execute(Database.BatchableContext bc, List<sObject> records) {
        totalBatchs++;
        totalRecords += records.size();

        System.debug('\n\nAdfProjektChecker: Execute: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', SizeOfBatchRecords = ' + records.size() + (bc == null ? '' : (', BatchJobId = ' + bc.getJobId())));       

        /*
        ... nach folgenden Bedingungen, Beträge der zugeordneten Oli´s im Objekt SomTv_AdfProjekt_c setzt bzw. berechnet.
        
        Folgende Berechnungen NUR für Oli.SomTv_OliRabattierfaehig__c=true && Oli.Product2.SomTv_Produkthierarchieebene1__c <> "8. Online"
        - SomTv_AdfProjekt_r.SomTv_MB3Rabattierfaehig__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Rabattierfaehig__c = SUM von Oli.SomTv_MB1Bezahlt__c
        - SomTv_AdfProjekt_r.SomTv_BRRabattierfaehig__c = (SUM von(Oli.SomTv_MB1Bezahlt__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Rabattierfaehig__c
        - SomTv_AdfProjekt_r.SomTv_MN1Rabattierfaehig__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Rabattierfaehig__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Rabattierfaehig__c = SUM von Oli.SomTv_MN3__c
        
        Folgende Berechnungen NUR für Oli.SomTv_Produkthierarchiebene1__c="3. Placements":
        - SomTv_AdfProjekt_r.SomTv_MB3Placements__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Placements__c = SUM von Oli.SomTv_MB1Bezahlt__c
        - SomTv_AdfProjekt_r.SomTv_BRPlacements__c = (SUM von(Oli.SomTv_MB1Bezahlt__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Placements__c
        - SomTv_AdfProjekt_r.SomTv_MN1Placements__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Placements__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Placements__c = SUM von Oli.SomTv_MN3__c
        
        Folgende Berechnungen NUR für Oli.SomTv_Produkthierarchiebene1__c="6. Lizenzierung":
        - SomTv_AdfProjekt_r.SomTv_MB3Lizenz__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Lizenz__c = SUM von Oli.SomTv_MB1Bezahlt__c
        - SomTv_AdfProjekt_r.SomTv_BRLizenz__c = (SUM von(Oli.SomTv_MB1Bezahlt__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Lizenz__c
        - SomTv_AdfProjekt_r.SomTv_MN1Lizenz__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Lizenz__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Lizenz__c = SUM von Oli.SomTv_MN3__c
        
        Folgende Berechnungen NUR für Oli.SomTv_Produkthierarchieebene1__c = "7. Testimonial":
        - SomTv_AdfProjekt__r.SomTv_MB3Testimonial__c = SUM von Oli.SomTv_MB3_Kopf_c
        - SomTv_AdfProjekt__r.SomTv_MB1Testimonial__c = SUM von Oli.SomTv_MB1Bezahlt__c
        - SomTv_AdfProjekt__r.SomTv_BRTestimonial__c = (SUM von(Oli.SomTv_MB1Bezahlt__c*Oli. BRc)) / SomTv_AdfProjekt_r.SomTv_MB1Testimonial__c
        - SomTv_AdfProjekt__r.SomTv_MN1Testimonial__c = SUM von Oli.SomTV_MN1_c
        - SomTv_AdfProjekt__r.SomTv_MN2Testimonial__c = SUM von Oli.SomTv_MN2_c
        - SomTv_AdfProjekt__r.SomTv_MN3Testimonial__c = SUM von Oli. SomTv_MN3_c

        Folgende Berechnungen NUR für Oli.SomTv_OliRabattierfaehig__c=true && Oli.SomTv_Innerhalb_Commitment__c ="nein" && Oli.Product2.SomTv_Produkthierarchieebene1__c <> "8. Online":
        - SomTv_AdfProjekt_r.SomTv_MB3Tvfrei__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Tvfrei__c = SUM von Oli.SomTv_MB1Bezahlt__c
        - SomTv_AdfProjekt_r.SomTv_BRTvfrei__c = (SUM von(Oli.SomTv_MB1Bezahlt__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Tvfrei__c
        - SomTv_AdfProjekt_r.SomTv_MN1Tvfrei__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Tvfrei__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Tvfrei__c = SUM von Oli.SomTv_MN3__c
        
        Folgende Berechnungen NUR für Oli.SomTv_Produkthierarchieebene1__c = "8. Online":
        - SomTv_AdfProjekt_r.SomTv_MB3Digital__c = SUM von Oli.SomTv_MB3_Kopf_c
        - SomTv_AdfProjekt_r.SomTv_MB1Digital__c = SUM von Oli.SomTv_MB1Bezahlt__c
        - SomTv_AdfProjekt_r.SomTv_BRDigital__c = (SUM von(Oli.SomTv_MB1Bezahlt__c*Oli. BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Digital__c
        - SomTv_AdfProjekt_r.SomTv_MN1Digital__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Digital__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Digital__c = SUM von Oli. SomTv_MN3__c

        Folgende Berechnungen über ALLE Oli:
        - SomTv_AdfProjekt_r.SomTv_MB3Gesamt__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Gesamt__c = SUM von Oli.SomTv_MB1Bezahlt__c
        - SomTv_AdfProjekt_r.SomTv_BRGesamt__c = (SUM von(Oli.SomTv_MB1Bezahlt__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Gesamt__c
        - SomTv_AdfProjekt_r.SomTv_MN1Gesamt__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Gesamt__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Gesamt__c = SUM von Oli.SomTv_MN3__c
        */

        Map<Id, SomTv_AdfProjekt__c> mRecords = new Map<Id, SomTv_AdfProjekt__c>();
        
        for (SomTv_AdfProjekt__c rec : (List<SomTv_AdfProjekt__c>)records) {
            rec.SomTv_MB3Rabattierfaehig__c = 0;
            rec.SomTv_MB1Rabattierfaehig__c = 0;
            rec.SomTv_BRRabattierfaehig__c  = 0;
            rec.SomTv_MN1Rabattierfaehig__c = 0;
            rec.SomTv_MN2Rabattierfaehig__c = 0;
            rec.SomTv_MN3Rabattierfaehig__c = 0;
            
            rec.SomTv_MB3Placements__c = 0;
            rec.SomTv_MB1Placements__c = 0;
            rec.SomTv_BRPlacements__c  = 0;
            rec.SomTv_MN1Placements__c = 0;
            rec.SomTv_MN2Placements__c = 0;
            rec.SomTv_MN3Placements__c = 0;
            
            rec.SomTv_MB3Lizenz__c = 0;
            rec.SomTv_MB1Lizenz__c = 0;
            rec.SomTv_BRLizenz__c  = 0;
            rec.SomTv_MN1Lizenz__c = 0;
            rec.SomTv_MN2Lizenz__c = 0;
            rec.SomTv_MN3Lizenz__c = 0;
            
            rec.SomTv_MB3Testimonial__c = 0;
            rec.SomTv_MB1Testimonial__c = 0;
            rec.SomTv_BRTestimonial__c  = 0;
            rec.SomTv_MN1Testimonial__c = 0;
            rec.SomTv_MN2Testimonial__c = 0;
            rec.SomTv_MN3Testimonial__c = 0;

            rec.SomTv_MB3Tvfrei__c = 0;
            rec.SomTv_MB1Tvfrei__c = 0;
            rec.SomTv_BRTvfrei__c  = 0;
            rec.SomTv_MN1Tvfrei__c = 0;
            rec.SomTv_MN2Tvfrei__c = 0;
            rec.SomTv_MN3Tvfrei__c = 0;
            
            rec.SomTv_MB3Digital__c = 0;
            rec.SomTv_MB1Digital__c = 0;
            rec.SomTv_BRDigital__c  = 0;
            rec.SomTv_MN1Digital__c = 0;
            rec.SomTv_MN2Digital__c = 0;
            rec.SomTv_MN3Digital__c = 0;

            rec.SomTv_MB3Gesamt__c = 0;
            rec.SomTv_MB1Gesamt__c = 0;
            rec.SomTv_BRGesamt__c  = 0;
            rec.SomTv_MN1Gesamt__c = 0;
            rec.SomTv_MN2Gesamt__c = 0;
            rec.SomTv_MN3Gesamt__c = 0;
            
            mRecords.put(rec.Id, rec);
        }
        
        mRecords.remove(null);
        
        if (!mRecords.isEmpty()) {
            for (List<OpportunityLineItem> olis : [SELECT Id, SomTv_Projektname__c, SomTv_MB3_Kopf__c, SomTv_MB1Bezahlt__c, BR__c, SomTV_MN1__c, SomTV_MN2__c, SomTV_MN3__c, SomTv_OliRabattierfaehig__c, SomTv_Produkthierarchiebene1__c, SomTv_Innerhalb_Commitment__c FROM OpportunityLineItem WHERE SomTv_Projektname__c IN :mRecords.keySet() AND isDeleted = false ORDER BY SomTv_Projektname__c]) {
                for (OpportunityLineItem oli : olis) {
                    SomTv_AdfProjekt__c ap = mRecords.get(oli.SomTv_Projektname__c);
                    if (ap != null) {
                        if (oli.SomTv_OliRabattierfaehig__c && '8. Online'.equalsIgnoreCase(oli.SomTv_Produkthierarchiebene1__c) != true) {
                            ap.SomTv_MB3Rabattierfaehig__c += (oli.SomTv_MB3_Kopf__c != null ? oli.SomTv_MB3_Kopf__c : 0);
                            ap.SomTv_MB1Rabattierfaehig__c += (oli.SomTv_MB1Bezahlt__c != null ? oli.SomTv_MB1Bezahlt__c : 0);
                            ap.SomTv_BRRabattierfaehig__c  += ((oli.SomTv_MB1Bezahlt__c != null && oli.BR__c != null) ? (oli.SomTv_MB1Bezahlt__c * oli.BR__c) : 0);
                            ap.SomTv_MN1Rabattierfaehig__c += (oli.SomTV_MN1__c != null ? oli.SomTV_MN1__c : 0);
                            ap.SomTv_MN2Rabattierfaehig__c += (oli.SomTV_MN2__c != null ? oli.SomTV_MN2__c : 0);
                            ap.SomTv_MN3Rabattierfaehig__c += (oli.SomTV_MN3__c != null ? oli.SomTV_MN3__c : 0);
                            
                        }
                        if ('3. Placements'.equalsIgnoreCase(oli.SomTv_Produkthierarchiebene1__c)) {
                            ap.SomTv_MB3Placements__c += (oli.SomTv_MB3_Kopf__c != null ? oli.SomTv_MB3_Kopf__c : 0);
                            ap.SomTv_MB1Placements__c += (oli.SomTv_MB1Bezahlt__c != null ? oli.SomTv_MB1Bezahlt__c : 0);
                            ap.SomTv_BRPlacements__c  += ((oli.SomTv_MB1Bezahlt__c != null && oli.BR__c != null) ? (oli.SomTv_MB1Bezahlt__c * oli.BR__c) : 0);
                            ap.SomTv_MN1Placements__c += (oli.SomTV_MN1__c != null ? oli.SomTV_MN1__c : 0);
                            ap.SomTv_MN2Placements__c += (oli.SomTV_MN2__c != null ? oli.SomTV_MN2__c : 0);
                            ap.SomTv_MN3Placements__c += (oli.SomTV_MN3__c != null ? oli.SomTV_MN3__c : 0);
                        }
                        if ('6. Lizenzierung'.equalsIgnoreCase(oli.SomTv_Produkthierarchiebene1__c)) {
                            ap.SomTv_MB3Lizenz__c += (oli.SomTv_MB3_Kopf__c != null ? oli.SomTv_MB3_Kopf__c : 0);
                            ap.SomTv_MB1Lizenz__c += (oli.SomTv_MB1Bezahlt__c != null ? oli.SomTv_MB1Bezahlt__c : 0);
                            ap.SomTv_BRLizenz__c  += ((oli.SomTv_MB1Bezahlt__c != null && oli.BR__c != null) ? (oli.SomTv_MB1Bezahlt__c * oli.BR__c) : 0);
                            ap.SomTv_MN1Lizenz__c += (oli.SomTV_MN1__c != null ? oli.SomTV_MN1__c : 0);
                            ap.SomTv_MN2Lizenz__c += (oli.SomTV_MN2__c != null ? oli.SomTV_MN2__c : 0);
                            ap.SomTv_MN3Lizenz__c += (oli.SomTV_MN3__c != null ? oli.SomTV_MN3__c : 0);
                        }
                        if ('7. Testimonial'.equalsIgnoreCase(oli.SomTv_Produkthierarchiebene1__c)) {
                            ap.SomTv_MB3Testimonial__c += (oli.SomTv_MB3_Kopf__c != null ? oli.SomTv_MB3_Kopf__c : 0);
                            ap.SomTv_MB1Testimonial__c += (oli.SomTv_MB1Bezahlt__c != null ? oli.SomTv_MB1Bezahlt__c : 0);
                            ap.SomTv_BRTestimonial__c  += ((oli.SomTv_MB1Bezahlt__c != null && oli.BR__c != null) ? (oli.SomTv_MB1Bezahlt__c * oli.BR__c) : 0);
                            ap.SomTv_MN1Testimonial__c += (oli.SomTV_MN1__c != null ? oli.SomTV_MN1__c : 0);
                            ap.SomTv_MN2Testimonial__c += (oli.SomTV_MN2__c != null ? oli.SomTV_MN2__c : 0);
                            ap.SomTv_MN3Testimonial__c += (oli.SomTV_MN3__c != null ? oli.SomTV_MN3__c : 0);
                        }
                        if (oli.SomTv_OliRabattierfaehig__c && 'Nein'.equalsIgnoreCase(oli.SomTv_Innerhalb_Commitment__c) && '8. Online'.equalsIgnoreCase(oli.SomTv_Produkthierarchiebene1__c) != true) {
                            ap.SomTv_MB3Tvfrei__c += (oli.SomTv_MB3_Kopf__c != null ? oli.SomTv_MB3_Kopf__c : 0);
                            ap.SomTv_MB1Tvfrei__c += (oli.SomTv_MB1Bezahlt__c != null ? oli.SomTv_MB1Bezahlt__c : 0);
                            ap.SomTv_BRTvfrei__c  += ((oli.SomTv_MB1Bezahlt__c != null && oli.BR__c != null) ? (oli.SomTv_MB1Bezahlt__c * oli.BR__c) : 0);
                            ap.SomTv_MN1Tvfrei__c += (oli.SomTV_MN1__c != null ? oli.SomTV_MN1__c : 0);
                            ap.SomTv_MN2Tvfrei__c += (oli.SomTV_MN2__c != null ? oli.SomTV_MN2__c : 0);
                            ap.SomTv_MN3Tvfrei__c += (oli.SomTV_MN3__c != null ? oli.SomTV_MN3__c : 0);
                        }
                        if ('8. Online'.equalsIgnoreCase(oli.SomTv_Produkthierarchiebene1__c)) {
                            ap.SomTv_MB3Digital__c += (oli.SomTv_MB3_Kopf__c != null ? oli.SomTv_MB3_Kopf__c : 0);
                            ap.SomTv_MB1Digital__c += (oli.SomTv_MB1Bezahlt__c != null ? oli.SomTv_MB1Bezahlt__c : 0);
                            ap.SomTv_BRDigital__c  += ((oli.SomTv_MB1Bezahlt__c != null && oli.BR__c != null) ? (oli.SomTv_MB1Bezahlt__c * oli.BR__c) : 0);
                            ap.SomTv_MN1Digital__c += (oli.SomTV_MN1__c != null ? oli.SomTV_MN1__c : 0);
                            ap.SomTv_MN2Digital__c += (oli.SomTV_MN2__c != null ? oli.SomTV_MN2__c : 0);
                            ap.SomTv_MN3Digital__c += (oli.SomTV_MN3__c != null ? oli.SomTV_MN3__c : 0);
                        }                       
                        {
                            ap.SomTv_MB3Gesamt__c += (oli.SomTv_MB3_Kopf__c != null ? oli.SomTv_MB3_Kopf__c : 0);
                            ap.SomTv_MB1Gesamt__c += (oli.SomTv_MB1Bezahlt__c != null ? oli.SomTv_MB1Bezahlt__c : 0);
                            ap.SomTv_BRGesamt__c  += ((oli.SomTv_MB1Bezahlt__c != null && oli.BR__c != null) ? (oli.SomTv_MB1Bezahlt__c * oli.BR__c) : 0);
                            ap.SomTv_MN1Gesamt__c += (oli.SomTV_MN1__c != null ? oli.SomTV_MN1__c : 0);
                            ap.SomTv_MN2Gesamt__c += (oli.SomTV_MN2__c != null ? oli.SomTV_MN2__c : 0);
                            ap.SomTv_MN3Gesamt__c += (oli.SomTV_MN3__c != null ? oli.SomTV_MN3__c : 0);
                        }
                    }
                }
            }
            
            // Recalculate varios SomTv_BR*__c
            for (SomTv_AdfProjekt__c ap : mRecords.values()) {
                ap.SomTv_BRRabattierfaehig__c = ap.SomTv_MB1Rabattierfaehig__c > 0 ? ap.SomTv_BRRabattierfaehig__c / ap.SomTv_MB1Rabattierfaehig__c : 0;
                ap.SomTv_BRPlacements__c      = ap.SomTv_MB1Placements__c > 0 ? ap.SomTv_BRPlacements__c / ap.SomTv_MB1Placements__c : 0;
                ap.SomTv_BRLizenz__c          = ap.SomTv_MB1Lizenz__c > 0 ? ap.SomTv_BRLizenz__c / ap.SomTv_MB1Lizenz__c : 0;
                ap.SomTv_BRTestimonial__c     = ap.SomTv_MB1Testimonial__c > 0 ? ap.SomTv_BRTestimonial__c / ap.SomTv_MB1Testimonial__c : 0;
                ap.SomTv_BRTvfrei__c          = ap.SomTv_MB1Tvfrei__c > 0 ? ap.SomTv_BRTvfrei__c / ap.SomTv_MB1Tvfrei__c : 0;
                ap.SomTv_BRDigital__c         = ap.SomTv_MB1Digital__c > 0 ? ap.SomTv_BRDigital__c / ap.SomTv_MB1Digital__c : 0;
                ap.SomTv_BRGesamt__c          = ap.SomTv_MB1Gesamt__c > 0 ? ap.SomTv_BRGesamt__c / ap.SomTv_MB1Gesamt__c : 0;
            }

            update mRecords.values();
        }
        
    }
    
    /**
     * Batch job completion routine.
     *
     * @param   bc  Context of the batchable job.
     */
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob a = bc == null ? null : [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];

        System.debug('\n\nAdfProjektChecker: Finish: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + (a == null ? '' : (', ' + a)));       
    }

    /**
     * Schedule excution routine.
     *
     * @param   sc  Context of the schedule job.
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, batchSize);
    }

    /**
     * A test methode. seeAllData option is enabled because Standard Pricebook is needed but can't be created.
     */
    @isTest (seeAllData=true)
    public static void testAdfProjektChecker() {
        Test.StartTest();
        
        Id recordTypeId = null;
        
        for (RecordType r : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'SomTv_Commitment' LIMIT 1]) {
            recordTypeId = r.Id;
        }
        System.assert(recordTypeId!=null, 'No RecordType \'SomTv_Commitment\' for Opportunity found!');
        
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        System.assert(pb!=null, 'No standard Pricebook found!');
        
        Product2 prod = new Product2(Name = 'Test Product', SomTv_Produkthierarchieebene1__c='3. Placements');
        insert prod;

        PricebookEntry pbe = new PricebookEntry(UnitPrice=1, Product2Id=prod.Id, Pricebook2Id=pb.Id, IsActive=true, UseStandardPrice=false);
        insert pbe;

        SomTv_AdfProjekt__c ap = new SomTv_AdfProjekt__c();
        insert ap;

        Account acc = new Account(Name='Test Account', ProRex_Rolle__c='Kunde', SomTv_HilfsfeldProRexRolle__c='Kunde');
        insert acc;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity', AccountId=acc.Id, RecordTypeId=recordTypeId, StageName='Angebot abgegeben', CloseDate=System.today(), Amount = 1000, SomTv_AdFProjekt__c = ap.Id);
        insert opp;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbe.Id, Quantity=1, TotalPrice=1, SomTv_MN3_1FS__c=100, SomTv_DispoPreisprozent__c=10, SomTv_OliRabattierfaehig__c=true);
        insert oli;
        
        Set<Id> ids = new Set<Id>();
        ids.add(ap.Id);
        
        SchedulableContext sc;
        
        AdfProjektChecker apc = new AdfProjektChecker();
        
        apc.setAdfProjektIds(ids);
        
        apc.execute(sc);
        
        prod.SomTv_Produkthierarchieebene1__c = '6. Lizenzierung';
        update prod;
        
        apc.execute(sc);        

        Test.StopTest();

    }

}