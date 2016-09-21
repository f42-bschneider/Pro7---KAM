/**
 * A batchable and schedulable class to copy the field data of a campaign item.
 *
 */
global with sharing class Adv_CampaignItem_Performance implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    /** Batch size. */
    private Integer	batchSize 		= 100;

    /** Ids of ADvendio__Campaign_Item__c to force to check. Mainly used for testing. */
    private Set<Id>	recIds 			= null;

    /** A count for counting number of batches processed. */
    private	Integer totalBatchs		= 0;

    /** A count for counting number of accounts processed. */
    private	Integer totalRecords	= 0;

    /**
     * Constructor.
     */
    public Adv_CampaignItem_Performance() {
    }

    /**
     * Set the RecordIds to check. Mainly used for testing.
     * @param	recIds	Record-Ids to set.
     */
    public void setRecordIds(Set<Id> recIds) {
        this.recIds = recIds;
    }

    /**
     * Add a RecordId to check. Mainly used for testing.
     * @param	recId	Record-Id to add.
     */
    public void addRecordId(Id recId) {
        if (this.recIds == null) {
            this.recIds = new Set<Id>();
        }
        this.recIds.add(recId);
    }

    /**
     * Batch job start routine.
     *
     * @param	bc	Context of the batchable job.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query =	'SELECT Id, ADvendio__PerformanceIndicator__c, SomDig_LeistungskennzahlVortag__c ' +
                        'FROM ADvendio__Campaign_Item__c ' +
                        'WHERE isDeleted = false AND ADvendio__Media_Campaign__r.RecordType.DeveloperName = \'SomDig_Auftrag\' AND ADvendio__from_Date__c <= TODAY AND ADvendio__until_Date__c >= TODAY';

        if (recIds != null) {
            recIds.remove(null);
            if (!recIds.isEmpty()) {
                query += ' AND Id IN :recIds';
            }
        }

        return Database.getQueryLocator(query);
    }

    /**
     * Batch job execution routine.
     *
     * It sums revenues of opportunities of accounts.
     *
     * @param	bc		Context of the batchable job.
     * @param	records	List of sObject to process.
     */
    global void execute(Database.BatchableContext bc, List<sObject> records) {
        totalBatchs++;
        totalRecords += records.size();

        System.debug('\n\nAdv_CampaignItem_Performance: Execute: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', SizeOfBatchRecords = ' + records.size() + ', BatchJobId = ' + (bc == null ? '' : bc.getJobId()));

        List<ADvendio__Campaign_Item__c> toUpdateRecords = new List<ADvendio__Campaign_Item__c>();

        for (ADvendio__Campaign_Item__c rec : (List<ADvendio__Campaign_Item__c>)records) {
            // Note: it is assumed that all CampaignItems here fulfill the filter-condition defined e.g. in start().
            if (rec.SomDig_LeistungskennzahlVortag__c != rec.ADvendio__PerformanceIndicator__c) {
                rec.SomDig_LeistungskennzahlVortag__c = rec.ADvendio__PerformanceIndicator__c;
                toUpdateRecords.add(rec);
            }
        }

        if (!toUpdateRecords.isEmpty()) {
            update toUpdateRecords;
        }
    }

    /**
     * Batch job completion routine.
     *
     * @param	bc	Context of the batchable job.
     */
    global void finish(Database.BatchableContext bc){
        // Debug!!!
        AsyncApexJob a = (bc == null ? null : [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()]);
        System.debug('\n\nAdv_CampaignItem_Performance: Finish: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', ' + a);
    }

    /**
     * Schedule excution routine.
     *
     * @param	sc	Context of the schedule job.
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, batchSize);
    }


}