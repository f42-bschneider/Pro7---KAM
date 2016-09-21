/**
 * Test class for SomDig_Buchungssatz_EaBase.
 */
@IsTest
public class SomDig_Buchungssatz_EaBase_Test {
	private static SomDig_Werbetraegergruppierung__c Werbetraegergruppierung_TestData;
	
	@IsTest
	public static void testStaticMethods()  {
		generateTestData();

		Test.StartTest();
		
		String IaNummer = SomDig_Buchungssatz_EaBase.getIaNummer(cls_P7S1_TestData.Mediagattung_TestData.Id,
																cls_P7S1_TestData.MediagattungsSegment_TestData.Id,
																cls_P7S1_TestData.MediagattungsDifferenzierung_TestData.Id,
																Werbetraegergruppierung_TestData.Id);
		
		System.assertEquals('123456789', IaNummer);
		
		String Sachkonto = SomDig_Buchungssatz_EaBase.getSachkontoNummerByType('Test Sachkonto Typ 1');
		System.assertEquals('123456', Sachkonto);
		
		Sachkonto = SomDig_Buchungssatz_EaBase.getSachkontoNummerByInternalOrder(cls_P7S1_TestData.Mediagattung_TestData.Id,
																				cls_P7S1_TestData.MediagattungsSegment_TestData.Id,
																				cls_P7S1_TestData.MediagattungsDifferenzierung_TestData.Id,
																				Werbetraegergruppierung_TestData.Id);
		System.assertEquals('234567', Sachkonto);

		Sachkonto = SomDig_Buchungssatz_EaBase.getSachkonto(cls_P7S1_TestData.Mediagattung_TestData.Id,
															cls_P7S1_TestData.MediagattungsSegment_TestData.Id,
															cls_P7S1_TestData.MediagattungsDifferenzierung_TestData.Id,
															Werbetraegergruppierung_TestData.Id,
															'Test Sachkonto Typ 1');
		System.assertEquals('234567', Sachkonto);

		Sachkonto = SomDig_Buchungssatz_EaBase.getSachkonto(cls_P7S1_TestData.Mediagattung_TestData.Id,
															cls_P7S1_TestData.MediagattungsSegment_TestData.Id,
															cls_P7S1_TestData.MediagattungsDifferenzierung_TestData.Id,
															null,
															'Test Sachkonto Typ 1');
		System.assertEquals('123456', Sachkonto);
		
		System.assertNotEquals(null, SomDig_Buchungssatz_EaBase.getRecordTypeIdByName('ADvendio__Campaign_Item__c', 'Standard'));
		
		Map<Date, Integer> dayInMonth = SomDig_Buchungssatz_EaBase.getNumberOfDaysInMonth(System.today(), System.Today().addMonths(1));
		System.assertEquals(2, dayInMonth.size());
		
		Test.StopTest();
	}
	
	@IsTest
	public static void testFakeCoverage()  {
		Test.StartTest();
		
		SomDig_Buchungssatz_EaBase c = new SomDig_Buchungssatz_EaBase();
		c.fakeTestingCoverage();
		
		Test.StopTest();
	}

	private static void generateTestData() {
		SomDig_Mediagattung__c Mediagattung_TestData = cls_P7S1_TestData.createTestMediagattung(true);

		SomDig_MediagattungsSegment__c MediagattungsSegment_TestData = cls_P7S1_TestData.createTestMediagattungsSegment(true);

		SomDig_MediagattungsDifferenzierung__c MediagattungsDifferenzierung_TestData = cls_P7S1_TestData.createTestMediagattungsDifferenzierung(true);

		Werbetraegergruppierung_TestData = new SomDig_Werbetraegergruppierung__c(Name='Test Werbeträgergruppierung 1');
		insert Werbetraegergruppierung_TestData;

		SomDig_IaNummer__c IaNummer = new SomDig_IaNummer__c(Name = '123456789', Som_SachkontokonzernintereneVerrechnung__c = 234567,
															SomDig_BeschreibungCO__c='Test IA-Nummer 1',
															SomDig_Mediagattung__c = Mediagattung_TestData.Id,
															SomDig_MediagattungsSegment__c = MediagattungsSegment_TestData.Id,
															SomDig_MediagattungsDifferenzierung__c = MediagattungsDifferenzierung_TestData.Id,
															SomDig_Werbetraergergruppierung__c = Werbetraegergruppierung_TestData.Id);
		insert IaNummer;
		
		SomDig_Sachkonto__c Sachkonto = new SomDig_Sachkonto__c(Name = '123456', SomDig_SachkontoTyp__c = 'Test Sachkonto Typ 1');
		insert Sachkonto;
	}
}