global with sharing class SomDig_SapDateiZuweisung implements Database.Batchable<sObject>, Database.Stateful {
    
    public Map<String, SomDig_Buchungssatz__c> bsByName	= null;
	/** A count for counting number of batches processed. */
	private	Integer totalBatchs							= 0;

	/** A count for counting number of records (SomDig_Buchungssatz__c) processed. */
	private	Integer totalRecords						= 0;
	
	/** The current instance name. */
	private String instanceName							= null;
	  
	/** The record type name of the current SomDig_SapDatei__c record. */
	public String recordTypeName						= null;
	  
	/** The current max. group number. */
	public Integer currentMaxGroupNumber				= 0;
	  
	/** The current gropu name. */
	private String currentGroupName						= null;

	/** ID of SomDig_SapDatei__c record, to which the SomDig_Buchungssatz__c records are to assign. */
    public Id sapDateiId { public get; public set; }
 
 	/**
	 * Constructor.
	 */
	public SomDig_SapDateiZuweisung() {
		bsByName	= new Map<String, SomDig_Buchungssatz__c>();
        for (Organization o : [SELECT InstanceName FROM Organization LIMIT 1]) {
			this.instanceName = o.InstanceName;
		}
	}
 
    /**
	 * Batch job start routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global List<SomDig_Buchungssatz__c> start(Database.BatchableContext bc) {
		List<SomDig_Buchungssatz__c> bsList	= new List<SomDig_Buchungssatz__c>();
		List<String> bsNames				= new List<String>();
		if (bsByName != null) {
			for (String bsName : bsByName.keySet()) {
				bsNames.add(bsName);
			}
			
			bsNames.sort();
			
			for (String bsName : bsNames) {
				bsList.add(bsByName.get(bsName));
			}
			
		}
		return bsList;
	}

	/**
	 * Batch job execution routine.
	 *
	 * It sums revenues of opportunities of accounts.
	 *
	 * @param	bc		Context of the batchable job.
	 * @param	scope	List of sObject to process.
	 */
	global void execute(Database.BatchableContext bc, List<sObject> scope){
		totalBatchs++;
		totalRecords += scope.size();
		List<SomDig_Buchungssatz__c> bsListToUpdate	= new List<SomDig_Buchungssatz__c>();

		for (SomDig_Buchungssatz__c buchungssatz : (List<SomDig_Buchungssatz__c>)scope) {
			buchungssatz.SomDig_SapDatei__c = sapDateiId;

			// Set the SomDig_Belegnummer__c
			if ('Hochrechnung'.equals(recordTypeName) || 'Erloesaufteilung'.equals(recordTypeName)) {
				// The name consists of: MediaCampaignId + '-' + InvoiceId + '-' + InvoiceItemId + '-' + GroupId + '-' MemberId
				// Refer SomDig_Buchungssatz_EaBatch for details!
				String[] token	= buchungssatz.Name.split('-');
				String grpName	= token[0] + '-' + token[1] + '-' + token[2] + '-' + token[3];
				
				if (currentGroupName == null || currentGroupName.equals(grpName) == false) {
					currentGroupName	= grpName;
					currentMaxGroupNumber++;
				}
				
				buchungssatz.SomDig_Belegnummer__c	= String.valueOf(currentMaxGroupNumber).leftPad(10).replace(' ','0');
				
				bsListToUpdate.add(new SomDig_Buchungssatz__c(Id=buchungssatz.Id, SomDig_SapDatei__c=buchungssatz.SomDig_SapDatei__c, SomDig_Belegnummer__c=buchungssatz.SomDig_Belegnummer__c));
			}
			else { // only for FAKTURA - don't calc Ba Belegnummer
				bsListToUpdate.add(new SomDig_Buchungssatz__c(Id=buchungssatz.Id, SomDig_SapDatei__c=buchungssatz.SomDig_SapDatei__c));
			}
		}

		update bsListToUpdate;
	}

	/**
	 * Batch job completion routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global void finish(Database.BatchableContext bc){
    	AsyncApexJob job = (bc == null ? null : [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.FirstName, CreatedBy.LastName, CreatedBy.Name FROM AsyncApexJob WHERE Id = :bc.getJobId()]);

    	// Send mail
    	if (job != null) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			String[] toAddresses = new String[] { job.CreatedBy.Email };
			mail.setToAddresses(toAddresses);
	
			mail.setSubject('Prozess "Buchungssätze Zuweisung" ist beendet');
			
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
			htmlbody += 'der von Dir gestartete Prozess "Buchungssätze Zuweisung" ist jetzt beendet. Im Folgenden findest Du die Informationen zum Prozessergebnis und das weitere Vorgehen.\n';
			
			htmlbody += '<p>\n<b>Statistiken</b>\n<table style=\'border-width:0px;\'>';
			htmlbody += '<tr><td style=\'text-align:left; border-width:0px;\'>Anzahl der bearbeiteten Buchnungssätzen:</td><td style=\'border-width:0px;\'>' + totalRecords + '</td></tr>';
			htmlbody += '</table>\n</p>\n';
			
			if (totalRecords > 0 && sapDateiId != null) {	
				htmlbody += '<p>\n<b>Weiteres Vorgehen</b>\n<ul>\n';
				htmlbody += '<li>Gehe zu <a href="https://' + instanceName + '.salesforce.com/' + sapDateiId + '">' + 'SAP-Datei</a>, starte den Uploadprozess durch Klicken den Button "SAP Datei Upload".</li>';
				htmlbody += '</ul>\n</p>\n';
			}

			htmlbody += '<p>\nViel Grüße\n<br/>Dein SF-Admin</p>';
			
			mail.setHtmlBody(htmlbody);
	
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}    	
	}

}