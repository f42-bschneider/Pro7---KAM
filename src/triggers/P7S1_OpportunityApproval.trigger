/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_OpportunityApproval
* @author:		BS factory42
* @email:		bschneider@factory42.com
* @version:		V0.1
* @date:		Nov 25, 2015
* @last change:	
* @description:	Set sales fields on Account depending on Account-TeamMemberRoles
* @objects:		Account, P7S1_OpportunityApproval__c
* =================================================================
*/
trigger P7S1_OpportunityApproval on P7S1_OpportunityApproval__c (after update) {
	
	if(Trigger.isAfter){
		if(Trigger.isUpdate){
			P7S1_Account_SetSalesFields.getAccIdsFromOpportunityApproval(Trigger.new);
		}
	}
    
}