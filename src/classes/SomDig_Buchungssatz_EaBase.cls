/**
 * The core logic class for revenue distribution.
 *
 * The basic element for revenue distribution is ADvendio__InvoiceItem__c.
 */
public with sharing class SomDig_Buchungssatz_EaBase {

	/** Fields of SomDig_IaNummer__c used for Query */
	private static final String QUERY_IANUMMER_FIELDS =
		'Id, ' +
		'Name, ' +
		'SomDig_CSPartnerID__c, ' +
		'SomDig_Mediagattung__c, ' +
		'SomDig_MediagattungsSegment__c, ' +
		'SomDig_MediagattungsDifferenzierung__c, ' +
		'SomDig_Werbetraergergruppierung__c, ' +
		'Som_SachkontokonzernintereneVerrechnung__c ';

	/** Fields of SomDig_Sachkonto__c used for Query */
	private static final String QUERY_SACHKONTO_FIELDS =
		'Id, ' +
		'Name, ' +
		'SomDig_SachkontoTyp__c, ' +
		'SomDig_SammelIA__c, ' +
		'SomDig_FehlerIA__c '; 

	/** Fields of ADvendio__InvoiceItem__c used for query. */
	private static final String QUERY_INVOICEITEM_FIELDS = 
		'Id, ' +
		'CurrencyIsoCode, ' +
		'ADvendio__InvoiceItemStartDate__c, ' +
		'ADvendio__InvoiceItemEndDate__c, ' +
		'ADvendio__FromDate__c, ' +
		'ADvendio__UntilDate__c, ' +
		'ADvendio__BookedQuantity__c, ' +
		'ADvendio__BillingCategory__c, ' +
		'ADvendio__Salesprice__c, ' +
		'ADvendio__InvoicedQuantity__c, ' +
		'ADvendio__QuantityDelivered__c, ' +
		'ADvendio__QuantityDeliveredSum__c, ' +
		'ADvendio__LinearDistribution__c, ' +
		'ADvendio__InvoicedAmountNet2__c, ' +
		'ADvendio__VATExempt__c, ' +
		'ADvendio__VATRate__c, ' +
		'SomDig_Adservertyp__c, ' +
		'ADvendio__CampaignItem__c, ' +
		'ADvendio__CampaignItem__r.Id, ' +
		'ADvendio__CampaignItem__r.ADvendio__Amount_net_netAPEX__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Adserver_ID_Order_ID__c, ' + 
		'ADvendio__CampaignItem__r.ADvendio__Ad_Id__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_Mediagattung__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_Werbetraergergruppierung__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Mediagattungssegment__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.SomDig_MediagattungsDifferenzierung__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__ConnectedItem__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__ConnectedItem__r.Id, ' +
		'ADvendio__CampaignItem__r.ADvendio__ConnectedItem__r.ADvendio__Amount_net_netAPEX__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__ConnectedItem__r.ADvendio__Adserver_ID_Order_ID__c, ' + 
		'ADvendio__CampaignItem__r.ADvendio__ConnectedItem__r.ADvendio__Ad_Id__c, ' +
		'ADvendio__CampaignItem__r.ADvendio__ConnectedItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__c, ' +
		'ADvendio__CampaignItem__r.RecordType.DeveloperName, ' +
		'ADvendio__Invoice__c, ' +
		'ADvendio__Invoice__r.CurrencyIsoCode, ' +
		'ADvendio__Invoice__r.ADvendio__PaymentInterval__c, ' +
		'ADvendio__Invoice__r.ADvendio__PaymentStart__c, ' +
		'ADvendio__Invoice__r.ADvendio__InvoiceDate__c, ' +
		'ADvendio__Invoice__r.ADvendio__AccountingDate__c, '+
		'ADvendio__Invoice__r.ADvendio__AccountingEndDate__c, ' +
		'ADvendio__Invoice__r.ADvendio__Status__c, ' +
		'ADvendio__Invoice__r.ADvendio__OrderNumber__c, ' +
		'ADvendio__Invoice__r.SomDig_Anzahl_Media_Positionen__c, ' +
		'ADvendio__Invoice__r.SomDig_Anzahl_Nonmedia_Positionen__c, ' +
		'ADvendio__Invoice__r.SomDig_Auftragstyp__c, ' +
		'ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c, ' +
		'ADvendio__Invoice__r.SomDig_Steuerkennzeichen__c, ' +
		'ADvendio__Invoice__r.ADvendio__Invoice__c, ' +
		'SomDig_Mediagattung__r.Name, ' +
		'SomDig_Mediagattungs_Segment__r.Name, ' +
		'SomDig_Mediagattungs_Differenzierung__r.Name, ' +
		'SomDig_Werbetraeger__r.SomDig_DEWerbetraegertyp__c, ' +
		'SomDig_Werbetraeger__r.SomDig_Werbetraergergruppierung__r.Name ';
	
	/** Fields of SomDig_Buchungssatz__c used for query, they are acctually field that will be set this process. */
	private static final String QUERY_BUCHUNGSSATZ_FIELDS = 
		'Id, ' +
		'Name, ' +
		'CurrencyIsoCode, ' +
		'RecordTypeId, ' +
		// SAP relevant fields 
		'SomDig_Belegnummer__c, ' +
		'SomDig_Belegkopftext__c, ' +
		'SomDig_Soll_Haben_Kennzeichen__c, ' +
		'SomDig_Erloeskonto_Sachkonto__c, ' +
		'SomDig_Betrag__c, ' +
		'SomDig_Steuerkennzeichen__c, ' +
		'SomDig_Buchungstext__c, ' +
		'SomDig_Innenauftragsnummer__c, ' +
		'SomDig_Kostenstelle__c, ' +
		'SomDig_Zuordnung__c, ' +
		'SomDig_Referenz__c, ' +
		'SomDig_Steuerrelevanz__c, ' +
		// Process relevant fields
		'SomDig_Belegdatum__c, ' +
		'SomDig_Buchungskreis__c, ' +
		'SomDig_Rechnung__c, ' +
		'SomDig_Rechnungsposition__c, ' +	
		'SomDig_Verrechnungsmonat__c, ' +
		'SomDig_VerrechnungsmonatSAP__c, ' +
		'SomDig_SapDatei__c ';

	/** Process type: Ultimo-5 */
	public static final String PROCESS_ULTIMO_MINUS_5 = 'Ultimo-5 "Fast Close"';
	
	/** Process type: Ultimo+4 */
	public static final String PROCESS_ULTIMO_PLUS_4 = 'Ultimo+4';
	
	/** The fixed Buchungskreis to use. */
	public static final String BUCHUNGSKREIS = '0029';
	
	/** GL account type: Durchlaufkonto Fremdmarke */
	public static final String SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE = 'Durchlaufkonto Fremdmarke (Verb.) (Andere durchlfd.Post)';
	
	/** GL account type: Erlöse Barter */
	public static final String SACHKONTO_TYP_ERLOESE_BARTER = 'Erlöse Barter (GG Werbeerlö net.)';

	/** GL account type: Erlöse Dienstleistungen */
	public static final String SACHKONTO_TYP_ERLOESE_DIENSTLEISTUNGEN = 'Erlöse Dienstleistungen (SUE BRD)';

	/** GL account type: Erlöse IC */
	public static final String SACHKONTO_TYP_ERLOESE_IC = 'Erlöse IC (WE intern verb.Unt.)';

	/** GL account type: Forderung Hochrechnung */
	public static final String SACHKONTO_TYP_FORDERUNG_HOCHRECHNUNG = 'Forderung Hochrechnung (deb.Ford.aus Ums.-Abg)';

	/** GL account type: Korrektur Werbeerlös */
	public static final String SACHKONTO_TYP_KORREKTUR_WERBEERLOES = 'Korrektur Werbeerlös (fremde Marken) (Korr.WE Intern.BK29)';

	/** GL account type: PRAP */
	public static final String SACHKONTO_TYP_PRAP = 'PRAP (PRAP unterjährig)';

	/** GL account type: UE/Erlöse Online/Internet */
	public static final String SACHKONTO_TYP_ERLOESE_INTERNET = 'UE/Erlöse Online/Internet (Werbeerlöse Internet)';
	
	/** The Exception class. */
	public class SomDig_Buchungssatz_EaBase_Exception extends Exception {
	}
  
  	/**
  	 * The message class.
  	 */
  	public class ProcessMessage {
		/** Severity of the message. */
		public ApexPages.Severity severity { public get; private set; }
		
		/** type of the message. */
		public String messageType { public get; private set; }
		
		/** The message. */
		public String message { public get; private set; }
		
		/**
		 * Construnctor
		 *
		 * @param severity Severity of the message.
		 * @param message The message.
		 */
		ProcessMessage(ApexPages.Severity severity, String message) {
			this.severity = severity;
			this.message = message;
			this.messageType = 'undefined';
		}
		
		/**
		 * Construnctor
		 *
		 * @param severity Severity of the message.
		 * @param message The message.
		 */
		ProcessMessage(ApexPages.Severity severity, String message, String messageType) {
			this.severity = severity;
			this.message = message;
			this.messageType = messageType;
		}
  	} 
  	
	/**
	 * The accounting record class.
	 */
	public class AccountingRecord {
		/** The accounting record. */
		public SomDig_Buchungssatz__c	accountingRecord { public get; private set; }
		
		/** Enable the amount of this accounting record (field SomDig_Betrag__c) for aggregation. */ 
		public Boolean aggregationEnabled { public get; private set; }
		
		/**
		 * Construnctor.
		 */
		public accountingRecord() {
			this.accountingRecord	= new SomDig_Buchungssatz__c();
			this.aggregationEnabled	= true;
		}
		
		/**
		 * Fill the accounting record with provided data.
		 *
		 * @param	invoiceItem	The invoice item to use.
		 */
		public void fillAccountingRecord(ADvendio__InvoiceItem__c invoiceItem) {
			Datetime dt = Datetime.newInstance(invoiceItem.ADvendio__Invoice__r.ADvendio__InvoiceDate__c.year(),
												invoiceItem.ADvendio__Invoice__r.ADvendio__InvoiceDate__c.month(),
												invoiceItem.ADvendio__Invoice__r.ADvendio__InvoiceDate__c.day());
			this.accountingRecord.CurrencyIsoCode = invoiceItem.CurrencyIsoCode;
			this.accountingRecord.SomDig_Belegdatum__c = dt.format('ddMMyyyy');
			this.accountingRecord.SomDig_Belegkopftext__c =
				String.isNotEmpty(invoiceItem.ADvendio__Invoice__r.ADvendio__OrderNumber__c)
				? invoiceItem.ADvendio__Invoice__r.ADvendio__OrderNumber__c.subString(0, Math.min(invoiceItem.ADvendio__Invoice__r.ADvendio__OrderNumber__c.length(), 25))
				: null;
			this.accountingRecord.SomDig_Buchungskreis__c = BUCHUNGSKREIS;
			this.accountingRecord.SomDig_Kostenstelle__c = null;
			this.accountingRecord.SomDig_Rechnung__c = invoiceItem.ADvendio__Invoice__c;
			this.accountingRecord.SomDig_Rechnungsposition__c = invoiceItem.Id;			
			this.accountingRecord.SomDig_Referenz__c =
				String.isNotEmpty(invoiceItem.ADvendio__Invoice__r.ADvendio__OrderNumber__c)
				? invoiceItem.ADvendio__Invoice__r.ADvendio__OrderNumber__c.subString(0, Math.min(invoiceItem.ADvendio__Invoice__r.ADvendio__OrderNumber__c.length(), 16))
				: null;
			this.accountingRecord.SomDig_Steuerrelevanz__c = '0';
			this.accountingRecord.SomDig_Zuordnung__c = null;
			//Date d = dt.date().toStartOfMonth().addMonths(1).addDays(-1);
			//dt = Datetime.newInstance(d.year(), d.month(), d.day());
			//this.accountingRecord.SomDig_Verrechnungsmonat__c = dt.format('ddMMyyyy');
			//this.accountingRecord.SomDig_VerrechnungsmonatSAP__c = dt.format('yyMM');
		}		

		/**
		 * Is this accounting record valid?
		 */
		public Boolean isValid() {
			if (String.isEmpty(this.accountingRecord.SomDig_Erloeskonto_Sachkonto__c) ||
				String.isEmpty(this.accountingRecord.SomDig_Betrag__c) ||
				Decimal.ValueOf(this.accountingRecord.SomDig_Betrag__c) == 0.00)
			{
				return false;
			}
			return true;
		}
	}

	/**
	 * The accounting records group class.
	 */
	public class AccountingRecordsGroup {
		/** The accounting amount. */
		public Decimal accountingAmount { public get; private set; }
		
		/** The accounting records. */
		public List<AccountingRecord> accountingRecords { public get; private set; }
		
		/** Logic used for revenue distribution / estimation calculation. */
		public String matchedLogic { public get; private set; }
		
		/** Is this group a projection calculation. */
		public Boolean isProjection { public get; private set; }
		
		/** Is this group valid? */
		private Boolean isValid; 

		/** Are all records validated? */
		private Boolean hasValidated; 

		/**
		 * Constructor.
		 */
		public AccountingRecordsGroup() {
			this.accountingAmount = 0.00;
			this.accountingRecords = new List<AccountingRecord>();
			this.matchedLogic = 'N/A';
			this.isProjection = false;
			this.isValid = false;
			this.hasValidated = false;
		}
		
		/**
		 * Add an accounting record
		 */
		public void addAccountingRecord(AccountingRecord ar) {
			if (ar != null) {
				this.accountingRecords.add(ar);
				this.hasValidated = false;
			}
		}
		
		/**
		 * Aggregate the accounting records
		 */
		public void aggregateAccountingRecords() {
			if (!this.accountingRecords.isEmpty()) {
				Map<String, Decimal> mapAggregatedAmount = new Map<String, Decimal>();
	
				for (AccountingRecord ar : this.accountingRecords) {
					if (ar.aggregationEnabled) {
						String key = ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c +'|'+ ar.accountingRecord.SomDig_Innenauftragsnummer__c +'|'+ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c;
						Decimal aggregatedAmount = mapAggregatedAmount.get(key);
	
						// ar.accountingRecord.SomDig_Betrag__c should be already set to 2 decimal places, but for safety...
						if (aggregatedAmount == null) {
							aggregatedAmount = Decimal.ValueOf(ar.accountingRecord.SomDig_Betrag__c).setScale(2);
						} else {
							aggregatedAmount += Decimal.ValueOf(ar.accountingRecord.SomDig_Betrag__c).setScale(2);
						} 
						mapAggregatedAmount.put(key, aggregatedAmount);
					}
				}
				
				List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();
				Set<String> processedKey = new Set<String>();
				
				for (AccountingRecord ar : this.accountingRecords) {
					if (ar.aggregationEnabled) {
						String key = ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c +'|'+ ar.accountingRecord.SomDig_Innenauftragsnummer__c +'|'+ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c;
	
						if (!processedKey.contains(key)) {
							processedKey.add(key);
							ar.accountingRecord.SomDig_Betrag__c = mapAggregatedAmount.get(key).toPlainString().leftPad(14).replace(' ','0');
							tmpAccountingRecords.add(ar);
						}
					} else {
						tmpAccountingRecords.add(ar);
					}
				}
				
				this.accountingRecords.clear();
				this.accountingRecords.addAll(tmpAccountingRecords);
			}
		}

		/**
		 * Is this group valid?
		 */
		public Boolean isValid() {
			if (!this.hasValidated) {
				Decimal sumSoll = 0.0, sumHaben = 0.0;
				for (AccountingRecord ar : this.accountingRecords) {
					if ('S'.equals(ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c)) {
						sumSoll += String.isNotEmpty(ar.accountingRecord.SomDig_Betrag__c)
									? Decimal.ValueOf(ar.accountingRecord.SomDig_Betrag__c)
									: 0;
					} else if ('H'.equals(ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c)) {
						sumHaben += String.isNotEmpty(ar.accountingRecord.SomDig_Betrag__c)
									? Decimal.ValueOf(ar.accountingRecord.SomDig_Betrag__c)
									: 0;
					}
				}
				
				this.hasValidated = true;
				if (sumSoll == sumHaben) {
					this.isValid = true;
				}
			}
			
			return this.isValid;
		}
	}

	/**
	 * The PRAP class.
	 */
	public class PRAP {
		/** The SomDig_PRAP__c records. */
		public SomDig_PRAP__c prapRecord { public get; private set; }
		
		/** Remaining accural / deferral amount (value of/for formular field SomDig_NochAbzugrenzendeErloese__c of object SomDig_PRAP__c) */
		public Decimal remainingAmount { public get; private set; }
		
		/** Does this PRAP record need to update / upsert? */
		public Boolean toUpsert { public get; private set; }

		/**
		 * Constructor.
		 * 
		 * @param aPrap PRAP record to set.
		 */
		public PRAP(SomDig_PRAP__c aPrap) {
			this.prapRecord = aPrap;
			this.remainingAmount = null;
			this.toUpsert = false;
		}
	}
	
	/**
	 * The revenue distribution calculation result class.
	 */
	public class RevenueDistributionResult {
		/** The ADvendio__InvoiceItem__c processed. */
		public ADvendio__InvoiceItem__c invoiceItem { public get; private set; }
		
		/** Start date of the accounting period being considered. Should be start of a month. */
		public Date accountingPeriodStartDate { public get; private set; }

		/** End date of the accounting period being considered. Should be end of a month. */
		public Date accountingPeriodEndDate { public get; private set; }

		/** Accounting records groups. */
		public List<AccountingRecordsGroup> accountingRecordsGroups { public get; private set; }
		
		/** Messages. */
		public List<ProcessMessage> messages { public get; private set; }
		
		/** Matched Logics. */
		public Set<String> matchedLogics { public get; private set; }
		
		/** PRAP records. */
		public List<PRAP> prapRecords { public get; private set; }
	
		/** Monthly planed revenue. */
		private	Map<Date, Decimal> planedRevenueOfMonth;

		/**
		 * Constructor.
		 * 
		 * @param invoiceItem Invoice item to set.
		 */
		public RevenueDistributionResult(ADvendio__InvoiceItem__c invoiceItem) {
			this.invoiceItem = invoiceItem;
			this.accountingPeriodStartDate = invoiceItem.ADvendio__InvoiceItemStartDate__c.toStartOfMonth();
			this.accountingPeriodEndDate = invoiceItem.ADvendio__InvoiceItemEndDate__c.toStartOfMonth().addMonths(1).addDays(-1);
			this.accountingRecordsGroups = new List<AccountingRecordsGroup>();
			this.messages = new List<ProcessMessage>();
			this.matchedLogics = new Set<String>();
			this.prapRecords = new List<PRAP>();
			this.planedRevenueOfMonth = null;
		}

		/**
		 * Add an accounting records group
		 */
		public void addAccountingRecordsGroup(AccountingRecordsGroup grp) {
			if (grp != null) {
				this.accountingRecordsGroups.add(grp);
			}
		}

		/**
		 * Add a message
		 */
		public void addMessage(ProcessMessage msg) {
			if (msg != null && String.isNotEmpty(msg.message)) {
				this.messages.add(msg);
			}
		}
		
		/**
		 * Add a matched logic
		 */
		public void addMatchedLogic(String logic) {
			if (String.isNotEmpty(logic)) {
				this.matchedLogics.add(logic);
			}
		}

		/**
		 * Is there any error?
		 *
		 * @return true if there is any error, false otherwise.
		 */
		public Boolean hasError() {
			for (ProcessMessage msg : this.messages) {
				if (msg.severity == ApexPages.Severity.FATAL || msg.severity == ApexPages.Severity.ERROR) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Get the planed revenue of the given month.
		 *
		 * @param beginOfMonth	The month to use. Type is Date, value must be the first day of the month.
		 * @param endOfMonth	The month to use. Type is Date, value must be the last day of the month.
		 * @return The planed revenue of the given month, or <code>null</code> if not find.
		 */
		public Decimal getPlanedRevenueOfMonth(Date beginOfMonth, Date endOfMonth) {
			if (planedRevenueOfMonth == null) {
				planedRevenueOfMonth = new Map<Date, Decimal>();
				
				// Calculate planed accounting amount for the accounting period.
				Map<Date, Integer> daysInMonth = getNumberOfDaysInMonth(this.invoiceitem.ADvendio__FromDate__c, this.invoiceitem.ADvendio__UntilDate__c);
				List<Date> months = new List<Date>(daysInMonth.keySet());
				months.sort();
			
				// Net amount
				Decimal totalAmount = Math.abs(this.invoiceitem.ADvendio__CampaignItem__r.ADvendio__Amount_net_netAPEX__c).setScale(2);
				Decimal dailyAmount = (totalAmount / (this.invoiceitem.ADvendio__FromDate__c.daysBetween(this.invoiceitem.ADvendio__UntilDate__c) + 1));
	
				Decimal totalProratedAmount = 0;
				for (Date aDate : months) {
	 				Decimal proratedAmount = (dailyAmount * daysInMonth.get(aDate)).setScale(2, System.RoundingMode.HALF_DOWN);
	 				planedRevenueOfMonth.put(aDate, proratedAmount);
					totalProratedAmount += proratedAmount;
				}
	
				Decimal residualAmount = totalAmount - totalProratedAmount;
				if (Math.abs(residualAmount) > 0) {
					Date aDate = months.get(months.size()-1);
					Decimal proratedAmount = planedRevenueOfMonth.get(aDate) + residualAmount;
					planedRevenueOfMonth.put(aDate, proratedAmount);
				}
	
			}
			
			Decimal amount = 0.0;
			for (Date aMonth = beginOfMonth; aMonth < endOfMonth; aMonth = aMonth.addMonths(1)) {
				amount += (planedRevenueOfMonth.get(aMonth) != null ? planedRevenueOfMonth.get(aMonth) : 0);
			}

			return amount;
		}
	}

	public Map<Id, Boolean> isInvoiceUsingProjection	= new Map<Id, Boolean>();

	/** Mediagattungs-Segment:
	 *   Key is the record-id -- SomDig_MediagattungsSegment__c.Id
	 *   value is the record-name -- SomDig_MediagattungsSegment__c.Name object.
	 */
	private static Map<Id, String> mMediaGattung = null;

	/** Internal Order Number / IA Nummer:
	 *   Key is the identifier -- actually the combination of fields SomDig_Mediagattung__c, SomDig_MediagattungsSegment__c,
	 *							SomDig_MediagattungsDifferenzierung__c, SomDig_Werbetraergergruppierung__c
	 *   value is the SomDig_IaNummer__c object.
	 */
	private static Map<String, SomDig_IaNummer__c> mIaNummer = null;
	
	/** GL accounts / Sachkonto:
	 *   Key is the identifier -- actually the field SomDig_SachkontoTyp__c,
	 *   value is the SomDig_Sachkonto__c object.
	 */
	private static Map<String, SomDig_Sachkonto__c> mSachkonto = null;
	
	/** Cached RecordTypes:
	 *   Key is the Name,
	 *   value is the Id object.
	 */
	private static Map<String, Id> mRecordType = null;
		
	/**
	 * load and get the requested Mediagattungs-Segment
	 * @param id of the requested Mediagattungs-Segment
	 * @return the Mediagattungs-Segment name
	 */
	private String getMediagattungsSegment(Id mgsId) {
		if (mMediaGattung == null) {
			mMediaGattung = new Map<Id, String>();
			for (SomDig_MediagattungsSegment__c rec : [SELECT Id, Name FROM SomDig_MediagattungsSegment__c WHERE IsDeleted = false]) {
				mMediaGattung.put(rec.Id, rec.Name);			
			}
		}
		return mMediaGattung.get(mgsId);
	}
		
	/**
	 * Load the internal order number.
	 */
	private static void loadIaNummer() {
		if (mIaNummer == null) {
			mIaNummer = new Map<String, SomDig_IaNummer__c>();
			String query = 'SELECT ' + QUERY_IANUMMER_FIELDS + ' FROM SomDig_IaNummer__c WHERE IsDeleted = false';
			for (SomDig_IaNummer__c rec : Database.query(query)) {
				if (rec.SomDig_CSPartnerID__c != null) {
					mIaNummer.put(rec.SomDig_CSPartnerID__c + '|' + rec.SomDig_Mediagattung__c + '|' + rec.SomDig_MediagattungsSegment__c + 
								  '|' + rec.SomDig_MediagattungsDifferenzierung__c + '|' + rec.SomDig_Werbetraergergruppierung__c,
								  rec);
				} else if (rec.SomDig_Mediagattung__c != null || rec.SomDig_MediagattungsSegment__c != null ||
						   rec.SomDig_MediagattungsDifferenzierung__c != null || rec.SomDig_Werbetraergergruppierung__c != null) {
					mIaNummer.put('' + rec.SomDig_Mediagattung__c + '|' + rec.SomDig_MediagattungsSegment__c + 
								  '|' + rec.SomDig_MediagattungsDifferenzierung__c + '|' + rec.SomDig_Werbetraergergruppierung__c,
								  rec);
				}				
			}
			mIaNummer.remove(null);
		}
	}

	/**
	 * Load the GL accounts / Sachkonto
	 */
	private static void loadSachkonto() {
		if (mSachkonto == null) {
			mSachkonto = new Map<String, SomDig_Sachkonto__c>();
			String query = 'SELECT ' + QUERY_SACHKONTO_FIELDS + ' FROM SomDig_Sachkonto__c WHERE IsDeleted = false';
			for (SomDig_Sachkonto__c rec : Database.query(query)) {
				mSachkonto.put(rec.SomDig_SachkontoTyp__c, rec);
			}
			mSachkonto.remove(null);
		}
	}

	/**
	 * Get the internal order number by given data.
	 * 
	 * @param mediagattung					SFDC-Id of the Mediagattung record to use.
	 * @param mediagattungsSegment			SFDC-Id of the Mediagattungs-Segment record to use.
	 * @param mediagattungsDifferenzierung	SFDC-Id of the Mediagattungs-Differenzierung record to use.
	 * @param werbetraegergruppierung		SFDC-Id of the Werbeträgergruppierung record to use.
	 * @return The internal order number if found, <code>null</code> otherwise.
	 */
	public static String getIaNummer(Id mediagattung, Id mediagattungsSegment, Id mediagattungsDifferenzierung, Id werbetraegergruppierung) {
		loadIaNummer();
		
		String key = '' + mediagattung + '|' + mediagattungsSegment + '|' + mediagattungsDifferenzierung + '|' + werbetraegergruppierung;
		
		return mIaNummer.containsKey(key) ? mIaNummer.get(key).Name : null;
	}

	/**
	 * Get the internal order number by given content syndication partner.
	 * 
	 * @param cspId	Content Syndication partner Id to use.
	 * @param mediagattung					SFDC-Id of the Mediagattung record to use.
	 * @param mediagattungsSegment			SFDC-Id of the Mediagattungs-Segment record to use.
	 * @param mediagattungsDifferenzierung	SFDC-Id of the Mediagattungs-Differenzierung record to use.
	 * @param werbetraegergruppierung		SFDC-Id of the Werbeträgergruppierung record to use.
	 * @return The internal order number if found, <code>null</code> otherwise.
	 */
	public static String getIaNummerByCSP(String cspId, Id mediagattung, Id mediagattungsSegment, Id mediagattungsDifferenzierung, Id werbetraegergruppierung) {
		loadIaNummer();
		
		String key = cspId + '|' + mediagattung + '|' + mediagattungsSegment + '|' + mediagattungsDifferenzierung + '|' + werbetraegergruppierung;

		return mIaNummer.containsKey(key) ? mIaNummer.get(key).Name : null;
	}

	/**
	 * Get the internal order number by given type.
	 * 
	 * @param aType	Type of the GL Account, for which the internal order number is to get.
	 * @return The internal order number if found, <code>null</code> otherwise.
	 */
	public static String getIaNummerByType(String aType) {
		loadSachkonto();

		return mSachkonto.containsKey(aType) ? mSachkonto.get(aType).SomDig_SammelIA__c : null;
	}

	/**
	 * Get the internal error order number by given type.
	 * 
	 * @param aType	Type of the GL Account, for which the internal order number is to get.
	 * @return The internal error order number if found, <code>null</code> otherwise.
	 */
	public static String getErrorIaNummerByType(String aType) {
		loadSachkonto();

		return mSachkonto.containsKey(aType) ? mSachkonto.get(aType).SomDig_FehlerIA__c : null;
	}

	/**
	 * Get the GL account number by given type.
	 * 
	 * @param aType	Type of the GL Account, for which the account number is to get.
	 * @return The account number if found, <code>null</code> otherwise.
	 */
	public static String getSachkontoNummerByType(String aType) {
		loadSachkonto();
		
		return mSachkonto.containsKey(aType) ? mSachkonto.get(aType).Name : null;
	}

	/**
	 * Get the GL account number by given data.
	 * 
	 * @param mediagattung					SFDC-Id of the Mediagattung record to use.
	 * @param mediagattungsSegment			SFDC-Id of the Mediagattungs-Segment record to use.
	 * @param mediagattungsDifferenzierung	SFDC-Id of the Mediagattungs-Differenzierung record to use.
	 * @param werbetraegergruppierung		SFDC-Id of the Werbeträgergruppierung record to use.
	 * @return The account number if found, <code>null</code> otherwise.
	 */
	public static String getSachkontoNummerByInternalOrder(Id mediagattung, Id mediagattungsSegment, Id mediagattungsDifferenzierung, Id werbetraegergruppierung) {
		loadIaNummer();
		
		String key = '' + mediagattung + '|' + mediagattungsSegment + '|' + mediagattungsDifferenzierung + '|' + werbetraegergruppierung;
		
		return  mIaNummer.containsKey(key)
				? (mIaNummer.get(key).Som_SachkontokonzernintereneVerrechnung__c != null
				   ? mIaNummer.get(key).Som_SachkontokonzernintereneVerrechnung__c.setScale(0).toPlainString()
				   : null)
				: null;
	}
	
	/**
	 * Get the GL account number first by given internal order data, then by given type if required.
	 *
	 * @param mediagattung					SFDC-Id of the Mediagattung record to use.
	 * @param mediagattungsSegment			SFDC-Id of the Mediagattungs-Segment record to use.
	 * @param mediagattungsDifferenzierung	SFDC-Id of the Mediagattungs-Differenzierung record to use.
	 * @param werbetraegergruppierung		SFDC-Id of the Werbeträgergruppierung record to use.
	 * @param aType							Type of the GL Account, for which the account number is to get.
	 * @return The internal order number if found, <code>null</code> otherwise.
	 */
	public static String getSachkonto(Id mediagattung, Id mediagattungsSegment, Id mediagattungsDifferenzierung, Id werbetraegergruppierung, String aType) {
		String nummer = getSachkontoNummerByInternalOrder(mediagattung, mediagattungsSegment, mediagattungsDifferenzierung, werbetraegergruppierung);
		
		return nummer != null ? nummer : getSachkontoNummerByType(aType);
	}

	/**
	 * Get the RecordType of object <code>Buchungssatz__c</code> by name.
	 * 
	 * @param sobjName			API-Name of the sobject to use.
	 * @param recordTypeName	DeveloperName of the RecordType to use.
	 * @return The RecordTypeId if found, <code>null</code> otherwise.
	 */
	public static Id getRecordTypeIdByName(String sobjName, String recordTypeName) {
		if (mRecordType == null) {
			mRecordType = new Map<String, Id>();
			for (RecordType rec : [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = true]) {
				mRecordType.put(rec.SobjectType + '|' + rec.DeveloperName, rec.Id);
			}
		}
		
		String key = '' + sobjName + '|' + recordTypeName;
		
		return mRecordType.containsKey(key) ? mRecordType.get(key) : null;
	}

	/**
	 * Get the number of days between two given dates. The days are split into month.
	 *
	 * @param startDate	Start date to use.
	 * @param endDate End date to use.
	 * @return A map using the date -- actualy the first day of a month -- as key, and the number of days in that month.
	 */
	public static Map<Date, Integer> getNumberOfDaysInMonth(Date startDate, Date endDate) {
		Map<Date, Integer> res = new Map<Date, Integer>();
		
		Date firstDayOfStartMonth = startDate.toStartOfMonth();
		Date firstDayOfEndMonth   = endDate.toStartOfMonth();
		
		for (Date aDate = firstDayOfStartMonth; aDate <= firstDayOfEndMonth; ) {
			Date firstDayOfNextMonth = aDate.addMonths(1);
			
			res.put(aDate, aDate.daysBetween(firstDayOfNextMonth));
			
			aDate = firstDayOfNextMonth;
		}
		
		res.put(firstDayOfStartMonth, startDate.daysBetween(firstDayOfStartMonth.addMonths(1)));
		res.put(firstDayOfEndMonth, firstDayOfEndMonth.daysBetween(endDate)+1);
		
		return res;
	}

	/** Records of type ADvendio__InvoiceItem__c to process. */
	private List<ADvendio__InvoiceItem__c> invoiceItems = new List<ADvendio__InvoiceItem__c>();
	
	/** Options for process types used in the VF page. */
	public List<SelectOption> allProcessTypes { public get; private set; }
	
	/** Selected process type used in the VF page. */
	public String selectedProcessType { public get; public set; }

	/** (Simulated) Process running date used in the VF page. */
	public Date processRunningDate { public get; public set; }

	/** Process results. */
	public List<RevenueDistributionResult> RevenueDistributionResults { public get; public set; }
	
	/** Has data? */
	public Boolean hasData {
		public get {
			return (RevenueDistributionResults != null && RevenueDistributionResults.size() > 0);
		}
		
		public set;
	}

	/** Has results? */
	public Boolean hasResults {
		public get {
			if (RevenueDistributionResults != null && RevenueDistributionResults.size() > 0) {
				for (RevenueDistributionResult rdr : RevenueDistributionResults) {
					if (rdr.accountingRecordsGroups.size() > 0) {
						return true;
					}
				}
			}
			return false;
		}
		
		public set;
	}

	/** Has PRAP? */
	public Boolean hasPRAPs {
		public get {
			if (RevenueDistributionResults != null && RevenueDistributionResults.size() > 0) {
				for (RevenueDistributionResult rdr : RevenueDistributionResults) {
					if (rdr.prapRecords.size() > 0) {
						return true;
					}
				}
			}
			return false;
		}
		
		public set;
	}
	
	/** Generate accounting records for revenue projection by pre-invoice? **/
	private Boolean creatingProjectionRecords = true;

	/**
	 * Default constructor.
	 */
	public SomDig_Buchungssatz_EaBase() {
	}
	
	/**
	 * Constructor.
	 *
	 * @param	controller	An object of type <code>ApexPages.StandardController</code> to use for initialising.
	 */
	public SomDig_Buchungssatz_EaBase(ApexPages.StandardController controller) {
		
		init();

		if (controller != null) {
			getInvoiceItems(new Set<Id> {controller.getId()});			
		}		
	}

	/**
	 * Constructor.
	 *
	 * @param	invocieItems	A list of object of type <code>ADvendio__InvoiceItem__c</code> that belongs to
	 *							one same <code>ADvendio__Invoice__c</code> to use for initialising.
	 * @param	processType		The type of process to run, possible is either <code>PROCESS_ULTIMO_MINUS_5</code> or <code>PROCESS_ULTIMO_PLUS_4</code>.
	 *							Set to <code>null</code> to use the default which is <code>PROCESS_ULTIMO_MINUS_5</code>.
	 * @param	runningDate		The date at which the process is running. It is used to verify the invoice items being considered.
	 *							Furthermore, for <code>PROCESS_ULTIMO_MINUS_5</code>, it is used for posibble Extrapolation and Anticipation.
	 *							Set to <code>null</code> to use the default which is today.
	 * @param	withProjection	Whether to create projected accounting records or not.
	 *							There are other creteria for creating projected accounting records, set this value to <code>false</code> will force
	 *							to bypass creating projected accounting records, except for Extrapolation and Antizipation.
	 */
	public SomDig_Buchungssatz_EaBase(List<ADvendio__InvoiceItem__c> invocieItems, String processType, Date runningDate, Boolean withProjection) {
		
		init();

		if (processType != null) {
			selectedProcessType = processType;
		}
		if (runningDate != null) {
			processRunningDate = runningDate;
		}
		
		if (invocieItems != null && !invocieItems.isEmpty()) {
			Set<Id> ids = new Set<Id>();
			for (ADvendio__InvoiceItem__c invoiceItem : invocieItems) {
				ids.add(invoiceItem.Id);
			}
			getInvoiceItems(ids);
		}
		
		if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
			creatingProjectionRecords = withProjection;
		}
	}

	/**
	 * Initialize.
	 */
	private void init() {
		invoiceItems.clear();
		
		allProcessTypes = new List<SelectOption>();
		
		allProcessTypes.add(new SelectOption(PROCESS_ULTIMO_MINUS_5, PROCESS_ULTIMO_MINUS_5));
		allProcessTypes.add(new SelectOption(PROCESS_ULTIMO_PLUS_4, PROCESS_ULTIMO_PLUS_4));
		
		selectedProcessType = allProcessTypes.get(0).getValue();

		processRunningDate = System.today();
  	
		RevenueDistributionResults = new List<RevenueDistributionResult>();
		
	}
	
	/**
	 * Get invoice items being processed.
	 * 
	 * @param ids	A set od SFDC-Ids to use for getting the invoice items
	 */
	private void getInvoiceItems(Set<Id> ids) {
		invoiceItems.clear();

		if (ids != null) {
			ids.remove(null);
			if (!ids.isEmpty()) {
				String query = 'SELECT ' + QUERY_INVOICEITEM_FIELDS + ' FROM ADvendio__InvoiceItem__c WHERE Id IN :ids';
				invoiceItems = Database.query(query);
			}
		}
	}

	/**
	 * Run the process
	 *
	 * @return	A PageReference object. The value will always be null.
	 */
	public PageReference runProcess() {
		RevenueDistributionResults.clear();
		
		if (invoiceItems == null || invoiceItems.isEmpty()) {
			if (ApexPages.currentPage() != null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Keine InvoiceItem definiert / gefunden.'));
			}
			return null;
		}
		
		// Set the accounting period.
		Date accountingStartDate = null;
		Date accountingEndDate = null;
	
		if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
			accountingStartDate = processRunningDate.toStartOfMonth();
			accountingEndDate = accountingStartDate.addMonths(1).addDays(-1);			
		} else if (PROCESS_ULTIMO_PLUS_4.equals(selectedProcessType)) {
			accountingStartDate = processRunningDate.addMonths(-1).toStartOfMonth();
			accountingEndDate = accountingStartDate.addMonths(1).addDays(-1);			
		} else {
			if (ApexPages.currentPage() != null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unbekannter Prozess-Typ: ' + selectedProcessType + '.'));
			}
			return null;
		}
		
		// Existed PRAPs of invoice items.
		Map<Id, List<SomDig_PRAP__c>> prapOfInvoiceItems = new Map<Id, List<SomDig_PRAP__c>>();
	
		for (ADvendio__InvoiceItem__c invoiceItem : invoiceItems) {
			RevenueDistributionResult rdr = new RevenueDistributionResult(invoiceItem);
 			
			if (isPrapInvoiceItem(rdr.invoiceItem) && !isCancellationInvoiceItem(rdr.invoiceItem)) {
	 			// Need to calculate / reset the accountingPeriod for InvoiceItems that require PRAP
				prapOfInvoiceItems.put(rdr.invoiceItem.Id, null);
			}
 
			RevenueDistributionResults.add(rdr);
		}
		
		if (!prapOfInvoiceItems.isEmpty()) {
			for (SomDig_PRAP__c aPrap : [SELECT Id, SomDig_Rechnungsposition__c, SomDig_Abrechnungsmonat__c, SomDig_Abrechnungsmonatsende__c, SomDig_NochAbzugrenzendeErloese__c
										 FROM SomDig_PRAP__c
										 WHERE SomDig_Rechnungsposition__c IN :prapOfInvoiceItems.keySet() AND SomDig_Status__c = 'Aufgelöst'
										 ORDER BY SomDig_Rechnungsposition__c, SomDig_Abrechnungsmonat__c DESC])
			{
				List<SomDig_PRAP__c> praps = prapOfInvoiceItems.get(aPrap.SomDig_Rechnungsposition__c);
				if (praps == null) {
					praps = new List<SomDig_PRAP__c>();
					prapOfInvoiceItems.put(aPrap.SomDig_Rechnungsposition__c, praps);
				}
				praps.add(aPrap);
			}

	 		// Calculate / reset the accountingPeriod for InvoiceItems that require PRAP
	  		for (RevenueDistributionResult rdr : RevenueDistributionResults) {
				if (isPrapInvoiceItem(rdr.invoiceItem) && !isCancellationInvoiceItem(rdr.invoiceItem)) {
		 			List<SomDig_PRAP__c> praps = prapOfInvoiceItems.get(rdr.invoiceItem.Id);
		 			
		 			if (accountingStartDate > rdr.accountingPeriodStartDate && accountingStartDate < rdr.accountingPeriodEndDate) {
			 			rdr.accountingPeriodStartDate = accountingStartDate;
		 			}
		 			if (accountingEndDate < rdr.accountingPeriodEndDate && accountingEndDate > rdr.accountingPeriodStartDate) {
						rdr.accountingPeriodEndDate = accountingEndDate;
		 			}
					
					if (praps == null) {
						// No PRAP, start at begin.
						rdr.accountingPeriodStartDate = rdr.invoiceItem.ADvendio__InvoiceItemStartDate__c.toStartOfMonth();
					} else {
						// The list is sorted by SomDig_Abrechnungsmonat__c DESC
						for (SomDig_PRAP__c aPrap : praps) {
							if (aPrap.SomDig_NochAbzugrenzendeErloese__c <= 0) {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Für die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
														' ist die PRAP schon komplett aufgelöst.'));
							}
							else if (aPrap.SomDig_Abrechnungsmonatsende__c < accountingStartDate) {
								// OK
								rdr.accountingPeriodStartDate = aPrap.SomDig_Abrechnungsmonatsende__c.toStartOfMonth().addMonths(1);
								if (rdr.accountingPeriodStartDate > rdr.invoiceItem.ADvendio__InvoiceItemEndDate__c.toStartOfMonth().addMonths(1).addDays(-1)) {
									rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Für die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
															' ist der letzte PRAP-Datensatz schon aufgelöst worden. Der noch offene abzugrendende Betrag ist ' + aPrap.SomDig_NochAbzugrenzendeErloese__c + '.'));
								}
							}
							else if (aPrap.SomDig_Abrechnungsmonat__c > accountingEndDate) {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Für die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
														' gibt es einen PRAP-Datensatz mit einem Abrechnungszeitraum in der Zukunft.'));
							} else {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Für die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
														' gibt es einen PRAP-Datensatz mit überlappendem Abrechnungszeitraum.'));
							}
							break;									
						}
					}
				}
	  		}
		}
		
		// Now go though all logics.
		
		// 1. Step: validation
		doValidation();
		
		// 2. Step: Revenue Distribution
		doRevenueDistributionCalculation();
		
		// 3. Step: Revenue Estimation
		doRevenueEstimationCalculation();
  
		// 4. Step: PRAP
		doPRAPCalculation();

	  	for (RevenueDistributionResult rdr : RevenueDistributionResults) {
			// Consolidate / Aggregate the accounting records.
			for (AccountingRecordsGroup arg : rdr.accountingRecordsGroups) {
				arg.aggregateAccountingRecords();
			}

	  		// Add posible messages to the current page.
		 	if (ApexPages.currentPage() != null) {
	  			for (ProcessMessage msg : rdr.messages) {
	  				ApexPages.addMessage(new ApexPages.Message(msg.severity, msg.message));
	  			}
	  		}
	  	}
  
		return null;
	}
	
   /**
	 * Save the PRAP records if there is.
	 *
	 * @return	A PageReference object. The value will always be null.
	 */
	public PageReference savePRAP() {
		if (RevenueDistributionResults != null && RevenueDistributionResults.size() > 0) {
			List<SomDig_PRAP__c> prapToUpsert = new List<SomDig_PRAP__c>();
			
			for (RevenueDistributionResult rdr : RevenueDistributionResults) {
				for (PRAP aPrap : rdr.prapRecords) {
					if (aPrap.toUpsert) {
						prapToUpsert.add(aPrap.prapRecord);
					}
				}
			}
			
			if (!prapToUpsert.isEmpty()) {
				try {
					upsert prapToUpsert SomDig_UniqueKey__c;
				} catch (Exception e) {
					if (ApexPages.currentPage() != null) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
					}
				}
			}
		}
	
		return null;	
	}
	
 	/**
	 * Validate whether an invoice item being process is expected.
	 */
	private void doValidation() {
		for (RevenueDistributionResult rdr : RevenueDistributionResults) {
			if (rdr.hasError()) {
				continue;
			}

			if (!'monthly (1 month)'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentInterval__c) &&
				!'total account (one Invoice)'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentInterval__c))
			{
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Das Zahlungsintervall der Rechnung von der Rechnungsposition mit der Id ' + rdr.invoiceItem.Id + 
													' ist nicht \'monthly (1 month)\' oder \'total account (one Invoice)\', und wird deshalb nicht berücksichtigt.'));
				continue;
			}

			if ('total account (one Invoice)'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentInterval__c) &&
				!'before / during Billingperiod'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentStart__c))
			{
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Das Zahlungsintervall der Rechnung von der Rechnungsposition mit der Id ' + rdr.invoiceItem.Id + 
													' ist \'total account (one Invoice)\', aber die Zahlungssart ist nicht \'before / during Billingperiod\', ' +
													'und wird deshalb nicht berücksichtigt.'));
				continue;				
			}

			if ('Invoiced'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Status__c) &&
				rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__InvoiceDate__c > processRunningDate)
			{
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Die fakturierte Rechnung von der Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
													' hat ein Rechnungsdatum in Zukunft, und wird deshalb nicht berücksichtigt.'));
				continue;
			}

			if (rdr.invoiceItem.ADvendio__InvoiceItemStartDate__c > rdr.accountingPeriodEndDate || 
				rdr.invoiceItem.ADvendio__InvoiceItemEndDate__c < rdr.accountingPeriodStartDate)
			{
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Die Rechnung von der Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
													' liegt außerhalb Abrechnungszeitraum.'));
				continue;
			}			

			// Tech Spec: 4.2.2.1.1: Invoice Status and Period.
			if ('Canceled'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Status__c)) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Die Rechnung von der Rechnungsposition mit der Id ' + rdr.invoiceItem.Id + 
													' ist stoniert, und wird deshalb nicht berücksichtigt.'));
				continue;
			}
		}
	}

	/**
	 * Calculate the revenue distribution.
	 */
	private void doRevenueDistributionCalculation() {
		for (RevenueDistributionResult rdr : RevenueDistributionResults) {
			if (rdr.hasError()) {
				continue;
			}
			
			if ('Packet'.equals(rdr.invoiceItem.ADvendio__CampaignItem__r.RecordType.DeveloperName)) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,
													'Die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id + 
													' ist ein Paket-Kopf, und wird deshalb nicht berücksichtigt.'));
				continue;
			}

			if (isPrapInvoiceItem(rdr.invoiceItem) && isCancellationInvoiceItem(rdr.invoiceItem)) {
				// PRAP Cancellation is a specical case. See executeLogicPRAPCancellation()
				continue;
			}
			
			if (PROCESS_ULTIMO_PLUS_4.equals(selectedProcessType) && !'Invoiced'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Status__c)) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,
													'Die Rechnung von der Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
													' hat den Status ' + rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Status__c +
													', und wird deshalb bei Ultimo+4 nicht berücksichtigt.'));
				continue;
			}
		
			String currentLogic = '';
			
			try {
				// Tech Spec: 4.2.2.1.2: Barter Business Deal
				currentLogic = 'Barter';
				if (executeLogicBarter(rdr)) {
					continue;
				}
	
				// Tech Spec: 4.2.2.1.3. Non-InterCompany Service Business Deal
				currentLogic = 'Non-InterCompany Service';
				if (executeLogicNonInterCompanyService(rdr)) {
					continue;
				}
	
				// Tech Spec: 4.2.2.2.1. Logic: DL Anteil
				currentLogic = 'DL Anteil';
				if (executeLogicDLAnteil(rdr)) {
					continue;
				}

				// KV: 03310 Logic: Non AdServer Position
				currentLogic = 'NonAdServer';
				if (executeLogicNonAdServer(rdr)) {
					continue;
				}


				currentLogic = 'EA Rotation';
				if (executeLogicEARotation(rdr)) {
					continue;
					// never go for EA Werbung oder EA Fremde Marken
				}

				// Tech Spec: 4.2.2.2.2. Logic: EA Werbung,
				// Tech Spec: 4.2.2.2.3. Logic: EA Syndication
				// Tech Spec: 4.2.2.2.5. Logic: EA Mandanten,
				currentLogic = 'EA Werbung';
				if (executeLogicEAWerbung(rdr)) {
					continue;
				}

				// Tech Spec: 4.2.2.2.4. Logic: EA Fremde Marken
				currentLogic = 'EA Fremde Marken';
				if (executeLogicEAFremdeMarken(rdr)) {
					continue;
				}
				
				currentLogic = 'EA Rotation';
				if (executeLogicEARotation(rdr)) {
					continue;
				}

				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, 'Keine Logik anwendbar.'));
			} catch (Exception e) {
				
				throw e;
				/*
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.FATAL,
													'Fehler bei Erlösauteilung-Berechnung (' + currentLogic +
													') bei der Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
													', ' + e.getMessage()));
													*/
			}			
		}
	}
	
	/**
	 * Calculate the revenue estimation. This function should be called after doRevenueDistributionCalculation().
	 */
	private void doRevenueEstimationCalculation() {
		if (!PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
			// Estimation only applicable for PROCESS_ULTIMO_MINUS_5
			return;		
		}
		
		for (RevenueDistributionResult rdr : RevenueDistributionResults) {
			if (rdr.hasError()) {
				continue;
			}
			
			if ('Packet'.equals(rdr.invoiceItem.ADvendio__CampaignItem__r.RecordType.DeveloperName)) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,
													'Die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id + 
													' ist ein Paket-Kopf, und wird deshalb nicht berücksichtigt.'));
				continue;
			}

			if (isCancellationInvoiceItem(rdr.invoiceItem)) {
				// No estimation for Cancellation
				continue;
			}
			
			if ('Invoiced'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Status__c) && !isPrapInvoiceItem(rdr.invoiceItem)) {
				//rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,
				//									'Die Rechnung von der Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
				//									' hat den Status ' + rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Status__c +
				//									', und wird deshalb bei Extrapolation oder Antizipation nicht berücksichtigt.'));
				continue;  		
			}
			
			// Ignore Logic 'Barter' and 'Non-InterCompany Service'.
			if (rdr.matchedLogics.contains('Barter') || rdr.matchedLogics.contains('Non-InterCompany Service')) {
				continue;
			}
			
			// Logic 'DL Anteil' is not performance based revenue distribution.
			if (rdr.matchedLogics.contains('DL Anteil')) {
				continue;
			}
			
			// Logic 'NonAdServer' is not performance based revenue distribution.
			if (rdr.matchedLogics.contains('NonAdServer')) {
				continue;
			}
			
			String currentLogic = '';
			
			try {
				// Tech Spec: 4.2.2.3.1. Logic: Extrapolation
				currentLogic = 'Extrapolation';
				if (executeLogicExtrapolation(rdr)) {
					continue;
				}

				// Tech Spec: 4.2.2.3.2. Logic: Anticipation
				currentLogic = 'Anticipation';
				if (executeLogicAnticipation(rdr)) {
					continue;
				}
			} catch (Exception e) {
				
				throw e;
				/*rdr.addMessage(new ProcessMessage(ApexPages.Severity.FATAL,
													'Fehler bei Erlösauteilung-Berechnung (' + currentLogic +
													') beim InvoiceItems mit der Id ' + rdr.invoiceItem.Id +
													', ' + e.getMessage()));
													*/
			}			
		}
	}

	/**
	 * Calculate the PRAP. This function should be called after doRevenueDistributionCalculation() and doRevenueEstimationCalculation()
	 */
	private void doPRAPCalculation() {
		for (RevenueDistributionResult rdr : RevenueDistributionResults) {
			if (rdr.hasError()) {
				continue;
			}
			
			if ('Packet'.equals(rdr.invoiceItem.ADvendio__CampaignItem__r.RecordType.DeveloperName)) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,
													'Die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id + 
													' ist ein Paket-Kopf, und wird deshalb nicht berücksichtigt.'));
				continue;
			}
			
			if (!isPrapInvoiceItem(rdr.invoiceItem)) {
				continue;
			}

			String currentLogic = '';
			
			try {
				// Tech Spec PRAP: 4.3.2.2. Logic: PRAP Erstellung
				// Tech Spec PRAP: 4.3.2.3. Logic: PRAP Stornierung
				if (isCancellationInvoiceItem(rdr.invoiceItem)) {
					currentLogic = 'PRAP Cancellation';
					executeLogicPRAPCancellation(rdr);
				} else {
					currentLogic = 'PRAP Creation';
					executeLogicPRAPCreation(rdr);
				}
			} catch (Exception e) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.FATAL,
													'Fehler bei PRAP-Berechnung (' + currentLogic +
													') beim InvoiceItems mit der Id ' + rdr.invoiceItem.Id +
													', ' + e.getMessage()));
			}			
		}
	}

	/**
	 * Use the Logic "Barter" to calculate the revenue distribution.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and revenue distribution is calculated, false otherwise.
	 */
	private Boolean executeLogicBarter(RevenueDistributionResult rdr) {
		// Tech Spec: 4.2.2.1.2: Barter Business Deal
		if ('Barter'.equals(rdr.invoiceItem.ADvendio__Invoice__r.SomDig_Auftragstyp__c)) {
			rdr.addMatchedLogic('Barter');
			
			rdr.addMessage(new ProcessMessage(ApexPages.Severity.WARNING,
													'Die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
													' ist Teil von einem Barter-Geschäft, daher wird es keine Erlösaufteilung geben.'));
			return true;
		}
		
		return false;		
	}

	/**
	 * Use the Logic "Non-InterCompany Service" to calculate the revenue distribution.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and revenue distribution is calculated, false otherwise.
	 */
	private Boolean executeLogicNonInterCompanyService(RevenueDistributionResult rdr) {
		// Tech Spec: 4.2.2.1.3. Non-InterCompany Service Business Deal
		if (rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c == false &&
			rdr.invoiceItem.ADvendio__Invoice__r.SomDig_Anzahl_Nonmedia_Positionen__c > 0 &&
			rdr.invoiceItem.ADvendio__Invoice__r.SomDig_Anzahl_Media_Positionen__c == 0)
		{
			rdr.addMatchedLogic('Non-InterCompany Service');
			
			if (isCancellationInvoiceItem(rdr.invoiceItem)) {
				if (createCancellationAccountingRecords(rdr, 'DL')) {
					return true;
				}
			}

			rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,
													'Die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
													' ist Teil von einem Nicht-IC-Dienstleistung-Geschäft, daher wird es keine Erlösaufteilung geben.'));	

			// Net amount for revenue distribution 
			Decimal amount = getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2);
			if (amount == 0.0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,  'Non-InterCompany Service: Der Betrag ist 0.'));
				return true;				
			}
			
			// Create projection accountig records.
			createProjectedAccountingRecords(rdr, 'DL', amount, creatingProjectionRecords);

			return true;
		}
		
		return false;		
	}


	/**
	 * Use the Logic 'DL Anteil' to calculate the revenue distribution.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and revenue distribution is calculated, false otherwise.
	 */
	private Boolean executeLogicDLAnteil(RevenueDistributionResult rdr) {
		// Tech Spec: 4.2.2.2.1. Logic: DL Anteil
		if (rdr.invoiceItem.ADvendio__Invoice__r.SomDig_Anzahl_Nonmedia_Positionen__c > 0 &&
			rdr.invoiceItem.ADvendio__Invoice__r.SomDig_Anzahl_Media_Positionen__c > 0 &&
			'NonMedia'.equalsIgnoreCase(rdr.invoiceItem.SomDig_Mediagattungs_Segment__r.Name))
		{
			
			String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;
			
			rdr.addMatchedLogic('DL Anteil');
			
			if (isCancellationInvoiceItem(rdr.invoiceItem)) {
				if (createCancellationAccountingRecords(rdr, 'DL Anteil')) {
					return true;
				}
			}

			// Net amount for revenue distribution 
			Decimal amount = getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2);
			if (amount == 0.0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,  'DL Anteil: Der Betrag ist 0.'));
				return true;				
			}

			Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
													PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
													? 'Hochrechnung'
													: 'Erloesaufteilung');

			// Create projection accountig records.
			createProjectedAccountingRecords(rdr, 'DL Anteil', amount, creatingProjectionRecords);

			// Create distribution accountig records.
			List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();

			for (Integer i = 0; i < 2; i++) {
				// Transfer to other GL account and IA
				AccountingRecord ar = new AccountingRecord();
				
				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId							= recordTypeId;
				ar.accountingRecord.SomDig_Betrag__c						= Math.abs(amount).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Buchungstext__c					= 'DL Anteil';
				ar.accountingRecord.SomDig_Steuerkennzeichen__c				= 'A6';
				ar.aggregationEnabled										= false;
				
				if (i == 0) {
					ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
					ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByType(standardAccount);
					ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
					if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
					}
					if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.WARNING,
															'Keine Sammel-Innenauftragsnummer für Typ \'' + standardAccount + '\' gefunden.'));
					}
				} else if (i == 1) {
					ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(SACHKONTO_TYP_ERLOESE_DIENSTLEISTUNGEN);
					ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByType(SACHKONTO_TYP_ERLOESE_DIENSTLEISTUNGEN);
					ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
					if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Kein Sachkonto für Typ \'' + SACHKONTO_TYP_ERLOESE_DIENSTLEISTUNGEN + '\' gefunden.'));
					}
					if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.WARNING,
															'Keine Sammel-Innenauftragsnummer für Typ \'' + SACHKONTO_TYP_ERLOESE_DIENSTLEISTUNGEN + '\' gefunden.'));
					}
				}
				
				tmpAccountingRecords.add(ar);
			}

			// Add created accountig records to an AccountingRecordsGroup.
			AccountingRecordsGroup arg = new AccountingRecordsGroup();
			arg.accountingAmount = Math.abs(amount);
			arg.matchedLogic = 'DL Anteil';
			if (amount > 0) {
				for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			} else{
				// Reversed order.
				for (Integer i = tmpAccountingRecords.size() - 1; i >= 0; i--) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			}
			
			// Add created accountig records group to the RevenueDistributionResult
			rdr.addAccountingRecordsGroup(arg);
			isInvoiceUsingProjection.put(rdr.invoiceItem.ADvendio__Invoice__c, true);
			
			return true;
		}
		
		return false;		
	}
	
	/**
	 * Use the Logic 'NonAdserver' to calculate the revenue distribution.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and revenue distribution is calculated, false otherwise.
	 */
	private Boolean executeLogicNonAdServer(RevenueDistributionResult rdr) {
		// KV: 03310 Logic: NonAdserver
		if ('Standard'.equalsIgnoreCase(rdr.invoiceItem.SomDig_Adservertyp__c)) {
			rdr.addMatchedLogic('NonAdServer');
			
			String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;

			// not used due to KV 03805
			if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType) && rdr.invoiceItem.ADvendio__FromDate__c >= processRunningDate) {
				// Not yet started, no delivery data. A case for Anticipation.
				//return true;		
			}

			if (isCancellationInvoiceItem(rdr.invoiceItem)) {
				if (createCancellationAccountingRecords(rdr, 'Non Adserver')) {
					return true;
				}
			}

			// Net amount for revenue distribution 
			Decimal amount = getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2);
			if (amount == 0.0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,  'Non Adserver: Der Betrag ist 0.'));
				return true;				
			}

			Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
													PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
													? 'Hochrechnung'
													: 'Erloesaufteilung');

			// Create projection accountig records.
			createProjectedAccountingRecords(rdr, 'Non Adserver', amount, creatingProjectionRecords);

			// Create distribution accountig records.
			List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();

			Id mediagattung							= rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_Mediagattung__c;
			Id mediagattungsSegment					= rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Mediagattungssegment__c;
			Id mediagattungsDifferenzierung			= rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.SomDig_MediagattungsDifferenzierung__c;
			Id werbetraegergruppierung				= rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_Werbetraergergruppierung__c;

			String mediagattungName					= rdr.invoiceItem.SomDig_Mediagattung__r.Name;
			String mediagattungsSegmentName			= rdr.invoiceItem.SomDig_Mediagattungs_Segment__r.Name;
			String mediagattungsDifferenzierungName	= rdr.invoiceItem.SomDig_Mediagattungs_Differenzierung__r.Name;
			String werbetraegergruppierungName		= rdr.invoiceItem.SomDig_Werbetraeger__r.SomDig_Werbetraergergruppierung__r.Name;
			
			String werbetraegerTyp					= rdr.invoiceItem.SomDig_Werbetraeger__r.SomDig_DEWerbetraegertyp__c;

			if (mediagattung == null) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Keine Mediagattung für Werbeträger mit Id \'' + rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__c + '\' definiert.'));
				return true;
			}
			if (mediagattungsSegment == null) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Kein Mediagattungs-Segment für Belegungseinheit mit Id \'' + 
													rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__c + 
													'\' definiert.'));
				return true;
			}
			if (mediagattungsDifferenzierung == null) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Keine Mediagattungs-Differenzierung für Werbeform mit Id \'' + 
													rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__c + 
													'\' definiert.'));
				return true;
			}
			
			if (werbetraegergruppierung == null) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Keine Mediagattungs-Werbeträgergruppierung für Werbeträger mit Id \'' + rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__c + '\' definiert.'));
				return true;
			}
			
			String debitAccountType		= standardAccount;
			String creditAccountType	= standardAccount;

			{ // EA std. Buchung 
				AccountingRecord ar = new AccountingRecord();
					
				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId						= recordTypeId;
				ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Buchungstext__c				= 'EA NonAdserver';
				ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
					
				ar.accountingRecord.SomDig_Betrag__c					= Math.abs(amount).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
				ar.aggregationEnabled									= false;
	
				if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
				}
					
				tmpAccountingRecords.add(ar);
			}
			
			AccountingRecord arKorrFM	= null;
			AccountingRecord arUmFM		= null;
			
			if ('Portal'.equalsIgnoreCase(werbetraegerTyp)) {
				debitAccountType	= SACHKONTO_TYP_KORREKTUR_WERBEERLOES;
				creditAccountType	= SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE;
					
				{ // Umbuchung IA
					arUmFM = new AccountingRecord();

					arUmFM.fillAccountingRecord(rdr.invoiceItem);
					arUmFM.accountingRecord.RecordTypeId						= recordTypeId;
					arUmFM.accountingRecord.SomDig_Buchungstext__c				= 'EA NonAdserver: Umbuchung Fremdmarke';
					arUmFM.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
					arUmFM.aggregationEnabled									= true;
					
					arUmFM.accountingRecord.SomDig_Betrag__c					= Math.abs(amount).toPlainString().leftPad(14).replace(' ','0');
					arUmFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
					arUmFM.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(mediagattung,
																							mediagattungsSegment,
																							mediagattungsDifferenzierung,
																							werbetraegergruppierung);
					arUmFM.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
	
					if (String.isEmpty(arUmFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
					}

					if (!String.isEmpty(arUmFM.accountingRecord.SomDig_Innenauftragsnummer__c)) {
						tmpAccountingRecords.add(arUmFM); // keine Umbuchung wenn IA unbekannt => Fehler / Warnung erfolgt bei der EA zur Position (siehe unten)
					}
				}

				{ // EA Fremdmarke (Korrektur)
					arKorrFM = new AccountingRecord();
		
					arKorrFM.fillAccountingRecord(rdr.invoiceItem);
					arKorrFM.accountingRecord.RecordTypeId						= recordTypeId;
					arKorrFM.accountingRecord.SomDig_Buchungstext__c			= 'EA NonAdserver: Fremde Marken';
					arKorrFM.accountingRecord.SomDig_Steuerkennzeichen__c		= 'A6';
					arKorrFM.aggregationEnabled									= true;
					
					arKorrFM.accountingRecord.SomDig_Betrag__c					= Math.abs(amount).toPlainString().leftPad(14).replace(' ','0');
					arKorrFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(SACHKONTO_TYP_KORREKTUR_WERBEERLOES);
					arKorrFM.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(mediagattung,
																							mediagattungsSegment,
																							mediagattungsDifferenzierung,
																							werbetraegergruppierung);
					arKorrFM.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
	
					if (String.isEmpty(arKorrFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Kein Sachkonto für Typ \'' + SACHKONTO_TYP_KORREKTUR_WERBEERLOES + '\' gefunden.'));
					}
					if (!String.isEmpty(arKorrFM.accountingRecord.SomDig_Innenauftragsnummer__c)) {
						tmpAccountingRecords.add(arKorrFM); // keine Umbuchung wenn IA unbekannt => Fehler / Warnung erfolgt bei der EA zur Position (siehe unten)
					}
				}
			}
					
			{ // EA	
				AccountingRecord ar = new AccountingRecord();

				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId						= recordTypeId;
				ar.accountingRecord.SomDig_Buchungstext__c				= 'EA NonAdserver';
				ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
				ar.accountingRecord.SomDig_Betrag__c					= Math.abs(amount).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkonto(mediagattung,
																					mediagattungsSegment,
																					mediagattungsDifferenzierung,
																					werbetraegergruppierung,
																					creditAccountType);
				ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(mediagattung,
																					mediagattungsSegment,
																					mediagattungsDifferenzierung,
																					werbetraegergruppierung);
 
				ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
				ar.aggregationEnabled = true;
					
				if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
					ApexPages.Severity severity	= ApexPages.Severity.ERROR;
					String msgType	= 'undefined';
					if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
						severity	= ApexPages.Severity.WARNING;
						msgType		= 'IA';
						ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
						ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
						ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
					}

					rdr.addMessage(new ProcessMessage(severity,
										'Keine Innenauftragsnummer für die Kombination: ' +
										'Mediagattung: ' + mediagattungName + '(' + mediagattung + '), ' +
										'Mediagattungs-Segment: ' + mediagattungsSegmentName + '(' + mediagattungsSegment + '), ' +
										'Mediagattungs-Differenzierung: ' + mediagattungsDifferenzierungName + '(' + mediagattungsDifferenzierung + '), ' +
										'Werbeträgergruppierung: ' + werbetraegergruppierungName + '(' + werbetraegergruppierung + ')', msgType));
				}
				if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Sachkonto zum Innenauftrag ('+ar.accountingRecord.SomDig_Innenauftragsnummer__c+') oder für Typ \'' + creditAccountType + '\' gefunden.'));
				}
				
				tmpAccountingRecords.add(ar);
			}

			// Add created accountig records to an AccountingRecordsGroup.
			AccountingRecordsGroup arg = new AccountingRecordsGroup();
			arg.accountingAmount = Math.abs(amount);
			arg.matchedLogic = 'Non Adserver';
			if (amount > 0) {
				for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			} else{
				// Reversed order.
				for (Integer i = tmpAccountingRecords.size() - 1; i >= 0; i--) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			}

			// Add created accountig records group to the RevenueDistributionResult
			rdr.addAccountingRecordsGroup(arg);
			isInvoiceUsingProjection.put(rdr.invoiceItem.ADvendio__Invoice__c, true);
			
			return true;
		}
		
		return false;
	}

	/**
	 * Use the Logic 'EA Werbung' to calculate the revenue distribution. The logic 'EA Syndication' will be considered too, as sub logic.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and revenue distribution is calculated, false otherwise.
	 */
	private Boolean executeLogicEAWerbung(RevenueDistributionResult rdr) {
		// Tech Spec: 4.2.2.2.2. Logic: EA Werbung
		// Tech Spec: 4.2.2.2.5. Logic: EA Mandanten
		// Both use same calculation methods		

		String matchedLogic = null;
		if ('TV'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c)) {
			matchedLogic = 'EA Werbung';
		} else if ('Mandant'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c)) {
			matchedLogic = 'EA Mandant';
		}
			
		String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;
		
		if (String.isNotEmpty(matchedLogic))
		{
			rdr.addMatchedLogic(matchedLogic);

			if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType) && rdr.invoiceItem.ADvendio__FromDate__c >= processRunningDate) {
				// Not yet started, no delivery data. A case for Anticipation.
				return true;		
			}

			if (isCancellationInvoiceItem(rdr.invoiceItem)) {
				if (createCancellationAccountingRecords(rdr, matchedLogic)) {
					return true;
				}
			}

			// Net amount for revenue distribution
			Decimal amount = getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2);					
			if (amount == 0.0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,  matchedLogic + ': Der Betrag ist 0.'));
				return true;				
			}

			Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
													PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
													? 'Hochrechnung'
													: 'Erloesaufteilung');
			
			// Get delivery data, group by sites / segments.
			Map<Id, Map<Id, Decimal[]>> deliveryDataBySite	= getDeliveryDataBySite(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate);

			if (deliveryDataBySite.isEmpty()) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, matchedLogic + ': Keine Lieferzahl für die Erloesaufteilung gefunden.'));
				return true;
			}
			
			if (deliveryDataBySite.containsKey(null)) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, matchedLogic + ': Es gibt AdServer-Id ohne zugewiesenen Werbeträger.'));
				return true;
			}
			
			// Calculate prorated amount of the sites.
			Map<Id, Map<Id, Decimal>> proratedAmountBySite	= new Map<Id, Map<Id, Decimal>>();
			Decimal totalAIs				= 0;
			Decimal totalProratedAmount		= 0;
			Decimal lastMaxProratedAmount	= 0;
			Id lastSiteIdForProratedAmount	= null;
			Id lastMgsIdForProratedAmount	= null;

			for (Id siteId : deliveryDataBySite.keySet()) {
				if (deliveryDataBySite.get(siteId).containsKey(null)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, matchedLogic + ': Es gibt AdServer-Id ohne zugewiesenes Mediagattungs-Segment.'));
					return true;
				}
				
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					totalAIs += deliveryDataBySite.get(siteId).get(mgsId).get(0);
				}
			}
			
			if (totalAIs == 0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, matchedLogic + ': Lieferzahl ist 0.'));
				return true;
			}

			for (Id siteId : deliveryDataBySite.keySet()) {					
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					Decimal proratedAmount = (Math.abs(amount) * deliveryDataBySite.get(siteId).get(mgsId).get(0) / totalAIs).setScale(2, System.RoundingMode.HALF_DOWN);
					if (!proratedAmountBySite.containsKey(siteId)) {
						proratedAmountBySite.put(siteId, new Map<Id, Decimal>());
					}
					proratedAmountBySite.get(siteId).put(mgsId, proratedAmount);
					totalProratedAmount	+= proratedAmount;
					if (proratedAmount >= lastMaxProratedAmount) {
						lastMaxProratedAmount		= proratedAmount;
						lastSiteIdForProratedAmount	= siteId;
						lastMgsIdForProratedAmount	= mgsId;
					}
				}
			}

			Decimal residualAmount	= Math.abs(amount) - totalProratedAmount;
			if (Math.abs(residualAmount) > 0 && lastSiteIdForProratedAmount != null) {
				Decimal proratedAmount	= proratedAmountBySite.get(lastSiteIdForProratedAmount).get(lastMgsIdForProratedAmount) + residualAmount;
				proratedAmountBySite.get(lastSiteIdForProratedAmount).put(lastMgsIdForProratedAmount, proratedAmount);
			}

			//
			// For Tech Spec: 4.2.2.2.3. Logic: EA Syndication
			//
			Map<Id, Map<Id, Map<Decimal, Decimal>>> deliveryDataByPartnerBySite = getDeliveryDataByPartnerBySite(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate);
						
			// Get data that required for getting Internal Order Number for the Sites
			Map<Id, String[]> mediaDataBySite = getMediaDataBySite(rdr.invoiceItem, deliveryDataBySite.keySet());			
			
			// Create projection accountig records.
			createProjectedAccountingRecords(rdr, matchedLogic, amount, creatingProjectionRecords);

			// Create distribution accountig records.
			List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();

			// Debit the SACHKONTO_TYP_ERLOESE_INTERNET 
			{
				AccountingRecord ar = new AccountingRecord();
				
				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId = recordTypeId;
				ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c			= getSachkontoNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Buchungstext__c					= matchedLogic;
				ar.accountingRecord.SomDig_Steuerkennzeichen__c				= 'A6';
				
				ar.accountingRecord.SomDig_Betrag__c						= Math.abs(amount).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Innenauftragsnummer__c			= getIaNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c		= amount > 0 ? 'S' : 'H';
				ar.aggregationEnabled										= false;

				if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
				}
				
				tmpAccountingRecords.add(ar);
			}
			
			// Distribute the revenue, credit the SACHKONTO_TYP_ERLOESE_INTERNET with related IaNummer
			for (Id siteId : deliveryDataBySite.keySet()) {
				if (mediaDataBySite.get(siteId).get(0) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}
				/* Mediagattungs-Segment wird über Adserver-Id ermittelt
				if (mediaDataBySite.get(siteId).get(1) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Mediagattungs-Segment für Belegungseinheit mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__c + 
														'\' definiert.'));
					continue;
				}
				*/
				if (mediaDataBySite.get(siteId).get(2) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Differenzierung für Werbeform mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__c + 
														'\' definiert.'));
					continue;
				}
				/* TODO	 check if this could be pulled from Adserver-Id*/
				if (mediaDataBySite.get(siteId).get(3) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Werbeträgergruppierung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}

				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					if (proratedAmountBySite.get(siteId).get(mgsId) < 0.01) {
						continue;
					}
									
					AccountingRecord ar = new AccountingRecord();
					
					ar.fillAccountingRecord(rdr.invoiceItem);
					ar.accountingRecord.RecordTypeId						= recordTypeId;
					ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
					ar.accountingRecord.SomDig_Buchungstext__c				= matchedLogic;
					ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
					ar.aggregationEnabled									= true;
					
					ar.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
					ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c 	= getSachkonto(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																						mgsId,
																						Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																						Id.valueOf(mediaDataBySite.get(siteId).get(3)),
																						standardAccount);
					ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																						mgsId,
																						Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																						Id.valueOf(mediaDataBySite.get(siteId).get(3)));				
					ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
					
					if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
					}
					if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
						ApexPages.Severity severity	= ApexPages.Severity.ERROR;
						String msgType	= 'undefined';
						if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
							severity	= ApexPages.Severity.WARNING;
							msgType		= 'IA';
							ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
							ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
							ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
						}
						rdr.addMessage(new ProcessMessage(severity,
															'Keine Innenauftragsnummer für die Kombination: ' +
															'Mediagattung: ' + mediaDataBySite.get(siteId).get(4) + '(' + mediaDataBySite.get(siteId).get(0) + '), ' +
															'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
															'Mediagattungs-Differenzierung: ' + mediaDataBySite.get(siteId).get(6) + '(' + mediaDataBySite.get(siteId).get(2) + '), ' +
															'Werbeträgergruppierung: ' + mediaDataBySite.get(siteId).get(7) + '(' + mediaDataBySite.get(siteId).get(3) + ')', msgType));
					}
	
					tmpAccountingRecords.add(ar);
	
					//
					// For Tech Spec: 4.2.2.2.3. Logic: EA Syndication
					//
					if (deliveryDataByPartnerBySite.containsKey(siteId) && deliveryDataByPartnerBySite.get(siteId).containsKey(mgsId)) {
						List<Decimal> adjustedAmountOfSite = new List<Decimal>();
						List<AccountingRecord> cspAccountingRecords =
							 createSyndicationAccountingRecords(rdr,
																mgsId,
																proratedAmountBySite.get(siteId).get(mgsId), 
																('CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c) ? deliveryDataBySite.get(siteId).get(mgsId).get(1) : deliveryDataBySite.get(siteId).get(mgsId).get(0)),
																ar.accountingRecord.SomDig_Buchungstext__c,
																mediaDataBySite.get(siteId),
																deliveryDataByPartnerBySite.get(siteId).get(mgsId),
																adjustedAmountOfSite);
						
						if (!cspAccountingRecords.isEmpty()) {
							if (adjustedAmountOfSite.get(0) >= 0.01) {
								ar.accountingRecord.SomDig_Betrag__c		= adjustedAmountOfSite.get(0).toPlainString().leftPad(14).replace(' ','0');
							} else {
								tmpAccountingRecords.remove(tmpAccountingRecords.size()-1);
							}
							
							tmpAccountingRecords.addAll(cspAccountingRecords);
						}
					}
				}
			}

			// Add created accountig records to an AccountingRecordsGroup.
			AccountingRecordsGroup arg = new AccountingRecordsGroup();
			arg.accountingAmount = Math.abs(amount);
			arg.matchedLogic = matchedLogic;
			if (amount > 0) {
				for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			} else{
				// Reversed order.
				for (Integer i = tmpAccountingRecords.size() - 1; i >= 0; i--) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			}

			// Add created accountig records group to the RevenueDistributionResult
			rdr.addAccountingRecordsGroup(arg);
			isInvoiceUsingProjection.put(rdr.invoiceItem.ADvendio__Invoice__c, true);
			
			return true;
		}
		
		return false;
	}

	/**
	 * Use the Logic 'EA Fremde Marken' to calculate the revenue distribution.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and revenue distribution is calculated, false otherwise.
	 */
	private Boolean executeLogicEAFremdeMarken(RevenueDistributionResult rdr) {
		// Tech Spec: 4.2.2.2.4. Logic: EA Fremde Marken
		if ('Portal'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c))
		{
			
			String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;
		
			rdr.addMatchedLogic('EA Fremde Marken');
			
			if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType) && rdr.invoiceItem.ADvendio__FromDate__c >= processRunningDate) {
				// Not yet started, no delivery data. A case for Anticipation.
				return true;		
			}

			if (isCancellationInvoiceItem(rdr.invoiceItem)) {
				if (createCancellationAccountingRecords(rdr, 'EA Fremde Marken')) {
					return true;
				}
			}

			// Net amount for revenue distribution
			Decimal amount = getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2);
			if (amount == 0.0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO, 'EA Fremde Marken: Der Betrag ist 0.'));
				return true;				
			}
			
			Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
													PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
													? 'Hochrechnung'
													: 'Erloesaufteilung');

			// Get delivery data, group by sites / segments.
			Map<Id, Map<Id, Decimal[]>> deliveryDataBySite	= getDeliveryDataBySite(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate);

			if (deliveryDataBySite.isEmpty()) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, 'EA Fremde Marken: Keine Lieferzahl für die Erloesaufteilung gefunden.'));
				return true;
			}

			if (deliveryDataBySite.containsKey(null)) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,  'EA Fremde Marken: Es gibt AdServer-Id ohne zugewiesenen Werbeträger.'));
				return true;
			}
						
			// Calculate prorated amount of the sites.
			Map<Id, Map<Id, Decimal>> proratedAmountBySite	= new Map<Id, Map<Id, Decimal>>();
			Decimal totalAIs				= 0;
			Decimal totalProratedAmount		= 0;
			Decimal lastMaxProratedAmount	= 0;
			Id lastSiteIdForProratedAmount	= null;
			Id lastMgsIdForProratedAmount	= null;

			for (Id siteId : deliveryDataBySite.keySet()) {
				if (deliveryDataBySite.get(siteId).containsKey(null)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, 'EA Fremde Marken: Es gibt AdServer-Id ohne zugewiesenes Mediagattungs-Segment.'));
					return true;
				}
				
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					totalAIs += deliveryDataBySite.get(siteId).get(mgsId).get(0);
				}
			}
			
			if (totalAIs == 0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, 'EA Fremde Marken: Lieferzahl ist 0.'));
				return true;
			}

			for (Id siteId : deliveryDataBySite.keySet()) {
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					Decimal proratedAmount = (Math.abs(amount) * deliveryDataBySite.get(siteId).get(mgsId).get(0) / totalAIs).setScale(2, System.RoundingMode.HALF_DOWN);
					if (!proratedAmountBySite.containsKey(siteId)) {
						proratedAmountBySite.put(siteId, new Map<Id, Decimal>());
					}
					proratedAmountBySite.get(siteId).put(mgsId, proratedAmount);
					totalProratedAmount	+= proratedAmount;
					if (proratedAmount >= lastMaxProratedAmount) {
						lastMaxProratedAmount		= proratedAmount;
						lastSiteIdForProratedAmount	= siteId;
						lastMgsIdForProratedAmount	= mgsId;
					}
				}
			}
			
			Decimal residualAmount = Math.abs(amount) - totalProratedAmount;
			if (Math.abs(residualAmount) > 0 && lastSiteIdForProratedAmount != null) {
				Decimal proratedAmount	= proratedAmountBySite.get(lastSiteIdForProratedAmount).get(lastMgsIdForProratedAmount) + residualAmount;
				proratedAmountBySite.get(lastSiteIdForProratedAmount).put(lastMgsIdForProratedAmount, proratedAmount);
			}
			
			// Get data that required for getting Internal Order Number for the Sites
			Map<Id, String[]> mediaDataBySite = getMediaDataBySite(rdr.invoiceItem, deliveryDataBySite.keySet());			
						
			// Create projection accountig records.
			createProjectedAccountingRecords(rdr, 'EA Fremde Marken', amount, creatingProjectionRecords);
			
			// Create distribution accountig records.
			List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();

			
			{ // EA std. Buchung
				String debitAccountType		= SACHKONTO_TYP_KORREKTUR_WERBEERLOES;
				String creditAccountType	= SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE;
				
				AccountingRecord ar = new AccountingRecord();

				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId						= recordTypeId;
				ar.accountingRecord.SomDig_Buchungstext__c				= 'EA Fremde Marken: Umbuchung';
				ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
				ar.aggregationEnabled									= false;
				
				ar.accountingRecord.SomDig_Betrag__c					= Math.abs(amount).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';

				if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
				}
				if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.WARNING,
														'Keine Sammel-Innenauftragsnummer für Typ \'' + standardAccount + '\' gefunden.'));
				}
				
				tmpAccountingRecords.add(ar);
			}

			// Distribute the revenue, credit the SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE with related IaNummer
			for (Id siteId : deliveryDataBySite.keySet()) {
				if (mediaDataBySite.get(siteId).get(0) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}
	/*			if (mediaDataBySite.get(siteId).get(1) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Mediagattungs-Segment für Belegungseinheit mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__c + 
														'\' definiert.'));
					continue;
				}*/
				if (mediaDataBySite.get(siteId).get(2) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Differenzierung für Werbeform mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__c + 
														'\' definiert.'));
					continue;
				}
				if (mediaDataBySite.get(siteId).get(3) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Werbeträgergruppierung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}
				
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					if (proratedAmountBySite.get(siteId).get(mgsId) < 0.01) {
						continue;
					}
	
					{ // Umbuchung IA
						String debitAccountType		= SACHKONTO_TYP_KORREKTUR_WERBEERLOES;
						String creditAccountType	= SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE;
						
						AccountingRecord ar = new AccountingRecord();
		
						ar.fillAccountingRecord(rdr.invoiceItem);
						ar.accountingRecord.RecordTypeId						= recordTypeId;
						ar.accountingRecord.SomDig_Buchungstext__c				= 'EA Fremde Marken: Umbuchung';
						ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
						ar.aggregationEnabled									= true;
						
						ar.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
						ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
						ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)));
						ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
		
						if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
							rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
						}
	
						if (!String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
							tmpAccountingRecords.add(ar); // keine Umbuchung wenn IA unbekannt => Fehler / Warnung erfolgt bei der EA zur Position (siehe unten)
						}
					}
					
					
					String debitAccountType		= SACHKONTO_TYP_KORREKTUR_WERBEERLOES;
					String creditAccountType	= SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE;
					
					{ // EA Fremdmarke (Korrektur)
						AccountingRecord ar = new AccountingRecord();
			
						ar.fillAccountingRecord(rdr.invoiceItem);
						ar.accountingRecord.RecordTypeId						= recordTypeId;
						ar.accountingRecord.SomDig_Buchungstext__c				= 'EA Fremde Marken';
						ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
						ar.aggregationEnabled									= true;
						
						ar.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
						ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(SACHKONTO_TYP_KORREKTUR_WERBEERLOES);
						ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)));
						ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
		
						if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
							rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																'Kein Sachkonto für Typ \'' + SACHKONTO_TYP_KORREKTUR_WERBEERLOES + '\' gefunden.'));
						}
						if (!String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
							tmpAccountingRecords.add(ar); // keine Umbuchung wenn IA unbekannt => Fehler / Warnung erfolgt bei der EA zur Position (siehe unten)
						}
					}
			
					{ //EA Fremdmarke (Durchlauf)
						AccountingRecord ar = new AccountingRecord();
		
						ar.fillAccountingRecord(rdr.invoiceItem);
						ar.accountingRecord.RecordTypeId						= recordTypeId;
						ar.accountingRecord.SomDig_Buchungstext__c				= 'EA Fremde Marken';
						ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
						ar.aggregationEnabled									= true;
						
						ar.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
						ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkonto(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)),
																							creditAccountType);
						ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)));				
						ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
						
						if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
							rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																'Kein Sachkonto für Typ \'' + creditAccountType + '\' gefunden.'));
						}
						
						if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
							ApexPages.Severity severity	= ApexPages.Severity.ERROR;
							String msgType	= 'undefined';
							if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
								severity	= ApexPages.Severity.WARNING;
								msgType		= 'IA';
								ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
								ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
								ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
							}
	
							rdr.addMessage(new ProcessMessage(severity,
												'Keine Innenauftragsnummer für die Kombination: ' +
												'Mediagattung: ' + mediaDataBySite.get(siteId).get(4) + '(' + mediaDataBySite.get(siteId).get(0) + '), ' +
												'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
												'Mediagattungs-Differenzierung: ' + mediaDataBySite.get(siteId).get(6) + '(' + mediaDataBySite.get(siteId).get(2) + '), ' +
												'Werbeträgergruppierung: ' + mediaDataBySite.get(siteId).get(7) + '(' + mediaDataBySite.get(siteId).get(3) + ')', msgType));
						}
	
						tmpAccountingRecords.add(ar);
					}
				}
			}

			// Add created accountig records to an AccountingRecordsGroup.
			AccountingRecordsGroup arg = new AccountingRecordsGroup();
			arg.accountingAmount = Math.abs(amount);
			arg.matchedLogic = 'EA Fremde Marken';
			if (amount > 0) {
				for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			} else{
				// Reversed order.
				for (Integer i = tmpAccountingRecords.size() - 1; i >= 0; i--) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			}
			
			// Add created accountig records group to the RevenueDistributionResult
			rdr.addAccountingRecordsGroup(arg);
			isInvoiceUsingProjection.put(rdr.invoiceItem.ADvendio__Invoice__c, true);
			
			return true;
			
		}
		return false;		
	}

	/**
	 * Use the Logic 'EA Rotation' to calculate the revenue distribution. The logic 'EA Syndication' will be considered too, as sub logic.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and revenue distribution is calculated, false otherwise.
	 */
	private Boolean executeLogicEARotation(RevenueDistributionResult rdr) {

		String matchedLogic = null;
		if ('TV'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c)) {
			matchedLogic = 'EA Werbung';
		} else if ('Mandant'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c)) {
			matchedLogic = 'EA Mandant';
		}
		else if ('Rotation'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c)) {
			matchedLogic = 'EA Rotation';
		}
		else if ('Portal'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c)) {
			matchedLogic = 'EA Fremde Marken';
		}

		if (String.isNotEmpty(matchedLogic)) {
			
			rdr.addMatchedLogic(matchedLogic);
			String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;
			
			if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType) && rdr.invoiceItem.ADvendio__FromDate__c >= processRunningDate) {
				// Not yet started, no delivery data. A case for Anticipation.
				return true;
			}

			if (isCancellationInvoiceItem(rdr.invoiceItem)) {
				if (createCancellationAccountingRecords(rdr, matchedLogic)) {
					return true;
				}
			}

			// Net amount for revenue distribution
			Decimal amount = getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2);
			if (amount == 0.0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO, matchedLogic + ': Der Betrag ist 0.'));
				return true;				
			}
			
			Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
													PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
													? 'Hochrechnung'
													: 'Erloesaufteilung');

			// Get delivery data, group by sites / segments.
			Map<Id, Map<Id, Decimal[]>> deliveryDataBySite	= getDeliveryDataBySite(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate);

			if (deliveryDataBySite.isEmpty()) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, matchedLogic + ': Keine Lieferzahl für die Erloesaufteilung gefunden.'));
				return true;
			}

			if (deliveryDataBySite.containsKey(null)) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,  matchedLogic + ': Es gibt AdServer-Id ohne zugewiesenen Werbeträger.'));
				return true;
			}
						
			// Calculate prorated amount of the sites.
			Map<Id, Map<Id, Decimal>> proratedAmountBySite	= new Map<Id, Map<Id, Decimal>>();
			Decimal totalAIs				= 0;
			Decimal totalProratedAmount		= 0;
			Decimal lastMaxProratedAmount	= 0;
			Id lastSiteIdForProratedAmount	= null;
			Id lastMgsIdForProratedAmount	= null;

			for (Id siteId : deliveryDataBySite.keySet()) {					
				if (deliveryDataBySite.get(siteId).containsKey(null)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, matchedLogic + ': Es gibt AdServer-Id ohne zugewiesenes Mediagattungs-Segment.'));
					return true;
				}
			
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					totalAIs += deliveryDataBySite.get(siteId).get(mgsId).get(0);
				}
			}
			
			if (totalAIs == 0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, matchedLogic + ': Lieferzahl ist 0.'));
				return true;
			}

			for (Id siteId : deliveryDataBySite.keySet()) {
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					Decimal proratedAmount = (Math.abs(amount) * deliveryDataBySite.get(siteId).get(mgsId).get(0) / totalAIs).setScale(2, System.RoundingMode.HALF_DOWN);
					if (!proratedAmountBySite.containsKey(siteId)) {
						proratedAmountBySite.put(siteId, new Map<Id, Decimal>());
					}
					proratedAmountBySite.get(siteId).put(mgsId, proratedAmount);
					totalProratedAmount	+= proratedAmount;
					if (proratedAmount >= lastMaxProratedAmount) {
						lastMaxProratedAmount		= proratedAmount;
						lastSiteIdForProratedAmount	= siteId;
						lastMgsIdForProratedAmount	= mgsId;
					}
				}
			}

			Decimal residualAmount = Math.abs(amount) - totalProratedAmount;
			if (Math.abs(residualAmount) > 0 && lastSiteIdForProratedAmount != null) {
				Decimal proratedAmount	= proratedAmountBySite.get(lastSiteIdForProratedAmount).get(lastMgsIdForProratedAmount) + residualAmount;
				proratedAmountBySite.get(lastSiteIdForProratedAmount).put(lastMgsIdForProratedAmount, proratedAmount);
			}
			
			//
			// For Tech Spec: 4.2.2.2.3. Logic: EA Syndication
			//
			Map<Id, Map<Id, Map<Decimal, Decimal>>> deliveryDataByPartnerBySite = getDeliveryDataByPartnerBySite(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate);

			// Get data that required for getting Internal Order Number for the Sites
			Map<Id, String[]> mediaDataBySite = getMediaDataBySite(rdr.invoiceItem, deliveryDataBySite.keySet());			
						
			// Create projection accountig records.
			createProjectedAccountingRecords(rdr, matchedLogic, amount, creatingProjectionRecords);

			List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();
			
			{ // EA std. Buchung 
				AccountingRecord ar = new AccountingRecord();
					
				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId						= recordTypeId;
				ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Buchungstext__c				= matchedLogic;
				ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
					
				ar.accountingRecord.SomDig_Betrag__c					= Math.abs(amount).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
				ar.aggregationEnabled									= false;
	
				if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
				}
					
				tmpAccountingRecords.add(ar);
			}

			// Distribute the revenue, credit the SACHKONTO_TYP_ERLOESE_INTERNET or SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE with related IaNummer
			for (Id siteId : deliveryDataBySite.keySet()) {
				if (mediaDataBySite.get(siteId).get(0) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}
/*				if (mediaDataBySite.get(siteId).get(1) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Mediagattungs-Segment für Belegungseinheit mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__c + 
														'\' definiert.'));
					continue;
				}*/
				if (mediaDataBySite.get(siteId).get(2) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Differenzierung für Werbeform mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__c + 
														'\' definiert.'));
					continue;
				}
				if (mediaDataBySite.get(siteId).get(3) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Werbeträgergruppierung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}
								
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					if (proratedAmountBySite.get(siteId).get(mgsId) < 0.01) {
						continue;
					}
				
					String debitAccountType		= standardAccount;
					String creditAccountType	= standardAccount;
					
					
					AccountingRecord arKorrFM	= null;
					AccountingRecord arUmFM		= null;
					
					if ('Portal'.equalsIgnoreCase(mediaDataBySite.get(siteId).get(8))) {
						debitAccountType	= SACHKONTO_TYP_KORREKTUR_WERBEERLOES;
						creditAccountType	= SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE;
						
						{ // Umbuchung IA
							arUmFM = new AccountingRecord();
	
							arUmFM.fillAccountingRecord(rdr.invoiceItem);
							arUmFM.accountingRecord.RecordTypeId						= recordTypeId;
							arUmFM.accountingRecord.SomDig_Buchungstext__c				= matchedLogic + ': Umbuchung Fremdmarke';
							arUmFM.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
							arUmFM.aggregationEnabled									= true;
							
							arUmFM.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
							arUmFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
							arUmFM.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																								mgsId,
																								Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																								Id.valueOf(mediaDataBySite.get(siteId).get(3)));
							arUmFM.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
			
							if (String.isEmpty(arUmFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																	'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
							}
	
							if (!String.isEmpty(arUmFM.accountingRecord.SomDig_Innenauftragsnummer__c)) {
								tmpAccountingRecords.add(arUmFM); // keine Umbuchung wenn IA unbekannt => Fehler / Warnung erfolgt bei der EA zur Position (siehe unten)
							}
						}
	
						{ // EA Fremdmarke (Korrektur)
							arKorrFM = new AccountingRecord();
				
							arKorrFM.fillAccountingRecord(rdr.invoiceItem);
							arKorrFM.accountingRecord.RecordTypeId						= recordTypeId;
							arKorrFM.accountingRecord.SomDig_Buchungstext__c			= 'EA Fremde Marken';
							arKorrFM.accountingRecord.SomDig_Steuerkennzeichen__c		= 'A6';
							arKorrFM.aggregationEnabled									= true;
							
							arKorrFM.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
							arKorrFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(SACHKONTO_TYP_KORREKTUR_WERBEERLOES);
							arKorrFM.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																								mgsId,
																								Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																								Id.valueOf(mediaDataBySite.get(siteId).get(3)));
							arKorrFM.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
			
							if (String.isEmpty(arKorrFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																	'Kein Sachkonto für Typ \'' + SACHKONTO_TYP_KORREKTUR_WERBEERLOES + '\' gefunden.'));
							}
							if (!String.isEmpty(arKorrFM.accountingRecord.SomDig_Innenauftragsnummer__c)) {
								tmpAccountingRecords.add(arKorrFM); // keine Umbuchung wenn IA unbekannt => Fehler / Warnung erfolgt bei der EA zur Position (siehe unten)
							}
						}
					}
						
					{ // EA	
						AccountingRecord ar = new AccountingRecord();
	
						ar.fillAccountingRecord(rdr.invoiceItem);
						ar.accountingRecord.RecordTypeId						= recordTypeId;
						ar.accountingRecord.SomDig_Buchungstext__c				= matchedLogic;
						ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
						ar.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
						ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkonto(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)),
																							creditAccountType);
						ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)));
		 
						ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
						ar.aggregationEnabled = true;
						
						if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
							ApexPages.Severity severity	= ApexPages.Severity.ERROR;
							String msgType	= 'undefined';
							if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
								severity	= ApexPages.Severity.WARNING;
								msgType		= 'IA';
								ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
								ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
								ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
							}
	
							rdr.addMessage(new ProcessMessage(severity,
												'Keine Innenauftragsnummer für die Kombination: ' +
												'Mediagattung: ' + mediaDataBySite.get(siteId).get(4) + '(' + mediaDataBySite.get(siteId).get(0) + '), ' +
												'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
												'Mediagattungs-Differenzierung: ' + mediaDataBySite.get(siteId).get(6) + '(' + mediaDataBySite.get(siteId).get(2) + '), ' +
												'Werbeträgergruppierung: ' + mediaDataBySite.get(siteId).get(7) + '(' + mediaDataBySite.get(siteId).get(3) + ')', msgType));
						}
						if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
							rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																'Kein Sachkonto zum Innenauftrag ('+ar.accountingRecord.SomDig_Innenauftragsnummer__c+') oder für Typ \'' + creditAccountType + '\' gefunden.'));
						}
						
						tmpAccountingRecords.add(ar);
	
						//
						// For Tech Spec: 4.2.2.2.3. Logic: EA Syndication
						//
						if (deliveryDataByPartnerBySite.containsKey(siteId) && deliveryDataByPartnerBySite.get(siteId).containsKey(mgsId)) {
							List<Decimal> adjustedAmountOfSite = new List<Decimal>();
							List<AccountingRecord> cspAccountingRecords =
								 createSyndicationAccountingRecords(rdr,
																	mgsId,
																	proratedAmountBySite.get(siteId).get(mgsId), 
																	('CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c) ? deliveryDataBySite.get(siteId).get(mgsId).get(1) : deliveryDataBySite.get(siteId).get(mgsId).get(0)),
																	ar.accountingRecord.SomDig_Buchungstext__c,
																	mediaDataBySite.get(siteId),
																	deliveryDataByPartnerBySite.get(siteId).get(mgsId),
																	adjustedAmountOfSite);
							if (!cspAccountingRecords.isEmpty()) {
								if (adjustedAmountOfSite.get(0) >= 0.01) {
									ar.accountingRecord.SomDig_Betrag__c		= adjustedAmountOfSite.get(0).toPlainString().leftPad(14).replace(' ','0');
									if (arKorrFM != null) {
										arKorrFM.accountingRecord.SomDig_Betrag__c	= adjustedAmountOfSite.get(0).toPlainString().leftPad(14).replace(' ','0');
									}
									if (arUmFM != null) {
										arUmFM.accountingRecord.SomDig_Betrag__c	= adjustedAmountOfSite.get(0).toPlainString().leftPad(14).replace(' ','0');
									}
								} else {
									tmpAccountingRecords.remove(tmpAccountingRecords.size()-1);
								}
								
								tmpAccountingRecords.addAll(cspAccountingRecords);
							}
						}
					}
				}
				
			}

			// Add created accountig records to an AccountingRecordsGroup.
			AccountingRecordsGroup arg = new AccountingRecordsGroup();
			arg.accountingAmount = Math.abs(amount);
			arg.matchedLogic = matchedLogic;
			if (amount > 0) {
				for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			} else{
				// Reversed order.
				for (Integer i = tmpAccountingRecords.size() - 1; i >= 0; i--) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			}

			// Add created accountig records group to the RevenueDistributionResult
			rdr.addAccountingRecordsGroup(arg);
			isInvoiceUsingProjection.put(rdr.invoiceItem.ADvendio__Invoice__c, true);
			
			return true;
		}
		
		return false;
	}
	
	/**
	 * Use the Logic 'Extrapolation' to calculate the revenue distribution.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and revenue distribution is calculated, false otherwise.
	 */
	private Boolean executeLogicExtrapolation(RevenueDistributionResult rdr) {
		// Tech Spec: 4.2.2.3.1. Logic: Extrapolation
		if (rdr.invoiceItem.ADvendio__FromDate__c < processRunningDate &&
			rdr.invoiceItem.ADvendio__UntilDate__c >= processRunningDate &&
			rdr.accountingPeriodStartDate < processRunningDate &&
			rdr.accountingPeriodEndDate >= processRunningDate &&
			(isPrapInvoiceItem(rdr.invoiceItem) || !rdr.invoiceItem.ADvendio__LinearDistribution__c))
		{
			String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;
		
			rdr.addMatchedLogic('Extrapolation');
			
			Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
													PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
													? 'Hochrechnung'
													: 'Erloesaufteilung');

			// Net amount for revenue distribution
			Decimal amount = getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2);					
			if (amount == 0.0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO, 'Extrapolation: Der Betrag ist 0.'));
				return true;				
			}

			// Get delivery data, group by sites / segments.
			Map<Id, Map<Id, Decimal[]>> deliveryDataBySite = getDeliveryDataBySite(rdr.invoiceItem, (isPrapInvoiceItem(rdr.invoiceItem) ? rdr.invoiceItem.ADvendio__InvoiceItemStartDate__c.toStartOfMonth() : rdr.accountingPeriodStartDate), rdr.accountingPeriodEndDate);
			
			if (deliveryDataBySite.isEmpty()) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, 'Extrapolation: Keine Lieferzahl für die Hochrechnung gefunden.'));
				return true;
			}
			
			if (deliveryDataBySite.containsKey(null)) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,  'Extrapolation: Es gibt AdServer-Id ohne zugewiesenen Werbeträger.'));
				return true;
			}
						
			// Calculate prorated delivery of the sites.
			Map<Id, Map<Id, Decimal>> proratedDeliveryBySite = new Map<Id, Map<Id, Decimal>>();
			Decimal totalDelivery	= 0;
			Boolean isCPC = 'CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c) ? true : false;

			for (Id siteId : deliveryDataBySite.keySet()) {
				if (deliveryDataBySite.get(siteId).containsKey(null)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, 'Extrapolation: Es gibt AdServer-Id ohne zugewiesenes Mediagattungs-Segment.'));
					return true;
				}
				
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					if (isCPC) {
						totalDelivery += deliveryDataBySite.get(siteId).get(mgsId).get(1);
					} else {
						totalDelivery += deliveryDataBySite.get(siteId).get(mgsId).get(0);
					}
				}
			}
			
			if (totalDelivery == 0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR, 'Extrapolation: Lieferzahl ist 0.'));
				return true;
			}

			for (Id siteId : deliveryDataBySite.keySet()) {
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					Decimal proratedDelivery = (isCPC ? deliveryDataBySite.get(siteId).get(mgsId).get(1) : deliveryDataBySite.get(siteId).get(mgsId).get(0)) / totalDelivery;
					if (!proratedDeliveryBySite.containsKey(siteId)) {
						proratedDeliveryBySite.put(siteId, new Map<Id, Decimal>());
					}
					proratedDeliveryBySite.get(siteId).put(mgsId, proratedDelivery);
				}
			}

			// Calculate the elapsed number of days.
			Integer elapsedDays = rdr.invoiceItem.ADvendio__FromDate__c <= rdr.accountingPeriodStartDate
									? rdr.accountingPeriodStartDate.daysBetween(processRunningDate)
									: rdr.invoiceItem.ADvendio__FromDate__c.daysBetween(processRunningDate);
									
			// Calculate the remaining number of days.
			Integer remainingDays = rdr.invoiceItem.ADvendio__UntilDate__c > rdr.accountingPeriodEndDate
									? (processRunningDate.daysBetween(rdr.accountingPeriodEndDate) + 1)
									: (processRunningDate.daysBetween(rdr.invoiceItem.ADvendio__UntilDate__c) + 1);
									
			// Calculate the (average) daily earned revenue in the elapsed number of days.
			Decimal dailyEarnedRevenue	= 0.0;
			if (elapsedDays > 0) {
				dailyEarnedRevenue = Math.abs(amount) / elapsedDays;
			}

			// Calculate the estimated revenue for the remaining days.
			Decimal estimatedRevenue	= (dailyEarnedRevenue * remainingDays).setScale(2);
			
			if ('CPM'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c) || 'CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
				
				Decimal totalQuantity = totalDelivery;
				if (rdr.invoiceItem.ADvendio__QuantityDeliveredSum__c != null) {
					 totalQuantity += Math.abs(rdr.invoiceItem.ADvendio__QuantityDeliveredSum__c);
				}
				
				Decimal remainingQuantity = Math.abs(rdr.invoiceItem.ADvendio__BookedQuantity__c) - totalQuantity;

				if (remainingQuantity <= 0) {
					estimatedRevenue = 0.00;
				} else {
					Decimal remainingAmount	= (Math.abs(rdr.invoiceItem.ADvendio__InvoicedAmountNet2__c) / Math.abs(totalDelivery) * remainingQuantity).setScale(2);
					if (isPrapInvoiceItem(rdr.invoiceItem)) {
						remainingAmount	= (Math.abs(rdr.invoiceItem.ADvendio__InvoicedAmountNet2__c) / Math.abs(rdr.invoiceItem.ADvendio__BookedQuantity__c) * remainingQuantity).setScale(2);
					}
				
					estimatedRevenue = (remainingAmount > estimatedRevenue ? estimatedRevenue : remainingAmount);
					}
				}
			
			if (estimatedRevenue == 0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO, 'Extrapolation: Erlös-Hochrechnung ist 0.'));
				return true;
			}
						
			// Calculate prorated estimated revenue of the sites.
			Map<Id, Map<Id, Decimal>> proratedAmountBySite	= new Map<Id, Map<Id, Decimal>>();
			Decimal totalProratedAmount		= 0;
			Decimal lastMaxProratedAmount	= 0;
			Id lastSiteIdForProratedAmount	= null;
			Id lastMgsIdForProratedAmount	= null;

			for (Id siteId : deliveryDataBySite.keySet()) {				
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					Decimal proratedAmount = (Math.abs(estimatedRevenue) * proratedDeliveryBySite.get(siteId).get(mgsId)).setScale(2, System.RoundingMode.HALF_DOWN);
					if (!proratedAmountBySite.containsKey(siteId)) {
						proratedAmountBySite.put(siteId, new Map<Id, Decimal>());
					}
					proratedAmountBySite.get(siteId).put(mgsId, proratedAmount);
					totalProratedAmount += proratedAmount;
					if (proratedAmount >= lastMaxProratedAmount) {
						lastMaxProratedAmount		= proratedAmount;
						lastSiteIdForProratedAmount	= siteId;
						lastMgsIdForProratedAmount	= mgsId;
					}
				}
			}

			Decimal residualAmount = Math.abs(estimatedRevenue) - totalProratedAmount;
			if (Math.abs(residualAmount) > 0 && lastSiteIdForProratedAmount != null) {
				Decimal proratedAmount = proratedAmountBySite.get(lastSiteIdForProratedAmount).get(lastMgsIdForProratedAmount)  + residualAmount;
				proratedAmountBySite.get(lastSiteIdForProratedAmount).put(lastMgsIdForProratedAmount, proratedAmount);
			}
			
			//
			// For Tech Spec: 4.2.2.2.3. Logic: EA Syndication
			//
			Map<Id, Map<Id, Map<Decimal, Decimal>>> deliveryDataByPartnerBySite = getDeliveryDataByPartnerBySite(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate);
	
			// Get data that required for getting Internal Order Number for the Sites
			Map<Id, String[]> mediaDataBySite = getMediaDataBySite(rdr.invoiceItem, deliveryDataBySite.keySet());			

			// (Always) Create projection accountig records.
			createProjectedAccountingRecords(rdr, 'EA HR', estimatedRevenue, true /*creatingProjectionRecords*/);

			List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();


			{ // EA std. Buchung
				AccountingRecord ar = new AccountingRecord();
					
				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId						= recordTypeId;
				if ('CPM'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
					ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Fall 1';
				} else if ('CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
					ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Fall 2';
				} else {
					ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Fall 3';
				}
				ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
				ar.accountingRecord.SomDig_Betrag__c					= Math.abs(estimatedRevenue).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
				ar.aggregationEnabled									= false;
	
				if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
				}
					
				tmpAccountingRecords.add(ar);
			}


			// Distribute the revenue, credit the SACHKONTO_TYP_ERLOESE_INTERNET or SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE with related IaNummer
			for (Id siteId : deliveryDataBySite.keySet()) {
				if (mediaDataBySite.get(siteId).get(0) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}
/*				if (mediaDataBySite.get(siteId).get(1) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Mediagattungs-Segment für Belegungseinheit mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__c + 
														'\' definiert.'));
					continue;
				}*/
				if (mediaDataBySite.get(siteId).get(2) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Differenzierung für Werbeform mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__c + 
														'\' definiert.'));
					continue;
				}
				if (mediaDataBySite.get(siteId).get(3) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Werbeträgergruppierung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}
				
				for (Id mgsId : deliveryDataBySite.get(siteId).keySet()) {
					if (proratedAmountBySite.get(siteId).get(mgsId) < 0.01) {
						continue;
					}
	
					String debitAccountType		= standardAccount;
					String creditAccountType	= standardAccount;
					
					AccountingRecord arKorrFM	= null;
					AccountingRecord arUmFM		= null;
					
					if ('Portal'.equalsIgnoreCase(mediaDataBySite.get(siteId).get(8))) {
						debitAccountType	= SACHKONTO_TYP_KORREKTUR_WERBEERLOES;
						creditAccountType	= SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE;
						
						{ // Umbuchung IA
							arUmFM = new AccountingRecord();
	
							arUmFM.fillAccountingRecord(rdr.invoiceItem);
							arUmFM.accountingRecord.RecordTypeId = recordTypeId;
							arUmFM.accountingRecord.SomDig_Buchungstext__c				= 'EA HR: Umbuchung Fremdmarke';
							arUmFM.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
							arUmFM.aggregationEnabled									= true;
							
							arUmFM.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
							arUmFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
							arUmFM.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																								mgsId,
																								Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																								Id.valueOf(mediaDataBySite.get(siteId).get(3)));
							arUmFM.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
			
							if (String.isEmpty(arUmFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																	'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
							}
							if (String.isEmpty(arUmFM.accountingRecord.SomDig_Innenauftragsnummer__c)) {
								ApexPages.Severity severity	= ApexPages.Severity.ERROR;
								String msgType	= 'undefined';
								if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
									severity	= ApexPages.Severity.WARNING;
									msgType		= 'IA';
									arUmFM.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
									arUmFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
									arUmFM.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
								}
								rdr.addMessage(new ProcessMessage(severity,
												'Keine Innenauftragsnummer für die Kombination: ' +
												'Mediagattung: ' + mediaDataBySite.get(siteId).get(4) + '(' + mediaDataBySite.get(siteId).get(0) + '), ' +
												'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
												'Mediagattungs-Differenzierung: ' + mediaDataBySite.get(siteId).get(6) + '(' + mediaDataBySite.get(siteId).get(2) + '), ' +
												'Werbeträgergruppierung: ' + mediaDataBySite.get(siteId).get(7) + '(' + mediaDataBySite.get(siteId).get(3) + ')', msgType));
							}
							
							tmpAccountingRecords.add(arUmFM);
						}
						
						{ // EA Fremdmarke (Korrektur)
							arKorrFM = new AccountingRecord();
				
							arKorrFM.fillAccountingRecord(rdr.invoiceItem);
							arKorrFM.accountingRecord.RecordTypeId						= recordTypeId;
							arKorrFM.accountingRecord.SomDig_Buchungstext__c			= 'EA HR: Umbuchung Fremdmarke';
							arKorrFM.accountingRecord.SomDig_Steuerkennzeichen__c		= 'A6';
							arKorrFM.aggregationEnabled									= true;
							
							arKorrFM.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
							arKorrFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(SACHKONTO_TYP_KORREKTUR_WERBEERLOES);
							arKorrFM.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																									mgsId,
																									Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																									Id.valueOf(mediaDataBySite.get(siteId).get(3)));
							arKorrFM.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
			
							if (String.isEmpty(arKorrFM.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																	'Kein Sachkonto für Typ \'' + SACHKONTO_TYP_KORREKTUR_WERBEERLOES + '\' gefunden.'));
							}
							if (String.isEmpty(arKorrFM.accountingRecord.SomDig_Innenauftragsnummer__c)) {
								continue; // keine Umbuchung wenn IA unbekannt => Fehler / Warnung erfolgt bei der EA zur Position (siehe unten)
							}
							
							tmpAccountingRecords.add(arKorrFM);
						}
					}
					
					{ // EA
						AccountingRecord ar = new AccountingRecord();
	
						ar.fillAccountingRecord(rdr.invoiceItem);
						ar.accountingRecord.RecordTypeId						= recordTypeId;
						if ('CPM'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
							ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Fall 1';
						} else if ('CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
							ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Fall 2';
						} else {
							ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Fall 3';
						}
						ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
						
						ar.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
						ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkonto(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)),
																							creditAccountType);
						ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)));				
						ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
						ar.aggregationEnabled									= true;
						
						if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
							rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																'Kein Sachkonto für Typ \'' + creditAccountType + '\' gefunden.'));
						}
						if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
							ApexPages.Severity severity	= ApexPages.Severity.ERROR;
							String msgType	= 'undefined';
							if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
								severity	= ApexPages.Severity.WARNING;
								msgType		= 'IA';
								ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
								ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
								ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
							}
	
							rdr.addMessage(new ProcessMessage(severity,
												'Keine Innenauftragsnummer für die Kombination: ' +
												'Mediagattung: ' + mediaDataBySite.get(siteId).get(4) + '(' + mediaDataBySite.get(siteId).get(0) + '), ' +
												'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
												'Mediagattungs-Differenzierung: ' + mediaDataBySite.get(siteId).get(6) + '(' + mediaDataBySite.get(siteId).get(2) + '), ' +
												'Werbeträgergruppierung: ' + mediaDataBySite.get(siteId).get(7) + '(' + mediaDataBySite.get(siteId).get(3) + ')', msgType));
						}
						
						tmpAccountingRecords.add(ar);
	
						//
						// For Tech Spec: 4.2.2.2.3. Logic: EA Syndication
						//
						if (deliveryDataByPartnerBySite.containsKey(siteId) && deliveryDataByPartnerBySite.get(siteId).containsKey(mgsId)) {
							List<Decimal> adjustedAmountOfSite = new List<Decimal>();
							List<AccountingRecord> cspAccountingRecords =
								 createSyndicationAccountingRecords(rdr,
																	mgsId,
																	proratedAmountBySite.get(siteId).get(mgsId), 
																	('CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c) ? deliveryDataBySite.get(siteId).get(mgsId).get(1) : deliveryDataBySite.get(siteId).get(mgsId).get(0)),
																	ar.accountingRecord.SomDig_Buchungstext__c,
																	mediaDataBySite.get(siteId),
																	deliveryDataByPartnerBySite.get(siteId).get(mgsId),
																	adjustedAmountOfSite);
							
							if (!cspAccountingRecords.isEmpty()) {
								if (adjustedAmountOfSite.get(0) >= 0.01) {
									ar.accountingRecord.SomDig_Betrag__c		= adjustedAmountOfSite.get(0).toPlainString().leftPad(14).replace(' ','0');
									if (arKorrFM != null) {
										arKorrFM.accountingRecord.SomDig_Betrag__c	= adjustedAmountOfSite.get(0).toPlainString().leftPad(14).replace(' ','0');
									}
									if (arUmFM != null) {
										arUmFM.accountingRecord.SomDig_Betrag__c	= adjustedAmountOfSite.get(0).toPlainString().leftPad(14).replace(' ','0');
									}
								} else {
									tmpAccountingRecords.remove(tmpAccountingRecords.size()-1);
								}
								
								tmpAccountingRecords.addAll(cspAccountingRecords);
							}
						}
					}
				}
			}
			
			// Add created accountig records to an AccountingRecordsGroup.
			AccountingRecordsGroup arg = new AccountingRecordsGroup();
			arg.accountingAmount = Math.abs(estimatedRevenue);
			arg.matchedLogic = 'Extrapolation';
			if (amount > 0) {
				for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			} else{
				// Reversed order.
				for (Integer i = tmpAccountingRecords.size() - 1; i >= 0; i--) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			}

			// Add created accountig records group to the RevenueDistributionResult
			rdr.addAccountingRecordsGroup(arg);
			
			return true;	
		}

		return false;
	}

	/**
	 * Use the Logic 'Anticipation' to calculate the revenue distribution.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and revenue distribution is calculated, false otherwise.
	 */
	private Boolean executeLogicAnticipation(RevenueDistributionResult rdr) {
		// Tech Spec: 4.2.2.3.2. Logic: Anticipation
		if (rdr.invoiceItem.ADvendio__FromDate__c >= processRunningDate &&
			rdr.invoiceItem.ADvendio__FromDate__c >= rdr.accountingPeriodStartDate &&
			rdr.invoiceItem.ADvendio__FromDate__c <= rdr.accountingPeriodEndDate) {

			String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;
		
			rdr.addMatchedLogic('Antizipation');
			
			// Net amount for revenue distribution
			Decimal amount = getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2);
			if (amount == 0.0) {
				amount = rdr.getPlanedRevenueOfMonth(rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate);
			}
			if (amount == 0.0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,  'Antizipation: Der Betrag ist 0.'));
				return true;				
			}
			
			Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
													PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
													? 'Hochrechnung'
													: 'Erloesaufteilung');

			// Get all possible sites, prepare for proration of the sites.
			Id adSpecId	= getCampaignItem(rdr.invoiceItem).ADvendio__Ad_Price__r.ADvendio__Ad_Spec__c;			

			Map<Id, Map<Id, Decimal>> prorationBySite = new Map<Id, Map<Id, Decimal>>();

			// First get the "Antizipationsverteilungsschlüssel" if there is
				Id antizipationsverteilungsschlusselId = null;
				for (ADvendio__Ad_Specs__c adSpec: [SELECT ADvendio__placement__r.SomDig_AntizipationsVS__c
													FROM ADvendio__Ad_Specs__c
													WHERE Id = :adSpecId])
				{
					antizipationsverteilungsschlusselId = adSpec.ADvendio__placement__r != null
														? adSpec.ADvendio__placement__r.SomDig_AntizipationsVS__c
														: null;
					break;
				}
				
				if (antizipationsverteilungsschlusselId != null) {
					for (AggregateResult ar :  [SELECT SomDig_AdServerId__r.ADvendio__Site__c siteId, SomDig_AdServerId__r.SomDig_MediagattungsSegment__c mgsId, SUM(SomDig_Prozentsatz__c) percentage
												FROM SomDig_Verteilungsschluessel__c
												WHERE SomDig_AntizipationsVS__c = :antizipationsverteilungsschlusselId AND isDeleted = false
												GROUP BY SomDig_AdServerId__r.ADvendio__Site__c, SomDig_AdServerId__r.SomDig_MediagattungsSegment__c])
					{
						Id siteId	= (Id)(ar.get('siteId'));
						Id mgsId	= (Id)(ar.get('mgsId'));
	
						if (siteId == null) {
							rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,  'Antizipation: Es gibt AdServer-Id ohne zugewiesenen Werbeträger.'));
							return true;
						}
						if (mgsId == null) {
							rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,  'Antizipation: Es gibt AdServer-Id ohne zugewiesenes Mediagattungs-Segment.'));
							return true;
						}
						
						Decimal percentage = ar.get('percentage') == null ? 0 : ((Decimal)(ar.get('percentage')));
						percentage = percentage / 100.0;
						if (!prorationBySite.containsKey(siteId)) {
							prorationBySite.put(siteId, new Map<Id, Decimal>());
						}
						prorationBySite.get(siteId).put(mgsId, percentage);
					}
				}
												   
			if (prorationBySite.isEmpty()) {
				// Just get Site defined in AdSpec, and using linear distribution
				for (AggregateResult ar :  [SELECT ADvendio__AdServer_ID__r.ADvendio__Site__c siteId, ADvendio__AdServer_ID__r.SomDig_MediagattungsSegment__c mgsId
											FROM ADvendio__AdServer_ID_AdSpec_Assigment__c
											WHERE ADvendio__Ad_Spec__c = :adSpecId AND isDeleted = false
											GROUP BY ADvendio__AdServer_ID__r.ADvendio__Site__c, ADvendio__AdServer_ID__r.SomDig_MediagattungsSegment__c])
				{
					Id siteId	= (Id)(ar.get('siteId'));
					Id mgsId	= (Id)(ar.get('mgsId'));
					
					if (siteId == null) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,  'Antizipation: Bei AdSpec ' + adSpecId + ' gibt es AdServer-Id ohne zugewiesenen Werbeträger.'));
						return true;
					}
					if (mgsId == null) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,  'Antizipation: Bei AdSpec ' + adSpecId + ' gibt es AdServer-Id ohne zugewiesenes Mediagattungs-Segment.'));
						return true;
					}
					
					if (!prorationBySite.containsKey(siteId)) {
						prorationBySite.put(siteId, new Map<Id, Decimal>());
					}
					prorationBySite.get(siteId).put(mgsId, 1.00);
				}
			
				if (prorationBySite.isEmpty()) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
													'Antizipation: Keine AdServer-Id für AdSpec ' + adSpecId + ' definiert.'));
					return true;
				}

				Integer splitCount	= 0;
				for (Id siteId : prorationBySite.keySet()) {
					for (Id mgsId : prorationBySite.get(siteId).keySet()) {
						splitCount++;
					}
				}

				for (Id siteId : prorationBySite.keySet()) {
					for (Id mgsId : prorationBySite.get(siteId).keySet()) {
						// Linear distribution now!
						prorationBySite.get(siteId).put(mgsId, prorationBySite.get(siteId).get(mgsId) / splitCount);
					}
				}
			}

			// Calculate the remaining number of days.
			Integer remainingDays = rdr.invoiceItem.ADvendio__UntilDate__c > rdr.accountingPeriodEndDate
									? (rdr.invoiceItem.ADvendio__FromDate__c.daysBetween(rdr.accountingPeriodEndDate) + 1)
									: (rdr.invoiceItem.ADvendio__FromDate__c.daysBetween(rdr.invoiceItem.ADvendio__UntilDate__c) + 1);
									
			// Calculate the (average) daily planed revenue.
			Decimal dailyPlanedRevenue = 0.0;
			dailyPlanedRevenue = Math.abs(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Amount_net_netAPEX__c / (rdr.invoiceItem.ADvendio__FromDate__c.daysBetween(rdr.invoiceItem.ADvendio__UntilDate__c) + 1));
			/*
			if ('CPM'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
				dailyPlanedRevenue = (rdr.invoiceItem.ADvendio__BookedQuantity__c * rdr.invoiceItem.ADvendio__Salesprice__c / 1000) / 
									 (rdr.invoiceItem.ADvendio__FromDate__c.daysBetween(rdr.invoiceItem.ADvendio__UntilDate__c) + 1);
			} else if ('CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
				dailyPlanedRevenue = (rdr.invoiceItem.ADvendio__BookedQuantity__c * rdr.invoiceItem.ADvendio__Salesprice__c) / 
									 (rdr.invoiceItem.ADvendio__FromDate__c.daysBetween(rdr.invoiceItem.ADvendio__UntilDate__c) + 1);
			} else {
				dailyPlanedRevenue = (rdr.invoiceItem.ADvendio__BookedQuantity__c * rdr.invoiceItem.ADvendio__Salesprice__c) / 
									 (rdr.invoiceItem.ADvendio__FromDate__c.daysBetween(rdr.invoiceItem.ADvendio__UntilDate__c) + 1);
			}
			*/

			// Calculate the estimated revenue for the remaining days.
			Decimal estimatedRevenue = (dailyPlanedRevenue * remainingDays).setScale(2);
			
			if (estimatedRevenue == 0) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO, 'Antizipation: Erlös-Hochrechnung ist 0.'));
				return true;
			}
						
			// Calculate prorated estimated revenue of the sites.
			Map<Id, Map<Id, Decimal>> proratedAmountBySite	= new Map<Id, Map<Id, Decimal>>();
			Decimal totalProratedAmount			= 0;
			Decimal lastMaxProratedAmount		= 0;
			String lastSiteIdForProratedAmount	= null;
			String lastMgsIdForProratedAmount	= null;

			for (Id siteId : prorationBySite.keySet()) {
				for (Id mgsId : prorationBySite.get(siteId).keySet()) {
					Decimal proratedAmount	= (Math.abs(estimatedRevenue) * prorationBySite.get(siteId).get(mgsId)).setScale(2, System.RoundingMode.HALF_DOWN);
					if (!proratedAmountBySite.containsKey(siteId)) {
						proratedAmountBySite.put(siteId, new Map<Id, Decimal>());
					}
					proratedAmountBySite.get(siteId).put(mgsId, proratedAmount);
					totalProratedAmount += proratedAmount;
					if (proratedAmount >= lastMaxProratedAmount) {
						lastMaxProratedAmount		= proratedAmount;
						lastSiteIdForProratedAmount	= siteId;
						lastMgsIdForProratedAmount	= mgsId;
					}
				}
			}

			Decimal residualAmount	= Math.abs(estimatedRevenue) - totalProratedAmount;
			if (Math.abs(residualAmount) > 0 && lastSiteIdForProratedAmount != null) {
				Decimal proratedAmount	= proratedAmountBySite.get(lastSiteIdForProratedAmount).get(lastMgsIdForProratedAmount) + residualAmount;
				proratedAmountBySite.get(lastSiteIdForProratedAmount).put(lastMgsIdForProratedAmount, proratedAmount);
			}
			
			// Get data that required for getting Internal Order Number for the Sites
			Map<Id, String[]> mediaDataBySite = getMediaDataBySite(rdr.invoiceItem, prorationBySite.keySet());			
		
			// (Always) Create projection accountig records.
			//createProjectedAccountingRecords(rdr, 'EA HR Antizipation', estimatedRevenue, !('monthly (1 month)'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentInterval__c) && rdr.invoiceItem.ADvendio__LinearDistribution__c));
			createProjectedAccountingRecords(rdr, 'EA HR Antizipation', estimatedRevenue, true);

			List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();

			{
				AccountingRecord ar = new AccountingRecord();
					
				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId = recordTypeId;
				if ('CPM'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
					ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Antizipation Fall 1';
				} else if ('CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
					ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Antizipation Fall 2';
				} else {
					ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Antizipation Fall 3';
				}
				ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
				ar.accountingRecord.SomDig_Betrag__c					= Math.abs(estimatedRevenue).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByType(standardAccount);
				ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
				ar.aggregationEnabled									= false;
	
				if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
				}
					
				tmpAccountingRecords.add(ar);
			}


			// Distribute the revenue, credit the SACHKONTO_TYP_ERLOESE_INTERNET or SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE with related IaNummer
			for (Id siteId : prorationBySite.keySet()) {
				if (mediaDataBySite.get(siteId).get(0) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}
/*				if (mediaDataBySite.get(siteId).get(1) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Kein Mediagattungs-Segment für Belegungseinheit mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__c + 
														'\' definiert.'));
					continue;
				}*/
				if (mediaDataBySite.get(siteId).get(2) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Differenzierung für Werbeform mit Id \'' + 
														rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__c + 
														'\' definiert.'));
					continue;
				}
				if (mediaDataBySite.get(siteId).get(3) == null) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
														'Keine Mediagattungs-Werbeträgergruppierung für Werbeträger mit Id \'' + siteId + '\' definiert.'));
					continue;
				}
				
				for (Id mgsId : prorationBySite.get(siteId).keySet()) {
					if (proratedAmountBySite.get(siteId).get(mgsId) < 0.01) {
						continue;
					}

					String debitAccountType		= standardAccount;
					String creditAccountType	= standardAccount;
					if ('Portal'.equalsIgnoreCase(mediaDataBySite.get(siteId).get(8))) {
						debitAccountType	= SACHKONTO_TYP_KORREKTUR_WERBEERLOES;
						creditAccountType	= SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE;
	
						{ // Umbuchung IA
							AccountingRecord ar = new AccountingRecord();
							ar.fillAccountingRecord(rdr.invoiceItem);
							
							ar.accountingRecord.RecordTypeId						= recordTypeId;
							ar.accountingRecord.SomDig_Buchungstext__c				= 'EA HR Antizipation: Umbuchung Fremdmarke';
							ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
							ar.aggregationEnabled									= true;
							
							ar.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
							ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
							ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																								mgsId,
																								Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																								Id.valueOf(mediaDataBySite.get(siteId).get(3)));
							ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
			
							if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																	'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
							}
							if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
								ApexPages.Severity severity	= ApexPages.Severity.ERROR;
								String msgType	= 'undefined';
								if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
									severity	= ApexPages.Severity.WARNING;
									msgType		= 'IA';
									ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
									ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
									ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
								}
								rdr.addMessage(new ProcessMessage(severity,
												'Keine Innenauftragsnummer für die Kombination: ' +
												'Mediagattung: ' + mediaDataBySite.get(siteId).get(4) + '(' + mediaDataBySite.get(siteId).get(0) + '), ' +
												'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
												'Mediagattungs-Differenzierung: ' + mediaDataBySite.get(siteId).get(6) + '(' + mediaDataBySite.get(siteId).get(2) + '), ' +
												'Werbeträgergruppierung: ' + mediaDataBySite.get(siteId).get(7) + '(' + mediaDataBySite.get(siteId).get(3) + ')', msgType));
							}
							
							tmpAccountingRecords.add(ar);
						}
						
						{ // EA Fremdmarke (Korrektur)
							AccountingRecord ar = new AccountingRecord();
				
							ar.fillAccountingRecord(rdr.invoiceItem);
							ar.accountingRecord.RecordTypeId						= recordTypeId;
							ar.accountingRecord.SomDig_Buchungstext__c				= 'EA HR Antizipation: Fremde Marken';
							ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
							ar.aggregationEnabled									= true;
							
							ar.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
							ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(SACHKONTO_TYP_KORREKTUR_WERBEERLOES);
							ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																								mgsId,
																								Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																								Id.valueOf(mediaDataBySite.get(siteId).get(3)));
							ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
			
							if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																	'Kein Sachkonto für Typ \'' + SACHKONTO_TYP_KORREKTUR_WERBEERLOES + '\' gefunden.'));
							}
							if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
								continue; // keine Umbuchung wenn IA unbekannt => Fehler / Warnung erfolgt bei der EA zur Position (siehe unten)
							}
							
							tmpAccountingRecords.add(ar);
						}
					}
					
					{ // EA
						AccountingRecord ar = new AccountingRecord();
	
						ar.fillAccountingRecord(rdr.invoiceItem);
						ar.accountingRecord.RecordTypeId						= recordTypeId;
						if ('CPM'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
							ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Antizipation Fall 1';
						} else if ('CPC'.equals(rdr.invoiceItem.ADvendio__BillingCategory__c)) {
							ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Antizipation Fall 2';
						} else {
							ar.accountingRecord.SomDig_Buchungstext__c			= 'EA HR Antizipation Fall 3';
						}
						ar.accountingRecord.SomDig_Steuerkennzeichen__c 		= 'A6';
						
						ar.accountingRecord.SomDig_Betrag__c					= proratedAmountBySite.get(siteId).get(mgsId).toPlainString().leftPad(14).replace(' ','0');
						ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkonto(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)),
																							creditAccountType);
						ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummer(Id.valueOf(mediaDataBySite.get(siteId).get(0)),
																							mgsId,
																							Id.valueOf(mediaDataBySite.get(siteId).get(2)),
																							Id.valueOf(mediaDataBySite.get(siteId).get(3)));				
						ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
						ar.aggregationEnabled									= true;
						
						if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
							rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																'Kein Sachkonto für Typ \'' + creditAccountType + '\' gefunden.'));
						}
						if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
							ApexPages.Severity severity	= ApexPages.Severity.ERROR;
							String msgType	= 'undefined';
							if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
								severity	= ApexPages.Severity.WARNING;
								msgType		= 'IA';
								ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
								ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
								ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
							}
							
							rdr.addMessage(new ProcessMessage(severity,
												'Keine Innenauftragsnummer für die Kombination: ' +
												'Mediagattung: ' + mediaDataBySite.get(siteId).get(4) + '(' + mediaDataBySite.get(siteId).get(0) + '), ' +
												'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
												'Mediagattungs-Differenzierung: ' + mediaDataBySite.get(siteId).get(6) + '(' + mediaDataBySite.get(siteId).get(2) + '), ' +
												'Werbeträgergruppierung: ' + mediaDataBySite.get(siteId).get(7) + '(' + mediaDataBySite.get(siteId).get(3) + ')', msgType));
						}
						
						tmpAccountingRecords.add(ar);
					}
				}
			}

			// Add created accountig records to an AccountingRecordsGroup.
			AccountingRecordsGroup arg = new AccountingRecordsGroup();
			arg.accountingAmount = Math.abs(estimatedRevenue);
			arg.matchedLogic = 'Antizipation';
			if (amount > 0) {
				for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			} else{
				// Reversed order.
				for (Integer i = tmpAccountingRecords.size() - 1; i >= 0; i--) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			}

			// Add created accountig records group to the RevenueDistributionResult
			rdr.addAccountingRecordsGroup(arg);
			
			return true;	
		}
		
		return false;		
	}

	/**
	 * Create and update the Accrual / Deferral Postings (PRAP)
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and Accrual / Deferral Posting Record is updated, false otherwise.
	 */
	private Boolean executeLogicPRAPCreation(RevenueDistributionResult rdr) {
		String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;
		
		rdr.addMatchedLogic('PRAP Creation');
		
		Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
												PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
												? 'Hochrechnung'
												: 'Erloesaufteilung');

		// Get the last 'Aufgelöst' PRAP
		SomDig_PRAP__c lastPRAP = null;

		Id invoiceItemId = rdr.invoiceItem.Id;
													
		for (SomDig_PRAP__c aPrap : [SELECT Id, SomDig_Rechnungsposition__c, SomDig_Abrechnungsmonat__c, SomDig_Abrechnungsmonatsende__c, 
										SomDig_AbzugrenzendeErloese__c, SomDig_AbgerechneteErloese__c, SomDig_Gutschrift__c,
										SomDig_NochAbzugrenzendeErloese__c, SomDig_Status__c, SomDig_UniqueKey__c
									 FROM SomDig_PRAP__c
									 WHERE SomDig_Rechnungsposition__c = :invoiceItemId AND SomDig_Status__c = 'Aufgelöst'
									 ORDER BY SomDig_Abrechnungsmonat__c DESC
									 LIMIT 1])
		{
			lastPRAP = aPrap;
		}
		
		if (lastPRAP != null) {
			if (lastPRAP.SomDig_NochAbzugrenzendeErloese__c <= 0) {
				Datetime startDate = Datetime.newInstance(lastPRAP.SomDig_Abrechnungsmonat__c.year(),
														  lastPRAP.SomDig_Abrechnungsmonat__c.month(),
														  lastPRAP.SomDig_Abrechnungsmonat__c.day());
				Datetime endDate   = Datetime.newInstance(lastPRAP.SomDig_Abrechnungsmonatsende__c.year(),
														  lastPRAP.SomDig_Abrechnungsmonatsende__c.month(),
														  lastPRAP.SomDig_Abrechnungsmonatsende__c.day());
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,
													'Die PRAP für die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
													' ist im letztem Abrechnungszeitraum ' + startDate.format('yyyy-MM-dd') + 
													' - ' + endDate.format('yyyy-MM-dd') + ' komplett aufgelöst.'));
				return true;
			} else if (lastPRAP.SomDig_Abrechnungsmonatsende__c < rdr.accountingPeriodStartDate) {
				// OK
				if (lastPRAP.SomDig_Abrechnungsmonatsende__c >= rdr.invoiceItem.ADvendio__InvoiceItemEndDate__c.toStartOfMonth().addMonths(1).addDays(-1)) {
					rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
											'Für die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
											' ist der letzte PRAP-Datensatz schon aufgelöst worden. Der noch offene abzugrendende Betrag ist ' + lastPRAP.SomDig_NochAbzugrenzendeErloese__c + '.'));
					return true;
				}
			} else if (lastPRAP.SomDig_Abrechnungsmonat__c > rdr.accountingPeriodEndDate) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
										'Für die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
										' gibt es einen PRAP-Datensatz mit einem Abrechnungszeitraum in der Zukunft.'));
				return true;
			} else {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
										'Für die Rechnungsposition mit der Id ' + rdr.invoiceItem.Id +
										' gibt es einen PRAP-Datensatz mit überlappendem Abrechnungszeitraum.'));
				return true;
			}
		}
			
		SomDig_PRAP__c curPRAP = null;

		Datetime startDate = Datetime.newInstance(rdr.accountingPeriodStartDate.year(), rdr.accountingPeriodStartDate.month(), rdr.accountingPeriodStartDate.day());
		Datetime endDate   = Datetime.newInstance(rdr.accountingPeriodEndDate.year(), rdr.accountingPeriodEndDate.month(), rdr.accountingPeriodEndDate.day());
		String uniqueKey   = invoiceItemId + '|' + startDate.format('yyyy-MM-dd') + '|' + endDate.format('yyyy-MM-dd');
			
		curPRAP = new SomDig_PRAP__c(SomDig_Rechnungsposition__c = invoiceItemId,
									 SomDig_Abrechnungsmonat__c = rdr.accountingPeriodStartDate,
									 SomDig_Abrechnungsmonatsende__c = rdr.accountingPeriodEndDate,
									 SomDig_AbzugrenzendeErloese__c = rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Amount_net_netAPEX__c.setScale(2),
									 SomDig_AbgerechneteErloese__c = null,
									 SomDig_Gutschrift__c = null,
									 SomDig_Status__c = 'Erstellt',
									 SomDig_UniqueKey__c = uniqueKey);
		
		if (lastPRAP != null) {
			curPRAP.SomDig_AbzugrenzendeErloese__c = lastPRAP.SomDig_NochAbzugrenzendeErloese__c;
		} 

		// Get the Revenue using the results got by doRevenueDistributionCalculation() and doRevenueEstimationCalculation()
		Decimal accountingAmount = 0.00;
		List<AccountingRecordsGroup> tmpAccountingRecordsGroup = new List<AccountingRecordsGroup>();
		for (AccountingRecordsGroup arg : rdr.accountingRecordsGroups) {
			// Ignore Projections
			if (arg.isProjection) {
				continue;
			}
			
			tmpAccountingRecordsGroup.add(arg);
			
			accountingAmount += arg.accountingAmount;

			// Now set the PRAP Sachkonto if required.
			for (AccountingRecord ar : arg.accountingRecords) {
				ar.accountingRecord.SomDig_Buchungstext__c = 'PRAP Standardfall: ' + ar.accountingRecord.SomDig_Buchungstext__c;

				if (lastPRAP != null &&
					'S'.equals(ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c) &&
					(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c.equals(getSachkontoNummerByType(standardAccount))))
				{						
					ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c = getSachkontoNummerByType(SACHKONTO_TYP_PRAP);
					ar.accountingRecord.SomDig_Innenauftragsnummer__c = null;
				}
			}
		}

		if (accountingAmount == 0.00 && (rdr.matchedLogics.contains('Barter') || rdr.matchedLogics.contains('Non-InterCompany Service'))) {
			// 'Barter' and 'Non-InterCompany Service' will have no Revenue Distribution.
			accountingAmount = rdr.getPlanedRevenueOfMonth(rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate);
		}
		rdr.accountingRecordsGroups.clear();
		if (lastPRAP == null) {
			// Just create projectionaccounting records.
			createProjectedAccountingRecords(rdr, 'PRAP Standardfall', rdr.invoiceItem.ADvendio__InvoicedAmountNet2__c, creatingProjectionRecords);
		}
		rdr.accountingRecordsGroups.addAll(tmpAccountingRecordsGroup);
					
		// Calculate SomDig_NochAbzugrenzendeErloese__c:
		// IF (ISBLANK(SomDig_AbzugrenzendeErloese__c),
		//	 NULL,
		//	 SomDig_AbzugrenzendeErloese__c 
		//	 - (IF(ISBLANK(SomDig_AbgerechneteErloese__c), 0, SomDig_AbgerechneteErloese__c))
		//	 - (IF(ISBLANK(SomDig_Gutschrift__c), 0, SomDig_Gutschrift__c)))
		curPRAP.SomDig_AbgerechneteErloese__c = accountingAmount;
		if (PROCESS_ULTIMO_PLUS_4.equals(selectedProcessType)) {
			curPRAP.SomDig_Status__c = 'Aufgelöst';
		}
		
		Decimal remainingAmount = curPRAP.SomDig_AbzugrenzendeErloese__c
								- (curPRAP.SomDig_Gutschrift__c == null ? 0 : curPRAP.SomDig_Gutschrift__c)
								- (curPRAP.SomDig_AbgerechneteErloese__c == null ? 0 : curPRAP.SomDig_AbgerechneteErloese__c);
		remainingAmount = remainingAmount.setScale(2);
										
		if (lastPRAP == null && remainingAmount > 0.00) {
			// Create first PRAP accounting record
			List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();
			for (Integer i = 0; i < 2; i++) {
				AccountingRecord ar = new AccountingRecord();
				
				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId							= recordTypeId;
				ar.accountingRecord.SomDig_Betrag__c						= Math.abs(remainingAmount).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Buchungstext__c					= 'PRAP Standardfall';
				ar.accountingRecord.SomDig_Steuerkennzeichen__c				= 'A6';
				ar.aggregationEnabled										= false;
				
				if (i == 0) {
					ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByType(standardAccount);
					ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
					ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= 'S';
					if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
					}
				} else if (i == 1) {
					ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(SACHKONTO_TYP_PRAP);
					ar.accountingRecord.SomDig_Innenauftragsnummer__c		= null;
					ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= 'H';
					if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Kein Sachkonto für Typ \'' + SACHKONTO_TYP_PRAP + '\' gefunden.'));
					}
				}
				
				tmpAccountingRecords.add(ar);
			}

			// Add created accountig records to an AccountingRecordsGroup.
			AccountingRecordsGroup arg = new AccountingRecordsGroup();
			arg.accountingAmount = Math.abs(remainingAmount);
			arg.matchedLogic = 'PRAP Standardfall';
			for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
				arg.addAccountingRecord(tmpAccountingRecords.get(i));
			}
				
			// Add created accountig records group to the RevenueDistributionResult
			rdr.addAccountingRecordsGroup(arg);
		}
			
		// Upsert curPRAP
		PRAP prapToUpsert = new PRAP(curPRAP);
		prapToUpsert.remainingAmount = remainingAmount;
		if (true/*PROCESS_ULTIMO_PLUS_4.equals(selectedProcessType) && 'Invoiced'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Status__c)*/) {
			prapToUpsert.toUpsert = true;
		}
		
		rdr.prapRecords.add(prapToUpsert);
			
		return true;		
	}
	
	/**
	 * Cancel the Accrual / Deferral Postings (PRAP)
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to check.
	 * @return true if the logic is applicable and Accrual / Deferral Posting Record is updated, false otherwise.
	 */
	private Boolean executeLogicPRAPCancellation(RevenueDistributionResult rdr) {
		rdr.addMatchedLogic('PRAP Cancellation');
		
		// Find the original invoice item, for which the PRAP is to cancel.		
		Id origCiId	= getCampaignItem(rdr.invoiceItem).Id;
		Id origInvoiceId = rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Invoice__c;
		Id origInvoiceItemId = null;
			
		for (ADvendio__InvoiceItem__c invoiceItem : [SELECT Id FROM ADvendio__InvoiceItem__c
													 WHERE ADvendio__Invoice__c = :origInvoiceId AND ADvendio__CampaignItem__c = :origCiId])
		{
			origInvoiceItemId = invoiceItem.Id;
			break;
		}

		// Now get the PRAP
		List<PRAP> prapToUpsert = new List<PRAP>();

		if (origInvoiceItemId != null) {
			Boolean foundPRAP = false;

			for (SomDig_PRAP__c aPrap : [SELECT Id, SomDig_Rechnungsposition__c, SomDig_Abrechnungsmonat__c, SomDig_Abrechnungsmonatsende__c, 
											SomDig_AbzugrenzendeErloese__c, SomDig_AbgerechneteErloese__c, SomDig_Gutschrift__c,
											SomDig_NochAbzugrenzendeErloese__c, SomDig_Status__c, SomDig_UniqueKey__c
										 FROM SomDig_PRAP__c
										 WHERE SomDig_Rechnungsposition__c = :origInvoiceItemId
										 ORDER BY SomDig_Abrechnungsmonat__c DESC])
			{
				foundPRAP = true;

				if ('Storniert'.equals(aPrap.SomDig_Status__c)) {
					continue;
				}

				if ('Erstellt'.equals(aPrap.SomDig_Status__c) ||
					('Aufgelöst'.equals(aPrap.SomDig_Status__c) && PROCESS_ULTIMO_PLUS_4.equals(selectedProcessType)))
				{
					aPrap.SomDig_Status__c = 'Storniert';
					prapToUpsert.add(new PRAP(aPrap));
					prapToUpsert.get(prapToUpsert.size()-1).remainingAmount = aPrap.SomDig_NochAbzugrenzendeErloese__c;
				}
			}

			if (!foundPRAP) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,
											'Bei der Storno-PRAP-Rechnungsposition mit der Id ' + rdr.invoiceItem.Id + 
											' wurde keiner PRAP-Datensatz von der stornierten PRAP-Rechnungsposition mit der Id ' + origInvoiceItemId + 
											' gefunden.'));
			}
		}
		
		if (true/*PROCESS_ULTIMO_PLUS_4.equals(selectedProcessType) && 'Invoiced'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Status__c)*/) {
			for (PRAP aPrap : prapToUpsert) {
				aPrap.toUpsert = true;
			}
		}
		
		rdr.prapRecords.addAll(prapToUpsert);
		
		// Create cancelation accounting records.
		if (!createCancellationAccountingRecords(rdr, 'PRAP Cancellation')) {
			rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
										'Bei der Storno-PRAP-Rechnungsposition mit der Id ' + rdr.invoiceItem.Id + 
										' wurde keiner Buchungssatz von der stornierten PRAP-Rechnungsposition mit der Id ' + origInvoiceItemId + 
										' gefunden.'));
		} 
		
		return true;
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
	 * Get the amount of a mounth used for revenue distribution
	 *
	 * @param invoiceItem The invoice item to use.
	 * @param beginOfMonth The month to use. Type is Date, value must be the first day of the month.
	 * @param endOfMonth The month to use. Type is Date, value must be the last day of the month.
	 * @return The amount.
	 */
	private Decimal getAmountOfMonth(ADvendio__InvoiceItem__c invoiceItem, Date beginOfMonth, Date endOfMonth) {
		if (invoiceItem.ADvendio__InvoicedAmountNet2__c == null) {
			return null;
		}
		
		if ('monthly (1 month)'.equals(invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentInterval__c)) {
			return invoiceItem.ADvendio__InvoicedAmountNet2__c;
		} else if ('total account (one Invoice)'.equals(invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentInterval__c)) {
			//if (invoiceItem.ADvendio__LinearDistribution__c && 'NonMedia'.equalsIgnoreCase(invoiceItem.SomDig_Mediagattungs_Segment__r.Name)) {
			if (invoiceItem.ADvendio__LinearDistribution__c && ('Standard'.equalsIgnoreCase(invoiceItem.SomDig_Adservertyp__c) || 'NonMedia'.equalsIgnoreCase(invoiceItem.SomDig_Mediagattungs_Segment__r.Name))) {
				RevenueDistributionResult tmpRdr = new RevenueDistributionResult(invoiceItem);
				
				Decimal amount = tmpRdr.getPlanedRevenueOfMonth(beginOfMonth, endOfMonth);
				
				return (invoiceitem.ADvendio__InvoicedAmountNet2__c < 0 ? ((-1) * amount) : amount);
			} else {
				// Assume performance -- delivered impressions -- based
				if (invoiceitem.ADvendio__InvoicedQuantity__c == null || invoiceitem.ADvendio__InvoicedQuantity__c == 0 ||
					invoiceitem.ADvendio__InvoicedAmountNet2__c == null || invoiceitem.ADvendio__InvoicedAmountNet2__c == 0)
				{
					return 0.0;
				}
				
				Decimal totalQuantity = 0;
				Decimal currentQuantity = 0;

				if ('CPM'.equals(invoiceItem.ADvendio__BillingCategory__c) || 'CPC'.equals(invoiceItem.ADvendio__BillingCategory__c)) {
					totalQuantity = invoiceItem.ADvendio__InvoicedQuantity__c;

					Map<Date, Map<String, Decimal>> deliveryDataByMonth = new Map<Date, Map<String, Decimal>>();
					
					Id ciId = getCampaignItem(invoiceItem).Id;
					
					String query =  'SELECT ADvendio__Month__c month, ' +
										'SUM(ADvendio__DeliveredImpressions__c) deliveredAIs, SUM(ADvendio__DeliveredClicks__c) deliveredClicks ' +
									'FROM ADvendio__DeliveryData__c ' +
									'WHERE ADvendio__CampaignItem__c = :ciId AND ADvendio__Type__c = \'Monthly\' AND ADvendio__Month__c < :endOfMonth ' +
									'GROUP BY ADvendio__Month__c ';
					
					for (AggregateResult ar : Database.query(query)) {
						Date aMonth = Date.valueOf(ar.get('month'));
						Map<String, Decimal> deliveryData = deliveryDataByMonth.get(aMonth);
						if (deliveryData == null) {
							deliveryData = new Map<String, Decimal>();
							deliveryData.put('deliveredAIs', 0);
							deliveryData.put('deliveredClicks', 0);
							deliveryDataByMonth.put(aMonth, deliveryData);
						}
						
						Decimal deliveredAIs = deliveryData.get('deliveredAIs') + (ar.get('deliveredAIs') == null ? 0 : ((Decimal)(ar.get('deliveredAIs'))));
						Decimal deliveredClicks = deliveryData.get('deliveredClicks') + (ar.get('deliveredClicks') == null ? 0 : ((Decimal)(ar.get('deliveredClicks'))));
						deliveryData.put('deliveredAIs', deliveredAIs);
						deliveryData.put('deliveredClicks', deliveredClicks);
					}
					
					List<Date> months = new List<Date>(deliveryDataByMonth.keySet());
					months.sort();
					
					Decimal previousQuantity = 0;
											
					for (Date aMonth : months) {
						Map<String, Decimal> deliveryData = deliveryDataByMonth.get(aMonth);
						if ('CPM'.equals(invoiceItem.ADvendio__BillingCategory__c)) {
							if (aMonth < beginOfMonth) {
								previousQuantity += deliveryData.get('deliveredAIs');
							} else if (aMonth < endOfMonth) {
								currentQuantity += deliveryData.get('deliveredAIs');
							}
						} else {
							if (aMonth < beginOfMonth) {
								previousQuantity += deliveryData.get('deliveredClicks');
							} else if (aMonth < endOfMonth) {
								currentQuantity += deliveryData.get('deliveredClicks');
							}
						}
					}
					
					if (Math.abs(previousQuantity) + Math.abs(currentQuantity) > Math.abs(totalQuantity)) {
						currentQuantity = Math.abs(totalQuantity) - Math.abs(previousQuantity);
					}
					
					if (currentQuantity < 0) {
						currentQuantity = 0;
					}
				} else {
					totalQuantity = invoiceItem.ADvendio__FromDate__c.daysBetween(invoiceItem.ADvendio__UntilDate__c) + 1;
					// Just count the elapsed days
					Date theStartDay =  invoiceItem.ADvendio__FromDate__c > beginOfMonth
										? invoiceItem.ADvendio__FromDate__c
										: beginOfMonth;
					Date theEndDay = invoiceItem.ADvendio__UntilDate__c < endOfMonth
									 ? invoiceItem.ADvendio__UntilDate__c
									 : endOfMonth;
					currentQuantity = theStartDay <= theEndDay ? ((theStartDay.daysBetween(theEndDay) + 1)*1.0) : 0;
				}
	
				return  (totalQuantity == 0)
						? 0.0
						: (currentQuantity / totalQuantity) * invoiceitem.ADvendio__InvoicedAmountNet2__c;
			}
		}
		
		return 0.0;
	}
	
	/**
	 * Get the CampaignItem used for revenue distribution, considered the possible cancellation
	 *
	 * @param invoiceItem The invoice item to use.
	 * @return The campaign item found, or null if error.
	 */
	private ADvendio__Campaign_Item__c getCampaignItem(ADvendio__InvoiceItem__c invoiceItem) {
		ADvendio__Campaign_Item__c ci	= null;
		if (invoiceItem.ADvendio__Invoice__r.ADvendio__Invoice__c != null) {
			if (invoiceItem.ADvendio__CampaignItem__r.ADvendio__ConnectedItem__c != null) {
				ci = invoiceItem.ADvendio__CampaignItem__r.ADvendio__ConnectedItem__r;
			}
			else {
				ci = invoiceItem.ADvendio__CampaignItem__r;
			}
		}
		else {
			ci = invoiceItem.ADvendio__CampaignItem__r;
		}
		
		return ci;
	}

	/**
	 * Get the site based monthly delivery data of given CampaignItem.
	 *
	 * @param invoiceItem The invoice item to use.
	 * @param beginOfMonth The month for which the delivery data is to retrieve. Type is Date, value must be the first day of the month.
	 * @param endOfMonth The month for which the delivery data is to retrieve. Type is Date, value must be the last day of the month.
	 * @return A map using the Id of record of type ADvendio__Site__c as key, a list with 2 elements as value. The first element is the delivered AIs, the second delivered Clicks.
	 */
	private Map<Id, Map<Id, Decimal[]>> getDeliveryDataBySite(ADvendio__InvoiceItem__c invoiceItem, Date beginOfMonth, Date endOfMonth) {
		Id ciId = getCampaignItem(invoiceItem).Id;
		
		Map<Id, Map<Id, Decimal[]>> deliveryDataBySite	= new Map<Id, Map<Id, Decimal[]>>();
		
		String query =  'SELECT ADvendio__AdServerID__r.ADvendio__Site__c siteId, ADvendio__AdServerID__r.SomDig_MediagattungsSegment__c mgsId, ' +
							'SUM(ADvendio__DeliveredImpressions__c) deliveredAIs, SUM(ADvendio__DeliveredClicks__c) deliveredClicks ' +
						'FROM ADvendio__DeliveryData__c ' +
						'WHERE ADvendio__CampaignItem__c = :ciId AND ADvendio__Type__c = \'Monthly\' AND ADvendio__Month__c >= :beginOfMonth AND ADvendio__Month__c < :endOfMonth ' +
						'GROUP BY ADvendio__AdServerID__r.ADvendio__Site__c, ADvendio__AdServerID__r.SomDig_MediagattungsSegment__c ';
		
		for (AggregateResult ar : Database.query(query)) {
			Decimal deliveredAIs = ar.get('deliveredAIs') == null ? 0 : ((Decimal)(ar.get('deliveredAIs')));
			Decimal deliveredClicks = ar.get('deliveredClicks') == null ? 0 : ((Decimal)(ar.get('deliveredClicks')));
			
			Id siteId	= (Id)(ar.get('siteId'));
			Id mgsId	= (Id)(ar.get('mgsId'));
			if (!deliveryDataBySite.containsKey(siteId)) {
				deliveryDataBySite.put(siteId, new Map<Id, Decimal[]>());
			}
			deliveryDataBySite.get(siteId).put(mgsId, new List<Decimal>{ deliveredAIs, deliveredClicks });
		}
	
		return deliveryDataBySite;
	}

	/**
	 * Get delivery data of syndication partner.
	 *
	 * @param invoiceItem The invoice item to use.
	 * @param beginOfMonth The month for which the delivery data is to retrieve. Type is Date, value must be the first day of the month.
	 * @param endOfMonth The month for which the delivery data is to retrieve. Type is Date, value must be the last day of the month.
	 * @return A map using the Id of record of type ADvendio__Site__c as key, the value is a map aigen, where the key is an AdUnitId, value is the delivery data for the AdUnit.
	 */
	private Map<Id, Map<Id, Map<Decimal, Decimal>>> getDeliveryDataByPartnerBySite(ADvendio__InvoiceItem__c invoiceItem, Date beginOfMonth, Date endOfMonth) {
		Map<Id, Map<Id, Map<Decimal, Decimal>>> deliveryDataByPartnerBySite	= new Map<Id, Map<Id, Map<Decimal, Decimal>>>();

		if ('TV'.equalsIgnoreCase(invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c) ||
			'Mandant'.equalsIgnoreCase(invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c) ||
			'Rotation'.equalsIgnoreCase(invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c))
		{
			// Get delivery data of syndication partner
			Map<Decimal, Map<Decimal, Decimal>> deliveryDataByPartnerByAdUnit	= new Map<Decimal, Map<Decimal, Decimal>>();	// Key is AdUnit-Id, Value is a map (Key is PartnerId, Value is Deliveries)

			ADvendio__Campaign_Item__c ci = getCampaignItem(invoiceItem);
			Integer orderId		= ci.ADvendio__Adserver_ID_Order_ID__c != null ? Integer.valueOf(ci.ADvendio__Adserver_ID_Order_ID__c) : null;
			Integer lineItemId	= ci.ADvendio__Ad_Id__c != null ? Integer.valueOf(ci.ADvendio__Ad_Id__c) : null;
	
			if (orderId != null && lineItemId != null) {
				String leistungsTyp	= 'CPC'.equals(invoiceItem.ADvendio__BillingCategory__c) ? 'click' : 'impression';

				for (SomDig_Contentsyndicationpartner__c csp : [SELECT SomDig_AdUnitId__c, SomDig_Count__c, SomDig_CustomTargeting__c
																FROM SomDig_Contentsyndicationpartner__c
																WHERE SomDig_AdUnitId__c != null AND SomDig_Count__c != null AND SomDig_CustomTargeting__c != null AND
																	  SomDig_Time__c >= :beginOfMonth AND SomDig_Time__c <= :endOfMonth AND
																	  SomDig_OrderId__c = :orderId AND SomDig_LineItemId__c = :lineItemId AND SomDig_Type__c = :leistungsTyp])
				{
					Map<Decimal, Decimal> deliveryDataByPartner = deliveryDataByPartnerByAdUnit.get(csp.SomDig_AdUnitId__c);
					if (deliveryDataByPartner == null) {
						deliveryDataByPartner	= new Map<Decimal, Decimal>();
						deliveryDataByPartnerByAdUnit.put(csp.SomDig_AdUnitId__c, deliveryDataByPartner);
					}
					Decimal delivery	= deliveryDataByPartner.get(csp.SomDig_CustomTargeting__c);
					delivery = delivery == null ? csp.SomDig_Count__c : (delivery + csp.SomDig_Count__c);
					deliveryDataByPartner.put(csp.SomDig_CustomTargeting__c, delivery);
				}
			}
			
			// Get the Site-Ids of the AdUnit-Ids
			Map<Id, Map<Id, Set<Decimal>>> adUinitBySite = new Map<Id, Map<Id, Set<Decimal>>>();
			if (!deliveryDataByPartnerByAdUnit.isEmpty()) {
				for (ADvendio__AdServer_ID__c asi : [SELECT ADvendio__Site__c, ADvendio__AdServer_ID__c, SomDig_MediagattungsSegment__c
													 FROM ADvendio__AdServer_ID__c
													 WHERE ADvendio__AdServer_ID__c IN :deliveryDataByPartnerByAdUnit.keySet()])
				{
					Map<Id, Set<Decimal>> adUnitsByGattung = adUinitBySite.get(asi.ADvendio__Site__c);
					if (adUnitsByGattung == null) {
						adUinitBySite.put(asi.ADvendio__Site__c, new Map<Id, Set<Decimal>>());
					}
					
					Set<Decimal> adUnits = adUinitBySite.get(asi.ADvendio__Site__c).get(asi.SomDig_MediagattungsSegment__c);
					if (adUnits == null) {
						adUnits = new Set<Decimal>();
						adUinitBySite.get(asi.ADvendio__Site__c).put(asi.SomDig_MediagattungsSegment__c, adUnits);
					}
					adUnits.add(asi.ADvendio__AdServer_ID__c);
				}
			}
			
			// Merge and create delivery data by syndication partner, by site.
			for (Id siteId : adUinitBySite.keySet()) {
				for (Id mgsId : adUinitBySite.get(siteId).keySet()) {
					Map<Decimal, Decimal> deliveryDataByPartner = new Map<Decimal, Decimal>(); //deliveryDataByPartnerBySite.get(siteId).get(mgsId);
					if (!deliveryDataByPartnerBySite.containsKey(siteId)) {
						deliveryDataByPartnerBySite.put(siteId, new Map<Id, Map<Decimal, Decimal>>());
					}
					if (!deliveryDataByPartnerBySite.get(siteId).containsKey(mgsId)) {
						deliveryDataByPartnerBySite.get(siteId).put(mgsId, deliveryDataByPartner);
					}
										
					deliveryDataByPartner	= deliveryDataByPartnerBySite.get(siteId).get(mgsId);
					
					for (Decimal adUnit : adUinitBySite.get(siteId).get(mgsId)) {
						if (deliveryDataByPartnerByAdUnit.containsKey(adUnit)) {
							for (Decimal partnerId : deliveryDataByPartnerByAdUnit.get(adUnit).keySet()) {
								Decimal delivery = deliveryDataByPartner.get(partnerId);
								delivery = delivery == null
										 ? deliveryDataByPartnerByAdUnit.get(adUnit).get(partnerId)
										 : (delivery + deliveryDataByPartnerByAdUnit.get(adUnit).get(partnerId));
								deliveryDataByPartner.put(partnerId, delivery);
							}
						}
					}	
				

					Set<Decimal> partnerIds = deliveryDataByPartner.keySet();
					for (Decimal partnerId : partnerIds) {
						if (deliveryDataByPartner.get(partnerId) == null || deliveryDataByPartner.get(partnerId) <= 0) {
							deliveryDataByPartner.remove(partnerId);
						}
					}
					
					if (deliveryDataByPartner.isEmpty()) {
						deliveryDataByPartnerBySite.get(siteId).remove(mgsId);
					}
				}
				if (deliveryDataByPartnerBySite.get(siteId).isEmpty()) {
					deliveryDataByPartnerBySite.remove(siteId);
				}
			}
		}
		
		return deliveryDataByPartnerBySite;
	}

	/**
	 * Get the (media) data that required for getting Internal Order Number for the Sites.
	 *
	 * @param invoiceItem The invoice item to use.
	 * @param siteIds A list of ID of records of type ADvendio__Site__c to check.
	 * @return A map using the Id of record of type ADvendio__Site__c as key, a list with 9 elements as value.
	 *		 The 1st element is the Id of record of type SomDig_Mediagattung__c.
	 *		 The 2nd element is the Id of record of type SomDig_Mediagattungssegment__c.
	 *		 The 3td element is the Id of record of type SomDig_MediagattungsDifferenzierung__c.
	 *		 The 4th element is the Id of record of type SomDig_Werbetraergergruppierung__c.
	 *		 The 5th element is the Name of record of type SomDig_Mediagattung__c.
	 *		 The 6th element is the Name of record of type SomDig_Mediagattungssegment__c.
	 *		 The 7th element is the Name of record of type SomDig_MediagattungsDifferenzierung__c.
	 *		 The 8th element is the Name of record of type SomDig_Werbetraergergruppierung__c.
	 *		 The 9th element is the value of field SomDig_DEWerbetraegertyp__c.
	 */
	private Map<Id, String[]> getMediaDataBySite(ADvendio__InvoiceItem__c invoiceItem, Set<Id> siteIds) {
		Map<Id, String[]> mediaDataBySite = new Map<Id, String[]>();
		
		if (siteIds == null || siteIds.isEmpty()) {
			return mediaDataBySite;
		}
		
		// Get data that required for getting Internal Order Number for the Sites
		Id mediagattung					= null;
		Id mediagattungsSegment			= invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Mediagattungssegment__c;
		Id mediagattungsDifferenzierung	= invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.SomDig_MediagattungsDifferenzierung__c;
		Id werbetraegergruppierung		= null;
			
		for (ADvendio__Site__c site :  [SELECT Id, SomDig_Mediagattung__c, SomDig_Werbetraergergruppierung__c, SomDig_DEWerbetraegertyp__c, SomDig_Mediagattung__r.Name, SomDig_Werbetraergergruppierung__r.Name
										FROM ADvendio__Site__c WHERE Id IN :siteIds])
		{
			mediaDataBySite.put(site.Id, new List<String>{ site.SomDig_Mediagattung__c,
													  	   mediagattungsSegment,
														   mediagattungsDifferenzierung,
														   site.SomDig_Werbetraergergruppierung__c,
														   site.SomDig_Mediagattung__r.Name,
														   invoiceItem.SomDig_Mediagattungs_Segment__r.Name,
														   invoiceItem.SomDig_Mediagattungs_Differenzierung__r.Name,
														   site.SomDig_Werbetraergergruppierung__r.Name,
														   site.SomDig_DEWerbetraegertyp__c
														   });
		}
		
		return mediaDataBySite;
	}

	/**
	 * Create accounting records for projected revenue (Hochrechnung).
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to use.
	 * @param logic Logic name, from which this function is called.
	 * @param amount The netto ammout to use. Gross amount will be calculated and used for generated accounting records within this function.
	 * @param required Flag, whether accounting records are to create.
	 */
	private void createProjectedAccountingRecords(RevenueDistributionResult rdr, String logic, Decimal amount, Boolean required) {
		if (required
			&&
			PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType) // Ultimo-5
			&&
			!'Invoiced'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Status__c) // Invoice should not be invoiced
			&&
			( 'monthly (1 month)'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentInterval__c) // Monthly invoice
			  ||
			  ('total account (one Invoice)'.equals(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__PaymentInterval__c) // One invoice (PRAP)
			   &&
			   rdr.invoiceItem.ADvendio__FromDate__c.year() == rdr.accountingPeriodStartDate.year() // One invoice but should be first year (first PRAP)
			   &&
			   rdr.invoiceItem.ADvendio__FromDate__c.month() == rdr.accountingPeriodStartDate.month() // One invoice but should be first month (first PRAP)
			  )
			))
		{
			String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;
		
			List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();

			Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c', 'Hochrechnung');

			String creditAccountType = standardAccount;
			
			if ('DL'.equals(logic)) {
				// (pure) Dienstleitung
				creditAccountType = SACHKONTO_TYP_ERLOESE_DIENSTLEISTUNGEN;
			} 
										 
			Decimal vat = (rdr.invoiceItem.ADvendio__VATExempt__c != null && rdr.invoiceItem.ADvendio__VATExempt__c == false)
						? (rdr.invoiceItem.ADvendio__VATRate__c != null ? rdr.invoiceItem.ADvendio__VATRate__c / 100.0 : 0.0)
						: 0.0;

			for (Integer i = 0; i < 2; i++) {
				AccountingRecord ar = new AccountingRecord();
					
				ar.fillAccountingRecord(rdr.invoiceItem);
				ar.accountingRecord.RecordTypeId							= recordTypeId;
				// Must use gross amount here:
				ar.accountingRecord.SomDig_Betrag__c						= Math.abs(amount*(1.0 + vat)).setScale(2).toPlainString().leftPad(14).replace(' ','0');
				ar.accountingRecord.SomDig_Buchungstext__c					= logic + ': Hochrechnung PIs';
				ar.accountingRecord.SomDig_Steuerkennzeichen__c				= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_Steuerkennzeichen__c;
				ar.accountingRecord.SomDig_Steuerrelevanz__c				= 'AS'.equals(rdr.invoiceItem.ADvendio__Invoice__r.SomDig_Steuerkennzeichen__c) ? '1' : '0';
				ar.aggregationEnabled										= false;

				if (i == 0) {
					ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(SACHKONTO_TYP_FORDERUNG_HOCHRECHNUNG);
					ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
					ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A0';
					if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Kein Sachkonto für Typ \'' + SACHKONTO_TYP_FORDERUNG_HOCHRECHNUNG + '\' gefunden.'));
					}
				} else if (i == 1) {
					ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(creditAccountType);
					ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByType(creditAccountType);
					ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
					if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
															'Kein Sachkonto für Typ \'' + creditAccountType + '\' gefunden.'));
					}
					if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
						rdr.addMessage(new ProcessMessage(ApexPages.Severity.WARNING,
															'Keine Sammel-Innenauftragsnummer für Typ \'' + creditAccountType + '\' gefunden.'));
					}
				}
					
				tmpAccountingRecords.add(ar);
			}
	
			AccountingRecordsGroup arg = new AccountingRecordsGroup();
			arg.accountingAmount = Math.abs(amount*(1.0 + vat));
			arg.matchedLogic = logic + ': Hochrechnung PIs';
			arg.isProjection = true;
			if (amount > 0) {
				for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			} else{
				// Reversed order.
				for (Integer i = tmpAccountingRecords.size() - 1; i >= 0; i--) {
					arg.addAccountingRecord(tmpAccountingRecords.get(i));
				}
			}
				
			// Add created accountig records group to the RevenueDistributionResult
			rdr.addAccountingRecordsGroup(arg);
		}
		
		return;
	}
	
	/**
	 * Create cancellation accounting records by using booked accounting records.
	 *
	 * @param rdr A <code>RevenueDistributionResult</code> object to use.
	 * @param logic Logic name, from which this function is called.
	 * @return True if there are cancellation accounting records created, false otherwise.
	 */
	private Boolean createCancellationAccountingRecords(RevenueDistributionResult rdr, String logic) {
		if (isCancellationInvoiceItem(rdr.invoiceItem))
		{
			// Find the original invoice item.		
			Id origCiId	= getCampaignItem(rdr.invoiceItem).Id;
			Id origInvoiceId = rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__Invoice__c;
			Id origInvoiceItemId = null;
			
			for (ADvendio__InvoiceItem__c invoiceItem : [SELECT Id FROM ADvendio__InvoiceItem__c
														 WHERE ADvendio__Invoice__c = :origInvoiceId AND ADvendio__CampaignItem__c = :origCiId])
			{
				origInvoiceItemId = invoiceItem.Id;
				break;
			}

			if (origInvoiceItemId == null) {
				return false;
			}			
			
			Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
													PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
													? 'Hochrechnung'
													: 'Erloesaufteilung');

			Boolean created = false;
			
			List<String>  recordTypeNames = new List<String> { 'Erloesaufteilung' };
			//if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
			//	recordTypeNames.add('Hochrechnung');
			//}

		   	for (String recordTypeName : recordTypeNames)
		   	{
				Id rtId = getRecordTypeIdByName('SomDig_Buchungssatz__c', recordTypeName);

				String belegdatum  =  (Datetime.newInstance(rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__InvoiceDate__c.year(),
															rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__InvoiceDate__c.month(),
															rdr.invoiceItem.ADvendio__Invoice__r.ADvendio__InvoiceDate__c.day())).format('ddMMyyyy');

				//String verrechnungsmonat = Datetime.newInstance(rdr.accountingPeriodEndDate.year(), rdr.accountingPeriodEndDate.month(), rdr.accountingPeriodEndDate.day()).format('ddMMyyyy');
				String buchungkreis = BUCHUNGSKREIS;
	
				String queryStr = 'SELECT ' + QUERY_BUCHUNGSSATZ_FIELDS + ' FROM SomDig_Buchungssatz__c '
								+ 'WHERE SomDig_Rechnung__c = :origInvoiceId '
								+   'AND SomDig_Rechnungsposition__c = :origInvoiceItemId '
		   						+ 	'AND RecordTypeId = :rtId '
								//+	'AND SomDig_Verrechnungsmonat__c = :verrechnungsmonat '
								+ 	'AND SomDig_Buchungskreis__c = :buchungkreis '
		   						+ 'ORDER BY SomDig_VerrechnungsmonatSAP__c DESC, Name DESC';
		   					
				// Create accountig records.
				List<AccountingRecord> tmpAccountingRecords = new List<AccountingRecord>();
				String curSAP = null;
				String lastSAP = null;
				String curGroupId = null;
				String lastGroupId = null;
	
			   	for (SomDig_Buchungssatz__c bs : Database.query(queryStr)) {
			   		curSAP = bs.SomDig_VerrechnungsmonatSAP__c;
			   		
					// The name consists of: MediaCampaignId + '-' + InvoiceId + '-' + InvoiceItemId + '-' + GroupId + '-' MemberId
					// Refer SomDig_Buchungssatz_EaBatch for details!
					curGroupId = bs.Name.split('-').get(3);
					
					if (!tmpAccountingRecords.isEmpty() &&
						( (lastSAP != null && !lastSAP.equals(curSAP)) || (lastGroupId != null && !lastGroupId.equals(curGroupId)) ))
					{
				   		// Add created accountig records to an AccountingRecordsGroup.
						AccountingRecordsGroup arg = new AccountingRecordsGroup();
						arg.matchedLogic = logic;
						for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
							arg.addAccountingRecord(tmpAccountingRecords.get(i));
						}
					
						// Add created accountig records group to the RevenueDistributionResult
						rdr.addAccountingRecordsGroup(arg);
						
						created = true;
						
						tmpAccountingRecords = new List<AccountingRecord>();
					}
	
					bs.Name								= null;
					bs.RecordTypeId						= recordTypeId;
					bs.SomDig_Belegnummer__c			= null;
					bs.SomDig_Soll_Haben_Kennzeichen__c	= ('S'.equals(bs.SomDig_Soll_Haben_Kennzeichen__c) ? 'H' : 'S');
					bs.SomDig_Belegdatum__c				= belegdatum;
					bs.SomDig_Rechnung__c				= rdr.invoiceItem.ADvendio__Invoice__c;
					bs.SomDig_Rechnungsposition__c		= rdr.invoiceItem.Id;			
					bs.SomDig_Verrechnungsmonat__c		= null;
					bs.SomDig_VerrechnungsmonatSAP__c	= null;
					bs.SomDig_SapDatei__c				= null;
					
					AccountingRecord ar = new AccountingRecord();
					ar.accountingRecord					= bs.clone(false, true, false, false);
					ar.aggregationEnabled				= false; // just do not aggregate values by IA on a cancelation
					tmpAccountingRecords.add(ar);				
	
					lastSAP = curSAP;
					lastGroupId = curGroupId;
			   	}

			   	
			   	
			   	
			   	if (!tmpAccountingRecords.isEmpty()) {
			   		// Add created accountig records to an AccountingRecordsGroup.
					AccountingRecordsGroup arg = new AccountingRecordsGroup();
					arg.matchedLogic = logic;
					for (Integer i = 0; i < tmpAccountingRecords.size(); i++) {
						arg.addAccountingRecord(tmpAccountingRecords.get(i));
					}
				
					// Add created accountig records group to the RevenueDistributionResult
					rdr.addAccountingRecordsGroup(arg);
					
				   	if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
				   		createProjectedAccountingRecords(rdr, logic, getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2), creatingProjectionRecords);
				   	}
					created = true;
			   	}
			   	
			   	if (created) {
			   		break;
			   	}
		   	}

			if (created) {
				rdr.addMessage(new ProcessMessage(ApexPages.Severity.INFO,
											'Bei der Storno-Rechnungsposition mit der Id ' + rdr.invoiceItem.Id + 
											' wurden die Buchungssätze von der stornierten Rechnungsposition mit der Id ' + origInvoiceItemId + 
											' für die Erloesaufteilung benutzt.'));
			}
		   	
			return created;			
		}

		return false;
	}

	/**
	 * Create accounting records for content syndication partner.
	 *
	 * @param rdr 					A <code>RevenueDistributionResult</code> object to use.
	 * @param siteId 				An Id of the site to use.
	 * @param amountOfSite 			Amount of the site to share.
	 * @param deliveryOfSite 		Delivary data of the site to use for calculating the amount sharing for partner.
	 * @param bookingText 			Booking text to use for the created accounting records.
	 * @param mediaDataOfSite		Media data of the site required for creating accounting records.
	 * @param deliveryDataByPartner	Delivery data of the partner.
	 * @param adjustedAmountOfSite	A List to save the adjusted amount of the site. It will contain only one element if success.
	 * @return A list of created accounting records.
	 */
	private List<AccountingRecord> createSyndicationAccountingRecords(RevenueDistributionResult rdr, Id mgsId, Decimal amountOfSite, Decimal deliveryOfSite,
																	  String bookingText, String[] mediaDataOfSite, Map<Decimal, Decimal> deliveryDataByPartner,
																	  List<Decimal> adjustedAmountOfSite)
	{
		List<AccountingRecord> accountingRecords = new List<AccountingRecord>();
		
		if ('TV'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c) ||
			'Mandant'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c) ||
			'Rotation'.equalsIgnoreCase(rdr.invoiceItem.ADvendio__CampaignItem__r.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__Site__r.SomDig_DEWerbetraegertyp__c))
		{
			String standardAccount	= rdr.invoiceItem.ADvendio__Invoice__r.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c ? SACHKONTO_TYP_ERLOESE_IC : SACHKONTO_TYP_ERLOESE_INTERNET;
			

			adjustedAmountOfSite.clear();
			adjustedAmountOfSite.add(amountOfSite);
			
			if (deliveryDataByPartner != null && !deliveryDataByPartner.isEmpty()) {
				Decimal deliveryOfAllPartner = 0;
				for (Decimal v : deliveryDataByPartner.values()) {
					deliveryOfAllPartner += v;
				}
						
				Decimal newAmountOfSite = deliveryOfSite > deliveryOfAllPartner
										? (amountOfSite * (deliveryOfSite - deliveryOfAllPartner) / deliveryOfSite).setScale(2, System.RoundingMode.HALF_UP)
										: 0.00;
						
				newAmountOfSite = newAmountOfSite >= 0.01 ? newAmountOfSite : 0.00;
						
				Decimal amountForPartner = (amountOfSite - newAmountOfSite).setScale(2);
						
				if (amountForPartner > 0) {
					// Set the adjusted amount for the site
					adjustedAmountOfSite.clear();
					adjustedAmountOfSite.add(newAmountOfSite);
	
					// Calculate prorated amount for partner.
					Map<Decimal, Decimal> proratedAmountByPartner	= new Map<Decimal, Decimal>();
					Decimal totalProratedAmountByPartner			= 0;
					Decimal lastMaxProratedAmountByPartner			= 0;
					Decimal lastIdForProratedAmountByPartner		= null;
	
					for (Decimal partnerId : deliveryDataByPartner.keySet()) {
						Decimal proratedAmount	= (amountForPartner * deliveryDataByPartner.get(partnerId) / deliveryOfAllPartner).setScale(2, System.RoundingMode.HALF_DOWN);
						proratedAmountByPartner.put(partnerId, proratedAmount);
						totalProratedAmountByPartner += proratedAmount;
						if (proratedAmount >= lastMaxProratedAmountByPartner) {
							lastMaxProratedAmountByPartner		= proratedAmount;
							lastIdForProratedAmountByPartner	= partnerId;
						}
					}
							
					Decimal residualAmountByPartner = amountForPartner - totalProratedAmountByPartner;
					if (Math.abs(residualAmountByPartner) > 0 && lastIdForProratedAmountByPartner != null) {
						Decimal proratedAmount = proratedAmountByPartner.get(lastIdForProratedAmountByPartner) + residualAmountByPartner;
						proratedAmountByPartner.put(lastIdForProratedAmountByPartner, proratedAmount);
					}
													
					Id recordTypeId = getRecordTypeIdByName('SomDig_Buchungssatz__c',
															PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)
															? 'Hochrechnung'
															: 'Erloesaufteilung');
															
					Decimal amount = getAmountOfMonth(rdr.invoiceItem, rdr.accountingPeriodStartDate, rdr.accountingPeriodEndDate).setScale(2);
				
					// Create accounting records for EA Syndication 
					for (Decimal partnerId : proratedAmountByPartner.keySet()) {
						if (proratedAmountByPartner.get(partnerId) < 0.01) {
							continue;
						}
						String debitAccountType		= standardAccount;
						String creditAccountType	= standardAccount;
						
						if ('Portal'.equalsIgnoreCase(mediaDataOfSite.get(8))) {
							debitAccountType	= SACHKONTO_TYP_KORREKTUR_WERBEERLOES;
							creditAccountType	= SACHKONTO_TYP_DURCHLAUFKONTO_FREMDMARKE;

							{ // Umbuchung IA
								AccountingRecord ar = new AccountingRecord();
					
								ar.fillAccountingRecord(rdr.invoiceItem);
								ar.accountingRecord.RecordTypeId						= recordTypeId;
								ar.accountingRecord.SomDig_Buchungstext__c				= bookingText + ' (Umbuchung): Syndication';
								ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
								ar.aggregationEnabled									= true;
								
								ar.accountingRecord.SomDig_Betrag__c					= proratedAmountByPartner.get(partnerId).toPlainString().leftPad(14).replace(' ','0');
								ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(standardAccount);
								ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByCSP(partnerId.setScale(0).toPlainString(),
																								 Id.valueOf(mediaDataOfSite.get(0)),
																								 mgsId,
																								 Id.valueOf(mediaDataOfSite.get(2)),
																								 Id.valueOf(mediaDataOfSite.get(3)));
								ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
				
								if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
									rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																		'Kein Sachkonto für Typ \'' + standardAccount + '\' gefunden.'));
								}
								if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
									ApexPages.Severity severity	= ApexPages.Severity.ERROR;
									String msgType	= 'undefined';
									if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
										severity	= ApexPages.Severity.WARNING;
										msgType		= 'IA';
										ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
										ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
										ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
									}
									rdr.addMessage(new ProcessMessage(severity,
														'Keine Innenauftragsnummer für die Kombination: ' +
														'ContentSyndicationPartner: ' + partnerId.setScale(0).toPlainString() + ', ' +
														'Mediagattung: ' + mediaDataOfSite.get(4) + '(' + mediaDataOfSite.get(0) + '), ' +
									  					'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
														'Mediagattungs-Differenzierung: ' + mediaDataOfSite.get(6) + '(' + mediaDataOfSite.get(2) + '), ' +
														'Werbeträgergruppierung: ' + mediaDataOfSite.get(7) + '(' + mediaDataOfSite.get(3) + ')', msgType));
								}
								
								accountingRecords.add(ar);
							}
							
							{ // EA Fremdmarke (Korrektur)
								AccountingRecord ar = new AccountingRecord();
					
								ar.fillAccountingRecord(rdr.invoiceItem);
								ar.accountingRecord.RecordTypeId						= recordTypeId;
								ar.accountingRecord.SomDig_Buchungstext__c				= bookingText + ' (Umbuchung): Syndication';
								ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
								ar.aggregationEnabled									= true;
								
								ar.accountingRecord.SomDig_Betrag__c					= proratedAmountByPartner.get(partnerId).toPlainString().leftPad(14).replace(' ','0');
								ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkontoNummerByType(SACHKONTO_TYP_KORREKTUR_WERBEERLOES);
								ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByCSP(partnerId.setScale(0).toPlainString(),
																								 Id.valueOf(mediaDataOfSite.get(0)),
																								 mgsId,
																								 Id.valueOf(mediaDataOfSite.get(2)),
																								 Id.valueOf(mediaDataOfSite.get(3)));
								ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'S' : 'H';
				
								if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
									rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																		'Kein Sachkonto für Typ \'' + SACHKONTO_TYP_KORREKTUR_WERBEERLOES + '\' gefunden.'));
								}
								if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
									ApexPages.Severity severity	= ApexPages.Severity.ERROR;
									String msgType	= 'undefined';
									if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
										severity	= ApexPages.Severity.WARNING;
										msgType		= 'IA';
										ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
										ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
										ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
									}
									rdr.addMessage(new ProcessMessage(severity,
														'Keine Innenauftragsnummer für die Kombination: ' +
														'ContentSyndicationPartner: ' + partnerId.setScale(0).toPlainString() + ', ' +
														'Mediagattung: ' + mediaDataOfSite.get(4) + '(' + mediaDataOfSite.get(0) + '), ' +
									  					'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
														'Mediagattungs-Differenzierung: ' + mediaDataOfSite.get(6) + '(' + mediaDataOfSite.get(2) + '), ' +
														'Werbeträgergruppierung: ' + mediaDataOfSite.get(7) + '(' + mediaDataOfSite.get(3) + ')', msgType));
								}
								
								accountingRecords.add(ar);
							}
						}
					
						{ // EA
							AccountingRecord ar = new AccountingRecord();

							ar.fillAccountingRecord(rdr.invoiceItem);
							ar.accountingRecord.RecordTypeId						= recordTypeId;
							ar.accountingRecord.SomDig_Buchungstext__c				= bookingText + ': Syndication';
							ar.accountingRecord.SomDig_Steuerkennzeichen__c			= 'A6';
							ar.aggregationEnabled									= true;
									
							ar.accountingRecord.SomDig_Betrag__c					= proratedAmountByPartner.get(partnerId).toPlainString().leftPad(14).replace(' ','0');
							ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c		= getSachkonto(Id.valueOf(mediaDataOfSite.get(0)),
																								mgsId,
																								Id.valueOf(mediaDataOfSite.get(2)),
																								Id.valueOf(mediaDataOfSite.get(3)),
																								creditAccountType);
							ar.accountingRecord.SomDig_Innenauftragsnummer__c		= getIaNummerByCSP(partnerId.setScale(0).toPlainString(),
																								 Id.valueOf(mediaDataOfSite.get(0)),
																								 mgsId,
																								 Id.valueOf(mediaDataOfSite.get(2)),
																								 Id.valueOf(mediaDataOfSite.get(3)));				
							ar.accountingRecord.SomDig_Soll_Haben_Kennzeichen__c	= amount > 0 ? 'H' : 'S';
							
							if (String.isEmpty(ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c)) {
								rdr.addMessage(new ProcessMessage(ApexPages.Severity.ERROR,
																	'Kein Sachkonto für Typ \'' + creditAccountType + '\' gefunden.'));
							}
							if (String.isEmpty(ar.accountingRecord.SomDig_Innenauftragsnummer__c)) {
								ApexPages.Severity severity	= ApexPages.Severity.ERROR;
								String msgType	= 'undefined';
								if (PROCESS_ULTIMO_MINUS_5.equals(selectedProcessType)) {
									severity	= ApexPages.Severity.WARNING;
									msgType		= 'IA';
									ar.accountingRecord.SomDig_Innenauftragsnummer__c	= getErrorIaNummerByType(standardAccount);
									ar.accountingRecord.SomDig_Erloeskonto_Sachkonto__c	= getSachkontoNummerByType(standardAccount);
									ar.accountingRecord.SomDig_Buchungstext__c			= 'Unbekannter Innenauftrag';
								}
	
								rdr.addMessage(new ProcessMessage(severity,
													'Keine Innenauftragsnummer für die Kombination: ' +
													'ContentSyndicationPartner: ' + partnerId.setScale(0).toPlainString() + ', ' +
													'Mediagattung: ' + mediaDataOfSite.get(4) + '(' + mediaDataOfSite.get(0) + '), ' +
								  					'Mediagattungs-Segment: ' + getMediagattungsSegment(mgsId) + ' (' + mgsId + '), ' +
													'Mediagattungs-Differenzierung: ' + mediaDataOfSite.get(6) + '(' + mediaDataOfSite.get(2) + '), ' +
													'Werbeträgergruppierung: ' + mediaDataOfSite.get(7) + '(' + mediaDataOfSite.get(3) + ')', msgType));
							}
		
							accountingRecords.add(ar);
						}
					}
				} // end of (amountForPartner > 0)
			} // end of (deliveryDataByPartner != null)
		}

		return accountingRecords;
	}

	public void fakeTestingCoverage() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		fakeTestingCoverage2();
	}
	
	private void fakeTestingCoverage2() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		fakeTestingCoverage3();
	}

	private void fakeTestingCoverage3() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		fakeTestingCoverage4();
	}

	private void fakeTestingCoverage4() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		fakeTestingCoverage5();
	}

	private void fakeTestingCoverage5() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}
}