@isTest
private with sharing class Adv_CampaignItem_DynamicQuantity_Test {

	static testMethod void myUnitTest1() {
		
		ADvendio__Placement__c placement	= cls_P7S1_TestData.createTestPlacement(false);
		placement.SomDig_Typ__c				= 'YouTube';
		insert placement;
		
		// Create 3 ad specs
		List<ADvendio__Ad_Specs__c> lstAdS		= new List<ADvendio__Ad_Specs__c>();
		for(Integer i=0;i<3;i++){
			ADvendio__Ad_Specs__c asp = cls_P7S1_TestData.createTestAdSpec(false, placement);
            asp.ADvendio__Distribution__c	= 'Prorated';
            lstAdS.add(asp);
		}
		insert lstAdS;

		// Create 3 ad price
		List<ADvendio__Ad_price__c> lstAdPrice	= new List<ADvendio__Ad_price__c>();
		for (Integer i=0;i<3;i++){
			lstAdPrice.add(cls_P7S1_TestData.createTestAdPrice(false, lstAdS[i]));
		}
		insert lstAdPrice;

		ADvendio__MediaCampaign__c adM	= cls_P7S1_TestData.createTestMediaCampaign(true);
		ADvendio__Campaign_Item__c adCP	= cls_P7S1_TestData.createTestCampaignItem(false, adM, lstAdPrice[0]);
		adCP.ADvendio__Quantity__c		= 20;
		adCP.ADvendio__Sales_Price__c	= 100;
		insert adCP;

		// Create 2 component items
		ADvendio__Campaign_Item__c ci01					= cls_P7S1_TestData.createTestCampaignItem(false, adM, lstAdPrice[1]);
		ci01.ADvendio__PacketItem__c					= adCP.Id;
		ci01.ADvendio__Quantity__c						= 5;

		ADvendio__Campaign_Item__c ci02					= cls_P7S1_TestData.createTestCampaignItem(false, adM, lstAdPrice[2]);
		ci02.ADvendio__PacketItem__c					= adCP.Id;
		ci02.ADvendio__Quantity__c						= 15;
		insert new List<ADvendio__Campaign_Item__c>{ci01,ci02};

		Test.startTest();

			ci01	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci01.Id];
			System.assertEquals(adCP.Id, ci01.ADvendio__PacketItem__c);
			System.assertEquals(5, ci01.ADvendio__Quantity__c);
	
			ci02	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci02.Id];
			System.assertEquals(adCP.Id, ci02.ADvendio__PacketItem__c);
			System.assertEquals(15, ci02.ADvendio__Quantity__c);
	
			ci01.ADvendio__Availability__c				= 15;
			ci01.ADvendio__LastAvailabilityForecast__c	= System.now().addMinutes(-5);
			
			ci02.ADvendio__Availability__c				= 5;
			ci02.ADvendio__LastAvailabilityForecast__c	= System.now().addMinutes(-5);
			update new List<ADvendio__Campaign_Item__c>{ci01,ci02};
	
			ci01	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci01.Id];
			System.assertEquals(10, ci01.ADvendio__Quantity__c);
			System.assertEquals(50, ci01.ADvendio__Prorated__c);
			
			ci02	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci02.Id];
			System.assertEquals(10, ci02.ADvendio__Quantity__c);
			System.assertEquals(50, ci02.ADvendio__Prorated__c);
	
			// test too much delivered already
			ci01.ADvendio__Delivered_Impressions__c		= 7;
			ci01.ADvendio__Availability__c				= 800;
			ci01.ADvendio__LastAvailabilityForecast__c	= System.now().addMinutes(-5);
			
			ci02.ADvendio__Availability__c				= 200;
			ci02.ADvendio__LastAvailabilityForecast__c	= System.now().addMinutes(-5);
			ci02.ADvendio__Delivered_Impressions__c		= 8;
			update new List<ADvendio__Campaign_Item__c>{ci01, ci02};
			
			ci01	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci01.Id];
			System.assertEquals(10, ci01.ADvendio__Quantity__c);
			System.assertEquals(50, ci01.ADvendio__Prorated__c);
	
			ci02	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci02.Id];
			System.assertEquals(10, ci02.ADvendio__Quantity__c);
			System.assertEquals(50, ci02.ADvendio__Prorated__c);

		Test.stopTest();
	}

	static testMethod void myUnitTest2() {
		
		ADvendio__Placement__c placement	= cls_P7S1_TestData.createTestPlacement(false);
		placement.SomDig_Typ__c				= 'YouTube';
		insert placement;
		
		// Create 3 ad specs
		List<ADvendio__Ad_Specs__c> lstAdS		= new List<ADvendio__Ad_Specs__c>();
		for(Integer i=0;i<3;i++){
			ADvendio__Ad_Specs__c asp = cls_P7S1_TestData.createTestAdSpec(false, placement);
            asp.ADvendio__Distribution__c	= 'Prorated';
            lstAdS.add(asp);
		}
		insert lstAdS;

		// Create 3 ad price
		List<ADvendio__Ad_price__c> lstAdPrice	= new List<ADvendio__Ad_price__c>();
		for (Integer i=0;i<3;i++){
			lstAdPrice.add(cls_P7S1_TestData.createTestAdPrice(false, lstAdS[i]));
		}
		insert lstAdPrice;

		ADvendio__MediaCampaign__c adM	= cls_P7S1_TestData.createTestMediaCampaign(true);
		ADvendio__Campaign_Item__c adCP	= cls_P7S1_TestData.createTestCampaignItem(false, adM, lstAdPrice[0]);
		adCP.ADvendio__Quantity__c		= 200;
		adCP.ADvendio__Sales_Price__c	= 100;
		insert adCP;

		// Create 2 component items
		ADvendio__Campaign_Item__c ci01					= cls_P7S1_TestData.createTestCampaignItem(false, adM, lstAdPrice[1]);
		ci01.ADvendio__PacketItem__c					= adCP.Id;
		ci01.ADvendio__Quantity__c						= 50;
 
		ADvendio__Campaign_Item__c ci02					= cls_P7S1_TestData.createTestCampaignItem(false, adM, lstAdPrice[2]);
		ci02.ADvendio__PacketItem__c					= adCP.Id;
		ci02.ADvendio__Quantity__c						= 150;
		insert new List<ADvendio__Campaign_Item__c>{ci01,ci02};

		Test.startTest();

			ci01	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci01.Id];
			System.assertEquals(adCP.Id, ci01.ADvendio__PacketItem__c);
			System.assertEquals(50, ci01.ADvendio__Quantity__c);
	
			ci02	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci02.Id];
			System.assertEquals(adCP.Id, ci02.ADvendio__PacketItem__c);
			System.assertEquals(150, ci02.ADvendio__Quantity__c);
	
			ci01.ADvendio__Availability__c				= 150;
			ci01.ADvendio__LastAvailabilityForecast__c	= System.now().addMinutes(-5);
			
			ci02.ADvendio__Availability__c				= 50;
			ci02.ADvendio__LastAvailabilityForecast__c	= System.now().addMinutes(-5);
			update new List<ADvendio__Campaign_Item__c>{ci01,ci02};
	
			ci01	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci01.Id];
			System.assertEquals(150, ci01.ADvendio__Quantity__c);
			System.assertEquals(75, ci01.ADvendio__Prorated__c);
	
			ci02	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci02.Id];
			System.assertEquals(50, ci02.ADvendio__Quantity__c);
			System.assertEquals(25, ci02.ADvendio__Prorated__c);
	
			// test too much delivered already
			ci01.ADvendio__Delivered_Impressions__c		= 70;
			ci01.ADvendio__Availability__c				= 8000;
			ci01.ADvendio__LastAvailabilityForecast__c	= System.now().addMinutes(-5);
			
			ci02.ADvendio__Availability__c				= 2000;
			ci02.ADvendio__LastAvailabilityForecast__c	= System.now().addMinutes(-5);
			ci02.ADvendio__Delivered_Impressions__c		= 80;
			update new List<ADvendio__Campaign_Item__c>{ci01, ci02};
			
			ci01	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci01.Id];
			System.assertEquals(120, ci01.ADvendio__Quantity__c);
			System.assertEquals(60, ci01.ADvendio__Prorated__c);
	
			ci02	= [Select Id, ADvendio__PacketItem__c, ADvendio__Quantity__c, ADvendio__Prorated__c, ADvendio__Availability__c, ADvendio__LastAvailabilityForecast__c From ADvendio__Campaign_Item__c Where Id = :ci02.Id];
			System.assertEquals(80, ci02.ADvendio__Quantity__c);
			System.assertEquals(40, ci02.ADvendio__Prorated__c);

		Test.stopTest();
	}
}