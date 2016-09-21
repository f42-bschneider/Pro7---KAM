/*
KV 02135
If "Sonderrabatt" Nachliefierung or Storno ohne Leistungsfluss set ADvendio__DoNotShowOnProposalPDF__c true
and ADvendio__ShowOnInvoicePDF__c false.
*/

public class Adv_CampaignItem_PDFCheckboxes {

    public static void setPDFCheckboxes(List<sObject> lstNewItems){
        for(sObject ci : lstNewItems){            
            ADvendio__Campaign_Item__c o = (ADvendio__Campaign_Item__c) ci;
            if(o.ADvendio__Rate_Discount_4_Name__c == 'Nachlieferung' || o.ADvendio__Rate_Discount_4_Name__c == 'Storno ohne Leistungsfluss'){
                o.ADvendio__DoNotShowOnProposalPDF__c = true;
                o.ADvendio__ShowOnInvoicePDF__c = false;    
            }            
        }        
    }           
}