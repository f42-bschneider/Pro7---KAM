({
    onInit : function(component, event, helper) {
        var accPlanId   = helper.getParamByName('accPlanId'),
        accPlanDetailId = helper.getParamByName('accPlanDetailId'),
        accId = helper.getParamByName('accId');

        if(component.isValid()){
            component.set("v.accId", accId);

            if(accPlanId){
                //show to Som_KamEditCmp.cmp => edit acc plan
                component.set("v.showAccountPlan", true);
                //aura:method in Som_KamEditCmp.cmp
                component.find("accPlanEdit").setAccIdAndAccPlanId(accId, accPlanId);
            }else if(accPlanDetailId){
                // show to Som_KamDetailEditCmp.cmp => edit acc plan detail
                component.set("v.showAccountPlanDetail", true);
                // aura:method in Som_KamDetailEditCmp.cmp
                component.find("accPlanDetailEdit").setAccPlanDetailId(accId, accPlanDetailId);
            }else {
                // show to Som_KamEditCmp.cmp => new acc plan
                component.set("v.showAccountPlan", true);
                component.find("accPlanEdit").setAccIdAndAccPlanId(accId, null);
            }
        }
    },

    callToast : function(component, event, helper){
        helper.callToast(component, event, helper);
    }

    /*** Does not work with Locker-Service ***
    onInitScripts : function(component, event, helper){
        helper.initToastr();
    }*/
})