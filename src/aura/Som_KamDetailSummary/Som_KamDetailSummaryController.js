({
    onInit : function(component) {
        component.set("v.thisYear", new Date().getFullYear());
    },

    onShowSubItems : function(component){
        component.set("v.showSubItems", true);
    },

    onHideSubItems : function(component){
        component.set("v.showSubItems", false);
    }
})