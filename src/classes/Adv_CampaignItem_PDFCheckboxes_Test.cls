@isTest
public class Adv_CampaignItem_PDFCheckboxes_Test {

    static testMethod void testSetPDFCheckboxes(){
    
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(false);
        objCI.ADvendio__Rate_Discount_4_Name__c = 'Nachlieferung';
        insert objCI;
        
        objCI = [SELECT ADvendio__DoNotShowOnProposalPDF__c, ADvendio__ShowOnInvoicePDF__c FROM ADvendio__Campaign_Item__c WHERE ID = :objCI.ID limit 1];
        System.assert(objCI.ADvendio__DoNotShowOnProposalPDF__c == true);                
        System.assert(objCI.ADvendio__ShowOnInvoicePDF__c == false);                        
    }
}