global class P7S1_Account_AutoAprv implements Schedulable {
   global void execute(SchedulableContext SC) {
        
     database.executebatch(new P7S1_Account_AutoAprvBatch(), 20);
                                                
   }
}