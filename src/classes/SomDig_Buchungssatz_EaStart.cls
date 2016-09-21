/**
 * The control class for selecting MediaCampaign / Invoice / InvoicesItem for Revenue Distribution & Projection.
 */
public with sharing class SomDig_Buchungssatz_EaStart {
	/** Process type: Ultimo-5 */
	public static final String PROCESS_ULTIMO_MINUS_5 = SomDig_Buchungssatz_EaBase.PROCESS_ULTIMO_MINUS_5;
	
	/** Process type: Ultimo+4 */
	public static final String PROCESS_ULTIMO_PLUS_4 = SomDig_Buchungssatz_EaBase.PROCESS_ULTIMO_PLUS_4;
	
	/** Number of MediaCampaigns to show in a results-page. */
	public static final Integer MAX_NUMBER_MCS_PER_PAGE = 20;
	
	/** Options for process types used in the VF page. */
	public List<SelectOption> allProcessTypes { public get; private set; }
	
    /** Selected process type used in the VF page. */
    public String selectedProcessType { public get; public set; }

    /** Search performed flag used in the VF page. */
    public Boolean performedSearch { public get; public set; }

    /** Selection-Checkbox of the current results page in the VF page. */
    public Boolean pageSelected { public get; public set; }

	/** A dummy ADvendio__MediaCampaign__c, some fields are used for filter/settings in the VF page.
	 *    ADvendio__Close_Date__c: used as process running date which will be passed to the batch job.
	 *    ADvendio__Closed_Lost__c: used in VF page to enable / disable manuell changing process running date.
	 *    ADvendio__IsApproved__c: used in VF page to select / de-select the MediaCampaign for further processing.
	 *    ADvendio__Account__c: used as filter for searching the MediaCampaign
	 *    ADvendio__Agency__c: used as filter for searching the MediaCampaign
	 *    ADvendio__Campaign_Start_Date__c: used as filter for searching the MediaCampaign
	 *    ADvendio__Campaign_End_Date__c: used as filter for searching the MediaCampaign
	 */
	public ADvendio__MediaCampaign__c filterMediaCampaign { public get; private set; }
	
    /** Current MediaCampaigns used in the VF page. */
    public List<ADvendio__MediaCampaign__c> currentMediaCampaigns { public get; public set; }

	/** The results of found ADvendio__MediaCampaign__c with its ADvendio__InvoiceItem__c to process. */
	@TestVisible private Map<Id, Set<Id>> allMediaCampaignWithInvoiceItem = new Map<Id, Set<Id>>();
	
	/** The results of found ADvendio__MediaCampaign__c. */
	@TestVisible private List<ADvendio__MediaCampaign__c> allMediaCampaigns = new List<ADvendio__MediaCampaign__c>();
	
	/** The current page number. */
	private Integer totalPageNumber = 0;
	
	/** The current page number. */
	private Integer currentPageNumber = 0;
	
	/** The Selection-Checkbox status of all results pages. */
	private List<Boolean> allPagesSelection = new List<Boolean>();
	
	/**
	 * Construnctor
	 */
	public SomDig_Buchungssatz_EaStart() {
		allProcessTypes = new List<SelectOption>();
        
		allProcessTypes.add(new SelectOption(PROCESS_ULTIMO_MINUS_5, PROCESS_ULTIMO_MINUS_5));
		allProcessTypes.add(new SelectOption(PROCESS_ULTIMO_PLUS_4, PROCESS_ULTIMO_PLUS_4));
		
		selectedProcessType = allProcessTypes.get(0).getValue();
		
		performedSearch = false;
		
		pageSelected = false;

		filterMediaCampaign = new ADvendio__MediaCampaign__c(ADvendio__Close_Date__c=System.today(), ADvendio__Closed_Lost__c=false, ADvendio__IsApproved__c=true);
		
		currentMediaCampaigns = new List<ADvendio__MediaCampaign__c>();
	}

	/**
	 * Reset.
     *
     * @return	A PageReference object. The value will always be null.
	 */	
    public PageReference reset() {
    	currentMediaCampaigns.clear();
    	allMediaCampaignWithInvoiceItem.clear();
    	allMediaCampaigns.clear();
    	totalPageNumber = 0;
    	currentPageNumber = 0;
    	allPagesSelection.clear();
    	
    	performedSearch = false;
    	pageSelected = false;
    	   	
    	return null;
    }

	/**
	 * Change the process running date.
     *
     * @return	A PageReference object. The value will always be null.
	 */	
    public PageReference changeProcessRunningDate() {
    	if (!filterMediaCampaign.ADvendio__Closed_Lost__c) {
    		filterMediaCampaign.ADvendio__Close_Date__c = System.today();
    	}
    	
    	reset();
    	
    	return null;
    }

	/**
	 * Toggle the selection of MediaCampaigns in current page.
     *
     * @return	A PageReference object. The value will always be null.
	 */	
    public PageReference toggleSelection() {
    	/*
    	if (currentPageNumber > 0 && currentPageNumber <= totalPageNumber && currentPageNumber <= allPagesSelection.size()) {
    		allPagesSelection[currentPageNumber - 1] = pageSelected;
    	}
		for (ADvendio__MediaCampaign__c mc : currentMediaCampaigns) {
			mc.ADvendio__IsApproved__c = pageSelected;
		}
		*/

		allPagesSelection.clear();
		for (Integer i = 0; i< totalPageNumber; i++) {
			allPagesSelection.add(pageSelected);
		}
		for (ADvendio__MediaCampaign__c mc : allMediaCampaigns) {
			mc.ADvendio__IsApproved__c = pageSelected;
		}

		return null;
    }

	/**
     * Search the MediaCampaigns being processed.
     *
     * @return	A PageReference object. The value will always be null.
     */
    public PageReference doSearch() {
    	reset();
    	
    	try {
			Map<Id, ADvendio__MediaCampaign__c> mMediaCampaigns = new Map<Id, ADvendio__MediaCampaign__c>();

			SomDig_Buchungssatz_EaBatch	batchClass = new SomDig_Buchungssatz_EaBatch(selectedProcessType, filterMediaCampaign.ADvendio__Close_Date__c);
	    	
	    	String queryStr = batchClass.getQueryString();

			Id accountId = filterMediaCampaign.ADvendio__Account__c;
			Id agencyId = filterMediaCampaign.ADvendio__Agency__c;
	    	Date startDate = filterMediaCampaign.ADvendio__Campaign_Start_Date__c;
	    	Date endDate = filterMediaCampaign.ADvendio__Campaign_End_Date__c;
	    	if (accountId != null) {
	    		queryStr += ' AND ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Account__c = :accountId ';
	    	}
	    	if (agencyId != null) {
	    		queryStr += ' AND ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Agency__c = :agencyId ';
	    	}
	    	if (startDate != null) {
	    		queryStr += ' AND ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Campaign_Start_Date__c >= :startDate ';
	    	}
	    	if (endDate != null) {
	    		queryStr += ' AND ADvendio__Invoice__r.ADvendio__MediaCampaign__r.ADvendio__Campaign_End_Date__c <= :endDate ';
	    	}

			queryStr += 'ORDER BY ADvendio__Invoice__c';
			
			//System.debug('\n\n' + queryStr + '\n');
			
			List<ADvendio__InvoiceItem__c> invoiceItems = Database.query(queryStr);

			// Using the query, some cases are not covered:
			//   1: Once an invoice is "Canceled", a cancellation invoice will be created for it.
			//      For the case if there is no SomDig_Buchungssatz__c was created for the cancelled invoice,
			//      the cancellation invoice should be ignored.
			//   2: The PRAP invoice items need to be checked. 

			// Following code will prepare data for checking such cases.
			
			// Get all original invoices and campaign items of cancellation items
			// Get all PRAP items			
			Set<Id> origCiIds = new Set<Id>();
			Set<Id> origInvoiceIds = new Set<Id>();
			Set<Id> prapInvoiceItemIds = new Set<Id>();
			Set<Id> prapCalcellationInvoiceItemIds = new Set<Id>();
			for (ADvendio__InvoiceItem__c invoiceItem : invoiceItems) {
				if (isCancellationInvoiceItem(invoiceItem)) {
					// Cancellation
					origCiIds.add(invoiceItem.ADvendio__CampaignItem__r.ADvendio__ConnectedItem__c != null
									? invoiceItem.ADvendio__CampaignItem__r.ADvendio__ConnectedItem__c
									: invoiceItem.ADvendio__CampaignItem__c);
					origInvoiceIds.add(invoiceItem.ADvendio__Invoice__r.ADvendio__Invoice__c);
					System.debug('\n\nCancellation-InvoiceItemId: ' + invoiceItem.Id + '\n');
				}
				if (isPrapInvoiceItem(invoiceItem)) {
					if (isCancellationInvoiceItem(invoiceItem)) {
						prapCalcellationInvoiceItemIds.add(invoiceItem.Id);
					} else {
						prapInvoiceItemIds.add(invoiceItem.Id);
					}
					System.debug('\n\nPRAP-InvoiceItemId: ' + invoiceItem.Id + '\n');
				}
			}
			
			// Find now original invoice items of cancellation items
			Set<Id> origInvoiceItemIds = new Set<Id>();
			Map<String, Set<Id>> origCiInvoice2InvoiceItems = new Map<String, Set<Id>>();
			if (!origCiIds.isEmpty() && !origInvoiceIds.isEmpty()) {
				for (ADvendio__InvoiceItem__c invoiceItem : [SELECT Id, ADvendio__Invoice__c, ADvendio__CampaignItem__c FROM ADvendio__InvoiceItem__c
															 WHERE ADvendio__Invoice__c IN :origInvoiceIds AND ADvendio__CampaignItem__c IN :origCiIds])
				{
					origInvoiceItemIds.add(invoiceItem.Id);
					String key = '' + invoiceItem.ADvendio__CampaignItem__c + invoiceItem.ADvendio__Invoice__c;
					Set<Id> tmpInvoiceItemIds = origCiInvoice2InvoiceItems.get(key);
					if (tmpInvoiceItemIds == null) {
						tmpInvoiceItemIds = new Set<Id>();
						origCiInvoice2InvoiceItems.put(key, tmpInvoiceItemIds);
					}
					tmpInvoiceItemIds.add(invoiceItem.Id);
					System.debug('\n\nOriginal-InvoiceItemId: ' + invoiceItem.Id + '\n');
				}	
			}
			
			// Find now original invoice items with SomDig_Buchungssatz__c
			Set<Id> origInvoiceItemWithBS = new Set<Id>();
			if (!origInvoiceItemIds.isEmpty()) {
				Id recordTypeIdEA = null;
				Id recordTypeIdHR = null;
 
				if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
					recordTypeIdHR = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_Buchungssatz__c', 'Hochrechnung');
					recordTypeIdEA = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_Buchungssatz__c', 'Erloesaufteilung');
    			} else if (PROCESS_ULTIMO_PLUS_4.equals(selectedProcessType)) {
					recordTypeIdEA = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_Buchungssatz__c', 'Erloesaufteilung');
   				}
   				
   				String qs = 'SELECT SomDig_Rechnungsposition__c invoiceItemId ' +
							'FROM SomDig_Buchungssatz__c ' +
							'WHERE SomDig_Rechnungsposition__c IN :origInvoiceItemIds AND ' +
							(PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType) ? '(RecordTypeId = :recordTypeIdEA OR RecordTypeId = :recordTypeIdHR )'  : 'RecordTypeId = :recordTypeIdEA ') +
							'GROUP BY SomDig_Rechnungsposition__c ';
   				
				for (AggregateResult ar : Database.query(qs)) {
   					origInvoiceItemWithBS.add(((Id)(ar.get('invoiceItemId'))));
					System.debug('\n\nFound Buchungssatz of Original-InvoiceItemId: ' + ar.get('invoiceItemId') + '\n');
   				}
 			}
			
			// Find now PRAP invoice items with SomDig_Buchungssatz__c, 
			Set<Id> prapOfInvoiceItemWithBS = new Set<Id>();
	    	if (!prapInvoiceItemIds.isEmpty() || !prapCalcellationInvoiceItemIds.isEmpty()) {
				String accountingMonthSAP = batchClass.getAccountingMonthSAP();
				Id recordTypeId = null;
 
				if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
					recordTypeId = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_Buchungssatz__c', 'Hochrechnung');
    			} else if (PROCESS_ULTIMO_PLUS_4.equals(selectedProcessType)) {
					recordTypeId = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_Buchungssatz__c', 'Erloesaufteilung');
   				}
   				
   				String qs = 'SELECT SomDig_Rechnungsposition__c invoiceItemId ' +
							'FROM SomDig_Buchungssatz__c ' +
							'WHERE RecordTypeId = :recordTypeId ' +
									'AND ((SomDig_Rechnungsposition__c IN :prapInvoiceItemIds AND SomDig_VerrechnungsmonatSAP__c = :accountingMonthSAP) OR ' +
										 '(SomDig_Rechnungsposition__c IN :prapCalcellationInvoiceItemIds)) ' +
							'GROUP BY SomDig_Rechnungsposition__c ';
   				
				for (AggregateResult ar : Database.query(qs)) {
   					prapOfInvoiceItemWithBS.add(((Id)(ar.get('invoiceItemId'))));
					System.debug('\n\nFound Buchungssatz of PRAP-InvoiceItemId: ' + ar.get('invoiceItemId') + '\n');
   				}	    		
	    	}
	    	
	    	// Find the PRAPs, validate them
			Set<Id> prapOfInvoiceItemValidated = new Set<Id>();
	    	if (!prapInvoiceItemIds.isEmpty()) {
	    		Map<Id, List<SomDig_PRAP__c>> prapOfInvoiceItems = new Map<Id, List<SomDig_PRAP__c>>();
				for (SomDig_PRAP__c aPrap : [SELECT Id, SomDig_Rechnungsposition__c, SomDig_Abrechnungsmonat__c, SomDig_Abrechnungsmonatsende__c, SomDig_NochAbzugrenzendeErloese__c
											 FROM SomDig_PRAP__c
											 WHERE SomDig_Rechnungsposition__c IN :prapInvoiceItemIds AND SomDig_Status__c = 'Aufgelöst'
											 ORDER BY SomDig_Rechnungsposition__c, SomDig_Abrechnungsmonat__c DESC])
				{
					List<SomDig_PRAP__c> praps = prapOfInvoiceItems.get(aPrap.SomDig_Rechnungsposition__c);
					if (praps == null) {
						praps = new List<SomDig_PRAP__c>();
						prapOfInvoiceItems.put(aPrap.SomDig_Rechnungsposition__c, praps);
					}
					praps.add(aPrap);
				}
				
				Date processAccountingStartDate = null;
	
		    	if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
					processAccountingStartDate = filterMediaCampaign.ADvendio__Close_Date__c.toStartOfMonth();
		    	} else if (PROCESS_ULTIMO_PLUS_4.equals(selectedProcessType)) {
					processAccountingStartDate = filterMediaCampaign.ADvendio__Close_Date__c.addMonths(-1).toStartOfMonth();
		    	}

				for (ADvendio__InvoiceItem__c invoiceItem : invoiceItems) {
					if (prapInvoiceItemIds.contains(invoiceItem.Id)) {
						List<SomDig_PRAP__c> praps = prapOfInvoiceItems.get(invoiceItem.Id);
						if (praps == null) {
							// OK
							prapOfInvoiceItemValidated.add(invoiceItem.Id);
						} else {
							// The list is sorted by SomDig_Abrechnungsmonat__c DESC
							Date itemAccountingPeriodEndDate = invoiceItem.ADvendio__InvoiceItemEndDate__c.toStartOfMonth().addMonths(1).addDays(-1);
							for (SomDig_PRAP__c aPrap : praps) {
								if (aPrap.SomDig_Abrechnungsmonatsende__c < processAccountingStartDate &&
									aPrap.SomDig_Abrechnungsmonatsende__c < itemAccountingPeriodEndDate &&
									aPrap.SomDig_NochAbzugrenzendeErloese__c > 0)
								{
									// OK
									prapOfInvoiceItemValidated.add(invoiceItem.Id);
								}
								break;									
							}
						}
					}
				}
	    	}	    	 
			
			// Now go through all found invoice items, and filter those if not expected.

	    	Schema.SObjectField invoiceField = ADvendio__InvoiceItem__c.ADvendio__Invoice__c.getDescribe().getSobjectField();
	    	Schema.SObjectField mcField = ADvendio__Invoice__c.ADvendio__MediaCampaign__c.getDescribe().getSobjectField();
	    	
			for (ADvendio__InvoiceItem__c invoiceItem : invoiceItems) {
	    		Id mcId = invoiceItem.ADvendio__Invoice__r.ADvendio__MediaCampaign__c;
	    		
	    		if (mcId == null) {
	    			continue;
	    		}
	    		
	    		// Check cancelation invoiceItem 
				if (isCancellationInvoiceItem(invoiceItem)) {
					Boolean originalHasBS = false;
					
					Id origCiId = invoiceItem.ADvendio__CampaignItem__r.ADvendio__ConnectedItem__c != null
								? invoiceItem.ADvendio__CampaignItem__r.ADvendio__ConnectedItem__c
								: invoiceItem.ADvendio__CampaignItem__c;
					
					Id origInvoiceId = invoiceItem.ADvendio__Invoice__r.ADvendio__Invoice__c;
					
					String key = '' + origCiId + origInvoiceId;
					Set<Id> tmpInvoiceItemIds = origCiInvoice2InvoiceItems.get(key);
					if (tmpInvoiceItemIds != null) {
						for (Id anInvoiceItemId : tmpInvoiceItemIds) {
							if (!origInvoiceItemWithBS.isEmpty() && origInvoiceItemWithBS.contains(anInvoiceItemId)) {
								originalHasBS = true;
								break;
							}
						}
					}
					
					if (!originalHasBS) {
						// No BS for original invoiceItem, so this invoiceItem is to ignore.
						System.debug('\n\nNo Buchungssatz found for Original-InvoiceItem, thus ignored the Cancellation-InvoiceItemId ' + invoiceItem.Id + '\n');
   						continue;
					}
				}

	    		// Check PRAP invoiceItem 
				if (isPrapInvoiceItem(invoiceItem)) {
					if (!prapOfInvoiceItemWithBS.isEmpty() && prapOfInvoiceItemWithBS.contains(invoiceItem.Id)) {
						System.debug('\n\nBuchungssatz found, thus ignored the PRAP-InvoiceItemId ' + invoiceItem.Id + '\n');
						continue;
					} else if (!isCancellationInvoiceItem(invoiceItem) && !prapOfInvoiceItemValidated.isEmpty() && !prapOfInvoiceItemValidated.contains(invoiceItem.Id)) {
						System.debug('\n\nValidate failed, thus ignored the PRAP-InvoiceItemId ' + invoiceItem.Id + '\n');
						continue;
					}
				}
	    		
	    		// Save the invoiceItem.
	    		Set<Id> invoiceItemIds = allMediaCampaignWithInvoiceItem.get(mcId);
	    		if (invoiceItemIds == null) {
	    			invoiceItemIds = new Set<Id>();
	    			allMediaCampaignWithInvoiceItem.put(mcId, invoiceItemIds);
	    		}
	    		invoiceItemIds.add(invoiceItem.Id);
	    		
	    		// Save the MediaCampaign
	    		if (!mMediaCampaigns.containsKey(mcId)) {
		    		ADvendio__MediaCampaign__c mc = (ADvendio__MediaCampaign__c)invoiceItem.getSObject(invoiceField).getSObject(mcField);
		    		if (mc != null) {
		    			// We use / abuse the field ADvendio__IsApproved__c for select / de-select the MC for processing.
		    			mc.ADvendio__IsApproved__c = filterMediaCampaign.ADvendio__IsApproved__c;
		    			mMediaCampaigns.put(mcId, mc);
		    		}
	    		}	    		
	    	}
	    	
	    	performedSearch = true;
	    	
	    	if (!mMediaCampaigns.isEmpty()) {
	    		allMediaCampaigns = mMediaCampaigns.values();
	    		allMediaCampaigns.sort();

				initPagination();
	    	}
   	} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	}
    	
    	return null;
    }
	
	/**
	 * Start the batch job.
     *
     * @return	A PageReference object. The value will always be null.
	 */	
    public PageReference runProcess() {
    	if (allMediaCampaigns.isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Keine Mediakampagne gefunden.'));
			return null;
    	}

		for (AsyncApexJob job: [SELECT Id, Status FROM AsyncApexJob
								WHERE ApexClass.Name = 'SomDig_Buchungssatz_EaBatch' AND
									  (Status = 'Queued' OR Status = 'Preparing' OR Status = 'Processing')])
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ein ' + PROCESS_ULTIMO_MINUS_5 + ' oder ' + PROCESS_ULTIMO_PLUS_4 + ' Prozess läuft gerade!'));
			return null;
		}
		
		Set<Id> mcIds = new Set<Id>();
		for (ADvendio__MediaCampaign__c mc : allMediaCampaigns) {
			if (mc.ADvendio__IsApproved__c) {
				mcIds.add(mc.Id);
			}
		}
		
		Set<Id> invoiceItemIds = new Set<Id>();
		for (Id mcId : mcIds) {
			if (allMediaCampaignWithInvoiceItem.containsKey(mcId)) {
				invoiceItemIds.addAll(allMediaCampaignWithInvoiceItem.get(mcId));
			}
		}
		
		if (!invoiceItemIds.isEmpty()) {
	    	SomDig_Buchungssatz_EaBatch	batchClass = new SomDig_Buchungssatz_EaBatch(selectedProcessType, filterMediaCampaign.ADvendio__Close_Date__c);
	    	batchClass.setInvoiceItemIds(invoiceItemIds);
	    	
	    	Id jobId = Database.executeBatch(batchClass, 1);
	    	
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
														'Ein Prozess mit der ID ' + jobId + 
														' ist im Hintergrund gestartet. Sie werden per Email benachrichtigt wenn der Prozess beendet ist.'));
	    	
			filterMediaCampaign = new ADvendio__MediaCampaign__c(ADvendio__Close_Date__c=System.today(), ADvendio__Closed_Lost__c=false, ADvendio__IsApproved__c=true);		
	
	    	reset();
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Keine Mediakampagne ausgewählt.'));
		}

    	return null;
    }
    
    /**
     * Indicates whether there is any record found.
     *
     * @return	True if there is record found, false otherwise.
     */
    public Boolean getHasResult() {
        return totalPageNumber > 0;
    }

    /**
     * Indicates whether there are more records after the current page set.
     *
     * @return	True if there is record, false otherwise.
     */
    public Boolean getHasNext() {
        return currentPageNumber < totalPageNumber;
    }

    /**
     * Indicates whether there are more records before the current page set.
     *
     * @return	True if there is record, false otherwise.
     */
    public Boolean getHasPrevious() {
        return currentPageNumber > 1;
    }

    /**
     * Returns the page number of the current page set
     *
     * @return	Current page number, starting with 1.
     */
    public Integer getPageNumber() {
        return currentPageNumber;
    }

    /**
     * Returns the total page numbers of set
     *
     * @return	Total page numbers.
     */
    public Integer getTotalPages() {
		return totalPageNumber;
    }

    /**
     * Goes to the first page of records
     */
    public void first() {
    	if (currentPageNumber != 1) {
	    	currentPageNumber = 1;
	    	createPageRecords();
    	}
    }

    /**
     * Goes to the last page of records
     */
    public void last() {
    	if (currentPageNumber != totalPageNumber) {
	    	currentPageNumber = totalPageNumber;
	    	createPageRecords();
    	}
    }

    /**
     * Goes to the previous page of records
     */
    public void previous() {
    	if (currentPageNumber > 1) {
    		currentPageNumber--;
    		createPageRecords();
    	}
    }

    /**
     * Goes to the next page of records
     */
    public void next() {
    	if (currentPageNumber < totalPageNumber) {
    		currentPageNumber++;
    		createPageRecords();
    	}
    }
    
	/**
	 * Check whether an invoice item is a cancelllation item.
	 *
	 * @param invoiceItem The invoice item to check.
	 * @return True if invoice item is a cancelllation item, false otherwise
	 */
	private Boolean isCancellationInvoiceItem(ADvendio__InvoiceItem__c invoiceItem) {
		if (invoiceItem.ADvendio__InvoicedAmountNet2__c < 0 && invoiceItem.ADvendio__Invoice__r.ADvendio__Invoice__c != null) {
			return true;
		}
	
		return false;		
	}

	/**
	 * Check whether an invoice item requires PRAP.
	 *
	 * @param invoiceItem The invoice item to check.
	 * @return True if invoice item requires PRAP, false otherwise
	 */
	private Boolean isPrapInvoiceItem(ADvendio__InvoiceItem__c invoiceItem) {
		if ('total account (one Invoice)'.equals(invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentInterval__c) &&
			'before / during Billingperiod'.equals(invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentStart__c) &&
			(invoiceItem.ADvendio__Invoice__r.ADvendio__AccountingDate__c.year() != invoiceItem.ADvendio__Invoice__r.ADvendio__AccountingEndDate__c.year() ||
			 invoiceItem.ADvendio__Invoice__r.ADvendio__AccountingDate__c.month() != invoiceItem.ADvendio__Invoice__r.ADvendio__AccountingEndDate__c.month()))
		{
			return true;
		}
	
		return false;		
	}

    /**
     * Init pagination
     */
	@TestVisible private void initPagination() {
		Integer totalPages = allMediaCampaigns.size() / MAX_NUMBER_MCS_PER_PAGE;
		Integer remainder = Math.mod(allMediaCampaigns.size(), MAX_NUMBER_MCS_PER_PAGE);

		totalPageNumber = remainder == 0 ? totalPages : (totalPages+1);
		currentPageNumber = 1;
		
		allPagesSelection.clear();
		for (Integer i = 0; i< totalPageNumber; i++) {
			allPagesSelection.add(true);
		}
				
		createPageRecords();
	}
	
    /**
     * Create pagination records
     */
	private void createPageRecords() {
		currentMediaCampaigns.clear();
		
		Integer fromPosition = currentPageNumber > 1 ? (currentPageNumber - 1) * MAX_NUMBER_MCS_PER_PAGE : 0;
		Integer toPosition = Math.min(fromPosition + MAX_NUMBER_MCS_PER_PAGE, allMediaCampaigns.size());
		
		for (Integer i = fromPosition; i < toPosition; i++) {
			currentMediaCampaigns.add(allMediaCampaigns.get(i));
		}
		
		if (currentPageNumber > 0 && currentPageNumber <= totalPageNumber && currentPageNumber <= allPagesSelection.size()) {
    		pageSelected = allPagesSelection[currentPageNumber - 1];
    	}
	}
}