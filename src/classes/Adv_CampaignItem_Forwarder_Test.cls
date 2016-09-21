@isTest
public class Adv_CampaignItem_Forwarder_Test{

    public static testMethod void testCampaignItemForwarderEdit(){
        
        ID rcIDAuftrag = Schema.SObjectType.ADvendio__MediaCampaign__c.RecordTypeInfosByName.get('Auftrag').RecordTypeId;
        
        // Auftrag
        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(false);
        objMC.RecordTypeID = rcIDAuftrag;
        insert objMC;
        
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(true, objMC);
        
        Test.startTest();
        
        PageReference p1 = Page.Adv_CampaignItem_Forwarder;
        Test.setCurrentPageReference(p1);
        
        ApexPages.StandardController sCon = new ApexPages.standardController(objCI);
        Adv_CampaignItem_Forwarder con = new Adv_CampaignItem_Forwarder(sCon);
     
            
        PageReference objPageRef = con.forward();
        System.assertNotEquals(null, objPageRef);
        
        
        Test.stopTest();        
    }
    
    
    public static testMethod void testCampaignItemForwarderDelete(){
        
        ID rcIDAuftrag = Schema.SObjectType.ADvendio__MediaCampaign__c.RecordTypeInfosByName.get('Auftrag').RecordTypeId;
        
        // Auftrag
        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(false);
        objMC.RecordTypeID = rcIDAuftrag;
        insert objMC;
        
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(true, objMC);
        
        Test.startTest();
        
        PageReference p1 = Page.Adv_CampaignItem_Forwarder;
        p1.getParameters().put('delID', objCI.ID);
        Test.setCurrentPageReference(p1);
        
        ApexPages.StandardController sCon = new ApexPages.standardController(objCI);
        Adv_CampaignItem_Forwarder con = new Adv_CampaignItem_Forwarder(sCon);
     
            
        PageReference objPageRef = con.forward();
        System.assertNotEquals(null, objPageRef);
        
        
        Test.stopTest();        
    }    
}