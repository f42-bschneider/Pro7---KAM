/**
 *  The trigger controller class for sObject SomTv_Angebot__c.
 *  @author Benhui.Chen@advendio.com
 */
public without sharing class SomTv_Opportunity_UpdateFromAngebot extends TriggerController {
    /** RecordType for TV Opportinty */
    private final static Set<String> RECORDTYPEFORTVOPP = new Set<String> {'SomTv_BuchungenOhneVertraege', 'SomTv_Commitment', 'SomTv_Paket', 'SomTv_Zubuchung'};
    
    /** 
     * Constructor.
     * @see TriggerController   The base class of trigger controller.
     */
    public SomTv_Opportunity_UpdateFromAngebot (Boolean isAfter, Boolean isBefore,
            Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    /**
     * Override method to perform action after an insert operation was fired.
     * @see TriggerController#runAfterInsert
     */
    protected override void runAfterInsert() {
        if (validateAngebot((List<SomTv_Angebot__c>)lstNewItems)) {
            updateOppornity((List<SomTv_Angebot__c>)lstNewItems);
            calculateSomTv_MN3((List<SomTv_Angebot__c>)lstNewItems, (Map<Id, SomTv_Angebot__c>) mapOldItems);
        }
    }

    /**
     * Override method to perform action after an undelete operation was fired.
     * @see TriggerController#runAfterUndelete
     */
    protected override void runAfterUndelete() {
        if (validateAngebot((List<SomTv_Angebot__c>)lstNewItems)) {
            updateOppornity((List<SomTv_Angebot__c>)lstNewItems);
            calculateSomTv_MN3((List<SomTv_Angebot__c>)lstNewItems, (Map<Id, SomTv_Angebot__c>) mapOldItems);
        }
    }

    /**
     * Override method to perform action after an update operation was fired.
     * @see TriggerController#runAfterUpdate
     */
    protected override void runAfterUpdate() {
        if (validateAngebot((List<SomTv_Angebot__c>)lstNewItems)) {
            updateOppornity((List<SomTv_Angebot__c>)lstNewItems);
            calculateSomTv_MN3((List<SomTv_Angebot__c>)lstNewItems, (Map<Id, SomTv_Angebot__c>) mapOldItems);
        }
    }

    /**
     * Calculate the SomTv_MN3__c.
     *
     * @param   lstNewAngebots  A list of SomTv_Angebot__c to use.
     * @param   mapOldAngebots  A map with the Id as key and (old)SomTv_Angebot__c as value.
     */
    private void calculateSomTv_MN3(List<SomTv_Angebot__c> lstNewAngebots, Map<Id, SomTv_Angebot__c> mapOldAngebots) {
        // Note: This calculation will be done per workflow and/or field-update. (Stand: 2013-04-24)
        
        /*
        // Hm, this should be called for after events because SomTv_BRDSB__c is a formula field :-(
        
        // According to JIRA Issue: SOTV-1
        // Bei der Auswahl des jeweiligen oben genannten Rabatte gehen wir nach folgender Regel vor (OBER sticht UNTER):
        // Prio: Angebot > DSB > RM > Sales > Kunde
        // --> WENN NUR SomTv_BRKunde_c, DANN SomTv_BRKunde_c
        // --> WENN NUR SomTv_BRKunde_c && SomTv_BRRMc, DANN SomTv_BRRM_c
        // --> WENN NUR SomTv_BRKunde_c && SomTv_BRRMc && SomTv_BRDSBc, DANN SomTv_BRDSB_c
        // --> WENN SomTv_BRRM_c && SomTv_BRDSBc, DANN SomTv_BRDSB_c
        // --> WENN SomTv_BRKunde_c && SomTv_BRDSBc, DANN SomTv_BRDSB_c
        // --> WENN SomTv_BRAngebot_c DANN DANN SomTv_BRAngebot_c
        
        // Thus saying simplified: discount is:
        // If SomTv_BRAngebot__c defined, then take it
        // If SomTv_BRDSB__c defined, then take it
        // If SomTv_BRRM__c defined, then take it
        // If SomTv_BRKunde__c defined, then take it
        
        List<SomTv_Angebot__c> angebots2update = new List<SomTv_Angebot__c>();
        for (SomTv_Angebot__c angebot : lstNewAngebots) {
            Decimal discount = angebot.SomTv_BRAngebot__c != null ? angebot.SomTv_BRAngebot__c : (angebot.SomTv_BRDSB__c != null ? angebot.SomTv_BRDSB__c : (angebot.SomTv_BRRM__c != null ? angebot.SomTv_BRRM__c : (angebot.SomTv_BRKunde__c != null ? angebot.SomTv_BRKunde__c : 0.0)));
            Decimal amount = (angebot.SomTv_MB1__c * (1 - discount/100.0)).setScale(2, System.Roundingmode.HALF_UP);
            if (mapOldAngebots == null || !mapOldAngebots.containsKey(angebot.Id) || mapOldAngebots.get(angebot.Id).SomTv_MN3__c == null || mapOldAngebots.get(angebot.Id).SomTv_MN3__c.setScale(2, System.Roundingmode.HALF_UP) != amount) {
                angebots2update.add(new SomTv_Angebot__c(Id=angebot.Id, SomTv_MN3__c=amount));
            }
        }
        
        if (!angebots2update.isEmpty()) {
            update angebots2update;
        }
        */
    }

    /**
     * Validate the SomTv_Angebot__c being changed.
     *
     * @param   lstNewAngebots  A list of SomTv_Angebot__c to use.
     * @return                  True if eventhing is OK, false otherwise.
     */
    private Boolean validateAngebot(List<SomTv_Angebot__c> lstNewAngebots) {
        // This should be called for after events because some data used require "updated"/"actual" data.
        Boolean isOK = true;
                
        // For all SomTv_Angebot__c for an Opportunity:
        //--> Feld SomTv_RealisticCaseAngebot__c darf MAXIMAL nur bei einem Datensatz = true sein (Sprechende Fehlermeldung mit verweis auf Datensatz, welcher = true ist)
        //--> Feld SomTv_Stufe__c (Picklist) muss eindeutig sein, d.h. Werte 1-5 dürfen nur einmal vorkommen
        //--> Feldwerte SomTv_MB1__c, SomTv_BRKopf_c__c, SomTv_NRKopf_c__c, SomTv_SonderNR1Kopf_c__c, SomTv_SonderNR2Kopf_c__c in Kombination mit SomTv_Stufe__c muss eindeutig sein

        // A map, key is the OpportunityId, value is a list of newly changed SomTv_Angebot__c.
        Map<Id, List<SomTv_Angebot__c>> mOppId2ChangedAngebots = new Map<Id, List<SomTv_Angebot__c>>();

        // A map, key is the OpportunityId, value is a list of other existed SomTv_Angebot__c.
        Map<Id, List<SomTv_Angebot__c>> mOppId2ExistedAngebots = new Map<Id, List<SomTv_Angebot__c>>();

        // Collect some data.       
        Set<Id> angebotIds = new Set<Id>();
        for (SomTv_Angebot__c angebot : lstNewAngebots) {
            angebotIds.add(angebot.Id);
            List<SomTv_Angebot__c> lst = mOppId2ChangedAngebots.get(angebot.SomTv_Opportunity__c);
            if (lst == null) {
                lst = new List<SomTv_Angebot__c>();
                mOppId2ChangedAngebots.put(angebot.SomTv_Opportunity__c, lst);
            }
            lst.add(angebot);
        }
        mOppId2ChangedAngebots.remove(null);
        angebotIds.remove(null);
        
        // Get all SomTv_Angebot__c not in current list but belong to same opportunity.
        if (!mOppId2ChangedAngebots.isEmpty()) {
            Set<Id> oppIds = mOppId2ChangedAngebots.keySet();
            for (List<SomTv_Angebot__c> angebots : [SELECT Id, SomTv_Opportunity__c, SomTv_RealisticCaseAngebot__c, SomTv_Stufe__c, SomTv_MB1__c, SomTv_BRKopf_c__c, SomTv_NRKopf_c__c, SomTv_SonderNR1Kopf_c__c, SomTv_SonderNR2Kopf_c__c FROM SomTv_Angebot__c WHERE SomTv_Opportunity__c IN :oppIds AND Id NOT IN :angebotIds AND isDeleted = false]) {
                for (SomTv_Angebot__c angebot : angebots) {
                    List<SomTv_Angebot__c> lst = mOppId2ExistedAngebots.get(angebot.SomTv_Opportunity__c);
                    if (lst == null) {
                        lst = new List<SomTv_Angebot__c>();
                        mOppId2ExistedAngebots.put(angebot.SomTv_Opportunity__c, lst);
                    }
                    lst.add(angebot);
                }
            }
        }
        
        // Check records being changed.
        isOk = validateAngebot(lstNewAngebots, mOppId2ChangedAngebots);
        if (isOK) {
            isOk = validateAngebot(lstNewAngebots, mOppId2ExistedAngebots);
        }

        return isOK;
    }
    
    /**
     * Validate the SomTv_Angebot__c being changed.
     *
     * @param   lstNewAngebots          A list of SomTv_Angebot__c to check.
     * @param   mOppId2Angebots A map using OpportunityId as key and a list of SomTv_Angebot__c as value to compare.
     * @return                          True if eventhing is OK, false otherwise.
     */
    private Boolean validateAngebot(List<SomTv_Angebot__c> lstNewAngebots, Map<Id, List<SomTv_Angebot__c>> mOppId2Angebots) {
        Boolean isOK = true;

        // For all SomTv_Angebot__c for an Opportunity:
        //--> Feld SomTv_RealisticCaseAngebot__c darf MAXIMAL nur bei einem Datensatz = true sein (Sprechende Fehlermeldung mit verweis auf Datensatz, welcher = true ist)
        //--> Feld SomTv_Stufe__c (Picklist) muss eindeutig sein, d.h. Werte 1-5 dürfen nur einmal vorkommen
        //--> Feldwerte SomTv_MB1__c, SomTv_BRKopf_c__c, SomTv_NRKopf_c__c, SomTv_SonderNR1Kopf_c__c, SomTv_SonderNR2Kopf_c__c in Kombination mit SomTv_Stufe__c muss eindeutig sein

        // The last rule is needless because 2nd. rule.
        
        // Check records being changed.
        for (SomTv_Angebot__c angebot : lstNewAngebots) {
            List<SomTv_Angebot__c> lstAngebots = mOppId2Angebots.get(angebot.SomTv_Opportunity__c);
            if (lstAngebots != null) {
                /*
                String uniqueKey1 = (angebot.SomTv_Stufe__c == null ? 'null' : String.valueOf(angebot.SomTv_Stufe__c)) + '|' +
                                    (angebot.SomTv_MB1__c == null ? 'null' :  String.valueOf(angebot.SomTv_MB1__c)) + '|' +
                                    (angebot.SomTv_BRKopf_c__c == null ? 'null' :  String.valueOf(angebot.SomTv_BRKopf_c__c)) + '|' + 
                                    (angebot.SomTv_NRKopf_c__c == null ? 'null' :  String.valueOf(angebot.SomTv_NRKopf_c__c)) + '|' + 
                                    (angebot.SomTv_SonderNR1Kopf_c__c == null ? 'null' :  String.valueOf(angebot.SomTv_SonderNR1Kopf_c__c)) + '|' + 
                                    (angebot.SomTv_SonderNR2Kopf_c__c == null ? 'null' :  String.valueOf(angebot.SomTv_SonderNR2Kopf_c__c));
                */
                for (SomTv_Angebot__c otherAngebot : lstAngebots) {
                    if (angebot.Id == otherAngebot.Id ) {
                        continue;
                    }
                    if (angebot.SomTv_RealisticCaseAngebot__c && otherAngebot.SomTv_RealisticCaseAngebot__c) {
                        isOK = false;
                        angebot.SomTv_RealisticCaseAngebot__c.addError('Es existiert schon ein Angebot (Id: ' + otherAngebot.Id + ') mit dem Wert ' + String.valueOf(otherAngebot.SomTv_RealisticCaseAngebot__c) + ' im Feld SomTv_RealisticCaseAngebot__c.');
                        break;
                    }
                    if (angebot.SomTv_Stufe__c != null && angebot.SomTv_Stufe__c.equals(otherAngebot.SomTv_Stufe__c)) {
                        isOK = false;
                        angebot.SomTv_Stufe__c.addError('Es existiert schon ein Angebot (Id: ' + otherAngebot.Id + ') mit dem Wert ' + String.valueOf(otherAngebot.SomTv_Stufe__c) + ' im Feld SomTv_Stufe__c.');
                        break;
                    }
                    /*
                    if (otherAngebot.SomTv_Stufe__c != null || otherAngebot.SomTv_MB1__c != null || otherAngebot.SomTv_BRKopf_c__c != null || otherAngebot.SomTv_NRKopf_c__c != null || otherAngebot.SomTv_SonderNR1Kopf_c__c != null || otherAngebot.SomTv_SonderNR2Kopf_c__c != null) {
                        String uniqueKey2 = (otherAngebot.SomTv_Stufe__c == null ? 'null' : String.valueOf(otherAngebot.SomTv_Stufe__c)) + '|' +
                                            (otherAngebot.SomTv_MB1__c == null ? 'null' :  String.valueOf(otherAngebot.SomTv_MB1__c)) + '|' +
                                            (otherAngebot.SomTv_BRKopf_c__c == null ? 'null' :  String.valueOf(otherAngebot.SomTv_BRKopf_c__c)) + '|' + 
                                            (otherAngebot.SomTv_NRKopf_c__c == null ? 'null' :  String.valueOf(otherAngebot.SomTv_NRKopf_c__c)) + '|' + 
                                            (otherAngebot.SomTv_SonderNR1Kopf_c__c == null ? 'null' :  String.valueOf(otherAngebot.SomTv_SonderNR1Kopf_c__c)) + '|' + 
                                            (otherAngebot.SomTv_SonderNR2Kopf_c__c == null ? 'null' :  String.valueOf(otherAngebot.SomTv_SonderNR2Kopf_c__c));
                        if (uniqueKey1 == uniqueKey2) {
                            isOK = false;
                            angebot.addError('Es existiert schon ein Angebot (Id: ' + otherAngebot.Id + ') mit einem gleichen Wert ' + uniqueKey1 + ' aus der Kombination SomTv_Stufe__c, SomTv_MB1__c, SomTv_BRKopf_c__c, SomTv_NRKopf_c__c, SomTv_SonderNR1Kopf_c__c und SomTv_SonderNR2Kopf_c__c.');
                            break;
                        }
                    }
                    */
                }
            }
            if (!isOK) break;
        }

        return isOK;
    }
    
    /**
     * Update the (parent) Opportunity.
     *
     * @param   lstNewAngebots  A list of SomTv_Angebot__c to use.
     */
    private void updateOppornity(List<SomTv_Angebot__c> lstNewAngebots) {
        Map<Id, Opportunity> mOpps = new Map<Id, Opportunity>();

        // Action 1:        
        // Update Opportunity.Amount and Opportunity.SomTv_MN3__c with SomTv_MB1_konsolidiert__c and SomTv_MN3_konsolidiert__c,
        // where conditions are:
        // 1) SomTv_RealisticCaseAngebot_c = true
        // 2) RecordType of Opp must be for TV Opp.
        
        // Action 2:        
        // Update Opportunity
        // 1) wenn mindestens ein Angebot mit SomTv_Status__c = "Angeboten", dann Opp.StageName = "Angebot abgegeben";
        // 2) wenn mindestens ein Angebot mit SomTv_Status__c = "Angenommen", dann Opp.StageName = "geschlossen und gewonnene";
        // 3) wenn alle Angebote mit SomTv_Status__c = "Abgelehnt", dann StageName = "geschlossen und verloren"

        // A map, key is Id of opportunity to update, value is a SomTv_Angebot__c to use. For Action 1.
        Map<Id, SomTv_Angebot__c> mOppId2Angebot = new Map<Id, SomTv_Angebot__c>();

        // A set with Opportunity Ids. For Action 2.
        Set<Id> oppIds = new Set<Id>();

        // Get Opportunity Ids.
        for (SomTv_Angebot__c angebot : lstNewAngebots) {
            if (angebot.SomTv_RealisticCaseAngebot__c) {
                // There is a validation to make sure that
                // there is only one SomTv_Angebot__c for an Opportinity will have SomTv_RealisticCaseAngebot__c set to true.
                mOppId2Angebot.put(angebot.SomTv_Opportunity__c, angebot);
            }
            oppIds.add(angebot.SomTv_Opportunity__c);
        }
        
        // Action 1:        
        if (!mOppId2Angebot.isEmpty()) {
            for (List<Opportunity> opps : [SELECT Id, StageName, Amount, SomTv_MN3__c, RecordType.Name, RecordType.DeveloperName FROM Opportunity WHERE Id IN : mOppId2Angebot.keySet()]) {
                for (Opportunity opp : opps) {
                    if (RECORDTYPEFORTVOPP.contains(opp.RecordType.DeveloperName)) {
                        SomTv_Angebot__c angebot = mOppId2Angebot.get(opp.Id);
                        if (angebot != null && (opp.Amount != angebot.SomTv_MB1_konsolidiert__c || opp.SomTv_MN3__c != angebot.SomTv_MN3_konsolidiert__c)) {
                            opp.Amount = angebot.SomTv_MB1_konsolidiert__c;
                            opp.SomTv_MN3__c = angebot.SomTv_MN3_konsolidiert__c;
                            mOpps.put(opp.Id, opp);
                        }
                    }
                }
            }
            
        }       
        
        // Action 2:        
        if (!oppIds.isEmpty()) {
            for (List<Opportunity> opps : [SELECT Id, StageName, (SELECT Id, SomTv_Status__c FROM Angebote__r) FROM Opportunity WHERE Id IN : oppIds]) {
                for (Opportunity opp : opps) {
                    if (opp.Angebote__r != null && !opp.Angebote__r.isEmpty()) {
                        Integer anzahlAngeboten = 0, anzahlAngenommen = 0, anzahlAbgelehnt = 0;
                        for (SomTv_Angebot__c angebot : opp.Angebote__r) {
                            if ('Angeboten'.equals(angebot.SomTv_Status__c)) {
                                anzahlAngeboten++;
                            } else if ('Angenommen'.equals(angebot.SomTv_Status__c)) {
                                anzahlAngenommen++;
                            } else if ('Abgelehnt'.equals(angebot.SomTv_Status__c)) {
                                anzahlAbgelehnt++;
                            }
                        }
                        
                        String StageName = null;
                        if (anzahlAngenommen > 0) {
                            StageName = 'Geschlossene und gewonnene';
                        } else if (anzahlAngeboten > 0) {
                            StageName = 'Angebot abgegeben';
                        } else if (anzahlAbgelehnt == opp.Angebote__r.size()) {
                            StageName = 'Geschlossen und verloren'; 
                        }
                        
                        if (mOpps.containsKey(opp.Id)) {
                            if (StageName != null && !StageName.equals(mOpps.get(opp.Id).StageName)) {
                                mOpps.get(opp.Id).StageName = StageName;
                            }
                        } else if (StageName != null && !StageName.equals(opp.StageName)) {
                            opp.StageName = StageName;
                            mOpps.put(opp.Id, opp); 
                        }
                    }
                }
            }
        }
        
        if (!mOpps.isEmpty()) {
            update mOpps.values();
        }
    }
 
}