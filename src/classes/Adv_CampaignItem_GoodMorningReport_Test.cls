/*
    Class Name   : Adv_CampaignItem_GoodMorningReport_Test
    Description  : This class is test class for Adv_CampaignItem_GoodMorningReport
    Created By   : Cognizant Technology Solutions
    Created On   : 5/21/2014
*/
@isTest
private class Adv_CampaignItem_GoodMorningReport_Test {

    /*
        Method Name  : testCampgnItemsGoodMrngController
        Parameters   : void
        Return Type  : void
        Description  : This method is used for unit testing the functionalities of Adv_CampaignItem_GoodMorningReport class
        Created By   : Cognizant Technology Solutions
    */
    static testMethod void testCampgnItemsGoodMrngController(){
        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        l_oMediaCampaign.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Auftrag'].id;
        insert l_oMediaCampaign;

        ADvendio__Campaign_Item__c l_oCampaignItem = cls_P7S1_TestData.createTestCampaignItem(false, l_oMediaCampaign);
        l_oCampaignItem.SomDig_PositionStatus__c = 'abgeschlossen-unterliefert';
        insert l_oCampaignItem;

        Test.startTest();
        Adv_CampaignItem_GoodMorningReport l_oCampgnItemsGoodMrngRprtController = new Adv_CampaignItem_GoodMorningReport();
        l_oCampgnItemsGoodMrngRprtController.i_oCampaignItem.ADvendio__from_Date__c = system.today()-1;
        l_oCampgnItemsGoodMrngRprtController.i_oCampaignItem.ADvendio__until_Date__c = system.today()+3;
        l_oCampgnItemsGoodMrngRprtController.getCampaignItemWrapper();
        l_oCampgnItemsGoodMrngRprtController.i_sSortField = 'Name';
        l_oCampgnItemsGoodMrngRprtController.SortToggle();
        l_oCampgnItemsGoodMrngRprtController.getPositionStatus();
        l_oCampgnItemsGoodMrngRprtController.getUser();
        l_oCampgnItemsGoodMrngRprtController.getCampaign();
        l_oCampgnItemsGoodMrngRprtController.i_sListSelectedStatus= new List<String>{'abgeschlossen-unterliefert'};
        l_oCampgnItemsGoodMrngRprtController.i_sListSelectedCampaign= new List<String>{'Test Media Campaign'};
        List<Id> l_iListUser = new List<Id>();
        for(User l_oUser : [select Firstname,LastName,Id from User where Profile.Name = 'SomDig_PAM' and IsActive=true order by Firstname asc limit 2]){
            l_iListUser.add(l_oUser.id);
        }
        l_oCampgnItemsGoodMrngRprtController.i_sListUserselected = l_iListUser;
        l_oCampgnItemsGoodMrngRprtController.getExportReport();
        l_oCampgnItemsGoodMrngRprtController.i_sSelectedContentType = 'PDF Format';
        l_oCampgnItemsGoodMrngRprtController.CreateReport();
        l_oCampgnItemsGoodMrngRprtController.i_sSelectedContentType = 'Excel Format';
        l_oCampgnItemsGoodMrngRprtController.CreateReport();
        l_oCampgnItemsGoodMrngRprtController.i_sSelectedContentType = 'CSV Format';
        l_oCampgnItemsGoodMrngRprtController.CreateReport();
        l_oCampgnItemsGoodMrngRprtController.i_sAlphaFilter = 'Other';
        l_oCampgnItemsGoodMrngRprtController.refreshController();
        l_oCampgnItemsGoodMrngRprtController.getCampaignItemWrapper();
        l_oCampgnItemsGoodMrngRprtController.i_sAlphaFilter = 'T';
        l_oCampgnItemsGoodMrngRprtController.i_sListUserselected = new List<String>{'Alle'};
        l_oCampgnItemsGoodMrngRprtController.refreshController();
        l_oCampgnItemsGoodMrngRprtController.getCampaignItemWrapper();
        Test.stoptest();
    }
}