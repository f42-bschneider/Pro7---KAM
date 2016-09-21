@isTest
private class Adv_OptimizingVersion_Attachment_Test {

    @isTest static void testOptimizingVersionCreateAttachment() {              
    
        // Create Campaign
        ADvendio__MediaCampaign__c objCampaign = cls_P7S1_TestData.createTestMediaCampaign(true); 

        // Optimizing Version 
        ADvendio__OptimizingVersion__c objOV = createADvendioOptimizingVersion(false);
        objOV.ADvendio__MediaCampaign__c = objCampaign.ID;
        insert objOV;    
        

        String res = Adv_OptimizingVersion_Attachment.attachPDFToOV( objOV.ID, objCampaign.ID, 'testname' );
          
        System.assert( res == 'SUCCESS' );
    }
    
    // TODO: move to TESTClass
    public static ADvendio__OptimizingVersion__c createADvendioOptimizingVersion(Boolean isInsert){
        ADvendio__OptimizingVersion__c objOV = new ADvendio__OptimizingVersion__c();
        if(isInsert) insert objOV;
        return objOV;
    }      
}