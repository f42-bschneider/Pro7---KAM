public with sharing class cls_P7S1_GroupMember_SphereProfileQueue implements Queueable{

	// User-Ids to handle async
	public Set<Id> i_oSetUserIds;
	
	public void execute(QueueableContext context) {
		system.debug('### i_oSetUserIds: ' + i_oSetUserIds);
		DeleteGroupMember();
		InsertGroupMember();
	}
	
	private void DeleteGroupMember() {
		List < GroupMember > l_oListGMs = new List<GroupMember>
			([SELECT Id 
			FROM GroupMember 
			WHERE UserOrGroupId 
			IN :i_oSetUserIds 
			AND (Group.Developername LIKE 'P7S1_Profiles%' OR Group.Developername LIKE 'P7S1_Sphere%') ]);

		delete l_oListGMs;
	}
	
	private void InsertGroupMember () {
		List < User > l_oListUsers = new List<User>
			([SELECT Id, IsActive, ProfileId, P7S1_Sphere__c 
			FROM User 
			WHERE Id 
			IN :i_oSetUserIds ]);
		InsertGroupMember(l_oListUsers);
	}
	
	private static void InsertGroupMember(List<User> p_oListUsers) {
		Set<Id> l_oSetUserIds = new Set<Id>();
			
		List<GroupMember> l_oInsertGm = new List<GroupMember>();

		// Create Map of Groups for lookup: Group.Name => Group.Id
		Map<String, Id> l_oMapGroups = new Map <String,Id>();
		for (Group l_oGroup : [SELECT Id,Name FROM Group WHERE (Developername LIKE 'P7S1_Profiles%' OR Developername LIKE 'P7S1_Sphere%')   ]) {
			l_oMapGroups.put(l_oGroup.Name, l_oGroup.Id);
		}

		// Create a Map of Profile for Lookup
		Map < Id, Profile > l_oMapProfile = new Map<Id, Profile> ([SELECT Id,Name FROM Profile]);
		String l_sProfileName;

		String l_sGroupName;
		Id l_sGroupId;
        
		For(User l_oUser :p_oListUsers) {            
		if (l_oUser.IsActive) {
			// add to Group for Profile
			l_sProfileName = l_oMapProfile.get(l_oUser.ProfileId).Name;
			l_sGroupName = 'P7S1_Profiles' + l_sProfileName;
			system.debug('### UserId: ' + l_oUser.Id);
			system.debug('### l_sProfileName: ' + l_sProfileName);
			system.debug('### User.GroupName: ' + l_sGroupName);
            
			if (l_oMapGroups.ContainsKey(l_sGroupName)) {
				l_sGroupId = l_oMapGroups.get(l_sGroupName);
				system.debug('### l_sGroupId: ' + l_sGroupId);

				GroupMember l_oGm = new GroupMember (GroupId = l_sGroupId, UserOrGroupId = l_oUser.Id);
				l_oInsertGm.Add(l_oGm);
			}
			
			// add to Group for Sphere
			l_sGroupName = 'P7S1_Sphere' + l_oUser.P7S1_Sphere__c;
			system.debug('### UserId: ' + l_oUser.Id);
			system.debug('### User.GroupName: ' + l_sGroupName);
            
			if (l_oMapGroups.ContainsKey(l_sGroupName)) {
				l_sGroupId = l_oMapGroups.get(l_sGroupName);
				system.debug('### l_sGroupId: ' + l_sGroupId);

				GroupMember l_oGm = new GroupMember (GroupId = l_sGroupId, UserOrGroupId = l_oUser.Id);
				l_oInsertGm.Add(l_oGm);
			}
			
		}            
		}
		insert l_oInsertGm;
		}
	
}