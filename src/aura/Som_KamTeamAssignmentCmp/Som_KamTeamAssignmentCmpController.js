({
    onInit : function(component) {
        if(component.isValid()){
            var accPlanTeam = component.get("v.accPlanTeam");

            if(typeof accPlanTeam.selectedUserId === 'undefined'){
                component.set("v.accPlanTeam.isValid", false);
            }

            if(typeof accPlanTeam.apdAccTeam === 'undefined'){
                component.set("v.isNew", true);
            }
        }
    },

    setIsValid : function(component){
        if(component.isValid()){
            var isSelected = component.get("v.accPlanTeam.isSelected"),
            selectIsValid = component.get("v.selectIsValid");

            component.set("v.accPlanTeam.isValid", false);

            if(isSelected && selectIsValid){
                component.set("v.accPlanTeam.isValid", true);
            }
        }
    }
})