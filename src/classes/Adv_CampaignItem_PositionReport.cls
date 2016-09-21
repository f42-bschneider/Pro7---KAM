/*
    Class Name   : Adv_CampaignItem_PositionReport
    Description  : This is the Controller class for Adv_CampaignItem_PositionReport, Adv_CampaignItem_PositionReportCSV and Adv_CampaignItem_PositionReportPDF pages
    Created By   : Cognizant Technology Solutions
    Created On   : 5/7/2014
    Test Class   : Adv_CampaignItem_PositionReport_Test
*/
public with sharing class Adv_CampaignItem_PositionReport {

    // account and selection set/variables
    private list<ADvendio__MediaCampaign__c> i_oListMediaCampaign {get; set;}

    // selection and filter
    public list<String> i_sListAlpha {get; set;}
    public String i_sAlphaFilter {get; set;}
    private String i_sQuery;

    // display sort and number
    public String i_sRecordPerPage {get; set;}
    public list<SelectOption> i_soListRecordPerPage {get; set;}
    public List<String> i_sListSelectedStatus {get; set;}{ i_sListSelectedStatus = new List<String>{''}; }
    public String i_sSortFieldSave;
    public String i_sSortField {get; set;}

    public String i_sSortDirection {
        get { if (i_sSortDirection == null) {  i_sSortDirection = 'asc'; } return i_sSortDirection;  }
        set;
    }
    public ApexPages.StandardSetController i_oStandardSetController {get; set;}

    public ADvendio__Campaign_Item__c i_oCampaignItem {get; set;}
    public Integer i_nPAMStatusSize {get; set;}
    public List<String> i_sListSelectedCampaign {get; set;} { i_sListSelectedCampaign = new List<String>{''}; }
    public List<String> i_sListSelectedAgency {get; set;} { i_sListSelectedAgency = new List<String>{''}; }
    public List<String> i_sListSelectedAdvertiser {get; set;} { i_sListSelectedAdvertiser = new List<String>{''}; }
    public List<String> i_sListSelectedOfferNumber {get; set;} { i_sListSelectedOfferNumber = new List<String>{''}; }
    public List<String> i_sListUserselected { get; set; } { i_sListUserselected = new List<String>{''}; }
    public String i_sSearchOfferNumber {get; set;}

    //report  variables
    public String i_sContentType {get; set;}
    public String i_sFileName {get; set;}
    public String i_sReportData {get; set;}
    public String i_sSelectedContentType{get;set;}
    public static List<ADvendio__MediaCampaign__c> i_oListMediaCampaignReport {get; private set; }

    //controls how many rows are displayed on page 1
    private static Integer i_nFIRST_BREAK = 20;
    //controls how many rows  are displayed on subsequent pages
    private static Integer i_nSUBSEQ_BREAKS = 20;
    public List<ADvendio__Campaign_Item__c> i_oListCampaignItemClone = new List<ADvendio__Campaign_Item__c>();
    public Date i_dFrom;
    public Date i_dUntil;
    public List<ADvendio__Campaign_Item__c[]> i_oListListCampaignItem {get; private set; }
    public Id i_iMediaCampaignId;
    public Id i_iMediaCampaignOwnerId;

    /*
        Method Name  : Adv_CampaignItem_PositionReport
        Parameters   : void
        Return Type  : void
        Description  : This method is used for:
        1. Initializing the variables and invoke the refreshController method
        Created By   : Cognizant Technology Solutions
    */
    public Adv_CampaignItem_PositionReport() {
        i_oCampaignItem = new ADvendio__Campaign_Item__c();
        i_oListMediaCampaign = new list<ADvendio__MediaCampaign__c>();
        //records for page initialization
        i_soListRecordPerPage = new list<SelectOption>();
        i_soListRecordPerPage.add(new SelectOption('5','5'));
        i_soListRecordPerPage.add(new SelectOption('10','10'));
        i_soListRecordPerPage.add(new SelectOption('25','25'));
        i_soListRecordPerPage.add(new SelectOption('50','50'));
        i_soListRecordPerPage.add(new SelectOption('100','100'));
        i_soListRecordPerPage.add(new SelectOption('200','200'));
        i_sRecordPerPage = '200'; //default records per page

        // initialization alpha list
        i_sListAlpha = new list<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Other', 'All'};
        i_sSortFieldSave = i_sSortField;

        // alpha filter, use page parameter or set default to all
        if (apexpages.currentpage().getparameters().get('alpha') == null) {
            i_sAlphaFilter = 'All';
        } else {
            i_sAlphaFilter = apexpages.currentpage().getparameters().get('alpha');
        }
        // Media Campaign Id from Campaign View
        i_iMediaCampaignId = ApexPages.currentPage().getParameters().get('mcid');
        if(i_iMediaCampaignId != null)
        i_iMediaCampaignOwnerId = [Select OwnerId from ADvendio__MediaCampaign__c where id =: i_iMediaCampaignId].OwnerId;
        // list generation
        i_oListMediaCampaignReport= new List<ADvendio__MediaCampaign__c>();
        refreshController();
    }

    /*
        Method Name  : refreshController
        Parameters   : void
        Return Type  : void
        Description  : This method is used for:
        1. Refreshing the whole page by building the query again based on filters and Sorting Columns
        Created By   : Cognizant Technology Solutions
    */
    public void refreshController(){
        BuildQuery();
        i_oStandardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(i_sQuery));
        // sets the number of records in each page set
        if(i_sRecordPerPage == null)
        i_sRecordPerPage = '200';
        i_oStandardSetController.setPageSize(Integer.valueOf(i_sRecordPerPage));
    }

    /*
        Method Name  : saveInline
        Parameters   : void
        Return Type  : PageReference
        Description  : This method is used for:
        1. Saving the records edited by using the inline editing
        Created By   : Cognizant Technology Solutions
    */
    public PageReference saveInline(){
        List<ADvendio__Campaign_Item__c> l_oListCampaignItem = new List<ADvendio__Campaign_Item__c>();
        List<ADvendio__Campaign_Item__c> l_oListCampaignItemUpdate = new List<ADvendio__Campaign_Item__c>();
        for(ADvendio__MediaCampaign__c media : i_oListMediaCampaign){
            l_oListCampaignItem.addAll(media.ADvendio__Advertising_Media__r);
        }
        system.debug('inside save');
        system.debug(l_oListCampaignItem.size()+''+l_oListCampaignItem);
        system.debug(i_oListCampaignItemClone.size()+''+i_oListCampaignItemClone);
        for(ADvendio__Campaign_Item__c ci : l_oListCampaignItem){
            for(ADvendio__Campaign_Item__c ciClone : i_oListCampaignItemClone){
                if(ci.id == ciClone.id && (ci.SomDig_PAMKommentar2__c != ciClone.SomDig_PAMKommentar2__c || ci.Status_Screenshot__c != ciClone.Status_Screenshot__c)){
                    ci.SomDig_PAMKommentar__c = ci.SomDig_PAMKommentar2__c;
                    l_oListCampaignItemUpdate.add(ci);
                }
            }
        }
        if(l_oListCampaignItemUpdate.size() > 0)
        update l_oListCampaignItemUpdate;
        return null;
    }

    /*
        Method Name  : getMediaCampaign
        Parameters   : void
        Return Type  : list<ADvendio__MediaCampaign__c>
        Description  : This method is used for:
        1. Returning the list of ADvendio__MediaCampaign__c class
        Created By   : Cognizant Technology Solutions
    */
    public list<ADvendio__MediaCampaign__c> getMediaCampaign() {
        //UpdateAccountSelectedSet();
        i_oListMediaCampaign = new list<ADvendio__MediaCampaign__c>{};
        if (i_oStandardSetController != null) {
            i_oListMediaCampaign = (list<ADvendio__MediaCampaign__c>)i_oStandardSetController.getRecords();
            i_oListCampaignItemClone.clear();
            for(ADvendio__MediaCampaign__c media : (list<ADvendio__MediaCampaign__c>)i_oStandardSetController.getRecords()){
                for(ADvendio__Campaign_Item__c campaign : media.ADvendio__Advertising_Media__r)
                i_oListCampaignItemClone.add(campaign.clone(true,true,true,true));
            }
            system.debug('####i_oListMediaCampaign: '+i_oListMediaCampaign);
            system.debug(i_oListCampaignItemClone.size()+''+i_oListCampaignItemClone);
        }
        return i_oListMediaCampaign;
    }

    /*
        Method Name  : BuildQuery
        Parameters   : void
        Return Type  : void
        Description  : This method is used for:
        1. Building the Dynamic Query based on Filters and Sorting Columns
        Created By   : Cognizant Technology Solutions
    */
    public void BuildQuery() {
        i_oStandardSetController = null;
        String l_sQueryWhere = '';
        String l_sQuerySubWhere = '';
        String l_sQuerySubWhereChild='';
        if (i_sAlphaFilter == null || i_sAlphaFilter.trim().length() == 0) {
            i_sAlphaFilter = 'All';
        }
        i_dFrom = i_oCampaignItem.ADvendio__from_Date__c;
        i_dUntil = i_oCampaignItem.ADvendio__until_Date__c;

        system.debug(i_dFrom);
        system.debug(i_dUntil);
        i_sQuery = 'SELECT Name,ADvendio__Account__r.Name,ADvendio__Account__c,ADvendio__Agency__r.Name,ADvendio__Agency__c,SomDig_WtAgBeziehung__c,ADvendio__Offer_Number__c,' +
            ' (Select Name,SomDig_StatusFlagPosition__c,ADvendio__Amount_B3__c,ADvendio__Amount_net_net__c,ADvendio__eCPC__c,SomDig_PositionStatus__c,ADvendio__from_Date__c,' +
            ' ADvendio__until_Date__c,ADvendio__PositionNumber__c,ADvendio__Billing_category__c,' +
            ' ADvendio__Quantity__c,SomDig_AIClicksSollBisHeute__c,SomDig_AiClicksIst__c,SomDig_Risk__c,' +
            ' ADvendio__PerformanceIndicator__c,ADvendio__Adserver_ID_Order_ID__c,SomDig_LineItemInAdServer__c,' +
            ' SomDig_PAMKommentar__c,SomDig_PAMKommentar2__c,Status_Screenshot__c,ADvendio__Media_Campaign__r.OwnerId,ADvendio__Media_Campaign__r.Owner.FirstName,'+
            ' ADvendio__Media_Campaign__c,ADvendio__Media_Campaign__r.Name,ADvendio__Media_Campaign__r.RecordType.Name,' +
            ' SomDig_Inhaber_Kuerzel__c,SomDig_MediagattungsSegment__c,ADvendio__Media_Campaign__r.ADvendio__Account__r.Name from ADvendio__Advertising_Media__r';

        if (i_sAlphaFilter == 'Other') {
            if(i_sSortField == null || i_sSortField == '')
            i_sSortField = 'ADvendio__Media_Campaign__r.Owner.FirstName';
            l_sQuerySubWhereChild = BuildWhere(l_sQuerySubWhereChild, '(' + String.escapeSingleQuotes(i_sSortField) + ' < \'A\' OR ' +
            String.escapeSingleQuotes(i_sSortField) + ' > \'Z\') AND (NOT ' +
            String.escapeSingleQuotes(i_sSortField) + ' LIKE \'Z%\') ');
        }


        else if (i_sAlphaFilter != 'All') {
            if(i_sSortField == null || i_sSortField == '')
            i_sSortField = 'ADvendio__Media_Campaign__r.Owner.FirstName';
            l_sQuerySubWhereChild = BuildWhere(l_sQuerySubWhereChild, '(' + String.escapeSingleQuotes(i_sSortField) + ' LIKE \'' + String.escapeSingleQuotes(i_sAlphaFilter) + '%\')' );
        }

        if(i_sListSelectedStatus != null && String.isNotEmpty(i_sListSelectedStatus[0])){
            String l_sStatusFilter = separateSetForDynamicSOQL(i_sListSelectedStatus);
            l_sQuerySubWhereChild = BuildWhere(l_sQuerySubWhereChild,' (SomDig_PositionStatus__c in ('+ l_sStatusFilter +'))');
        }

        if(i_sListSelectedCampaign != null && i_sListSelectedCampaign.size()>0 && String.isNotEmpty(i_sListSelectedCampaign[0])){
            String l_sCampaignFilter = separateSetForDynamicSOQL(i_sListSelectedCampaign);
            l_sQuerySubWhereChild = BuildWhere(l_sQuerySubWhereChild, '(ADvendio__Media_Campaign__r.Name in ('+ l_sCampaignFilter +'))');
        }

        if(i_dFrom != null){
            DateTime l_dFrom = DateTime.newInstance(i_dFrom.year(), i_dFrom.month(), i_dFrom.day());
            String l_sFrom = l_dFrom.format('yyyy-MM-dd');
            l_sQuerySubWhereChild = BuildWhere(l_sQuerySubWhereChild,' (ADvendio__from_Date__c >= ' + l_sFrom + ')');
        }

        if(i_dUntil != null){
            DateTime l_dUntil = DateTime.newInstance(i_dUntil.year(), i_dUntil.month(), i_dUntil.day());
            String l_sUntil = l_dUntil.format('yyyy-MM-dd');
            l_sQuerySubWhereChild = BuildWhere(l_sQuerySubWhereChild, ' (ADvendio__until_Date__c <= ' + l_sUntil + ')');
        }

        i_sQuery += l_sQuerySubWhereChild;

        if(i_sSortField == null || i_sSortField == '')
        i_sQuery += ' ORDER BY ADvendio__Media_Campaign__r.Name '+ String.escapeSingleQuotes(i_sSortDirection) + ') FROM ADvendio__MediaCampaign__c';
        else
        i_sQuery += ' ORDER BY ' + String.escapeSingleQuotes(i_sSortField) + ' ' + String.escapeSingleQuotes(i_sSortDirection) + ') FROM ADvendio__MediaCampaign__c';

        l_sQueryWhere = BuildWhere(l_sQueryWhere, '(SomDig_StatusPAMCockpit__c != \'abgeschlossen\')');

        l_sQueryWhere = BuildWhere(l_sQueryWhere, '(RecordType.Name = \'Auftrag\')');

        if(i_sListSelectedAgency != null && i_sListSelectedAgency.size()>0 && String.isNotEmpty(i_sListSelectedAgency[0]))
        l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__Agency__r.Name in : i_sListSelectedAgency)');

        if(i_sListSelectedAdvertiser != null && i_sListSelectedAdvertiser.size()>0  && String.isNotEmpty(i_sListSelectedAdvertiser[0]))
        l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__Account__r.Name in : i_sListSelectedAdvertiser)');

        if(i_sListSelectedOfferNumber != null && i_sListSelectedOfferNumber.size()>0  && String.isNotEmpty(i_sListSelectedOfferNumber[0]))
        l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__Offer_Number__c in : i_sListSelectedOfferNumber)');

        if (i_sSearchOfferNumber != null) {
            l_sQueryWhere = BuildWhere(l_sQueryWhere, ' (ADvendio__Offer_Number__c LIKE \'%' + String.escapeSingleQuotes(i_sSearchOfferNumber) + '%\')');
        }

        Set<String> l_sSetUserId = new Set<String>();
        String l_sUserFilter = '';
        l_sSetUserId.add(UserInfo.getUserId());
        if(i_sListUserselected != null  && i_sListUserselected.size()>0  && String.isNotEmpty(i_sListUserselected[0])){
            Set<String> l_sSetUserSelected = new Set<String>();
            l_sSetUserSelected.addAll(i_sListUserselected);
            if(!l_sSetUserSelected.contains('Alle'))
            {
                l_sSetUserId = new Set<String>();
                l_sSetUserId.addAll(i_sListUserselected);
            }
            else{
                for(User l_oUser : getAllPAMUsers()) {
                    l_sSetUserId.add(l_oUser.id);
                }
            }
        } else if (String.isEmpty(i_sListUserselected[0]) && i_sSearchOfferNumber != null && String.isNotEmpty(i_sSearchOfferNumber)) {
            for(User l_oUser : getAllPAMUsers()) {
                l_sSetUserId.add(l_oUser.id);
            }
        }
        l_sUserFilter = separateSetForDynamicSOQL(l_sSetUserId);

        if(i_iMediaCampaignId == null){
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(OwnerId In (' + l_sUserFilter + '))');
            l_sQueryWhere = BuildWhere(l_sQueryWhere, 'id in (select ADvendio__Media_Campaign__c from ADvendio__Campaign_Item__c');

            if(i_sSortField == null || i_sSortField == '')
            i_sSortField = 'ADvendio__Media_Campaign__r.Owner.FirstName';
            if (i_sAlphaFilter == 'Other') {
                l_sQuerySubWhere = BuildWhere(l_sQuerySubWhere, '(' + String.escapeSingleQuotes(i_sSortField) + ' < \'A\' OR ' +
                String.escapeSingleQuotes(i_sSortField) + ' > \'Z\') AND (NOT ' +
                String.escapeSingleQuotes(i_sSortField) + ' LIKE \'Z%\') ');
            } else if (i_sAlphaFilter != 'All') {
                l_sQuerySubWhere = BuildWhere(l_sQuerySubWhere, '(' + String.escapeSingleQuotes(i_sSortField) + ' LIKE \'' + String.escapeSingleQuotes(i_sAlphaFilter) + '%\')' );
            }

            if(i_sListSelectedStatus != null && String.isNotEmpty(i_sListSelectedStatus[0]))
            l_sQuerySubWhere = BuildWhere(l_sQuerySubWhere, 'SomDig_PositionStatus__c in : i_sListSelectedStatus');

            if(i_sListSelectedCampaign != null && i_sListSelectedCampaign.size()>0 && String.isNotEmpty(i_sListSelectedCampaign[0]))
            l_sQuerySubWhere = BuildWhere(l_sQuerySubWhere, '(ADvendio__Media_Campaign__r.Name in : i_sListSelectedCampaign)');

            if(i_dFrom != null)
            l_sQuerySubWhere = BuildWhere(l_sQuerySubWhere, '(ADvendio__from_Date__c >: i_dFrom)');

            if(i_dUntil != null)
            l_sQuerySubWhere = BuildWhere(l_sQuerySubWhere, '(ADvendio__until_Date__c <: i_dUntil)');

            l_sQueryWhere += l_sQuerySubWhere + ')';
        }
        else{
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(OwnerId = \'' + i_iMediaCampaignOwnerId + '\')');
            l_sQueryWhere = BuildWhere(l_sQueryWhere, 'id = \'' + i_iMediaCampaignId + '\'');
        }
        i_sQuery += l_sQueryWhere;
        i_sQuery += ' LIMIT 10000';

        system.debug('i_sQuery:' + i_sQuery);

        i_oListMediaCampaignReport = Database.query(i_sQuery);
    }

    /*
        Method Name  : BuildWhere
        Parameters   : String, String
        Return Type  : String
        Description  : This method is used for:
        1. Building the Dynamic Where Query based on the Filter selection
        Created By   : Cognizant Technology Solutions
    */
    public String BuildWhere(String p_sQueryWhere, String p_sCondition) {
        if (p_sQueryWhere == '') {
            return ' WHERE ' + p_sCondition;
        } else {
            return p_sQueryWhere + ' AND ' + p_sCondition;
        }
    }

    /*
        Method Name  : separateSetForDynamicSOQL
        Parameters   : Set<String>
        Return Type  : String
        Description  : This method is used for:
        1. Seperating the Set of Strings to String to be used in Dynamic SOQL
        Created By   : Cognizant Technology Solutions
    */
    public static String separateSetForDynamicSOQL(Set<String> p_sSetSeparate)
    {
        String l_sSeparated = '';
        for(String l_sTemporary : p_sSetSeparate)
        {
            if(l_sSeparated != '') l_sSeparated += ',';
            l_sSeparated += '\'' + l_sTemporary + '\'';
        }
        return l_sSeparated;
    }

    /*
        Method Name  : separateSetForDynamicSOQL
        Parameters   : List<String>
        Return Type  : String
        Description  : This method is used for:
        1. Seperating the List of Strings to String to be used in Dynamic SOQL
        Created By   : Cognizant Technology Solutions
    */
    public static String separateSetForDynamicSOQL(List<String> p_sSetSeparate)
    {
        String l_sSeparated = '';
        for(String l_sTemporary : p_sSetSeparate)
        {
            if(l_sSeparated != '') l_sSeparated += ',';
            l_sSeparated += '\'' + l_sTemporary + '\'';
        }
        return l_sSeparated;
    }

    /*
        Method Name  : SortToggle
        Parameters   : void
        Return Type  : void
        Description  : This method is used for:
        1. Refreshing the whole page by building the query again based on Sorting Columns
        Created By   : Cognizant Technology Solutions
    */
    public void SortToggle() {
        i_sSortDirection = i_sSortDirection.equals('asc') ? 'desc NULLS LAST' : 'asc';
        // reset alpha filter and sort sequence when sorted field is changed
        if (i_sSortFieldSave != i_sSortField) {
            i_sSortDirection = 'asc';
            i_sAlphaFilter = 'All';
            i_sSortFieldSave = i_sSortField;
        }
        // run the query again
        refreshController();
    }

    /*
        Method Name  : getPositionStatus
        Parameters   : void
        Return Type  : list<SelectOption>
        Description  : This method is used for:
        1. Returning the list of SelectOption of Position Status
        Created By   : Cognizant Technology Solutions
    */
    public List<SelectOption> getPositionStatus()
    {
        List<SelectOption> l_oListSelectOption = new List<SelectOption>();
        l_oListSelectOption.add(new SelectOption('','Alle'));
        for(Schema.PicklistEntry l_oPickListEntry : ADvendio__Campaign_Item__c.SomDig_PositionStatus__c.getDescribe().getPicklistValues()){
            l_oListSelectOption.add(new SelectOption(l_oPickListEntry.getLabel(), l_oPickListEntry.getValue()));
        }
        return l_oListSelectOption;
    }

    /*
        Method Name  : getUser
        Parameters   : void
        Return Type  : list<SelectOption>
        Description  : This method is used for:
        1. Returning the list of SelectOption of User First Name and Last Name having SomDig_PAM profile
        Created By   : Cognizant Technology Solutions
    */
    public List<SelectOption> getUser() {
        List<SelectOption> l_oListSelectOption = new List<SelectOption>();
        l_oListSelectOption.add(new SelectOption('','-keinen-'));
        l_oListSelectOption.add(new SelectOption('Alle','Alle'));
        for (User l_oUser : getAllPAMUsers()) {
            l_oListSelectOption.add(new SelectOption(l_oUser.id, l_oUser.Firstname + ' ' + l_oUser.Lastname));
        }
        return l_oListSelectOption;
    }

    /*
        Method Name  : getCampaign
        Parameters   : void
        Return Type  : list<SelectOption>
        Description  : This method is used for:
        1. Returning the list of SelectOption of Campaign Names
        Created By   : Cognizant Technology Solutions
    */
    public List<SelectOption> getCampaign(){
        List<SelectOption> l_oListSelectOption = new List<SelectOption>();
        l_oListSelectOption.add(new SelectOption('','Alle'));
        Set<String> l_sSetCampaign = new Set<String>();
        for(ADvendio__MediaCampaign__c l_oMediaCampaign : i_oListMediaCampaign){
            l_sSetCampaign.add(l_oMediaCampaign.Name);
        }
        for(String l_sTemporary : l_sSetCampaign){
            l_oListSelectOption.add(new SelectOption(l_sTemporary,l_sTemporary));
        }
        l_oListSelectOption.sort();
        return l_oListSelectOption;
    }

    /*
        Method Name  : getAgency
        Parameters   : void
        Return Type  : list<SelectOption>
        Description  : This method is used for:
        1. Returning the list of SelectOption of Agency
        Created By   : Cognizant Technology Solutions
    */
    public List<SelectOption> getAgency(){
        List<SelectOption> l_oListSelectOption = new List<SelectOption>();
        l_oListSelectOption.add(new SelectOption('','Alle'));
        Set<String> l_sSetAgency = new Set<String>();
        for(ADvendio__MediaCampaign__c l_oMediaCampaign : i_oListMediaCampaign){
            if(l_oMediaCampaign.ADvendio__Agency__c != null)
            l_sSetAgency.add(l_oMediaCampaign.ADvendio__Agency__r.Name);
        }
        if(l_sSetAgency != null && l_sSetAgency.size() > 0)
        {
            for(String l_sTemporary : l_sSetAgency){
                if(l_sTemporary != null)
                l_oListSelectOption.add(new SelectOption(l_sTemporary,l_sTemporary));
            }
        }
        l_oListSelectOption.sort();
        return l_oListSelectOption;
    }

    /*
        Method Name  : getAdvertiser
        Parameters   : void
        Return Type  : list<SelectOption>
        Description  : This method is used for:
        1. Returning the list of SelectOption of Advertiser
        Created By   : Cognizant Technology Solutions
    */
    public List<SelectOption> getAdvertiser(){
        List<SelectOption> l_oListSelectOption = new List<SelectOption>();
        l_oListSelectOption.add(new SelectOption('','Alle'));
        Set<String> l_sSetAdvertiser = new Set<String>();
        for(ADvendio__MediaCampaign__c l_oMediaCampaign : i_oListMediaCampaign){
            if(l_oMediaCampaign.SomDig_WtAgBeziehung__c != null)
            l_sSetAdvertiser.add(l_oMediaCampaign.ADvendio__Account__r.Name);
        }
        system.debug('l_sSetAdvertiser-----'+l_sSetAdvertiser);

        if(l_sSetAdvertiser != null && l_sSetAdvertiser.size() > 0)
        {
            for(String l_sTemporary : l_sSetAdvertiser){
                if(l_sTemporary != null)
                l_oListSelectOption.add(new SelectOption(l_sTemporary,l_sTemporary));
            }
        }
        l_oListSelectOption.sort();
        return l_oListSelectOption;
    }

    /*
        Method Name  : getOfferNumber
        Parameters   : void
        Return Type  : list<SelectOption>
        Description  : This method is used for:
        1. Returning the list of SelectOption of OfferNumber
        Created By   : Cognizant Technology Solutions
    */
    public List<SelectOption> getOfferNumber(){
        List<SelectOption> l_oListSelectOption = new List<SelectOption>();
        l_oListSelectOption.add(new SelectOption('','Alle'));
        Set<String> l_sSetOfferNumber = new Set<String>();
        for(ADvendio__MediaCampaign__c l_oMediaCampaign : i_oListMediaCampaign){
            if(l_oMediaCampaign.ADvendio__Offer_Number__c != null)
            l_sSetOfferNumber.add(l_oMediaCampaign.ADvendio__Offer_Number__c);
        }
        if(l_sSetOfferNumber != null && l_sSetOfferNumber.size() > 0)
        {
            for(String l_sTemporary : l_sSetOfferNumber){
                if(l_sTemporary != null)
                l_oListSelectOption.add(new SelectOption(l_sTemporary,l_sTemporary));
            }
        }
        l_oListSelectOption.sort();
        return l_oListSelectOption;
    }

    /*
        Method Name  : getExportReport
        Parameters   : void
        Return Type  : list<SelectOption>
        Description  : This method is used for:
        1. Returning the list of SelectOption of Export Types
        Created By   : Cognizant Technology Solutions
    */
    public List<SelectOption> getExportReport(){
        List<SelectOption> l_oListSelectOption = new List<SelectOption>();
        l_oListSelectOption.add(new SelectOption('PDF Format','PDF Format'));
        l_oListSelectOption.add(new SelectOption('Excel Format','Excel Format'));
        l_oListSelectOption.add(new SelectOption('CSV Format','CSV Format'));
        return l_oListSelectOption;
    }

    /*
        Method Name  : CreateReport
        Parameters   : void
        Return Type  : PageReference
        Description  : This method is used for:
        1. Exporting the Report in Excel/CSV/PDF
        Created By   : Cognizant Technology Solutions
    */
    public PageReference CreateReport()
    {
        i_sFileName = System.Label.Position_View+'_'+UserInfo.getFirstName()+'_'+ System.now();
        i_sFileName = i_sFileName.replaceAll( '\\s+', '');
        BuildQuery();
        if(i_oListMediaCampaignReport!=null && i_oListMediaCampaignReport.size()>0)
        {
            if(i_sSelectedContentType == 'PDF Format')
            {
                Pagereference l_oPageReference = Page.Adv_CampaignItem_PositionReportPDF;
                i_sContentType='attachment; filename='+System.Label.Position_View+'_'+UserInfo.getFirstName()+'_'+ System.now()+''+'.pdf';
                i_sContentType= i_sContentType.replaceAll( '\\s+', '');
                l_oPageReference.getHeaders().put('content-disposition',i_sContentType);
                return l_oPageReference;
            }
            else if(i_sSelectedContentType == 'Excel Format')
            {
                i_sContentType='application/vnd.ms-excel#'+System.Label.Position_View+'_'+UserInfo.getFirstName()+'_'+ System.now()+'.xls';
                i_sContentType= i_sContentType.replaceAll( '\\s+', '');
                return Page.Adv_CampaignItem_PositionReportCSV;
            }
            else if (i_sSelectedContentType == 'CSV Format')
            {
                i_sContentType='text/csv#'+System.Label.Position_View+'_'+UserInfo.getFirstName()+'_'+ System.now()+'.csv';
                i_sContentType= i_sContentType.replaceAll( '\\s+', '');
                String l_sCSV = System.Label.Kampagne+','+
                System.Label.Status_Pos+','+
                System.Label.Pos_Nr_PR+','+
                System.Label.DFP_Pos_Nr_PR+','+
                System.Label.Werbemittel_PR+','+
                System.Label.Werbetreibender_PR+','+
                System.Label.Start_PR+','+
                System.Label.Ende_PR+','+
                System.Label.Abrechnungsart_PR+','+
                System.Label.Menge_PR+','+
                System.Label.SOLL_aktuell_PR+','+
                System.Label.IST_aktuell_PR+','+
                System.Label.risk+','+
                System.Label.DFP_Prognose_PR+','+
                System.Label.Screenshot_PR+','+
                System.Label.Kommentar_PR+','+
                System.Label.MB3_PR+','+
                System.Label.MN2_PR+','+
                System.Label.eTKP_PR+','+
                System.Label.Inhaber+','+
                '\n';

                //Executing the flow for bulk records.
                for(ADvendio__MediaCampaign__c l_oMediaCampaign : i_oListMediaCampaignReport)
                {
                    if(l_oMediaCampaign != null && l_oMediaCampaign.ADvendio__Advertising_Media__r != null && l_oMediaCampaign.ADvendio__Advertising_Media__r.size() > 0)
                    {
                        for(ADvendio__Campaign_Item__c l_oCampaignItem : l_oMediaCampaign.ADvendio__Advertising_Media__r)
                        {


                            if(l_oCampaignItem.ADvendio__Media_Campaign__r.Name!=null){
                                l_sCSV += l_oCampaignItem.ADvendio__Media_Campaign__r.Name + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }

                            if(l_oCampaignItem.SomDig_PositionStatus__c!=null){
                                l_sCSV += l_oCampaignItem.SomDig_PositionStatus__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.ADvendio__PositionNumber__c!=null){
                                l_sCSV += l_oCampaignItem.ADvendio__PositionNumber__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.SomDig_LineItemInAdServer__c!=null){
                                l_sCSV += l_oCampaignItem.SomDig_LineItemInAdServer__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.Name!=null){
                                l_sCSV += l_oCampaignItem.Name + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }

                            if(l_oCampaignItem.ADvendio__Media_Campaign__r.ADvendio__Account__r.Name!=null){
                                l_sCSV += l_oCampaignItem.ADvendio__Media_Campaign__r.ADvendio__Account__r.Name + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }

                            if(l_oCampaignItem.ADvendio__from_Date__c!=null){
                                Datetime l_dFrom = DateTime.newInstance(l_oCampaignItem.ADvendio__from_Date__c, System.now().Time());
                                l_sCSV += l_dFrom.format('"dd/MM/yyyy"') + ',';

                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.ADvendio__until_Date__c!=null){
                                Datetime l_dUntil = DateTime.newInstance(l_oCampaignItem.ADvendio__until_Date__c, System.now().Time());
                                l_sCSV += l_dUntil.format('"dd/MM/yyyy"') + ',';

                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.ADvendio__Billing_category__c!=null){
                                l_sCSV += l_oCampaignItem.ADvendio__Billing_category__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.ADvendio__Quantity__c!=null){
                                l_sCSV += l_oCampaignItem.ADvendio__Quantity__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.SomDig_AIClicksSollBisHeute__c!=null){
                                l_sCSV += l_oCampaignItem.SomDig_AIClicksSollBisHeute__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.SomDig_AiClicksIst__c!=null){
                                l_sCSV += l_oCampaignItem.SomDig_AiClicksIst__c  + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.SomDig_Risk__c!=null){
                                l_sCSV += l_oCampaignItem.SomDig_Risk__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.ADvendio__PerformanceIndicator__c!=null){
                                l_sCSV += l_oCampaignItem.ADvendio__PerformanceIndicator__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.Status_Screenshot__c!=null){
                                l_sCSV += l_oCampaignItem.Status_Screenshot__c  + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.SomDig_PAMKommentar__c!=null){
                                l_sCSV += l_oCampaignItem.SomDig_PAMKommentar__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }

                            if(l_oCampaignItem.ADvendio__Amount_B3__c!=null){
                                l_sCSV += l_oCampaignItem.ADvendio__Amount_B3__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }

                            if(l_oCampaignItem.ADvendio__Amount_net_net__c!=null){
                                l_sCSV += l_oCampaignItem.ADvendio__Amount_net_net__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.ADvendio__eCPC__c!=null){
                                l_sCSV += l_oCampaignItem.ADvendio__eCPC__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }
                            if(l_oCampaignItem.SomDig_Inhaber_Kuerzel__c!=null){
                                l_sCSV += l_oCampaignItem.SomDig_Inhaber_Kuerzel__c + ',';
                            }else
                            {
                                l_sCSV +=',';
                            }

                            l_sCSV += '\n';
                        }
                    }
                }
                i_sReportData = l_sCSV;
                if (i_sReportData != '')
                {
                    //pgRef.setRedirect(true);
                    return Page.Adv_CampaignItem_PositionReportCSV;
                }
                else
                return null;

                //}
            }  else
            return null;
        }
        else
        return null;
    }

    // Return a list of all PAM users
    private List<User> getAllPAMUsers() {
        return [
        SELECT Firstname, LastName, Id
          FROM User
         WHERE Profile.Name = 'SomDig_PAM'
           AND IsActive = TRUE
         ORDER BY Firstname ASC
        ];
    }

}