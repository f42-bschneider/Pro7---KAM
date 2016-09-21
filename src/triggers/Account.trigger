trigger Account on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        P7S1_Account_NielsenArea.setNielsenArea(Trigger.oldMap, Trigger.new, Trigger.isUpdate);
    }

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        P7S1_Account_Visibility.updateVisibility(Trigger.oldMap, Trigger.new, Trigger.isInsert, Trigger.isUpdate);
    }


	if (Trigger.isAfter && Trigger.isUpdate) {
        Som_Contact_Address.runFromAccountTrigger(Trigger.new, Trigger.oldMap);
    }

    new AccountTrigger(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();

    new P7S1_Account_Sphere(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();
    
    /*
    Added new Method for Account Index creation
    factory42 - VVR - 26.10.2015
    */
    new P7S1_Account_Index_Creator(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();    

	/*
    Added new Method for setting sales fields on Account
    factory42 - BS - 25.11.2015
    */
	if(Trigger.isAfter && Trigger.isUpdate){
		P7S1_Account_SetSalesFields.getAccIdsFromAccount(Trigger.new);
	}
	
}