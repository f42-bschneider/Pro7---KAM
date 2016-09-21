public with sharing class P7S1_Emp_UserQueue implements Queueable{

	// User-Ids to handle async
	public Map<Id,User> i_oMapUserQueue = new Map<Id,User>();

	public void execute(QueueableContext context) {
		update i_oMapUserQueue.values(); 
		}
}