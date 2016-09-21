({
    buildAccPlanDetail : function(component) {
        var apd = component.get("v.data.accPlanDetail");

        return {
            "sobjectType"                       : "Som_KamDetail__c",
            "Id"                                : apd.Id,
            "Som_KamTeamMember__c"      : apd.Som_KamTeamMember__c,
            "Som_RatingDealLearnings__c"        : apd.Som_RatingDealLearnings__c,
            "Som_PreviousCashIn__c"             : apd.Som_PreviousCashIn__c,
            "Som_PreviousCashExternalYield__c"  : apd.Som_PreviousCashExternalYield__c,
            "Som_Status__c"                     : apd.Som_Status__c
        };
    },

    buildStratProfs : function(component){
        var stratProfs = component.get("v.data.stratProfileTopics"),
        result = [];

        for(var i=0; i<stratProfs.length; i+=1){
            result.push({
                "sobjectType"           : "Som_KamStrategyProfileTopic__c",
                "Id"                    : stratProfs[i].Id,
                "Som_Description__c"    : stratProfs[i].Som_Description__c
            });
        }

        return result;
    },

    buildCashInsUpsert : function(component){
        var cashIns = component.get("v.data.accPlanDetailCashIn"),
        result = [];

        for(var i=0; i<cashIns.length; i+=1){
            if(!cashIns[i].isDeleted){
                var apdci = cashIns[i].accPlanDetailCashIn;

                result.push({
                    "sobjectType"                       : "Som_KamDetailCashIn__c",
                    "Id"                                : apdci.Id,
                    "Name"                              : apdci.Name,
                    "Som_KamDetail__c"          : apdci.Som_KamDetail__c,
                    "Som_KamAccountCashInDetail__c"  : apdci.Som_KamAccountCashInDetail__c,
                    "Som_PreviousCashExternalYield__c"  : apdci.Som_PreviousCashExternalYield__c,
                    "Som_PreviousCashIn__c"             : apdci.Som_PreviousCashIn__c
                });
            }
        }

        return result;
    },


    buildCashInsDelete : function(component){
        var cashIns = component.get("v.data.accPlanDetailCashIn"),
        result = [];

        for(var i=0; i<cashIns.length; i+=1){
            if(cashIns[i].isDeleted){
                var apdci = cashIns[i].accPlanDetailCashIn;

                result.push({
                    "sobjectType" : "Som_KamDetailCashIn__c",
                    "Id"          : apdci.Id
                });
            }
        }

        return result;
    },

    validateAccPlanDetail : function(component){

        var data = component.get("v.data");

        if(!data.isValidPrevCashExtYield || !data.isValidPrevCashIn){
            return false;
        }

        for(var j=0; j<data.accPlanDetailCashIn.length; j+=1){
            var apdci = data.accPlanDetailCashIn[j];

            if(!apdci.isValidPrevCashExtYield || !apdci.isValidPrevCashIn){
                return false;
            }
        }

        return true;
    }
})