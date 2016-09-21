/*
KV: 02453
When a Campaign-Item with negative amount
*/
public class Adv_CampaignItem_Storno {

    public static void updateFields(List<ADvendio__Campaign_Item__c> lstNewItems, Boolean isAfter){
        if(!isAfter || !SomDig_SOQLOptimizer.bCampaignItemStorno_Run) return;
        // Prepare map to the Delivered AIs from related Object
        Set<ID> setCIIDs = new Set<ID>();
        for(ADvendio__Campaign_Item__c o : lstNewItems){
            if(o.ADvendio__Quantity__c < 0 && o.SomDig_Stornoposition__c)
                if(o.ADvendio__Delivered_Impressions__c == null || o.ADvendio__Delivered_Impressions__c == 0)
                    setCIIDs.add(o.ID);
        }

        if(!setCIIDs.isEmpty()){
            // Get Campaign Updates to update
            Set<ID> setUpdateRelatedCIs = new Set<ID>();
            Set<ID> setUpdateNegativeCIs = new Set<ID>();
            System.Debug('+++++SELECT Adv_CampaignItem_Storno');
            for(ADvendio__Campaign_Item__c o : [SELECT ID, ADvendio__from_Date__c, ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.RecordType.DeveloperName, ADvendio__PositionReference__c, ADvendio__PositionReference__r.SomDig_SumDeliveredAIsManual__c FROM ADvendio__Campaign_Item__c WHERE ID IN :setCIIDs]){
                // Skip if NonAdServer & Startdate in the Past
               if(o.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.RecordType.DeveloperName == 'Standard' && o.ADvendio__from_Date__c < System.Today()){
                    continue;
               }

               // Check if related Position (positive) has delivered AIs
               if(o.ADvendio__PositionReference__c != null && o.ADvendio__PositionReference__r.SomDig_SumDeliveredAIsManual__c != 0){
                       continue;
               }

               setUpdateNegativeCIs.add(o.ID);
               if(o.ADvendio__PositionReference__c != null){
                  setUpdateRelatedCIs.add(o.ADvendio__PositionReference__c);
               }
            }


            // Update Negative CIs
            if(!setUpdateNegativeCIs.isEmpty() || !setUpdateRelatedCIs.isEmpty()){
                System.Debug('+++++SELECT Adv_CampaignItem_Storno');
                List<ADvendio__Campaign_Item__c> listNegativeCIs = new List<ADvendio__Campaign_Item__c>([SELECT ID FROM ADvendio__Campaign_Item__c WHERE ID IN :setUpdateNegativeCIs OR ID IN :setUpdateRelatedCIs]);
                for(ADvendio__Campaign_Item__c o : listNegativeCIs){
                    o.ADvendio__rate_discount_4_name__c = 'Storno ohne Leistungsfluss';

                    if(setUpdateRelatedCIs.contains(o.ID))
                        o.ADvendio__AdserverStatus__c = 'Released';
                }
                SomDig_SOQLOptimizer.bCampaignItemStorno_Run = false;
                update listNegativeCIs;
            }
        }
    }
}