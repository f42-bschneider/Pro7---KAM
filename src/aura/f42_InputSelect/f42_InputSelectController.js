({
    onInit : function(component, event, helper) {
        helper.validateValue(component);
    },

    onValueChange : function(component, event, helper){
        component.set("v.value", component.find("inputSelect").get("v.value"));
        helper.validateValue(component);
    },

    onRequireChange : function(component, event, helper){
        helper.validateValue(component);
    }
})