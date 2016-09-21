/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_AccountSetTeamAndShare_Test
* @author:      BS factory42
* @email:       bschneider@factory42.com
* @version:     V0.1
* @date:        Nov 10, 2015
* @last change: AS 2015-11-23 - changed line 38 'FUV'  to 'Sales'
* @description: Testclass for P7S1_AccountSetTeamAndShare
* @objects:     P7S1_AccountAccess__c, AccountTeamMember, AccountShare
* =================================================================
*/
@isTest
private class P7S1_AccountSetTeamAndShare_Test {

    private static Integer cntRecords = 30;
    private static Integer cntAccounts;
    private static User insertUser;
    private static set<String> userIds = new set<String>();
    private static String unitStr;

    /***********************
    * Test for P7S1_AccountAccess__c with recType "Aufnahme ins Account Team"
    ***/
    static testMethod void testAccountTeamAufnahme() {

        Test.startTest();
        //******************************************

        //Create test data for adding AccountTeamMember
        createTestData();

        //Check AccountTeam
        list<AccountTeamMember> lstAccTeam = [SELECT Id, TeamMemberRole FROM AccountTeamMember];
        system.assertEquals(cntAccounts, lstAccTeam.size());

        for(AccountTeamMember team : lstAccTeam){
            System.assertEquals(unitStr.toLowerCase(), team.TeamMemberRole.toLowerCase());
        }

        //Check AccountShare
        list<AccountShare> lstAccShare = [SELECT AccountId, UserOrGroupId, AccountAccessLevel, ContactAccessLevel, OpportunityAccessLevel, CaseAccessLevel FROM AccountShare WHERE UserOrGroupId IN :userIds ];
        system.assertEquals(userIds.size(), lstAccShare.size());

        map<String, String> mapAcc2NewOwner = new map<String, String>();
        for(AccountShare accShare : lstAccShare){
            system.assertEquals('Edit', accShare.AccountAccessLevel);
            system.assertEquals('Read', accShare.ContactAccessLevel);
            system.assertEquals('Read', accShare.OpportunityAccessLevel);
            system.assertEquals('Read', accShare.CaseAccessLevel);
            mapAcc2NewOwner.put(accShare.AccountId, accShare.UserOrGroupId);
        }

        system.runAs(insertUser){

            //Alter Accounts for Account owner change
            list<Account> lstAccUpdate = new list<Account>();
            for(Account acc : [SELECT Id, OwnerId FROM Account]){
                acc.OwnerId = mapAcc2NewOwner.get(acc.Id);
                lstAccUpdate.add(acc);
            }
            update lstAccUpdate;

            //Alter P7S1_AccountAccess__c for Account owner change
            list<P7S1_AccountAccess__c> lstAccAccessUpdate = new list<P7S1_AccountAccess__c>();
            for(P7S1_AccountAccess__c aa : [SELECT P7S1_Account__c, RecordTypeId, OwnerId FROM P7S1_AccountAccess__c]){
                aa.RecordTypeId = P7S1_AccountSetTeamAndShare.RECTYPE_ACC_UEBERNAHME;
                aa.OwnerId = insertUser.Id;
                lstAccAccessUpdate.add(aa);
            }
            update lstAccAccessUpdate;
        }

        for(Account acc : [SELECT OwnerId FROM Account]){
            system.assertEquals(insertUser.Id, acc.OwnerId);
        }

        lstAccShare = [SELECT AccountId, UserOrGroupId, AccountAccessLevel, ContactAccessLevel, OpportunityAccessLevel, CaseAccessLevel FROM AccountShare WHERE UserOrGroupId IN :userIds ];
        system.assert(lstAccShare.isEmpty());

        lstAccTeam = [SELECT Id, TeamMemberRole FROM AccountTeamMember];
        system.assert(lstAccTeam.isEmpty());

        //******************************************
        Test.stopTest();

    }

    /***********************
    * Test data
    ***/
    private static void createTestData(){

        //Get Roles
        map<String, list<UserRole>> mapUnit2Roles = new map<String, list<UserRole>>();
        for(UserRole ur : [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'maxdome' ORDER BY ParentRoleId]){
            String key = ur.DeveloperName;
            mapUnit2Roles.put(key, new list<UserRole>{ur});
        }

        //User
        list<User> lstUser = new list<User>();
        Integer i = 1;
        Id idProfile = [Select Id from Profile where Name = 'System Administrator' or Name='Systemadministrator' limit 1].id;
        for(String unit : mapUnit2Roles.keySet()){
            unitStr = unit;
            lstUser.add(createTestUser(i, idProfile, mapUnit2Roles.get(unit)[0].Id, unit, false));
            i++;
        }
        insert lstUser;

        insertUser = createTestUser(999, idProfile, null, 'P7S1', true);

        system.runAs(insertUser){
            //Accounts
            List<Account> accountsList = new List<Account>();
            for (Integer j = 0; j < lstUser.size(); j++) {
                accountsList.add(cls_P7S1_TestData.createTestAccount(false));
            }
            insert accountsList;
            cntAccounts = accountsList.size();

            map<String, Account> mapUserId2Account = new map<String, Account>();
            for (Integer j = 0; j < lstUser.size(); j++) {
                User u = lstUser.get(j);
                mapUserId2Account.put(u.Id, accountsList.get(j));
                userIds.add(u.Id);
            }

            //Account Access
            list<P7S1_AccountAccess__c> lstAccAccess = new list<P7S1_AccountAccess__c>();
            for(String user : mapUserId2Account.keySet()){
                P7S1_AccountAccess__c aa = new P7S1_AccountAccess__c(P7S1_Account__c = mapUserId2Account.get(user).Id,
                                                                     RecordTypeId = P7S1_AccountSetTeamAndShare.RECTYPE_AUFNAHME_ACC_TEAM,
                                                                     P7S1_ApprovalState__c = 'Genehmigt',
                                                                     OwnerId = user);
                lstAccAccess.add(aa);
            }
            insert lstAccAccess;
        }

    }

    //User
    public static User createTestUser(Integer i, Id idProfile, String idRole, String unit, Boolean insertObject){
        User obj = new User();
        obj.ProfileId = idProfile;
        obj.FirstName = 'First' + i;
        obj.LastName = 'Last' + i;
        obj.Username = 'test@email' + i + '.de';
        obj.Email = 'test@email' + i + '.de';
        obj.Alias = 'fila' + i;
        obj.CommunityNickname = 'test@email' + i + '.de';
        obj.TimeZoneSidKey = 'America/Los_Angeles';
        obj.LocaleSidKey = 'en_US';
        obj.EmailEncodingKey = 'ISO-8859-1';
        obj.LanguageLocaleKey = 'en_US';
        obj.IsActive = true;
        obj.UserRoleId = idRole;
        obj.P7S1_Unit__c = unit;

        if(insertObject) insert obj;
        return obj;
    }

}