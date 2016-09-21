@isTest
public class Adv_CampaignItem_Storno_Test {

    static testMethod void testupdateFieldsWithouthDeliveredAIs(){

        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(true);

        ADvendio__Campaign_Item__c objCIPositiv = cls_P7S1_TestData.createTestCampaignItem(false, objMC);
        insert objCIPositiv;


        ADvendio__Campaign_Item__c objCINegativ = cls_P7S1_TestData.createTestCampaignItem(false, objMC);
        objCINegativ.ADvendio__PositionReference__c  = objCIPositiv.ID;
        objCINegativ.ADvendio__Quantity__c = (-1) * objCIPositiv.ADvendio__Quantity__c;
        objCINegativ.ADvendio__OptimizationExclusion__c = 'This is a canceled Campaign Item from a previous optimization.';
        insert objCINegativ;


        Test.startTest();
        objCIPositiv = [SELECT ADvendio__rate_discount_4_name__c, ADvendio__AdserverStatus__c FROM ADvendio__Campaign_Item__c WHERE ID = :objCIPositiv.ID];
        System.assert(objCIPositiv.ADvendio__rate_discount_4_name__c == 'Storno ohne Leistungsfluss');
        System.assert(objCIPositiv.ADvendio__AdserverStatus__c == 'Released');

        objCINegativ = [SELECT ADvendio__rate_discount_4_name__c FROM ADvendio__Campaign_Item__c WHERE ID = :objCINegativ.ID];
        System.assert(objCINegativ.ADvendio__rate_discount_4_name__c == 'Storno ohne Leistungsfluss');

        Test.stopTest();
    }


    static testMethod void testupdateFieldsWithDeliveredAIs(){

        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(true);

        ADvendio__Campaign_Item__c objCIPositiv = cls_P7S1_TestData.createTestCampaignItem(false, objMC);
        insert objCIPositiv;

        ADvendio__Revenue_Schedule__c objRS = createTestRevenueSchedule(true, objCIPositiv);


        ADvendio__Campaign_Item__c objCINegativ = cls_P7S1_TestData.createTestCampaignItem(false, objMC);
        objCINegativ.ADvendio__PositionReference__c  = objCIPositiv.ID;
        objCINegativ.ADvendio__Quantity__c = (-1) * objCIPositiv.ADvendio__Quantity__c;
        objCINegativ.ADvendio__OptimizationExclusion__c = 'This is a canceled Campaign Item from a previous optimization.';
        insert objCINegativ;


        Test.startTest();
        objCIPositiv = [SELECT ADvendio__rate_discount_4_name__c, ADvendio__AdserverStatus__c FROM ADvendio__Campaign_Item__c WHERE ID = :objCIPositiv.ID];
        System.assert(objCIPositiv.ADvendio__rate_discount_4_name__c != 'Storno ohne Leistungsfluss');
        System.assert(objCIPositiv.ADvendio__AdserverStatus__c != 'Released');

        objCINegativ = [SELECT ADvendio__rate_discount_4_name__c FROM ADvendio__Campaign_Item__c WHERE ID = :objCINegativ.ID];
        System.assert(objCINegativ.ADvendio__rate_discount_4_name__c != 'Storno ohne Leistungsfluss');

        Test.stopTest();
    }



    static testMethod void testupdateFieldsNonAdServer(){

        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(true);

        ADvendio__Campaign_Item__c objCIPositiv = cls_P7S1_TestData.createTestCampaignItem(false, objMC);
        insert objCIPositiv;



        // Negative position NonAdserver
        ADvendio__Ad_Type__c objAdType = cls_P7S1_TestData.createTestAdType(false);
        objAdType.RecordTypeId  = Schema.SObjectType.ADvendio__Ad_Type__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        insert objAdType;


        ADvendio__Ad_Specs__c objAdSpec = cls_P7S1_TestData.createTestAdSpec(true, objAdType);
        ADvendio__Ad_price__c objAdPrice =  cls_P7S1_TestData.createTestAdPrice(true, objAdSpec);


        ADvendio__Campaign_Item__c objCINegativ = cls_P7S1_TestData.createTestCampaignItem(false, objMC, objAdPrice);
        objCINegativ.ADvendio__PositionReference__c  = objCIPositiv.ID;
        objCINegativ.ADvendio__Quantity__c = (-1) * objCIPositiv.ADvendio__Quantity__c;
        objCINegativ.ADvendio__from_Date__c = objCINegativ.ADvendio__from_Date__c.addDays(-5);
        objCINegativ.ADvendio__OptimizationExclusion__c = 'This is a canceled Campaign Item from a previous optimization.';
        insert objCINegativ;


        Test.startTest();
        objCIPositiv = [SELECT ADvendio__rate_discount_4_name__c, ADvendio__AdserverStatus__c FROM ADvendio__Campaign_Item__c WHERE ID = :objCIPositiv.ID];
        System.assert(objCIPositiv.ADvendio__rate_discount_4_name__c != 'Storno ohne Leistungsfluss');
        System.assert(objCIPositiv.ADvendio__AdserverStatus__c != 'Released');

        objCINegativ = [SELECT ADvendio__rate_discount_4_name__c FROM ADvendio__Campaign_Item__c WHERE ID = :objCINegativ.ID];
        System.assert(objCINegativ.ADvendio__rate_discount_4_name__c != 'Storno ohne Leistungsfluss');

        Test.stopTest();
    }





    // TODO: move to testclass
    public static ADvendio__Revenue_Schedule__c createTestRevenueSchedule(Boolean insertObject, ADvendio__Campaign_Item__c campaignItem) {
        ADvendio__Revenue_Schedule__c objRS = new ADvendio__Revenue_Schedule__c();
        objRS.ADvendio__Campaign_Item__c = campaignItem.ID;
        objRS.ADvendio__DeliveredAIsManual__c = 1000;
        if (insertObject) insert objRS;
        return objRS;
    }
}