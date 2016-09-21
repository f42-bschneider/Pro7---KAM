/**
 * Test class for SomDig_Buchungssatz_EaBatch.
 */
@IsTest
public with sharing class SomDig_Buchungssatz_EaBatch_Test {

	@IsTest
	public static void testEaBatch()  {
		Test.StartTest();
		
		SomDig_Buchungssatz_EaBatch	c = new SomDig_Buchungssatz_EaBatch(SomDig_Buchungssatz_EaBatch.PROCESS_ULTIMO_MINUS_5, null);
		
		c.setInvoiceItemIds(null);
		
		Database.executeBatch(c, 1);
		
		System.assertNotEquals(null, c.getQueryString());
		
		Test.StopTest();
	}
}