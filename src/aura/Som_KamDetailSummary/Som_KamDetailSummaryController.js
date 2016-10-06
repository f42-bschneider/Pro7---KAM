({
    onInit : function(component, event, helper) {
        component.set("v.thisYear", new Date().getFullYear());
        helper.calcSum(component, event);
    },

    onShowSubItems : function(component){
        component.set("v.showSubItems", true);
    },

    onHideSubItems : function(component){
        component.set("v.showSubItems", false);
    },

    onCalcSum : function(component, event, helper){
        helper.calcSum(component, event);
    }
})