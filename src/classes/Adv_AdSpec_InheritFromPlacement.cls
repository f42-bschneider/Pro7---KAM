public with sharing class Adv_AdSpec_InheritFromPlacement {

    public static void runFromAdSpecTrigger(List<ADvendio__Ad_Specs__c> adSpecsList) {
        Set<Id> placementIdsSet = new Set<Id>();
        for (ADvendio__Ad_Specs__c adSpec : adSpecsList) {
            placementIdsSet.add(adSpec.ADvendio__Placement__c);
        }

        Map<Id, ADvendio__Placement__c> placementsMap = new Map<Id, ADvendio__Placement__c>([
            SELECT SomDig_Auftragstypen__c, SomDig_BT__c, SomDig_FC__c, SomDig_GtFaehig__c, SomDig_iAdFaehig__c, Targeting_Provider__c
              FROM ADvendio__Placement__c
             WHERE Id IN :placementIdsSet
        ]);

        for (ADvendio__Ad_Specs__c adSpec : adSpecsList) {
            ADvendio__Placement__c placement = placementsMap.get(adSpec.ADvendio__Placement__c);

            if (placement != null) {
                adSpec.SomDig_Auftragstypen__c = placement.SomDig_Auftragstypen__c;
                adSpec.SomDig_BT__c = placement.SomDig_BT__c;
                adSpec.SomDig_FC__c = placement.SomDig_FC__c;
                adSpec.SomDig_GtFaehig__c = placement.SomDig_GtFaehig__c;
                adSpec.SomDig_iAdFaehig__c = placement.SomDig_iAdFaehig__c;
                adSpec.SomDig_Targeting_Provider__c = placement.Targeting_Provider__c;
            }
        }
    }

    public static void runFromAdSpecTrigger(Map<Id, ADvendio__Ad_Specs__c> adSpecsMap) {
        Set<Id> placementIdsSet = new Set<Id>();
        for (ADvendio__Ad_Specs__c adSpec : adSpecsMap.values()) {
            placementIdsSet.add(adSpec.ADvendio__Placement__c);
        }

        Map<Id, ADvendio__Placement__c> placementsMap = new Map<Id, ADvendio__Placement__c>([
            SELECT SomDig_AdServerID__c
              FROM ADvendio__Placement__c
             WHERE Id IN :placementIdsSet
        ]);

        updateAdServerIdAdSpecAssignments(placementsMap, adSpecsMap);
    }

    public static void runFromPlacementTrigger(Map<Id, ADvendio__Placement__c> newPlacementsMap, Map<Id, ADvendio__Placement__c> oldPlacementsMap) {
        Map<Id, ADvendio__Placement__c> changedPlacementsMap = new Map<Id, ADvendio__Placement__c>();
        Map<Id, ADvendio__Placement__c> changedAdServerIdPlacementsMap = new Map<Id, ADvendio__Placement__c>();
        Set<Id> placementIdsSet = new Set<Id>();

        for (ADvendio__Placement__c newPlacement : newPlacementsMap.values()) {
            if (newPlacement.SomDig_Auftragstypen__c != oldPlacementsMap.get(newPlacement.Id).SomDig_Auftragstypen__c ||
                newPlacement.SomDig_BT__c != oldPlacementsMap.get(newPlacement.Id).SomDig_BT__c ||
                newPlacement.SomDig_FC__c != oldPlacementsMap.get(newPlacement.Id).SomDig_FC__c ||
                newPlacement.SomDig_GtFaehig__c != oldPlacementsMap.get(newPlacement.Id).SomDig_GtFaehig__c ||
                newPlacement.SomDig_iAdFaehig__c != oldPlacementsMap.get(newPlacement.Id).SomDig_iAdFaehig__c ||
                newPlacement.Targeting_Provider__c != oldPlacementsMap.get(newPlacement.Id).Targeting_Provider__c
            ) {
                changedPlacementsMap.put(newPlacement.Id, newPlacement);
                placementIdsSet.add(newPlacement.Id);
            }

            if (newPlacement.SomDig_AdServerID__c != oldPlacementsMap.get(newPlacement.Id).SomDig_AdServerID__c) {
                changedAdServerIdPlacementsMap.put(newPlacement.Id, newPlacement);
                placementIdsSet.add(newPlacement.Id);
            }
        }

        if (!placementIdsSet.isEmpty()) {
            List<ADvendio__Ad_Specs__c> adSpecsList = new List<ADvendio__Ad_Specs__c>();
            Map<Id, ADvendio__Ad_Specs__c> adSpecsMap = new Map<Id, ADvendio__Ad_Specs__c>();

            for (ADvendio__Ad_Specs__c adSpec : [
                SELECT ADvendio__Placement__c, SomDig_Auftragstypen__c, SomDig_BT__c, SomDig_FC__c,
                       SomDig_GtFaehig__c, SomDig_iAdFaehig__c, SomDig_Targeting_Provider__c
                  FROM ADvendio__Ad_Specs__c
                 WHERE ADvendio__Placement__c IN :placementIdsSet
            ]) {
                if (changedPlacementsMap.containsKey(adSpec.ADvendio__Placement__c)) {
                    adSpecsList.add(adSpec);
                }

                if (changedAdServerIdPlacementsMap.containsKey(adSpec.ADvendio__Placement__c)) {
                    adSpecsMap.put(adSpec.Id, adSpec);
                }
            }

            if (!adSpecsList.isEmpty()) {
                updateAdSpecs(changedPlacementsMap, oldPlacementsMap, adSpecsList);
            }

            if (!adSpecsMap.isEmpty()) {
                updateAdServerIdAdSpecAssignments(changedAdServerIdPlacementsMap, adSpecsMap);
            }
        }
    }

    private static void updateAdSpecs(Map<Id, ADvendio__Placement__c> newPlacementsMap, Map<Id, ADvendio__Placement__c> oldPlacementsMap, List<ADvendio__Ad_Specs__c> adSpecsList) {
        Set<ADvendio__Ad_Specs__c> adSpecsSet = new Set<ADvendio__Ad_Specs__c>();

        for (ADvendio__Ad_Specs__c adSpec : adSpecsList) {
            ADvendio__Placement__c newPlacement = newPlacementsMap.get(adSpec.ADvendio__Placement__c);
            ADvendio__Placement__c oldPlacement = oldPlacementsMap.get(adSpec.ADvendio__Placement__c);
            Boolean changed = false;

            // Auftragstypen: ADvendio__Placement__c.SomDig_Auftragstypen__c, ADvendio__Ad_Specs__c.SomDig_Auftragstypen__c
            if (newPlacement.SomDig_Auftragstypen__c != oldPlacement.SomDig_Auftragstypen__c &&
                newPlacement.SomDig_Auftragstypen__c != adSpec.SomDig_Auftragstypen__c
            ) {
                adSpec.SomDig_Auftragstypen__c = newPlacement.SomDig_Auftragstypen__c;
                changed = true;
            }

            // BT Fähigkeit: ADvendio__Placement__c.SomDig_BT__c, ADvendio__Ad_Specs__c.SomDig_BT__c
            if (newPlacement.SomDig_BT__c != oldPlacement.SomDig_BT__c &&
                newPlacement.SomDig_BT__c != adSpec.SomDig_BT__c
            ) {
                adSpec.SomDig_BT__c = newPlacement.SomDig_BT__c;
                changed = true;
            }

            // FC Fähigkeit: ADvendio__Placement__c.SomDig_FC__c, ADvendio__Ad_Specs__c.SomDig_FC__c
            if (newPlacement.SomDig_FC__c != oldPlacement.SomDig_FC__c &&
                newPlacement.SomDig_FC__c != adSpec.SomDig_FC__c
            ) {
                adSpec.SomDig_FC__c = newPlacement.SomDig_FC__c;
                changed = true;
            }

            // GT Fähigkeit: ADvendio__Placement__c.SomDig_GtFaehig__c, ADvendio__Ad_Specs__c.SomDig_GtFaehig__c
            if (newPlacement.SomDig_GtFaehig__c != oldPlacement.SomDig_GtFaehig__c &&
                newPlacement.SomDig_GtFaehig__c != adSpec.SomDig_GtFaehig__c
            ) {
                adSpec.SomDig_GtFaehig__c = newPlacement.SomDig_GtFaehig__c;
                changed = true;
            }

            // iAD Fähigkeit: ADvendio__Placement__c.SomDig_iAdFaehig__c, ADvendio__Ad_Specs__c.SomDig_iAdFaehig__c
            if (newPlacement.SomDig_iAdFaehig__c != oldPlacement.SomDig_iAdFaehig__c &&
                newPlacement.SomDig_iAdFaehig__c != adSpec.SomDig_iAdFaehig__c
            ) {
                adSpec.SomDig_iAdFaehig__c = newPlacement.SomDig_iAdFaehig__c;
                changed = true;
            }

            // Targeting Provider: ADvendio__Placement__c.Targeting_Provider__c, ADvendio__Ad_Specs__c.SomDig_Targeting_Provider__c
            if (newPlacement.Targeting_Provider__c != oldPlacement.Targeting_Provider__c &&
                newPlacement.Targeting_Provider__c != adSpec.SomDig_Targeting_Provider__c
            ) {
                adSpec.SomDig_Targeting_Provider__c = newPlacement.Targeting_Provider__c;
                changed = true;
            }

            if (changed) adSpecsSet.add(adSpec);
        }

        if (!adSpecsSet.isEmpty()) {
            update new List<ADvendio__Ad_Specs__c>(adSpecsSet);
        }
    }

    private static void updateAdServerIdAdSpecAssignments(Map<Id, ADvendio__Placement__c> placementsMap, Map<Id, ADvendio__Ad_Specs__c> adSpecsMap) {
        List<ADvendio__AdServer_ID_AdSpec_Assigment__c> existingAssignments = [
            SELECT Id, ADvendio__Ad_Spec__c
              FROM ADvendio__AdServer_ID_AdSpec_Assigment__c
             WHERE ADvendio__Ad_Spec__c IN :adSpecsMap.keySet()
        ];
        List<ADvendio__AdServer_ID_AdSpec_Assigment__c> newAssignments = new List<ADvendio__AdServer_ID_AdSpec_Assigment__c>();

        for (ADvendio__Ad_Specs__c adSpec : adSpecsMap.values()) {
            if (placementsMap.containsKey(adSpec.ADvendio__Placement__c) && placementsMap.get(adSpec.ADvendio__Placement__c).SomDig_AdServerID__c != null) {
                newAssignments.add(new ADvendio__AdServer_ID_AdSpec_Assigment__c(
                    ADvendio__Ad_Spec__c = adSpec.Id,
                    ADvendio__AdServer_ID__c = placementsMap.get(adSpec.ADvendio__Placement__c).SomDig_AdServerID__c
                ));
            }
        }

        if (!existingAssignments.isEmpty()) delete existingAssignments;
        if (!newAssignments.isEmpty()) insert newAssignments;
    }

}