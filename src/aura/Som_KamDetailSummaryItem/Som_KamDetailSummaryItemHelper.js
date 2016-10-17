({
    fillTempListWithItems : function(component){
        /*** Workarround for rendering problems with Locker Service and pushing data into lists ***
        *** http://salesforce.stackexchange.com/questions/130418/auraiteration-doesnt-rerender-when-changing-attribute-object-under-locker-se ***/
        var accPlanDetail = component.get("v.accPlanDetail");
        if(accPlanDetail !== null && accPlanDetail.accPlanDetailCashIn !== null && accPlanDetail.accPlanDetailCashIn.length > 0){
            var lstTemp = [];
            for(var i=0; i<accPlanDetail.accPlanDetailCashIn.length; i+=1){

                var result = {
                    "accPlanDetailCashIn" : {
                        "Id"                                    : accPlanDetail.accPlanDetailCashIn[i].accPlanDetailCashIn.Id,
                        "Name"                              : accPlanDetail.accPlanDetailCashIn[i].accPlanDetailCashIn.Name,
                        "Som_KamDetail__c"          : accPlanDetail.accPlanDetailCashIn[i].accPlanDetailCashIn.Som_KamDetail__c,
                        "Som_PreviousCashExternalYield__c"  : accPlanDetail.accPlanDetailCashIn[i].accPlanDetailCashIn.Som_PreviousCashExternalYield__c,
                        "Som_PreviousCashIn__c"             : accPlanDetail.accPlanDetailCashIn[i].accPlanDetailCashIn.Som_PreviousCashIn__c,
                        "Som_Cashin__c"                     : accPlanDetail.accPlanDetailCashIn[i].accPlanDetailCashIn.Som_Cashin__c
                    },
                    "isValidPrevCashExtYield"   : true,
                    "isValidPrevCashIn"         : true,
                    "isValidTargetCashIn"       : true,
                    "isDeleted" : false
                };
                lstTemp.push(result);
            }
            component.set("v.tempList", lstTemp);
        }
    },

    validateNewAccPlanDetailCashIn : function(component) {
        var newAccPlanDetail = component.get("v.newCashIn"),
        inputNewCashInName = component.find("newCashInName"),
        isValid = true;

        if(component.isValid() && inputNewCashInName.isValid()){
            inputNewCashInName.set("v.errors", null);

            if(newAccPlanDetail.Name === ''){
                inputNewCashInName.set("v.errors", [{"message":$A.get("$Label.c.Som_lbl_CompleteThisField")}]);
                isValid = false;
            }

            if(!newAccPlanDetail.isValidPrevCashExtYield){
                isValid = false;
            }

            if(!newAccPlanDetail.isValidPrevCashIn){
                isValid = false;
            }

            if(!newAccPlanDetail.isValidTargetCashIn){
                isValid = false;
            }
        }

        return isValid;
    },

    calcGap : function(component){
        var targetCashIn = component.get("v.accPlanDetail.accPlanDetail.Som_TargetCashIn__c"),
        optInClosed = component.get("v.accPlanDetail.optInClosed"),
        optInOpen = component.get("v.accPlanDetail.optInOpen"),
        gap = 0;

        if(typeof optInClosed !== 'undefined' && typeof optInOpen !== 'undefined' && typeof targetCashIn !== 'undefined'){
            gap = (optInClosed + optInOpen) - targetCashIn;
        }else if(typeof targetCashIn !== 'undefined'){
            gap = 0 - targetCashIn;
        }

        //Set color of gap value
        var gapOutput = component.find("gapOutput");
        if(gap < 0){
            $A.util.addClass(gapOutput, "redFont");
        }else{
            $A.util.removeClass(gapOutput, "redFont");
        }

        component.set("v.gap", gap);
        if(!$A.util.isEmpty(component.get("v.accPlanDetail.gap"))){
            component.set("v.accPlanDetail.gap", gap);
        }
    },

    getAccPlanTeam2Id : function(component){
        var mapTeams = component.get("v.accPlanTeamMap"),
        teamId = component.get("v.accPlanDetail.accPlanDetail.Som_KamTeam__c");

        if(!$A.util.isEmpty(teamId) && !$A.util.isEmpty(mapTeams)){
            component.set("v.currentTeam", mapTeams[teamId]);
        }

        //Check if selected Team Member is valid
        var accPlanTeam = component.get("v.currentTeam");
        if(typeof accPlanTeam.selectedUserId === 'undefined'){
            component.set("v.currentTeam.isValid", false);
        }
    },

    updateTeamMap : function(component, event){
        var mapTeams = component.get("v.accPlanTeamMap"),
        currentTeam = component.get("v.currentTeam");

        mapTeams[currentTeam.accPlanTeam.Id] = currentTeam;
        component.set("v.accPlanTeamMap", mapTeams);
    },

    setIsValid : function(component){
        if(component.isValid()){
            var isSelected = component.get("v.currentTeam.isSelected"),
            selectIsValid = component.get("v.selectIsValid");

            component.set("v.currentTeam.isValid", false);

            if(isSelected && selectIsValid){
                component.set("v.currentTeam.isValid", true);
            }
        }
    }
})