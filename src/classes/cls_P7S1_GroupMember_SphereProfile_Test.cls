@isTest
private class cls_P7S1_GroupMember_SphereProfile_Test {
	
	public static User User_TestData;
	
	public static User createTestUser(boolean p_bInsertObject, string p_sSphere, Id p_sProfileId) {
		String l_sRandomName = String.valueOf(Math.random());
		
		User_TestData = new User(
			LastName = 'TestUser',
			Alias = 'Test',
			EMail = l_sRandomName + '@p7s1.net',
			Username = l_sRandomName + '@p7s1.net',
			CommunityNickname = l_sRandomName + '@p7s1.net',
			ProfileId = p_sProfileId,
			TimeZoneSidKey = 'Europe/Berlin', // or 'GMT'
			LocaleSidKey = 'de_DE_EURO', // or 'en_US'
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'de',
			UserPermissionsMobileUser = false,
			P7S1_Sphere__c = p_sSphere
			);
	
		if (p_bInsertObject) {
			insert User_TestData;
		}
		return User_TestData;
	}
	
	static void checkGroupMember (User p_oUser, String  p_sGroupType, String p_sGroupName) {
		// p_sGroupType: P7S1_Profiles oder P7S1_Sphere
		// p_sGroupName: Spehere- or Profile Names
		// Checks, that ONE User has exactly ONE GroupMember of given Type with given Name
		
		GroupMember l_oGroupMember;
		String l_sSoql = 'SELECT Id,Group.Developername FROM GroupMember WHERE UserOrGroupId = \'' + p_oUser.Id + '\' AND Group.Developername LIKE \'' + p_sGroupType + '%\'';

		GroupMember[] l_oGroupMembers = Database.query(l_sSoql);
		System.assert(l_oGroupMembers.size() == 1, 'there is not exactly one Groupmember of Type ' + p_sGroupType);
		
		l_oGroupMember = l_oGroupMembers[0];
		System.assert(l_oGroupMember.Group.Developername == p_sGroupType + p_sGroupName, 'wrong groupmember');
	}		
	
	static testMethod void testInsert() {
		String l_sSphere = 'SomDe';
		String l_sProfileId1 = '00eD0000001Qacc'; //SomDig_PM
		
		// 1. Test: create User and check GroupMember(s)
		Test.startTest();        
		User l_oUser = createTestUser(true, l_sSphere, l_sProfileId1);
		Test.stopTest();
		
		checkGroupMember(l_oUser, 'P7S1_Profiles', 'SomDig_PM');
		checkGroupMember(l_oUser, 'P7S1_Sphere', l_sSphere);
	}
	
	static testMethod void testUpdate() {
		String l_sSphere = 'SomDe';
		String l_sProfileId1 = '00eD0000001Qacc'; //SomDig_PM
		String l_sProfileId2 = '00eD0000001QoiV'; //SomTv_Sales

		// 2. Test: update User and check GroupMember(s)
		Test.startTest();        
		User l_oUser = createTestUser(true, l_sSphere, l_sProfileId1);
		l_oUser.ProfileId = l_sProfileId2;
		update l_oUser;
		Test.stopTest();

		checkGroupMember(l_oUser, 'P7S1_Profiles', 'SomTv_Sales');
		checkGroupMember(l_oUser, 'P7S1_Sphere', 'SomDe');		
	}
}