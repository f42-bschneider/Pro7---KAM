public with sharing class cls_P7S1_GroupMember_SphereProfile extends TriggerController {
/**
@description    1. Add Users to PublicGroup depending on Sphere and Profile
                i.e. Sphere:  User.P7S1_Sphere__c = 'SomDe' => Add to group 'P7S1_SphereSomDe'
                i.e. Profile: User.Profile = 'SomTv_Sales' => Add to group 'P7S1_ProfileSomTv_Sales'
  
                2. Remove Users from PublicGroups, where Sphere and Profile doesn't matches
                3. Remove inactive Users from Sphere and Profile-PublicGroups

@timeline           date            version     changes
Markus Thun         2015-03-09      1.0         Initial
*/

	public cls_P7S1_GroupMember_SphereProfile(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List <sObject >lstNewItems, Map <Id, sObject >mapNewItems, List <sObject >lstOldItems, Map <Id, sObject >mapOldItems) {
		super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
	}

	// Override TriggerController.runAfterInsert
	protected override void runAfterInsert() {
		GroupMemberQueue(this.mapNewItems.keyset());
	}
	
	// Override TriggerController.runAfterUpdate
	protected override void runAfterUpdate() {
		GroupMemberQueue(this.mapNewItems.keyset());
	}
	
	private static void GroupMemberQueue(Set<Id> p_oSetUserIds) {
		//run only as admin (not when user i.e. changes phoneno)
		system.debug('### p_oSetUserIds: ' + p_oSetUserIds);
		if ( userinfo.getProfileId().left(15) == Label.ProfileIdAdmin) {
			cls_P7S1_GroupMember_SphereProfileQueue l_oQueue = new cls_P7S1_GroupMember_SphereProfileQueue();
			l_oQueue.i_oSetUserIds = p_oSetUserIds;
		
			ID jobID = System.enqueueJob(l_oQueue);
		}

	}
	
}