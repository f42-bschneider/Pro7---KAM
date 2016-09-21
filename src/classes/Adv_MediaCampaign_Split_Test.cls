@isTest
private class Adv_MediaCampaign_Split_Test {

    static testMethod void testSplit() {
        ADvendio__MediaCampaign__c mediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(true);
        ADvendio__Ad_price__c adPrice = cls_P7S1_TestData.createTestAdPrice(true, mediaCampaign.ADvendio__Pricelist__r);
        ADvendio__Campaign_Item__c campaignItem1 = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign, adPrice);
        ADvendio__Campaign_Item__c campaignItem2 = cls_P7S1_TestData.createTestCampaignItem(false, mediaCampaign, adPrice);
        List<ADvendio__Campaign_Item__c> items = new List<ADvendio__Campaign_Item__c>{campaignItem1, campaignItem2};
        insert items;

        Test.startTest();

        ApexPages.StandardController ctrl= new ApexPages.StandardController(mediaCampaign);

        Adv_MediaCampaign_Split cls = new Adv_MediaCampaign_Split(ctrl);

        System.assertEquals('showBtnSplit:true','showBtnSplit:'+cls.showBtnSplit);

        for(Adv_MediaCampaign_Split.ItemWrapper w: cls.itmWrappers){
                //user selects only packet item then its component item will follow
                if(w.item.id==items[0].Id)w.selected=true;
        }

        //button split
        PageReference p=cls.back();
        System.assertEquals('button back:true','button back:'+p.getUrl().contains('/'+mediaCampaign.Id));
        p=cls.split();

        //Naviaget to new Media campaign
        System.assertEquals('button split:true','button split:'+(!p.getUrl().contains('/'+mediaCampaign.Id)));

        //splited items
        Map<Id, List<ADvendio__Campaign_Item__c>> mSplitItem=new Map<Id, List<ADvendio__Campaign_Item__c>>();
        for(ADvendio__Campaign_Item__c itm1: [select ADvendio__Media_Campaign__c FROM ADvendio__Campaign_Item__c WHERE
            //New MediaCampaign will lookup to orginal MediaCampaign by reffernce field
            ADvendio__Media_Campaign__c IN (Select Id FROM ADvendio__MediaCampaign__c WHERE SomDig_MasterMediaCampaign__c=:mediaCampaign.Id OR Id=:mediaCampaign.Id)])

            {

            List<ADvendio__Campaign_Item__c> l=mSplitItem.get(itm1.ADvendio__Media_Campaign__c);
            if(l==null)l=new List<ADvendio__Campaign_Item__c>();

            l.add(itm1);
            mSplitItem.put(itm1.ADvendio__Media_Campaign__c,l);

        }

        Test.stopTest();
    }

}