@IsTest
private class SomTv_Opportunity_AgenturSplit_Test{

    public static testMethod void testSaveWithoutAddingAgenturSplit(){
        
        // Create Test Data
        Account objAcc = cls_P7S1_TestData.createTestAccount(true);
        Opportunity objOpp = cls_P7S1_TestData.createTestOpportunity(true);
        
        
        ///// AUSLAGERN IN cls_P7S1_TestData!
        SomTv_Agentursplit__c objAS1 = createTestAgenturSplit(true, objOpp, objAcc, 30);
        SomTv_Agentursplit__c objAS2 = createTestAgenturSplit(true, objOpp, objAcc, 30);        
        SomTv_Agentursplit__c objAS3 = createTestAgenturSplit(true, objOpp, objAcc, 40);                
        
        Test.startTest();
        
        // Create Class and StandardController
        PageReference pageRef = Page.SomTv_Opportunity_AgenturSplit;
        Test.setCurrentPage(pageRef);
        system.currentPageReference().getParameters().put('id', objAS1.Id);
        system.currentPageReference().getParameters().put('retURL', objOpp.Id);        




        ApexPages.StandardController sc = new ApexPages.StandardController(objAS1);
        SomTv_Opportunity_AgenturSplit con = new SomTv_Opportunity_AgenturSplit(sc);
        


        
        // User presses Save Button without changes
        con.saveAgentursplits();
        List<AggregateResult> agSUM = [SELECT SUM(SomTv_Prozent_Anteil__c) sum FROM SomTv_Agentursplit__c WHERE SomTv_Opportunity__c = :objOpp.ID];
        System.assert(agSUM[0].get('sum') == 100);
        
        Test.stopTest();    
    }
    
    
    public static testMethod void testDeleteAgenturSplit(){ 
    
    
        // Create Test Data
        Account objAcc = cls_P7S1_TestData.createTestAccount(true);
        Opportunity objOpp = cls_P7S1_TestData.createTestOpportunity(true);
        
        
        ///// AUSLAGERN IN cls_P7S1_TestData!
        SomTv_Agentursplit__c objAS1 = createTestAgenturSplit(true, objOpp, objAcc, 30);
        SomTv_Agentursplit__c objAS2 = createTestAgenturSplit(true, objOpp, objAcc, 30);        
        SomTv_Agentursplit__c objAS3 = createTestAgenturSplit(true, objOpp, objAcc, 40);                
        
        Test.startTest();
        
        PageReference pageRef = Page.SomTv_Opportunity_AgenturSplit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('delid', String.valueOf(objAS1.Id));
        ApexPages.currentPage().getParameters().put('retURL', String.valueOf(objOpp.Id));        



        // Create Class and StandardController
        ApexPages.StandardController sc = new ApexPages.StandardController(objAS1);
        SomTv_Opportunity_AgenturSplit con = new SomTv_Opportunity_AgenturSplit(sc);

    
        // Delete one Agentursplit
        con.iDelIndex = 0;
        con.delAgenturSplit();
        con.saveAgentursplits();

            
        Test.stopTest();       
    }  


    public static SomTv_Agentursplit__c createTestAgenturSplit(Boolean insertObject, Opportunity opportunity,Account account, Integer anteil) {
        SomTv_Agentursplit__c AgenturSplit_TestData = new SomTv_Agentursplit__c();
        AgenturSplit_TestData.SomTv_Prozent_Anteil__c = anteil;
        AgenturSplit_TestData.SomTv_Opportunity__c = opportunity.ID;
        AgenturSplit_TestData.SomTv_Agentur__c = account.ID;

        if (insertObject) insert AgenturSplit_TestData;
        return AgenturSplit_TestData;
    }    
}