global with sharing class Adv_AdPrice_AssignKeys implements Database.Batchable<sObject> {

    static final Set<String> FESTPLATZIERUNGEN = new Set<String>{'CPD', 'CPW', 'Fixed Price'};
    static final String ROTATIONSAUSSCHLUSS = 'Rotationsausschluss';

    private Map<Id, ADvendio__Placement__c> i_placementsMap;

    public Adv_AdPrice_AssignKeys(List<ADvendio__Placement__c> placementsList) {
        this.i_placementsMap = new Map<Id, ADvendio__Placement__c>(placementsList);
    }

    global Iterable<sObject> start(Database.BatchableContext BC) {
        return [
                SELECT ADvendio__Billing_Category__c, SomDig_Placement__c
                  FROM ADvendio__Ad_price__c
                 WHERE SomDig_Placement__c IN :this.i_placementsMap.keySet()
                   AND ADvendio__Active__c = true
        ];
    }

    global void execute(Database.BatchableContext BC, List<ADvendio__Ad_price__c> adPricesList) {
        System.debug('### this.i_placementsMap: ' + this.i_placementsMap);
        System.debug('### adPricesList: ' + adPricesList);

        assignKeysToAdPrices(this.i_placementsMap, new Map<Id, ADvendio__Ad_price__c>(adPricesList));
    }

    global void finish(Database.BatchableContext BC) {
    }


    public static void runFromAdPriceTrigger(Map<Id, ADvendio__Ad_price__c> newAdPricesMap, Map<Id, ADvendio__Ad_price__c> oldAdPricesMap) {
        Map<Id, ADvendio__Placement__c> relevantPlacementsMap = new Map<Id, ADvendio__Placement__c>();
        Map<Id, ADvendio__Ad_price__c> relevantAdPricesMap = new Map<Id, ADvendio__Ad_price__c>();

        Set<Id> placementIdsSet = new Set<Id>();

        for (ADvendio__Ad_price__c adPrice : newAdPricesMap.values()) {
            if (oldAdPricesMap == null || adPrice.ADvendio__Billing_Category__c != oldAdPricesMap.get(adPrice.Id).ADvendio__Billing_Category__c) {
                relevantAdPricesMap.put(adPrice.Id, adPrice);
                placementIdsSet.add(adPrice.SomDig_Placement__c);
            }
        }

        if (!relevantAdPricesMap.isEmpty()) {
            relevantPlacementsMap = new Map<Id, ADvendio__Placement__c>([
                SELECT Targeting_Provider__c
                  FROM ADvendio__Placement__c
                 WHERE Id IN :placementIdsSet
            ]);
        }

        assignKeysToAdPrices(relevantPlacementsMap, relevantAdPricesMap);
    }

    public static void runFromPlacementTrigger(Map<Id, ADvendio__Placement__c> newPlacementsMap, Map<Id, ADvendio__Placement__c> oldPlacementsMap) {
        List<ADvendio__Placement__c> relevantPlacementsList = new List<ADvendio__Placement__c>();

        for (ADvendio__Placement__c placement : newPlacementsMap.values()) {
            if (placement.Targeting_Provider__c != oldPlacementsMap.get(placement.Id).Targeting_Provider__c) {
                relevantPlacementsList.add(placement);
            }
        }

        if (!relevantPlacementsList.isEmpty()) {
            Database.executeBatch(new Adv_AdPrice_AssignKeys(relevantPlacementsList), 50);
        }
    }

    private static void assignKeysToAdPrices(Map<Id, ADvendio__Placement__c> placementsMap, Map<Id, ADvendio__Ad_price__c> adPricesMap) {
        if (!placementsMap.isEmpty() && !adPricesMap.isEmpty()) {
            List<ADvendio__KeyAdPriceAssignment__c> deleteableAssignmentsList = new List<ADvendio__KeyAdPriceAssignment__c>();
            List<ADvendio__KeyAdPriceAssignment__c> insertableAssignmentsList = new List<ADvendio__KeyAdPriceAssignment__c>();

            Map<Id, Set<String>> placementIdTargetingProvidersMap = getPlacementIdTargetingProvidersMap(placementsMap);
            Map<String, List<ADvendio__Key__c>> targetingProviderKeysMap = getTargetingProviderKeysMap(placementsMap);

            Map<Id, List<ADvendio__Ad_price__c>> placementIdAdPricesMap = new Map<Id, List<ADvendio__Ad_price__c>>();
            Map<Id, List<ADvendio__KeyAdPriceAssignment__c>> adPriceIdAssignmentsMap = new Map<Id, List<ADvendio__KeyAdPriceAssignment__c>>();

            for (ADvendio__Ad_price__c adPrice : adPricesMap.values()) {
                if (!placementIdAdPricesMap.containsKey(adPrice.SomDig_Placement__c)) {
                    placementIdAdPricesMap.put(adPrice.SomDig_Placement__c, new List<ADvendio__Ad_price__c>());
                }
                placementIdAdPricesMap.get(adPrice.SomDig_Placement__c).add(adPrice);
            }

            for (ADvendio__KeyAdPriceAssignment__c assignment : [
                SELECT ADvendio__AdPrice__c, ADvendio__Key__c, ADvendio__Key__r.SomDig_TargetingProvider__c
                  FROM ADvendio__KeyAdPriceAssignment__c
                 WHERE ADvendio__AdPrice__c IN :adPricesMap.keySet()
            ]) {
                if (!adPriceIdAssignmentsMap.containsKey(assignment.ADvendio__AdPrice__c)) {
                    adPriceIdAssignmentsMap.put(assignment.ADvendio__AdPrice__c, new List<ADvendio__KeyAdPriceAssignment__c>());
                }
                adPriceIdAssignmentsMap.get(assignment.ADvendio__AdPrice__c).add(assignment);
            }

            for (Id placementId : placementsMap.keySet()) {
                if (placementIdAdPricesMap.get(placementId) == null || placementIdAdPricesMap.get(placementId).isEmpty()) continue;

                Set<String> targetingProvidersSet = placementIdTargetingProvidersMap.get(placementId);

                for (ADvendio__Ad_price__c adPrice : placementIdAdPricesMap.get(placementId)) {
                    Boolean isFestplatzierung = FESTPLATZIERUNGEN.contains(adPrice.ADvendio__Billing_Category__c);

                    Map<Id, ADvendio__KeyAdPriceAssignment__c> existingAssignmentsMatrix = new Map<Id, ADvendio__KeyAdPriceAssignment__c>();

                    if (adPriceIdAssignmentsMap.get(adPrice.Id) != null) {
                        for (ADvendio__KeyAdPriceAssignment__c assignment : adPriceIdAssignmentsMap.get(adPrice.Id)) {
                            existingAssignmentsMatrix.put(assignment.ADvendio__Key__c, assignment);
                        }
                    }

                    for (String targetingProvider : targetingProvidersSet) {
                        if (targetingProviderKeysMap.get(targetingProvider) == null) continue;

                        if (!isFestplatzierung || targetingProvider == ROTATIONSAUSSCHLUSS) {
                            for (ADvendio__Key__c key : targetingProviderKeysMap.get(targetingProvider)) {
                                if (existingAssignmentsMatrix.containsKey(key.Id)) {
                                    existingAssignmentsMatrix.remove(key.Id);
                                } else {
                                    insertableAssignmentsList.add(new ADvendio__KeyAdPriceAssignment__c(
                                        ADvendio__AdPrice__c = adPrice.Id,
                                        ADvendio__Key__c = key.Id
                                    ));
                                }
                            }
                        }
                    }

                    deleteableAssignmentsList.addAll(existingAssignmentsMatrix.values());
                }
            }

            if (!insertableAssignmentsList.isEmpty()) insert insertableAssignmentsList;
            if (!deleteableAssignmentsList.isEmpty()) delete deleteableAssignmentsList;
        }
    }



    private static Map<Id, Set<String>> getPlacementIdTargetingProvidersMap(Map<Id, ADvendio__Placement__c> placementsMap) {
        Map<Id, Set<String>> placementIdTargetingProvidersMap = new Map<Id, Set<String>>();

        for (ADvendio__Placement__c placement : placementsMap.values()) {
                placementIdTargetingProvidersMap.put(placement.Id, new Set<String>());

                if (placement.Targeting_Provider__c != null) {
                    for (String targetingProvider : placement.Targeting_Provider__c.split(';')) {
                        placementIdTargetingProvidersMap.get(placement.Id).add(targetingProvider);
                    }
                }
        }

        return placementIdTargetingProvidersMap;
    }

    private static Map<String, List<ADvendio__Key__c>> getTargetingProviderKeysMap(Map<Id, ADvendio__Placement__c> placementsMap) {
        Map<String, List<ADvendio__Key__c>> targetingProviderKeysMap = new Map<String, List<ADvendio__Key__c>>();
        Set<String> targetingProvidersSet = new Set<String>();

        for (ADvendio__Placement__c placement : placementsMap.values()) {
            if (placement.Targeting_Provider__c != null) {
                for (String targetingProvider : placement.Targeting_Provider__c.split(';')) {
                    targetingProvidersSet.add(targetingProvider);
                }
            }
        }

        for (ADvendio__Key__c key : [
            SELECT SomDig_TargetingProvider__c
              FROM ADvendio__Key__c
             WHERE SomDig_TargetingProvider__c IN :targetingProvidersSet
        ]) {
            if (!targetingProviderKeysMap.containsKey(key.SomDig_TargetingProvider__c)) {
                targetingProviderKeysMap.put(key.SomDig_TargetingProvider__c, new List<ADvendio__Key__c>());
            }
            targetingProviderKeysMap.get(key.SomDig_TargetingProvider__c).add(key);
        }

        return targetingProviderKeysMap;
    }

}