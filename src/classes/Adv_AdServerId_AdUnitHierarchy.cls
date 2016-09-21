/**
 * A batchable and schedulable class to maintain some data in AdUnitHierarchy
 *
 */
global with sharing class Adv_AdServerId_AdUnitHierarchy implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    /** Batch size. */
    private Integer	batchSize 		= 100;

    /** Ids of ADvendio__AdServer_ID__c to check. Mainly used for testing. */
    private Set<Id>	recIds 			= null;

    /** A count for counting number of batches processed. */
    private	Integer totalBatchs		= 0;

    /** A count for counting number of accounts processed. */
    private	Integer totalRecords	= 0;

    /**
     * Constructor.
     */
    public Adv_AdServerId_AdUnitHierarchy() {
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
        String query = 'SELECT ADvendio__Site__c, SomDig_MediagattungsSegment__c, SomDig_TopSite__c, SomDig_TopMediagattungsSegment__c ' +
                         'FROM ADvendio__AdServer_ID__c ' +
                        'WHERE isDeleted = false ' +
                          'AND ADvendio__Parent_AdServer_ID__c != null ' +
                          'AND ADvendio__Type__c = \'Ad Unit\' ' +
                          'AND (ADvendio__Site__c = null OR SomDig_MediagattungsSegment__c = null)';

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

        System.debug('\n\nAdv_AdServerId_AdUnitHierarchy: Execute: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', SizeOfBatchRecords = ' + records.size() + ', BatchJobId = ' + (bc == null ? '' : bc.getJobId()) + '\n');

        List<ADvendio__AdServer_ID__c> toUpdateRecords = new List<ADvendio__AdServer_ID__c>();

        Id siteId = null, mediagattungId = null;
        for (ADvendio__AdServer_ID__c rec : (List<ADvendio__AdServer_ID__c>)records) {
            Boolean alreadyAdded = false;
            if (rec.ADvendio__Site__c != null || rec.SomDig_MediagattungsSegment__c != null || rec.SomDig_TopSite__c != null || rec.SomDig_TopMediagattungsSegment__c != null) {
                // Issue: SOMDIG-21
                siteId = rec.SomDig_TopSite__c == null ? null : Id.valueOf(rec.SomDig_TopSite__c);
                mediagattungId = rec.SomDig_TopMediagattungsSegment__c == null ? null : Id.valueOf(rec.SomDig_TopMediagattungsSegment__c);
                if (siteId != null && mediagattungId != null && (siteId != rec.ADvendio__Site__c || mediagattungId != rec.SomDig_MediagattungsSegment__c)) {
                    rec.ADvendio__Site__c = siteId;
                    rec.SomDig_MediagattungsSegment__c = mediagattungId;
                    toUpdateRecords.add(rec);
                    alreadyAdded = true;
                }
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
        AsyncApexJob job = (bc == null ? null : [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()]);
        System.debug('\n\nAdv_AdServerId_AdUnitHierarchy: Finish: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', ' + job + '\n');
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