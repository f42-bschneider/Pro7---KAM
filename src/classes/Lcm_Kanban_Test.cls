@isTest
public class Lcm_Kanban_Test{

    public static testMethod void testKanban(){

        Lcm_Release__c objRelease = createTestRelease(true);

        Case objCase = cls_P7S1_TestData.createTestCase(false);
        objCase.Lcm_Release__c = objRelease.ID;
        objCase.Lcm_KanStation__c = 'Dev';
        insert objCase;

        PageReference pageRef = Page.Lcm_Kanban;
        Test.setCurrentPage(pageRef);

        Test.startTest();

        Lcm_Kanban con = new Lcm_Kanban();

        // TESTS
        System.assert(con.getReleases().size() > 0 );
        System.assert(con.getStations().size() > 0 );
        System.assert(con.getTickets().size() > 0 );

        Test.stopTest();
    }


    // TODO: in TestData auslagern
    private static Lcm_Release__c createTestRelease(Boolean insertObject) {
        Lcm_Release__c release_TestData = new Lcm_Release__c(
            Name = 'KW29',
            Lcm_StartDate__c = Date.today(),
            Lcm_EndDate__c = Date.today()
        );
        if (insertObject) insert release_TestData;
        return release_TestData;
    }

}