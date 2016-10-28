public without sharing class LS_TestCtrl {

    /*************************
    * Test Load
    *************************/
    @AuraEnabled
    public static testWrapper getData(){

        Som_KamDetail__c som = [
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
                Id = 'a2U3E00000085Ui' ];

        return new testWrapper(som, true);
    }

    /*************************
    * Test Save
    *************************/
    @AuraEnabled
    public static void doSave(Som_KamDetail__c som){
        update som;
    }

    public class testWrapper{

        @AuraEnabled
        public Som_KamDetail__c detail{get;set;}

        @AuraEnabled
        public Boolean check{get;set;}


        public testWrapper(Som_KamDetail__c detail, Boolean check){
            this.detail = detail;
            this.check = check;
        }
    }

}