/*
KV: 01371, 02982
Called from Trigger
Controlls Position-Status
*/
public class Adv_CampaignItem_PositionStatus{
    public static void setStatus(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){

        Map<ID, Schema.RecordTypeInfo> mapRecordTypes = Schema.SObjectType.ADvendio__Campaign_Item__c.getRecordTypeInfosById();
        
        
        for(sObject ci : lstNewItems){
            
            ADvendio__Campaign_Item__c o = (ADvendio__Campaign_Item__c) ci;
            
            Boolean bMotivGebucht = o.SomDig_MotivEingebucht__c;           
            String sADServerStatus = o.ADvendio__AdserverStatus__c;             
            String sBillingCat = o.ADvendio__Billing_category__c;
            String sSubmitStatus = o.ADvendio__StatusSubmittedToAdServer__c;
            String sOptiExclusion = o.ADvendio__OptimizationExclusion__c != null ? o.ADvendio__OptimizationExclusion__c : ''; 

            String sRT = mapRecordTypes.containsKey(o.RecordTypeId) ? mapRecordTypes.get(o.RecordTypeId).getName() : '';
            
            Double dDeliveredImp     = o.ADvendio__Delivered_Impressions__c != null ? o.ADvendio__Delivered_Impressions__c : 0;             
            Double dDeliveredClick   = o.ADvendio__Delivered_Clicks__c      != null ? o.ADvendio__Delivered_Clicks__c : 0;  
            Double dSollbisHeute     = o.SomDig_AIClicksSollBisHeute__c     != null ? o.SomDig_AIClicksSollBisHeute__c : 0;    
            Double dQuan             = o.ADvendio__Quantity__c              != null ? o.ADvendio__Quantity__c : 0;       
            
            //  If a date is null set to 01.01.1980
            Datetime dtNull = Datetime.newInstance(1980, 1, 1, 0, 0, 0);
            Datetime Now = System.today();
            Datetime BD  = o.ADvendio__LastBookingProcess__c             != null ? o.ADvendio__LastBookingProcess__c : dtNull;
            Datetime AOD = o.SomDig_LastOptimizationActivationDate__c    != null ? o.SomDig_LastOptimizationActivationDate__c : dtNull;
            Datetime UFD = o.SomgDig_LastDurationChange__c               != null ? o.SomgDig_LastDurationChange__c : dtNull;
            Datetime SAD = o.SomDig_LastAdServerStatusChange__c          != null ? o.SomDig_LastAdServerStatusChange__c : dtNull;
            Datetime SAS = o.SomDig_LastAdServerStatusProcess__c         != null ? o.SomDig_LastAdServerStatusProcess__c : dtNull;
            Datetime Until = o.ADvendio__until_Date__c                   != null ? o.ADvendio__until_Date__c : dtNull;
            Datetime FromDate = o.ADvendio__from_Date__c                    != null  ? o.ADvendio__from_Date__c : dtNull;                                                            
    
            

            ///// NonAdserver
            if(!o.SomDig_AdServerRelevant__c || sRT == 'Paket' || sRT == 'Packet' || (dQuan < 0 && sOptiExclusion.contains('Dies ist eine Stornierungsposition einer früheren Optimierung')) || (dQuan < 0 && sOptiExclusion.contains('This is a canceled Campaign Item from a previous optimization.'))){
                o.SomDig_PositionStatus__c = 'NonAdserver';            
                continue;                
            }
            
            ///// Ad Status aktualisieren
            if(SAS < SAD && Now < Until && BD != dtNull){
                o.SomDig_PositionStatus__c = 'Ad Status aktualisieren';
                continue;
            }
            
            ///// An Adserver übermitteln        
            if(((BD > AOD || BD > UFD) &&  sSubmitStatus == 'Error') ||
                (BD == dtNull)
            ){
                o.SomDig_PositionStatus__c = 'An Adserver übermitteln';            
                continue;
            }
            
            ///// Position pausiert
            if(SAS > SAD && sADServerStatus == 'Paused' && BD != dtNull){
                o.SomDig_PositionStatus__c = 'Position pausiert';
                continue;
            }
            
            ///// Position gestoppt
            if(SAS > SAD && sADServerStatus == 'Released' && BD != dtNull){
                o.SomDig_PositionStatus__c = 'Position gestoppt';
                continue;
            }     
            
            ///// inaktiv
            if(BD != dtNull && dDeliveredImp == 0 && !bMotivGebucht &&
               (sSubmitStatus == 'Created' || sSubmitStatus == 'Updated')
            ){
                o.SomDig_PositionStatus__c = 'inaktiv';
                continue;
            }
            
            ///// Bereit
            if(BD != dtNull && dDeliveredImp == 0 && bMotivGebucht && FROMDate > Now &&
              (sSubmitStatus == 'Created' || sSubmitStatus == 'Updated')
            ){
                o.SomDig_PositionStatus__c = 'bereit';
                continue;
            }
            
            ///// Auslieferung normal
            if(BD != dtNull && FromDate <= Now && Until >= Now && o.ADvendio__PerformanceIndicator__c >= 100 &&
              (sSubmitStatus == 'Created' || sSubmitStatus == 'Updated')
              ){                
                o.SomDig_PositionStatus__c = 'Auslieferung-normal';
                continue;
            }
            
            ///// Auslieferung @risk
            if(BD != dtNull && FromDate <= Now && Until >= Now && o.ADvendio__PerformanceIndicator__c < 100 &&
               (sSubmitStatus == 'Created' || sSubmitStatus == 'Updated')                
               ){
                o.SomDig_PositionStatus__c = 'Auslieferung-@Risk';
                continue;
            }
            
            ///// Abgelaufen erfüllt
            if(BD != dtNull && Now > Until &&
              (sBillingCat == 'CPC' && dDeliveredClick >= dQuan || sBillingCat != 'CPC' && dDeliveredImp >= dQuan)){
                o.SomDig_PositionStatus__c = 'abgelaufen-erfüllt';
                continue;
            }
            
            ///// Abgelaufen unterliefert
            if(BD != dtNull && Now > Until &&
              (sBillingCat == 'CPC' && dDeliveredClick < dQuan || sBillingCat != 'CPC' && dDeliveredImp < dQuan)){
                o.SomDig_PositionStatus__c = 'abgelaufen-unterliefert';
                continue;
            }                                                       
        }        
    }
}