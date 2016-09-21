/**
 * Klasse um Buchungssätze einer SAP-Datei zuzuordnen. (Als Batch-Job)
 */
global with sharing class SomDig_SapDatei implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	/** An exception class. */
	public class sapDateiUploadException extends Exception {}
	  
	/** The record type name of the current SomDig_SapDatei__c record. */
	private String recordTypeName = null;


	/** ID of SomDig_SapDatei__c record, to which the SomDig_Buchungssatz__c records are to assign. */
    public Id sapDateiId { public get; public set; }
    
    private SomDig_SapDateiZuweisung zuweisungJob	= null;
    
	/**
	 * A webservice to start the batch job for assigning SomDig_Buchungssatz__c records to a SomDig_SapDatei__c.
	 *
	 * @param sapDateiId Id of the SomDig_SapDatei__c being assigned.
	 */
	webservice static void buchungssaetzeZuweisen(Id sapDateiId) {
		Set<String> openJobStatus	= new Set<String>{'Holding','Queued','Preparing','Processing'};
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE (ApexClass.Name='SomDig_SapDatei' OR ApexClass.Name='SomDig_SapDateiZuweisung') AND Status IN :openJobStatus limit 1];
        if (jobs==null || jobs.size() == 0) {
            SomDig_SapDatei sapDateiClass = new SomDig_SapDatei();
            sapDateiClass.sapDateiId = sapDateiId;
            Database.executeBatch(sapDateiClass);  
        }
        else {
            throw new sapDateiUploadException('Start der Zuweisung nicht möglich! Eine Zuweisung von Buchungssätzen ist bereits in Gange.');
        }
	}

	/**
	 * A webservice to set the status of given SomDig_SapDatei__c to 'Übermittlung'.
	 *
	 * @param sapDateiId Id of the SomDig_SapDatei__c to use.
	 */
	webservice static void setUploadStatus(Id sapDateiId) {
		SomDig_SapDatei__c datei	= null;
		
		for (SomDig_SapDatei__c rec : [SELECT Id, SomDig_Status__c, SomDig_Jahr__c, SomDig_Buchungskreis__c FROM SomDig_SapDatei__c WHERE id = :sapDateiId]) {
			datei	= rec;
		}
		
		if (datei == null) {
			throw new sapDateiUploadException('Keine SAP-Datei mit der ID ' + sapDateiId + ' gefunden.');
		}
		
		if ('Übermittlung'.equalsIgnoreCase(datei.SomDig_Status__c)) {
			throw new sapDateiUploadException('Die SAP-Datei wird bereits übertragen!');
		}
		if ('übermittelt'.equalsIgnoreCase(datei.SomDig_Status__c)) {
			throw new sapDateiUploadException('Die SAP-Datei wurde bereits übertragen und kann nicht erneut übertragen werden!');
		}

		Integer maxNummer	= 0;
		for (SomDig_SapDatei__c maxNummerDatei : [SELECT Id, SomDig_Nummer__c FROM SomDig_SapDatei__c
												  WHERE SomDig_Nummer__c != NULL
														AND SomDig_Buchungskreis__c = :datei.SomDig_Buchungskreis__c
														AND SomDig_Jahr__c = :datei.SomDig_Jahr__c
												  ORDER BY SomDig_Nummer__c DESC
												  LIMIT 1])
		{
			maxNummer		= Integer.valueOf(maxNummerDatei.SomDig_Nummer__c);
		}
		maxNummer++;

		datei.SomDig_Status__c	= 'Übermittlung';
		datei.SomDig_Nummer__c	= String.valueOf(maxNummer).leftPad(4).replace(' ','0');
		update datei;
	}

	/**
	 * Batch job start routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global Database.querylocator start(Database.BatchableContext bc) {
		zuweisungJob			= new SomDig_SapDateiZuweisung();
		zuweisungJob.sapDateiId	= sapDateiId;
		
		if (sapDateiId != null) {
			SomDig_SapDatei__c sapDatei	= null;
			
			for (SomDig_SapDatei__c rec :  [SELECT Id, SomDig_Verrechnungsmonat__c, SomDig_Buchungskreis__c, RecordType.DeveloperName
											FROM SomDig_SapDatei__c
											WHERE Id = :sapDateiId]) {
				sapDatei	= rec;
			}
			
			if (sapDatei == null) {
				return null;
			}
			
			String verrechnungsmonat	= sapDatei.SomDig_Verrechnungsmonat__c;
			String buchungskreis		= sapDatei.SomDig_Buchungskreis__c;
			if ('SomDig_Faktura'.equals(sapDatei.RecordType.DeveloperName)) {
				recordTypeName			= 'Faktura';
			} else if ('SomDig_Hochrechnung'.equals(sapDatei.RecordType.DeveloperName)) {
				recordTypeName			= 'Hochrechnung';
			} else if ('SomDig_Erloesaufteilung'.equals(sapDatei.RecordType.DeveloperName)) {
				recordTypeName			= 'Erloesaufteilung';
			}

			zuweisungJob.recordTypeName	= recordTypeName;
			
			// Get the current max. group number
			if ('Hochrechnung'.equals(recordTypeName) || 'Erloesaufteilung'.equals(recordTypeName)) {
				for (SomDig_Buchungssatz__c rec :  [SELECT Id, SomDig_Belegnummer__c
													FROM SomDig_Buchungssatz__c
													WHERE SomDig_SapDatei__c = :sapDateiId AND
														  SomDig_Belegnummer__c != null AND
														  SomDig_VerrechnungsmonatSAP__c = :verrechnungsmonat AND
														  SomDig_Buchungskreis__c = :buchungskreis AND
														  RecordType.DeveloperName = :recordTypeName
													ORDER BY SomDig_Belegnummer__c DESC
													LIMIT 1])
				{
					zuweisungJob.currentMaxGroupNumber	= Integer.valueOf(rec.SomDig_Belegnummer__c);
				}				
			}


			String queryStr = 'SELECT Id, Name FROM SomDig_Buchungssatz__c '
							+ 'WHERE SomDig_SapDatei__c = NULL '
	    					+	'AND SomDig_VerrechnungsmonatSAP__c = :verrechnungsmonat '
	    					+ 	'AND SomDig_Buchungskreis__c = :buchungskreis '
		   					+ 	'AND RecordType.DeveloperName = :recordTypeName '
		   					+ 	'ORDER BY Name';
			
			return Database.getQueryLocator(queryStr);
		} else {
			return null;
		}
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
		List<SomDig_Buchungssatz__c> bsListToUpdate	= new List<SomDig_Buchungssatz__c>();
		
		for (SomDig_Buchungssatz__c buchungssatz : (List<SomDig_Buchungssatz__c>)scope) {
			zuweisungJob.bsByName.put(buchungssatz.Name, buchungssatz);
		}
	}

	/**
	 * Batch job completion routine.
	 *
	 * @param	bc	Context of the batchable job.
	 */
	global void finish(Database.BatchableContext bc){
		Database.executeBatch(zuweisungJob);
    /*
    	AsyncApexJob job = (bc == null ? null : [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.FirstName, CreatedBy.LastName, CreatedBy.Name FROM AsyncApexJob WHERE Id = :bc.getJobId()]);

    	System.debug('\n\nSomDig_SapDatei: Finish: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', ' + job);

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
    	}    	*/
	}
	
		
	/**
	 * Schedule job execution routine.
	 *
	 * @param	sc		Context of the Scheduleable job.
	 */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(this);
	}
}