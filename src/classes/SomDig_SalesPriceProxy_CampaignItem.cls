public with sharing class SomDig_SalesPriceProxy_CampaignItem {

    public static void handleInsertOrUpdate(List<ADvendio__Campaign_Item__c> listCampaignItems, Map<Id, ADvendio__Campaign_Item__c> mapOldCampaignItems) {
        List<ADvendio__Campaign_Item__c> listRelevantCampaignItems = new List<ADvendio__Campaign_Item__c>();

        for (ADvendio__Campaign_Item__c campaignItem : listCampaignItems) {
            if (mapOldCampaignItems == null ||
                campaignItem.ADvendio__Sales_Price__c                != mapOldCampaignItems.get(campaignItem.Id).ADvendio__Sales_Price__c ||
                campaignItem.ADvendio__FC_Quantity__c                != mapOldCampaignItems.get(campaignItem.Id).ADvendio__FC_Quantity__c ||
                campaignItem.ADvendio__FC_Period__c                  != mapOldCampaignItems.get(campaignItem.Id).ADvendio__FC_Period__c ||
                campaignItem.ADvendio__FC_Ad_served_every__c         != mapOldCampaignItems.get(campaignItem.Id).ADvendio__FC_Ad_served_every__c ||
                campaignItem.SomDig_OtpAufschlag__c                  != mapOldCampaignItems.get(campaignItem.Id).SomDig_OtpAufschlag__c ||
                campaignItem.SomDig_Retargeting__c                   != mapOldCampaignItems.get(campaignItem.Id).SomDig_Retargeting__c ||
                campaignItem.ADvendio__SelectedCountryInformation__c != mapOldCampaignItems.get(campaignItem.Id).ADvendio__SelectedCountryInformation__c ||
                campaignItem.ADvendio__SelectedRegionInformation__c  != mapOldCampaignItems.get(campaignItem.Id).ADvendio__SelectedRegionInformation__c ||
                campaignItem.ADvendio__SelectedCityInformation__c    != mapOldCampaignItems.get(campaignItem.Id).ADvendio__SelectedCityInformation__c ||
                campaignItem.ADvendio__AdKeyValues__c                != mapOldCampaignItems.get(campaignItem.Id).ADvendio__AdKeyValues__c
            ) {
                Adv_CampaignItem_Helper helper = Adv_CampaignItem_Helper.lazyLoad(campaignItem, mapOldCampaignItems != null ? mapOldCampaignItems.get(campaignItem.Id) : null);
                helper.save();

                listRelevantCampaignItems.add(campaignItem);
            }
        }

        if (!listRelevantCampaignItems.isEmpty()) {
            insertOrUpdateProxies(listRelevantCampaignItems);
        }
    }


    public static void insertOrUpdateProxies(List<ADvendio__Campaign_Item__c> listCampaignItems) {
        List<SomDig_SalesPriceProxy__c> listProxies = new List<SomDig_SalesPriceProxy__c>();
        Map<Id, ADvendio__Ad_price__c> mapAdPrices = getAdPriceMap(listCampaignItems);

        for (ADvendio__Campaign_Item__c campaignItem : listCampaignItems) {
            ADvendio__Ad_price__c adPrice = mapAdPrices.get(campaignItem.ADvendio__Ad_Price__c);

            if (adPrice != null) {
                SomDig_SalesPriceProxy__c proxy = new SomDig_SalesPriceProxy__c(
                    SomDig_CampaignItem__c = campaignItem.Id,
                    SomDig_CampaignItemID__c = campaignItem.Id,
                    SomDig_ListPrice__c = campaignItem.ADvendio__List_Price__c,
                    SomDig_SalesPrice__c = campaignItem.ADvendio__Sales_Price__c
                );

                proxy.SomDig_FcSurcharge__c = considerFcSurcharge(campaignItem) ? adPrice.ADvendio__Ad_Spec__r.SomDig_FcAufschlag__c : null;
                proxy.SomDig_OtpSurcharge__c = campaignItem.SomDig_OtpAufschlag__c ? adPrice.ADvendio__Ad_Spec__r.SomDig_OtpAufschlag__c : null;
                proxy.SomDig_RetargetingSurcharge__c = campaignItem.SomDig_Retargeting__c ? adPrice.ADvendio__Ad_Spec__r.SomDig_RetargetingSurcharge__c : null;

                listProxies.add(proxy);
            }
        }

        if (!listProxies.isEmpty()) upsert listProxies SomDig_CampaignItemID__c;
    }


    /** Determine whether the FC surcharge should be added to the surcharge calculation (see KV 1990) */
    private static Boolean considerFcSurcharge(ADvendio__Campaign_Item__c campaignItem) {
        return (
            /** Condition 1: CampaignItem must NOT have OTP enabled */
            (!campaignItem.SomDig_OtpAufschlag__c) &&

            /** Condition 2: MediagattungsDifferenzierung must be 'InStream' */
            (campaignItem.SomDig_MediagattungsDifferenzierungName__c == 'InStream/Video') &&

            /** Condition 3: the 3 relevant FC fields must be filled */
            (campaignItem.ADvendio__FC_Ad_served_every__c != null &&
             campaignItem.ADvendio__FC_Period__c != null &&
             campaignItem.ADvendio__FC_Quantity__c != null) &&

            /** Condition 4: the FC period must be equal to or greater than 'week' */
            (campaignItem.ADvendio__FC_Period__c == 'week' ||
             campaignItem.ADvendio__FC_Period__c == 'month' ||
             campaignItem.ADvendio__FC_Period__c == 'campaign')
        );
    }


    /** Get a map of Ad Prices for a list of Campaign Items */
    private static Map<Id, ADvendio__Ad_price__c> getAdPriceMap(List<ADvendio__Campaign_Item__c> listCampaignItems) {
        Map<Id, ADvendio__Ad_price__c> mapAdPrices = new Map<Id, ADvendio__Ad_price__c>();
        Set<Id> setAdPriceIds = new Set<Id>();

        for (ADvendio__Campaign_Item__c campaignItem : listCampaignItems) {
            setAdPriceIds.add(campaignItem.ADvendio__Ad_Price__c);
        }

        if (!setAdPriceIds.isEmpty()) {
            mapAdPrices = new Map<Id, ADvendio__Ad_price__c>([
                SELECT ADvendio__Ad_Spec__r.SomDig_OtpAufschlag__c,
                       ADvendio__Ad_Spec__r.SomDig_FcAufschlag__c,
                       ADvendio__Ad_Spec__r.SomDig_Targetingaufschlag__c,
                       ADvendio__Ad_Spec__r.SomDig_RotationExclusionSurcharge__c,
                       ADvendio__Ad_Spec__r.SomDig_RetargetingSurcharge__c
                  FROM ADvendio__Ad_price__c
                 WHERE Id IN :setAdPriceIds
            ]);
        }

        return mapAdPrices;
    }

}