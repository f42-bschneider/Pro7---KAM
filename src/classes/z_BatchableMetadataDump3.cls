global with sharing class z_BatchableMetadataDump3 implements Database.Batchable<SObject>, Database.Stateful {

	// z_BatchableMetadataDump2 should be executed before this call
	global database.querylocator start(Database.BatchableContext BC) {
        
		integer l_nLimit;
		if (Test.isRunningTest()) {
			l_nLimit = 1;
		}else{
			l_nLimit = 10000;
		}
			
		String query = 'SELECT z_ChildSObjectDescription__c, childobjectname__c FROM z_ChildRelationship__c LIMIT :l_nLimit';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, SObject[] scope){
		List<z_ChildRelationship__c> records = new List<z_ChildRelationship__c>();

		for(SObject record : scope) {
			z_ChildRelationship__c schema = (z_ChildRelationship__c) record;
			String objname = schema.childobjectname__c;
            
			List < z_SObjectDescription__c > tmps = [Select id From z_SObjectDescription__c Where name =: objname];
			if(tmps.size() == 0)
				continue;
            
			schema.z_ChildSObjectDescription__c = tmps[0].id;
			records.add(schema);
		}

		update records;
	}
    
	global void finish(Database.BatchableContext BC){
	}      

}