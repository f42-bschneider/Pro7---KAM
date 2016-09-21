@isTest
public class P7S1_Account_AutoAprvBatch_Test{

    public static testMethod void testAccountAutoAprvBatch(){
      
      // Create the Account
      Account objAccount = cls_P7S1_TestData.createTestAccount(false);
      objAccount.P7S1_AutomaticalApproval__c = Datetime.now().addDays(-30);
      insert objAccount;
      
      
      Test.startTest();      
      
      // Submit the Account for Approval
      Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
      req1.setComments('Submitting request for approval.');
      req1.setObjectId(objAccount.id);
      req1.setSubmitterId(cls_P7S1_TestData.USER_MAP_PROFILE.get('SomTv_Sales'));
      req1.setProcessDefinitionNameOrId('Som_AccountGueltigSetzen');
      req1.setSkipEntryCriteria(true);
      Approval.ProcessResult result = Approval.process(req1);
      
      
      
        
      // Start the scheduler, which starts the batch  
      String CRON_EXP = '0 0 0 15 3 ? 2022';



      String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new P7S1_Account_AutoAprv());
         
      Test.stopTest();


    }
}