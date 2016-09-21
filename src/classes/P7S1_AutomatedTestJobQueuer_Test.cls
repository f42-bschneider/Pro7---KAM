@isTest
public class P7S1_AutomatedTestJobQueuer_Test {
    static testMethod void enqueueTests() {
        P7S1_AutomatedTestJobQueuer.enqueueTests();
    }	
    static testMethod void processAsyncResults() {
        P7S1_AutomatedTestingJob.processAsyncResults();
    }  
    static testMethod void sendTestResultEmail() {
       P7S1_AutomatedTestingJob.sendTestResultEmail(null);    
    }    
}