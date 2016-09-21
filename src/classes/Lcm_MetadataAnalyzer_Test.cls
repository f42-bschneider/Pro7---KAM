@isTest
private with sharing class Lcm_MetadataAnalyzer_Test {

    static testMethod void testRoleComparison() {
        UserRole newRole = new UserRole(Name = 'ThisRoleShouldNeverExist', DeveloperName = 'ThisRoleShouldNeverExist');
        insert newRole;

        Test.startTest();

        Lcm_MetadataAnalyzer analyzer = new Lcm_MetadataAnalyzer();
        analyzer.run();

        Test.stopTest();

        System.assert(!analyzer.data.isEmpty());
        System.assert(analyzer.data.get('Rollen').contains('Existiert nur im Setup: ThisRoleShouldNeverExist'));
    }

}