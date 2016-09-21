@isTest
public class Adv_DeliveryData_Test {
    @isTest (seeAllData=false)
    public static void testDeleteTecnicalDeliveryData() {
     //   cls_P7S1_TestData.createTestCampaignItem(true, new advendio__ad_price__c(id='a0O25000004DBlA'));
		ADvendio__Campaign_Item__c ci		= cls_P7S1_TestData.createTestCampaignItem(true);
        ADvendio__Adserver_Id__c techAsi	= cls_P7S1_TestData.createTestAdServerID(false);
        techAsi.SomDig_KeineLieferzahlen__c = true;
        ADvendio__Adserver_Id__c asi		= cls_P7S1_TestData.createTestAdServerID(false);
        asi.SomDig_KeineLieferzahlen__c 	= false;
        insert new List<ADvendio__Adserver_Id__c>{techAsi, asi};

        ADvendio__DeliveryData__c dd1		= new ADvendio__DeliveryData__c(
            									ADvendio__AdServerID__c		= asi.Id,
            									ADvendio__CampaignItem__c	= ci.Id,
            									ADvendio__Day__c			= ci.ADvendio__from_Date__c,
            									ADvendio__Type__c			= 'monthly'
        									);
        ADvendio__DeliveryData__c dd2		= new ADvendio__DeliveryData__c(
            									ADvendio__AdServerID__c		= techAsi.Id,
            									ADvendio__CampaignItem__c	= ci.Id,
            									ADvendio__Day__c			= ci.ADvendio__from_Date__c,
            									ADvendio__Type__c			= 'monthly'
        									);
        insert new List<ADvendio__DeliveryData__c>{dd1, dd2}; // dd2 will be deleted - this happens asynchronous and can not be tested here
    }
}