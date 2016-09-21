global with sharing class z_SchedulableBatchableMetadataDump1 implements Schedulable {

	global void execute(SchedulableContext sc) {

		List < SObject > records = [Select id From z_MetaDumpSetting__c Limit 10000];
		if(records.size() != 0)
			delete records;


		List<z_MetaDumpSetting__c> dumps = new List<z_MetaDumpSetting__c>();
		for(String name : Schema.getGlobalDescribe().keySet()) {
			if (name.endsWith('history') || name.endsWith('share') || name.endsWith('tag')    ) {
				continue;
			}

			if (name.equalsIgnoreCase('ApexComponent') || name.equalsIgnoreCase('ApexClass') || name.equalsIgnoreCase('ApexTrigger') || name.equalsIgnoreCase('ApexPage') || name.equalsIgnoreCase('ProcessInstance') || name.equalsIgnoreCase('ProcessInstanceHistory') || name.equalsIgnoreCase('ProcessInstanceStep') || name.equals('ProcessInstanceHistory') || name.equalsIgnoreCase('Document') || name.equalsIgnoreCase('DocumentAttachmentMap') || name.equalsIgnoreCase('Note') || name.equals('NoteAndAttachment') || name.equalsIgnoreCase('EmailServicesAddress') || name.equalsIgnoreCase('EmailServicesFunction') || name.equalsIgnoreCase('EmailStatus') || name.equalsIgnoreCase('FiscalYearSettings') || name.equalsIgnoreCase('Folder') || name.equalsIgnoreCase('ForecastShare') || name.equalsIgnoreCase('Group') || name.equalsIgnoreCase('GroupMember')) {
				continue;
			}

			dumps.add(new z_MetaDumpSetting__c(name__c = name));
			/*
			if (name.equalsIgnoreCase('User') || name.equalsIgnoreCase('Account') ) {
				dumps.add(new z_MetaDumpSetting__c(name__c = name));
			}
			*/

		}
		insert dumps;


		z_Util.executeBatchableMetadataDump1(true);
	}
}