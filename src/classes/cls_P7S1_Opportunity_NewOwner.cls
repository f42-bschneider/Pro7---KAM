public with sharing class cls_P7S1_Opportunity_NewOwner extends TriggerController {


	public cls_P7S1_Opportunity_NewOwner(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
		List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
	{
		super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
	}

	// before Update
	protected override void runBeforeUpdate() {
		SetNewOwner((List<Opportunity>) lstNewItems, (Map<Id, Opportunity>) mapOldItems);
	}

	private void SetNewOwner(List<Opportunity> p_oListNew, Map<Id, Opportunity> p_oMapOld) {
		for (Opportunity l_oNewOpp : p_oListNew) {

			if (l_oNewOpp.P7S1_NewOwner__c != null) {
				l_oNewOpp.Ownerid = l_oNewOpp.P7S1_NewOwner__c;
				l_oNewOpp.P7S1_NewOwner__c = null;
			}
			l_oNewOpp.P7S1_OldOwnerEmail__c = l_oNewOpp.P7S1_CurrentOwnerEmail__c;
		}
	}
}