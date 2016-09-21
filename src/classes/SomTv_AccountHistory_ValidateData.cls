/**
 *  The trigger controller class for sObject AccountHistory__c.
 */

public with sharing class SomTv_AccountHistory_ValidateData extends TriggerController {
  /** 
   * Constructor.
   * @see TriggerController   The base class of trigger controller.
   */
  public SomTv_AccountHistory_ValidateData(Boolean isAfter, Boolean isBefore,
      Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
      List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
  {
    super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
  }

  /**
   * Override method to perform action before an insert operation was fired.
   * @see TriggerController#runBeforeInsert
   */
    protected override void runBeforeInsert() {
      validateData((List<AccountHistory__c>)lstNewItems);
    }
  
  /**
   * Override method to perform action before an update operation was fired.
   * @see TriggerController#runBeforeUpdate
   */
    protected override void runBeforeUpdate() {
      validateData((List<AccountHistory__c>)lstNewItems);
    }

  /**
   * Override method to perform action after an undelete operation was fired.
   * @see TriggerController#runAfterUndelete
   */
    protected override void runAfterUndelete() {
      validateData((List<AccountHistory__c>)lstNewItems);
    }
    
    /**
     * Validate the data, make sure that there is no record  
     *  1) with overlapped GueltigVon__c and GueltigBis__c for same UntergeordneterAccount__c.
     *
     * @param  lstRecords  List of records to validate.
     */
    private void validateData(List<AccountHistory__c> lstRecords) {
      Boolean hasError = false;
      
      // A map to hold temporary data passed from SF in current batch.
      Map<String, List<AccountHistory__c>>  mRecords = new Map<String, List<AccountHistory__c>>();
      
    Set<Id> sIds = new Set<Id>();

      // Check first the records in batch.
      for (AccountHistory__c a : lstRecords) {
      if (a.GueltigVon__c == null) {
          a.GueltigVon__c.addError('Bitte ein Startdatum für die Gültigkeit eingeben!');
          hasError = true;
          break;
      /*} else if (a.GueltigBis__c == null) {
          a.GueltigVon__c.addError('Bitte ein Enddatum für die Gültigkeit eingeben!');
          hasError = true;
          break;
      */} else if (a.GueltigBis__c != null && a.GueltigBis__c < a.GueltigVon__c) {
          a.GueltigBis__c.addError('Das Enddatum muss nach dem Startdatum sein!');
          hasError = true;
          break;
      } /* CR: 2014-04-02, SOTV-28
       else if (a.UebergeordneterAccount__c != null && a.UntergeordneterAccount__c != null && a.UebergeordneterAccount__c == a.UntergeordneterAccount__c) {
          a.UntergeordneterAccount__c.addError('Der übergeordnete und untergeordnete Account dürfen nicht geleich sein!');
          hasError = true;
          break;
      } */  
        
        if (a.UebergeordneterAccount__c != null && a.UntergeordneterAccount__c != null) {
          sIds.add(a.UntergeordneterAccount__c);

          String key = '' + a.UntergeordneterAccount__c;
    
          if (isValidData(a, mRecords, key)) {
            List<AccountHistory__c> records = mRecords.get(key);
              
            if (records == null) {
              records = new List<AccountHistory__c>();
             }
    
             records.add(a);
    
            mRecords.put(key, records);
          } else {
            hasError = true;
            break;
          }
        }
       }

    if (hasError) {
      return;
    }
    
    // Now get all existed records.
    mRecords.clear();
        
      for (List<AccountHistory__c> az : [SELECT Id, UebergeordneterAccount__c, UntergeordneterAccount__c, GueltigVon__c, GueltigBis__c, Som_NrRolleDwh__c
                         FROM AccountHistory__c
                         WHERE isDeleted = false AND (UntergeordneterAccount__c IN :sIds)])
      {
        for (AccountHistory__c a : az) {
          if (a.UebergeordneterAccount__c != null && a.UntergeordneterAccount__c != null) {
            String key = '' + a.UntergeordneterAccount__c;

            List<AccountHistory__c> records = mRecords.get(key);
            
            if (records == null) {
              records = new List<AccountHistory__c>();
            }
            
            records.add(a);  
  
            mRecords.put(key, records);
          }
        }
      }

    // Check record in batch agaignst existed records.
      for (AccountHistory__c a : lstRecords) {
        if (a.UebergeordneterAccount__c != null && a.UntergeordneterAccount__c != null) {
          String key = '' + a.UntergeordneterAccount__c;
  
          if (!isValidData(a, mRecords, key)) {
            break;
          }
        }
       }

    }

    /**
     * Validate the data, make sure that there is no record  
     *  1) with overlapped GueltigVon__c and GueltigBis__c for same UntergeordneterAccount__c.
     *
     * @param  record    Record to validate.
     * @param  mRecords  A map contains all existed Records.
     * @param  key      Key in map to use.
     * @return  True if OK, false otherwise.
     */
    private Boolean isValidData(AccountHistory__c record, Map<String, List<AccountHistory__c>> mRecords, String key) {
      Boolean isOK = true;

      if (!mRecords.isEmpty()) {
        List<AccountHistory__c> records = mRecords.get(key);
        if (records != null) {
          // Need to check whether there is date overlapped.
          for (Integer i = 0; i < records.size(); i++) {
            AccountHistory__c other = records.get(i);
            
            if (record.Id != null && record.Id == other.Id) {
              continue;
            }
            
            /* Illustrated here:
             *      |                           |
             *      |other.GueltigVon__c        |other.GueltigBis__c
              * ----------------------------------------------------------------> Time
             * 
             * (New) Record is valid if its date-range is
             *  1) left out side of other.GueltigVon__c, or
             *  2) right out side of other.GueltigBis__c if other.GueltigBis__c isn't empty (open end).
             */
             
            if (record.GueltigVon__c < other.GueltigVon__c && (record.GueltigBis__c != null && record.GueltigBis__c < other.GueltigVon__c)) {
              // left out side of curGueltigVon
            } else if (other.GueltigBis__c != null && record.GueltigVon__c > other.GueltigBis__c) {
              // right out side of curGueltigBis
            } else {
              // CR: SOTV-28, 2014-04-11: Überlappungsfreiheit nur innerhalb der DWH Rolle.
              if (record.Som_NrRolleDwh__c == other.Som_NrRolleDwh__c) {
                record.GueltigVon__c.addError('Für den untergeordneten Account existiert bereits ein übergeordneter Account im gegebenen Zeitraum. Bitte prüfen Sie Ihre Angaben!');
                isOK = false;
                break;
              }
            }
          }
        }
        
      }
      
      return isOK;
    }
}