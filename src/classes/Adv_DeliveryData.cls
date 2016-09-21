public class Adv_DeliveryData extends TriggerController {

    // Constructor
    public Adv_DeliveryData(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    protected override void runAfterInsert() {
        deleteTechnicalDeliveryData((List<ADvendio__DeliveryData__c>) lstNewItems, NULL);
    }
    
    private void deleteTechnicalDeliveryData(List<ADvendio__DeliveryData__c> ddList, Map<Id, ADvendio__DeliveryData__c> oldMapDD) {
        
        List<Id> technicalDDs	= new List<Id>();
        for (ADvendio__DeliveryData__c dd : [SELECT Id FROM ADvendio__DeliveryData__c WHERE Id IN :ddList AND ADvendio__AdServerID__r.SomDig_KeineLieferzahlen__c = TRUE]) {
        	technicalDDs.add(dd.Id);
        }

        if (!technicalDDs.isEmpty()) {
            deleteDeliveryData(technicalDDs);
        }
    }
    
    @future
    static void deleteDeliveryData(List<Id> deliveryDataIds) {
        delete [SELECT Id FROM ADvendio__DeliveryData__c WHERE Id IN :deliveryDataIds];
    }
}