global class P7S1_AutomatedTestJobQueuer implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        enqueueTests();
    }    
    
    // Enqueue all classes beginning with "Test".  
    public static void enqueueTests() {
        /* The first thing you need to do is query the classes that contain
         the unit tests you want executed. In our org, our test classes are named "<Class_Name_Here>Test".
       */    
        ApexClass[] testClasses = [SELECT ID, Name, NamespacePrefix FROM ApexClass WHERE NamespacePrefix = '' and Name LIKE '%Test' limit 1];
        Integer testClassCnt = testClasses != null ? testClasses.size() : 0;
        system.debug('** P7S1_AutomatedTestJobQueuer::testClasses: ' + testClasses);
        system.debug('** P7S1_AutomatedTestJobQueuer::enqueueTests: ' + testClassCnt);

        if (testClassCnt > 0) {
            /*
             Insertion of the ApexTestQueueItem causes the unit tests to be 
             executed. Since they're asynchronous, the apex async job id
             needs to be stored in a Custom Object so we can process the test results
             when the job is complete.
            */
            ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
            
            for (ApexClass testClass : testClasses) {
                system.debug('* enqueueTests::testClass ' + testClass);
                queueItems.add(new ApexTestQueueItem(ApexClassId=testClass.Id));
            }
            
            if (!Test.isRunningTest()) insert queueItems;

            // Get the job ID of the first queue item returned. 
            List<ApexTestQueueItem> listApexTestQueueItems = new List<ApexTestQueueItem>([SELECT ParentJobId FROM ApexTestQueueItem WHERE Id =: queueItems[0].Id LIMIT 1]);
            system.debug('** listApexTestQueueItems: ' + listApexTestQueueItems);
            if (listApexTestQueueItems.size() > 0) {
               String sId = listApexTestQueueItems[0].parentjobid;
               sId = sId.substring(0,15); 
               
               P7S1_Settings__c CS = P7S1_Settings__c.getOrgDefaults();
               CS.P7S1_AutoTestQueueAsyncId__c = sId;
               upsert CS;
            }    
        }
    }     
}