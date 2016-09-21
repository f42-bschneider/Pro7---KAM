({
    onRemoveSubItemClick : function(component, event){
        component.set("v.accPlanDetailCashIn.isDeleted", true);
    },

    onChangeItem : function(component, event){
        /*** Workarround for rendering problems with Locker Service and pushing data into lists ***/
        var fireEvent = component.get("v.fireChangeEvent");
        if(fireEvent){
            var changeEvt = component.getEvent("changeTempItem");
            changeEvt.fire();
        }
    }
})