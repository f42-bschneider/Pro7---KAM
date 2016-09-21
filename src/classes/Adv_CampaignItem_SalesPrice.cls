public with sharing class Adv_CampaignItem_SalesPrice {

    public static void transferDataFromProxy() {
        if (Adv_CampaignItem_Helper.allReady()) {
            Set<Id> setCampaignItemIDs = Adv_CampaignItem_Helper.getAllCampaignItemIds();
            Map<Id, ADvendio__Campaign_Item__c> mapCampaignItems = getCampaignItems(setCampaignItemIDs);
            List<SomDig_SalesPriceProxy__c> listAllProxies = getProxies(setCampaignItemIDs);

            if (!mapCampaignItems.isEmpty() && !listAllProxies.isEmpty()) {
                List<ADvendio__Campaign_Item__c> listCampaignItems = new List<ADvendio__Campaign_Item__c>();

                for (SomDig_SalesPriceProxy__c proxy : listAllProxies) {
                    ADvendio__Campaign_Item__c campaignItem = mapCampaignItems.get(proxy.SomDig_CampaignItem__c);

                    if (campaignItem != null) {
                        Boolean changed = false;

                        if (campaignItem.ADvendio__Sales_Price__c != proxy.SomDig_SalesPrice__c) {
                            campaignItem.ADvendio__Sales_Price__c = proxy.SomDig_SalesPrice__c;
                            changed = true;
                        }
                        if (campaignItem.ADvendio__SurchargeSalesPrice__c != proxy.SomDig_TotalSurcharge__c) {
                            campaignItem.ADvendio__SurchargeSalesPrice__c = proxy.SomDig_TotalSurcharge__c;
                            changed = true;
                        }
                        if (changed) listCampaignItems.add(campaignItem);
                    }
                }

                if (!listCampaignItems.isEmpty()) update listCampaignItems;
            }
        }
    }


    private static List<SomDig_SalesPriceProxy__c> getProxies(Set<Id> setCampaignItemIDs) {
        return [
            SELECT SomDig_SalesPrice__c, SomDig_TotalSurcharge__c, SomDig_CampaignItem__c
              FROM SomDig_SalesPriceProxy__c
             WHERE SomDig_CampaignItem__c IN :setCampaignItemIDs
        ];
    }


    private static Map<Id, ADvendio__Campaign_Item__c> getCampaignItems(Set<Id> setCampaignItemIDs) {
        return new Map<Id, ADvendio__Campaign_Item__c>([
            SELECT ADvendio__Sales_Price__c, ADvendio__SurchargeSalesPrice__c, SomDig_Freitextnotiz__c
              FROM ADvendio__Campaign_Item__c
             WHERE Id IN :setCampaignItemIDs
        ]);
    }

}