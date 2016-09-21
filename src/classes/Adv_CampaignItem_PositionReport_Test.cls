@isTest
public class Adv_CampaignItem_PositionReport_Test {

    /*
        Method Name  : testCampgnItemsPositionControllerReport
        Parameters   : void
        Return Type  : void
        Description  : This method is used for unit testing the functionalities of Adv_CampaignItem_PositionReport class
        Created By   : Cognizant Technology Solutions
    */
    static testMethod void testCampgnItemsPositionControllerReport() {

        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        l_oMediaCampaign.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Auftrag'].id;
        insert l_oMediaCampaign;

        ADvendio__Campaign_Item__c l_oCampaignItem = cls_P7S1_TestData.createTestCampaignItem(false, l_oMediaCampaign);
        l_oCampaignItem.SomDig_PositionStatus__c = 'bereit';
        insert l_oCampaignItem;

        List<Position_Reports_Columns_Setting__c> l_oListPositionReportsCustomsSetting = new List<Position_Reports_Columns_Setting__c>();
        Position_Reports_Columns_Setting__c reportCustomSetting1 = new Position_Reports_Columns_Setting__c(Name = 'Name',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting1);
        Position_Reports_Columns_Setting__c reportCustomSetting2 = new Position_Reports_Columns_Setting__c(Name = 'SomDig_StatusFlagPosition__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting2);
        Position_Reports_Columns_Setting__c reportCustomSetting3 = new Position_Reports_Columns_Setting__c(Name = 'SomDig_PositionStatus__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting3);
        Position_Reports_Columns_Setting__c reportCustomSetting4 = new Position_Reports_Columns_Setting__c(Name = 'ADvendio__from_Date__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting4);
        Position_Reports_Columns_Setting__c reportCustomSetting5 = new Position_Reports_Columns_Setting__c(Name = 'ADvendio__until_Date__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting5);
        Position_Reports_Columns_Setting__c reportCustomSetting6 = new Position_Reports_Columns_Setting__c(Name = 'ADvendio__PositionNumber__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting6);
        Position_Reports_Columns_Setting__c reportCustomSetting7 = new Position_Reports_Columns_Setting__c(Name = 'SomDig_MediagattungsSegment__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting7);
        Position_Reports_Columns_Setting__c reportCustomSetting8 = new Position_Reports_Columns_Setting__c(Name = 'ADvendio__Billing_category__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting8);
        Position_Reports_Columns_Setting__c reportCustomSetting9 = new Position_Reports_Columns_Setting__c(Name = 'ADvendio__Quantity__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting9);
        Position_Reports_Columns_Setting__c reportCustomSetting10 = new Position_Reports_Columns_Setting__c(Name = 'SomDig_AIClicksSollBisHeute__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting10);
        Position_Reports_Columns_Setting__c reportCustomSetting11 = new Position_Reports_Columns_Setting__c(Name = 'SomDig_AiClicksIst__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting11);
        Position_Reports_Columns_Setting__c reportCustomSetting12 = new Position_Reports_Columns_Setting__c(Name = 'SomDig_Risk__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting12);
        Position_Reports_Columns_Setting__c reportCustomSetting13 = new Position_Reports_Columns_Setting__c(Name = 'ADvendio__PerformanceIndicator__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting13);
        Position_Reports_Columns_Setting__c reportCustomSetting14 = new Position_Reports_Columns_Setting__c(Name = 'SomDig_LineItemInAdServer__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting14);
        Position_Reports_Columns_Setting__c reportCustomSetting15 = new Position_Reports_Columns_Setting__c(Name = 'Status_Screenshot__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting15);
        Position_Reports_Columns_Setting__c reportCustomSetting16 = new Position_Reports_Columns_Setting__c(Name = 'SomDig_PAMKommentar__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting16);
        Position_Reports_Columns_Setting__c reportCustomSetting17 = new Position_Reports_Columns_Setting__c(Name = 'SomDig_Inhaber_Kuerzel__c',Is_Displayed__c = true);
        l_oListPositionReportsCustomsSetting.add(reportCustomSetting17);
        insert l_oListPositionReportsCustomsSetting;

        System.test.startTest();
        Adv_CampaignItem_PositionReport l_oCampgnItemsPositionRprtController = new Adv_CampaignItem_PositionReport();
        l_oCampgnItemsPositionRprtController.i_oCampaignItem.ADvendio__from_Date__c = system.today()-1;
        l_oCampgnItemsPositionRprtController.i_oCampaignItem.ADvendio__until_Date__c = system.today()+3;
        l_oCampgnItemsPositionRprtController.getMediaCampaign();
        for (ADvendio__MediaCampaign__c l_oMediaCampaignTemp : (list<ADvendio__MediaCampaign__c>)l_oCampgnItemsPositionRprtController.i_oStandardSetController.getRecords()) {
            for(ADvendio__Campaign_Item__c l_oCampaignItemTemp : l_oMediaCampaignTemp.Advendio__Advertising_Media__r)
                l_oCampaignItemTemp.SomDig_PAMKommentar2__c = 'test';
        }
        l_oCampgnItemsPositionRprtController.saveInline();
        l_oCampgnItemsPositionRprtController.i_sSortField = 'Name';
        l_oCampgnItemsPositionRprtController.SortToggle();
        l_oCampgnItemsPositionRprtController.getPositionStatus();
        l_oCampgnItemsPositionRprtController.getUser();
        l_oCampgnItemsPositionRprtController.getCampaign();
        l_oCampgnItemsPositionRprtController.getAgency();
        l_oCampgnItemsPositionRprtController.getAdvertiser();
        l_oCampgnItemsPositionRprtController.getOfferNumber();
        l_oCampgnItemsPositionRprtController.i_sListSelectedStatus = new List<String>{'bereit'};
        l_oCampgnItemsPositionRprtController.i_sListSelectedCampaign = new List<String>{'Test Media Campaign'};
        List<Id> l_iListUser = new List<Id>();
        for(User l_oUser : [select Firstname,LastName,Id from User where Profile.Name = 'SomDig_PAM' and IsActive=true order by Firstname asc limit 2]){
            l_iListUser.add(l_oUser.id);
        }
        l_oCampgnItemsPositionRprtController.i_sListUserselected = l_iListUser;
        l_oCampgnItemsPositionRprtController.getExportReport();
        l_oCampgnItemsPositionRprtController.i_sSelectedContentType = 'PDF Format';
        l_oCampgnItemsPositionRprtController.CreateReport();
        l_oCampgnItemsPositionRprtController.i_sSelectedContentType = 'Excel Format';
        l_oCampgnItemsPositionRprtController.CreateReport();
        l_oCampgnItemsPositionRprtController.i_sSelectedContentType = 'CSV Format';
        l_oCampgnItemsPositionRprtController.CreateReport();
        l_oCampgnItemsPositionRprtController.i_sAlphaFilter = 'Other';
        l_oCampgnItemsPositionRprtController.refreshController();
        l_oCampgnItemsPositionRprtController.getMediaCampaign();
        l_oCampgnItemsPositionRprtController.i_sAlphaFilter = 'T';
        l_oCampgnItemsPositionRprtController.i_sListUserselected = new List<String>{'Alle'};
        l_oCampgnItemsPositionRprtController.refreshController();
        l_oCampgnItemsPositionRprtController.getMediaCampaign();
        system.test.stoptest();
    }
}