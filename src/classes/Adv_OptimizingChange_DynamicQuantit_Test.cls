@isTest
public with sharing class Adv_OptimizingChange_DynamicQuantit_Test {
    static testMethod void testdynamicQuantity() {
    	
    	ADvendio__Placement__c placement = cls_P7S1_TestData.createTestPlacement(false);
    	placement.SomDig_Typ__c='YouTube';
    	insert placement;
    	
        // Create 3 ad specs
        List<ADvendio__Ad_Specs__c> lstAdS = new List<ADvendio__Ad_Specs__c>();
        for(Integer i=0;i<3;i++){
            lstAdS.add(cls_P7S1_TestData.createTestAdSpec(false, placement));
        }
        lstAdS[0].ADvendio__Distribution__c = 'Prorated';
        insert lstAdS;

        // Create 3 ad price
        List<ADvendio__Ad_price__c> lstAdPrice = new List<ADvendio__Ad_price__c>();
        for (Integer i=0;i<3;i++){
            lstAdPrice.add(cls_P7S1_TestData.createTestAdPrice(false, lstAdS[i]));
        }
        insert lstAdPrice;

        ADvendio__MediaCampaign__c mc = cls_P7S1_TestData.createTestMediaCampaign(true);
        ADvendio__Campaign_Item__c adCP = cls_P7S1_TestData.createTestCampaignItem(false, mc, lstAdPrice[0]);
        adCP.ADvendio__Quantity__c = 200;
        adCP.ADvendio__Sales_Price__c = 100;
        insert adCP;

        // Create 2 component items
        List<ADvendio__Campaign_Item__c> lstComponents = new List<ADvendio__Campaign_Item__c>();
        ADvendio__Campaign_Item__c ci01 = cls_P7S1_TestData.createTestCampaignItem(false, mc, lstAdPrice[1]);
        ci01.ADvendio__PacketItem__c = adCP.Id;
        ci01.ADvendio__Quantity__c = 50;
        ADvendio__Campaign_Item__c ci02 = cls_P7S1_TestData.createTestCampaignItem(false, mc, lstAdPrice[2]);
        ci02.ADvendio__PacketItem__c = adCP.Id;
        ci02.ADvendio__Quantity__c = 150;
        lstComponents.add(ci01);
        lstComponents.add(ci02);
        insert lstComponents;

		ADvendio__OptimizingVersion__c version = new ADvendio__OptimizingVersion__c(ADvendio__MediaCampaign__c=mc.Id);
		insert version;
		
        
        Test.startTest();

		ADvendio__OptimizingChange__c change10 = new ADvendio__OptimizingChange__c(ADvendio__CampaignItem__c=ci01.Id, ADvendio__OptimizingVersion__c = version.Id,
				ADvendio__FieldName__c='ADvendio__LastAvailabilityForecast__c',ADvendio__OptimizedValue__c=String.valueOf(DateTime.now().addMinutes(-5)));
		ADvendio__OptimizingChange__c change11 = new ADvendio__OptimizingChange__c(ADvendio__CampaignItem__c=ci01.Id, ADvendio__OptimizingVersion__c = version.Id,
				ADvendio__FieldName__c='ADvendio__Availability__c',ADvendio__OptimizedValue__c='150');
		ADvendio__OptimizingChange__c change20 = new ADvendio__OptimizingChange__c(ADvendio__CampaignItem__c=ci02.Id, ADvendio__OptimizingVersion__c = version.Id,
				ADvendio__FieldName__c='ADvendio__LastAvailabilityForecast__c',ADvendio__OptimizedValue__c=String.valueOf(DateTime.now().addMinutes(-5)));
		ADvendio__OptimizingChange__c change21 = new ADvendio__OptimizingChange__c(ADvendio__CampaignItem__c=ci02.Id, ADvendio__OptimizingVersion__c = version.Id,
				ADvendio__FieldName__c='ADvendio__Availability__c',ADvendio__OptimizedValue__c='50');
        insert new List<ADvendio__OptimizingChange__c>{change10, change11, change20, change21};

		List<ADvendio__OptimizingChange__c> changes = [SELECT Id, ADvendio__OptimizedValue__c, ADvendio__CampaignItem__c, ADvendio__FieldName__c FROM ADvendio__OptimizingChange__c 
				WHERE ADvendio__OptimizingVersion__c = :version.Id AND ADvendio__FieldName__c IN ('ADvendio__Quantity__c', 'ADvendio__Prorated__c')];
        System.assertEquals(4, changes.size());
        for (ADvendio__OptimizingChange__c change : changes) {
	        if ('ADvendio__Quantity__c'.equals(change.ADvendio__FieldName__c) && change.ADvendio__CampaignItem__c==ci01.Id) {
	        	System.assertEquals('150', change.ADvendio__OptimizedValue__c);
	        } else if ('ADvendio__Prorated__c'.equals(change.ADvendio__FieldName__c) && change.ADvendio__CampaignItem__c==ci01.Id) {
	        	System.assertEquals('75', change.ADvendio__OptimizedValue__c);
	        } else if ('ADvendio__Quantity__c'.equals(change.ADvendio__FieldName__c) && change.ADvendio__CampaignItem__c==ci02.Id) {
		        System.assertEquals('50', change.ADvendio__OptimizedValue__c);
	        } else if ('ADvendio__Prorated__c'.equals(change.ADvendio__FieldName__c) && change.ADvendio__CampaignItem__c==ci02.Id) {
		        System.assertEquals('25', change.ADvendio__OptimizedValue__c);
	        } else {
	        	System.assert(false, 'some other change? cannot be');
	        }
        }

		ci01.ADvendio__Delivered_Impressions__c = 70;
		ci02.ADvendio__Delivered_Impressions__c = 80;
		update new List<ADvendio__Campaign_Item__c>{ci01, ci02};
		
        change10.ADvendio__OptimizedValue__c = String.valueOf(System.now().addMinutes(-3));
        change11.ADvendio__OptimizedValue__c = '8000';
        change20.ADvendio__OptimizedValue__c = String.valueOf(System.now().addMinutes(-3));
        change21.ADvendio__OptimizedValue__c = '2000';
        update new List<ADvendio__OptimizingChange__c>{change10, change11, change20, change21};


		changes = [SELECT Id, ADvendio__OptimizedValue__c, ADvendio__CampaignItem__c, ADvendio__FieldName__c FROM ADvendio__OptimizingChange__c 
				WHERE ADvendio__OptimizingVersion__c = :version.Id AND ADvendio__FieldName__c IN ('ADvendio__Quantity__c', 'ADvendio__Prorated__c')];
        System.assertEquals(4, changes.size());
        for (ADvendio__OptimizingChange__c change : changes) {
	        if ('ADvendio__Quantity__c'.equals(change.ADvendio__FieldName__c) && change.ADvendio__CampaignItem__c==ci01.Id) {
	        	System.assertEquals('120', change.ADvendio__OptimizedValue__c);
	        } else if ('ADvendio__Prorated__c'.equals(change.ADvendio__FieldName__c) && change.ADvendio__CampaignItem__c==ci01.Id) {
	        	System.assertEquals(60, Decimal.valueOf(change.ADvendio__OptimizedValue__c));
	        } else if ('ADvendio__Quantity__c'.equals(change.ADvendio__FieldName__c) && change.ADvendio__CampaignItem__c==ci02.Id) {
		        System.assertEquals('80', change.ADvendio__OptimizedValue__c);
	        } else if ('ADvendio__Prorated__c'.equals(change.ADvendio__FieldName__c) && change.ADvendio__CampaignItem__c==ci02.Id) {
		        System.assertEquals(40, Decimal.valueOf(change.ADvendio__OptimizedValue__c));
	        } else {
	        	System.assert(false, 'some other change? cannot be');
	        }
        }

        Test.stopTest();
    }
    
}