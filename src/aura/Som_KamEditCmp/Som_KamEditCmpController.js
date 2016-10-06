({
    /**** BS - 27.09.2016 - NEW function ****/
    onCopyFromLastYear : function(component, event, helper){
        var accId = component.get("v.accId"),
        selYear = component.get("v.selectedYear");

        component.set("v.renderSpinner", true);

        var copyData = component.get("c.copyDataFromLastYear");

        copyData.setParams({
            "accId"     : accId,
            "selectedYear" : selYear
        });

        copyData.setCallback(this, function(resp){
            var result = resp.getReturnValue();

            if(component.isValid() && result.isSuccess && resp.getState() === "SUCCESS"){

                component.set("v.data", result.values.data);

            }else {
                var errorStr = $A.get("$Label.c.Ven_lbl_ContactAdmin") + " - " + result.message;
                $A.get("e.c:f42_ToastEvt").setParams({"type": "error", "msg" : errorStr}).fire();
                //toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
                //toastr.info(result.message);
            }

            component.set("v.renderSpinner", false);
        });

        $A.enqueueAction(copyData);

    },

    /**** BS - 27.09.2016 - NEW show different years ****/
    onChangeYear : function(component, event, helper){
        var accId = component.get("v.accId"),
        accPlanId = component.get("v.accPlanId"),
        selYear = component.get("v.selectedYear");

        component.set("v.renderSpinner", true);

        var getAccountPlanEditData = component.get("c.getAccountPlanEditData");

        getAccountPlanEditData.setParams({
            "accId"     : accId,
            "accPlanId" : accPlanId,
            "selectedYear" : selYear
        });

        getAccountPlanEditData.setCallback(this, function(resp){
            var result = resp.getReturnValue();

            if(component.isValid() && result.isSuccess && resp.getState() === "SUCCESS"){

                component.set("v.data", result.values.data);
                if(! $A.util.isEmpty(result.values.data.accPlan.accPlan.Id)){
                    component.set("v.accPlanId", result.values.data.accPlan.accPlan.Id);
                    component.set("v.showCopy", false);
                }else{
                    component.set("v.showCopy", true);
                }

            }else {
                var errorStr = $A.get("$Label.c.Ven_lbl_ContactAdmin") + " - " + result.message;
                $A.get("e.c:f42_ToastEvt").setParams({"type": "error", "msg" : errorStr}).fire();
                //toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
                //toastr.info(result.message);
            }

            component.set("v.renderSpinner", false);
        });

        $A.enqueueAction(getAccountPlanEditData);
    },


    onAccIdAndAccPlanIdSet : function(component, event, helper) {
        var accId,
        accPlanId,
        selYear,
        params = event.getParam('arguments');

        component.set("v.renderSpinner", true);

        if(params){
            accId = params.accId;
            accPlanId = params.accPlanId;
            selYear = component.get("v.selectedYear")

            // SET ACCOUNT DASH BOARD ACC ID
            component.find("dashboard").setAccountId(accId);

            component.set("v.accPlanId", accPlanId);
            component.set("v.accId", accId);

            var getAccountPlanEditData = component.get("c.getAccountPlanEditData");

            getAccountPlanEditData.setParams({
                "accId"     : accId,
                "accPlanId" : accPlanId,
                "selectedYear" : selYear
            });

            getAccountPlanEditData.setCallback(this, function(resp){
                var result = resp.getReturnValue();

                if(component.isValid() && result.isSuccess && resp.getState() === "SUCCESS"){

                    if(accPlanId === null){
                        component.set("v.isRead", false);
                    }

                    //Build list with available years and set selected year
                    var selYear = component.get("v.selectedYear");
                    helper.buildYearList(component, result.values.data.years);
                    component.set("v.selectedYear", result.values.data.accPlan.accPlan.Som_Year__c);

                    // user is kam/sek => write mode
                    if(result.values.isKamSek){
                        component.set("v.data", result.values.data);
                        component.set("v.showButtons", true);
                    }else if(result.values.isDetailPlanner){
                        // user is detail planner => read mode
                        component.set("v.data", result.values.data);
                        component.set("v.showButtons", false);
                    }else if(result.values.userUnitInvited){
                        // user unit is invited => read mode
                        component.set("v.data", result.values.data);
                        component.set("v.showButtons", false);
                    }else {
                        // show error message
                        component.set("v.showButtons", false);
                        component.set("v.showAll", false);
                    }

                }else {
                    var errorStr = $A.get("$Label.c.Ven_lbl_ContactAdmin") + " - " + result.message;
                    $A.get("e.c:f42_ToastEvt").setParams({"type": "error", "msg" : errorStr}).fire();
                    //toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
                    //toastr.info(result.message);
                }

                component.set("v.renderSpinner", false);
            });

            $A.enqueueAction(getAccountPlanEditData);
        }
    },

    onSave : function(component, event, helper){
        component.set("v.renderSpinner", true);

        if(!helper.validateAccPlan(component)){
            component.set("v.renderSpinner", false);
            return;
        }

        var saveAccountPlan = component.get("c.saveAccountPlan");

        saveAccountPlan.setParams({
            "accPlan"                       : helper.buildAccPlan(component),
            "accPlanDetailsUpsert"          : helper.buildAccPlanDetailsUpsert(component),
            "accPlanDetailsDelete"          : helper.buildAccPlanDetailsDelete(component),
            "accPlanDetailCashInsUpsert"    : helper.buildAccPlanDetailCashInsUpsert(component),
            "accPlanDetailCashInsDelete"    : helper.buildAccPlanDetailCashInsDelete(component),
            "accPlanStrategies"             : helper.buildAccPlanStrategies(component),
            "accPlanDetailStrategies"       : helper.buildAccPlanDetailStrategies(component)
        });

        saveAccountPlan.setCallback(this, function(resp){
            var result = resp.getReturnValue();

            if(result.isSuccess && resp.getState() === "SUCCESS" && component.isValid()){
                var data = result.values.data;
                component.set("v.data", data);
                component.set("v.accPlanId", result.values.data.accPlan.accPlan.Id);

                $A.get("e.c:f42_ToastEvt").setParams({"type": "success", "msg" : $A.get("$Label.c.Ven_lbl_Saved")}).fire();
                //toastr.success($A.get("$Label.c.Ven_lbl_Saved"));

                component.set("v.isRead", true);
            }else {
                var errorStr = $A.get("$Label.c.Ven_lbl_ContactAdmin") + " - " + result.message;
                $A.get("e.c:f42_ToastEvt").setParams({"type": "error", "msg" : errorStr}).fire();
                //toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
                //toastr.info(result.message);
            }

            component.set("v.renderSpinner", false);
        });

        $A.enqueueAction(saveAccountPlan);
    },

    onInviteReview : function(component, event, helper){
        component.set("v.renderSpinner", true);

        var accPlan = component.get("v.data.accPlan.accPlan"),
        isValid = true,
        accPlanTeams = component.get("v.data.accPlanTeams"),
        accPlanTeamIds = [],
        inviteForReview = component.get("c.inviteForReview");

        // show error if review date is not set
        if(typeof accPlan.Som_Review__c === 'undefined' || accPlan.Som_Review__c === ''){

            $A.get("e.c:f42_ToastEvt").setParams({"type": "warning", "msg" : $A.get("$Label.c.Som_lbl_Review") + ' ' + $A.get("$Label.c.Som_lbl_Date")+ ' ' +$A.get("$Label.c.Som_lbl_MustBeCompleted")}).fire();
            //toastr.warning($A.get("$Label.c.Som_lbl_Review") + ' ' + $A.get("$Label.c.Som_lbl_Date")+ ' ' +$A.get("$Label.c.Som_lbl_MustBeCompleted"));
            isValid = false;
        }

        // show error if email text is not set
        if(typeof accPlan.Som_EmailText__c === 'undefined' || accPlan.Som_EmailText__c === ''){
            $A.get("e.c:f42_ToastEvt").setParams({"type": "warning", "msg" : $A.get("$Label.c.Som_lbl_EmailText")+ ' ' +$A.get("$Label.c.Som_lbl_MustBeCompleted")}).fire();
            //toastr.warning($A.get("$Label.c.Som_lbl_EmailText")+ ' ' +$A.get("$Label.c.Som_lbl_MustBeCompleted"));
            isValid = false;
        }

        if(!isValid){
            component.set("v.renderSpinner", false);
            return;
        }

        // acc plan detail having status Kickoff or Review can be invited for review only
        for(var i in accPlanTeams){
            if(accPlanTeams[i].isSelected){
                if(accPlanTeams[i].status === 'Kickoff' || accPlanTeams[i].status === 'Review'){
                    accPlanTeamIds.push(accPlanTeams[i].accPlanTeam.Id);
                }
            }
        }

        if(accPlanTeamIds.length === 0){
            $A.get("e.c:f42_ToastEvt").setParams({"type": "info", "msg" : $A.get("$Label.c.Som_lbl_NoTeamMembersToInvite")}).fire();
            //toastr.info($A.get("$Label.c.Som_lbl_NoTeamMembersToInvite"));
            component.set("v.renderSpinner", false);
            return;
        }

        inviteForReview.setParams({
            "accPlanTeamIds" : accPlanTeamIds,
            "accPlanId" : accPlan.Id,
            "accId" : accPlan.Som_Account__c,
            "hostUrl" : helper.getHostUrl(),
            "selectedYear" : accPlan.Som_Year__c
        });

        inviteForReview.setCallback(this, function(resp){
            var result = resp.getReturnValue();

            if(result.isSuccess && resp.getState() === 'SUCCESS'){
                component.set("v.data", result.values.data);
                $A.get("e.c:f42_ToastEvt").setParams({"type": "success", "msg" : $A.get("$Label.c.Som_lbl_TeamMembersNotified")}).fire();
                //toastr.success($A.get("$Label.c.Som_lbl_TeamMembersNotified"));
            }else {
                var errorStr = $A.get("$Label.c.Ven_lbl_ContactAdmin") + " - " + result.message;
                $A.get("e.c:f42_ToastEvt").setParams({"type": "error", "msg" : errorStr}).fire();
                //toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
                //toastr.info(result.message);
            }

            component.set("v.renderSpinner", false);
        });

        $A.enqueueAction(inviteForReview);
    },

    onInviteKickoff : function(component, event, helper){
        component.set("v.renderSpinner", true);

        var accPlan = component.get("v.data.accPlan.accPlan"),
        isValid = true,
        inviteAll = component.get("v.inviteAll"),
        accPlanTeams = component.get("v.data.accPlanTeams"),
        accPlanTeamIds = [],
        inviteForKickoff = component.get("c.inviteForKickoff");

        if(typeof accPlan.Som_Kickoff__c === 'undefined' || accPlan.Som_Kickoff__c === ''){
            $A.get("e.c:f42_ToastEvt").setParams({"type": "warning", "msg" : $A.get("$Label.c.Som_lbl_Kickoff")+ ' ' +$A.get("$Label.c.Som_lbl_MustBeCompleted")}).fire();
            //toastr.warning($A.get("$Label.c.Som_lbl_Kickoff")+ ' ' +$A.get("$Label.c.Som_lbl_MustBeCompleted"));
            isValid = false;
        }

        if(typeof accPlan.Som_EmailText__c === 'undefined' || accPlan.Som_EmailText__c === ''){
            $A.get("e.c:f42_ToastEvt").setParams({"type": "warning", "msg" : $A.get("$Label.c.Som_lbl_EmailText")+ ' ' +$A.get("$Label.c.Som_lbl_MustBeCompleted")}).fire();
            //toastr.warning($A.get("$Label.c.Som_lbl_EmailText")+ ' ' +$A.get("$Label.c.Som_lbl_MustBeCompleted"));
            isValid = false;
        }

        if(!isValid){
            component.set("v.renderSpinner", false);
            return;
        }

        for(var i in accPlanTeams){
            if(accPlanTeams[i].isSelected){
                if(inviteAll){
                    accPlanTeamIds.push(accPlanTeams[i].accPlanTeam.Id);
                }else if(accPlanTeams[i].status === 'Created'){
                    accPlanTeamIds.push(accPlanTeams[i].accPlanTeam.Id);
                }
            }
        }

        if(accPlanTeamIds.length === 0){
            $A.get("e.c:f42_ToastEvt").setParams({"type": "info", "msg" : $A.get("$Label.c.Som_lbl_AllTeamMembersInvited")}).fire();
            //toastr.info($A.get("$Label.c.Som_lbl_AllTeamMembersInvited"));
            component.set("v.renderSpinner", false);
            return;
        }

        inviteForKickoff.setParams({
            "accPlanTeamIds" : accPlanTeamIds,
            "accPlanId" : accPlan.Id,
            "accId" : accPlan.Som_Account__c,
            "hostUrl" : helper.getHostUrl(),
            "selectedYear" : accPlan.Som_Year__c
        });

        inviteForKickoff.setCallback(this, function(resp){
            var result = resp.getReturnValue();

            if(result.isSuccess && resp.getState() === 'SUCCESS'){
                component.set("v.data", result.values.data);
                $A.get("e.c:f42_ToastEvt").setParams({"type": "success", "msg" : $A.get("$Label.c.Som_lbl_TeamMembersNotified")}).fire();
                //toastr.success($A.get("$Label.c.Som_lbl_TeamMembersNotified"));
            }else {
                var errorStr = $A.get("$Label.c.Ven_lbl_ContactAdmin") + " - " + result.message;
                $A.get("e.c:f42_ToastEvt").setParams({"type": "error", "msg" : errorStr}).fire();
                //toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
                //toastr.info(result.message);
            }

            component.set("v.renderSpinner", false);
        });

        $A.enqueueAction(inviteForKickoff);
    },

    onCancel : function(component){
        component.set("v.data", component.get("v.dataTmpMain"));
        component.set("v.isRead", true);
    },

    onAccount : function(component){
        if(typeof component.get("v.accId") !== 'undefined'){
            location.href = "/" + component.get("v.accId");
        }else {
            window.history.back();
        }
    },

    onInviteKickoffChange : function(component, event){
        var selected = event.getSource().get("v.text");

        if(selected === 'inviteAll'){
            component.set("v.inviteAll", true);
        }else {
            component.set("v.inviteAll", false);
        }
    },

    onReviewStrategies : function(component){
        component.set("v.isMainView", false);
        component.set("v.dataTmpStratProf", JSON.parse(JSON.stringify(component.get("v.data"))));
        component.find("stratSummary").setAccPlan(component.get("v.data.accPlan"));
    },

    onStratProfOk : function(component){
        component.set("v.isMainView", true);
    },

    onStratProfCancel : function(component){
        var isRead = component.get("v.isRead");
        if(!isRead){
            component.set("v.data", component.get("v.dataTmpStratProf"));
        }
        component.set("v.isMainView", true);
    },

    onStratProfChange : function(component){
        var accPlan = component.get("v.data.accPlan");
        component.find("stratSummary").setAccPlan(accPlan);
    },

    showKickoffModal: function(component, event, helper) {
        //Toggle CSS styles for opening Modal
        helper.toggleClass(component, 'backdrop', 'slds-backdrop--');
        helper.toggleClass(component, 'kickoffModal', 'slds-fade-in-');
    },

    hideKickoffModal : function(component, event, helper) {
         //Toggle CSS styles for hiding Modal
        helper.toggleClassInverse(component, 'backdrop', 'slds-backdrop--');
        helper.toggleClassInverse(component, 'kickoffModal', 'slds-fade-in-');
    },

    showReviewModal: function(component, event, helper) {
        //Toggle CSS styles for opening Modal
        helper.toggleClass(component, 'backdrop', 'slds-backdrop--');
        helper.toggleClass(component, 'reviewModal', 'slds-fade-in-');
    },

    hideReviewModal : function(component, event, helper) {
         //Toggle CSS styles for hiding Modal
        helper.toggleClassInverse(component, 'backdrop', 'slds-backdrop--');
        helper.toggleClassInverse(component, 'reviewModal', 'slds-fade-in-');
    },

    showDetailSection : function(component, event, helper){
        $A.util.toggleClass(component.find("detailSection"), 'dontShowSection');
    },

    showStratProfileSection : function(component, event, helper){
        $A.util.toggleClass(component.find("stratProfileSection"), 'dontShowSection');
    },

    showTeamSection : function(component, event, helper){
        $A.util.toggleClass(component.find("teamSection"), 'dontShowSection');
    }

    /**** Not needed BS - 27.09.2016 *****
    onEdit : function(component){
        component.set("v.dataTmpMain", JSON.parse(JSON.stringify(component.get("v.data"))));
        component.set("v.dataTmpStratProf", JSON.parse(JSON.stringify(component.get("v.data"))));
        component.set("v.isRead", false);
    },*/

    /*** OLD Delete function not needed anymore
    onDelete : function(component){
        var accPlanId = component.get("v.accPlanId");

        var deleteAccountPlan = component.get("c.deleteAccountPlan");

        deleteAccountPlan.setParams({"accPlanId" : accPlanId});

        deleteAccountPlan.setCallback(this, function(resp){
            var result = resp.getReturnValue();

            if(result.isSuccess && resp.getState() === "SUCCESS"){
                location.href = "/" + component.get("v.accId");
            }else {
                var errorStr = $A.get("$Label.c.Ven_lbl_ContactAdmin") + " - " + result.message;
                $A.get("e.c:f42_ToastEvt").setParams({"type": "error", "msg" : errorStr}).fire();
                //toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
                //toastr.info(result.message);
            }
        });

        $A.enqueueAction(deleteAccountPlan);
    }, */
})