public with sharing class Adv_CampaignItem_Inventarklasse {

    public static void setInventarklassen(List<ADvendio__Campaign_Item__c> campaignItemsList) {
        List<SomDig_Inventarklasse__c> inventarklassenList = [
            SELECT SomDig_Auftragstyp__c, SomDig_WerbeformDatensatztyp__c, SomDig_Rotationstyp__c,
                   SomDig_MediagattungsDifferenzierung__c, SomDig_Preismerkmal__c
              FROM SomDig_Inventarklasse__c
        ];
        Set<Id> adPriceIdsSet = new Set<Id>();

        for (ADvendio__Campaign_Item__c ci : campaignItemsList) {
            adPriceIdsSet.add(ci.ADvendio__Ad_Price__c);
        }

        Map<Id, ADvendio__Ad_price__c> adPricesMap = new Map<Id, ADvendio__Ad_price__c>([
                SELECT ADvendio__Pricelist__r.SomDig_AuftragstypId__r.Name, ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.RecordType.Name,
                       ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Rotationstyp__c,
                       ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.SomDig_MediagattungsDifferenzierung__c,
                       ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__RateCategory__c
                  FROM ADvendio__Ad_price__c
                 WHERE Id IN :adPriceIdsSet
        ]);

        for (ADvendio__Campaign_Item__c ci : campaignItemsList) {
            SomDig_Inventarklasse__c bestMatching = null;

            for (SomDig_Inventarklasse__c inventarklasse : inventarklassenList) {

                // Testen ob die Inventarklasse passt
                if ((inventarklasse.SomDig_Auftragstyp__c == null
                            || inventarklasse.SomDig_Auftragstyp__c == adPricesMap.get(ci.ADvendio__Ad_Price__c).ADvendio__Pricelist__r.SomDig_AuftragstypId__r.Name)
                        && (inventarklasse.SomDig_WerbeformDatensatztyp__c == null
                            || inventarklasse.SomDig_WerbeformDatensatztyp__c == adPricesMap.get(ci.ADvendio__Ad_Price__c).ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.RecordType.Name)
                        && (inventarklasse.SomDig_Rotationstyp__c == null
                            || inventarklasse.SomDig_Rotationstyp__c == adPricesMap.get(ci.ADvendio__Ad_Price__c).ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Rotationstyp__c)
                        && (inventarklasse.SomDig_MediagattungsDifferenzierung__c == null
                            || inventarklasse.SomDig_MediagattungsDifferenzierung__c == adPricesMap.get(ci.ADvendio__Ad_Price__c).ADvendio__Ad_Spec__r.ADvendio__Ad_Type__r.SomDig_MediagattungsDifferenzierung__c)
                        && (inventarklasse.SomDig_Preismerkmal__c == null
                            || inventarklasse.SomDig_Preismerkmal__c == adPricesMap.get(ci.ADvendio__Ad_Price__c).ADvendio__Ad_Spec__r.ADvendio__Placement__r.ADvendio__RateCategory__c)) {

                    // Testen ob die Inventarklasse besser passt, als die bisher am besten passende.
                    if (bestMatching == null
                            || (inventarklasse.SomDig_Preismerkmal__c != null && bestMatching.SomDig_Preismerkmal__c == null)
                            || (inventarklasse.SomDig_MediagattungsDifferenzierung__c != null && bestMatching.SomDig_MediagattungsDifferenzierung__c == null)
                            || (inventarklasse.SomDig_Rotationstyp__c != null && bestMatching.SomDig_Rotationstyp__c == null)
                            || (inventarklasse.SomDig_WerbeformDatensatztyp__c != null && bestMatching.SomDig_WerbeformDatensatztyp__c == null)
                            || (inventarklasse.SomDig_Auftragstyp__c != null && bestMatching.SomDig_Auftragstyp__c == null)
                    ) {
                        bestMatching = inventarklasse;
                    }
                }
            }

            if (bestMatching != null) {
                ci.SomDig_Inventarklasse__c = bestMatching.Id;
            }
        }
    }

}