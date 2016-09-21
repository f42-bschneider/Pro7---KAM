({
    onInit : function(component, event, helper) {
        if(component.isValid()){
            helper.calcGap(component);
        }

        /*** Workarround for rendering problems with Locker Service and pushing data into lists ***
        *** http://salesforce.stackexchange.com/questions/130418/auraiteration-doesnt-rerender-when-changing-attribute-object-under-locker-se ***/
       helper.fillTempListWithItems(component);
    },

    onInitiateTempList : function(component, event, helper){
      helper.fillTempListWithItems(component);
    },

    onAddAccPlanDetailCashIn : function(component, event, helper){
        var accPlanDetail = component.get("v.accPlanDetail"),
        newAccPlanDetail = component.get("v.newCashIn"),
        result,
        resetNewCashIn;

        if(component.isValid()){
            if(!helper.validateNewAccPlanDetailCashIn(component)){
                $A.get("e.c:f42_ToastEvt").setParams({"type": "warning", "msg" : $A.get("$Label.c.Ven_lbl_CompleteFields")}).fire();
                //toastr.warning($A.get("$Label.c.Ven_lbl_CompleteFields"));
                return;
            }

            result = {
                "accPlanDetailCashIn" : {
                    "Name"                              : newAccPlanDetail.Name,
                    "Som_KamDetail__c"          : accPlanDetail.accPlanDetail.Id,
                    "Som_PreviousCashExternalYield__c"  : newAccPlanDetail.Som_PreviousCashExternalYield__c,
                    "Som_PreviousCashIn__c"             : newAccPlanDetail.Som_PreviousCashIn__c,
                    "Som_Cashin__c"                     : newAccPlanDetail.Som_Cashin__c
                },
                "isValidPrevCashExtYield"   : true,
                "isValidPrevCashIn"         : true,
                "isValidTargetCashIn"       : true,
                "isDeleted" : false
            };

            /*** Workarround for rendering problems with Locker Service and pushing data into lists ***/
            var check = component.get("v.tempList");
            check.push(result);
            component.set("v.tempList", check);

            //accPlanDetail.accPlanDetailCashIn.push(result);
            //component.set("v.accPlanDetail", accPlanDetail);

            resetNewCashIn = {
                "Name"                              : '',
                "Som_PreviousCashIn__c"             : 0,
                "Som_PreviousCashExternalYield__c"  : 0,
                "Som_Cashin__c"                     : 0,
                "isValidPrevCashIn"                 : true,
                "isValidPrevCashExtYield"           : true,
                "isValidTargetCashIn"               : true
            };

            component.set("v.newCashIn", resetNewCashIn);
        }
    },

    onNewCashInNameChange : function(component){
        if(component.isValid()){
            var newCashInName = component.get("v.newCashIn.Name"),
            inputNewCashInName = component.find("newCashInName");

            inputNewCashInName.set("v.errors", null);

            if(newCashInName === ''){
                inputNewCashInName.set("v.errors", [{"message":$A.get("$Label.c.Som_lbl_CompleteThisField")}]);
            }
        }
    },

    onTargetCashInChange : function(component, event, helper){
        if(component.isValid()){
            helper.calcGap(component);
        }
    },

    getItemsFromTempList : function(component, event, helper){

        var lstTemp = component.get("v.tempList");
        component.set("v.accPlanDetail.accPlanDetailCashIn", lstTemp);

    }
})