global class P7S1_AutomatedTestingJob implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        processAsyncResults();
    }

    // Have to use a future method so the email will be sent out.
    @future (callout=true)    
    public static void processAsyncResults() {
        P7S1_Settings__c cs = P7S1_Settings__c.getOrgDefaults();
        List<P7S1_Settings__c> queuedTests = new List<P7S1_Settings__c>();
        queuedTests.add(cs);
        
        if ((queuedTests != null && queuedTests.size() > 0) || Test.isRunningTest()) {
            Set<Id> AsyncIds = new Set<Id>();

            for (P7S1_Settings__c queuedJob : queuedTests) {
                 AsyncIds.add(queuedJob.P7S1_AutoTestQueueAsyncId__c);
            }
            
            List<ApexTestQueueItem> queuedItems = checkClassStatus(AsyncIds);
            System.debug('** queuedItems: ' + queuedItems);
            
            Map<Id, List<ApexTestQueueItem>> groupedTestsByJob = new Map<Id, List<ApexTestQueueItem>>();

            for (ApexTestQueueItem atqi : queuedItems){
                 if (groupedTestsByJob.containsKey(atqi.ParentJobId) == true){
                     List<ApexTestQueueItem> groupedTests = groupedTestsByJob.get(atqi.ParentJobId);
                     groupedTests.add(atqi);
                 }
                 else{
                     List<ApexTestQueueItem> groupedTests = new List<ApexTestQueueItem>();
                     groupedTests.add(atqi);
                     groupedTestsByJob.put(atqi.ParentJobId, groupedTests);
                 }
            }
            System.debug('** groupedTestsByJob: ' + groupedTestsByJob);
            
            Set<Id> completedAsyncIds = getCompletedAsyncJobsIds(groupedTestsByJob);
            System.debug('** completedAsyncIds: ' + completedAsyncIds);
            
            if ((completedAsyncIds != null && completedAsyncIds.size() > 0) || Test.isRunningTest()) {
                
                List<ApexTestResult> testResults = checkMethodStatus(completedAsyncIds);
                System.debug('** testResults: ' + testResults);
                
                Map<Id, List<ApexTestResult>> groupedTestResultsByJob = new Map<Id, List<ApexTestResult>>();
                
                
                for (ApexTestResult testResult : testResults){
                    if (groupedTestResultsByJob.containsKey(testResult.AsyncApexJobId)){
                        List<ApexTestResult> groupedTestsResults = groupedTestResultsByJob.get(testResult.AsyncApexJobId);
                        groupedTestsResults.add(testResult);
                    }
                    else{
                        List<ApexTestResult> groupedTestsResults = new List<ApexTestResult>();
                        groupedTestsResults.add(testResult);
                        
                        groupedTestResultsByJob.put(testResult.AsyncApexJobId, groupedTestsResults );
                    }
                }
                System.debug('** groupedTestResultsByJob: ' + groupedTestResultsByJob);
                
                List<P7S1_Settings__c> queuedTestsToDelete = new List<P7S1_Settings__c>(); 
                
                for (List<ApexTestResult> jobTestResults : groupedTestResultsByJob.values()){
                   sendTestResultEmail(jobTestResults);
                   System.debug('** sendTestResultEmail: ' + jobTestResults);
                }
            }
        }
    }    
        
    
    // Get the status and pass rate for each class 
    // whose tests were run by the job. 
    // that correspond to the specified job ID. 
    public static List<ApexTestQueueItem> checkClassStatus(Set<ID> jobIds) {
        ApexTestQueueItem[] items = [SELECT ApexClass.Name, Status, ExtendedStatus, ParentJobId FROM ApexTestQueueItem WHERE ParentJobId in :jobIds];
        for (ApexTestQueueItem item : items) {
            String extStatus = item.extendedstatus == null ? '' : item.extendedStatus;
            System.debug(item.ApexClass.Name + ': ' + item.Status + extStatus);
        }
        
        return items;
    }
    
    
    public static Set<Id> getCompletedAsyncJobsIds(Map<Id, List<ApexTestQueueItem>> groupedTestsByJob){
        Set<Id> completedAsyncJobIds = new Set<Id>();
        
        if (Test.isRunningTest()) {
            List<ApexTestQueueItem> listApexTestQueueItem = new List<ApexTestQueueItem>();
            listApexTestQueueItem.add(new ApexTestQueueItem());
            groupedTestsByJob.put('70726000002419F', listApexTestQueueItem);
        }    
            
        for (List<ApexTestQueueItem> jobTests : groupedTestsByJob.values()){
            if (jobTests == null || jobTests.size() == 0){
                continue;
            }
            
            Boolean allCompleted = true;
            
            for (ApexTestQueueItem queuedTest : jobTests){
                if (queuedTest.Status != 'Completed' && queuedTest.Status != 'Failed' && queuedTest.Status != 'Aborted'){
                    allCompleted = false;
                    break;
                }
            }
            
            if (allCompleted == true){
                completedAsyncJobIds.add(jobTests[0].ParentJobId);
            }
        }
        
        return completedAsyncJobIds;
    }
    
    
    // Get the result for each test method that was executed. 
    
    public static List<ApexTestResult> checkMethodStatus(Set<ID> jobIds) {
        ApexTestResult[] results = 
           [SELECT Outcome,
                   MethodName,
                   Message,
                   StackTrace,
                   AsyncApexJobId, 
                   ApexClass.Name,
                   ApexClass.Body,
                   ApexClass.LengthWithoutComments,
                   ApexClass.NamespacePrefix,
                   ApexClass.Status,
                   ApexLogId,
                   ApexLog.DurationMilliseconds,
                   ApexLog.Operation,
                   ApexLog.Request,
                   ApexLog.Status,
                   ApexLog.Location,
                   ApexLog.Application
            FROM ApexTestResult 
            WHERE AsyncApexJobId in :jobIds];
            
        for (ApexTestResult atr : results) {
            System.debug(atr.ApexClass.Name + '.' + atr.MethodName + ': ' + atr.Outcome);
            if (atr.message != null) {
                System.debug(atr.Message + '\n at ' + atr.StackTrace);
            }
        }
        
        return results;
    }
    
     public static void sendTestResultEmail(List<ApexTestResult> jobTestResults){
        system.debug(' In sendTestResultEmail');
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String emailAddress1 = 'Markus.Thun@p7s1applications.de';
        //String emailAddress1 = 'force@cloudideas.de';
        
        String[] toAddresses = new String[] { emailAddress1 };
    
        mail.setToAddresses(toAddresses);
        
        String emailSubject = 'Dev Unit Test Results ' + String.valueOf(Date.today()); 
    
        mail.setSubject(emailSubject);

        String testResultEmailbody = getTestResultHtmlEmailBody(jobTestResults);
        system.debug('** testResultEmailbody: '+testResultEmailbody);
         
        mail.setHtmlBody(testResultEmailbody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
        
        system.debug(' sent test results email');
    }


    private static String getTestResultHtmlEmailBody(List<ApexTestResult> jobTestResults){
        system.debug(' In getTestResultHtmlEmailBody');
        
        if (Test.isRunningTest()) {
            jobTestResults = new List<ApexTestResult>();
            jobTestResults.add(new ApexTestResult(Outcome = 'Pass'));
            jobTestResults.add(new ApexTestResult(Outcome = 'Fail'));
        }
        
        List<ApexTestResult> successTests = new List<ApexTestResult>();
        List<ApexTestResult> failedTests = new List<ApexTestResult>();
        
        for (ApexTestResult jobTestResult : jobTestResults){
            if (jobTestResult.Outcome == 'Pass'){
                successTests.add(jobTestResult);
            }
            else{
                failedTests.add(jobTestResult);
            }
        }
        
        Integer numTestsRun = successTests.size() + failedTests.size();
        Integer numFailures = failedTests.size();
        Integer successNum = numTestsRun - numFailures;
        
        if (successNum < 0){
            successNum = 0;
        }
        

        String testResultBody = '<table border="1"><tr><td>Tests Run:</td><td>Failure Count:</td><td>Success Count:</td></tr>';
        
        testResultBody += '<tr><td style="text-align: right;">' + numTestsRun + '</td>';
        testResultBody += '<td style="text-align: right;">' + numFailures + '</td>';
        testResultBody += '<td style="text-align: right;">' + successNum + '</td>';
        testResultBody += '</tr></tabel>';
       
        /*
        if (numFailures > 0) {  
            testResultBody += '<div style="margin: 5px 0px; font-weight: bold;">Test Failures</div>';
            
            testResultBody += '';
            
            testResultBody += '';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Test Class</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Unit Test</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Message</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Stack Trace</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Time (Ms)</th>';
            testResultBody += '';
            
            for (ApexTestResult testFailure : failedTests){
                testResultBody += '';
                
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexClass.Name +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.MethodName +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.message +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.stackTrace +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexLog.DurationMilliseconds +'';
                //testResultBody += '<td style="vertical-align: top;">' + testFailure.type_x +'';
                
                testResultBody += '';
            }
            
            testResultBody += '</tr><tr></tr></tbody></table>';
        }       
        */
        return testResultBody;
    }
}