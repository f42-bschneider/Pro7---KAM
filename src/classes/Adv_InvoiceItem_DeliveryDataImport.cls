/**
 * A batchable and schedulable job to import delivery data from ADvendio__Revenue_Schedule__c into ADvendio__InvoiceItem__c
 */
global with sharing class Adv_InvoiceItem_DeliveryDataImport implements Database.Batchable<SObject>, Schedulable {
    /** Batch size. */
    private Integer	batchSize = 100;

    /** Ids of ADvendio__InvoiceItem__c to force to check. Mainly used for testing. */
    private Set<Id>	recIds = null;

    /** A count for counting number of batches processed. */
    global 	Integer totalBatchs	= 0;

    /** A count for counting number of accounts processed. */
    global 	Integer totalRecords = 0;

    /**
     * Constructor.
     */
    public Adv_InvoiceItem_DeliveryDataImport() {
        this.totalBatchs = 0;
        this.totalRecords = 0;
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
        String query =  'SELECT Id, ADvendio__CampaignItem__c, ADvendio__InvoiceItemStartDate__c, ADvendio__InvoiceItemEndDate__c, ADvendio__QuantityDelivered__c ' +
                        'FROM ADvendio__InvoiceItem__c ' +
                        'WHERE isDeleted = false ' +
                        ' AND ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.ADvendio__AdServer_Login__c != null ' +
                        ' AND ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.ADvendio__AdServer_Login__r.ADvendio__Active__c = true ' +
                        ' AND ADvendio__CampaignItem__r.SomDig_MediagattungsSegment__c != \'Nonmedia\' ' +
                        ' AND ADvendio__CampaignItem__r.ADvendio__LinearDistribution__c != true ' +
                        ' AND ADvendio__Invoice__r.ADvendio__Status__c = \'Draft\' ';

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

        System.debug('\n\n Adv_InvoiceItem_DeliveryDataImport: Execute: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', SizeOfBatchRecords = ' + records.size() + ', BatchJobId = ' + (bc == null ? '' : bc.getJobId()));

        Set<Id> campaignItemIds = new Set<Id>();
        for (ADvendio__InvoiceItem__c invoiceItem : (List<ADvendio__InvoiceItem__c>)records) {
            campaignItemIds.add(invoiceItem.ADvendio__CampaignItem__c);
        }

        campaignItemIds.remove(null);

        if (!campaignItemIds.isEmpty()) {
            // Get InvoiceQuantity from RevenueSchedule, grouped by CampaignItem and Month
            Map<String, Decimal> rsInvoiceQuantityMap = getRsInvoiceQuantityMap(campaignItemIds);

            List<ADvendio__InvoiceItem__c> invoiceItemsToUpdate = new List<ADvendio__InvoiceItem__c>();

            for (ADvendio__InvoiceItem__c invoiceItem : (List<ADvendio__InvoiceItem__c>)records) {
                List<String> keyList = new List<String>();

                Date firstOfStartDate = invoiceItem.ADvendio__InvoiceItemStartDate__c.toStartOfMonth();
                keyList.add(invoiceItem.ADvendio__CampaignItem__c+'#'+firstOfStartDate.format());

                Date firstOfEndDate = invoiceItem.ADvendio__InvoiceItemEndDate__c.toStartOfMonth();

                if (firstOfStartDate != firstOfEndDate) {
                    Integer monthsBetween = firstOfStartDate.monthsBetween(firstOfEndDate);

                    if (monthsBetween > 1) {
                        for (Integer i=1; i<monthsBetween; i++) {
                            keyList.add(invoiceItem.ADvendio__CampaignItem__c+'#'+firstOfStartDate.addMonths(i).format());
                        }
                    }

                    keyList.add(invoiceItem.ADvendio__CampaignItem__c+'#'+firstOfEndDate.format());
                }

                // Get / Calculate DeliveredQuantity for the invoiceItem
                Decimal deliveredQuantity = 0;

                for (String key : keyList) {
                    if (rsInvoiceQuantityMap.containsKey(key) && rsInvoiceQuantityMap.get(key) != null) {
                        deliveredQuantity += rsInvoiceQuantityMap.get(key);
                    }
                }

                invoiceItemsToUpdate.add(new ADvendio__InvoiceItem__c(Id=invoiceItem.Id, ADvendio__QuantityDelivered__c=deliveredQuantity));
            }

            System.debug('\n\n invoiceItemsToUpdate: ' + invoiceItemsToUpdate + '\n');

            if (!invoiceItemsToUpdate.isEmpty()) {
                update invoiceItemsToUpdate;
            }
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
        System.debug('\n\n Adv_InvoiceItem_DeliveryDataImport: Finish: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', ' + a);
    }

    /**
     * Schedule excution routine.
     *
     * @param	sc	Context of the schedule job.
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, batchSize);
    }

    /**
     * Gets the Revenue Schedule Invoice Quantity Map.
     * Map key: Campaign Item Id + # + Revenue_Schedule__c.Month__c
     * Map value: Revenue_Schedule__c.InvoiceQuantity__c
     *
     * @param campaignItemIds
     *			Campaign Item Ids
     *
     * @return the Revenue Schedule Invoice Quantity Map
     */
    private Map<String, Decimal> getRsInvoiceQuantityMap(Set<Id> campaignItemIds) {
        Map<String, Decimal> rsInvoiceQuantityMap = new Map<String, Decimal>();

        for (ADvendio__Revenue_Schedule__c revenueSchedule : [SELECT ADvendio__Campaign_Item__c, ADvendio__InvoiceQuantity__c, ADvendio__Month__c FROM ADvendio__Revenue_Schedule__c WHERE ADvendio__Campaign_Item__c IN :campaignItemIds]) {
            String key = revenueSchedule.ADvendio__Campaign_Item__c+'#'+revenueSchedule.ADvendio__Month__c.format();
            rsInvoiceQuantityMap.put(key, revenueSchedule.ADvendio__InvoiceQuantity__c);
        }

        return rsInvoiceQuantityMap;
    }

}