/**
 *  The trigger controller class for sObject Opportunity.
 *  @author Benhui.Chen@advendio.com
 */
public without sharing class SomTv_Opportunity_ValidateData extends TriggerController {
    /** RecordType for child Opportinty to check */
    private final static Set<String> CHILDRENRECORDTYPE = new Set<String> {'SomTv_AdFactory'};
    
    /** RecordType for parent Opportinty to modify */
    private final static Set<String> PARENTRECORDTYPE = new Set<String> {'SomTv_Commitment', 'SomTv_Paket', 'SomTv_Zubuchung'};

    /** 
     * Constructor.
     * @see TriggerController   The base class of trigger controller.
     */
    public SomTv_Opportunity_ValidateData(Boolean isAfter, Boolean isBefore,
            Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    /**
     * Override method to perform action after a delete operation was fired.
     * @see TriggerController#runAfterDelete
     */
    protected override void runAfterDelete() {
        checkOpportunity((List<Opportunity>)lstOldItems, null);
        updateCampaignMN3((List<Opportunity>)lstOldItems, null);
    }

    /**
     * Override method to perform action after an insert operation was fired.
     * @see TriggerController#runAfterInsert
     */
    protected override void runAfterInsert() {
        checkOpportunity((List<Opportunity>)lstNewItems, null);
        updateCampaignMN3((List<Opportunity>)lstNewItems, null);
    }

    /**
     * Override method to perform action after an undelete operation was fired.
     * @see TriggerController#runAfterUndelete
     */
    protected override void runAfterUndelete() {
        checkOpportunity((List<Opportunity>)lstNewItems, null);
        updateCampaignMN3((List<Opportunity>)lstNewItems, null);
    }

    /**
     * Override method to perform action after an update operation was fired.
     * @see TriggerController#runAfterUpdate
     */
    protected override void runAfterUpdate() {
        checkOpportunity((List<Opportunity>)lstNewItems, (Map<Id, Opportunity>) mapOldItems);
        copyDataToOpportunityLineItems((List<Opportunity>)lstNewItems, (Map<Id, Opportunity>) mapOldItems);
        // Feature "Opportunity-Produkt-Snapshot" nicht mehr benötigt, daher auskommentiert.
        //createSnapshotOfLineItems((List<Opportunity>)lstNewItems, (Map<Id, Opportunity>) mapOldItems);
        updateCampaignMN3((List<Opportunity>)lstNewItems, (Map<Id, Opportunity>) mapOldItems);
    }

    /**
     * Override method to perform action before a delete operation was fired.
     * @see TriggerController#runBeforeDelete
     */
    protected override void runBeforeDelete() { }
    
    /**
     * Override method to perform action before an insert operation was fired.
     * @see TriggerController#runBeforeInsert
     */
    protected override void runBeforeInsert() { }

    /**
     * Override method to perform action before an update operation was fired.
     * @see TriggerController#runBeforeUpdate
     */
    protected override void runBeforeUpdate() { }
        
    /**
     * Check the opportunities and update them if required.
     *
     * @param   lstNewOpportunities A list of Opportunity to check.
     * @param   mapOldOpportunities A map contains Opportunity with old value for comparison. Key is Id of Opportunity, value is Opportunity.
     */
    private void checkOpportunity(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        // Specification:
        //   Übernahme von "Amount" (Tochter) zu "SomTv_AdfactoryAnteilAbsolut__c" (Mutter) in Abhängigkeit von Datensatztypen.
        //   Eine Opp vom Typ "Opp AdFactory" kann MutterOpp haben vom Datensatztyp "Opp Commitment (TV)" oder "Opp Paket (TV)" oder "Opp Zubuchung (TV)".
        //   Wenn Mutter vorhanden, dann schreibe "Amount" nach "SomTv_AdfactoryAnteilAbsolut__c".
        //   Wenn Anzahl Töchter > 1, dann summiere alle "Amount" und schreibe nach "SomTv_AdfactoryAnteilAbsolut__c".

        Map<Id, RecordType> mChildRecordType = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN :CHILDRENRECORDTYPE]);
        Map<Id, RecordType> mParentRecordType = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN :PARENTRECORDTYPE]);

        Set<Id> parentIds = new Set<Id>();      
        for (Opportunity opp : lstNewOpportunities) {
            if (mChildRecordType.containsKey(opp.RecordTypeId) && 
                (mapOldOpportunities == null || (mapOldOpportunities.containsKey(opp.Id) && (mapOldOpportunities.get(opp.Id).Amount != opp.Amount || mapOldOpportunities.get(opp.Id).SomTv_MutterOpportunity__c != opp.SomTv_MutterOpportunity__c)))
               )
            {
                // It is a "Tochter Opportunity", and "Amount" or "Mutter" is changed.
                parentIds.add(opp.SomTv_MutterOpportunity__c);
                try {
                    parentIds.add(mapOldOpportunities.get(opp.Id).SomTv_MutterOpportunity__c);
                } catch (Exception e) {
                }
            }
        }
        
        parentIds.remove(null);
                
        if (!parentIds.isEmpty()) {
            List<Opportunity> oppToUpdate = new List<Opportunity>();
            for (List<Opportunity> opps : [SELECT Id, SomTv_AdfactoryAnteilAbsolut__c, (SELECT Id, Amount FROM Opportunities__r WHERE isDeleted = false AND RecordTypeId IN :mChildRecordType.keySet()) FROM Opportunity WHERE Id IN :parentIds AND isDeleted = false AND RecordTypeId IN :mParentRecordType.keySet()]) {
                for (Opportunity opp : opps) {
                    Decimal amount = 0.0;
                    for (Opportunity child : opp.Opportunities__r) {
                        amount += (child.Amount == null ? 0.0 : child.Amount);
                    }
                    if (amount == 0.0 && opp.SomTv_AdfactoryAnteilAbsolut__c == null) {
                        // For compatible reason, do nothing.
                    } else if (opp.SomTv_AdfactoryAnteilAbsolut__c != amount) {
                        opp.SomTv_AdfactoryAnteilAbsolut__c = amount;
                        oppToUpdate.add(opp);   
                    }
                }
            }
            if (!oppToUpdate.isEmpty()) {
                update oppToUpdate;
            }
        }
    }

    /**
     * Copy data to OpportunityLineItem.
     *
     * @param   lstNewOpportunities A list of Opportunity to check.
     * @param   mapOldOpportunities A map contains Opportunity with old value for comparison. Key is Id of Opportunity, value is Opportunity.
     */
    private void copyDataToOpportunityLineItems(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        // Only perform this aktion for after update events.
        if (isAfter && isUpdate) {
            Map<Id, Opportunity> mOpps = new Map<Id, Opportunity>();
            
            for (Opportunity opp : lstNewOpportunities) {
                if (mapOldOpportunities != null && mapOldOpportunities.containsKey(opp.Id) &&
                    opp.SomTv_AdFProjekt__c != mapOldOpportunities.get(opp.Id).SomTv_AdFProjekt__c)
                {
                    mOpps.put(opp.Id, opp);
                }
            }
            
            if (!mOpps.isEmpty()) {
                for (List<OpportunityLineItem> olis : [SELECT Id, OpportunityId, SomTv_Projektname__c FROM OpportunityLineItem WHERE OpportunityId IN :mOpps.keySet()]) {
                    for (OpportunityLineItem oli : olis) {
                        oli.SomTv_Projektname__c = mOpps.get(oli.OpportunityId).SomTv_AdFProjekt__c;
                    }
                    update olis;
                }
            }
        }
    }

    /**
     * Check the opportunities and create snapshots of lineitems if required.
     *
     * @param   lstNewOpportunities A list of Opportunity to check.
     * @param   mapOldOpportunities A map contains Opportunity with old value for comparison. Key is Id of Opportunity, value is Opportunity.
     */
    private void createSnapshotOfLineItems(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        // Only perform this aktion for after update events.
        if (isAfter && isUpdate) {
            Map<Id, RecordType> mRecordType = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'SomTv_AdFactory']);

            Set<Id> oppIds = new Set<Id>();
            
            for (Opportunity opp : lstNewOpportunities) {
                if (mapOldOpportunities != null && mapOldOpportunities.containsKey(opp.Id) && mRecordType.containsKey(opp.RecordTypeId) &&
                    (/*('Angebot abgegeben'.equals(opp.StageName) && opp.StageName != mapOldOpportunities.get(opp.Id).StageName) || */
                     ('Geschlossene und gewonnene'.equals(opp.StageName) && opp.StageName != mapOldOpportunities.get(opp.Id).StageName)))
                {
                    oppIds.add(opp.Id);
                }
            }
            
            /* Snapshot-Objekt nicht in SomTvTest, daher diesen Part auskommentiert
            if (!oppIds.isEmpty()) {
                List<SomTv_OliSnapshot__c> lstSnapshots = new List<SomTv_OliSnapshot__c>();
                                
                for (List<OpportunityLineItem> olis : [SELECT Id, OpportunityId, Opportunity.Name, OpportunityLineItem.PricebookEntry.Product2Id, OpportunityLineItem.PricebookEntry.Product2.Name, BR__c, SomTv_NrProzent__c, UnitPrice, Sonder_NR__c, SomTv_Projektname__c, SomTv_Projektname__r.Name FROM OpportunityLineItem WHERE OpportunityId IN :oppIds]) {
                    for (OpportunityLineItem oli : olis) {
                        lstSnapshots.add(new SomTv_OliSnapshot__c(SomTv_SSOpportunityName__c = oli.Opportunity.Name,
                                                                  SomTv_SSBR__c = oli.BR__c,
                                                                  SomTv_SSNrProzent__c = oli.SomTv_NrProzent__c,
                                                                  SomTv_SSVerkaufspreis__c = oli.UnitPrice,
                                                                  SomTv_SSSonderNR__c = oli.Sonder_NR__c,
                                                                  SomTv_SSProdukt__c = oli.PricebookEntry.Product2.Name,
                                                                  SomTv_SSProjektname__c = oli.SomTv_Projektname__r.Name));
                    }
                }
                
                if (!lstSnapshots.isEmpty()) {
                    insert lstSnapshots;
                }               
            }
            */
        }
    }
    
  /**
   * Update SomTv_OpportunitiesMN3Gesamt__c etc. in Campaign if required.
   *
     * @param   lstNewOpportunities A list of Opportunity to check.
     * @param   mapOldOpportunities A map contains Opportunity with old value for comparison. Key is Id of Opportunity, value is Opportunity.
   */
  private void updateCampaignMN3(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
    // Update data only for after events.
    if (isAfter) {      
      if (lstNewOpportunities != null) {
        Set<Id> campaignIds = new Set<Id>();
  
        for (Opportunity opp : lstNewOpportunities) {
          if (mapOldOpportunities == null) {
            // Should be inserted, deleted, undeleted
            campaignIds.add(opp.CampaignId);
          } else {
            Opportunity oldOpp = mapOldOpportunities.get(opp.Id);
            if (oldOpp == null ||
              opp.SomTv_MN3__c != oldOpp.SomTv_MN3__c ||
              opp.Probability != oldOpp.Probability ||
              opp.StageName != oldOpp.StageName ||
              opp.CampaignId != oldOpp.CampaignId)
            {
              // Conditions for data updating in Opportunity changed.
              campaignIds.add(opp.CampaignId);
              if (oldOpp != null) {
                campaignIds.add(oldOpp.CampaignId);
              }    
            }
          }
        }
        
        cls_SomTv_Campaign.updateMN3OfCampaignByIds(campaignIds);
      }
    }
    
    return;
  }

    /**
     * Sum the SomTv_MN3__c of all Olis of given Opportunities with RecordType 'SomTv_AdFactory',
     * update then SomTv_MN3__c of Opportunities respectively.
     *
     * @param oppIds  Id of Opportiniteis to check.
     */    
    public static void updateMN3OfOpportinityByIds(Set<Id> oppIds) {
      if (oppIds != null) {
      oppIds.remove(null);
      
      if (!oppIds.isEmpty()) {
          for (List<Opportunity> opps :  [SELECT Id, SomTv_MN3__c, (SELECT SomTv_MN3__c FROM OpportunityLineItems WHERE IsDeleted=false)
                        FROM Opportunity
                        WHERE Id IN :oppIds AND RecordType.DeveloperName='SomTv_AdFactory'])
        {
          for (Opportunity opp : opps) {
            opp.SomTv_MN3__c = 0;
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
              opp.SomTv_MN3__c += (oli.SomTV_MN3__c == null ? 0 : oli.SomTV_MN3__c);
            }
          }
          update opps;
        }
      }
    }
    }
}