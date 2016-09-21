@isTest
public class Adv_OptimizingVersion_Activate_Test{

    public static testMethod void testOptimizingVersionActivate(){
        
        // Create Campaig
        ADvendio__MediaCampaign__c objCampaign = cls_P7S1_TestData.createTestMediaCampaign(true); 
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(true, objCampaign);
    
    
    
        // Optimizing Version 1
        ADvendio__OptimizingVersion__c objOV1 = createADvendioOptimizingVersion(false);
        objOV1.ADvendio__MediaCampaign__c = objCampaign.ID;
        insert objOV1;    
        
        ADvendio__OptimizingChange__c objChange1 = createADvendioOptimizingChange(true, objOV1, objCI);        
        
        
        
        // Optimizing Version 2
        ADvendio__OptimizingVersion__c objOV2 = createADvendioOptimizingVersion(false);
        objOV2.ADvendio__MediaCampaign__c = objCampaign.ID;
        insert objOV2;            
        
        ADvendio__OptimizingChange__c objChange2 = createADvendioOptimizingChange(true, objOV2, objCI);        
    
        
        
        
        // Before activation there are two Optimizing Versions
        System.assert(2 == [SELECT COUNT() FROM ADvendio__OptimizingVersion__c WHERE ADvendio__MediaCampaign__c = :objCampaign.ID]);
        
        objOV1.ADvendio__DateOfActivation__c = System.now();
        update objOV1;
        
        
        // After activation there is one Optimizing Versions        
        System.assert(1 == [SELECT COUNT() FROM ADvendio__OptimizingVersion__c WHERE ADvendio__MediaCampaign__c = :objCampaign.ID]);        
    }
    
    
    // TODO: move to TESTClass
    public static ADvendio__OptimizingVersion__c createADvendioOptimizingVersion(Boolean isInsert){
        ADvendio__OptimizingVersion__c objOV = new ADvendio__OptimizingVersion__c();
        if(isInsert) insert objOV;
        return objOV;
    }    
    
    public static ADvendio__OptimizingChange__c createADvendioOptimizingChange(Boolean isInsert, ADvendio__OptimizingVersion__c objOV, ADvendio__Campaign_Item__c objCI){
    
        ADvendio__OptimizingChange__c objOC = new ADvendio__OptimizingChange__c();
        objOC.ADvendio__OptimizingVersion__c = objOV.ID;
        objOC.ADvendio__CampaignItem__c = objCI.ID;
        
        if(isInsert) insert objOC;
        return objOC;    
    }    

}