public with sharing class SomDig_SalesPriceProxy_Geo {

    public static void handleInsertOrUpdate(List<ADvendio__Selected_City__c> listSelectedCities) {
        Set<Id> setCampaignItemIds = new Set<Id>();
        for (ADvendio__Selected_City__c selectedCity : listSelectedCities) {
            setCampaignItemIds.add(selectedCity.ADvendio__Campaign_Item__c);
        }
        upsertProxies(setCampaignItemIds, 'cities');
    }


    public static void handleInsertOrUpdate(List<ADvendio__Selected_Country__c> listSelectedCountries) {
        Set<Id> setCampaignItemIds = new Set<Id>();
        for (ADvendio__Selected_Country__c selectedCountry : listSelectedCountries) {
            setCampaignItemIds.add(selectedCountry.ADvendio__Campaign_Item__c);
        }
        upsertProxies(setCampaignItemIds, 'countries');
    }


    public static void handleInsertOrUpdate(List<ADvendio__Selected_Region__c> listSelectedRegions) {
        Set<Id> setCampaignItemIds = new Set<Id>();
        for (ADvendio__Selected_Region__c selectedRegion : listSelectedRegions) {
            setCampaignItemIds.add(selectedRegion.ADvendio__Campaign_Item__c);
        }
        upsertProxies(setCampaignItemIds, 'regions');
    }


    private static void upsertProxies(Set<Id> setCampaignItemIds, String geoType) {
        List<ADvendio__Campaign_Item__c> listCampaignItems = [
            SELECT ADvendio__Sales_Price__c, ADvendio__List_price__c,
                   ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.SomDig_Targetingaufschlag__c,
                   ADvendio__SelectedCountryInformation__c, ADvendio__SelectedRegionInformation__c, ADvendio__SelectedCityInformation__c, ADvendio__AdKeyValues__c,
                   (SELECT ADvendio__Country__r.SomDig_Zuschlagspflichtig__c FROM ADvendio__Selected_Countries__r),
                   (SELECT ADvendio__Region__r.SomDig_Zuschlagspflichtig__c FROM ADvendio__Selected_Regions__r),
                   (SELECT ADvendio__City__r.SomDig_Zuschlagspflichtig__c FROM ADvendio__Selected_Cities__r)
              FROM ADvendio__Campaign_Item__c
             WHERE Id IN :setCampaignItemIds
        ];

        if (!listCampaignItems.isEmpty()) {
            List<SomDig_SalesPriceProxy__c> listProxies = new List<SomDig_SalesPriceProxy__c>();

            for (ADvendio__Campaign_Item__c campaignItem : listCampaignItems) {
                // Decimal oldSurcharge = campaignItem.SomDig_GeoTargetingSurcharge__c;
                Boolean considerTargetingSurcharge = false;

                /**
                 * For all lists in the data map campaignItemData:
                 *   - First, check if the Bool flag considerTargetingSurcharge = false
                 *   - If so, iterate the Campaign Item's Selected Objects
                 *   - Check if one of the Selected Objects has a connected Geo objects with the value of SomDig_Zuschlagspflichtig__c = true
                 *   - If yes, set the Bool flag considerTargetingSurcharge to true
                 */
                if (!considerTargetingSurcharge) {
                    for (ADvendio__Selected_Country__c selectedCountry : campaignItem.ADvendio__Selected_Countries__r) {
                        if (selectedCountry.ADvendio__Country__r.SomDig_Zuschlagspflichtig__c) {
                            considerTargetingSurcharge = true;
                            break;
                        }
                    }
                }

                if (!considerTargetingSurcharge) {
                    for (ADvendio__Selected_Region__c selectedRegion : campaignItem.ADvendio__Selected_Regions__r) {
                        if (selectedRegion.ADvendio__Region__r.SomDig_Zuschlagspflichtig__c) {
                            considerTargetingSurcharge = true;
                            break;
                        }
                    }
                }

                if (!considerTargetingSurcharge) {
                    for (ADvendio__Selected_City__c selectedCity : campaignItem.ADvendio__Selected_Cities__r) {
                        if (selectedCity.ADvendio__City__r.SomDig_Zuschlagspflichtig__c) {
                            considerTargetingSurcharge = true;
                            break;
                        }
                    }
                }

                Adv_CampaignItem_Helper helper = Adv_CampaignItem_Helper.lazyLoad(campaignItem);
                if (geoType == 'countries') helper.isWaitingForCountries = false;
                if (geoType == 'regions') helper.isWaitingForRegions = false;
                if (geoType == 'cities') helper.isWaitingForCities = false;
                helper.save();

                SomDig_SalesPriceProxy__c proxy = new SomDig_SalesPriceProxy__c(
                    SomDig_CampaignItem__c = campaignItem.Id,
                    SomDig_CampaignItemID__c = campaignItem.Id,
                    SomDig_ListPrice__c = campaignItem.ADvendio__List_Price__c,
                    SomDig_SalesPrice__c = campaignItem.ADvendio__Sales_Price__c
                );

                proxy.SomDig_GeoTargetingSurcharge__c = considerTargetingSurcharge ? campaignItem.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.SomDig_Targetingaufschlag__c : null;

                listProxies.add(proxy);
            }

            if (!listProxies.isEmpty()) upsert listProxies SomDig_CampaignItemID__c;
        }
    }

}