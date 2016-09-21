@isTest
public class SomTv_OLI_AdfExport_Test
{
    
    @TestSetup
    public static void dataSetup()
    {
        SomTv_AdfProjekt__c adfProjekt = createTestAdfProjekt(true);
        
        Opportunity opp = cls_P7S1_TestData.createTestOpportunity(false);
        opp.SomTv_AdFProjekt__c = adfProjekt.id;
        insert opp;
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
		olis.add(cls_P7S1_TestData.createTestOpportunityLineItem(false, opp));
		olis.add(cls_P7S1_TestData.createTestOpportunityLineItem(false, opp));
        insert olis;
    }
    
    @isTest
    public static void Test_Container()
    {
        Id projId = [SELECT Id FROM SomTv_AdfProjekt__c].id;
        Test.startTest();        
        SomTv_OLI_AdfExportData  data = new SomTv_OLI_AdfExportData (projId);
        String query = data.buildQuery();
        List<SObject> result = Database.query(query);
        system.assertEquals(2, result.size());
        Test.stopTest();
    }
    
    @isTest
    public static void Test_Controller()
    {
        Id projId = [SELECT Id FROM SomTv_AdfProjekt__c].id;
        Test.startTest();        
        SomTv_OLI_AdfExportCtrl controller = new SomTv_OLI_AdfExportCtrl(projId);
        String contentString = controller.content;
        Test.stopTest();
    }
    
    //TODO: Auslagern
    
 	public static SomTv_AdfProjekt__c createTestAdfProjekt (Boolean insertObject)
    {
        SomTv_AdfProjekt__c adfProjekt = new SomTv_AdfProjekt__c();
        adfProjekt.Name = 'Testprojekt';
        if(insertObject)
            insert adfProjekt;
        return adfProjekt;
    }
}