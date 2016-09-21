/**
 * A schedulable job to create pre-invoices for ADvendio__MediaCampaign__c.
 */
global with sharing class Adv_Invoice_CreateInvoice implements Schedulable {

    /** The default QUERY. */
    private final static String DEFAULT_QUERY = 'SELECT Id FROM ADvendio__MediaCampaign__c WHERE isDeleted = false AND ADvendio__BillMe__c = true AND ADvendio__Propability__c = 100';

    /** Ids of ADvendio__MediaCampaign__c to force to check. Mainly used for testing. */
    private Set<Id> recIds  = null;

    /**
     * Constructor.
     */
    public Adv_Invoice_CreateInvoice() {
    }

    /**
     * Set the RecordIds to check. Mainly used for testing.
     * @param   recIds  Record-Ids to set.
     */
    public void setRecordIds(Set<Id> recIds) {
        this.recIds = recIds;
    }

    /**
     * Add a RecordId to check. Mainly used for testing.
     * @param   recId   Record-Id to add.
     */
    public void addRecordId(Id recId) {
        if (this.recIds == null) {
            this.recIds = new Set<Id>();
        }
        this.recIds.add(recId);
    }

    /**
     * Start the creating pre-invoice prozess.
     */
    public void createPreInvoice() {
        String query = DEFAULT_QUERY;

        if (recIds != null) {
            recIds.remove(null);
            if (!recIds.isEmpty()) {
                query += ' AND Id IN (';

                for (Id s : recIds) {
                    query += '\'' + s + '\'' + ',';
                }

                query = query.substring(0, query.length()-1);
                query += ')';
            }
        }

        ADvendio.GenerateInvoiceBatch job = new ADvendio.GenerateInvoiceBatch();

        job.query = query;
        job.batchsize = 1;

        Database.executeBatch(job, 1);
    }

    /**
     * Schedule excution routine.
     *
     * @param   sc  Context of the schedule job.
     */
    global void execute(SchedulableContext sc) {
        ADvendio.GenerateInvoiceBatch job = new ADvendio.GenerateInvoiceBatch();

        job.query = DEFAULT_QUERY;
        job.batchsize = 1;

        Database.executeBatch(job, 1);
    }
}