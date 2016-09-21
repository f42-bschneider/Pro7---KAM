({
        /**** Init on load ****/
        onInit : function(component, helper){

            var selectedId = component.get("v.selectedId");
            helper.validateSelect(component, helper, selectedId);

        },

        /**** On selecting item out of selectoptions ****/
        selectItem : function(component, event, helper){

            var sourceId = event.currentTarget.id;
            var sourceLbl = helper.getLabel2Id(component, sourceId);

            if(sourceLbl === null){
                sourceLbl = ' - ';
                sourceId = '';
            }

            component.set("v.selectedId", sourceId);
            component.set("v.selectedLbl", sourceLbl);

            helper.toggleList(component, event);
            helper.checkRequired(component, helper);

            //Fire onChange event
            $A.get("e.c:f42_Select2Evt").setParams({"value": sourceId}).fire();
        },

        /**** Check state of value ****/
        checkRequired : function(component, helper){

            var required    = component.get("v.required");
            var selectedId   = component.get("v.selectedId");

            component.set("v.isValid", true);

            if(helper.containsErrors(component, helper, required, selectedId)){
                component.set("v.isValid", false);
            }
        },

        /**** Validate value ****/
        validateSelect: function(component, helper, selectedId) {
            var required = component.get("v.required");
            component.set("v.isValid", true);

            if(helper.containsErrors(component, helper, required, selectedId)){
                component.set("v.isValid", false);
            }else if(!required && (typeof selectedId === 'undefined' || selectedId === null || selectedId === '')){
                component.set("v.selectedLbl", ' - ');
            }else{
                component.set("v.selectedLbl", helper.getLabel2Id(component, selectedId));
            }
        },

        /**** Check for errors and set message ****/
        containsErrors : function(component, helper, required, selectedId){
            var btn = component.find("btn");
            component.set("v.errorMsg", "");
            $A.util.removeClass(btn, 'error');

            if(required && (typeof selectedId === 'undefined' || selectedId === null || selectedId === '')){
                component.set("v.errorMsg", "Select a value!");
                $A.util.addClass(btn, 'error');
                return true;
            }else if(required && !helper.isValueInOptions(component)){
                component.set("v.errorMsg", "Invalid value: " + selectedId);
                $A.util.addClass(btn, 'error');
                return true;
            }else{
                return false;
            }
        },

        /**** Check if value is one of selectoptions ****/
        isValueInOptions : function(component){
            var options = component.get("v.options");
            var value = component.get("v.selectedId");

            for(var i=0; i<options.length; i+=1){
                if(value === options[i].text){
                    return true;
                }
            }

            return false;
        },

        /**** Get label to value from options ****/
        getLabel2Id : function(component, sourceId){
            var options = component.get("v.options");
            for(var i=0; i<options.length; i+=1){
                if(options[i].text === sourceId){
                    return options[i].label;
                }
            }
            return null;
        },

        /**** Switch between showing or hiding list of selectoptions ****/
        toggleList : function(component, event){
            var picklist = component.find("picklist");
            $A.util.toggleClass(picklist, 'slds-is-open');
        }
})