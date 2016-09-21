({
    onInit : function(component, event, helper) {
        helper.validateValue(component);
    },

    onValueChange : function(component, event, helper){
        helper.validateValue(component);
        component.set("v.value", component.find("inputSelect").get("v.value"));
    },

    onRequireChange : function(component, event, helper){
        helper.validateValue(component);
    }
})