/**
 *  The trigger controller class for sObject Contact.
 */
public with sharing class P7S1_Contact_Sphere extends TriggerController {
    /**
     * Constructor.
     * @see TriggerController   The base class of trigger controller.
     */
  public P7S1_Contact_Sphere(Boolean isAfter, Boolean isBefore,
    Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
    List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
  {
    super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
  }
  
  
  protected override void runBeforeUpdate() {    
      copyFields(lstNewItems);   
  }


  protected override void runBeforeInsert() {
      copyFields(lstNewItems);
  }  
  
  
  public static void copyFields(List<sObject> lstNewItems){ 
      for(sObject o : lstNewItems)
          o.put('P7S1_SphereCopy__c', o.get('P7S1_Sphere__c'));
  }
}