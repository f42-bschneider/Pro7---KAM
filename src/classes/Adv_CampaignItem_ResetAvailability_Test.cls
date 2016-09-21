@isTest
public class Adv_CampaignItem_ResetAvailability_Test {

    static testMethod void testSetAvailability(){
        
        // Create Paket
        ADvendio__Campaign_Item__c objCIPaket = cls_P7S1_TestData.createTestCampaignItem(true);
        
        
        // Create Component with SomDig_BelegungseinheitTyp__c = 'YouTube'
        ADvendio__Placement__c objPlacement = cls_P7S1_TestData.createTestPlacement(false);
        objPlacement.SomDig_Typ__c = 'YouTube';
        insert objPlacement;
        
        ADvendio__Ad_Specs__c objSpec = cls_P7S1_TestData.createTestAdSpec(true, objPlacement);
        ADvendio__Ad_price__c objPrice = cls_P7S1_TestData.createTestAdPrice(true, objSpec);
        
        Test.startTest();    
        ADvendio__Campaign_Item__c objCIComponent = cls_P7S1_TestData.createTestCampaignItem(false, objPrice);
        objCIComponent.ADvendio__PacketItem__c = objCIPaket.ID;
        insert objCIComponent;
                


        objCIComponent.ADvendio__until_Date__c = objCIComponent.ADvendio__until_Date__c.addDays(1);
        update objCIComponent;
        Test.stopTest();        
        
        objCIComponent = [SELECT ADvendio__Availability__c FROM ADvendio__Campaign_Item__c WHERE ID = :objCIComponent.ID];
        
        // TODO: asserts 
    }
}