/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* Ven_OppPipelineCmpCtrl
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         2015/10/12
* @description
* @lastchange
* @objects
* =================================================================
*/
public with sharing class Ven_OppPipeline_CmpCtrl {

    private String oppId{get;set;}

    private static List<String> OPP_STAGES{get;set;}
    private static List<String> IMS_ROLES{get;set;}
    private static List<String> SCOUT_ROLE{get;set;}
    private static List<String> ANALYST_ROLE{get;set;}
    private static String IM_ROLE{get;set;}
    private static String AUSTRIA_ROLE{get;set;}
    private static String SWITZERLAND_ROLE{get;set;}

    /*****************
    *
    *****************/
    public PageReference redirect(){
        return new PageReference('/c/Ven_OppPipeApp.app');
    }

    public Ven_OppPipeline_CmpCtrl(ApexPages.StandardController sc){
        oppId = sc.getId();
    }

    public Ven_OppPipeline_CmpCtrl(){

    }

    private static void initSettings(){
        OPP_STAGES = new List<String>();
        OPP_STAGES.add('Potential');
        OPP_STAGES.add('Contacted');
        OPP_STAGES.add('In Briefing');
        OPP_STAGES.add('M2N (Mandate to Negotiate)');
        OPP_STAGES.add('Deal approval');
        OPP_STAGES.add('Closed Won');
        OPP_STAGES.add('Closed Lost');
        OPP_STAGES.add('Cancelled');
        OPP_STAGES.add('Parked');

        IMS_ROLES           = new List<String>{'Ven_Investment_Manager', 'Ven_ManagingDirectors', 'Ven_OpsStrat', 'Ven_BusinessDevelopment', 'Ven_Austria', 'Ven_Switzerland'};
        SCOUT_ROLE          = new List<String>{'Ven_Scout'};
        ANALYST_ROLE        = new List<String>{'Ven_Analyst'};
        IM_ROLE             = 'Ven_Investment_Manager';
        AUSTRIA_ROLE        = 'Ven_Austria';
        SWITZERLAND_ROLE    = 'Ven_Switzerland';
    }

    /*****************
    *
    *****************/
    @AuraEnabled
    public static Opportunity saveOppPipeDetail(Opportunity opp, List<Ven_OppPipeline__c> oppPipes){

        try{
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ventures Default').getRecordTypeId();

            if(opp.CloseDate == null){
                opp.CloseDate = Date.today().addMonths(6);
            }

            upsert opp;

            List<Ven_OppPipeline__c> newOppPipes = new List<Ven_OppPipeline__c>();

            for(Ven_OppPipeline__c op : oppPipes){
                if(op.Id == null){
                    op.Ven_Opp__c = opp.Id;
                }

                newOppPipes.add((Ven_OppPipeline__c) op);
            }

            upsert newOppPipes;

            //Second Update to run trigger correctly
            update opp;

            return getOppById(opp.Id);
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, e.getLineNumber() +' => '+ e.getMessage());
        }

        return null;
    }


    /*****************
    *
    *****************/
    @AuraEnabled
    public static List<Opportunity> saveOpps(List<Opportunity> opps){

        try{
            update opps;

            List<Id> oppIds = new List<Id>();
            for(Opportunity opp : opps){
                oppIds.add(opp.Id);
            }

            return getOppsByIds(oppIds);
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, e.getLineNumber() +' => '+ e.getMessage());
        }

        return null;
    }



    /*****************
    *
    *****************/
    @AuraEnabled
    public static void deleteOppPipeDetail(String oppId){
        delete [SELECT Id FROM Opportunity WHERE Id = :oppId];
    }



    @AuraEnabled
    public static OppPipeDetail getOppPipeDetail(Opportunity opp){
        OppPipeDetailYear currentYear = getOppId2OppLineYearByYear(new Set<Id>{opp.Id}, System.today().year()).values()[0];
        OppPipeDetailYear nextYear =  getOppId2OppLineYearByYear(new Set<Id>{opp.Id}, System.today().year()+1).values()[0];

        return new OppPipeDetail(opp, currentYear, nextYear);
    }


    @AuraEnabled
    public static List<ExportData> getExportData(){
        Map<Id, Opportunity> oppId2Opp = getExportOpps();

        Map<Id, OppPipeDetailYear> oppId2CurrentYear = getOppId2OppLineYearByYear(oppId2Opp.keySet(), System.today().year());
        Map<Id, OppPipeDetailYear> oppId2NextYear = getOppId2OppLineYearByYear(oppId2Opp.keySet(), System.today().year()+1);

        List<ExportData> exportDatas = new List<ExportData>();

        for(Opportunity opp : oppId2Opp.values()){
            exportDatas.add(new ExportData(opp, oppId2CurrentYear.get(opp.Id), oppId2NextYear.get(opp.Id)));
        }

        return exportDatas;
    }


    /*****************
    *
    *****************/
    @AuraEnabled
    public static OppPipeData getOppPipeData(){
        initSettings();

        Set<Id> assigneeIds = new Set<Id>();

        for(PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Ven_OppPipeAccessAll']){
            assigneeIds.add(psa.AssigneeId);
        }

        Map<Id, Opportunity> oppId2Opp;
        Boolean isInPermissionSet;
        List<Opportunity> summaryItems = new List<Opportunity>();

        if(assigneeIds.contains(UserInfo.getUserId())){
            summaryItems = getAllOpps().values();
            isInPermissionSet  = true;
        }
        else {
            summaryItems = getOppsByOppTeam().values();
            isInPermissionSet  = false;
        }

        for(Opportunity opp : summaryItems){
            opp.StageName = getTranslatedStageName(opp.StageName);
        }

        List<Ven_Utility.InputSelectOpt> stageNames = new List<Ven_Utility.InputSelectOpt>();
        for(String stageName : OPP_STAGES){
            stageNames.add(new Ven_Utility.InputSelectOpt(stageName, stageName));
        }

        List<Ven_Utility.InputSelectOpt> imOptions = getUsersByRoleNames(IMS_ROLES);

        List<String> userIds = new List<String>();

        for(Ven_Utility.InputSelectOpt iso : imOptions){
            userIds.add(iso.text);
        }


        SelectOptionLists selectOptLsts = new SelectOptionLists(    Ven_Utility.getInputSelectOptsByPicklistValues('Opportunity', 'Ven_DealType__c'),
                                                                    Ven_Utility.getInputSelectOptsByPicklistValues('Opportunity', 'Ven_SubCategory__c'),
                                                                    getCountries(),
                                                                    Ven_Utility.getInputSelectOptsByPicklistValues('Opportunity', 'Ven_Stage_Finished_Subcategory__c'),
                                                                    stageNames,
                                                                    imOptions,
                                                                    getUsersByRoleNames(SCOUT_ROLE),
                                                                    getUsersByRoleNames(ANALYST_ROLE),
                                                                    Ven_Utility.getInputSelectOptsByPicklistValues('Opportunity', 'Ven_Vertical__c'),
                                                                    Ven_Utility.getInputSelectOptsByPicklistValues('Opportunity', 'Ven_DealCategory__c'),
                                                                    getCurrencies(),
                                                                    Ven_Utility.getInputSelectOptsByPicklistValues('Opportunity', 'Ven_TargetPL__c'));
        // ############################

        return new OppPipeData( UserInfo.getUserId(),
                                UserInfo.getFirstName()+' '+UserInfo.getLastName(),
                                UserInfo.getUserRoleId(),
                                Ven_Utility.getRoleIdByName(IM_ROLE),
                                Ven_Utility.getRoleIdByName(SCOUT_ROLE[0]),
                                Ven_Utility.getRoleIdByName(ANALYST_ROLE[0]),
                                isInPermissionSet,
                                summaryItems,
                                selectOptLsts,
                                buildCountryInternationalMap(),
                                Ven_Utility.getRoleIdByName(AUSTRIA_ROLE),
                                Ven_Utility.getRoleIdByName(SWITZERLAND_ROLE),
                                buildUserRoleMap(userIds));
    }


    /*****************
    *
    *****************/
    private static Map<String, String> buildUserRoleMap(List<String> userIds){

        Map<String, String> result = new Map<String, String>();

        for(User u : [  SELECT Id, UserRoleId
                        FROM User
                        WHERE Id IN :userIds]){
            result.put(u.Id, u.UserRoleId);
        }

        return result;
    }


    /*****************
    *
    *****************/
    private static Map<String, Boolean> buildCountryInternationalMap(){

        Map<String, Boolean> result = new Map<String, Boolean>();

        for(P7S1_Country__c country : [ SELECT Id, Ven_International__c
                                        FROM P7S1_Country__c
                                        WHERE Active__c = true
                                            AND P7S1_Sphere__c INCLUDES ('Ven')]){
            result.put(country.Id, country.Ven_International__c);
        }

        return result;
    }


    /*****************
    *
    *****************/
    private static List<Ven_Utility.InputSelectOpt> getCurrencies(){
        List<Ven_Utility.InputSelectOpt> currencyTypes = new List<Ven_Utility.InputSelectOpt>();

        for(CurrencyType cy : [ SELECT Id, IsoCode
                                FROM CurrencyType
                                WHERE isactive = true
                                ORDER BY isocode]){
            currencyTypes.add(new Ven_Utility.InputSelectOpt(cy.IsoCode, cy.IsoCode));
        }

        return currencyTypes;
    }


    /*****************
    *
    *****************/
    private static List<Ven_Utility.InputSelectOpt> getUsersByRoleNames(List<String> roleNames){
        List<Ven_Utility.InputSelectOpt> users = new List<Ven_Utility.InputSelectOpt>();

        Map<Id, UserRole> roleId2Role = new Map<Id, UserRole>([ SELECT Id
                                                                FROM UserRole
                                                                WHERE DeveloperName IN :roleNames]);

        for(User u : [  SELECT Id, Firstname, Lastname
                        FROM User
                        WHERE UserRoleId IN :roleId2Role.keySet()
                            AND isactive = true]){
            users.add( new Ven_Utility.InputSelectOpt(u.Id, u.Firstname + ' ' + u.Lastname));
        }

        return users;
    }

    /*****************
    *
    *****************/
    private static List<Ven_Utility.InputSelectOpt> getCountries(){
        List<Ven_Utility.InputSelectOpt> countries = new List<Ven_Utility.InputSelectOpt>();

        for(P7S1_Country__c country : [ SELECT Id, Name_EN__c
                                        FROM P7S1_Country__c
                                        WHERE Active__c = true
                                            AND P7S1_Sphere__c INCLUDES ('Ven')
                                        ORDER BY P7S1_TopCountry__c DESC, Name_EN__c]){
            countries.add(new Ven_Utility.InputSelectOpt(country.Id, country.Name_EN__c));
        }

        return countries;
    }



    /*****************
    *
    *****************/
    private static String getBaseQueryString(){
        return
            'SELECT '+
                'Id, '+
                'Name, '+
                'Ven_TotalGmvCurrentYear__c, '+
                'Ven_TotalGmvNextYear__c, '+
                'Ven_DealType__c,  '+
                'Ven_SubCategory__c, '+
                'Ven_CashInvest__c, '+
                'Ven_DealCategory__c, '+
                'StageName,  '+
                'Ven_Stage_Finished_Subcategory__c, '+
                'Ven_Comment__c, '+
                'Ven_Vertical__c, '+
                'Ven_International__c, '+
                'Ven_EstimateCashYieldCurrentYear__c, '+
                'Ven_EffectiveYield__c, '+
                'Ven_EstimatePrapYieldCurrentYear__c, '+
                'Account.Ven_SomApproval__c, '+
                'CurrencyIsoCode, '+
                'Probability, '+
                'OwnerId, '+
                'Ven_Country__c, '+
                'Ven_Country__r.Name_EN__c, '+
                'Owner.Firstname, '+
                'Owner.Lastname, '+
                'CloseDate, '+
                'CreatedDate, '+
                'AccountId, '+
                'Account.Name, '+
                'Account.CreatedDate, '+
                'Ven_NetPotentialCurrentYear__c, '+
                'Ven_NetPotentialNextYear__c, '+
                'Ven_TotalNetPotential__c, '+
                'Ven_TotalGmv__c, '+
                'Ven_LastModifiedBy__c, '+
                'Ven_LastModifiedDate__c, '+
                'Ven_Im2__c, '+
                'Ven_Scout__c, '+
                'Ven_Analyst__c, '+
                'Ven_Contacted__c, '+
                'Ven_m2n__c, '+
                'Ven_DealApproval__c, '+
                'Ven_ClosedWon__c, '+
                'Ven_ClosedLost__c, '+
                'Ven_ParkedDate__c, '+
                'Ven_Cancellation__c, '+
                'Ven_TargetPL__c, '+
                'Ven_Ep__c, '+
                'Ven_EpLight__c, '+
                'Ven_RevShare__c '+
            'FROM '+
            'Opportunity '+
            'WHERE '+
                'RecordTypeId IN (SELECT Id FROM RecordType WHERE Name LIKE \'Ven%\')';
    }


    /*****************
    *
    *****************/
    private static Map<Id, Opportunity> getExportOpps(){
        String baseQueryString = getBaseQueryString();
        String whereClause = ' AND StageName != \'Inbox\'';

        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(baseQueryString + whereClause));
    }


    /*****************
    *
    *****************/
    private static Opportunity getOppById(Id oppId){
        String baseQueryString = getBaseQueryString();
        String whereClause = ' AND Id = :oppId';

        return ((List<Opportunity>) Database.query(baseQueryString + whereClause))[0];
    }


    /*****************
    *
    *****************/
    private static List<Opportunity> getOppsByIds(List<Id> oppIds){
        String baseQueryString = getBaseQueryString();
        String whereClause = ' AND Id IN :oppIds';

        return (List<Opportunity>) Database.query(baseQueryString + whereClause);
    }


    /*****************
    *
    *****************/
    private static Map<Id, Opportunity> getAllOpps(){
        String baseQueryString = getBaseQueryString();
        //String whereClause = ' AND StageName != \'Inbox\' AND StageName != \'Closed Won\' AND StageName != \'Closed Lost\' AND StageName != \'Cancelled\' ORDER BY OwnerId';
        String whereClause = ' AND StageName IN (\'In Briefing\', \'M2N (Mandate to Negotiate)\', \'Deal approval\', \'Potential\', \'Contacted\') ORDER BY OwnerId';

        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(baseQueryString + whereClause));
    }


    /*****************
    *
    *****************/
    private static Map<Id, Opportunity> getOppsByOppTeam(){
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityTeamMember otm : [SELECT OpportunityId FROM OpportunityTeamMember WHERE UserId = :UserInfo.getUserId()]){
            oppIds.add(otm.OpportunityId);
        }

        String baseQueryString = getBaseQueryString();
        //String whereClause = ' AND Id IN :oppIds AND StageName != \'Inbox\' AND StageName != \'Closed Won\' AND StageName != \'Closed Lost\' AND StageName != \'Cancelled\' ORDER BY OwnerId';
        String whereClause = ' AND Id IN :oppIds AND StageName IN (\'In Briefing\', \'M2N (Mandate to Negotiate)\', \'Deal approval\', \'Potential\', \'Contacted\') ORDER BY OwnerId';

        return new Map<Id, Opportunity>((List<Opportunity>) Database.query(baseQueryString + whereClause));
    }


    /*****************
    *
    ******************/
    private static Map<Id, OppPipeDetailYear> getOppId2OppLineYearByYear(Set<Id> oppIds, Integer year){
        Map<Id, OppPipeDetailYear> oppId2OppPipelineYear            = new Map<Id, OppPipeDetailYear>();
        Map<Id, List<Ven_OppPipeline__c>> oppId2OppPipelineMonths   = new Map<Id, List<Ven_OppPipeline__c>>();

        for(Ven_OppPipeline__c oppPipeline : [  SELECT Ven_Amount__c, Ven_Year__c, Ven_Month__c, Ven_Opp__c, Ven_Cash__c
                                                FROM Ven_OppPipeline__c
                                                WHERE Ven_Opp__c IN :oppIds
                                                    AND Ven_Year__c = :year
                                                ORDER BY Ven_Opp__c, Ven_Year__c, Ven_Month__c DESC]){


            if(oppId2OppPipelineMonths.get(oppPipeline.Ven_Opp__c) != null){
                oppId2OppPipelineMonths.get(oppPipeline.Ven_Opp__c).add(oppPipeline);
            } else {
                oppId2OppPipelineMonths.put(oppPipeline.Ven_Opp__c, new List<Ven_OppPipeline__c>{oppPipeline});
            }
        }

        for(Id oppId : oppIds){
            Decimal totalAmount = 0;
            Decimal totalCash   = 0;

            List<Ven_OppPipeline__c> ops = new List<Ven_OppPipeline__c>();

            for(Integer i=1; i <= 12; i++){
                Boolean opmFound = false;

                if(oppId2OppPipelineMonths.get(oppid) != null){

                    for(Ven_OppPipeline__c op : oppId2OppPipelineMonths.get(oppId)){
                        if(op.Ven_Month__c == i){
                            totalAmount += (op.Ven_Amount__c == null ? 0 : op.Ven_Amount__c);
                            totalCash   += (op.Ven_Cash__c == null ? 0 : op.Ven_Cash__c);
                            opmFound    = true;
                            ops.add(op);
                        }
                    }
                }
            }

            OppPipeDetailYear opy = new OppPipeDetailYear(ops, totalAmount, totalCash, String.valueOf(year));
            oppId2OppPipelineYear.put(oppId, opy);
        }

        return oppId2OppPipelineYear;
    }


    /*****************
    *
    *****************/
    private static String getTranslatedStageName(String stageName){

            if(stageName == 'SE_Potenzial'){
                stageName = 'Potential';
            }
            else if(stageName == 'SE_Erstgespräch Bedarf/Bestand'){
                stageName = 'Contacted';
            }
            else if(stageName == 'SE_In Briefing/Erstgespräch'){
                stageName = 'In Briefing';
            }
            else if(stageName == 'SE_Rabatt freigegeben'){
                stageName = 'M2N (Mandate to Negotiate)';
            }
            else if(stageName == 'SE_Deal Approval'){
                stageName = 'Deal approval';
            }
            else if(stageName == 'SE_Closed Won'){
                stageName = 'Closed Won';
            }
            else if(stageName == 'SE_Closed Lost'){
                stageName = 'Closed Lost';
            }
            else if(stageName == 'SE_Storniert'){
                stageName = 'Cancelled';
            }
            else if(stageName == 'SE_Parked'){
                stageName = 'Parked';
            }

            return stageName;
        }





    /* ====================================== WRAPPER CLASSES ======================================== */

    public class ExportData{
        @AuraEnabled
        OppPipeDetailYear currentYear{get;set;}

        @AuraEnabled
        OppPipeDetailYear nextYear{get;set;}

        @AuraEnabled
        Opportunity opp{get;set;}

        public ExportData(Opportunity opp, OppPipeDetailYear currentYear, OppPipeDetailYear nextYear){
            this.opp           = opp;
            this.currentYear   = currentYear;
            this.nextYear      = nextYear;
        }
    }


    /* OPP PIPELINE DATA */
    public class OppPipeData{
        @AuraEnabled
        public String userId;

        @AuraEnabled
        public String userName;

        @AuraEnabled
        public String userRole;

        @AuraEnabled
        public String imRoleId;

        @AuraEnabled
        public String scoutRoleId;

        @AuraEnabled
        public String analystRoleId;

        @AuraEnabled
        public String austriaRoleId;

        @AuraEnabled
        public String switzerlandRoleId;

        @AuraEnabled
        public Map<String, Boolean> countryId2International;

        @AuraEnabled
        public Map<String, String> userId2RoleId;

        @AuraEnabled
        public List<Opportunity> summaryItems;

        @AuraEnabled
        public SelectOptionLists selectOptLsts;

        @AuraEnabled
        public Boolean isInPermissionSet;

        @AuraEnabled
        public Integer currentYear;

        @AuraEnabled
        public List<Ven_SomLikelihood__c> somLikelihoods;

        public OppPipeData( String userId,
                            String userName,
                            String userRole,
                            String imRoleId,
                            String scoutRoleId,
                            String analystRoleId,
                            Boolean isInPermissionSet,
                            List<Opportunity> summaryItems,
                            SelectOptionLists selectOptLsts,
                            Map<String, Boolean> countryId2International,
                            String austriaRoleId,
                            String switzerlandRoleId,
                            Map<String, String> userId2RoleId){
            this.userId                     = userId;
            this.userName                   = userName;
            this.userRole                   = userRole;
            this.imRoleId                   = imRoleId;
            this.scoutRoleId                = scoutRoleId;
            this.analystRoleId              = analystRoleId;
            this.isInPermissionSet          = isInPermissionSet;
            this.summaryItems               = summaryItems;
            this.selectOptLsts              = selectOptLsts;
            this.countryId2International    = countryId2International;
            this.austriaRoleId              = austriaRoleId;
            this.switzerlandRoleId          = switzerlandRoleId;
            this.userId2RoleId              = userId2RoleId;
            this.currentYear                = System.today().year();
            this.somLikelihoods             = Ven_SomLikelihood__c.getAll().values();
        }
    }

    /* OPP PIPELINE TABLE ROW */
    public class OppPipeDetail{
        @AuraEnabled
        public Opportunity opp;

        @AuraEnabled
        public OppPipeDetailYear currentYear;

        @AuraEnabled
        public OppPipeDetailYear nextYear;

        public OppPipeDetail(Opportunity opp, OppPipeDetailYear currentYear, OppPipeDetailYear nextYear){
            this.opp            = opp;
            this.currentYear    = currentYear;
            this.nextYear       = nextYear;
        }
    }



    /* OPP PIPELINE YEAR */
    public class OppPipeDetailYear{
        @AuraEnabled
        public List<Ven_OppPipeline__c> oppPipeMonths;

        @AuraEnabled
        public Decimal totalAmount;

        @AuraEnabled
        public Decimal totalCash;

        @AuraEnabled
        public String year;

        public OppPipeDetailYear(List<Ven_OppPipeline__c> oppPipeMonths, Decimal totalAmount, Decimal totalCash, String year){
            this.oppPipeMonths      = oppPipeMonths;
            this.totalAmount        = totalAmount;
            this.totalCash          = totalCash;
            this.year               = year;
        }
    }


    public class SelectOptionLists{
        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> dealTypes;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> subCats;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> countries;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> reasons;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> stageNames;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> ims;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> scouts;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> analysts;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> verticals;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> dealCats;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> currencies;

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> targetPls;

        public SelectOptionLists(   List<Ven_Utility.InputSelectOpt> dealTypes,
                                    List<Ven_Utility.InputSelectOpt> subCats,
                                    List<Ven_Utility.InputSelectOpt> countries,
                                    List<Ven_Utility.InputSelectOpt> reasons,
                                    List<Ven_Utility.InputSelectOpt> stageNames,
                                    List<Ven_Utility.InputSelectOpt> ims,
                                    List<Ven_Utility.InputSelectOpt> scouts,
                                    List<Ven_Utility.InputSelectOpt> analysts,
                                    List<Ven_Utility.InputSelectOpt> verticals,
                                    List<Ven_Utility.InputSelectOpt> dealCats,
                                    List<Ven_Utility.InputSelectOpt> currencies,
                                    List<Ven_Utility.InputSelectOpt> targetPls){
            this.dealTypes      = dealTypes;
            this.subCats        = subCats;
            this.countries      = countries;
            this.reasons        = reasons;
            this.stageNames     = stageNames;
            this.ims            = ims;
            this.scouts         = scouts;
            this.analysts       = analysts;
            this.verticals      = verticals;
            this.dealCats       = dealCats;
            this.currencies     = currencies;
            this.targetPls      = targetPls;
        }
    }
}