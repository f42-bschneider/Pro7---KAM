/**
 * A batchable and schedule-able class to create Buchungssätze (SomDig_Buchungssatz__c) for Faktura.
 *
 */
global without sharing class SomDig_Buchungssatz_Faktura implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    /** A count for counting number of batches processed. */
    private Integer totalBatchs     = 0;

    /** A count for counting number of records (ADvendio__Invoice__c) processed. */
    private Integer totalRecords    = 0;
    
    /** A count for counting number of ADvendio__Invoice__c successfully processed. */
    private Integer successNumberOfInvoices = 0;
    
    /** The current instance name. */
    private String instanceName = null;
      
    /** Errors */
    private List<String> errorMessages = new List<String>();

    /** Query used to find the Invoices. */
    public String batchBaseQuery    = 'SELECT Id '
                                    + 'FROM ADvendio__Invoice__c '
                                    + 'WHERE ADvendio__Status__c IN (\'Invoiced\',\'Canceled\') '
                                    +        'AND SomDig_FakturaBuchungssaetzeEnthalten__c = FALSE '
                                    +        'AND ADvendio__InvoicedAmountGrossN2__c != null '
                                    +        'AND ADvendio__InvoicedAmountGrossN2__c != 0';

    /**
     * Construnctor.
     */
    public SomDig_Buchungssatz_Faktura() {
        for (Organization o : [SELECT InstanceName FROM Organization LIMIT 1]) {
            this.instanceName = o.InstanceName;
        }
    }
    
    /**
     * Batch job start routine.
     *
     * @param   BC  Context of the batchable job.
     */
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(batchBaseQuery);
    }

    /**
     * Batch job execution routine.
     *
     * @param   bc      Context of the batchable job.
     * @param   scope   List of sObject to process.
     */
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        totalBatchs++;
        totalRecords += scope.size();

        System.debug('\n\nSomDig_Buchungssatz_Faktura: Execute: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', SizeOfBatchRecords = ' + scope.size() + ', BatchJobId = ' + (bc == null ? '' : bc.getJobId())); 
        
        start((List<ADvendio__Invoice__c>) scope);
    }

    /**
     * Batch job completion routine.
     *
     * @param   bc  Context of the batchable job.
     */
    global void finish(Database.BatchableContext bc){
        AsyncApexJob job = (bc == null ? null : [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.FirstName, CreatedBy.LastName, CreatedBy.Name FROM AsyncApexJob WHERE Id = :bc.getJobId()]);

        System.debug('\n\nSomDig_Buchungssatz_Faktura: Finish: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', ' + job);        

        SomDig_SapDatei__c sapDatei = null;

        if (successNumberOfInvoices > 0) {
            Date accountingEndDate = System.today().addMonths(1).toStartOfMonth().addDays(-1);
            Datetime accountingEndDateTime = Datetime.newInstance(accountingEndDate.year(), accountingEndDate.month(), accountingEndDate.day());
            
            String buchungskreis = SomDig_Buchungssatz_EaBase.BUCHUNGSKREIS;
            String jahr = accountingEndDateTime.format('yyyy');
            String monat = accountingEndDateTime.format('MM');
            String tag = accountingEndDateTime.format('dd');
            Id recordTypeId = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_SapDatei__c', 'SomDig_Faktura');

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
                System.debug('\n\nSomDig_Buchungssatz_Faktura: found existed SomDig_SapDatei__c: ' + sapDatei);     
            }
            
            if (sapDatei == null) {
                sapDatei = new SomDig_SapDatei__c(SomDig_Buchungskreis__c=buchungskreis, SomDig_Jahr__c=jahr, SomDig_Monat__c=monat, SomDig_Tag__c=tag,
                                                    SomDig_Quellsystem__c='advendio', SomDig_Status__c='erstellt', RecordTypeId=recordTypeId);
                insert sapDatei;
                System.debug('\n\nSomDig_Buchungssatz_Faktura: created new SomDig_SapDatei__c: ' + sapDatei);       
            }
        }
            
        // Send mail
        if (job != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
            String[] toAddresses = System.Label.SomDig_Buchungssatz_Faktura_Recipients.split(',');
            mail.setToAddresses(toAddresses);
            
            OrgWideEmailAddress[] emailAdress = [SELECT Id from OrgWideEmailAddress where Address = 'salesforce-admins@prosiebensat1.de' limit 1];
            if ( emailAdress.size() > 0 ) {
                mail.setOrgWideEmailAddressId(emailAdress.get(0).Id);
            }            
    
            mail.setSubject('Prozess "Faktura-Buchungssätze Erstellung" ist beendet');
            
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
            
            htmlbody += 'Hallo,\n<br/><br/>';
            htmlbody += 'der von Dir gestartete Prozess "Faktura-Buchungssätze Erstellung" ist jetzt beendet. Im Folgenden findest Du die Informationen zum Prozessergebnis und das weitere Vorgehen.\n';
            
            htmlbody += '<p>\n<b>Statistiken</b>\n<table style=\'border-width:0px;\'>';
            htmlbody += '<tr><td style=\'text-align:left; border-width:0px;\'>Anzahl der bearbeiteten Rechnungen:</td><td style=\'border-width:0px;\'>' + totalRecords + '</td></tr>';
            htmlbody += '<tr><td style=\'text-align:left; border-width:0px;\'>Anzahl der erfolgreich bearbeiteten Rechnungen:</td><td style=\'border-width:0px;\'>' + successNumberOfInvoices + '</td></tr>';
            htmlbody += '</table>\n</p>\n';

            if (!errorMessages.isEmpty() ) {
                htmlbody += '<p>\n<b>Fehler</b>\n<ul>\n';
                for (String s : errorMessages) {
                    htmlbody += '<li>' + s + '</li>';
                }
                htmlbody += '</ul>\n</p>\n';
            }
            
            if (totalRecords > 0 && (successNumberOfInvoices > 0 || !errorMessages.isEmpty())) {    
                htmlbody += '<p>\n<b>Weiteres Vorgehen</b>\n<ul>\n';
                if (!errorMessages.isEmpty()) {
                    htmlbody += '<li>Behebe die Fehler, starte dann den Prozess erneut.</li>';
                }
                if (sapDatei != null) {
                    //htmlbody += '<li>Gehe zu <a href="https://' + instanceName + '.salesforce.com/' + sapDatei.Id + '">' + 'SAP-Datei</a>, starte den Buchnungssätze-Zuweisensprozess durch Klicken den Button "Buchungssätze zuweisen".</li>';
                    //htmlbody += '<li>Nachdem die Buchungssätze zugewiesen sind, gehe zu <a href="https://' + instanceName + '.salesforce.com/' + sapDatei.Id + '">' + 'SAP-Datei</a>, starte den Uploadprozess durch Klicken den Button "SAP Datei Upload".</li>';
                    htmlbody += '<li>Ein Prozess wird gestartet, um die erstellte Buchungssätze zu SAP Datei zuzuweisen. Eine weitere Mail wird an Dich geschickt wenn der Prozess beendet ist.</li>';
                }
                htmlbody += '</ul>\n</p>\n';
            }

            htmlbody += '<p>\nViel Grüße\n<br/>Dein SF-Admin</p>';
            
            mail.setHtmlBody(htmlbody);
    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        if (sapDatei != null) {
            // Start the Buchungssätze Zuweisung now.
            SomDig_SapDatei sapDateiClass = new SomDig_SapDatei();
            sapDateiClass.sapDateiId = sapDatei.Id;
            
            Integer numJobs = [SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ( Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing' )];
            if (numJobs > 4) {
                // try again in a minute
                Datetime sysTime = System.now().addSeconds(60);
                String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
    
                System.debug('\n\nSomDig_Buchungssatz_Faktura: scheduled a batch job to assign Buchungssatz to SAP-Datei with Id ' + sapDatei.Id);      
                System.schedule('SomDig_SapDatei_' + sysTime, chronExpression, sapDateiClass);                
            } else {
                System.debug('\n\nSomDig_Buchungssatz_Faktura: started a batch job to assign Buchungssatz to SAP-Datei with Id ' + sapDatei.Id);        
                Database.executeBatch(sapDateiClass);
            }
        }       
    }

    /**
     * Schedule job execution routine.
     *
     * @param   sc      Context of the Scheduleable job.
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SomDig_Buchungssatz_Faktura());
    }

    /**
     * Start the Buchungssätze creation process.
     *
     * @param invoices List of ADvendio__Invoice__c to process.
     */
    public void start(List<ADvendio__Invoice__c> invoices) {
        Set<Id> invoiceIds  = new Set<Id>();
        for (ADvendio__Invoice__c invoice : invoices) {
            invoiceIds.add(invoice.Id);
        }
        createBuchungssatzForInvoices(invoiceIds);
    }

    /**
     * Start the Buchungssätze creation process.
     *
     * @param invoiceIds List of Id of type ADvendio__Invoice__c to process.
     */
    public void createBuchungssatzForInvoices(Set<Id> invoiceIds) {
        List<SomDig_Buchungssatz__c> bss    = new List<SomDig_Buchungssatz__c>();
        List<ADvendio__Invoice__c> invoicesWithBuchungssatz = new List<ADvendio__Invoice__c>();

        for (ADvendio__Invoice__c invoice : [SELECT Id, Name, SomDig_Dokumenttyp__c, ADvendio__InvoiceDate__c, ADvendio__InvoicedAmountGrossN2__c,
                                                    SomDig_Soll_Haben_Kennzeichen__c, SomDig_ZahlungsbedingungenSAP__c, CurrencyIsoCode,
                                                    SomDig_Anzahl_Media_Positionen__c, SomDig_Anzahl_Nonmedia_Positionen__c, SomDig_Auftragstyp__c,
                                                    SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c, SomDig_Steuerkennzeichen__c,
                                                    ADvendio__OrderNumber__c, ADvendio__CampaignName__c, ADvendio__RecipientDebitorId__c
                                            FROM ADvendio__Invoice__c
                                            WHERE Id IN :invoiceIds AND ADvendio__InvoicedAmountGrossN2__c != null AND ADvendio__InvoicedAmountGrossN2__c != 0])
        {
            SomDig_Buchungssatz__c bs   = createBuchungssatz(invoice);
            if (bs != null) {
                bss.add(bs);
                invoice.SomDig_FakturaBuchungssaetzeEnthalten__c = true;
                invoicesWithBuchungssatz.add(invoice);
            }
        }

        Savepoint sp = Database.setSavepoint();
        try {
            upsert bss SomDig_UniqueKey__c;
            update invoicesWithBuchungssatz; // update field SomDig_FakturaBuchungssaetzeEnthalten__c
            successNumberOfInvoices += invoicesWithBuchungssatz.size();
        } catch (Exception e) {
            Database.rollback(sp);
            errorMessages.add('Fehler beim Erstellen der Buchungssätze: ' + (e.getMessage() != null ? e.getMessage().escapeHtml4() : 'unbekannter Fehler.'));
        }
    }

    /**
     * Create one Buchungssatz for an invoice.
     *
     * @param invoice Invoice to use.
     */
    private SomDig_Buchungssatz__c createBuchungssatz(ADvendio__Invoice__c invoice) {
        String recordTypeName = 'Faktura';
        
        String sachkontoTyp = null;
        
        if (invoice.SomDig_RG_Empfaenger_P7S1_Konzernmitgl__c) { // Prio 1
            sachkontoTyp = SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_IC;
        } else if ('Barter'.equals(invoice.SomDig_Auftragstyp__c)) { // Prio 2
            sachkontoTyp = SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_BARTER;
        } else if (invoice.SomDig_Anzahl_Media_Positionen__c != null && invoice.SomDig_Anzahl_Media_Positionen__c > 0) { // Prio 3
            sachkontoTyp = SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_INTERNET;
        } else if (invoice.SomDig_Anzahl_Nonmedia_Positionen__c != null && invoice.SomDig_Anzahl_Nonmedia_Positionen__c > 0) { // Prio 4
            sachkontoTyp = SomDig_Buchungssatz_EaBase.SACHKONTO_TYP_ERLOESE_DIENSTLEISTUNGEN;
        }

        SomDig_Buchungssatz__c bs   = new SomDig_Buchungssatz__c();

        bs.RecordTypeId                     = SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('SomDig_Buchungssatz__c', recordTypeName);
        bs.SomDig_Status_SAP__c             = 'offen';
        bs.SomDig_Rechnung__c               = invoice.Id;
        bs.SomDig_Belegnummer__c            = invoice.Name;
        bs.SomDig_Buchungskreis__c          = '0029';
        bs.SomDig_Debitorennummer__c        = invoice.ADvendio__RecipientDebitorId__c;
        bs.SomDig_Dokumenttyp__c            = invoice.SomDig_Dokumenttyp__c;
        bs.SomDig_Verrechnungsmonat__c      = formatDate(invoice.ADvendio__InvoiceDate__c.addMonths(1).toStartOfMonth().addDays(-1), 'ddMMyyyy'); // Monatsletzter
        bs.SomDig_VerrechnungsmonatSAP__c   = formatDate(invoice.ADvendio__InvoiceDate__c, 'yyMM');
        bs.SomDig_Betrag__c                 = formatNumber(Math.abs(invoice.ADvendio__InvoicedAmountGrossN2__c));
        bs.SomDig_Belegdatum__c             = formatDate(invoice.ADvendio__InvoiceDate__c, 'ddMMyyyy');
        bs.CurrencyIsoCode                  = invoice.CurrencyIsoCode;
        bs.SomDig_Zahlungsbedingung__c      = invoice.SomDig_ZahlungsbedingungenSAP__c;
        bs.SomDig_Soll_Haben_Kennzeichen__c = invoice.SomDig_Soll_Haben_Kennzeichen__c;
        bs.SomDig_Erloeskonto_Sachkonto__c  = SomDig_Buchungssatz_EaBase.getSachkontoNummerByType(sachkontoTyp);
        bs.SomDig_Innenauftragsnummer__c    = SomDig_Buchungssatz_EaBase.getIaNummerByType(sachkontoTyp);
        bs.SomDig_Steuerkennzeichen__c      = invoice.SomDig_Steuerkennzeichen__c;
        bs.SomDig_Steuerrelevanz__c         = 'AS'.equals(invoice.SomDig_Steuerkennzeichen__c) ? '1' : '0';
        bs.SomDig_Werbeabgabe__c            = formatNumber(0);
        bs.SomDig_Buchungstext__c           = getBuchungsText(invoice);
        bs.SomDig_UniqueKey__c              = bs.SomDig_Rechnung__c + '|' + recordTypeName;

        if (bs.SomDig_Erloeskonto_Sachkonto__c == null) {
            errorMessages.add('Fehler beim Erstellen der Buchungssätze: kein Sachkonto für den Type \'' + sachkontoTyp + '\' definiert.');
            return null;
        }
        if (bs.SomDig_Innenauftragsnummer__c == null) {
            errorMessages.add('Fehler beim Erstellen der Buchungssätze: keine Sammelauftragsnummer für den Type \'' + sachkontoTyp + '\' definiert.');
            return null;
        }
        
        return bs;
    }

    /**
     * Format the date by a give format.
     *
     * @param d Date to format.
     * @param format Format to use.
     * @return Formated string.
     */
    private String formatDate(Date d, String format) {
        return DateTime.newInstance(d.year(), d.month(), d.day()).format(format);
    }

    /**
     * Format a number with 2 digits precision and 14 digits in total, whith 0 padding.
     *
     * @param d Number to format.
     * @return Formated string.
     */
    private String formatNumber(Decimal d) {
        return d == null ? null : (d.setScale(2, System.RoundingMode.HALF_DOWN).toPlainString().leftPad(14).replace(' ','0'));
    }

    /**
     * Create the Buchungstext.
     *
     * @param invoice Invoice to use.
     * @return Created text string.
     */
    private String getBuchungstext(ADvendio__Invoice__c invoice) {
        String buchungstext = invoice.ADvendio__OrderNumber__c + ' - ' + invoice.ADvendio__CampaignName__c;
        buchungstext = buchungstext.subString(0, Math.min(buchungstext.length(), 49));
        return buchungstext;
    }

    /**
     * A webservice to start the batch job for creating SomDig_Buchungssatz__c records.
     */
    webservice static void buchungssaetzeErstellen() {
        Database.executeBatch(new SomDig_Buchungssatz_Faktura());
    }

}