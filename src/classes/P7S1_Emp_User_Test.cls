@isTest
private class P7S1_Emp_User_Test {

	
	// TODO: Move createTestUser() to cls_P7S1_TestData
	public static User User_TestData;
	
	public static User createTestUser(Boolean p_bInsertObject, String p_sP7S1_Sphere, String p_sProfileName) {
		User_TestData = new User();
		User_TestData.FirstName = 'Harry';
		User_TestData.LastName = 'Hirsch';
		User_TestData.Alias = 'HiHa';
		User_TestData.CompanyName = 'P7S1 Applications GmbH';

		User_TestData.Email = 'harry.hirsch.' + String.valueOf(Math.random()) + '@p7s1applications.de';
		
		String l_sSandbox = cls_P7S1_Utils.getSandboxName(true);
		User_TestData.Username = User_TestData.Email + l_sSandbox;

		User_TestData.ProfileId = cls_P7S1_Utils.getProfileId(p_sProfileName);
		User_TestData.P7S1_Sphere__c = p_sP7S1_Sphere;
		 
		User_TestData.TimeZoneSidKey = 'Europe/Berlin';
		User_TestData.LocaleSidKey = 'de_DE';
		User_TestData.LanguageLocaleKey = 'de';
		User_TestData.EmailEncodingKey = 'UTF-8';
		User_TestData.UserPermissionsMarketingUser = true;
		//UserRoleId

		if (p_bInsertObject) {
			insert User_TestData;
		}
		return User_TestData;
	}
	// TODO
	
    static testMethod void nameIsFormatted() {
        P7S1_Comp__c firma = cls_P7S1_TestData.createTestFirma(true);
        P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiter(false, firma);
        
        Test.startTest();
        insert emp;
        Test.stopTest();
        
        emp = reloadEmp(emp);
        System.assertEquals(P7S1_Emp_User.getFormattedName(emp), emp.Name);
        
    }	
	
	static testMethod void insertDoesNothing() {
		Account acc = cls_P7S1_TestData.createTestAccount(true);
		P7S1_Comp__c firma = cls_P7S1_TestData.createTestFirma(true, acc);
		Integer l_nCountUser = [SELECT COUNT() FROM User];

		Test.startTest();

		P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiter(false, firma);
		emp.P7S1_Sync__c = true;
		insert emp;

		System.assertEquals(l_nCountUser, [SELECT COUNT() FROM User]);
		System.assertEquals(1, [SELECT COUNT() FROM P7S1_Emp__c]);

		emp = reloadEmp(emp);
		System.assertEquals(null, emp.P7S1_User__c);

		Test.stopTest();
	}

	static testMethod void updateEmpSyncExistingUser() {
		String l_sUsername = 'superman@p7s1.net';
		//TODO: User l_oUser = cls_P7S1_TestData.createTestUser...
		User l_oUser = createTestUser(false, 'SomDe', 'SomTv_RM');
				
		l_oUser.FirstName = 'Bruce';
		l_oUser.LastName = 'Wayne';
		l_oUser.Email = l_sUsername;
		l_oUser.Username = l_sUsername + cls_P7S1_Utils.getSandboxName(true);

		insert l_oUser;
		Integer l_nCountUser = [SELECT COUNT() FROM User];
	
		Account acc = cls_P7S1_TestData.createTestAccount(true);
		P7S1_Comp__c firma = cls_P7S1_TestData.createTestFirma(true, acc);
		
		P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiter(false, firma);
		emp.P7S1_Firstname__c = 'Clark';
		emp.P7S1_Lastname__c = 'Kent';
		emp.P7S1_Username__c = l_sUsername;
		
		emp.P7S1_Profile__c = 'SomTv_Sales';
		emp.P7S1_Role__c = 'SomDe';
		emp.P7S1_Sphere__c = 'SomDe';		
		insert emp;

		emp = reloadEmp(emp);
		System.assertEquals(null, emp.P7S1_User__c);
		System.assertEquals(l_nCountUser, [SELECT COUNT() FROM User]);

		// Kein start/stop Test, da dadurch queuebles synchron ausgeführt werden, was zum DML MIXED MODE Fehler führt
		// Test.startTest();

		
		P7S1_Emp_User.i_bIsTest = true;
		emp.P7S1_Sync__c = true;
		update emp;

		//Test.stopTest();

		l_oUser = reloadUser(l_oUser);
		system.debug('### l_oUser.UserName: ' + l_oUser.UserName);
		
		System.assertEquals('Clark', l_oUser.FirstName);
		System.assertEquals('Kent', l_oUser.LastName);
		emp = reloadEmp(emp);
		System.assertEquals(l_oUser.Id, emp.P7S1_User__c);
		System.assertEquals(l_nCountUser, [SELECT COUNT() FROM User]);
	
	}

	/*
	static  void updateEmpWithoutSync() {
		Account acc = cls_P7S1_TestData.createTestAccount(true);
		Contact con = cls_P7S1_TestData.createTestContact(false, acc);
		con.FirstName = 'Bruce';
		con.LastName = 'Wayne';
		con.Email = 'batman@p7s1.net';
		insert con;
		P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiterWithContact(con);

		emp = reloadEmp(emp);
		System.assertEquals(con.Id, emp.P7S1_Contact__c);
		System.assertEquals(1, [SELECT COUNT() FROM Contact]);

		Test.startTest();

		emp.P7S1_Firstname__c = 'Peter';
		emp.P7S1_Lastname__c = 'Parker';
		emp.P7S1_Username__c = 'spiderman@p7s1.net';
		emp.P7S1_Sync__c = false;
		update emp;

		con = reloadContact(con);
		System.assertEquals('Bruce', con.FirstName);
		System.assertEquals('Wayne', con.LastName);
		System.assertEquals('batman@p7s1.net', con.Email);
		emp = reloadEmp(emp);
		System.assertEquals(con.Id, emp.P7S1_Contact__c);
		System.assertEquals(1, [SELECT COUNT() FROM Contact]);

		Test.stopTest();
	}

	static  void updateEmpWithContact() {
		Account acc = cls_P7S1_TestData.createTestAccount(true);
		Contact con = cls_P7S1_TestData.createTestContact(false, acc);
		con.FirstName = 'Bruce';
		con.LastName = 'Wayne';
		con.Email = 'batman@p7s1.net';
		insert con;
		P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiterWithContact(con);

		emp = reloadEmp(emp);
		System.assertEquals(con.Id, emp.P7S1_Contact__c);

		List<Contact> cons = loadContacts(emp);
		System.assertEquals(1, cons.size());

		Test.startTest();

		emp.P7S1_Firstname__c = 'Peter';
		emp.P7S1_Lastname__c = 'Parker';
		emp.P7S1_Username__c = 'spiderman@p7s1.net';
		emp.P7S1_Sync__c = true;
		update emp;

		cons = loadContacts(emp);
		System.assertEquals(2, cons.size());

		cons.sort();

		System.assertEquals('Bruce', cons[0].FirstName);
		System.assertEquals('Wayne', cons[0].LastName);
		System.assertEquals('batman@p7s1.net', cons[0].Email);
		System.assertEquals('Peter', cons[1].FirstName);
		System.assertEquals('Parker', cons[1].LastName);
		System.assertEquals('spiderman@p7s1.net', cons[1].Email);

		emp = reloadEmp(emp);
		System.assertEquals(cons[1].Id, emp.P7S1_Contact__c);

		Test.stopTest();
	}

	static  void updateEmpWithouContact() {
		Account acc = cls_P7S1_TestData.createTestAccount(true);
		P7S1_Comp__c firma = cls_P7S1_TestData.createTestFirma(true, acc);
		P7S1_Emp__c emp = cls_P7S1_TestData.createTestMitarbeiter(true, firma);

		emp = reloadEmp(emp);
		System.assertEquals(null, emp.P7S1_Contact__c);

		System.assertEquals(0, [SELECT COUNT() FROM Contact]);

		Test.startTest();

		emp.P7S1_Firstname__c = 'Clark';
		emp.P7S1_Lastname__c = 'Kent';
		emp.P7S1_Username__c = 'superman@p7s1.net';
		emp.P7S1_Sync__c = true;
		update emp;

		List<Contact> cons = loadContacts(emp);
		System.assertEquals(1, cons.size());
		System.assertEquals('Clark', cons[0].FirstName);
		System.assertEquals('Kent', cons[0].LastName);
		System.assertEquals('superman@p7s1.net', cons[0].Email);

		emp = reloadEmp(emp);
		System.assertEquals(cons[0].Id, emp.P7S1_Contact__c);

		Test.stopTest();
	}

	private static List<Contact> loadContacts(P7S1_Emp__c emp) {
		return [SELECT Email, FirstName, LastName, P7S1_Emp__c FROM Contact WHERE P7S1_Emp__c = :emp.Id];
	}
*/
	
	
	private static P7S1_Emp__c reloadEmp(P7S1_Emp__c p_oEmp) {
		return [SELECT Name, P7S1_Username__c, P7S1_Email__c, P7S1_Firstname__c, P7S1_Lastname__c, P7S1_User__c, P7S1_CompName__c FROM P7S1_Emp__c WHERE Id = :p_oEmp.Id];
	}

	private static User reloadUser(User p_oUser) {
		return [SELECT UserName, Email, FirstName, LastName, CompanyName FROM User WHERE Id = :p_oUser.Id];
	}

}