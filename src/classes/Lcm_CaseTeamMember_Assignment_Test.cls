@isTest
private class Lcm_CaseTeamMember_Assignment_Test {

    static testMethod void testCaseTeamMembers() {
        Case testCase = cls_P7S1_TestData.createTestCase(true);
        User[] user = [select Id from User where isActive = true and Id != :UserInfo.getUserId() and UserType = 'Standard' limit 2];
        CaseTeamMember[] ctml;

        try {
            ctml = [select Id, MemberId, Member.Name, TeamRoleId, TeamRole.Name from CaseTeamMember where ParentId = :testCase.Id];
        } catch(Exception e) {
            System.assertNotEquals(null, e);
        }

        Test.startTest();

        testCase.OwnerId = user[0].Id;
        update testCase;
        ctml = [select Id, MemberId, Member.Name, TeamRoleId, TeamRole.Name from CaseTeamMember where ParentId = :testCase.Id];
        System.assertEquals(1, ctml.size());
        System.assertEquals(Userinfo.getUserId(), ctml[0].MemberId);
        System.assertEquals('Anforderungsmanager', ctml[0].TeamRole.Name);

        testCase.OwnerId = user[1].Id;
        update testCase;
        ctml = [select Id, MemberId, Member.Name, TeamRoleId, TeamRole.Name from CaseTeamMember where ParentId = :testCase.Id];
        System.assertEquals(2, ctml.size());
        for (CaseTeamMember ctm : ctml) {
            if (ctm.MemberId == Userinfo.getUserId()) {
                system.assertEquals(Userinfo.getUserId(), ctm.MemberId);
                system.assertEquals('Anforderungsmanager', ctm.TeamRole.Name);
            } else {
                System.assertEquals(user[0].Id, ctm.MemberId);
                System.assertEquals('Beobachter', ctm.TeamRole.Name);
            }
        }

        Test.stopTest();
    }

}