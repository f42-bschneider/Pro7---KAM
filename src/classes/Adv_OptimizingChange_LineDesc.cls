/*
Used in Trigger "Adv_OptimizingChange".

KV: 02724
Creates a OptimizingChange record for "ADvendio__Line_Description__c", dependent on several values from other changes of that version
*/

public with sharing class Adv_OptimizingChange_LineDesc {

    public static void setLineDescription(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<ADvendio__OptimizingChange__c> lstNewItems, Map<Id, ADvendio__OptimizingChange__c> mapNewItems, List<ADvendio__OptimizingChange__c> lstOldItems, Map<Id, ADvendio__OptimizingChange__c> mapOldItems) {

        // stop here if trigger context includes OptimizingChanges for more than 1 OptimizingVersion
        if (!Adv_OptimizingChange_Handler.isSingleOptimizingVersion(lstNewItems)) return;


        Id optiVersionID = lstNewItems[0].ADvendio__OptimizingVersion__c;

        List<ADvendio__OptimizingChange__c> relevantOCsList = new List<ADvendio__OptimizingChange__c>();
        Set<Id> setCampaignItemID = new Set<Id>();
        for (ADvendio__OptimizingChange__c oc : lstNewItems) {
            if (oc.ADvendio__FieldName__c == 'somdig_freitextnotiz__c' ||
                oc.ADvendio__FieldName__c == 'advendio__rate_discount_4_name__c' ||
                oc.ADvendio__FieldName__c == 'somdig_otpaufschlag__c'
            ) {
                relevantOCsList.add(oc);
                setCampaignItemID.add(oc.ADvendio__CampaignItem__c);
            }
        }

        if (!relevantOCsList.isEmpty()) {
            Map<Id, String> oldLineDescriptionMap = new Map<Id, String>();

            for (ADvendio__Campaign_Item__c ci : [
                SELECT ADvendio__Line_Description__c
                  FROM ADvendio__Campaign_Item__c
                 WHERE Id IN :setCampaignItemID
            ]) {
                oldLineDescriptionMap.put(ci.Id, ci.ADvendio__Line_Description__c);
            }

            Map<Id, String> identifierNewLineDescriptionMap = new Map<Id, String>();
            List<ADvendio__OptimizingChange__c> newOCsList = new List<ADvendio__OptimizingChange__c>();

            Map<Id, Map<String, ADvendio__OptimizingChange__c>> identifierOCsMap = Adv_OptimizingChange_Handler.getCIOptiMapAll(relevantOCsList);

            for (Id identifier : identifierOCsMap.keySet()) {
                Map<String, ADvendio__OptimizingChange__c> fieldNameOCMap = identifierOCsMap.get(identifier);

                String oldLineDescription = oldLineDescriptionMap.get(identifier);

                if (identifierNewLineDescriptionMap.get(identifier) == null) {
                    if (oldLineDescription != null) {
                        identifierNewLineDescriptionMap.put(identifier, oldLineDescription);
                    } else {
                        identifierNewLineDescriptionMap.put(identifier, '');
                    }
                }

                Id ciId;
                Id newCiIdentifier;

                for (String fieldName : fieldNameOCMap.keySet()) {
                    ADvendio__OptimizingChange__c oc = fieldNameOCMap.get(fieldName);

                    String tmpDescription = identifierNewLineDescriptionMap.get(identifier);
                    String tmp;

                    if (ciId == null) ciId = oc.ADvendio__CampaignItem__c;
                    if (newCiIdentifier == null) newCiIdentifier = oc.ADvendio__NewCiIdentifier__c;

                    if (fieldName == 'somdig_freitextnotiz__c') {
                        if (oc.ADvendio__OriginalValue__c == null) {
                            tmp = '-' + oc.ADvendio__OptimizedValue__c + ' ' + tmpDescription;
                        } else if (oc.ADvendio__OptimizedValue__c == null) {
                            tmp = tmpDescription.replace('-' + oc.ADvendio__OriginalValue__c, '');
                        } else {
                            tmp = tmpDescription.replace(oc.ADvendio__OriginalValue__c, oc.ADvendio__OptimizedValue__c);
                        }
                    }

                    if (fieldName == 'advendio__rate_discount_4_name__c') {
                        // e.g. null -> InStream
                        if (oc.ADvendio__OriginalValue__c == null && descriptionForDiscountType(oc.ADvendio__OptimizedValue__c) == null) {
                            tmp = tmpDescription;
                        }

                        // e.g. null -> Nachlieferung
                        if (oc.ADvendio__OriginalValue__c == null && descriptionForDiscountType(oc.ADvendio__OptimizedValue__c) != null) {
                            tmp = tmpDescription + ' -' + descriptionForDiscountType(oc.ADvendio__OptimizedValue__c);
                        }

                        // e.g. InPage -> NULL
                        if (descriptionForDiscountType(oc.ADvendio__OriginalValue__c) == null && oc.ADvendio__OptimizedValue__c == null) {
                            tmp = tmpDescription;
                        }

                        // e.g. InPage -> InStream
                        if (descriptionForDiscountType(oc.ADvendio__OriginalValue__c) == null && descriptionForDiscountType(oc.ADvendio__OptimizedValue__c) == null) {
                            tmp = tmpDescription;
                        }

                        // e.g. InPage -> Nachlieferung
                        if (descriptionForDiscountType(oc.ADvendio__OriginalValue__c) == null && descriptionForDiscountType(oc.ADvendio__OptimizedValue__c) != null) {
                            tmp = tmpDescription + ' -' + descriptionForDiscountType(oc.ADvendio__OptimizedValue__c);
                        }

                        // e.g. Storno mit LF -> NULL
                        if (descriptionForDiscountType(oc.ADvendio__OriginalValue__c) == null && oc.ADvendio__OptimizedValue__c == null) {
                            tmp = tmpDescription.replaceFirst(' ?-' + descriptionForDiscountType(oc.ADvendio__OriginalValue__c), '');
                        }

                        // e.g. Storno mit LF -> InStream
                        if (descriptionForDiscountType(oc.ADvendio__OriginalValue__c) != null && descriptionForDiscountType(oc.ADvendio__OptimizedValue__c) == null) {
                            tmp = tmpDescription.replaceFirst(' ?-' + descriptionForDiscountType(oc.ADvendio__OriginalValue__c), '');
                        }

                        // e.g. Storno mit LF -> Nachlieferung
                        if (descriptionForDiscountType(oc.ADvendio__OriginalValue__c) != null && descriptionForDiscountType(oc.ADvendio__OptimizedValue__c) != null) {
                            tmp = tmpDescription.replace(descriptionForDiscountType(oc.ADvendio__OriginalValue__c), descriptionForDiscountType(oc.ADvendio__OptimizedValue__c));
                        }
                    }

                    if (fieldName == 'somdig_otpaufschlag__c') {
                        if (oc.ADvendio__OptimizedValue__c == 'false') {
                            tmp = tmpDescription.replaceFirst(' ?-OTP', '');
                        } else {
                            tmp = tmpDescription + ' -OTP';
                        }
                    }

                    identifierNewLineDescriptionMap.put(identifier, tmp);
                }

                newOCsList.add(Adv_OptimizingChange_Handler.createOC(
                    ciId, optiVersionID, 'advendio__line_description__c', oldLineDescription, identifierNewLineDescriptionMap.get(identifier), newCiIdentifier
                ));
            }

            if(!newOCsList.isEmpty()) insert newOCsList;
        }
    }


    private static Map<String, String> MAPPING = new Map<String, String>{
        'Kompensation'               => 'Kompensation',
        'Nachlieferung'              => 'Nachlieferung',
        'Positionsrabatt Natural'    => 'NR',
        'Storno mit Leistungsfluss'  => 'Storno',
        'Storno ohne Leistungsfluss' => 'Storno'
    };


    // TODO: Methode auch für Klasse Adv_CampaignItem_FieldChanges verwenden
    private static String descriptionForDiscountType(String discountName) {
        return MAPPING.containsKey(discountName) ? MAPPING.get(discountName) : null;
    }

}