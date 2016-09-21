global with sharing class Adv_CampaignItem_NightlyUpdate implements Database.Batchable<sObject>, Schedulable {

    global final String i_sQuery;

    global Adv_CampaignItem_NightlyUpdate() {
        i_sQuery = 'SELECT Id, SomDig_PositionStatus__c, ADvendio__Media_Campaign__c, ADvendio__until_Date__c, ADvendio__from_Date__c ' +
                   'FROM ADvendio__Campaign_Item__c ' +
                   'WHERE ADvendio__from_Date__c <= TODAY AND ADvendio__until_Date__c >= TODAY ';
    }
    global Adv_CampaignItem_NightlyUpdate(String p_sQuery) {
        i_sQuery = p_sQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext p_BC) {
        return Database.getQueryLocator(i_sQuery);
    }

    /*
        Description:
        The execute method is called for each batch of records passed to the method.
        Use this method to do all required processing for each chunk of data.
        This method takes the following:
        A reference to the Database.BatchableContext object.
        A list of sObjects, such as List<sObject>, or a list of parameterized types.
        If you are using a Database.QueryLocator, the returned list should be used.
    */
    global void execute(Database.BatchableContext BC,List<sObject> p_scope) {
        List<ADvendio__Campaign_Item__c> l_oListUpdateLineItem = new List<ADvendio__Campaign_Item__c>();
        /*      1. type casting from Sobject to Campaign Line Items
         *      2. preapare the List of Campaign Items
         *      3. do the dummy update so its intiate the trigger
         */
        for (sObject sobj:p_scope) {
            ADvendio__Campaign_Item__c l_oLinitem = (ADvendio__Campaign_Item__c)Sobj;
            l_oListUpdateLineItem.add(l_oLinitem);
        }

        if (l_oListUpdateLineItem!=null && l_oListUpdateLineItem.size()>0) update l_oListUpdateLineItem;
    }

    global void finish(Database.BatchableContext p_BC) {
    }

    global void execute(SchedulableContext p_sc) {
        Database.executeBatch(new Adv_CampaignItem_NightlyUpdate(), 5);
    }

}