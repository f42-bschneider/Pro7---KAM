/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_AccountAccess
* @author:      BS factory42
* @email:       bschneider@factory42.com
* @version:     V0.1
* @date:        2015/11/09
* @last change:
* @description: Remove AccountTeam members and AccountShare and set new ones
* @objects:     P7S1_AccountAccess__c
* =================================================================
*/
trigger P7S1_AccountAccess on P7S1_AccountAccess__c (before insert, after insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        P7S1_AccountAccess_SetFields.setOwnerAndIndexOrAccount(Trigger.new);
    }

    /**********************
    * Call helper and do the magic
    ***/
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
            P7S1_AccountSetTeamAndShare.filterRecords(trigger.new);
            P7S1_Account_SetSalesFields.getAccIdsFromAccountAccess(Trigger.new);
        }
    }

}