/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* Som_KamStrategyProfileTopic
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         25-4-2016
* @description  
* @lastchange  
* @objects      
* =================================================================
*/
trigger Som_KamStrategyProfileTopic on Som_KamStrategyProfileTopic__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    new Som_KamStrategyProfileTopic(
        Trigger.isAfter, Trigger.isBefore, Trigger.isDelete, Trigger.isInsert, Trigger.isUnDelete, Trigger.isUpdate,
        Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap
    ).run();
}