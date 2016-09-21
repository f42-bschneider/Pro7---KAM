/**
 *  The trigger controller class for sObject ADvendio__MediaCampaign__c.
*/
public with sharing class Adv_MediaCampaign_Debitorennr extends TriggerController {
    /**
     * Constructor.
     * @see TriggerController   The base class of trigger controller.
     */
    public Adv_MediaCampaign_Debitorennr(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                         List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    public Adv_MediaCampaign_Debitorennr() {
    }

    // before Insert
    protected override void runBeforeInsert() {
        getDebitor((List<ADvendio__MediaCampaign__c>) lstNewItems, null, false);
    }

    // before Update
    protected override void runBeforeUpdate() {
        getDebitor((List<ADvendio__MediaCampaign__c>) lstNewItems, (Map<Id, ADvendio__MediaCampaign__c>) mapOldItems, false);
    }

    /**
    * Get the Debitornumber for the campaign depending on ADvendio__MediaCampaign__c.ADvendio__invoice_recipient__c.
    * Use ADvendio__Pricelist__r.SomDig_Auftragstyp__c to specify if a Barter-Number is to use
    * @param trigger.new (List<ADvendio__MediaCampaign__c>)
    * @param trigger.oldMap (Map<Id, ADvendio__MediaCampaign__c>)
    * @param modifier to skip checks
    **/
    public void getDebitor(List<ADvendio__MediaCampaign__c> mediaCampaigns, Map<Id, ADvendio__MediaCampaign__c> mediaCampaignsOld, Boolean init) {

        Map<Id, Map<String, String>> debitorNumberByAccount = new Map<Id, Map<String, String>>();
        Map<Id, Boolean> mapIsBarterCampaign    = new Map<Id, Boolean>();
        List<ADvendio__MediaCampaign__c> mcUpdates  = new List<ADvendio__MediaCampaign__c>();

        for (ADvendio__MediaCampaign__c mc : mediaCampaigns) {
            if (init ||
                (mc.ADvendio__Propability__c >= 25 &&
                    (
                    isInsert ||
                    mc.ADvendio__Propability__c != mediaCampaignsOld.get(mc.Id).ADvendio__Propability__c ||
// Old                   (mc.ADvendio__invoice_recipient__c != mediaCampaignsOld.get(mc.Id).ADvendio__invoice_recipient__c && mc.ADvendio__Propability__c < 100)
                    (mc.ADvendio__invoice_recipient__c != mediaCampaignsOld.get(mc.Id).ADvendio__invoice_recipient__c)

                    )
                )
            ) {
                debitorNumberByAccount.put(mc.ADvendio__invoice_recipient__c, new Map<String, String>{'Barter' => null, 'NonBarter' => null});
                mapIsBarterCampaign.put(mc.ADvendio__Pricelist__c, false);
            }
        }

        if (!mapIsBarterCampaign.isEmpty() && !debitorNumberByAccount.isEmpty()) {
            for (ADvendio__Pricelist__c pl : [SELECT Id, SomDig_Auftragstyp__c FROM ADvendio__Pricelist__c WHERE Id IN :mapIsBarterCampaign.keySet()]) {
                mapIsBarterCampaign.put(pl.id, ('Barter'.equals(pl.SomDig_Auftragstyp__c) ? true : false));
            }

            for (P7S1_ExternalId__c ext : [SELECT Id, P7S1_Source__c, P7S1_Account__c, Name FROM P7S1_ExternalId__c WHERE P7S1_Account__c IN :debitorNumberByAccount.keySet() AND P7S1_Source__c IN ('Debitorennr BK 29 - Barter','Debitorennr BK 29') AND P7S1_Source__c != null]) {
                if ('Debitorennr BK 29 - Barter'.equals(ext.P7S1_Source__c)) {
                    debitorNumberByAccount.get(ext.P7S1_Account__c).put('Barter', ext.Name);
                }
                if ('Debitorennr BK 29'.equals(ext.P7S1_Source__c)) {
                    debitorNumberByAccount.get(ext.P7S1_Account__c).put('NonBarter', ext.Name);
                }
            }

            for (ADvendio__MediaCampaign__c mc : mediaCampaigns) {
                if (init ||
                    (mc.ADvendio__Propability__c >= 25 &&
                        (
                        isInsert ||
                        mc.ADvendio__Propability__c != mediaCampaignsOld.get(mc.Id).ADvendio__Propability__c ||
                        //Old (mc.ADvendio__invoice_recipient__c != mediaCampaignsOld.get(mc.Id).ADvendio__invoice_recipient__c && mc.ADvendio__Propability__c < 100)
                        (mc.ADvendio__invoice_recipient__c != mediaCampaignsOld.get(mc.Id).ADvendio__invoice_recipient__c)                        
                        )
                    )
                ) {
                    mc.SomDig_Debitorennr__c = debitorNumberByAccount.get(mc.ADvendio__invoice_recipient__c).get((mapIsBarterCampaign.get(mc.ADvendio__Pricelist__c) ? 'Barter' : 'NonBarter'));
                    mcUpdates.add(mc);
                }
            }

            if (init) {
                update mcUpdates;
            }
        }
    }
}