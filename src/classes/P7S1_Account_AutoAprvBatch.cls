global class P7S1_Account_AutoAprvBatch implements Database.Batchable<sObject>{

   global Database.QueryLocator start(Database.BatchableContext BC){
   
      Datetime dNow = System.now();
           
      return Database.getQueryLocator('SELECT ID FROM Account WHERE P7S1_AutomaticalApproval__c != null AND P7S1_AutomaticalApproval__c < :dNow');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){

      Set<ID> setAccountIDs = new Set<ID>();
      for(sObject o : scope)
           setAccountIDs.add(o.ID);           

        // Get all pending approvals from the accounts            
        Set<ID> setWorkItemIDs = new Set<ID>();
        for(ProcessInstanceWorkitem o  : [SELECT ID FROM ProcessInstanceWorkitem WHERE 
                                          ProcessInstance.TargetObjectId IN :setAccountIDs AND
                                          ProcessInstance.Status = 'Pending']){
                                                 
        
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('durch automatische Genehmigung');
            req.setAction('Approve');
            req.setNextApproverIds(new Id[] {null});        
        
            req.setWorkitemId(o.ID);
            Approval.ProcessResult result =  Approval.process(req);                
        }
        
        // Feld leeren
        List<Account> listAccount = new List<Account>([SELECT ID FROM Account WHERE ID IN :setAccountIDs]);
        for(Account o : listAccount)
            o.P7S1_AutomaticalApproval__c = null;
        
        update listAccount;
    }
    
    
    
   global void finish(Database.BatchableContext BC){
   }
}