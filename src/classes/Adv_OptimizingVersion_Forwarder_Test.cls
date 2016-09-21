@isTest
public class Adv_OptimizingVersion_Forwarder_Test{

    public static testMethod void testOptimizingVersionForwarder(){
        
        ADvendio__OptimizingVersion__c objOV = createADvendioOptimizingVersion(true);
        
        PageReference p1 = Page.Adv_OptimizingVersion_Forwarder;
        Test.setCurrentPageReference(p1);
        
        ApexPages.StandardController sCon = new ApexPages.standardController(objOV);
        Adv_OptimizingVersion_Forwarder con = new Adv_OptimizingVersion_Forwarder(sCon);
     
            
        PageReference objPageRef = con.forward();
        System.assertNotEquals(null, objPageRef);
    }

    
    // TODO: move to TESTClass
    public static ADvendio__OptimizingVersion__c createADvendioOptimizingVersion(Boolean isInsert){
        ADvendio__OptimizingVersion__c objOV = new ADvendio__OptimizingVersion__c();
        if(isInsert) insert objOV;
        return objOV;
    }
}