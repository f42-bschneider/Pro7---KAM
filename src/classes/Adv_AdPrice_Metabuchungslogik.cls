public with sharing class Adv_AdPrice_Metabuchungslogik {

    public static String ERROR_MSG = 'Werbemittelpreis konnte nicht gespeichert werden, weil er nicht der Metabuchungslogik entspricht.';

    static List<SomDig_Metabuchungslogik__c> METABUCHUNGSLOGIK;
    @testVisible static Boolean manuallyEnabledForTesting;

    static {
            String activeMBLQuery = cls_P7S1_Utils.getStandardQuery('SomDig_Metabuchungslogik__c');
            activeMBLQuery += ' WHERE SomDig_IsActive__c = true';
            METABUCHUNGSLOGIK = Database.query(activeMBLQuery);

            manuallyEnabledForTesting = false;
    }


    public static void checkAdPriceConfiguration(List<ADvendio__Ad_price__c> listAdPrices) {
        for (ADvendio__Ad_price__c adPrice : listAdPrices) {
            SomDig_Metabuchungslogik__c mbl = findValidMbl(adPrice);

            if (mbl != null) {
                adPrice.SomDig_Metabuchungslogik__c = mbl.Id;
            } else if (!SomDig_Settings__c.getInstance().SomDig_MetabuchungslogikDebugMode__c && (!Test.isRunningTest() || manuallyEnabledForTesting)) {
                adPrice.addError(ERROR_MSG);
            }
        }
    }

    static SomDig_Metabuchungslogik__c findValidMbl(ADvendio__Ad_price__c adPrice) {
        SomDig_Metabuchungslogik__c validMbl;

        for (SomDig_Metabuchungslogik__c mbl : METABUCHUNGSLOGIK) {
            Set<String> abrechnungsartenSet = new Set<String>(mbl.SomDig_Abrechnungsart__c.split(';'));
            Set<String> rotationstypenSet = new Set<String>(mbl.SomDig_Rotationstyp__c.split(';'));

            if (
                // Abrechnungsart, SomDig_Abrechnungsart__c
                (mbl.SomDig_Abrechnungsart__c == null || abrechnungsartenSet.contains(adPrice.ADvendio__Billing_Category__c)) &&

                // Auftragstyp, SomDig_Auftragstyp__c
                (mbl.SomDig_Auftragstyp__c == null || mbl.SomDig_Auftragstyp__c == adPrice.SomDig_Auftragstyp__c) &&

                // BT fähig, SomDig_BtFaehig__c
                mbl.SomDig_BtFaehig__c == adPrice.SomDig_BtFaehig__c &&

                // CPX fähig, SomDig_CpxFaehig__c
                mbl.SomDig_CpxFaehig__c == adPrice.SomDig_CpxFaehig__c &&

                // FC fähig, SomDig_FcFaehig__c
                mbl.SomDig_FcFaehig__c == adPrice.SomDig_FcFaehig__c &&

                // GT fähig, SomDig_GtFaehig__c
                mbl.SomDig_GtFaehig__c == adPrice.SomDig_GtFaehig__c &&

                // Mediagattungsdifferenzierung, SomDig_Mediagattungsdifferenzierung__c
                (mbl.SomDig_MediagattungsDifferenzierung__c == null || mbl.SomDig_MediagattungsDifferenzierung__c == adPrice.SomDig_MediagattungsDifferenzierung__c) &&

                // Rotationstyp, SomDig_Rotationstyp__c
                (mbl.SomDig_Rotationstyp__c == null || rotationstypenSet.contains(adPrice.SomDig_Rotationstyp__c)) &&

                // TKP fähig, SomDig_TkpFaehig__c
                mbl.SomDig_TkpFaehig__c == adPrice.SomDig_TkpFaehig__c &&

                // WB Fähig, SomDig_WbFaehig__c
                mbl.SomDig_WbFaehig__c == adPrice.SomDig_WbFaehig__c &&

                // Werbeformgruppe, SomDig_Werbeformgruppe__c
                (mbl.SomDig_Werbeformgruppe__c == null || mbl.SomDig_Werbeformgruppe__c == adPrice.SomDig_Werbeformgruppe__c)
            ) {
                validMbl = mbl;
                break;
            }
        }

        return validMbl;
    }

}