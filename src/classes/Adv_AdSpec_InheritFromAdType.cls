public with sharing class Adv_AdSpec_InheritFromAdType {

    public static void runFromAdSpecTrigger(List<ADvendio__Ad_Specs__c> adSpecsList) {
        Set<Id> adTypeIdsSet = new Set<Id>();
        for (ADvendio__Ad_Specs__c adSpec : adSpecsList) {
            adTypeIdsSet.add(adSpec.ADvendio__Ad_Type__c);
        }

        Map<Id, ADvendio__Ad_Type__c> adTypesMap = new Map<Id, ADvendio__Ad_Type__c>([
            SELECT Id, SomDig_FcMenge__c, SomDig_FcPeriode__c
              FROM ADvendio__Ad_Type__c
             WHERE Id IN :adTypeIdsSet
        ]);

        for (ADvendio__Ad_Specs__c adSpec : adSpecsList) {
            ADvendio__Ad_Type__c adType = adTypesMap.get(adSpec.ADvendio__Ad_Type__c);

            if (adType != null) {
                adSpec.ADvendio__FC_Quantity__c = adType.SomDig_FcMenge__c;
                adSpec.ADvendio__FC_Period__c = translatePicklistValueForFcPeriod(adType.SomDig_FcPeriode__c);
            }
        }
    }

    public static void runFromAdTypeTrigger(Map<Id, ADvendio__Ad_Type__c> newAdTypesMap, Map<Id, ADvendio__Ad_Type__c> oldAdTypesMap){
        List<ADvendio__Ad_Specs__c> adSpecsList = [
            SELECT Id, ADvendio__Ad_Type__c, ADvendio__FC_Quantity__c, ADvendio__FC_Period__c
              FROM ADvendio__Ad_Specs__c
             WHERE ADvendio__Ad_Type__c IN :newAdTypesMap.keySet()
        ];
        Set<ADvendio__Ad_Specs__c> adSpecsSet = new Set<ADvendio__Ad_Specs__c>();

        for (ADvendio__Ad_Specs__c adSpec : adSpecsList) {
            ADvendio__Ad_Type__c newAdType = newAdTypesMap.get(adSpec.ADvendio__Ad_Type__c);
            ADvendio__Ad_Type__c oldAdType = oldAdTypesMap.get(adSpec.ADvendio__Ad_Type__c);
            Boolean changed = false;

            // FC Menge: ADvendio__Ad_Type__c.SomDig_FcMenge__c, ADvendio__Ad_Specs__c.ADvendio__FC_Quantity__c
            if (newAdType.SomDig_FcMenge__c != oldAdType.SomDig_FcMenge__c &&
                newAdType.SomDig_FcMenge__c != adSpec.ADvendio__FC_Quantity__c
            ) {
                adSpec.ADvendio__FC_Quantity__c = newAdType.SomDig_FcMenge__c;
                changed = true;
            }

            // FC Periode: ADvendio__Ad_Type__c.SomDig_FcPeriode__c, ADvendio__Ad_Specs__c.ADvendio__FC_Period__c
            if (translatePicklistValueForFcPeriod(newAdType.SomDig_FcPeriode__c) != translatePicklistValueForFcPeriod(oldAdType.SomDig_FcPeriode__c) &&
                translatePicklistValueForFcPeriod(newAdType.SomDig_FcPeriode__c) != adSpec.ADvendio__FC_Period__c
            ) {
                adSpec.ADvendio__FC_Period__c = translatePicklistValueForFcPeriod(newAdType.SomDig_FcPeriode__c);
                changed = true;
            }

            if (changed) adSpecsSet.add(adSpec);
        }

        if (!adSpecsSet.isEmpty()) {
            update new List<ADvendio__Ad_Specs__c>(adSpecsSet);
        }
    }

    /**
     * Translate a picklist value from the ADvendio__Ad_Type__c.SomDig_FcPeriode__c field into
     * the corresponding translation from the ADvendio__Ad_Specs__c.ADvendio__FC_Period__c field
     * or return the original value if no translation was found
     */
    public static String translatePicklistValueForFcPeriod(String fcPeriod) {
        Map<String, String> translationsMap = new Map<String, String>{
          'Minute'	 => 'minute',
          'Stunde'	 => 'hour',
          'Tag'		 => 'day',
          'Woche'	 => 'week',
          'Monat'	 => 'month',
          'Jahr'	 => 'year',
          'Kampagne' => 'campaign',
          'Session'	 => 'session'
        };
        String translatedFcPeriod = translationsMap.get(fcPeriod);
        if (translatedFcPeriod == null) {
            translatedFcPeriod = fcPeriod;
        }
        return translatedFcPeriod;
    }
}