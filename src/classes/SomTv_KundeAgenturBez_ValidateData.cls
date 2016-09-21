/**
 *  The trigger controller class for sObject SomTV_KundeAgenturBeziehung__c.
 *  @author stefan.voss@advendio.com
 */
public without sharing class SomTv_KundeAgenturBez_ValidateData extends TriggerController {

  /** 
   * Constructor.
   * @see TriggerController   The base class of trigger controller.
   */
  public SomTv_KundeAgenturBez_ValidateData (Boolean isAfter, Boolean isBefore,
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
    validateData((List<SomTV_KundeAgenturBeziehung__c>)lstNewItems);
  }

  /**
   * Override method to perform action before an update operation was fired.
   * @see TriggerController#runBeforeUpdate
   */
  protected override void runBeforeUpdate() {
    validateData((List<SomTV_KundeAgenturBeziehung__c>)lstNewItems);
  }

  /**
   * Override method to perform action after an undelete operation was fired.
   * @see TriggerController#runAfterUndelete
   */
  protected override void runAfterUndelete() {
    validateData((List<SomTV_KundeAgenturBeziehung__c>)lstNewItems);
  }

  private static final string VALIDATION_DUPLICATE_KABEZ_IN_LIST  = 'Kunde-Agentur-Beziehung gibt es bereits';
  private static final string VALIDATION_DUPLICATE_KABEZ_IN_SF  = 'Kunde-Agentur-Beziehung gibt es bereits';
  
  private void validateData(List<SomTV_KundeAgenturBeziehung__c> newkaBezs) {
    Map<String, String> errorMap  = new Map<String, String>();
    Map<Id, List<SomTV_KundeAgenturBeziehung__c>> kaBezByKundeId  = new Map<Id, List<SomTV_KundeAgenturBeziehung__c>>();
    String key  = '';
    
    for (SomTV_KundeAgenturBeziehung__c kaBez : newkaBezs) {
      if (!kaBezByKundeId.containsKey(kaBez.Kunde__c)) {
        kaBezByKundeId.put(kaBez.Kunde__c, new List<SomTV_KundeAgenturBeziehung__c>());
      }
      Boolean error = false;
      key  = kaBez.Kunde__c + '|' + kaBez.Agentur__c + '|' + kaBez.GueltigVon__c;
      
      for (SomTV_KundeAgenturBeziehung__c tmpKaBez : kaBezByKundeId.get(kaBez.Kunde__c)) {
        system.debug(tmpKaBez);
        system.debug(kaBez);
        
        if (tmpKaBez.Agentur__c == kaBez.Agentur__c &&
          (tmpKaBez.GueltigVon__c <= kaBez.GueltigBis__c || kaBez.GueltigBis__c == null) &&
          (tmpKaBez.GueltigBis__c >= kaBez.GueltigVon__c || tmpKaBez.GueltigBis__c == null)) {

          errorMap.put(key, VALIDATION_DUPLICATE_KABEZ_IN_LIST);
          break;
        }
      }
      
      system.debug(key);
      system.debug(errorMap);
      if (!errorMap.containsKey(key)) {
        kaBezByKundeId.get(kaBez.Kunde__c).add(kaBez);
      }
    }

    system.debug('errorMap: ' + errorMap);

    for (SomTV_KundeAgenturBeziehung__c kaBez : [select Id, Agentur__c, Kunde__c , GueltigVon__c, GueltigBis__c from SomTV_KundeAgenturBeziehung__c where Kunde__c IN :kaBezByKundeId.keySet()]) {
      for (SomTV_KundeAgenturBeziehung__c tmpKaBez : kaBezByKundeId.get(kaBez.Kunde__c)) {
      
      
        if (tmpKaBez.Agentur__c == kaBez.Agentur__c &&
          (tmpKaBez.GueltigVon__c <= kaBez.GueltigBis__c || kaBez.GueltigBis__c == null) &&
          (tmpKaBez.GueltigBis__c >= kaBez.GueltigVon__c || tmpKaBez.GueltigBis__c == null) &&
          tmpKaBez.Id != kaBez.Id) {
          
          key  = tmpKaBez.Kunde__c + '|' + tmpKaBez.Agentur__c + '|' + tmpKaBez.GueltigVon__c;
          
          errorMap.put(key, VALIDATION_DUPLICATE_KABEZ_IN_SF);
        }
      }
    }
    
    for (SomTV_KundeAgenturBeziehung__c kaBez : newkaBezs) {
      
      key  = kaBez.Kunde__c + '|' + kaBez.Agentur__c + '|' + kaBez.GueltigVon__c;
      
      if (errorMap.containsKey(key)) {
        kaBez.addError(errorMap.get(key));
      }
    }
  }
  
}