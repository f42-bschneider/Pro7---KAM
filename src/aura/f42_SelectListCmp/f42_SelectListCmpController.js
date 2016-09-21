({
    /**** Init on load ****/
    doInit : function(component, event, helper){
        helper.onInit(component, helper);
    },

    /**** Show or hide selectlist ****/
    doToggleList : function(component, event, helper) {
        helper.toggleList(component, event);
    },

    /**** Select item ****/
    doSelect : function(component, event, helper){
        helper.selectItem(component, event, helper);
    },

    /**** Change state of required ****/
    doChangeRequired : function(component, event, helper){
        helper.checkRequired(component, helper);
    }

})