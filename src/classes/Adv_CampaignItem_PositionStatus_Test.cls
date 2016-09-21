@isTest
public class Adv_CampaignItem_PositionStatus_Test {

    static testMethod void testCampaignItemPositionStatus(){
    
        Datetime dtNow = System.now();
    
        ADvendio__Campaign_Item__c objCI = cls_P7S1_TestData.createTestCampaignItem(true);
        
        
        // Status: Ad Status aktualisieren (Status senden)
        objCI.SomDig_LastAdServerStatusProcess__c = dtNow.addDays(-2);
        objCI.SomDig_LastAdServerStatusChange__c = dtNow.addDays(-1);        
        objCI.ADvendio__LastBookingProcess__c = dtNow;
        objCI.ADvendio__until_Date__c = Date.valueOf(dtNow.addDays(1));        
        update objCI;
        
        
        
        // Status:  An Adserver übermitteln (Position buchen)
        objCI.SomgDig_LastDurationChange__c = Date.valueOf(dtNow.addDays(2));
        objCI.SomDig_LastAdServerStatusProcess__c = dtNow.addDays(1);         
        update objCI;               
        
        
        
        ///// Position pausiert oder gestoppt
        objCI.ADvendio__AdserverStatus__c = 'Paused';
        objCI.ADvendio__LastBookingProcess__c = dtNow.addDays(3);                 
        update objCI;                       
        
        
                  
     
        ///// inaktiv
        // BD != dtNull && BD > AOD && BD > UFD && dDeliveredImp == null && !bMotivGebucht && bAdserverRel
        objCI.ADvendio__LastBookingProcess__c = dtNow.addDays(5);        
        objCI.ADvendio__until_Date__c = Date.valueOf(dtNow.addDays(4));   
        objCI.ADvendio__AdserverStatus__c = '';                     
        update objCI;              
        
        
    }
}