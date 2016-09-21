/**
 * A batch, schedulable job to check the accounts without DebitorenNummer.
 */
global with sharing class SomTv_Account_CheckDebitorennummer implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    /** Batch size. */
    private Integer batchSize = 100;
    
    /** Recipient mail addr. */
    private String  recipient = null;

    /** AccountIds to force to check. */
    private Set<Id> accIds = null;

    /** A stateful map to store found accounts. */
    global  Map<Id, Account>    mAccounts       = null;

    global  Integer             totalBatchs     = 0;
    global  Integer             totalRecords    = 0;

    /**
     * Constructor.
     */
    public SomTv_Account_CheckDebitorennummer() {
        this.totalBatchs    = 0;
        this.totalRecords   = 0;
        this.mAccounts      = new Map<Id, Account>();
    }

    /**
     * Set the Recipient mail addr.
     */
    public void setRecipient(String recipient) {
        this.recipient = recipient;
    }
    
    /**
     * Set the AccountIds to check.
     */
    public void setAccountIds(Set<Id> accIds) {
        this.accIds = accIds;
    }
    
    /**
     * Add the AccountId to check.
     */
    public void addAccountId(Id accId) {
        if (this.accIds == null) {
            this.accIds = new Set<Id>();
        }
        this.accIds.add(accId);
    }

    /**
     * Batch job start routine.
     *
     * @param   bc  Context of the batchable job.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Running checker only 7 days before (and till) end of each month.
        Date endOfCurrentMonth = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        Integer numberDaysDue  = Date.today().daysBetween(endOfCurrentMonth);
        
        // Get those extern IDs with Som_Quelle__c = 'DebitorenNr' but no Som_ExterneID__c.
        String query =  'SELECT Id, Name, Owner.Name, ' +
                        ' (SELECT Id, P7S1_ExtIdUniqueKey__c, P7S1_Source__c FROM P7S1_ExternalId__r' +
                        ' WHERE isDeleted = false AND P7S1_Source__c = \'DebitorenNr\' AND P7S1_ExtIdUniqueKey__c = null) ' + 
                        'FROM Account ' +
                        'WHERE isDeleted = false';
        
        if (accIds != null) {            
            accIds.remove(null);
        }

        if (accIds != null && !accIds.isEmpty()) {
            query += ' AND Id IN :accIds';
        } else if (numberDaysDue > 7) {
            // Just look for a non-existed account to get query executed.
            query += ' AND Id = null LIMIT 1';
        }
        
        return Database.getQueryLocator(query);
    }

    /**
     * Batch job excution routine.
     *
     * @param   bc      Context of the batchable job.
     * @param   records List of sObject to process.
     */
    global void execute(Database.BatchableContext bc, List<sObject> records) {
        totalBatchs++;
        totalRecords += records.size();

        System.debug('\n\nAccountDebitorenNummerChecker: Execute: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', SizeOfBatchRecords = ' + records.size() + ', BatchJobId = ' + bc.getJobId());     

        for (Account acc : (List<Account>)records) {
            if (acc.P7S1_ExternalId__r != null && !acc.P7S1_ExternalId__r.isEmpty()) {
                // Account has an extern IDs with Som_Quelle__c = 'DebitorenNr' but no Som_ExterneID__c.
                mAccounts.put(acc.Id, acc);
            }
        }       
    }
    
    /**
     * Batch job completion routine.
     *
     * @param   bc  Context of the batchable job.
     */
    global void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];

        System.debug('\n\nAccountDebitorenNummerChecker: Finish: TotalBatchs = ' + totalBatchs + ', TotalRecords = ' + totalRecords + ', ' + a);
        
        if (mAccounts.size() > 0) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
            String[] toAddresses = new String[] { recipient == null ? a.CreatedBy.Email :  recipient};
            mail.setToAddresses(toAddresses);
    
            mail.setSubject('Debitoren-Nummer fehlt');
            
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
                            + '<body style="font-family: Arial,sans-serif;">\n';

            
            
            // new: htmlbody += '<p style="color: rgb(250, 0, 51);font-size: 30px;">Debitoren-Nr. wurde noch nicht hinterlegt</p>';
            
            htmlbody += 'Hallo,</br></br>bei folgenden Accounts fehlt die Debitoren-Nummer. Bitte pr&uuml;fen und nachtragen.</br></br>\n';
            
            //htmlbody += '<table>\n<caption>Details</caption>\n';
            htmlbody += '<table>\n';
            htmlbody += '<tr><th>Account</th><th>Inhaber</th></tr>\n';
        
            for (Account acc : mAccounts.values()) {
                htmlbody += '<tr><td><a href="' + ('https://' + URL.getSalesforceBaseUrl().getHost().replace('-api', '') + '/' + acc.Id) + '">' + acc.Name + '</a></td><td>' + acc.Owner.Name + '</td></tr>\n';
            }
                
            htmlbody += '</table>\n</body>\n</html>\n';
    
            mail.setHtmlBody(htmlbody);
    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }       
    }

    /**
     * Schedule excution routine.
     *
     * @param   sc  Context of the schedule job.
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, batchSize);
    }


}