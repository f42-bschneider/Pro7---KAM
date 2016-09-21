@isTest
public with sharing class Adv_CampaignItem_PackageSumDelive_Test {
   static testMethod void testSumPackageDeliveries() {
        // Create a Site
        ADvendio__Site__c adSite = new ADvendio__Site__c(Name = 'Site 1');
        insert adSite;

        // Create a Placement
        List<ADvendio__Placement__c> lstAdP = new List<ADvendio__Placement__c>();
        lstAdP.add(new ADvendio__Placement__c(Name='Placement 1', SomDig_Typ__c='YouTube',ADvendio__Site__c=adSite.Id));
        insert lstAdP;

        // Create 3 ad specs
        List<ADvendio__Ad_Specs__c> lstAdS = new List<ADvendio__Ad_Specs__c>();
        for(Integer i=0;i<3;i++){
            lstAdS.add(new ADvendio__Ad_Specs__c(Name='Ad Spec'+i, ADvendio__Placement__c=lstAdP[0].Id));
        }
        insert lstAdS;

        // Create 3 ad price
        List<ADvendio__Ad_price__c> lstAdPrice = new List<ADvendio__Ad_price__c>();
        for (Integer i=0;i<3;i++){
            lstAdPrice.add(new ADvendio__Ad_price__c(ADvendio__Ad_Spec__c=lstAdS[i].Id, ADvendio__List_price__c=1000));
        }
        insert lstAdPrice;

        ADvendio__MediaCampaign__c adM = cls_P7S1_TestData.createTestMediaCampaign(true);
        ADvendio__Campaign_Item__c ciP = new ADvendio__Campaign_Item__c(ADvendio__Billing_category__c='CPM', ADvendio__Ad_Price__c=lstAdPrice[0].Id, ADvendio__Media_Campaign__c=adM.Id, ADvendio__Quantity__c=20, ADvendio__Sales_Price__c=100, ADvendio__from_Date__c=System.today(), ADvendio__until_Date__c=System.today());
        insert ciP;

        // Create 2 component items
        List<ADvendio__Campaign_Item__c> lstComponents = new List<ADvendio__Campaign_Item__c>();
        ADvendio__Campaign_Item__c ci01 = new ADvendio__Campaign_Item__c(ADvendio__PacketItem__c=ciP.Id, ADvendio__Billing_category__c='CPM', ADvendio__Ad_Price__c=lstAdPrice[1].Id, ADvendio__Media_Campaign__c=adM.Id, ADvendio__Quantity__c=5, ADvendio__Sales_Price__c=100, ADvendio__from_Date__c=System.today(), ADvendio__until_Date__c=System.today());
        ADvendio__Campaign_Item__c ci02 = new ADvendio__Campaign_Item__c(ADvendio__PacketItem__c=ciP.Id, ADvendio__Billing_category__c='CPM', ADvendio__Ad_Price__c=lstAdPrice[2].Id, ADvendio__Media_Campaign__c=adM.Id, ADvendio__Quantity__c=15, ADvendio__Sales_Price__c=100, ADvendio__from_Date__c=System.today(), ADvendio__until_Date__c=System.today());
        insert new List<ADvendio__Campaign_Item__c>{ci01, ci02};

        Test.startTest();

        ci01.ADvendio__Delivered_Impressions__c = 15;
        ci02.ADvendio__Delivered_Impressions__c = 5;

        update new List<ADvendio__Campaign_Item__c>{ci01, ci02};

        ciP = [Select Id, ADvendio__Delivered_Impressions__c From ADvendio__Campaign_Item__c Where Id = :ciP.Id];
        System.assertEquals(20, ciP.ADvendio__Delivered_Impressions__c);

        Test.stopTest();
    }    
}