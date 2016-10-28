({
    onAccPlanDetailIdSet : function(component, event) {
        var accPlanDetailId,
        params = event.getParam('arguments');

        component.set("v.renderSpinner", true);

        if(params){
            accPlanDetailId = params.accPlanDetailId;
            component.set("v.accPlanDetailId", accPlanDetailId);
            component.set("v.accId", params.accId);

            // SET ACCOUNT DASH BOARD ACC ID
            component.find("dashboard").setAccountId(params.accId);

            var getAccountPlanDetailEditData = component.get("c.getAccountPlanDetailEditData");

            getAccountPlanDetailEditData.setParams({
                "accPlanDetailId" : accPlanDetailId
            });

            getAccountPlanDetailEditData.setCallback(this, function(resp){
                var result = resp.getReturnValue();

                if(component.isValid() && result.isSuccess && resp.getState() === "SUCCESS"){

                    if(result.values.isDetailPlanner){
                        component.set("v.data", result.values.data);
                        component.set("v.isDetailPlanner", true);

                        //Initiate tempList for summary items
                        component.find("sumItemCmp").initiateTempList();

                    }else{
                        component.set("v.isDetailPlanner", false);
                    }
                }else {
                    var errorStr = $A.get("$Label.c.Ven_lbl_ContactAdmin") + " - " + result.message;
                    $A.get("e.c:f42_ToastEvt").setParams({"type": "error", "msg" : errorStr}).fire();
                    //toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
                    //toastr.info(result.message);
                }

                component.set("v.renderSpinner", false);
            });

            $A.enqueueAction(getAccountPlanDetailEditData);
        }
    },

    onAccount : function(component){
        if(typeof component.get("v.accId") !== 'undefined'){
            location.href = "/" + component.get("v.accId");
        }else {
            window.history.back();
        }
    },

    onSave : function(component, event, helper){
        component.set("v.renderSpinner", true);

        /*** Workarround for rendering problems with Locker Service and pushing data into lists ***/
        component.find("sumItemCmp").getItemsFromTempList();

        if(!helper.validateAccPlanDetail(component)){
            component.set("v.renderSpinner", false);
            $A.get("e.c:f42_ToastEvt").setParams({"type": "warning", "msg" : $A.get("$Label.c.Ven_lbl_CompleteFields")}).fire();
            //toastr.warning($A.get("$Label.c.Ven_lbl_CompleteFields"));
            return;
        }

        var saveAccPlanDetail = component.get("c.saveAccountPlanDetail"),
        accPlanDetail = helper.buildAccPlanDetail(component);

        saveAccPlanDetail.setParams({
            "accPlanDetail" : accPlanDetail,
            "profStrats"    : helper.buildStratProfs(component),
            "cashInUpserts" : helper.buildCashInsUpsert(component),
            "cashInDeletes" : helper.buildCashInsDelete(component)
        });

        saveAccPlanDetail.setCallback(this, function(resp){
            var result = resp.getReturnValue();

            if(component.isValid() && resp.getState() === 'SUCCESS' && result.isSuccess){
                $A.get("e.c:f42_ToastEvt").setParams({"type": "success", "msg" : $A.get("$Label.c.Ven_lbl_Saved")}).fire();
                //toastr.success($A.get("$Label.c.Ven_lbl_Saved"));
                component.set("v.renderSpinner", false);

                if(accPlanDetail.Som_Status__c === 'Invited'){
                    component.set("v.data.accPlanDetail.Som_Status__c", 'Kickoff');
                }

                /*** Workarround for rendering problems with Locker Service and pushing data into lists ***/
                component.set("v.data.accPlanDetailCashIn", result.values.dataUpserted);
                component.find("sumItemCmp").initiateTempList();

            }else {
                component.set("v.renderSpinner", false);
                var errorStr = $A.get("$Label.c.Ven_lbl_ContactAdmin") + " - " + result.message;
                $A.get("e.c:f42_ToastEvt").setParams({"type": "error", "msg" : errorStr}).fire();
                //toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
                //toastr.info(result.message);

            }

        });

        $A.enqueueAction(saveAccPlanDetail);
    },

    showDetailSection : function(component, event, helper){
        $A.util.toggleClass(component.find("detailSection"), 'dontShowSection');
    },

    showStratProfileSection : function(component, event, helper){
        $A.util.toggleClass(component.find("stratProfileSection"), 'dontShowSection');
    },

    showCashInsSection : function(component, event, helper){
        $A.util.toggleClass(component.find("cashInsSection"), 'dontShowSection');
    }
})