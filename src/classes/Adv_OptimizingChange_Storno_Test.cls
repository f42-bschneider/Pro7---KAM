@isTest
public class Adv_OptimizingChange_Storno_Test{

    public static testMethod void testOptimizingChangeStorno(){
        
        // Optimizing Version
        ADvendio__OptimizingVersion__c objOV = createADvendioOptimizingVersion(false);
        insert objOV;
        
        // Campaign Item
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(true);
        
        
        // Optimizing changes
        ADvendio__OptimizingChange__c objOCAvail = createADvendioOptimizingChange(false, objOV, objCI);
        objOCAvail.ADvendio__FieldName__c = 'advendio__rate_discount_4_name__c';
        objOCAvail.ADvendio__OptimizedValue__c = 'Storno mit Leistungsfluss';
        insert objOCAvail;
        

        
        // After the Trigger has run, the "Adv_AvailabilityApproved__c" checkbox on the Optimizing Version must be false
        //objOV = [SELECT Adv_AvailabilityApproved__c FROM ADvendio__OptimizingVersion__c WHERE ID = :objOV.ID];
        //System.Assert(objOV.Adv_AvailabilityApproved__c == false);
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