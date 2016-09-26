/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* Som_AccountPlan_CmpCtrl
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         5-4-2016
* @description
* @lastchange
* @objects
* ==================================================================
*/
public without sharing class Som_Kam_CmpCtrl {

    /*************************
    *
    *************************/
    private static Boolean isUserKamSek(String accId, Id userId){
        List<Account> accs = [
            SELECT
                Id
            FROM
                Account
            WHERE
                Id = :accId AND
                    (Som_Sek__c = :userId OR
                    Som_Kam__c = :userId)];

        return accs.size() > 0 ? true : false;
    }


    /*************************
    *
    *************************/
    private static Boolean isUserDetailPlanerAccPlanDetail(String accPlanDetailId, Id userId){
        if(accPlanDetailId == null){
            return false;
        }

        List<Som_KamDetail__c> apds = [
            SELECT
                Id
            FROM
                Som_KamDetail__c
            WHERE
                Id = :accPlanDetailId AND
                Som_KamTeamMember__c = :userId];

        return apds.size() > 0 ? true : false;
    }


    /*************************
    *
    *************************/
    private static Boolean isUserDetailPlanerAccPlan(String accPlanId, Id userId){
        if(accPlanId == null){
            return false;
        }

        List<Som_KamDetail__c> apds = [
            SELECT
                Id
            FROM
                Som_KamDetail__c
            WHERE
                Som_Kam__c = :accPlanId AND
                Som_KamTeamMember__c = :userId];

        return apds.size() > 0 ? true : false;
    }


    /*************************
    *
    *************************/
    public static Boolean isUserUnitInvited(String accPlanId, Id userId){
        if(accPlanId == null){
            return false;
        }

        Set<String> units = new Set<String>();

        for(Som_KamDetail__c apd : [
            SELECT
                Id,
                Som_KamTeam__r.Som_Unit__c
            FROM
                Som_KamDetail__c
            WHERE
                Som_Kam__c = :accPlanId])
        {
            units.add(apd.Som_KamTeam__r.Som_Unit__c);
        }

        List<User> users = [SELECT Id FROM User WHERE P7S1_Unit__c IN :units AND Id = :userId];

        return users.size() > 0 ? true : false;
    }


    /*************************
    * gets data for Som_AccountPlanEditCmp.cmp
    *************************/
    @AuraEnabled
    public static P7S1_ApexResponse getAccountPlanEditData(String accId, String accPlanId){

        P7S1_ApexResponse resp;

        try{
            Map<Object, Object> result = new Map<Object, Object>();

            if(isUserKamSek(accId, UserInfo.getUserId())){
                result.put('isKamSek', true);
            }
            else if(isUserDetailPlanerAccPlan(accPlanId, UserInfo.getUserId())){
                result.put('isDetailPlanner', true);
            }
            else if(isUserUnitInvited(accPlanId, UserInfo.getUserId())){
                result.put('userUnitInvited', true);
            }

            result.put('data', buildAccountPlanEditData(accId, accPlanId));

            resp = new P7S1_ApexResponse(result);
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, 'Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            resp = new P7S1_ApexResponse('Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
        }

        return resp;
    }


    /*************************
    * get data for Som_AccountPlanDetailEditCmp.cmp
    *************************/
    @AuraEnabled
    public static P7S1_ApexResponse getAccountPlanDetailEditData(String accPlanDetailId){

        P7S1_ApexResponse resp;

        try{
            Map<Object, Object> result = new Map<Object, Object>();

            if(isUserDetailPlanerAccPlanDetail(accPlanDetailId, UserInfo.getUserId())){
                result.put('isDetailPlanner', true);
            }

            result.put('data', getAccPlanDetails(null, accPlanDetailId)[0]);

            resp = new P7S1_ApexResponse(result);
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, 'Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            resp = new P7S1_ApexResponse('Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
        }

        return resp;
    }


    /*************************
    * builds all needed data for Som_AccountPlanEditCmp.cmp
    *************************/
    private static AccountPlanEditData buildAccountPlanEditData(String accId, String accPlanId){

        Som_Kam__c accPlan = new Som_Kam__c( Som_Year__c = Date.today().year(), Som_Account__c = accId);

        List<AccountPlanDetail> accPlanDetails = new List<AccountPlanDetail>();
        List<Som_KamStrategyProfileTopic__c> strategyProfiles = new List<Som_KamStrategyProfileTopic__c>();

        // set acc plan, acc plan detail and stratProfs if user acc plan exists
        // if not => user is creating a new acc plan
        if(accPlanId != null){
            accPlan             = getAccPlanById(accPlanId);
            accPlanDetails      = getAccPlanDetails(accPlanId, null);
            strategyProfiles    = getStrategyProfilesByAccPlanId(accPlanId);
        }

        AccountPlan ap = new AccountPlan(accPlan, accPlanDetails, strategyProfiles);

        Account acc = [SELECT Id, Name, Som_Kam__c, Som_Sek__c FROM Account WHERE Id = :accId];

        // build list of acc plan teams for Som_AccountPlanTeamAssignmentCmp.cmp
        List<AccountPlanTeam> accPlanTeams = getAccountPlanTeamsByAccountId(acc, accPlanDetails);

        AccountPlanEditData data = new AccountPlanEditData(ap, accPlanTeams, acc.Name);
        return data;
    }




    /*************************
    *
    *************************/
    private static Som_Kam__c getAccPlanById(String accPlanId){
        return [
            SELECT
                Id,
                Name,
                Som_Account__c,
                Som_Account__r.Name,
                Som_EmailText__c,
                Som_Kickoff__c,
                Som_Year__c,
                Som_Review__c
            FROM
                Som_Kam__c
            WHERE
                Id = :accPlanId];
    }


    /*************************
    * build acc plan detail(s) by acc plan id or acc plan detail id
    *************************/
    private static List<AccountPlanDetail> getAccPlanDetails(String accPlanId, String accPlanDetailId){
        List<AccountPlanDetail> apds = new List<AccountPlanDetail>();

        // get acc plan detail by id or acc plan details by acc plan id
        Map<Id, Som_KamDetail__c> apdId2Apd = new Map<Id, Som_KamDetail__c>([
            SELECT
                Id,
                Name,
                Som_Kam__c,
                Som_Kam__r.Som_Account__c,
                Som_Kam__r.Som_Account__r.Name,
                Som_Kam__r.Som_Kickoff__c,
                Som_Kam__r.Som_Review__c,
                Som_Kam__r.Som_Year__c,
                Som_KamTeam__c,
                Som_KamTeam__r.Name,
                Som_KamTeamMember__c,
                Som_KamTeamMember__r.Firstname,
                Som_KamTeamMember__r.Lastname,
                Som_CashExternalYield__c,
                Som_CashIn__c,
                Som_DaysUnitlKickoff__c,
                Som_DaysUntilReview__c,
                Som_KamAccountCashIn__c,
                Som_PreviousCashExternalYield__c,
                Som_PreviousCashIn__c,
                Som_RatingDealLearnings__c,
                Som_Status__c,
                Som_TargetCashIn__c
            FROM
                Som_KamDetail__c
            WHERE
                Som_Kam__c = :accPlanId OR
                Id = :accPlanDetailId]);


        Map<Id, List<Som_KamDetailCashIn__c>> apdId2CashIns = new Map<Id, List<Som_KamDetailCashIn__c>>();

        // get acc plan detail cash ins
        for(Som_KamDetailCashIn__c apdci : [
            SELECT
                Id,
                Name,
                Som_KamDetail__c,
                Som_KamAccountCashInDetail__c,
               Som_CashExternalYield__c,
                Som_Cashin__c,
                Som_PreviousCashExternalYield__c,
                Som_PreviousCashIn__c
            FROM
                Som_KamDetailCashIn__c
            WHERE
                Som_KamDetail__c IN :apdId2Apd.keySet()
            ORDER BY
                CreatedDate, Name])
        {
            if(apdId2CashIns.get(apdci.Som_KamDetail__c) != null){
                apdId2CashIns.get(apdci.Som_KamDetail__c).add(apdci);
            } else {
                apdId2CashIns.put(apdci.Som_KamDetail__c, new List<Som_KamDetailCashIn__c>{apdci});
            }
        }


        Map<Id, List<Som_KamStrategyProfileTopic__c>> apdId2StratProfTopics = new Map<Id, List<Som_KamStrategyProfileTopic__c>>();

        // get strategy profs from acc plan detail(s)
        for(Som_KamStrategyProfileTopic__c spt : [
            SELECT
                Id,
                Name,
                Som_Kam__c,
                Som_KamDetail__c,
                Som_Description__c,
                Som_Template__c
            FROM
                Som_KamStrategyProfileTopic__c
            WHERE
                Som_KamDetail__c IN :apdId2Apd.keySet()
            ORDER BY
                Name])
        {
            if(apdId2StratProfTopics.get(spt.Som_KamDetail__c) != null){
                apdId2StratProfTopics.get(spt.Som_KamDetail__c).add(spt);
            } else {
                apdId2StratProfTopics.put(spt.Som_KamDetail__c, new List<Som_KamStrategyProfileTopic__c>{spt});
            }
        }

        List<Ven_Utility.InputSelectOpt> options = new List<Ven_Utility.InputSelectOpt>();

        // get select options for the team member select
        if(accPlanDetailId != null){
            options = getTeamMemberOptsByAccPlanDetail(apdId2Apd.values()[0]);
        }

        // get opp data
        P7S1_AccountDashboardCmpCtrl.OppData oppData =  P7S1_AccountDashboardCmpCtrl.getOpportunityData(apdId2Apd.values()[0].Som_Kam__r.Som_Account__c, false);

        Map<String, P7S1_AccountDashboardCmpCtrl.TableData> unit2OppData = new Map<String, P7S1_AccountDashboardCmpCtrl.TableData>();
        for(P7S1_AccountDashboardCmpCtrl.TableData td : oppData.tableData){
            unit2OppData.put(td.unit, td);
        }

        for(Id apdId : apdId2Apd.keySet()){

            List<AccountPlanDetailCashIn> apdcis = new List<AccountPlanDetailCashIn>();

            if(apdId2CashIns.get(apdId) != null){
                for(Som_KamDetailCashIn__c apdci : apdId2CashIns.get(apdId)){
                    apdcis.add(new AccountPlanDetailCashIn(apdci));
                }
            }

            Som_KamDetail__c apd = apdId2Apd.get(apdId);
            Decimal optInOpen;
            Decimal optInClosed;

            if(unit2OppData.get(apd.Som_KamTeam__r.Name) != null){
                optInOpen = unit2OppData.get(apd.Som_KamTeam__r.Name).open;
                optInClosed = unit2OppData.get(apd.Som_KamTeam__r.Name).closed;
            }

            apds.add(new AccountPlanDetail(
                apdId2Apd.get(apdId),
                apdcis,
                apdId2StratProfTopics.get(apdId),
                options,
                optInOpen,
                optInClosed));
        }

        return apds;
    }


    /*************************
    *
    *************************/
    private static List<Som_KamStrategyProfileTopic__c> getStrategyProfilesByAccPlanId(String accPlanId){
        return [
            SELECT
                Id,
                Name,
                Som_Kam__c,
                Som_KamDetail__c,
                Som_Description__c,
                Som_Template__c
            FROM
                Som_KamStrategyProfileTopic__c
            WHERE
                Som_Kam__c = :accPlanId
            ORDER BY
                Name];
    }


    /*************************
    * get select options for the team member select for an acc plan detail
    *************************/
    private static List<Ven_Utility.InputSelectOpt> getTeamMemberOptsByAccPlanDetail(Som_KamDetail__c accPlanDetail){
        List<Ven_Utility.InputSelectOpt> result = new List<Ven_Utility.InputSelectOpt>();

        Map<Id, List<String>> accPlanTeamId2AccTeamRoles = new Map<Id, List<String>>();
        Set<Id> userIds = new Set<Id>();

        List<String> accTeamRoles = new List<String>();

        Som_KamTeam__c accPlanTeam = [
            SELECT
                Id, Name, Som_DefaultAccountTeamMember__c, Som_TeamMemberRoles__c
            FROM
                Som_KamTeam__c
            WHERE
                Id = :accPlanDetail.Som_KamTeam__c
            LIMIT
                1][0];

        if(accPlanTeam.Som_TeamMemberRoles__c != null){
            accTeamRoles = accPlanTeam.Som_TeamMemberRoles__c.split(';');
        }

        userIds.add(accPlanTeam.Som_DefaultAccountTeamMember__c);


        for(AccountTeamMember atm : [
            SELECT
                Id, AccountId, TeamMemberRole, UserId
            FROM
                AccountTeamMember
            WHERE
                AccountId = :accPlanDetail.Som_Kam__r.Som_Account__c AND TeamMemberRole IN :accTeamRoles])
        {
            userIds.add(atm.UserId);
        }

        for(User u : [SELECT Id, Firstname, Lastname FROM User WHERE Id IN :userIds]){
            result.add(new Ven_Utility.InputSelectOpt(String.valueOf(u.Id), u.Firstname + ' ' + u.Lastname));
        }

        return result;
    }


    /*************************
    * get all select options for the account plan team assignment section
    *************************/
    private static List<AccountPlanTeam> getAccountPlanTeamsByAccountId(Account acc, List<AccountPlanDetail> accPlanDetails){
        List<AccountPlanTeam> accPlanTeams = new List<AccountPlanTeam>();
        Map<Id, List<String>> accPlanTeamId2AccTeamRoles = new Map<Id, List<String>>();
        Set<Id> userIds = new Set<Id>();
        Map<Id, Som_KamTeam__c> accPlanTeamId2AccPlanTeam = new Map<Id, Som_KamTeam__c>();

        // get all account plan teams, acc team member roles to acc plan team
        for(Som_KamTeam__c apt : [SELECT Id, Name, Som_DefaultAccountTeamMember__c, Som_TeamMemberRoles__c FROM Som_KamTeam__c ORDER BY Name]){
            accPlanTeamId2AccPlanTeam.put(apt.Id, apt);

            List<String> accTeamRoles = new List<String>();

            if(apt.Som_TeamMemberRoles__c != null){
                accTeamRoles = apt.Som_TeamMemberRoles__c.split(';');
            }

            accPlanTeamId2AccTeamRoles.put(apt.Id, accTeamRoles);
            userIds.add(apt.Som_DefaultAccountTeamMember__c);
        }


        Map<String, Set<Id>> accTeamRole2UserIds = new Map<String, Set<Id>>();

        // get all posible team members for the acc plan detail by team member role
        for(AccountTeamMember atm : [SELECT Id, AccountId, TeamMemberRole, UserId FROM AccountTeamMember WHERE AccountId = :acc.Id]){
            if(accTeamRole2UserIds.get(atm.TeamMemberRole) != null){
                accTeamRole2UserIds.get(atm.TeamMemberRole).add(atm.UserId);
            } else {
                accTeamRole2UserIds.put(atm.TeamMemberRole, new Set<Id>{atm.UserId});
            }

            userIds.add(atm.UserId);
        }


        Map<Id, User> userId2User = new Map<Id, User>([SELECT Id, Firstname, Lastname FROM User WHERE Id IN :userIds]);

        List<String> allStatus = new List<String>();
        for(Schema.PicklistEntry pe : Som_KamDetail__c.Som_Status__c.getDescribe().getPicklistValues()){
            allStatus.add(pe.getLabel());
        }

        // build select options
        for(Id accPlanTeamId : accPlanTeamId2AccPlanTeam.keySet()){
            Som_KamTeam__c accPlanTeam = accPlanTeamId2AccPlanTeam.get(accPlanTeamId);

            List<Ven_Utility.InputSelectOpt> inpSelOpts = new List<Ven_Utility.InputSelectOpt>();
            String selectedUserId;

            List<Id> potentialDetailPlaners = new List<Id>();

            for(String accTeamRole : accPlanTeamId2AccTeamRoles.get(accPlanTeamId)){

                if(accTeamRole2UserIds.get(accTeamRole) != null){
                    // exactly one team member exists and will be set => must check for several potential detial planners with different roles
                    if(accTeamRole2UserIds.get(accTeamRole).size() == 1){
                        List<Id> us = new List<Id>(accTeamRole2UserIds.get(accTeamRole));
                        User u = userId2User.get(us[0]);
                        inpSelOpts.add(new Ven_Utility.InputSelectOpt(String.valueOf(u.Id), u.Firstname + ' ' + u.Lastname));
                        potentialDetailPlaners.add(u.Id);
                    }
                    // multiple team members exist
                    else {
                        for(Id uId : accTeamRole2UserIds.get(accTeamRole)){
                            User u = userId2User.get(uId);
                            inpSelOpts.add(new Ven_Utility.InputSelectOpt(String.valueOf(u.Id), u.Firstname + ' ' + u.Lastname));
                        }
                    }
                }
            }

            //
            if(potentialDetailPlaners.size() == 1){
                selectedUserId = potentialDetailPlaners[0];
            }

            // no matching team member found => use default
            if(inpSelOpts.size() == 0){
                User u = userId2User.get(accPlanTeamId2AccPlanTeam.get(accPlanTeamId).Som_DefaultAccountTeamMember__c);
                if(u != null){
                    inpSelOpts.add(new Ven_Utility.InputSelectOpt(String.valueOf(u.Id), u.Firstname + ' ' + u.Lastname));
                    selectedUserId = u.Id;
                }
            }

            Boolean isSelected = false;
            String status;

            Som_KamDetail__c apdAccTeam;

            // check out if account plan team was selected before => this means that there is an acc plan detail
            for(AccountPlanDetail apd : accPlanDetails){
                if(apd.accPlanDetail.Som_KamTeam__c == accPlanTeamId){
                    selectedUserId = apd.accPlanDetail.Som_KamTeamMember__c;
                    isSelected = true;
                    apdAccTeam = apd.accPlanDetail;
                    status = apd.accPlanDetail.Som_Status__c;
                    break;
                }
            }

            accPlanTeams.add(new AccountPlanTeam(accPlanTeam, inpSelOpts, selectedUserId, isSelected, status, apdAccTeam, allStatus));
        }

        return accPlanTeams;
    }


    /*************************
    *
    *************************/
    private static void sendMails(String accPlanId, List<String> accPlanTeamIds, String hostUrl, Boolean isKickoff){
        Som_Kam__c accPlan = [
            SELECT
                Id,
                Som_Kickoff__c,
                Som_Review__c,
                Som_EmailText__c,
                Som_Account__c,
                Som_Account__r.Name
            FROM
                Som_Kam__c
            WHERE
                Id = :accPlanId
            LIMIT
                1][0];

        List<Som_KamDetail__c> apds = [
            SELECT
                Id,
                Som_Kam__c,
                Som_KamTeamMember__c,
                Som_KamTeam__r.Name,
                Som_Status__c
            FROM
                Som_KamDetail__c
            WHERE
                Som_Kam__c = :accPlanId AND
                Som_KamTeam__c IN :accPlanTeamIds];

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        String accDetailUrl;
        String emailText = accPlan.Som_EmailText__c;
        String htmlBody;
        String meetingDate;

        for(Som_KamDetail__c apd : apds){
            // build url for the link in the email
            accDetailUrl = hostUrl + '/c/Som_AccountPlannerApp.app' + '?accId='+ accPlan.Som_Account__c + '&accPlanDetailId='+ apd.Id;
            htmlBody = emailText.replace('\n', '<br></br>') + '<br></br><br></br><a href="'+ accDetailUrl + '">Go to Account Plan Detail</a>';

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { apd.Som_KamTeamMember__c };

            // if inviting for kickoff => set status to Invited
            if(isKickoff){
                meetingDate = accPlan.Som_Kickoff__c.day() + '.' + accPlan.Som_Kickoff__c.month() + '.' + accPlan.Som_Kickoff__c.year();
                message.subject = Label.Som_lbl_AccountPlan +' '+ accPlan.Som_Account__r.Name +': Kickoff '+ apd.Som_KamTeam__r.Name +' '+ meetingDate;
                apd.Som_Status__c = 'Invited';
            }
            // if inviting for review => set status to Review
            else {
                meetingDate = accPlan.Som_Review__c.day() + '.' + accPlan.Som_Review__c.month() + '.' + accPlan.Som_Review__c.year();
                message.subject = Label.Som_lbl_AccountPlan +' '+ accPlan.Som_Account__r.Name +': Review '+ apd.Som_KamTeam__r.Name +' '+ meetingDate;
                apd.Som_Status__c = 'Review';
            }

            message.setHtmlBody(htmlBody);
            messages.add(message);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        update apds;
    }


    /*************************
    * invites acc plan detail team member for kickoff meeting
    *************************/
    @AuraEnabled
    public static P7S1_ApexResponse inviteForKickoff(List<String> accPlanTeamIds, String accPlanId, String accId, String hostUrl){
        P7S1_ApexResponse resp;
        Savepoint sp = Database.setSavepoint();

        try{
            sendMails(accPlanId, accPlanTeamIds, hostUrl, true);
            resp = new P7S1_ApexResponse('data', buildAccountPlanEditData(accId, accPlanId));
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, 'Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            resp = new P7S1_ApexResponse('Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            Database.rollback(sp);
        }

        return resp;
    }


    /*************************
    * invites acc plan detail team member for review meeting
    *************************/
    @AuraEnabled
    public static P7S1_ApexResponse inviteForReview(List<String> accPlanTeamIds, String accPlanId, String accId, String hostUrl){
        P7S1_ApexResponse resp;
        Savepoint sp = Database.setSavepoint();

        try{
            sendMails(accPlanId, accPlanTeamIds, hostUrl, false);
            resp = new P7S1_ApexResponse('data', buildAccountPlanEditData(accId, accPlanId));
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, 'Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            resp = new P7S1_ApexResponse('Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            Database.rollback(sp);
        }

        return resp;
    }


    /*************************
    * saves all changes to an acc plan detail etc. or inserts a new one
    *************************/
    @AuraEnabled
    public static P7S1_ApexResponse saveAccountPlanDetail(
        Som_KamDetail__c accPlanDetail,
        List<Som_KamStrategyProfileTopic__c> profStrats,
        List<Som_KamDetailCashIn__c> cashInUpserts,
        List<Som_KamDetailCashIn__c> cashInDeletes)
    {
        P7S1_ApexResponse resp;
        Savepoint sp = Database.setSavepoint();

        try{
            // set status to Kickoff if its Invited => this means that the acc plan detail has been updated and is ready for kickoff
            if(accPlanDetail.Som_Status__c == 'Invited'){
                accPlanDetail.Som_Status__c = 'Kickoff';
            }

            update accPlanDetail;
            update profStrats;

            List<Som_KamDetailCashIn__c> cashInUpsertNew = new List<Som_KamDetailCashIn__c>();

            // must be cast because of some serialization problem
            for(Som_KamDetailCashIn__c apdci : cashInUpserts){
                cashInUpsertNew.add((Som_KamDetailCashIn__c) apdci);
            }

            upsert cashInUpsertNew;
            delete cashInDeletes;

            List<AccountPlanDetailCashIn> backList = new List<AccountPlanDetailCashIn>();
            for(Som_KamDetailCashIn__c ci : cashInUpsertNew){
                backList.add(new AccountPlanDetailCashIn(ci));
            }
            return new P7S1_ApexResponse('dataUpserted',  backList);


            //return new P7S1_ApexResponse();
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, 'Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            resp = new P7S1_ApexResponse('Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            Database.rollback(sp);
        }

        return resp;
    }


    /*************************
    * saves all changes to an acc plan etc. or inserts a new one
    *************************/
    @AuraEnabled
    public static P7S1_ApexResponse saveAccountPlan(
        Som_Kam__c accPlan,
        List<Som_KamDetail__c> accPlanDetailsUpsert,
        List<Som_KamDetail__c> accPlanDetailsDelete,
        List<Som_KamDetailCashIn__c> accPlanDetailCashInsUpsert,
        List<Som_KamDetailCashIn__c> accPlanDetailCashInsDelete,
        List<Som_KamStrategyProfileTopic__c> accPlanStrategies,
        List<Som_KamStrategyProfileTopic__c> accPlanDetailStrategies)
    {
        P7S1_ApexResponse resp;
        Savepoint sp = Database.setSavepoint();

        try{
            Boolean isNew = accPlan.Id == null ? true : false;

            // get all prof strat templates
            List<Som_KamStrategyProfileTopic__c> profileTemplates = [
                SELECT
                    Id,
                    Name,
                    Som_Kam__c,
                    Som_KamDetail__c,
                    Som_Description__c,
                    Som_Template__c
                FROM
                    Som_KamStrategyProfileTopic__c
                WHERE
                    Som_IsTemplate__c = true];


            List<Som_KamStrategyProfileTopic__c> newProfiles = new List<Som_KamStrategyProfileTopic__c>();

            Som_Kam__c apTemp = (Som_Kam__c) accPlan;

            upsert accPlan;

            // acc plan is new => create strat profs
            if(isNew){
                for(Som_KamStrategyProfileTopic__c spt : profileTemplates){
                    newProfiles.add(new Som_KamStrategyProfileTopic__c(
                        Name = spt.Name,
                        Som_Kam__c = accPlan.Id,
                        Som_Template__c = spt.Id));
                }

                insert newProfiles;
            }

            List<Som_KamDetail__c> apdsUpdate = new List<Som_KamDetail__c>();
            List<Som_KamDetail__c> apdsInsert = new List<Som_KamDetail__c>();

            // set acc plan id for acc plan details
            for(Som_KamDetail__c apd : accPlanDetailsUpsert){

                if(apd.Som_Kam__c == null){
                    apd.Som_Kam__c = accPlan.Id;
                    apdsInsert.add(apd);
                }
                else {
                    apdsUpdate.add(apd);
                }
            }

            update apdsUpdate;

            // sets previous year values for acc plan detail (cash ins) and creates strat profs
            createAccountPlanDetailData(apdsInsert, accPlan.Som_Account__c, profileTemplates);

            Set<Id> accPlanDetailIdsDelete = new Set<Id>();
            for(Som_KamDetail__c apd : accPlanDetailsDelete){
                accPlanDetailIdsDelete.add(apd.Id);
            }

            delete accPlanDetailsDelete;

            List<Som_KamDetailCashIn__c> cashInsUpsert = new List<Som_KamDetailCashIn__c>();

            // remove cash ins from the upsert list that belong to an account plan detail that has been deleted
            for(Som_KamDetailCashIn__c cashIn : accPlanDetailCashInsUpsert){
                if(!accPlanDetailIdsDelete.contains(cashIn.Som_KamDetail__c)){
                    cashInsUpsert.add((Som_KamDetailCashIn__c) cashIn);
                }
            }

            List<Som_KamStrategyProfileTopic__c> stratsUpsert = new List<Som_KamStrategyProfileTopic__c>();

            // remove strat profs from the upsert list that belong to an account plan detail that has been deleted
            for(Som_KamStrategyProfileTopic__c spt : accPlanDetailStrategies){
                system.debug(LoggingLevel.ERROR, spt.Som_KamDetail__c);

                if(!accPlanDetailIdsDelete.contains(spt.Som_KamDetail__c)){

                    stratsUpsert.add(spt);
                }
            }

            update stratsUpsert;
            update accPlanStrategies;
            upsert cashInsUpsert;
            delete accPlanDetailCashInsDelete;

            resp = new P7S1_ApexResponse('data', buildAccountPlanEditData(accPlan.Som_Account__c, accPlan.Id));
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, 'Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            resp = new P7S1_ApexResponse('Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            Database.rollback(sp);
        }

        return resp;
    }



    /*************************
    * sets all previous year values for acc plan detail (cash ins) and creates strat profs
    *************************/
    private static void createAccountPlanDetailData(List<Som_KamDetail__c> apds, Id accId, List<Som_KamStrategyProfileTopic__c> profileTemplates){

        Map<Id, Som_KamDetail__c> accPlanTeamId2AccPlanDetail = new Map<Id, Som_KamDetail__c>();

        for(Som_KamDetail__c apd : apds){
            accPlanTeamId2AccPlanDetail.put(apd.Som_KamTeam__c, apd);
        }

        Integer year = Date.today().year();
        Set<Id> annualCashInIds = new Set<Id>();

        // set Annual Account Cash In data for the new acc plan details
        for(Som_KamAccountCashIn__c annualCashIn : [
            SELECT
                Id,
                Som_KamTeam__c,
                Som_CashExternalYield__c,
                Som_CashIn__c,
                Som_Year__c
            FROM
                Som_KamAccountCashIn__c
            WHERE
                Som_Year__c = :year AND
                Som_Account__c = :accId])
        {
            if(accPlanTeamId2AccPlanDetail.get(annualCashIn.Som_KamTeam__c) != null){
                annualCashInIds.add(annualCashIn.Id);
                accPlanTeamId2AccPlanDetail.get(annualCashIn.Som_KamTeam__c).Som_PreviousCashIn__c = annualCashIn.Som_CashIn__c;
                accPlanTeamId2AccPlanDetail.get(annualCashIn.Som_KamTeam__c).Som_PreviousCashExternalYield__c = annualCashIn.Som_CashExternalYield__c;
                accPlanTeamId2AccPlanDetail.get(annualCashIn.Som_KamTeam__c).Som_KamAccountCashIn__c = annualCashIn.Id;
            }
        }

        insert accPlanTeamId2AccPlanDetail.values();

        List<Som_KamDetailCashIn__c> acpdcids = new List<Som_KamDetailCashIn__c>();

        // set Annual Account Cash In Detail data for the new acc plan detail cash ins
        for(Som_KamAccountCashInDetail__c annualCashInDetail : [
            SELECT
                Id,
                Name,
                Som_KamAccountCashIn__c,
                Som_KamAccountCashIn__r.Som_KamTeam__c,
                Som_CashExternalYield__c,
                Som_CashIn__c
            FROM
                Som_KamAccountCashInDetail__c
            WHERE
                Som_KamAccountCashIn__c IN :annualCashInIds])
        {
            acpdcids.add(new Som_KamDetailCashIn__c(
                Name = annualCashInDetail.Name,
                Som_KamDetail__c = accPlanTeamId2AccPlanDetail.get(annualCashInDetail.Som_KamAccountCashIn__r.Som_KamTeam__c).Id,
                Som_KamAccountCashInDetail__c = annualCashInDetail.Id,
                Som_PreviousCashExternalYield__c = annualCashInDetail.Som_CashExternalYield__c,
                Som_PreviousCashIn__c = annualCashInDetail.Som_CashIn__c));

        }

        insert acpdcids;

        List<Som_KamStrategyProfileTopic__c> newProfiles = new List<Som_KamStrategyProfileTopic__c>();

        // create strat profs for every acc plan detail
        for(Som_KamDetail__c apd : accPlanTeamId2AccPlanDetail.values()){

            for(Som_KamStrategyProfileTopic__c spt : profileTemplates){
                newProfiles.add(new Som_KamStrategyProfileTopic__c(
                    Name = spt.Name,
                    Som_KamDetail__c = apd.Id,
                    Som_Template__c = spt.Id));
            }
        }

        insert newProfiles;
    }



    /*************************
    * deletes an acc plan
    *************************/
    @AuraEnabled
    public static P7S1_ApexResponse deleteAccountPlan(String accPlanId){
        P7S1_ApexResponse resp;
        Savepoint sp = Database.setSavepoint();

        try{
            delete new Som_Kam__c(Id = accPlanId);
            resp = new P7S1_ApexResponse();
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, 'Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            resp = new P7S1_ApexResponse('Some error occured: '+ e.getLineNumber() + ' => ' + e.getMessage());
            Database.rollback(sp);
        }

        return resp;
    }

    /************************************
    * WRAPPER CLASSES
    ************************************/


    /*************************
    *
    *************************/
    public class AccountPlanEditData{
        @AuraEnabled
        public AccountPlan accPlan{get;set;}

        @AuraEnabled
        public List<AccountPlanTeam> accPlanTeams{get;set;}

        @AuraEnabled
        public String accName{get;set;}

        public AccountPlanEditData(AccountPlan accPlan, List<AccountPlanTeam> accPlanTeams, String accName){
            this.accPlan        = accPlan;
            this.accPlanTeams   = accPlanTeams;
            this.accName        = accName;
        }
    }


    /*************************
    *
    *************************/
    public class AccountPlan{

        @AuraEnabled
        public Som_Kam__c accPlan{get;set;}

        @AuraEnabled
        public List<AccountPlanDetail> accPlanDetails{get;set;}

        @AuraEnabled
        public List<Som_KamStrategyProfileTopic__c> stratProfileTopics{get;set;}

        public AccountPlan(Som_Kam__c accPlan, List<AccountPlanDetail> accPlanDetails, List<Som_KamStrategyProfileTopic__c> stratProfileTopics){
            this.accPlan                = accPlan;
            this.accPlanDetails         = accPlanDetails;
            this.stratProfileTopics     = stratProfileTopics;
        }
    }


    /*************************
    *
    *************************/
    public class AccountPlanDetail{

        @AuraEnabled
        public Som_KamDetail__c accPlanDetail{get;set;}

        @AuraEnabled
        public List<AccountPlanDetailCashIn> accPlanDetailCashIn{get;set;}

        @AuraEnabled
        public List<Som_KamStrategyProfileTopic__c> stratProfileTopics{get;set;}

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> teamMembers{get;set;}

        @AuraEnabled
        public Decimal optInOpen{get;set;}

        @AuraEnabled
        public Decimal optInClosed{get;set;}

        @AuraEnabled
        public Boolean isValidPrevCashIn{get;set;}

        @AuraEnabled
        public Boolean isValidPrevCashExtYield{get;set;}

        @AuraEnabled
        public Boolean isValidTargetCashIn{get;set;}

        public AccountPlanDetail(Som_KamDetail__c accPlanDetail, List<AccountPlanDetailCashIn> accPlanDetailCashIn, List<Som_KamStrategyProfileTopic__c> stratProfileTopics, List<Ven_Utility.InputSelectOpt> teamMembers, Decimal optInOpen, Decimal optInClosed){
            this.accPlanDetail              = accPlanDetail;
            this.accPlanDetailCashIn        = accPlanDetailCashIn;
            this.stratProfileTopics         = stratProfileTopics;
            this.teamMembers                = teamMembers;
            this.isValidPrevCashIn          = true;
            this.isValidPrevCashExtYield    = true;
            this.isValidTargetCashIn        = true;
            this.optInOpen                  = optInOpen;
            this.optInClosed                = optInClosed;
        }
    }

    /*************************
    *
    *************************/
    public class AccountPlanDetailCashIn{
        @AuraEnabled
        public Som_KamDetailCashIn__c accPlanDetailCashIn{get;set;}

        @AuraEnabled
        public Boolean isValid{get;set;}

        @AuraEnabled
        public Boolean isValidPrevCashIn{get;set;}

        @AuraEnabled
        public Boolean isValidPrevCashExtYield{get;set;}

        @AuraEnabled
        public Boolean isValidTargetCashIn{get;set;}

        @AuraEnabled
        public Boolean isDeleted{get;set;}

        public AccountPlanDetailCashIn(Som_KamDetailCashIn__c apdci){
            this.accPlanDetailCashIn        = apdci;
            this.isValidPrevCashIn          = true;
            this.isValidPrevCashExtYield    = true;
            this.isValidTargetCashIn        = true;
            this.isDeleted                  = false;
        }
    }



    /*************************
    *
    *************************/
    public class AccountPlanTeam{

        @AuraEnabled
        public Som_KamTeam__c accPlanTeam{get;set;}

        @AuraEnabled
        public List<Ven_Utility.InputSelectOpt> teamMembers{get;set;}

        @AuraEnabled
        public String selectedUserId{get;set;}

        @AuraEnabled
        public Boolean isSelected{get;set;}

        @AuraEnabled
        public Boolean wasSelected{get;set;}

        @AuraEnabled
        public Boolean isValid{get;set;}

        @AuraEnabled
        public String status{get;set;}

        @AuraEnabled
        public List<String> allStatus{get;set;}

        @AuraEnabled
        public Som_KamDetail__c apdAccTeam{get;set;}

        public AccountPlanTeam(Som_KamTeam__c accPlanTeam, List<Ven_Utility.InputSelectOpt> teamMembers, String selectedUserId, Boolean isSelected, String status, Som_KamDetail__c apdAccTeam, List<String> allStatus){
            this.accPlanTeam    = accPlanTeam;
            this.teamMembers    = teamMembers;
            this.selectedUserId = selectedUserId;
            this.isSelected     = isSelected;
            this.wasSelected    = isSelected;
            this.isValid        = true;
            this.status         = status;
            this.apdAccTeam     = apdAccTeam;
            this.allStatus      = allStatus;
        }
    }


}