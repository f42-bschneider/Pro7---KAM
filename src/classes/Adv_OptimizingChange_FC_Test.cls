@isTest
public class Adv_OptimizingChange_FC_Test{

    public static testMethod void testOptimizingFC(){
        
        // Optimizing Version
        ADvendio__OptimizingVersion__c objOV = createADvendioOptimizingVersion(false);
        objOV.Adv_AvailabilityApproved__c = true;
        insert objOV;
        
        // Campaign Item
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(true);
        
        
        // Optimizing changes
        List<ADvendio__OptimizingChange__c> listOC = new List<ADvendio__OptimizingChange__c>();
        
        ADvendio__OptimizingChange__c objOCFCPeriod = createADvendioOptimizingChange(false, objOV, objCI);
        objOCFCPeriod.ADvendio__FieldName__c = 'advendio__fc_period__c';
        objOCFCPeriod.ADvendio__OptimizedValue__c = 'Minute';
        
        ADvendio__OptimizingChange__c objOCFCQuan = createADvendioOptimizingChange(false, objOV, objCI);
        objOCFCQuan.ADvendio__FieldName__c = 'advendio__fc_quantity__c';
        objOCFCQuan.ADvendio__OptimizedValue__c = '1';
        
        
        listOC.add(objOCFCPeriod);
        listOC.add(objOCFCQuan);        
        
        
        Test.startTest();
        insert listOC;
        
        
        // Test Insert
        Integer iCount = [SELECT COUNT() FROM ADvendio__OptimizingChange__c WHERE ADvendio__OptimizingVersion__c = :objOV.ID AND ADvendio__FieldName__c = 'advendio__fc_ad_served_every__c'];
        System.assert(iCount == 1);                    
        
        
        Test.stopTest();        
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