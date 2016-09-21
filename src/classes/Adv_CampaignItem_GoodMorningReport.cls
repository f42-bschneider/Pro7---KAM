/*
    Class Name   : Adv_CampaignItem_GoodMorningReport
    Description  : This is the Controller class for Adv_CampaignItem_GoodMorningReport, Adv_CampaignItem_GoodMorningReportCSV and Adv_CampaignItem_GoodMorningReportPDF pages
    Created By   : Cognizant Technology Solutions
    Created On   : 6/13/2014
    Test Class   : Adv_CampaignItem_GoodMorningReport_Test
*/
public with sharing class Adv_CampaignItem_GoodMorningReport {
    // Media Campaign and selection set/variables
    private list<ADvendio__Campaign_Item__c> i_oListCampaignItem {get; set;}
    private list<CampaignItemWrapper> i_oListCampaignItemWrapper {get; set;}

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
        get { if (i_sSortField == null) {i_sSortField = 'ADvendio__Media_Campaign__r.Name'; } return i_sSortField;  }
        set;
    }

    public String i_sSortDirection {
        get { if (i_sSortDirection == null) {  i_sSortDirection = 'asc'; } return i_sSortDirection;  }
        set;
    }
    public List<String> i_sListUserselected { get; set; } { i_sListUserselected = new List<String>{''}; }
    public ADvendio__Campaign_Item__c i_oCampaignItem {get; set;}
    public Integer i_nPAMStatusSize {get; set;}
    public List<String> i_sListSelectedCampaign {get; set;} { i_sListSelectedCampaign = new List<String>{''}; }
    //report  variables
    public String i_sContentType{get; set;}
    public String i_sFileName{get; set;}
    public String i_sReportData {get; set;}
    public String i_sSelectedContentType{get;set;}
    public static List<ADvendio__Campaign_Item__c> i_oListCampaignItemReport {get; private set; }
    //controls how many rows are displayed on page 1
    private static Integer i_nFIRST_BREAK = Integer.valueof(System.Label.PDF_Page_Break);
    //controls how many rows  are displayed on subsequent pages
    private static Integer i_nSUBSEQ_BREAKS = Integer.valueof(System.Label.PDF_Page_Break);
    public List<PDFWrapper> i_oListPDFWrapper {get; private set;}
    public List<ADvendio__Campaign_Item__c> i_oListCampaignItemClone = new List<ADvendio__Campaign_Item__c>();
    public Date i_dFrom;
    public Date i_dUntil;

    /*
        Method Name  : Adv_CampaignItem_GoodMorningReport
        Parameters   : void
        Return Type  : void
        Description  : This method is used for:
                       1. Initializing the variables and invoke the refreshController method
        Created By   : Cognizant Technology Solutions
    */
    public Adv_CampaignItem_GoodMorningReport() {

        // initialization Media Campaign List and Campaign Line Items
        i_oCampaignItem = new ADvendio__Campaign_Item__c();
        i_oListCampaignItem = new list<ADvendio__Campaign_Item__c>();
        i_oListCampaignItemWrapper = new list<CampaignItemWrapper>();
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
        refreshController();
    }


    public ApexPages.StandardSetController i_oStandardSetController {get; set;}

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
        i_oStandardSetController.setPageSize(Integer.valueOf(i_sRecordPerPage));
    }

    /*
        Method Name  : getCampaignItemWrapper
        Parameters   : void
        Return Type  : list<CampaignItemWrapper>
        Description  : This method is used for:
                       1. Returning the list of CampaignItemWrapper class
        Created By   : Cognizant Technology Solutions
    */
    public list<CampaignItemWrapper> getCampaignItemWrapper() {
        i_oListCampaignItemWrapper = new list<CampaignItemWrapper>();
        i_oListCampaignItemClone = (list<ADvendio__Campaign_Item__c>)i_oStandardSetController.getRecords().deepClone(true,true,true);
        for (ADvendio__Campaign_Item__c l_oCampaignItem : (list<ADvendio__Campaign_Item__c>)i_oStandardSetController.getRecords()) {
            i_oListCampaignItemWrapper.add(new CampaignItemWrapper(l_oCampaignItem, false));
        }
        return i_oListCampaignItemWrapper;
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

        i_dFrom = i_oCampaignItem.ADvendio__from_Date__c;
        i_dUntil = i_oCampaignItem.ADvendio__until_Date__c;

        i_sQuery = 'SELECT Name,SomDig_StatusFlagPosition__c,SomDig_PositionStatus__c,ADvendio__from_Date__c,ADvendio__Amount_net_net__c,ADvendio__eCPC__c,' +
                                    ' ADvendio__until_Date__c,ADvendio__PositionNumber__c,ADvendio__Billing_category__c,ADvendio__Media_Campaign__r.ADvendio__Account__r.Name,' +
                                    ' ADvendio__Quantity__c,SomDig_AIClicksSollBisHeute__c,SomDig_AiClicksIst__c,SomDig_Risk__c,ADvendio__Media_Campaign__r.ADvendio__Account__c,' +
                                    ' ADvendio__PerformanceIndicator__c,ADvendio__Adserver_ID_Order_ID__c,SomDig_LineItemInAdServer__c,' +
                                    ' SomDig_PAMKommentar__c,SomDig_Unterlieferungsflag__c,SomDig_Mediakampagnennummer__c,'+
                                    ' ADvendio__Media_Campaign__c,ADvendio__Media_Campaign__r.Name,ADvendio__Media_Campaign__r.RecordType.Name,' +
                                    ' SomDig_Werbetreibender__c,SomDig_AIClicksErreichbar__c,SomDig_RiskMN3Umsatz__c,ADvendio__Media_Campaign__r.ADvendio__Offer_Number__c,' +
                                    ' SomDig_LeistungskennzahlVortag__c,ADvendio__Media_Campaign__r.OwnerId,Status_Screenshot__c,' +
                                    ' SomDig_Inhaber_Kuerzel__c,ADvendio__Media_Campaign__r.Owner.FirstName,ADvendio__Media_Campaign__r.ADvendio__Agency__r.Name' +
            ' FROM ADvendio__Campaign_Item__c';

        l_sQueryWhere = BuildWhere(l_sQueryWhere, 'ADvendio__Media_Campaign__r.SomDig_StatusPAMCockpit__c != \'abgeschlossen\'');

        l_sQueryWhere = BuildWhere(l_sQueryWhere, 'ADvendio__Media_Campaign__r.RecordType.Name = \'Auftrag\'');

        if (i_sAlphaFilter == 'Other') {
            if(i_sSortField == null || i_sSortField == '')
                i_sSortField = 'ADvendio__Media_Campaign__r.Owner.FirstName';
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(' + String.escapeSingleQuotes(i_sSortField) + ' < \'A\' OR ' +
                                    String.escapeSingleQuotes(i_sSortField) + ' > \'Z\') AND (NOT ' +
                                    String.escapeSingleQuotes(i_sSortField) + ' LIKE \'Z%\') ');
        } else if (i_sAlphaFilter != 'All') {
            if(i_sSortField == null || i_sSortField == '')
                i_sSortField = 'ADvendio__Media_Campaign__r.Name';
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(' + String.escapeSingleQuotes(i_sSortField) + ' LIKE \'' + String.escapeSingleQuotes(i_sAlphaFilter) + '%\')' );
        }

        if(i_sListSelectedStatus != null && String.isNotEmpty(i_sListSelectedStatus[0]))
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(SomDig_PositionStatus__c in : i_sListSelectedStatus)');
        else
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(SomDig_PositionStatus__c in (\'abgelaufen-unterliefert\',\'abgelaufen-erfüllt\',\'Auslieferung-@Risk\'))');

        if(i_sListSelectedCampaign != null && i_sListSelectedCampaign.size()>0 && String.isNotEmpty(i_sListSelectedCampaign[0]))
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__Media_Campaign__r.Name in : i_sListSelectedCampaign)');

        if(i_dFrom != null)
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__from_Date__c >=: i_dFrom)');

        if(i_dUntil != null)
            l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__until_Date__c <=: i_dUntil)');

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
                for(User l_oUser : [select Firstname,LastName,Id from User where Profile.Name = 'SomDig_PAM' and IsActive=true order by Firstname asc])
                l_sSetUserId.add(l_oUser.id);
            }
        }
        l_sUserFilter = separateSetForDynamicSOQL(l_sSetUserId);
        l_sQueryWhere = BuildWhere(l_sQueryWhere, '(ADvendio__Media_Campaign__r.OwnerId In (' + l_sUserFilter + '))');

        i_sQuery += l_sQueryWhere;
        if(i_sSortField == null || i_sSortField == '')
            i_sQuery += ' ORDER BY ADvendio__Media_Campaign__r.Name ' + String.escapeSingleQuotes(i_sSortDirection) + ' LIMIT 10000';
        else
            i_sQuery += ' ORDER BY ' + String.escapeSingleQuotes(i_sSortField) + ' ' + String.escapeSingleQuotes(i_sSortDirection) + ' LIMIT 10000';

        system.debug('i_sQuery:' + i_sQuery);

        i_oListCampaignItemReport = Database.query(i_sQuery);
    }


    /*
        Method Name  : BuildWhere
        Parameters   : String, String
        Return Type  : String
        Description  : This method is used for:
                       1. Building the Dynamic Where Query based on the Condition
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

    /*
        Class Name   : CampaignItemWrapper
        Description  : This class is the Wrapper class to hold boolean and Campaign Item
        Created By   : Cognizant Technology Solutions
        Created On   : 5/5/2014
        Test Class   : Adv_CampaignItem_GoodMorningReport_Test
    */
    public class CampaignItemWrapper {
        public Boolean i_bCheck {get;set;}
        public ADvendio__Campaign_Item__c i_oCampaignItem {get;set;}

        // sub-class initialization
        public CampaignItemWrapper(ADvendio__Campaign_Item__c p_oCampaignItem, Boolean p_bCheck){
            i_oCampaignItem = p_oCampaignItem;
            i_bCheck = p_bCheck;
        }
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
        for( Schema.PicklistEntry l_oPickListEntry : ADvendio__Campaign_Item__c.SomDig_PositionStatus__c.getDescribe().getPicklistValues()){
            if(l_oPickListEntry.getLabel() == 'abgelaufen-unterliefert' || l_oPickListEntry.getLabel() == 'abgelaufen-erfüllt' || l_oPickListEntry.getLabel() == 'Auslieferung-@Risk')
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
        for (User l_oUser : [select Firstname,LastName,Id from User where Profile.Name = 'SomDig_PAM' and IsActive=true order by Firstname asc]) {
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
        for(CampaignItemWrapper l_oCampaignItemWrapper : i_oListCampaignItemWrapper){
            l_sSetCampaign.add(l_oCampaignItemWrapper.i_oCampaignItem.ADvendio__Media_Campaign__r.Name);
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
        List<SelectOption> l_oListSelectOption= new List<SelectOption>();
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
       i_sFileName = System.Label.Good_Morning_Report+'_'+UserInfo.getFirstName()+'_'+ System.now();
       i_sFileName = i_sFileName.replaceAll( '\\s+', '');
       BuildQuery();
       prepareQuoteLinesForPrinting();
       if(i_oListCampaignItemReport != null && i_oListCampaignItemReport.size() > 0)
       {
       system.debug('i_oListCampaignItemReport--'+i_oListCampaignItemReport);
       //if Selected Content Type is PDF type
        if(i_sSelectedContentType == 'PDF Format')
        {
            Pagereference l_oPageReference = Page.Adv_CampaignItem_GoodMorningReportPDF;
            i_sContentType='attachment; filename='+System.Label.Good_Morning_Report+'_'+UserInfo.getFirstName()+'_'+ System.now()+''+'.pdf';
            i_sContentType= i_sContentType.replaceAll( '\\s+', '');
            l_oPageReference.getHeaders().put('content-disposition',i_sContentType);
            return l_oPageReference;
        }
        //if Selected Content Type is Excel type
        else if(i_sSelectedContentType == 'Excel Format')
        {
            i_sContentType='application/vnd.ms-excel#'+System.Label.Good_Morning_Report+'_'+UserInfo.getFirstName()+'_'+ System.now()+'.xls';
            i_sContentType= i_sContentType.replaceAll( '\\s+', '');
            return Page.Adv_CampaignItem_GoodMorningReportCSV;
        }
         //if Selected Content Type is CSV type
        else if (i_sSelectedContentType == 'CSV Format')
        {
            i_sContentType='text/csv#'+System.Label.Good_Morning_Report+'_'+UserInfo.getFirstName()+'_'+ System.now()+''+'.csv';
            i_sContentType= i_sContentType.replaceAll( '\\s+', '');
            String l_sCSV =
            System.Label.Status_Pos_GM+','+
            System.Label.Kampagnen_Nr_GM+','+
            System.Label.Kampagne_GM+','+
            Schema.ADvendio__Campaign_Item__c.fields.SomDig_Werbetreibender__c.getDescribe().getLabel()+','+
            System.Label.Agentur_GM+','+
            System.Label.Pos_Nr_GM+','+
            System.Label.Werbemittel_GM+','+
            System.Label.Start_GM+','+
            System.Label.Ende_GM+','+
            System.Label.Abrechnungsart_GM+','+
            System.Label.IST_aktuell_GM+','+
            Schema.ADvendio__Campaign_Item__c.fields.SomDig_Risk__c.getDescribe().getLabel()+','+
            System.Label.SOLL_aktuell_GM+','+
            System.Label.DFP_Prognose_GM+','+
            System.Label.DFP_Prognose_Vortag_GM+','+
            System.Label.MN2_GM+','+
            System.Label.eTKP_GM+','+
            System.Label.Inhaber_GM+','+
            '\n';
            //Executing the flow for bulk records.
            for(ADvendio__Campaign_Item__c l_oCampaignItem : i_oListCampaignItemReport)
            {

                //uncomment below  Code if customer want Flag Image URL in Generated CSV File.
                /*if(l_oCampaignItem.SomDig_Unterlieferungsflag__c!=null){
                l_sCSV += l_oCampaignItem.SomDig_Unterlieferungsflag__c + ',';
                }else
                {
                l_sCSV +=',';
                }*/
                if(l_oCampaignItem.SomDig_PositionStatus__c!=null){
                    l_sCSV += l_oCampaignItem.SomDig_PositionStatus__c + ',';
                }else
                {
                    l_sCSV +=',';
                }

                if(l_oCampaignItem.SomDig_Mediakampagnennummer__c!=null){
                    l_sCSV += l_oCampaignItem.SomDig_Mediakampagnennummer__c + ',';
                }else
                {
                    l_sCSV +=',';
                }
                if(l_oCampaignItem.ADvendio__Media_Campaign__r.Name!=null){
                    l_sCSV += l_oCampaignItem.ADvendio__Media_Campaign__r.Name + ',';
                }else
                {
                    l_sCSV +=',';
                }

                if(l_oCampaignItem.SomDig_Werbetreibender__c!=null){
                    l_sCSV += l_oCampaignItem.SomDig_Werbetreibender__c + ',';
                }else
                {
                    l_sCSV +=',';
                }
                if(l_oCampaignItem.ADvendio__Media_Campaign__r.ADvendio__Agency__r.Name!=null){
                    l_sCSV += l_oCampaignItem.ADvendio__Media_Campaign__r.ADvendio__Agency__r.Name + ',';
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
                if(l_oCampaignItem.Name!=null){
                    l_sCSV += l_oCampaignItem.Name + ',';
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
                if(l_oCampaignItem.SomDig_AiClicksIst__c!=null){
                    l_sCSV += l_oCampaignItem.SomDig_AiClicksIst__c + ',';
                }else
                {
                    l_sCSV +=',';
                }

                if(l_oCampaignItem.SomDig_Risk__c!=null){
                    l_sCSV += l_oCampaignItem.SomDig_Risk__c  + ',';
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
                if(l_oCampaignItem.ADvendio__PerformanceIndicator__c!=null){
                    l_sCSV += l_oCampaignItem.ADvendio__PerformanceIndicator__c + ',';
                }else
                {
                    l_sCSV +=',';
                }
                if(l_oCampaignItem.SomDig_LeistungskennzahlVortag__c!=null){
                    l_sCSV += l_oCampaignItem.SomDig_LeistungskennzahlVortag__c + ',';
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
            i_sReportData = l_sCSV;
            if (i_sReportData != '')
            {
                return Page.Adv_CampaignItem_GoodMorningReportCSV;
            }
            else
                return null;

        }  else
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
                       1. Preparing the List of Campaign Item records to render in pages in PDF
        Created By   : Cognizant Technology Solutions
    */
    private void prepareQuoteLinesForPrinting()
    {
        i_oListPDFWrapper = new List<PDFWrapper>();
        ADvendio__Campaign_Item__c[] l_oListCampaignItem = new ADvendio__Campaign_Item__c[]{};
        Integer l_nCounter = 0;
        boolean l_bFirstBreakFound = false;
        system.debug('i_oListCampaignItemReport---'+i_oListCampaignItemReport);
        if(i_oListCampaignItemReport != null && i_oListCampaignItemReport.size() > 0)
        {
            for(ADvendio__Campaign_Item__c l_oCampaignItem : i_oListCampaignItemReport)
            {
                if(!l_bFirstBreakFound)
                {
                    if(l_nCounter < i_nFIRST_BREAK)
                    {
                        l_oListCampaignItem.add(l_oCampaignItem);
                        l_nCounter++;
                    }
                    if(l_nCounter == i_nFIRST_BREAK)
                    {
                        l_bFirstBreakFound = true;
                        l_nCounter = 0;
                        i_oListPDFWrapper.add(new PDFWrapper(l_oListCampaignItem));
                        l_oListCampaignItem = new ADvendio__Campaign_Item__c[]{};
                    }
                }
                else
                {
                    if(l_nCounter < i_nSUBSEQ_BREAKS)
                    {
                        l_oListCampaignItem.add(l_oCampaignItem);
                        l_nCounter++;
                    }
                    if(l_nCounter == i_nSUBSEQ_BREAKS)
                    {
                        l_nCounter = 0;
                        i_oListPDFWrapper.add(new PDFWrapper(l_oListCampaignItem));
                        l_oListCampaignItem = new ADvendio__Campaign_Item__c[]{};
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
        public ADvendio__Campaign_Item__c[] i_oListCampaignItem {get; set;}

        public PDFWrapper(ADvendio__Campaign_Item__c[] p_oListCampaignItem){
            i_sPageBreak = 'page-break-after:always;';
            i_oListCampaignItem = p_oListCampaignItem;
        }
    }
}