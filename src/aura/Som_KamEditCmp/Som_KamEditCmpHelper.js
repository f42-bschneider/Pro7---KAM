({
    getHostUrl : function(){
        return location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '');
    },

    buildAccPlan : function(component) {
        var accPlan = component.get("v.data.accPlan.accPlan"),
        result;

        result = {
            "sobjectType"       : "Som_Kam__c",
            "Id"                : accPlan.Id,
            "Som_Account__c"    : accPlan.Som_Account__c,
            "Som_Year__c"       : accPlan.Som_Year__c,
            "Som_Kickoff__c"    : accPlan.Som_Kickoff__c,
            "Som_Review__c"     : accPlan.Som_Review__c,
            "Som_EmailText__c"  : accPlan.Som_EmailText__c
        };

        return result;
    },

    buildAccPlanDetailsUpsert : function(component){
        var apds        = component.get("v.data.accPlan.accPlanDetails"),
        apId            = component.get("v.data.accPlan.accPlan.Id"),
        accPlanTeams    = component.get("v.data.accPlanTeams"),
        result          = [];

        for(var i=0; i<accPlanTeams.length; i+=1){
            var apt = accPlanTeams[i];

            // new account plan detail
            if(apt.isSelected && !apt.wasSelected){
                result.push({
                    "sobjectType"                   : "Som_KamDetail__c",
                    "Id"                            : null,
                    "Som_KamTeam__c"        : apt.accPlanTeam.Id,
                    "Som_KamTeamMember__c"  : apt.selectedUserId,
                    "Som_Status__c"                 : "Created"
                });
            }else if(apt.isSelected && apt.wasSelected){
                // existing account plan detail
                var apdId;

                for(var j=0; j<apds.length; j+=1){
                    if(apt.accPlanTeam.Id === apds[j].accPlanDetail.Som_KamTeam__c){
                        apdId = apds[j].accPlanDetail.Id;
                        var apd = apds[j].accPlanDetail;

                        result.push({
                            "sobjectType"                       : "Som_KamDetail__c",
                            "Id"                                : apdId,
                            "Som_KamTeam__c"            : apt.accPlanTeam.Id,
                            "Som_Kam__c"                : apId,
                            "Som_KamTeamMember__c"      : apt.selectedUserId,
                            "Som_RatingDealLearnings__c"        : apd.Som_RatingDealLearnings__c,
                            "Som_TargetCashIn__c"               : apd.Som_TargetCashIn__c,
                            "Som_PreviousCashIn__c"             : apd.Som_PreviousCashIn__c,
                            "Som_PreviousCashExternalYield__c"  : apd.Som_PreviousCashExternalYield__c
                        });

                        break;
                    }
                }
            }
        }

        return result;
    },

    buildAccPlanDetailsDelete : function(component){
        var apds        = component.get("v.data.accPlan.accPlanDetails"),
        accPlanTeams    = component.get("v.data.accPlanTeams"),
        result          = [];

        for(var i=0; i<accPlanTeams.length; i+=1){
            var apt = accPlanTeams[i];

            if(!apt.isSelected && apt.wasSelected){
                var apdId;

                for(var j=0; j<apds.length; j+=1){
                    if(apt.accPlanTeam.Id === apds[j].accPlanDetail.Som_KamTeam__c){
                        apdId = apds[j].accPlanDetail.Id;
                        break;
                    }
                }

                result.push({
                    "sobjectType"   : "Som_KamDetail__c",
                    "Id"            : apdId});
            }
        }

        return result;
    },

    buildAccPlanDetailCashInsUpsert : function(component){
        var apds = component.get("v.data.accPlan.accPlanDetails"),
        result = [];

        for(var i=0; i<apds.length; i+=1){

            for(var j=0; j<apds[i].accPlanDetailCashIn.length; j+=1){

                if(!apds[i].accPlanDetailCashIn[j].isDeleted){
                    var apdci = apds[i].accPlanDetailCashIn[j].accPlanDetailCashIn;

                    result.push({
                        "sobjectType"                       : "Som_KamDetailCashIn__c",
                        "Id"                                : apdci.Id,
                        "Name"                              : apdci.Name,
                        "Som_KamDetail__c"          : apdci.Som_KamDetail__c,
                        "Som_KamAccountCashInDetail__c"  : apdci.Som_KamAccountCashInDetail__c,
                        "Som_PreviousCashExternalYield__c"  : apdci.Som_PreviousCashExternalYield__c,
                        "Som_PreviousCashIn__c"             : apdci.Som_PreviousCashIn__c,
                        "Som_Cashin__c"                     : apdci.Som_Cashin__c
                    });
                }
            }
        }

        return result;
    },

    buildAccPlanDetailCashInsDelete : function(component){
        var apds = component.get("v.data.accPlan.accPlanDetails"),
        result = [];

        for(var i=0; i<apds.length; i+=1){

            for(var j=0; j<apds[i].accPlanDetailCashIn.length; j+=1){
                if(apds[i].accPlanDetailCashIn[j].isDeleted && typeof apds[i].accPlanDetailCashIn[j].accPlanDetailCashIn.Id !== 'undefined'){
                    var apdci = apds[i].accPlanDetailCashIn[j].accPlanDetailCashIn;

                    result.push({
                        "sobjectType"   : "Som_KamDetailCashIn__c",
                        "Id"            : apdci.Id
                    });
                }
            }
        }

        return result;
    },

    buildAccPlanStrategies : function(component){
        var accPlanStrats = component.get("v.data.accPlan.stratProfileTopics"),
        result = [];

        for(var i=0; i<accPlanStrats.length; i+=1){
            var strat = accPlanStrats[i];

            result.push({
                "sobjectType"           : "Som_KamStrategyProfileTopic__c",
                "Id"                    : strat.Id,
                "Som_Description__c"    : strat.Som_Description__c
            });
        }

        return result;
    },

    buildAccPlanDetailStrategies : function(component){
        var accPlanDetails = component.get("v.data.accPlan.accPlanDetails"),
        result = [];

        for(var i=0; i<accPlanDetails.length; i+=1){
            for(var j=0; j<accPlanDetails[i].stratProfileTopics.length; j+=1){
                var strat = accPlanDetails[i].stratProfileTopics[j];

                result.push({
                    "sobjectType"               : "Som_KamStrategyProfileTopic__c",
                    "Id"                        : strat.Id,
                    "Som_KamDetail__c"  : accPlanDetails[i].accPlanDetail.Id,
                    "Som_Description__c"        : strat.Som_Description__c
                });
            }
        }

        return result;
    },

    validateAccPlan : function(component){
        var isAccPlanTeamsValid = this.isAccPlanTeamsValid(component),
        isOneAccPlanTeamSelected = this.isOneAccPlanTeamSelected(component),
        isAccPlanDetailsValid = this.isAccPlanDetailsValid(component);

        if(!isAccPlanTeamsValid){
            //toastr.warning($A.get("$Label.c.Som_lbl_CompleteAccPlanTeamsForSelected"));
            $A.get("e.c:f42_ToastEvt").setParams({"type": "warning", "msg" : $A.get("$Label.c.Som_lbl_CompleteAccPlanTeamsForSelected")}).fire();
        }

        if(!isOneAccPlanTeamSelected){
            //toastr.warning($A.get("$Label.c.Som_lbl_AtLeast1AccTeamSelected"));
            $A.get("e.c:f42_ToastEvt").setParams({"type": "warning", "msg" : $A.get("$Label.c.Som_lbl_AtLeast1AccTeamSelected")}).fire();
        }

        if(!isAccPlanDetailsValid){
            //toastr.warning($A.get("$Label.c.Som_lbl_CompleteKickoffReviewSection"));
            $A.get("e.c:f42_ToastEvt").setParams({"type": "warning", "msg" : $A.get("$Label.c.Som_lbl_CompleteKickoffReviewSection")}).fire();
        }

        if(!isAccPlanTeamsValid || !isOneAccPlanTeamSelected || !isAccPlanDetailsValid){
            return false;
        }

        return true;
    },


    isAccPlanTeamsValid : function(component){
        var accPlanTeams = component.get("v.data.accPlanTeams");

        for(var i in accPlanTeams){
            if(!accPlanTeams[i].isValid && accPlanTeams[i].isSelected){
                return false;
            }
        }

        return true;
    },

    isOneAccPlanTeamSelected : function(component){
        var accPlanTeams = component.get("v.data.accPlanTeams");

        for(var i in accPlanTeams){
            if(accPlanTeams[i].isSelected){
                return true;
            }
        }

        return false;
    },

    isAccPlanDetailsValid : function(component){
        var accPlanDetails = component.get("v.data.accPlan.accPlanDetails");

        for(var i=0; i<accPlanDetails.length; i+=1){
            var apd = accPlanDetails[i];

            if(!apd.isValidPrevCashExtYield || !apd.isValidPrevCashIn || !apd.isValidTargetCashIn){
                return false;
            }

            for(var j=0; j<apd.accPlanDetailCashIn.length; j+=1){
                var apdci = apd.accPlanDetailCashIn[j];

                if(!apdci.isValidPrevCashExtYield || !apdci.isValidPrevCashIn || !apdci.isValidTargetCashIn){
                    return false;
                }
            }
        }

        return true;
    },

    setIsInvited : function(accPlanTeamId, component){
        var accPlanTeams = component.get("v.data.accPlanTeams");

        for(var i=0; i<accPlanTeams.length; i+=1){
            if(accPlanTeams[i].accPlanTeam.Id === accPlanTeamId){
                accPlanTeams[i].isInvited = true;
                component.set("v.data.accPlanTeams", accPlanTeams);
                break;
            }
        }
    },

    toggleClass: function(component, componentId, className) {
        var modal = component.find(componentId);
        $A.util.removeClass(modal, className+'hide');
        $A.util.addClass(modal, className+'open');
    },

    toggleClassInverse: function(component, componentId, className) {
        var modal = component.find(componentId);
        $A.util.addClass(modal, className+'hide');
        $A.util.removeClass(modal, className+'open');
    }

})