// helper class to invoke batch mass update from debug window
// 
// goto debug window, "Execute Anonymous"
// String batchId = P7S1_InvokeUpdateTriggerBatch.invoke('SELECT Id FROM Lead');

global class P7S1_InvokeUpdateTriggerBatch implements Database.Batchable<sObject> {
    
    private String query;
    
    global P7S1_InvokeUpdateTriggerBatch(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(this.query);    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){     
        update scope;           
    }

    global void finish(Database.BatchableContext BC){   
        System.debug('Batch Process Complete'); 
    }
    
    // utility static method to kick off a batch in one line.
    global static String invoke(String query) {
        P7S1_InvokeUpdateTriggerBatch batch = new P7S1_InvokeUpdateTriggerBatch(query);
        return Database.executeBatch(batch);
    }

}