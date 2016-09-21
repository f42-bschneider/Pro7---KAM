/*
    Class Name   : Adv_MediaCampaign_Report_Test
    Description  : This class is test class for Adv_MediaCampaign_Report
    Created By   : Cognizant Technology Solutions
    Created On   : 5/20/2014
*/
@isTest
public class Adv_MediaCampaign_Report_Test {

    /*
        Method Name  : testMediaCampaignReport
        Parameters   : void
        Return Type  : void
        Description  : This method is used for unit testing the functionalities of Adv_MediaCampaign_Report class
        Created By   : Cognizant Technology Solutions
    */
    static testMethod void testMediaCampaignReport() {
        ADvendio__MediaCampaign__c l_oMediaCampaign = cls_P7S1_TestData.createTestMediaCampaign(false);
        l_oMediaCampaign.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Auftrag'].Id;
        insert l_oMediaCampaign;

        Reports_Columns_Settings__c l_oReportsColumnsSettings = new Reports_Columns_Settings__c(Name = 'ADvendio__Offer_Number__c',Is_Displayed__c = true);
        insert l_oReportsColumnsSettings;

        Test.startTest();

        Adv_MediaCampaign_Report l_oMediaCampaignReport = new Adv_MediaCampaign_Report();
        l_oMediaCampaignReport.getMediaCampaignWrapper();
        l_oMediaCampaignReport.saveInline();
        for (ADvendio__MediaCampaign__c l_oMediaCampaignTemp : (list<ADvendio__MediaCampaign__c>)l_oMediaCampaignReport.i_oStandardSetController.getRecords()) {
            l_oMediaCampaignTemp.SomDig_PAMKommentar__c = 'test';
        }
        l_oMediaCampaignReport.doNext();
        for (ADvendio__MediaCampaign__c l_oMediaCampaignTemp : (list<ADvendio__MediaCampaign__c>)l_oMediaCampaignReport.i_oStandardSetController.getRecords()) {
            l_oMediaCampaignTemp.SomDig_PAMKommentar__c = 'test again';
        }
        l_oMediaCampaignReport.doPrevious();
        l_oMediaCampaignReport.i_sSortField = 'Name';
        l_oMediaCampaignReport.SortToggle();
        l_oMediaCampaignReport.getPAMStatus();
        l_oMediaCampaignReport.getUser();
        l_oMediaCampaignReport.getAgency();
        l_oMediaCampaignReport.getAdvertiser();
        l_oMediaCampaignReport.getOfferNumber();
        l_oMediaCampaignReport.getCampaign();
        l_oMediaCampaignReport.i_sListSelectedStatus = new List<String>{'neu'};
        l_oMediaCampaignReport.i_sListSelectedCampaign = new List<String>{'Test Media Campaign'};
        l_oMediaCampaignReport.i_sListSelectedAdvertiser = new List<String>{'TestAccount'};
        List<Id> l_iListUser = new List<Id>();
        for(User l_oUser : [select Firstname,LastName,Id from User where Profile.Name = 'SomDig_PAM' and IsActive=true order by Firstname asc limit 2]){
            l_iListUser.add(l_oUser.Id);
        }
        l_oMediaCampaignReport.i_sListUserselected = l_iListUser;
        l_oMediaCampaignReport.getExportReport();
        l_oMediaCampaignReport.i_sSelectedContentType = 'PDF Format';
        l_oMediaCampaignReport.CreateCsvReport();
        l_oMediaCampaignReport.i_sSelectedContentType = 'Excel Format';
        l_oMediaCampaignReport.CreateCsvReport();
        l_oMediaCampaignReport.i_sSelectedContentType = 'CSV Format';
        l_oMediaCampaignReport.CreateCsvReport();
        l_oMediaCampaignReport.i_sAlphaFilter = 'Other';
        l_oMediaCampaignReport.refreshController();
        l_oMediaCampaignReport.getMediaCampaignWrapper();
        l_oMediaCampaignReport.i_sAlphaFilter = 'T';
        l_oMediaCampaignReport.i_sListUserselected = new List<String>{'Alle'};
        l_oMediaCampaignReport.refreshController();
        l_oMediaCampaignReport.getMediaCampaignWrapper();

        Test.stopTest();
    }
}