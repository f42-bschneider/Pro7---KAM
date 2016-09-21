/**
 * A template controller class for trigger.
 *
 * @author  Benhui.Chen@avendio.de
 * @version 1.0
 */
public virtual with sharing class TriggerController {

    /** Flag, whether an "After" trigger-event for an operation was fired. */
    protected Boolean isAfter = false;
    
    /** Flag, whether a "Before" trigger-event for an operation was fired. */
    protected Boolean isBefore = false;
    
    /** Flag, whether a "Delete" trigger-operation was fired. */
    protected Boolean isDelete = false;
    
    /** Flag, whether an "Insert" trigger-operation was fired. */
    protected Boolean isInsert = false;

    /** Flag, whether an "Undelete" trigger-operation was fired. */
    protected Boolean isUndelete = false;
    
    /** Flag, whether an "Update" trigger-operation was fired. */
    protected Boolean isUpdate = false;

    /** A list of the new versions of the sObject records. */
    protected List<sObject> lstNewItems = null;
    
    /** A map of IDs to the new versions of the sObject records.
     *  Note: This map is only available in Event/Operation: before update, after insert, and after update.
     */
    protected Map<Id, sObject> mapNewItems = null;
    
    /** A list of the old versions of the sObject records.
     *  Note: This list is only available in Event: update and delete.
     */
    protected List<sObject> lstOldItems = null;

    /** A map of IDs to the old versions of the sObject records.
     *  Note: This map is only available in Event: update and delete.
     */
    protected Map<Id, sObject> mapOldItems = null;

    /**
     * The constructor.
     */
    public TriggerController() { }
     
    /**
     * The constructor.
     * @param   isAfter     Flag, whether the trigger was fired after all records were saved.
     * @param   isBefore    Flag, whether the trigger was fired before any record was saved.
     * @param   isDelete    Flag, whether the trigger was fired due to a delete operation.
     * @param   isInsert    Flag, whether the trigger was fired due to an insert operation.
     * @param   isUndelete  Flag, whether the trigger was fired after an undelete operation.
     * @param   isUpdate    Flag, whether the trigger was fired due to a delete operation.
     * @param   lstNewItems A list of the new versions of the sObject records.
     *                      Note that this sObject list is only available in insert and update triggers,
     *                      and the records can only be modified in before triggers.
     * @param   mapNewItems A map of IDs to the new versions of the sObject records.
     *                      Note that this map is only available in before update, after insert, and after update triggers.
     * @param   lstOldItems A list of the old versions of the sObject records.
     *                      Note that this sObject list is only available in update and delete triggers.
     * @param   mapOldItems A map of IDs to the old versions of the sObject records.
     *                      Note that this map is only available in update and delete triggers.
     */
    public TriggerController(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                             List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        this.isAfter        = isAfter;
        this.isBefore       = isBefore;
        this.isDelete       = isDelete;
        this.isInsert       = isInsert;
        this.isUndelete     = isUndelete;
        this.isUpdate       = isUpdate;
        this.lstNewItems    = lstNewItems;
        this.mapNewItems    = mapNewItems;
        this.lstOldItems    = lstOldItems;
        this.mapOldItems    = mapOldItems;
    }
    
    /**
     * Run the trigger controller.
     *
     * Note:
     * According to SF trigger bahaviour, at same time:
     *  - an event can only be either "Before" or "After", never both together.
     *  - an operation can only be one of "Delete", "Insert", "Undelete" and "Update", never two or more opearations together.
     *
     * Thus, this method will perform action in the order of:
     *  1. "before delete" action, if "Before" event and "Delete" operation are true. Otherwise,  
     *  2. "before insert" action, if "Before" event and "Insert" operation are true. Otherwise, 
     *  3. "before undelete" action, if "Before" event and "Undelete" operation true set. Otherwise, 
     *  4. "before update" action, if "Before" event and "Update" operation are true. Otherwise,  
     *  5. "after delete" action, if "After" event and "Delete" operation are true. Otherwise,  
     *  6. "after insert" action, if "After" event and "Insert" operation are true. Otherwise, 
     *  7. "after undelete" action, if "After" event and "Undelete" operation true set. Otherwise, 
     *  8. "after update" action, if "After" event and "Update" operation are true. Otherwise,
     *  9: nothing  
     */
    public void run() {
        if (isBefore) {
            if (isDelete) {
                runBeforeDelete();
            } else if (isInsert) {
                runBeforeInsert();
            } else if (isUndelete) {
                runBeforeUndelete();
            } else if (isUpdate) {
                runBeforeUpdate();
            }
        }       
        else if (isAfter) {
            if (isDelete) {
                runAfterDelete();
            } else if (isInsert) {
                runAfterInsert();
            } else if (isUndelete) {
                runAfterUndelete();
            } else if (isUpdate) {
                runAfterUpdate();
            }
        }
    }
    
    /**
     * A virtual method to perform action after a delete operation was fired.
     */
    protected virtual void runAfterDelete() { }
    
    /**
     * A virtual method to perform action after an insert operation was fired.
     */
    protected virtual void runAfterInsert() { }

    /**
     * A virtual method to perform action after an undelete operation was fired.
     */
    protected virtual void runAfterUndelete() { }

    /**
     * A virtual method to perform action after an update operation was fired.
     */
    protected virtual void runAfterUpdate() { }

    /**
     * A virtual method to perform action before a delete operation was fired.
     */
    protected virtual void runBeforeDelete() { }
    
    /**
     * A virtual method to perform action before an insert operation was fired.
     */
    protected virtual void runBeforeInsert() { }

    /**
     * A virtual method to perform action before an undelete operation was fired.
     */
    protected virtual void runBeforeUndelete() { }

    /**
     * A virtual method to perform action before an update operation was fired.
     */
    protected virtual void runBeforeUpdate() { }
        
    /**
     * A Test Methode.
     */
    public static testmethod void testTriggerController(){
        Profile p = [Select Id From Profile Where Name='System Administrator' or Name='Systemadministrator' Limit 1];
        User    u = new User(Username='testTriggerController@test.com', LastName='testTriggerController', 
                             Email='testTriggerController@test.com', Alias='test', CommunityNickname='testTriggerController',
                             TimeZoneSidKey='Europe/Berlin', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                             P7S1_Sphere__c = 'SomDe'   ,  
                             ProfileId=p.Id, LanguageLocaleKey='en_US');

        insert u;

        System.runAs(u) {
            TriggerController c = new TriggerController();
            
            c = new TriggerController(true, false, true, false, false, false, null, null, null, null);
            c.run();

            c = new TriggerController(true, false, false, true, false, false, null, null, null, null);
            c.run();

            c = new TriggerController(true, false, false, false, true, false, null, null, null, null);
            c.run();

            c = new TriggerController(true, false, false, false, false, true, null, null, null, null);
            c.run();

            c = new TriggerController(false, true, true, false, false, false, null, null, null, null);
            c.run();

            c = new TriggerController(false, true, false, true, false, false, null, null, null, null);
            c.run();

            c = new TriggerController(false, true, false, false, true, false, null, null, null, null);
            c.run();

            c = new TriggerController(false, true, false, false, false, true, null, null, null, null);
            c.run();
        }
    }
}