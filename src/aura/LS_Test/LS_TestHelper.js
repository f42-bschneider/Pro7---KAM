({
    toggleClass: function(component,componentId,className) {
        var modal = component.find(componentId);
        $A.util.removeClass(modal,className+'hide');
        $A.util.addClass(modal,className+'open');
    },

    toggleClassInverse: function(component,componentId,className) {
        var modal = component.find(componentId);
        $A.util.addClass(modal,className+'hide');
        $A.util.removeClass(modal,className+'open');
    },

    loadData : function(component, event){
         var getAccountPlanDetailEditData = component.get("c.getData");

        getAccountPlanDetailEditData.setCallback(this, function(resp){
            var result = resp.getReturnValue();

            if(component.isValid()){
                component.set("v.testDetail", result.detail);
            }
        });

        $A.enqueueAction(getAccountPlanDetailEditData);
    }

})