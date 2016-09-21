/*
    Class Name   : Adv_MediaCampaign_Report
    Description  : This is the Controller class for Adv_MediaCampaign_Report, Adv_MediaCampaign_ReportCSV and Adv_MediaCampaign_ReportPDF pages
    Created By   : Cognizant Technology Solutions
    Created On   : 6/13/2014
    Test Class   : Adv_MediaCampaign_Report_Test
*/
public with sharing class Adv_MediaCampaign_Report {
    // Campaign and selection set/variables
    private list<MediaCampaignWrapper> i_oListMediaCampaignWrapper {get; set;}

    // selection and filter
    public list<String> i_sListAlpha {get; set;}
    public String i_sAlphaFilter {get; set;}
    private String i_sQuery;

    // display sort and number
    public String i_sRecordPerPage {get; set;}
    public list<SelectOption> i_soListRecordPerPage {get; set;}
    public List<String> i_sListSelectedStatus {get; set;}{ i_sListSelectedStatus = new List<String>{''}; }
    public String i_sSortFieldSave;

    public String i_sSortField {
        get { if (i_sSortField == null) {i_sSortField = 'Name'; } return i_sSortField;  }
        set;
    }

    public String i_sSortDirection {
        get { if (i_sSortDirection == null) {  i_sSortDirection = 'asc'; } return i_sSortDirection;  }
        set;
    }
    public ApexPages.StandardSetController i_oStandardSetController {get; set;}

    //selected filter get/set variables
    public Integer i_nPAMStatusSize {get; set;}
    public List<String> i_sListSelectedAgency {get; set;} { i_sListSelectedAgency = new List<String>{''}; }
    public List<String> i_sListSelectedAdvertiser {get; set;} { i_sListSelectedAdvertiser = new List<String>{''}; }
    public List<String> i_sListSelectedOfferNumber {get; set;} { i_sListSelectedOfferNumber = new List<String>{''}; }
    public List<String> i_sListSelectedCampaign {get; set;} { i_sListSelectedCampaign = new List<String>{''}; }
    public List<String> i_sListUserselected { get; set; } { i_sListUserselected = new List<String>{''}; }
    public String i_sSearchOfferNumber {get; set;}
    public String i_sCloseCampaignId {get; set;}

    //report  variables
    public String i_sContentType{get; set;}
    public String i_sFileName{get; set;}
    public String i_sReportData {get; set;}
    public String i_sSelectedContentType{get;set;}

    //filtered media Campaign List
    public static List<ADvendio__MediaCampaign__c> i_oListMediaCampaignReport {get; private set; }

    //controls how many rows are displayed on page 1
    private static Integer i_nFIRST_BREAK = Integer.valueof(System.Label.PDF_Page_Break);
    //controls how many rows  are displayed on subsequent pages
    private static Integer i_nSUBSEQ_BREAKS = Integer.valueof(System.Label.PDF_Page_Break);
    public List<PDFWrapper> i_oListPDFWrapper {get; private set;}
    public List<ADvendio__MediaCampaign__c> i_oListMediaCampaignClone = new List<ADvendio__MediaCampaign__c>();

    /*
        Method Name  : Adv_MediaCampaign_Report
        Parameters   : void
        Return Type  : void
        Description  : This method is used for:
                       1. Initializing the variables and invoke the refreshController method
        Created By   : Cognizant Technology Solutions
    */
    public Adv_MediaCampaign_Report() {
        i_oListMediaCampaignWrapper = new list<MediaCampaignWrapper>();
        //records for page initialization
        i_soListRecordPerPage = new list<SelectOption>();
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
    public void refreshController()
    {
        BuildQuery();
        i_oStandardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(i_sQuery));
        // sets the number of records in each page set
        if(i_sRecordPerPage == null)
            i_sRecordPerPage = '200';
        i_oStandardSetController.setPageSize(Integer.valueOf(i_sRecordPerPage));
    }

    /*
        Method Name  : getMediaCampaign
        Parameters   : void
        Return Type  : list<MediaCampaignWrapper>
        Description  : This method is used for:
                       1. Returning the list of MediaCampaignWrapper class
        Created By   : Cognizant Technology Solutions
    */
    public list<MediaCampaignWrapper> getMediaCampaignWrapper() {
        i_oListMediaCampaignWrapper = new list<MediaCampaignWrapper>();
        if (i_oStandardSetController != null) {
            i_oListMediaCampaignClone = (list<ADvendio__MediaCampaign__c>)i_oStandardSetController.getRecords().deepClone(true,true,true);
            for (ADvendio__MediaCampaign__c l_oMediaCampaign : (list<ADvendio__MediaCampaign__c>)i_oStandardSetController.getRecords()) {
                i_oListMediaCampaignWrapper.add(new MediaCampaignWrapper(l_oMediaCampaign, false));
            }
        }
        return i_oListMediaCampaignWrapper;
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
        for(MediaCampaignWrapper l_oMediaCampaignWrapper : i_oListMediaCampaignWrapper){
            l_oMediaCampaignWrapper.i_oMediaCampaign.SomDig_PAMKommentar__c = l_oMediaCampaignWrapper.i_oMediaCampaign.SomDig_PAMKommentar2__c;
        }
        i_oStandardSetController.save();
        return null;
    }

    /*
        Method Name  : closeCampaign
        Parameters   : void
        Return Type  : PageReference
        Description  : This method is used for:
                       1. Close the Campaign record on click on Checkbox after confirmation
        Created By   : Cognizant Technology Solutions
    */
    public PageReference closeCampaign(){
        system.debug('####'+i_sCloseCampaignId);
        ADvendio__MediaCampaign__c l_oMediaCampaignClose = [select SomDig_StatusPAMCockpit__c from ADvendio__MediaCampaign__c where id =: i_sCloseCampaignId];
        l_oMediaCampaignClose.SomDig_StatusPAMCockpit__c = 'abgeschlossen';
        update l_oMediaCampaignClose;
        refreshController();
        return null;
    }

    /*
        Method Name  : doNext
        Parameters   : void
        Return Type  : void
        Description  : This method is used for:
                       1. Paginating to the next page after saving the records edited using inline editing
        Created By   : Cognizant Technology Solutions
    */
    public void doNext(){
        List<ADvendio__MediaCampaign__c> l_oListMediaCampaignUpdate = new List<ADvendio__MediaCampaign__c>();
        for (ADvendio__MediaCampaign__c l_oMediaCampaign : (list<ADvendio__MediaCampaign__c>)i_oStandardSetController.getRecords()) {
            for(ADvendio__MediaCampaign__c l_oMediaCampaignClone : i_oListMediaCampaignClone){
                system.debug('id: '+l_oMediaCampaign.id+'id1: '+l_oMediaCampaignClone.id);
                system.debug('PAM: '+l_oMediaCampaign.SomDig_PAMKommentar__c+'PAM1: '+l_oMediaCampaignClone.SomDig_PAMKommentar__c);
                if(l_oMediaCampaign.id == l_oMediaCampaignClone.id && l_oMediaCampaign.SomDig_PAMKommentar__c != l_oMediaCampaignClone.SomDig_PAMKommentar__c)
                    l_oListMediaCampaignUpdate.add(l_oMediaCampaign);
            }
        }
        if(l_oListMediaCampaignUpdate.size() > 0)
            i_oStandardSetController.save();
        i_oStandardSetController.next();
    }

    /*
        Method Name  : doPrevious
        Parameters   : void
        Return Type  : void
        Description  : This method is used for:
                       1. Paginating to the previous page after saving the records edited using inline editing
        Created By   : Cognizant Technology Solutions
    */
    public void doPrevious(){
        List<ADvendio__MediaCampaign__c> l_oListMediaCampaignUpdate = new List<ADvendio__MediaCampaign__c>();
        for (ADvendio__MediaCampaign__c l_oMediaCampaign : (list<ADvendio__MediaCampaign__c>)i_oStandardSetController.getRecords()) {
            for(ADvendio__MediaCampaign__c l_oMediaCampaignClone : i_oListMediaCampaignClone){
                system.debug('id: '+l_oMediaCampaign.id+'id1: '+l_oMediaCampaignClone.id);
                system.debug('PAM: '+l_oMediaCampaign.SomDig_PAMKommentar__c+'PAM1: '+l_oMediaCampaignClone.SomDig_PAMKommentar__c);
                if(l_oMediaCampaign.id == l_oMediaCampaignClone.id && l_oMediaCampaign.SomDig_PAMKommentar__c != l_oMediaCampaignClone.SomDig_PAMKommentar__c)
                    l_oListMediaCampaignUpdate.add(l_oMediaCampaign);
            }
        }
        if(l_oListMediaCampaignUpdate.size() > 0)
            i_oStandardSetController.save();
        i_oStandardSetController.previous();
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

        if (i_sAlphaFilter == null || i_sAlphaFilter.trim().length() == 0) {
            i_sAlphaFilter = 'All';
        }

        i_sQuery = 'SELECT SomDig_PAMStatusFlag__c,SomDig_StatusPAMCockpit__c,ADvendio__Offer_Number__c,Name,SomDig_IsRiskCount__c,SomDig_IsRiskStatus__c,' +
                                    ' ADvendio__Agency__c,ADvendio__Agency__r.Name,ADvendio__Campaign_Start_Date__c,ADvendio__Campaign_End_Date__c,' +
                                    ' SomDig_Abrechnungsart__c,SomDigNaechsterPositionStart__c,SomDigNaechsterPositionEnde__c,SomDig_LinkZurMediakampagneInDFP__c,' +
                                    ' SomDig_LetzterPositionEnde__c,SomDig_ScreenshotFlag__c,SomDig_PAMKommentar__c,SomDig_PAMKommentar2__c,SomDig_Inhaber_Kuerzel__c,' +
                                    ' SomDig_WtAgBeziehung__c,OwnerId,Owner.FirstName,SomDig_WtAgBeziehung__r.Name,ADvendio__Account__r.Name,SomDig_AdServerOrderId__c' +
            ' FROM ADvendio__MediaCampaign__c';

        l_sQueryWhere = BuildWhere(l_sQueryWhere, 'RecordTypeId in (SELECT Id FROM RecordType WHERE Name = \'Auftrag\' )');

        if (i_sAlphaFilter == 'Other') {
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(' + String.escapeSingleQuotes(i_sSortField) + ' < \'A\' OR ' +
                                    String.escapeSingleQuotes(i_sSortField) + ' > \'Z\') AND (NOT ' +
                                    String.escapeSingleQuotes(i_sSortField) + ' LIKE \'Z%\') ');
        } else if (i_sAlphaFilter != 'All') {
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(' + String.escapeSingleQuotes(i_sSortField) + ' LIKE \'' + String.escapeSingleQuotes(i_sAlphaFilter) + '%\')' );
        }

        if(i_sListSelectedStatus != null && String.isNotEmpty(i_sListSelectedStatus[0]))
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(SomDig_StatusPAMCockpit__c in : i_sListSelectedStatus)');
        else
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(SomDig_StatusPAMCockpit__c != \'abgeschlossen\')');

        if(i_sListSelectedAgency != null && i_sListSelectedAgency.size()>0 && String.isNotEmpty(i_sListSelectedAgency[0]))
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__Agency__r.Name in : i_sListSelectedAgency)');

        if(i_sListSelectedAdvertiser != null && i_sListSelectedAdvertiser.size()>0  && String.isNotEmpty(i_sListSelectedAdvertiser[0]))
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__Account__r.Name in : i_sListSelectedAdvertiser)');

        if(i_sListSelectedOfferNumber != null && i_sListSelectedOfferNumber.size()>0  && String.isNotEmpty(i_sListSelectedOfferNumber[0]))
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__Offer_Number__c in : SelectedOfferNumber)');

        if(i_sListSelectedCampaign != null && i_sListSelectedCampaign.size()>0 && String.isNotEmpty(i_sListSelectedCampaign[0]))
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(Name in : i_sListSelectedCampaign)');

        if (i_sSearchOfferNumber != null) {
            l_sQueryWhere = BuildWhere(l_sQueryWhere, ' (ADvendio__Offer_Number__c LIKE \'%' + String.escapeSingleQuotes(i_sSearchOfferNumber) + '%\')');
        }

        Set<String> l_sSetUserId = new Set<String>();
        String l_sUserFilter = '';
        //if(i_sListUserselected.size()==0)
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

                for(User l_oUser : getAllPAMUsers())
                l_sSetUserId.add(l_oUser.id);
            }
        } else if (String.isEmpty(i_sListUserselected[0]) && i_sSearchOfferNumber != null && String.isNotEmpty(i_sSearchOfferNumber)) {
            for(User l_oUser : getAllPAMUsers()) {
                l_sSetUserId.add(l_oUser.id);
            }
        }
        l_sUserFilter = separateSetForDynamicSOQL(l_sSetUserId);
        l_sQueryWhere = BuildWhere(l_sQueryWhere, '(OwnerId In (' + l_sUserFilter + '))');

        i_sQuery += l_sQueryWhere;

        /*if(i_sSortField == Null || i_sSortField == '')
            i_sQuery += ' ORDER BY Owner.firstName,ADvendio__Campaign_Start_Date__c' + ' ' + String.escapeSingleQuotes(i_sSortDirection) + ' LIMIT 10000';
        else*/
            i_sQuery += ' ORDER BY ' + String.escapeSingleQuotes(i_sSortField) + ' ' + String.escapeSingleQuotes(i_sSortDirection) + ' LIMIT 10000';

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


    public class MediaCampaignWrapper {
        public Boolean i_bCheck {get;set;}
        public ADvendio__MediaCampaign__c i_oMediaCampaign {get;set;}

        // sub-class initialization
        public MediaCampaignWrapper(ADvendio__MediaCampaign__c p_oMediaCampaign, Boolean p_bCheck){
            i_oMediaCampaign = p_oMediaCampaign;
            i_bCheck = p_bCheck;
        }
    }

    /*
        Method Name  : getPAMStatus
        Parameters   : void
        Return Type  : list<SelectOption>
        Description  : This method is used for:
                       1. Returning the list of SelectOption of PAM Status
        Created By   : Cognizant Technology Solutions
    */
    public List<SelectOption> getPAMStatus()
    {
        List<SelectOption> l_oListSelectOption = new List<SelectOption>();
        l_oListSelectOption.add(new SelectOption('','Alle'));
        for( Schema.PicklistEntry l_oPickListEntry : ADvendio__MediaCampaign__c.SomDig_StatusPAMCockpit__c.getDescribe().getPicklistValues()){
            l_oListSelectOption.add(new SelectOption(l_oPickListEntry.getLabel(), l_oPickListEntry.getValue()));
        }
        //options.add(new SelectOption(System.Label.risk, System.Label.risk));
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
        for(MediaCampaignWrapper l_oMediaCampaignWrapper : i_oListMediaCampaignWrapper){
            if(l_oMediaCampaignWrapper.i_oMediaCampaign.ADvendio__Agency__c != null)
                l_sSetAgency.add(l_oMediaCampaignWrapper.i_oMediaCampaign.ADvendio__Agency__r.Name);
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
        system.debug('i_oListMediaCampaignReport-----'+i_oListMediaCampaignReport);
        for(MediaCampaignWrapper l_oMediaCampaignWrapper : i_oListMediaCampaignWrapper){
            if(l_oMediaCampaignWrapper.i_oMediaCampaign.SomDig_WtAgBeziehung__c != null)
                l_sSetAdvertiser.add(l_oMediaCampaignWrapper.i_oMediaCampaign.ADvendio__Account__r.Name);
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
        for(MediaCampaignWrapper l_oMediaCampaignWrapper : i_oListMediaCampaignWrapper){
            if(l_oMediaCampaignWrapper.i_oMediaCampaign.ADvendio__Offer_Number__c != null)
                l_sSetOfferNumber.add(l_oMediaCampaignWrapper.i_oMediaCampaign.ADvendio__Offer_Number__c);
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
        for(MediaCampaignWrapper l_oMediaCampaignWrapper : i_oListMediaCampaignWrapper){
            l_sSetCampaign.add(l_oMediaCampaignWrapper.i_oMediaCampaign.Name);
        }
        for(String l_sTemporary : l_sSetCampaign){
            l_oListSelectOption.add(new SelectOption(l_sTemporary,l_sTemporary));
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
    public PageReference CreateCsvReport()
    {
       i_sFileName = System.Label.Campaign_Report+'_'+UserInfo.getFirstName()+'_'+ System.now();
       i_sFileName = i_sFileName.replaceAll( '\\s+', '');
       buildQuery();
       prepareQuoteLinesForPrinting();
       if(i_oListMediaCampaignReport!=null && i_oListMediaCampaignReport.size()>0)
       {
       //if Selected Content Type is PDF type
        if(i_sSelectedContentType == 'PDF Format')
        {
            Pagereference l_oPageReference = Page.Adv_MediaCampaign_ReportPDF;
            i_sContentType='attachment; filename='+System.Label.Campaign_Report+'_'+UserInfo.getFirstName()+'_'+ System.now()+''+'.pdf';
            i_sContentType= i_sContentType.replaceAll( '\\s+', '');
            l_oPageReference.getHeaders().put('content-disposition',i_sContentType);
            return l_oPageReference;
        }
        //if Selected Content Type is Excel type
        else if(i_sSelectedContentType == 'Excel Format')
        {
            i_sContentType='application/vnd.ms-excel#'+System.Label.Campaign_Report+'_'+UserInfo.getFirstName()+'_'+ System.now()+''+'.xls';
            i_sContentType= i_sContentType.replaceAll( '\\s+', '');
            return Page.Adv_MediaCampaign_ReportCSV;
        }
        //if Selected Content Type is CSV type
        else if (i_sSelectedContentType == 'CSV Format')
        {
            i_sContentType='text/csv#'+System.Label.Campaign_Report+'_'+UserInfo.getFirstName()+'_'+ System.now()+''+'.csv';
            i_sContentType= i_sContentType.replaceAll( '\\s+', '');
            String l_sCSV = System.Label.Flag+','+
            System.Label.Status+','+
            System.Label.risk+','+
            System.Label.Kampagnennummer+','+
            System.Label.Kampagne+','+
            System.Label.Werbetreibender+','+
            System.Label.Agentur+','+
            System.Label.Start+','+
            System.Label.Ende+','+
            System.Label.Abrechnungsart+','+
            System.Label.N_chster_Positions_Start+','+
            System.Label.N_chster_Positions_Ende+','+
            System.Label.Letzter_Positions_Ende+','+
            System.Label.Screenshot_versendet+','+
            System.Label.Kommentar+','+
            System.Label.Inhaber+','+
            '\n';
            //Executing the flow for bulk records.
            for(ADvendio__MediaCampaign__c l_oMediaCampaign : i_oListMediaCampaignReport)
            {

                if(l_oMediaCampaign.SomDig_PAMStatusFlag__c!=null){
                l_sCSV += l_oMediaCampaign.SomDig_PAMStatusFlag__c + ',';
                }else
                {
                l_sCSV +=',';
                }

                if(l_oMediaCampaign.SomDig_StatusPAMCockpit__c!=null){
                l_sCSV += l_oMediaCampaign.SomDig_StatusPAMCockpit__c + ',';
                }else
                {
                l_sCSV +=',';
                }
                /*if(l_oMediaCampaign.SomDig_IsRiskStatus__c!=null){
                l_sCSV += l_oMediaCampaign.SomDig_IsRiskStatus__c + ',';
                }else
                {
                l_sCSV +=',';
                }*/
                if(l_oMediaCampaign.ADvendio__Offer_Number__c!=null){
                l_sCSV += l_oMediaCampaign.ADvendio__Offer_Number__c + ',';
                }else
                {
                l_sCSV +=',';
                }

                if(l_oMediaCampaign.Name!=null){
                l_sCSV += l_oMediaCampaign.Name + ',';
                }else
                {
                l_sCSV +=',';
                }
                if(l_oMediaCampaign.ADvendio__Account__r.Name!=null){
                l_sCSV += l_oMediaCampaign.ADvendio__Account__r.Name + ',';
                }else
                {
                l_sCSV +=',';
                }

                if(l_oMediaCampaign.ADvendio__Agency__c!=null){
               l_sCSV += l_oMediaCampaign.ADvendio__Agency__c + ',';
                }else
                {
                l_sCSV +=',';
                }
                if(l_oMediaCampaign.ADvendio__Campaign_Start_Date__c!=null){
                //  l_oMediaCampaign.Fix_Date__c.format('dd-MM-yyyy hh:mm:ss'));
                Datetime l_dStart = DateTime.newInstance(l_oMediaCampaign.ADvendio__Campaign_Start_Date__c, System.now().Time());
                l_sCSV += l_dStart.format('"dd/MM/yyyy"') + ',';

                }else
                {
                l_sCSV +=',';
                }
                if(l_oMediaCampaign.ADvendio__Campaign_End_Date__c!=null){
                Datetime l_dEnd = DateTime.newInstance(l_oMediaCampaign.ADvendio__Campaign_End_Date__c, System.now().Time());
                l_sCSV += l_dEnd.format('"dd/MM/yyyy"') + ',';

                }else
                {
                l_sCSV +=',';
                }


                if(l_oMediaCampaign.SomDig_Abrechnungsart__c!=null){
                l_sCSV += l_oMediaCampaign.SomDig_Abrechnungsart__c + ',';
                }else
                {
                l_sCSV +=',';
                }
                if(l_oMediaCampaign.SomDigNaechsterPositionStart__c!=null){
                l_sCSV += l_oMediaCampaign.SomDigNaechsterPositionStart__c + ',';
                }else
                {
                l_sCSV +=',';
                }

                if(l_oMediaCampaign.SomDigNaechsterPositionEnde__c!=null){
                l_sCSV += l_oMediaCampaign.SomDigNaechsterPositionEnde__c + ',';
                }else
                {
                l_sCSV +=',';
                }

                if(l_oMediaCampaign.SomDig_LetzterPositionEnde__c!=null){
                l_sCSV += l_oMediaCampaign.SomDig_LetzterPositionEnde__c  + ',';
                }else
                {
                l_sCSV +=',';
                }

                if(l_oMediaCampaign.SomDig_ScreenshotFlag__c!=null){
                l_sCSV += l_oMediaCampaign.SomDig_ScreenshotFlag__c + ',';
                }else
                {
                l_sCSV +=',';
                }

                if(l_oMediaCampaign.SomDig_PAMKommentar__c!=null){
                l_sCSV += l_oMediaCampaign.SomDig_PAMKommentar__c + ',';
                }else
                {
                l_sCSV +=',';
                }

                if(l_oMediaCampaign.SomDig_Inhaber_Kuerzel__c!=null){
                l_sCSV += l_oMediaCampaign.SomDig_Inhaber_Kuerzel__c + ',';
                }else
                {
                l_sCSV +=',';
                }

                l_sCSV += '\n';

            }
            i_sReportData = l_sCSV;
            if (i_sReportData != '')
            {
                //pgRef.setRedirect(true);
                return Page.Adv_MediaCampaign_ReportCSV;
            }
            else
                return null;

            }
            else
                return null;
        }
        else
            return null;
    }

    /*
        Method Name  : prepareQuoteLinesForPrinting
        Parameters   : void
        Return Type  : void
        Description  : This method is used for:
                       1. Preparing the List of Campaign records to render in pages in PDF
        Created By   : Cognizant Technology Solutions
    */
    private void prepareQuoteLinesForPrinting()
    {
        i_oListPDFWrapper = new List<PDFWrapper>();
        ADvendio__MediaCampaign__c[] l_oListCampaignItem = new ADvendio__MediaCampaign__c[]{};
        Integer l_nCounter = 0;
        boolean l_bFirstBreakFound = false;
        if(i_oListMediaCampaignReport != null && i_oListMediaCampaignReport.size() > 0)
        {
        for(ADvendio__MediaCampaign__c l_oMediaCampaign : i_oListMediaCampaignReport)
        {
            if(!l_bFirstBreakFound)
            {
                if(l_nCounter < i_nFIRST_BREAK)
                {
                    l_oListCampaignItem.add(l_oMediaCampaign);
                    l_nCounter++;
                }
                if(l_nCounter == i_nFIRST_BREAK)
                {
                    l_bFirstBreakFound = true;
                    l_nCounter = 0;
                    i_oListPDFWrapper.add(new PDFWrapper(l_oListCampaignItem));
                    l_oListCampaignItem = new ADvendio__MediaCampaign__c[]{};
                }
            }
            else
            {
                if(l_nCounter < i_nSUBSEQ_BREAKS)
                {
                    l_oListCampaignItem.add(l_oMediaCampaign);
                    l_nCounter++;
                }
                if(l_nCounter == i_nSUBSEQ_BREAKS)
                {
                    l_nCounter = 0;
                    i_oListPDFWrapper.add(new PDFWrapper(l_oListCampaignItem));
                    l_oListCampaignItem = new ADvendio__MediaCampaign__c[]{};
                }
            }
        }
        }
        //if we have finished looping and have some quotes left lets assign them
        if(!l_oListCampaignItem.isEmpty())
            i_oListPDFWrapper.add(new PDFWrapper(l_oListCampaignItem));
            if(i_oListPDFWrapper!=null && i_oListPDFWrapper.size()>0)
                i_oListPDFWrapper[i_oListPDFWrapper.size() - 1].i_sPageBreak = 'page-break-after:avoid;';
    }

    public class PDFWrapper{
        public String i_sPageBreak {get; set;}
        public ADvendio__MediaCampaign__c[] i_oListCampaignItem {get; set;}

        public PDFWrapper(ADvendio__MediaCampaign__c[] p_oListCampaignItem){
            i_sPageBreak = 'page-break-after:always;';
            i_oListCampaignItem = p_oListCampaignItem;
        }
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