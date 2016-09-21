/**
 * This trigger checks if a 'SomDig_DeliverPrio__c' is already in the database  
 */
    public with sharing class SomDig_DeliverPrio_Check extends TriggerController{  
    
        public SomDig_DeliverPrio_Check(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    // before Insert
    protected override void runBeforeInsert() {
        checkDoubleValues((List<SomDig_DeliverPrio__c>) lstNewItems);
    }

    // before Update
    protected override void runBeforeUpdate() {
        List<SomDig_DeliverPrio__c> hasChanged = getChangedItems((List<SomDig_DeliverPrio__c>)lstNewItems, (Map<Id, SomDig_DeliverPrio__c>)mapOldItems);
        if (hasChanged.size() >0) {
            checkDoubleValues((List<SomDig_DeliverPrio__c>) hasChanged);
        } 
    }
    
    private List<SomDig_DeliverPrio__c> getChangedItems(List<SomDig_DeliverPrio__c> lstNewItems, Map<Id, SomDig_DeliverPrio__c> mapOldItems) {
        List<SomDig_DeliverPrio__c> changedItems = new List<SomDig_DeliverPrio__c>();
        
        for (SomDig_DeliverPrio__c auslieferungsprio : lstNewItems) {
            if (  mapOldItems.get(auslieferungsprio.id).SomDig_Abrechungsart__c != auslieferungsprio.SomDig_Abrechungsart__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Ad_Type__c != auslieferungsprio.SomDig_Ad_Type__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Auftragstyp__c != auslieferungsprio.SomDig_Auftragstyp__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Belegungseinheitstyp__c != auslieferungsprio.SomDig_Belegungseinheitstyp__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Gueltig_ab__c != auslieferungsprio.SomDig_Gueltig_ab__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Gueltig_bis__c != auslieferungsprio.SomDig_Gueltig_bis__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Mediagattungsdifferenzierung__c != auslieferungsprio.SomDig_Mediagattungsdifferenzierung__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Preistyp_zur_Auslieferung__c != auslieferungsprio.SomDig_Preistyp_zur_Auslieferung__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Prio__c != auslieferungsprio.SomDig_Prio__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Rotationstyp__c != auslieferungsprio.SomDig_Rotationstyp__c
               || mapOldItems.get(auslieferungsprio.id).SomDig_Werbeform_Kurzform__c != auslieferungsprio.SomDig_Werbeform_Kurzform__c
               ) {
                   changedItems.add(auslieferungsprio);
               }
        }
        return changedItems;
    }
    /**
     * Each new 'SomDig_DeliverPrio__c' gets an temporary uniqueKey as a concatenation of the following fields:
     *
     * SomDig_Abrechungsart__c, SomDig_Ad_Type__c, SomDig_Auftragstyp__c, SomDig_Belegungseinheitstyp__c, 
     * SomDig_Mediagattungsdifferenzierung__c, SomDig_Preistyp_zur_Auslieferung__c, SomDig_Prio__c,
     * SomDig_Rotationstyp__c, SomDig_Werbeform_Kurzform__c
     * 
     * If the same uniqueKey is already available we have to check if the given time periods overlaps. If 
     * yes show an error message. Otherwise the new 'SomDig_DeliverPrio__c'
     * will be inserted
     */
    private void checkDoubleValues(List<SomDig_DeliverPrio__c> newItemsList){
        List<SomDig_DeliverPrio__c> allItems = new List<SomDig_DeliverPrio__c>([SELECT Name, SomDig_Abrechungsart__c, SomDig_Ad_Type__c, SomDig_Auftragstyp__c, 
                                                                                                        SomDig_Belegungseinheitstyp__c, SomDig_Gueltig_ab__c, SomDig_Gueltig_bis__c, 
                                                                                                        SomDig_Mediagattungsdifferenzierung__c, SomDig_Preistyp_zur_Auslieferung__c, SomDig_Prio__c, 
                                                                                                        SomDig_Rotationstyp__c, SomDig_Werbeform_Kurzform__c 
                                                                                                        FROM SomDig_DeliverPrio__c]);
        
        for (SomDig_DeliverPrio__c toInsertItem : newItemsList) {
                String tmpToInsertUniqueKey = toInsertItem.SomDig_Abrechungsart__c + '|' + toInsertItem.SomDig_Ad_Type__c + '|' + toInsertItem.SomDig_Auftragstyp__c + '|' + toInsertItem.SomDig_Belegungseinheitstyp__c + '|' 
                            +  + toInsertItem.SomDig_Mediagattungsdifferenzierung__c + '|'
                            + toInsertItem.SomDig_Preistyp_zur_Auslieferung__c + '|'+ toInsertItem.SomDig_Prio__c + '|' + toInsertItem.SomDig_Rotationstyp__c + '|' 
                            + toInsertItem.SomDig_Werbeform_Kurzform__c;
                
                Date tmpToInsertValidFrom = toInsertItem.SomDig_Gueltig_ab__c;
                Date tmpToInsertValidUntil = toInsertItem.SomDig_Gueltig_bis__c;
        
                /** Add an error message if the from date is after the until date */
                if (tmpToInsertValidFrom > tmpToInsertValidUntil) {
                    toInsertItem.addError('Gültig ab Datum liegt vor Gültig bis Datum');
                }
            
                for (SomDig_DeliverPrio__c ap : allItems) {
                    String tmpUniqueKey = ap.SomDig_Abrechungsart__c + '|' + ap.SomDig_Ad_Type__c + '|' + ap.SomDig_Auftragstyp__c + '|' + ap.SomDig_Belegungseinheitstyp__c + '|' 
                                    + ap.SomDig_Mediagattungsdifferenzierung__c + '|'
                                    + ap.SomDig_Preistyp_zur_Auslieferung__c + '|'+ ap.SomDig_Prio__c + '|' + ap.SomDig_Rotationstyp__c + '|' 
                                    + ap.SomDig_Werbeform_Kurzform__c; 
                    Date tmpValidFrom = ap.SomDig_Gueltig_ab__c;
                    Date tmpValidUntil = ap.SomDig_Gueltig_bis__c;
                
                /** Just check the Auslieferungsprioritaeten where all other fields have the same values */
                if (tmpToInsertUniqueKey.equals(tmpUniqueKey)) {
                    // Such an SomDig_DeliverPrio__c is already available
                    // Now we have to check if the dates/date periods are the same.
                    boolean isSamePeriod = checkPeriods(tmpValidFrom, tmpValidUntil, tmpToInsertValidFrom, tmpToInsertValidUntil);
                    if (isSamePeriod && isInsert) {
                        toInsertItem.addError('Es gibt bereits eine Auslieferungsprioritaet, die in diesem Zeitraum liegt: ' + ap.Name);
                    }
                    if (isUpdate && isSamePeriod && (ap.Id != toInsertItem.id)) {
                        toInsertItem.addError('Es gibt bereits eine Auslieferungsprioritaet, die in diesem Zeitraum liegt: ' + ap.Name);
                    }
                }    
            }
        }
    }
        
    /**
     * Checks if a given time period is overlapping another time period
     * @param tmpValidFrom Field Gueltig_ab__c of the SomDig_DeliverPrio__c we compare to the item we want to insert.
     * @param tmpValidUntil Field Gueltig_bis__c of the SomDig_DeliverPrio__c we compare to the item we want to insert.
     * @param tmpToInsertValidFrom Field Gueltig_ab__c of the SomDig_DeliverPrio__c we want to insert
     * @param tmpToInsertValidUntil Field Gueltig_bis__c of the SomDig_DeliverPrio__c we want to insert
     * @return true if both time periods overlapp
     */    
    private boolean checkPeriods(Date tmpValidFrom, Date tmpValidUntil, Date tmpToInsertValidFrom, Date tmpToInsertValidUntil) {
        boolean hasSamePeriod = false;
        if ( !(tmpValidFrom > tmpToInsertValidUntil) && !(tmpToInsertValidFrom > tmpValidUntil) ) {
            System.debug('same period');
            hasSamePeriod = true;
        } 
        return hasSamePeriod;           
    }
}