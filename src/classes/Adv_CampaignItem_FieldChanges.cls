public with sharing class Adv_CampaignItem_FieldChanges {

    public static void setLineDescription(List<ADvendio__Campaign_Item__c> newCampaignItemsList, Map<Id, ADvendio__Campaign_Item__c> oldCampaignItemsMap) {
        for (ADvendio__Campaign_Item__c ci : newCampaignItemsList) {
            if (oldCampaignItemsMap == null ||
                ci.SomDig_Freitextnotiz__c != oldCampaignItemsMap.get(ci.Id).SomDig_Freitextnotiz__c ||
                ci.ADvendio__Rate_Discount_4_Name__c != oldCampaignItemsMap.get(ci.Id).ADvendio__Rate_Discount_4_Name__c ||
                ci.SomDig_OtpAufschlag__c != oldCampaignItemsMap.get(ci.Id).SomDig_OtpAufschlag__c ||
                ci.SomDig_Preiskriterium__c != oldCampaignItemsMap.get(ci.Id).SomDig_Preiskriterium__c ||
                ci.SomDig_Retargeting__c != oldCampaignItemsMap.get(ci.Id).SomDig_Retargeting__c
            ) {
                List<String> descriptionParts = new List<String>();

                if (ci.SomDig_Freitextnotiz__c != null && ci.SomDig_Freitextnotiz__c != '') {
                    descriptionParts.add('-' + ci.SomDig_Freitextnotiz__c);
                }

                if (ci.ADvendio__Rate_Discount_4_Name__c == 'Positionsrabatt Natural') {
                    descriptionParts.add('-NR');
                } else if (ci.ADvendio__Rate_Discount_4_Name__c == 'Nachlieferung') {
                    descriptionParts.add('-Nachlieferung');
                } else if (stornoMitOderOhneLeistungsfluss(ci)) {
                    descriptionParts.add('-Storno');
                }

                if (ci.SomDig_OtpAufschlag__c) {
                    descriptionParts.add('-OTP');
                }

                if (ci.SomDig_Retargeting__c) {
                    descriptionParts.add('-Re-Targeting-Aufschlag');
                }

                if (ci.SomDig_Preiskriterium__c != null && ci.SomDig_Preiskriterium__c != '') {
                    descriptionParts.add('-Videolänge: ' + ci.SomDig_Preiskriterium__c);
                }

                ci.ADvendio__Line_Description__c = String.join(descriptionParts, '\n');
            }
        }
    }

    public static void setAdServerStatus(List<ADvendio__Campaign_Item__c> newCampaignItemsList, Map<Id, ADvendio__Campaign_Item__c> oldCampaignItemsMap) {
        for (ADvendio__Campaign_Item__c ci : newCampaignItemsList) {
            if (oldCampaignItemsMap == null ||
                ci.ADvendio__Rate_Discount_4_Name__c != oldCampaignItemsMap.get(ci.Id).ADvendio__Rate_Discount_4_Name__c
            ) {
                if (stornoMitOderOhneLeistungsfluss(ci)) {
                    ci.ADvendio__AdserverStatus__c = 'Released';
                } else {
                    ci.ADvendio__AdserverStatus__c = 'Active';
                }
            }
        }
    }

    private static Boolean stornoMitOderOhneLeistungsfluss(ADvendio__Campaign_Item__c ci) {
        return (
            ci.ADvendio__Rate_Discount_4_Name__c == 'Storno mit Leistungsfluss' ||
            ci.ADvendio__Rate_Discount_4_Name__c == 'Storno ohne Leistungsfluss'
        );
    }

}