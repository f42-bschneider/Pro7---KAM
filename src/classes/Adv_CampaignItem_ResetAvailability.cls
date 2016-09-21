/*
KV: 02614
Called from Trigger, Resets Availability
*/
public class Adv_CampaignItem_ResetAvailability {
    public static void setAvailability(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<ADvendio__Campaign_Item__c> lstNewItems, Map<Id, ADvendio__Campaign_Item__c> mapNewItems, List<ADvendio__Campaign_Item__c> lstOldItems, Map<Id, ADvendio__Campaign_Item__c> mapOldItems) {

        Set<ID> setCIID = new Set<ID>();
       
        for (ADvendio__Campaign_Item__c ci : lstNewItems) {
            ADvendio__Campaign_Item__c ciOld = mapOldItems.get(ci.Id);                    
            
            if (ci.ADvendio__AdDayOfWeek__c != ciOld.ADvendio__AdDayOfWeek__c ||
                ci.ADvendio__AdHourOfDay__c != ciOld.ADvendio__AdHourOfDay__c ||
                ci.ADvendio__AdKeyValues__c != ciOld.ADvendio__AdKeyValues__c ||
                ci.ADvendio__AdKeyWords__c != ciOld.ADvendio__AdKeyWords__c ||
                ci.ADvendio__AdOperatingSystems__c != ciOld.ADvendio__AdOperatingSystems__c ||
                ci.ADvendio__AdWebBrowsers__c != ciOld.ADvendio__AdWebBrowsers__c ||
                ci.ADvendio__FC_Ad_served_every__c != ciOld.ADvendio__FC_Ad_served_every__c ||
                ci.ADvendio__FC_Period__c != ciOld.ADvendio__FC_Period__c ||
                ci.ADvendio__from_Date__c != ciOld.ADvendio__from_Date__c ||
                ci.ADvendio__Guaranteed_AI__c != ciOld.ADvendio__Guaranteed_AI__c ||
                ci.ADvendio__Priority__c != ciOld.ADvendio__Priority__c ||
                ci.ADvendio__Quantity__c != ciOld.ADvendio__Quantity__c ||
                ci.ADvendio__Targetingabbrevation__c != ciOld.ADvendio__Targetingabbrevation__c ||
                ci.ADvendio__until_Date__c != ciOld.ADvendio__until_Date__c
            ){
                setCIID.add(ci.ID);
            }
        }
        

           
        if (!setCIID.isEmpty()) {
            
            Set<ID> setPacketIDs = new Set<ID>();
            for(ADvendio__Campaign_Item__c o : lstNewItems)
                setPacketIDs.add(o.ADvendio__PacketItem__c);            
            
            // for each paket count how many Youtube Items exist
            Map<ID, Integer> mapPaketCountYT = new Map<ID, Integer>();
            for(ADvendio__Campaign_Item__c packet : [SELECT ADvendio__PacketItem__r.SomDig_Verteilung__c, (SELECT SomDig_Verteilung__c, SomDig_BelegungseinheitTyp__c  FROM ADvendio__PacketComponents__r) FROM ADvendio__Campaign_Item__c WHERE Id IN :setPacketIDs]){
                Integer iYT = 0;
                for(ADvendio__Campaign_Item__c comp : packet.ADvendio__PacketComponents__r){
                    if(comp.SomDig_BelegungseinheitTyp__c  == 'YouTube'){
                        iYT++;
                    }
                }
                mapPaketCountYT.put(packet.ID, iYT);
            }            


            List<ADvendio__Campaign_Item__c> listUpdateCI = new List<ADvendio__Campaign_Item__c>();
            
            for (ADvendio__Campaign_Item__c ci : [SELECT ADvendio__Availability__c,ADvendio__PacketItem__c, SomDig_Verteilung__c, ADvendio__PacketItem__r.SomDig_Verteilung__c FROM ADvendio__Campaign_Item__c WHERE ID IN :mapNewItems.keySet()]){
                if (ci.ADvendio__PacketItem__c != null && mapPaketCountYT.containsKey(ci.ADvendio__PacketItem__c)){       
                    if(mapPaketCountYT.get(ci.ADvendio__PacketItem__c) >= 1 && ci.ADvendio__PacketItem__r.SomDig_Verteilung__c == 'Prorated')                
                        continue;                        
                }
                
                for(ADvendio__Campaign_Item__c o : lstNewItems){
                    if(o.ID == ci.ID) o.ADvendio__Availability__c = null;
                }
            }
        }
    }   
}