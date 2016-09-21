/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* Som_Kam_CmpCtrl
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         6-4-2016
* @description
* @lastchange
* @objects
* =================================================================
*/
public with sharing class Som_Kam_RedirectCtrl {
	public Id accId{get;set;}
    public String msg{get;set;}
    public String parameter{get;set;}

    public AccountPlan accountPlan{get;set;}
    public List<AccountPlanDetail> accountPlanDetails{get;set;}

    public Som_Kam_RedirectCtrl(ApexPages.StandardController sc){
        accId = sc.getId();
    }

    /*************************
    *
    *************************/
    public PageReference backToAccount(){
        return new PageReference('/'+accId);
    }


    /*************************
    *
    *************************/
    public PageReference redirect(){

        // check for existing account plan
        Decimal thisYear = Date.today().year();

        List<Som_Kam__c> accPlans = [
            SELECT
                Id
            FROM
                Som_Kam__c
            WHERE
                Som_Account__c = :accId AND
                Som_Year__c = :thisYear];

system.debug('###=> ' + accPlans);


        // check for SEK or KAM
        List<Account> accs = [
            SELECT
                SOM_SEK__c,
                SOM_KAM__c
            FROM
                Account
            WHERE
                Id = :accId AND
                (Som_KAM__c = :UserInfo.getUserId() OR Som_SEK__c = :UserInfo.getUserId())];

system.debug('###=> ' + accs);


        List<Som_KamDetail__c> accPlanDetails = new List<Som_KamDetail__c>();

        if(accPlans.size() > 0){
            accPlanDetails = [
                SELECT
                    Id,
                    Som_KamTeam__r.Name
                FROM
                    Som_KamDetail__c
                WHERE
                    Som_Kam__c = :accPlans[0].Id AND
                    Som_KamTeamMember__c = :UserInfo.getUserId() AND
                    Som_Status__c != 'Created'
                ORDER BY
                    Som_KamTeam__r.Name];
        }

system.debug('###=> ' + accPlanDetails);

        parameter = 'accId='+accId;

        accountPlanDetails = new List<AccountPlanDetail>();

        // is SEK/KAM
        if(accs.size() > 0){
            // account plan and details exists => user is sek/kam AND detail planner
            if(accPlans.size() > 0 && accPlanDetails.size() > 0){
                accountPlan = new AccountPlan(accPlans[0], '/c/Som_KamApp.app?accId='+ accId +'&accPlanId='+accPlans[0].Id);

                for(Som_KamDetail__c apd : accPlanDetails){
                    accountPlanDetails.add(new AccountPlanDetail(apd, '/c/Som_KamApp.app?accId='+ accId +'&accPlanDetailId='+ apd.Id));
                }
            }
            // sek/kam owns an account plan only
            else if(accPlans.size() > 0 && accPlanDetails.size() == 0){
                parameter += '&accPlanId='+ accPlans[0].Id;
                return new PageReference('/c/Som_KamApp.app?'+parameter);
            }
            // there is no acc plan yet
            else {
                return new PageReference('/c/Som_KamApp.app?'+parameter);
            }
        }
        // isnt SEK/KAM
        else {

            // account plan exists
            if(accPlans.size() > 0){
                // detail account plan for this user exists
                if(accPlanDetails.size() > 0){
                    accountPlan = new AccountPlan(accPlans[0], '/c/Som_KamApp.app?accId='+ accId +'&accPlanId='+accPlans[0].Id);
                    for(Som_KamDetail__c apd : accPlanDetails){
                        accountPlanDetails.add(new AccountPlanDetail(apd, '/c/Som_KamApp.app?accId='+ accId +'&accPlanDetailId='+ apd.Id));
                    }
                }
                // detail account plan for this user doesnt exists

                // user's unit invited
                else if(Som_Kam_CmpCtrl.isUserUnitInvited(accPlans[0].Id, UserInfo.getUserId())){
                    parameter += '&accPlanId='+ accPlans[0].Id;
                    return new PageReference('/c/Som_KamApp.app?'+parameter);
                }
                // user's unit is not invited
                else {
                    msg = Label.Som_lbl_AccPlanRedirectNoAccess;
                }
            }
            // account plan doesnt exists
            else {
                msg = Label.Som_lbl_AccPlanRedirectNoPlan;
            }
        }

        return null;
    }


    /*************************
    *
    *************************/
    public class AccountPlan{
        public Som_Kam__c accPlan{get;set;}

        public String accPlanUrl{get;set;}

        public AccountPlan(Som_Kam__c accPlan, String accPlanUrl){
            this.accPlan = accPlan;
            this.accPlanUrl = accPlanUrl;
        }
    }

    /*************************
    *
    *************************/
    public class AccountPlanDetail{
        public Som_KamDetail__c accPlanDetail{get;set;}

        public String accPlanDetailUrl{get;set;}

        public AccountPlanDetail(Som_KamDetail__c accPlanDetail, String accPlanDetailUrl){
            this.accPlanDetail = accPlanDetail;
            this.accPlanDetailUrl = accPlanDetailUrl;
        }
    }
}