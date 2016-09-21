/**
 * A batchable class to create Buchungssätze (SomDig_Buchungssatz__c) for Revenue Distribution & Projection.
 *
 * ATTENTION:
 * Never start this batch job manuelly!!!
 * It should be started only from SomDig_Buchungssatz_EaStart due to additional checks done / required there!!!
 */
global with sharing class SomDig_Buchungssatz_EaBatch implements Database.Batchable<SObject>, Database.Stateful {
	/** Process type: Ultimo-5 */
	public static final String PROCESS_ULTIMO_MINUS_5 = SomDig_Buchungssatz_EaBase.PROCESS_ULTIMO_MINUS_5;
	
	/** Process type: Ultimo+4 */
	public static final String PROCESS_ULTIMO_PLUS_4 = SomDig_Buchungssatz_EaBase.PROCESS_ULTIMO_PLUS_4;
	
	/** Fields of ADvendio__InvoiceItem__c used for query. */
	private static final String QUERY_INVOICEITEM_FIELDS = 
		'Id, ' +
		'Name, ' +
		'ADvendio__InvoicedAmountNet2__c, ' +
		'ADvendio__InvoiceItemStartDate__c, ' +
		'ADvendio__InvoiceItemEndDate__c, ' +
		'ADvendio__FromDate__c, ' +
		'ADvendio__UntilDate__c, ' +
		'ADvendio__CampaignItem__c, ' +
		'ADvendio__CampaignItem__r.Id, ' +
		'ADvendio__CampaignItem__r.ADvendio__ConnectedItem__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__ConnectedItem__r.Id, ' +
		'ADvendio__Invoice__c, ' +
		'ADvendio__Invoice__r.Name, ' +
		'ADvendio__Invoice__r.CurrencyIsoCode, ' +
		'ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c, ' +
		'ADvendio__Invoice__r.ADvendio__OrderNumber__c, ' +
		'ADvendio__Invoice__r.ADvendio__Status__c, ' +
		'ADvendio__Invoice__r.ADvendio__AccountingDate__c, ' +
		'ADvendio__Invoice__r.ADvendio__AccountingEndDate__c, ' +
		'ADvendio__Invoice__r.ADvendio__InvoiceDate__c, ' +
		'ADvendio__Invoice__r.ADvendio__InvoicedAmountGrossN2__c, ' +
		'ADvendio__Invoice__r.ADvendio__PaymentInterval__c, ' +
		'ADvendio__Invoice__r.ADvendio__PaymentStart__c, ' +
		'ADvendio__Invoice__r.SomDig_Auftragstyp__c, ' +
		'ADvendio__Invoice__r.SomDig_Anzahl_Media_Positionen__c, '+
		'ADvendio__Invoice__r.SomDig_Anzahl_Nonmedia_Positionen__c, ' +
		'ADvendio__Invoice__r.SomDig_Steuerkennzeichen__c, ' +
		'ADvendio__Invoice__r.ADvendio__Invoice__c, ' +
		'ADvendio__Invoice__r.ADvendio__MediaCampaign__c, ' +
		'ADvendio__Invoice__r.ADvendio__MediaCampaign__r.Name, ' +
		'ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Account__c, ' +
		'ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Account__r.Name, ' +
		'ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Agency__c, ' +
		'ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Agency__r.Name, ' +
		'ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Campaign_Start_Date__c, ' +
		'ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Campaign_End_Date__c ';
		
	/** Batch size. */
	private Integer	batchSize 		= 1;
	
	/** Ids of ADvendio__InvoiceItem__c to force to check. */
	private Set<Id>	invoiceItemIds 	= null;

	/** A count for counting number of batches processed. */
	private	Integer totalBatchs		= 0;

	/** A count for counting number of records (ADvendio__InvoiceItem__c) processed. */
	private	Integer totalRecords	= 0;
	
	/** A count for counting number of ADvendio__Invoice__c processed. */
	private	Integer totalNumberOfInvoices	= 0;
	
	/** A count for counting number of ADvendio__Invoice__c successfully processed. */
	private	Integer successNumberOfInvoices	= 0;
	
	/** A count for counting number of SomDig_Buchungssatz__c created. */
	private	Integer totalNumberOfAccountingRecords	= 0;
	
	/** The current instance name. */
	private String instanceName = null;
	  
    /** Process running type. */
    private String processRunningType	= null;
    
    /** Process running date. */
    private Date processRunningDate		= null;

	/** Current / last processed ADvendio__MediaCampaign__c. */
	private ADvendio__MediaCampaign__c currentMediaCampaign = null;
	
	/** Current / last processed ADvendio__Invoice__c. */
	private ADvendio__Invoice__c currentInvoice = null;
	
	/** Processing current / last ADvendio__Invoice__c interrupted? */
	private Boolean currentInvoiceInterrupted = false;
	
	/** Youngest accounting start date of all ADvendio__InvoiceItem__c of current processed ADvendio__Invoice__c. */
	private Date currentYongestInvoiceItemAccountingDate = null;
	
	/** Accounting records being inserted for current / last processed ADvendio__Invoice__c */
	private List<SomDig_Buchungssatz__c> currentAccountingRecords = new List<SomDig_Buchungssatz__c>();
	
	/** PRAP records being upserted for current / last processed ADvendio__Invoice__c */
	private List<SomDig_PRAP__c> currentPRAPRecords = new List<SomDig_PRAP__c>();
	
	/** Errors */
	private List<String> errorMessages = new List<String>();
	private List<String> errorMessagesIA = new List<String>();

	/** Create projection accounting records at invoice item level? */
	private Boolean useProjectionRecordsByInvoiceItem = true;
	
	/** do not create projection accounting records at invoice item leve? */
	private Map<Id, Boolean> isInvoiceUsingProjection = new Map<Id, Boolean>();
			
	/** Accounting end date(time), used for setting accountingMonth, accountingMonthSAP etc. */
	private Datetime accountingEndTime = null;

	/** accountingMonth, used for setting SomDig_Verrechnungsmonat__c of record of SomDig_Buchungssatz__c. */
	private String accountingMonth = null;
	
	/** accountingMonthSAP, used for for setting SomDig_VerrechnungsmonatSAP__c of record of SomDig_Buchungssatz__c. */
	private String accountingMonthSAP = null;

	/**
	 * Constructor.
	 *
	 * @param	processType		The type of process to run, possible is either <code>PROCESS_ULTIMO_MINUS_5</code> or <code>PROCESS_ULTIMO_PLUS_4</code>.
	 *							Set to <code>null</code> to use the default which is <code>PROCESS_ULTIMO_MINUS_5</code>.
	 * @param	runningDate		The date at which the process is running. It is used to verify the invoice items being considered.
	 *							Furthermore, for <code>PROCESS_ULTIMO_MINUS_5</code>, it is used for posibble Extrapolation and Anticipation.
	 *							Set to <code>null</code> to use the default which is today.
	 */
	public SomDig_Buchungssatz_EaBatch(String processType, Date runningDate) {
		this.processRunningType = PROCESS_ULTIMO_MINUS_5.equals(processType)
								? PROCESS_ULTIMO_MINUS_5
								: (PROCESS_ULTIMO_PLUS_4.equals(processType) ? PROCESS_ULTIMO_PLUS_4 : null);

		this.processRunningDate = runningDate != null ? runningDate : System.today();
		
		Date accountingEndDate = System.today().toStartOfMonth().addMonths(1).addDays(-1);	// End of the current month.
    	this.accountingEndTime = Datetime.newInstance(accountingEndDate.year(), accountingEndDate.month(), accountingEndDate.day());

		this.accountingMonth = this.accountingEndTime.format('ddMMyyyy');
		this.accountingMonthSAP = this.accountingEndTime.format('yyMM');

    	if (PROCESS_ULTIMO_MINUS_5.equals(this.processRunningType)) {
			// Create invoice level projection accounting records.
			this.useProjectionRecordsByInvoiceItem = false;
    	} 

		for (Organization o : [SELECT InstanceName FROM Organization LIMIT 1]) {
			this.instanceName = o.InstanceName;
		}
	}

	/**
	 * Get the accounting month for SAP information.
	 *
	 * @return The accounting month for SAP in format 'yyMM'.
	 */
	public String getAccountingMonthSAP() {
		return this.accountingMonthSAP;
	}

	/**
	 * Set the Id of records of ADvendio__InvoiceItem__c to check.
	 * @param	invoiceIds	Ids to set.
	 */
	public void setInvoiceItemIds(Set<Id> invoiceItemIds) {
		this.invoiceItemIds = invoiceItemIds;
	}
	
	/**
	 * Get the query string used for retrieve ADvendio__InvoiceItem__c being processed.
	 *
	 * The query tries to find invoice items:
	 * <ol>
	 *   <li>in expected accounting period.</li>
	 *   <li>By PROCESS_ULTIMO_PLUS_4
	 *     <ol>
	 *       <li>status of invoice is 'Invoiced'.</li>							  
	 *       <li>no SomDig_Buchungssatz__c with recordType 'Erloesaufteilung' is created for it yet if the payment interval is 'monthly (1 month)'.</li>
	 *     </ol>
	 *   </li>
	 *   <li>By PROCESS_ULTIMO_MINUS_5
	 *     <ol>
	 *       <li>status of invoice is 'Created', 'Draft', 'Reviewed' or 'Invoiced'.</li>								  
	 *       <li>no SomDig_Buchungssatz__c with recordType 'Erloesaufteilung' is created for it yet if the payment interval is 'monthly (1 month)'.</li>
	 *       <li>no SomDig_Buchungssatz__c with recordType 'Hochrechnung' and with SomDig_VerrechnungsmonatSAP__c same as process running month,
	 *           is created for it yet if the payment interval is 'monthly (1 month)'.</li>
	 *     </ol>
	 *   </li>
	 * </ol>
	 *
	 * Thus, PRAP invoice items will always found using the query. They must be filtered addtionally. 
	 *
	 * @return	The query string, or <code>null</code> if error.
	 */
	public String getQueryString() {
 		// It is assumed that this process will be run regually (monthly), thus date range will be used to limit the query size.
 		// Furthermore, currently, no MediaCampaign with a date range more than one year is allowed.
 		// Considering this, only invoices in the last 18 months will be checked.
 		
 		// Process Running Time
 		DateTime processRunningTime	= Datetime.newInstance(processRunningDate.year(), processRunningDate.month(), processRunningDate.day());

 		// First (Pre-)Invoice
 		Date     aDate = processRunningDate.toStartOfMonth().addMonths(-18);	// first day of last 18 months of the processRunningDate
 		DateTime firstInvoiceDate = Datetime.newInstance(aDate.year(), aDate.month(), aDate.day());

 		// Last Invoice
	 	aDate = processRunningDate.toStartOfMonth().addDays(-1);	// last day of previous month
 		DateTime lastInvoiceDate = processRunningTime; //Datetime.newInstance(aDate.year(), aDate.month(), aDate.day());
 		
 		// Last Pre-Invoice
	 	aDate = processRunningDate.toStartOfMonth().addMonths(2).addDays(-1);	// last day of next month
 		DateTime lastPreInvoiceDate = Datetime.newInstance(aDate.year(), aDate.month(), aDate.day());
    		
 		// PRAP InvoiceItem
    	if (PROCESS_ULTIMO_MINUS_5.equals(processRunningType)) {
			aDate = processRunningDate.toStartOfMonth();
    	} else if (PROCESS_ULTIMO_PLUS_4.equals(processRunningType)) {
			aDate = processRunningDate.addMonths(-1).toStartOfMonth();
    	}		
 		DateTime prapInvoiceItemDate = Datetime.newInstance(aDate.year(), aDate.month(), aDate.day());

		// Record Type
		Id eaRecordTypeId = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_Buchungssatz__c', 'Erloesaufteilung');
    	Id hrRecordTypeId = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_Buchungssatz__c', 'Hochrechnung');

  		String queryStr = 'SELECT ' + QUERY_INVOICEITEM_FIELDS + ' FROM ADvendio__InvoiceItem__c ';
        
    	if (PROCESS_ULTIMO_MINUS_5.equals(processRunningType)) {
			queryStr += 'WHERE ADvendio__Invoice__r.ADvendio__InvoiceDate__c >= ' + firstInvoiceDate.format('yyyy-MM-dd') +
						 ' AND ((ADvendio__InvoicedAmountNet2__c = 0 AND ADvendio__FromDate__c > ' + processRunningTime.format('yyyy-MM-dd') + ' AND ADvendio__LinearDistribution__c = false) OR ADvendio__InvoicedAmountNet2__c != 0)' +
                		 ' AND ADvendio__CampaignItem__r.RecordType.DeveloperName != \'Packet\'' +
  						 ' AND ((ADvendio__Invoice__r.ADvendio__Status__c = \'Invoiced\' AND ADvendio__Invoice__r.ADvendio__InvoiceDate__c < ' + lastInvoiceDate.format('yyyy-MM-dd') + ') OR (ADvendio__Invoice__r.ADvendio__Status__c IN (\'Created\', \'Draft\', \'Reviewed\') AND ADvendio__Invoice__r.ADvendio__InvoiceDate__c < ' + lastPreInvoiceDate.format('yyyy-MM-dd') + '))' +
   						 ' AND (Id NOT IN (SELECT SomDig_Rechnungsposition__c FROM SomDig_Buchungssatz__c WHERE (RecordTypeId = \'' + eaRecordTypeId + '\' AND SomDig_Rechnungsposition__r.ADvendio__Invoice__r.ADvendio__PaymentInterval__c = \'monthly (1 month)\') OR (RecordTypeId = \'' + hrRecordTypeId + '\' AND SomDig_Rechnungsposition__r.ADvendio__Invoice__r.ADvendio__PaymentInterval__c = \'monthly (1 month)\' AND SomDig_VerrechnungsmonatSAP__c = \'' + accountingMonthSAP + '\')))';
    	} else if (PROCESS_ULTIMO_PLUS_4.equals(processRunningType)) {
			queryStr += 'WHERE ADvendio__Invoice__r.ADvendio__Status__c = \'Invoiced\'' +
						 ' AND ADvendio__InvoicedAmountNet2__c != 0' +		 
                		 ' AND ADvendio__CampaignItem__r.RecordType.DeveloperName != \'Packet\'' +
						 ' AND ADvendio__Invoice__r.ADvendio__InvoiceDate__c >= ' + firstInvoiceDate.format('yyyy-MM-dd') +
  						 ' AND ADvendio__Invoice__r.ADvendio__InvoiceDate__c <= ' + lastInvoiceDate.format('yyyy-MM-dd') +
   						 ' AND (Id NOT IN (SELECT SomDig_Rechnungsposition__c FROM SomDig_Buchungssatz__c WHERE RecordTypeId = \'' + eaRecordTypeId + '\' AND SomDig_Rechnungsposition__r.ADvendio__Invoice__r.ADvendio__PaymentInterval__c = \'monthly (1 month)\'))';
   		}
   		
 		return queryStr;
	}
	
	/**
	 * Batch job start routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String queryStr = getQueryString();

		// Force to find the invoice items with given IDs, even it could be empty, to avoid batch job started manually. 
		if (invoiceItemIds == null) {			 
			invoiceItemIds = new Set<Id>();
		}
		invoiceItemIds.remove(null);
		
		queryStr += ' AND (Id IN :invoiceItemIds) ';
		
		// IMPORTANT!!! Because we'll create Buchungssätze (SomDig_Buchungssatz__c) Invoice-based.
		// If there is any error by one InvoiceItem of an Invoice, the whole Invoice will be "rejected".
		queryStr += 'ORDER BY ADvendio__Invoice__c';

		return Database.getQueryLocator(queryStr);
	}
	
	/**
	 * Batch job execution routine.
	 *
	 * @param	bc		Context of the batchable job.
	 * @param	records	List of sObject to process.
	 */
	global void execute(Database.BatchableContext bc, List<sObject> records) {
		totalBatchs++;
		totalRecords += records.size();

    	System.debug('\n\nSomDig_Buchungssatz_EaBatch: Execute: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', SizeOfBatchRecords = ' + records.size() + ', BatchJobId = ' + (bc == null ? '' : bc.getJobId())); 
    	
    	// It is assumed that all records are sorted by their parent -- ADvendio__Invoice__c !!!
    	for (ADvendio__InvoiceItem__c invoiceItem : (List<ADvendio__InvoiceItem__c>)records) {
    		if (currentInvoice != null && currentInvoice.Id == invoiceItem.ADvendio__Invoice__c) {
    			// Same ADvendio__Invoice__c
    			if (currentInvoiceInterrupted) {
    				continue;
    			}
    		} else {
    			// Changing ADvendio__Invoice__c
    			totalNumberOfInvoices++;
    			
		    	
		    	createRecords();
		    	currentMediaCampaign = invoiceItem.ADvendio__Invoice__r.ADvendio__MediaCampaign__r;
		    	currentInvoice = invoiceItem.ADvendio__Invoice__r;
    			isInvoiceUsingProjection.put(currentInvoice.Id, false);	
	    		currentInvoiceInterrupted = false;
	    		currentYongestInvoiceItemAccountingDate = null;
	    		currentAccountingRecords.clear();
	    		currentPRAPRecords.clear();
    		}
    		
    		try {
    			SomDig_Buchungssatz_EaBase eaBase = new SomDig_Buchungssatz_EaBase(new List<ADvendio__InvoiceItem__c>{invoiceItem},
    																				processRunningType,
    																				processRunningDate,
    																				useProjectionRecordsByInvoiceItem);
    			
    			eaBase.runProcess();
    			
    			if (eaBase.isInvoiceUsingProjection.containsKey(currentInvoice.Id) && eaBase.isInvoiceUsingProjection.get(currentInvoice.Id)) {
    				isInvoiceUsingProjection.put(currentInvoice.Id, true);
    			} 
    			
    			for (SomDig_Buchungssatz_EaBase.RevenueDistributionResult rdr : eaBase.RevenueDistributionResults) {
	    			if (currentYongestInvoiceItemAccountingDate == null || rdr.accountingPeriodStartDate < currentYongestInvoiceItemAccountingDate) {
	    				currentYongestInvoiceItemAccountingDate = invoiceItem.ADvendio__InvoiceItemStartDate__c;
	    			}
    			
    				for (SomDig_Buchungssatz_EaBase.ProcessMessage msg : rdr.messages) {
						if (msg.severity == ApexPages.Severity.FATAL || msg.severity == ApexPages.Severity.ERROR || msg.severity == ApexPages.Severity.WARNING) {
							currentInvoiceInterrupted = true;

							if ('IA'.equals(msg.messageType)) {
								errorMessagesIA.add('Fehler beim Berechnen der EA für die Rechnungsposition ' +
												  createHtmlAnchorTag(currentMediaCampaign, currentInvoice, invoiceItem) +
												  ': ' + msg.message.escapeHtml4());
								currentInvoiceInterrupted = false;
							}
							else {
								errorMessages.add('Fehler beim Berechnen der EA für die Rechnungsposition ' +
												  createHtmlAnchorTag(currentMediaCampaign, currentInvoice, invoiceItem) +
												  ': ' + msg.message.escapeHtml4());
								break;
							}
						}
    				}
    				
    				if (!currentInvoiceInterrupted) {
    					String namePrefix = currentMediaCampaign.Id + '-' + currentInvoice.Id + '-' + invoiceItem.Id + '-';
    					Integer groupIdx = 0;
    					for (SomDig_Buchungssatz_EaBase.AccountingRecordsGroup arg : rdr.accountingRecordsGroups) {
    						groupIdx++;
    						Integer recIdx = 0;
    						for (SomDig_Buchungssatz_EaBase.AccountingRecord ar : arg.accountingRecords) {
    							recIdx++;
    							// Set the name, it will be used later as sort order while generating records for SAP file.
    							ar.accountingRecord.Name = namePrefix 
    													 + (groupIdx * 1.0).setScale(0).toPlainString().leftPad(6).replace(' ','0')
    													 + '-'
    													 + (recIdx * 1.0).setScale(0).toPlainString().leftPad(6).replace(' ','0');
								// Set the Verrechnungsmonat.
								ar.accountingRecord.SomDig_Verrechnungsmonat__c = accountingMonth;
								ar.accountingRecord.SomDig_VerrechnungsmonatSAP__c = accountingMonthSAP;

    							currentAccountingRecords.add(ar.accountingRecord);
    						}
    					}
    					
    					for (SomDig_Buchungssatz_EaBase.PRAP prap : rdr.prapRecords) {
    						if (prap.toUpsert) {
    							prap.prapRecord.SomDig_VerrechnungsmonatSAP__c = accountingMonthSAP;
    							currentPRAPRecords.add(prap.prapRecord);
    						}
    					}
    				} else {
    					currentYongestInvoiceItemAccountingDate = null;
			    		currentAccountingRecords.clear();
			    		currentPRAPRecords.clear();
    					break;
    				}
    			}
    		} catch (Exception e) {
	    		currentInvoiceInterrupted = true;
	    		currentYongestInvoiceItemAccountingDate = null;
	    		currentAccountingRecords.clear();
	    		currentPRAPRecords.clear();
				errorMessages.add('Fehler beim Berechnen der EA für die Rechnungsposition ' +
								  createHtmlAnchorTag(currentMediaCampaign, currentInvoice, invoiceItem) + 
								  ': ' + (e.getMessage() != null ? e.getMessage().escapeHtml4() : 'unbekannter Fehler.'));
    		}
    	}
	}
	
	/**
	 * Batch job completion routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global void finish(Database.BatchableContext bc){
    	AsyncApexJob job = (bc == null ? null : [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.FirstName, CreatedBy.LastName, CreatedBy.Name FROM AsyncApexJob WHERE Id = :bc.getJobId()]);

    	System.debug('\n\nSomDig_Buchungssatz_EaBatch: Finish: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', ' + job);
    	
    	// Just save records if there are
    	createRecords();
    	
    	// Get the SomDig_SapDatei__c
    	SomDig_SapDatei__c sapDatei = null;
	    if (successNumberOfInvoices > 0) {
	    	String buchungskreis = SomDig_Buchungssatz_EaBase.BUCHUNGSKREIS;
	    	String jahr = accountingEndTime.format('yyyy');
	    	String monat = accountingEndTime.format('MM');
	    	String tag = accountingEndTime.format('dd');
	    	Id recordTypeId = null;
	
	    	if (PROCESS_ULTIMO_MINUS_5.equals(processRunningType)) {
				recordTypeId = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_SapDatei__c', 'SomDig_Hochrechnung');
	    	} else if (PROCESS_ULTIMO_PLUS_4.equals(processRunningType)) {
				recordTypeId = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_SapDatei__c', 'SomDig_Erloesaufteilung');
	    	}
    	
	    	for (SomDig_SapDatei__c rec :  [SELECT Id FROM SomDig_SapDatei__c
	    									WHERE RecordTypeId = :recordTypeId AND
	    										  SomDig_Buchungskreis__c = :buchungskreis AND
	    										  SomDig_Jahr__c = :jahr AND
	    										  SomDig_Monat__c = :monat AND
	    										  SomDig_Nummer__c = null AND
	    										  SomDig_Status__c = 'erstellt'
	    									ORDER BY Name ASC
	    									LIMIT 1])
	    	{
	    		sapDatei = rec;
		    	System.debug('\n\nSomDig_Buchungssatz_EaBatch: found existed SomDig_SapDatei__c: ' + sapDatei);    	
	    	}
	    	
	    	if (sapDatei == null) {
	    		sapDatei = new SomDig_SapDatei__c(SomDig_Buchungskreis__c=buchungskreis, SomDig_Jahr__c=jahr, SomDig_Monat__c=monat, SomDig_Tag__c=tag,
	    											SomDig_Quellsystem__c='advendio', SomDig_Status__c='erstellt',RecordTypeId=recordTypeId);
	    		insert sapDatei;
		    	System.debug('\n\nSomDig_Buchungssatz_EaBatch: created new SomDig_SapDatei__c: ' + sapDatei);    	
	    	}
    	}
	    	
    	// Send mail
    	if (job != null) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			String[] toAddresses = new String[] { job.CreatedBy.Email };
			mail.setToAddresses(toAddresses);
	
			mail.setSubject('Prozess ' + processRunningType + ' ist beendet');
			
	        String htmlbody = '<html>\n'
	                        + '<head>\n'
	                        + '<style type="text/css">\n'
	                        + '<!--\n'
	                        + '  body    { font-family:Verdana; font-size:12px; }\n'
	                        + '  table   { font-size:12px; border-width:1px; border-spacing:2px; border-style:solid; border-color:gray; border-collapse:collapse; }\n'
	                        + '  caption { font-size:14px; font-weight:bold; white-space:nowrap; }\n'
	                        + '  th      { font-size:12px; font-weight:bold; border-width:1px; border-style:solid; border-color:gray; padding:4px; white-space:nowrap; }\n'
	                        + '  td      { font-size:12px; border-width:1px; border-style:solid; border-color:gray; padding:4px; white-space:nowrap; }\n'
	                        + '-->\n'
	                        + '</style>\n'
	                        + '</head>\n'
	                        + '<body>\n';
			
			htmlbody += 'Hallo ' + job.CreatedBy.FirstName + ',\n<br/><br/>';
			htmlbody += 'der von Dir gestartete Prozess ' + processRunningType + ' ist jetzt beendet. Im Folgenden findest Du die Informationen zum Prozessergebnis und das weitere Vorgehen.\n';
			
			htmlbody += '<p>\n<b>Statistiken</b>\n<table style=\'border-width:0px;\'>';
			htmlbody += '<tr><td style=\'text-align:left; border-width:0px;\'>Anzahl der bearbeiteten Rechnungen:</td><td style=\'border-width:0px;\'>' + totalNumberOfInvoices + '</td></tr>';
			htmlbody += '<tr><td style=\'text-align:left; border-width:0px;\'>Anzahl der erfolgreich bearbeiteten Rechnungen:</td><td style=\'border-width:0px;\'>' + successNumberOfInvoices + '</td></tr>';
			htmlbody += '<tr><td style=\'text-align:left; border-width:0px;\'>Anzahl der erfolgreich erstellten Buchnungssätze:</td><td style=\'border-width:0px;\'>' + totalNumberOfAccountingRecords + '</td></tr>';
			htmlbody += '</table>\n</p>\n';
			
			
			if (!errorMessages.isEmpty() ) {
				htmlbody += '<p>\n<b>Fehler</b>\n<ul>\n';
				for (String s : errorMessages) {
					htmlbody += '<li>' + s + '</li>';
				}
				htmlbody += '</ul>\n</p>\n';
			}

			if (totalNumberOfInvoices > 0 && (successNumberOfInvoices > 0 || !errorMessages.isEmpty())) {
				htmlbody += '<p>\n<b>Weiteres Vorgehen</b>\n<ul>\n';
				if (!errorMessages.isEmpty()) {
					htmlbody += '<li>Behebe die Fehler, starte dann den Prozess erneut.</li>';
				}
				if (sapDatei != null) {
					htmlbody += '<li>Gehe zu <a href="https://' + instanceName + '.salesforce.com/' + sapDatei.Id + '">' + 'SAP-Datei</a>, starte den Buchnungssätze-Zuweisensprozess durch Klicken den Button "Buchungssätze zuweisen".</li>';
					htmlbody += '<li>Nachdem die Buchungssätze zugewiesen sind, gehe zu <a href="https://' + instanceName + '.salesforce.com/' + sapDatei.Id + '">' + 'SAP-Datei</a>, starte den Uploadprozess durch Klicken den Button "SAP Datei Upload".</li>';
					//htmlbody += '<li>Ein Prozess wird gestartet, um die erstellte Buchungssätze zu SAP Datei zuzuweisen. Eine weitere Mail wird an Dich geschickt wenn der Prozess beendet ist.</li>';
				}
				htmlbody += '</ul>\n</p>\n';
			}
			
			if (!errorMessagesIA.isEmpty() ) {
				if (PROCESS_ULTIMO_MINUS_5.equalsIgnoreCase(this.processRunningType)) {
					htmlbody += '<p>\n<b>Hinweis</b>\n<ul>\n';
					htmlbody += 'Die folgenden Rechnungen aus Mediakampagnen konnten, Aufgrund fehlerhafter oder nicht vollständiger Daten im System, nicht auf ihre eigentlichen IA-Nummern und Sachkonten verteilt werden!\n';
					htmlbody += 'VOR dem Monatsabschluss (Ultimo+4) ist unbedingt sicherzustellen, dass die Daten gepflegt werden. Zum Monatsabschluss erfolgt KEINE Verteilung auf den Dummy Innenauftrag als Sammelposten!\n';

					for (String s : errorMessagesIA) {
						htmlbody += '<li>' + s + '</li>';
					}
					htmlbody += '</ul>\n</p>\n';
				}
			}

			htmlbody += '<p>\nViel Grüße\n<br/>Dein SF-Admin</p>';
			
			mail.setHtmlBody(htmlbody);
	
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}	

/*	Currently don't start Buchungssätze Zuweisung process.
 *
    	if (sapDatei != null) {
    		// Start the Buchungssätze Zuweisung now.
    		SomDig_SapDatei sapDateiClass = new SomDig_SapDatei();
			sapDateiClass.sapDateiId = sapDatei.Id;
			
			Integer numJobs = [SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ( Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing' )];
			if (numJobs > 4) {
				// try again in a minute
				Datetime sysTime = System.now().addSeconds(60);
				String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
	
		    	System.debug('\n\nSomDig_Buchungssatz_EaBatch: scheduled a batch job to assign Buchungssatz to SAP-Datei with Id ' + sapDatei.Id);    	
				System.schedule('SomDig_SapDatei_' + sysTime, chronExpression, sapDateiClass);                
	        } else {
		    	System.debug('\n\nSomDig_Buchungssatz_EaBatch: started a batch job to assign Buchungssatz to SAP-Datei with Id ' + sapDatei.Id);    	
				Database.executeBatch(sapDateiClass);
	        }
    	}
*/	
	}
	
	/**
	 * Create accounting / RPAP records if required.
	 */
	private void createRecords() {
		if (!currentInvoiceInterrupted) {
			Savepoint sp = Database.setSavepoint();

			try {
				List<SomDig_Buchungssatz__c> projectionAccountingRecords = createProjectedAccountingRecordsForInvoice();
				
				
				if (currentInvoice != null && currentInvoice.ADvendio__Invoice__c == null && !projectionAccountingRecords.isEmpty()) { // no cancelation
					insert projectionAccountingRecords;
				}
	    		if (!currentAccountingRecords.isEmpty()) {					
	    			insert currentAccountingRecords;
	    		}
	    		if (currentInvoice != null && currentInvoice.ADvendio__Invoice__c != null && !projectionAccountingRecords.isEmpty()) { // is cancelation
					insert projectionAccountingRecords;
				}
	    		if (!currentPRAPRecords.isEmpty()) {
	    			upsert currentPRAPRecords SomDig_UniqueKey__c;
	    		}
	    		if (!projectionAccountingRecords.isEmpty() || !currentAccountingRecords.isEmpty() || !currentPRAPRecords.isEmpty()) {
	    			successNumberOfInvoices++;
	    		}
	    		totalNumberOfAccountingRecords += projectionAccountingRecords.size();
	    		totalNumberOfAccountingRecords += currentAccountingRecords.size();
	    		currentAccountingRecords.clear();
	    		currentPRAPRecords.clear();
			} catch (Exception e) {
				Database.rollback(sp);
				errorMessages.add('Fehler beim Abspeichern der Buchungssätze für die Rechnung ' + 
								  createHtmlAnchorTag(currentMediaCampaign, currentInvoice, null) + 
								  ': ' + (e.getMessage() != null ? e.getMessage().escapeHtml4() : 'unbekannter Fehler.'));
			}
		}
	}
	
	/**
	 * Create accounting records for projected revenue (Hochrechnung) for current invoice.
	 *
	 * @return A list of object of type <code>SomDig_Buchungssatz__c</code>.
	 */
	private List<SomDig_Buchungssatz__c> createProjectedAccountingRecordsForInvoice() {
		List<SomDig_Buchungssatz__c> projectionAccountingRecords = new List<SomDig_Buchungssatz__c>();

		if (!useProjectionRecordsByInvoiceItem
			&&
			currentInvoice != null
			&&
			(!isInvoiceUsingProjection.containsKey(currentInvoice.Id) || isInvoiceUsingProjection.get(currentInvoice.Id))
			&&
		    PROCESS_ULTIMO_MINUS_5.equals(processRunningType) // Ultimo-5
			&&
		    !'Barter'.equals(currentInvoice.SomDig_Auftragstyp__c)	// No Barter.
		    &&
			!'Invoiced'.equals(currentInvoice.ADvendio__Status__c) // Invoice should not be invoiced
			&&
			(
			 'monthly (1 month)'.equals(currentInvoice.ADvendio__PaymentInterval__c) // Monthly invoice
			 ||
			 (
			  'total account (one Invoice)'.equals(currentInvoice.ADvendio__PaymentInterval__c)	// One invoice (PRAP)
			  &&
			  currentYongestInvoiceItemAccountingDate.year() == currentInvoice.ADvendio__AccountingDate__c.year()	// One invoice but should be first year (first PRAP)
			  &&
			  currentYongestInvoiceItemAccountingDate.month() == currentInvoice.ADvendio__AccountingDate__c.month() 	// One invoice but should be first month (first PRAP)
			 )
			)
		   )
		{				
			// Need to create projected accounting records
			Decimal amount = currentInvoice.ADvendio__InvoicedAmountGrossN2__c;
			String standardAccount	= currentInvoice.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_IC : SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_INTERNET;

			if (amount != null && amount != 0) {
				Boolean isPureDL = currentInvoice.SomDig_Anzahl_Nonmedia_Positionen__c > 0 && currentInvoice.SomDig_Anzahl_Media_Positionen__c == 0;
				String creditAccountType = isPureDL
										 ? SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_DIENSTLEISTUNGEN
										 : standardAccount;
						
				Datetime dt = Datetime.newInstance(currentInvoice.ADvendio__InvoiceDate__c.year(),
													currentInvoice.ADvendio__InvoiceDate__c.month(),
													currentInvoice.ADvendio__InvoiceDate__c.day());

				SomDig_Buchungssatz__c bs = new SomDig_Buchungssatz__c();
																	
				bs.RecordTypeId = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_Buchungssatz__c', 'Hochrechnung');	
				bs.CurrencyIsoCode = currentInvoice.CurrencyIsoCode;
				bs.SomDig_Belegdatum__c = dt.format('ddMMyyyy');
				bs.SomDig_Belegkopftext__c = String.isNotEmpty(currentInvoice.ADvendio__OrderNumber__c)
											? currentInvoice.ADvendio__OrderNumber__c.subString(0, Math.min(currentInvoice.ADvendio__OrderNumber__c.length(), 25))
											: null;
				bs.SomDig_Buchungskreis__c = SomDig_Buchungssatz_EaBase.BUCHUNGSKREIS;
				bs.SomDig_Kostenstelle__c = null;
				bs.SomDig_Rechnung__c = currentInvoice.Id;
				bs.SomDig_Rechnungsposition__c = null;			
				bs.SomDig_Referenz__c = String.isNotEmpty(currentInvoice.ADvendio__OrderNumber__c)
										? currentInvoice.ADvendio__OrderNumber__c.subString(0, Math.min(currentInvoice.ADvendio__OrderNumber__c.length(), 16))
										: null;
				bs.SomDig_Steuerrelevanz__c = '0';
				bs.SomDig_Zuordnung__c = null;

				bs.SomDig_Verrechnungsmonat__c = accountingMonth;
				bs.SomDig_VerrechnungsmonatSAP__c = accountingMonthSAP;
				
				bs.SomDig_Betrag__c = Math.abs(amount).setScale(2).toPlainString().leftPad(14).replace(' ','0');
				bs.SomDig_Buchungstext__c = 'Hochrechnung PIs';
				bs.SomDig_Steuerkennzeichen__c = currentInvoice.SomDig_Steuerkennzeichen__c;
				bs.SomDig_Steuerrelevanz__c = 'AS'.equals(currentInvoice.SomDig_Steuerkennzeichen__c) ? '1' : '0';
					
	    		Integer groupIdx = 1;
				for (Integer i = 0; i < 2; i++) {
					SomDig_Buchungssatz__c tmpBS = bs.clone(false, true, false, false);

					tmpBS.Name  = currentMediaCampaign.Id + '-' + currentInvoice.Id + '-' + ADvendio__InvoiceItem__c.sObjectType.getDescribe().getKeyPrefix() + '-'
	    						+ (groupIdx * 1.0).setScale(0).toPlainString().leftPad(6).replace(' ','0') + '-'
	    						+ ((i+1) * 1.0).setScale(0).toPlainString().leftPad(6).replace(' ','0');
							
					if (i == 0) {
						if (amount > 0) {
							tmpBS.SomDig_Erloeskonto_Sachkonto__c = SomDig_Buchungssatz_EaBase.getSachkontoNummerByType(SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_FORDERUNG_HOCHRECHNUNG);
							tmpBS.SomDig_Soll_Haben_Kennzeichen__c = 'S';
							tmpBS.SomDig_Steuerkennzeichen__c = 'A0';
						} else {
							tmpBS.SomDig_Erloeskonto_Sachkonto__c = SomDig_Buchungssatz_EaBase.getSachkontoNummerByType(creditAccountType);
							tmpBS.SomDig_Innenauftragsnummer__c = SomDig_Buchungssatz_EaBase.getIaNummerByType(creditAccountType);
							tmpBS.SomDig_Soll_Haben_Kennzeichen__c = 'S';
						}
					} else if (i == 1) {
						if (amount > 0) {
							tmpBS.SomDig_Erloeskonto_Sachkonto__c = SomDig_Buchungssatz_EaBase.getSachkontoNummerByType(creditAccountType);
							tmpBS.SomDig_Innenauftragsnummer__c = SomDig_Buchungssatz_EaBase.getIaNummerByType(creditAccountType);
							tmpBS.SomDig_Soll_Haben_Kennzeichen__c = 'H';
						} else {
							tmpBS.SomDig_Erloeskonto_Sachkonto__c = SomDig_Buchungssatz_EaBase.getSachkontoNummerByType(SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_FORDERUNG_HOCHRECHNUNG);
							tmpBS.SomDig_Soll_Haben_Kennzeichen__c = 'H';
							tmpBS.SomDig_Steuerkennzeichen__c = 'A0';
						}
					}
									
					projectionAccountingRecords.add(tmpBS);
				}							
			}							
		}
		
		return projectionAccountingRecords;
	}

	/**
	 * Generate the HREF tag based on the given parameter.
	 *
	 * @param aMc	An ADvendio__MediaCampaign__c, whereby fields Id and Name are filled. Could be <code>null</code>.
	 * @param anInvoice	An ADvendio__Invoice__c, whereby fields Id and Name are filled. Could be <code>null</code>.
	 * @param anInvoiceItem	An ADvendio__InvoiceItem__c, whereby fields Id and Name are filled. Could be <code>null</code>.
	 * @return The generated string.
	 */
	private String createHtmlAnchorTag(ADvendio__MediaCampaign__c aMc, ADvendio__Invoice__c anInvoice, ADvendio__InvoiceItem__c anInvoiceItem) {
		String url = 'https://' + instanceName + '.salesforce.com/' +
					 (anInvoiceItem != null ? anInvoiceItem.Id : (anInvoice != null ? anInvoice.Id : (aMc != null ? aMc.Id : '')));
		
		String text = '';
		if (aMc != null) {
			text = aMc.Name.escapeHtml4();
		}
		if (anInvoice != null) {
			if (String.isNotEmpty(text)) {
				text += '&nbsp;&gt;&nbsp;';
			}
			text += anInvoice.Name.escapeHtml4();
		}
		if (anInvoiceItem != null) {
			if (String.isNotEmpty(text)) {
				text += '&nbsp;&gt;&nbsp;';
			}
			text += anInvoiceItem.Name.escapeHtml4();
		}
		
		return '<a href="' + url + '">' + text + '</a>';		
	}
}