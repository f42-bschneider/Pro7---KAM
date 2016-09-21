public with sharing class SomDig_SalesPriceProxy_KeyValue {

    // TODO: die Konstanten in ein CustomSetting auslagern bzw. anderweitig konfigurierbar machen (auch in Adv_AdPrice_AssignKeys)
    @testVisible static final String ROTATIONSAUSSCHLUSS = 'Rotationsausschluss';
    @testVisible static final String TARGETING_PROVIDER = 'Targeting Provider';
    @testVisible static final String FUTURETV = 'FutureTV';
    @testVisible static final String VIDEOVALIS = 'Videovalis';

    public static void handleInsertOrUpdate(List<ADvendio__KeyLine__c> keyLinesList) {
        Set<Id> campaignItemIdsSet = new Set<Id>();
        for (ADvendio__KeyLine__c keyLine : keyLinesList) {
            if (keyLine.ADvendio__CampaignItem__c != null) {
                campaignItemIdsSet.add(keyLine.ADvendio__CampaignItem__c);
            }
        }
        upsertProxies(campaignItemIdsSet);
    }

    public static void handleInsertOrUpdate(List<ADvendio__KeyValue__c> keyValuesList) {
        Set<Id> campaignItemIdsSet = new Set<Id>();
        for (ADvendio__KeyValue__c keyValue : keyValuesList) {
            if (keyValue.SomDig_Campaign_Item__c != null && keyValue.ADvendio__Key__c != null) {
                campaignItemIdsSet.add(keyValue.SomDig_Campaign_Item__c);
            }
        }
        upsertProxies(campaignItemIdsSet);
    }


    private static void upsertProxies(Set<Id> campaignItemIdsSet) {
        Map<Id, ADvendio__Campaign_Item__c> campaignItemsMap = new Map<Id, ADvendio__Campaign_Item__c>();

        if (!campaignItemIdsSet.isEmpty()) {
            campaignItemsMap = new Map<Id, ADvendio__Campaign_Item__c>([
                SELECT ADvendio__Sales_Price__c, ADvendio__List_price__c,
                       ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.SomDig_Targetingaufschlag__c,
                       ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.SomDig_RotationExclusionSurcharge__c,
                       ADvendio__SelectedCountryInformation__c, ADvendio__SelectedRegionInformation__c, ADvendio__SelectedCityInformation__c, ADvendio__AdKeyValues__c
                FROM ADvendio__Campaign_Item__c
                WHERE Id IN :campaignItemIdsSet
            ]);
        }

        if (!campaignItemsMap.isEmpty()) {
            List<SomDig_SalesPriceProxy__c> listProxies = new List<SomDig_SalesPriceProxy__c>();
            Map<Id, Map<String, List<ADvendio__KeyValue__c>>> campaignItemIdKeyValuesListMap = new Map<Id, Map<String, List<ADvendio__KeyValue__c>>>();

            for (ADvendio__KeyValue__c keyValue : [
                SELECT SomDig_Campaign_Item__c, ADvendio__Values__c, ADvendio__Key__r.SomDig_TargetingProvider__c
                  FROM ADvendio__KeyValue__c
                 WHERE SomDig_Campaign_Item__c IN :campaignItemsMap.keySet()
                   AND ADvendio__Key__r.SomDig_TargetingProvider__c <> null
            ]) {
                if (campaignItemIdKeyValuesListMap.get(keyValue.SomDig_Campaign_Item__c) == null) {
                    campaignItemIdKeyValuesListMap.put(keyValue.SomDig_Campaign_Item__c, new Map<String, List<ADvendio__KeyValue__c>>());
                    campaignItemIdKeyValuesListMap.get(keyValue.SomDig_Campaign_Item__c).put(ROTATIONSAUSSCHLUSS, new List<ADvendio__KeyValue__c>());
                    campaignItemIdKeyValuesListMap.get(keyValue.SomDig_Campaign_Item__c).put(TARGETING_PROVIDER, new List<ADvendio__KeyValue__c>());
                }

                if (keyValue.ADvendio__Key__r.SomDig_TargetingProvider__c == ROTATIONSAUSSCHLUSS) {
                    campaignItemIdKeyValuesListMap.get(keyValue.SomDig_Campaign_Item__c).get(ROTATIONSAUSSCHLUSS).add(keyValue);
                } else {
                    campaignItemIdKeyValuesListMap.get(keyValue.SomDig_Campaign_Item__c).get(TARGETING_PROVIDER).add(keyValue);
                }
            }

            for (ADvendio__Campaign_Item__c campaignItem : campaignItemsMap.values()) {
                Boolean includeTargeting = false;
                Boolean excludeFutureTv = false;
                Boolean excludeVideovalis = false;
                Integer exclusionCount = 0;

                Map<String, List<ADvendio__KeyValue__c>> campaignItemKeyValuesDataMap = campaignItemIdKeyValuesListMap.get(campaignItem.Id);

                if (campaignItemKeyValuesDataMap != null) {
                    List<ADvendio__KeyValue__c> rotationExclusionKeyValuesList = campaignItemKeyValuesDataMap.get(ROTATIONSAUSSCHLUSS);

                    if (!campaignItemKeyValuesDataMap.get(TARGETING_PROVIDER).isEmpty()) {
                        includeTargeting = true;
                    }
                    if (!rotationExclusionKeyValuesList.isEmpty()) {
                        for (ADvendio__KeyValue__c keyValue : rotationExclusionKeyValuesList) {
                            if (keyValue.ADvendio__Values__c == null) continue;

                            for (String value : keyValue.ADvendio__Values__c.split(',')) {
                                if (value.trim().equalsIgnoreCase(FUTURETV)) {
                                    excludeFutureTv = true;
                                } else if (value.trim().equalsIgnoreCase(VIDEOVALIS)) {
                                    excludeVideovalis = true;
                                }

                                exclusionCount += 1;
                            }
                        }
                    }
                }

                Adv_CampaignItem_Helper helper = Adv_CampaignItem_Helper.lazyLoad(campaignItem);
                helper.isWaitingForKeyValues = false;
                helper.save();

                SomDig_SalesPriceProxy__c proxy = new SomDig_SalesPriceProxy__c(
                    SomDig_CampaignItem__c = campaignItem.Id,
                    SomDig_CampaignItemID__c = campaignItem.Id,
                    SomDig_ListPrice__c = campaignItem.ADvendio__List_Price__c,
                    SomDig_SalesPrice__c = campaignItem.ADvendio__Sales_Price__c
                );

                if (includeTargeting) {
                    proxy.SomDig_KeyValueTargetingSurcharge__c = campaignItem.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.SomDig_Targetingaufschlag__c;
                } else {
                    proxy.SomDig_KeyValueTargetingSurcharge__c = null;
                }

                if (exclusionCount > 3 || (excludeFutureTv && excludeVideovalis)) {
                    proxy.SomDig_RotationExclusionSurcharge__c = campaignItem.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.SomDig_RotationExclusionSurcharge__c;
                } else {
                    proxy.SomDig_RotationExclusionSurcharge__c = null;
                }

                listProxies.add(proxy);
            }

            if (!listProxies.isEmpty()) upsert listProxies SomDig_CampaignItemID__c;
        }
    }

}