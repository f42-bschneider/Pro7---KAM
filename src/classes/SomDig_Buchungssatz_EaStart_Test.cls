/**
 * Test class for SomDig_Buchungssatz_EaStart.
 */
@IsTest
public with sharing class SomDig_Buchungssatz_EaStart_Test {

	@IsTest
	public static void testEaStartPagination()  {
		Test.StartTest();

		PageReference pr = Page.SomDig_Buchungssatz_EaStart;
		Test.setCurrentPage(pr);		

		SomDig_Buchungssatz_EaStart crtl = new SomDig_Buchungssatz_EaStart();
		
		for (Integer i = 0; i <= SomDig_Buchungssatz_EaStart.MAX_NUMBER_MCS_PER_PAGE; i++) {
			crtl.allMediaCampaigns.add(new ADvendio__MediaCampaign__c(Name=('Test Mc ' + (i+1))));
		}
		
		crtl.initPagination();
		
		System.assertEquals(true, crtl.getHasResult());
		System.assertEquals(2, crtl.getTotalPages());

		System.assertEquals(1, crtl.getPageNumber());
		System.assertEquals(true, crtl.getHasNext());
		System.assertEquals(false, crtl.getHasPrevious());
		
		crtl.next();
		System.assertEquals(2, crtl.getPageNumber());
		System.assertEquals(false, crtl.getHasNext());
		System.assertEquals(true, crtl.getHasPrevious());
		
		crtl.previous();
		System.assertEquals(1, crtl.getPageNumber());
		System.assertEquals(true, crtl.getHasNext());
		System.assertEquals(false, crtl.getHasPrevious());

		crtl.last();
		System.assertEquals(2, crtl.getPageNumber());
		System.assertEquals(false, crtl.getHasNext());
		System.assertEquals(true, crtl.getHasPrevious());
		
		crtl.first();
		System.assertEquals(1, crtl.getPageNumber());
		System.assertEquals(true, crtl.getHasNext());
		System.assertEquals(false, crtl.getHasPrevious());
				
		crtl.filterMediaCampaign.ADvendio__Closed_Lost__c = false;
		crtl.changeProcessRunningDate();

		Test.StopTest();
	}
}