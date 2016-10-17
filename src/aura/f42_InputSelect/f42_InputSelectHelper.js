({
    validateValue : function(component){
        var inputSelect = component.find("inputSelect"),
        errors = [],
        value = component.find("inputSelect").get("v.value"),
        options = component.get("v.options"),
        required = component.get("v.required"),
        valueInit = component.get("v.value");

        inputSelect.set("v.errors", null);
        component.set("v.isValid", true);

        if(!this.isValueInOptions(valueInit, options) && typeof valueInit !== 'undefined' && valueInit !== null){ // initial value was undefined => just check for required
            errors.push({"message" : "Invalid value: "+ valueInit});
            component.set("v.isValid", false);
        }

        if(this.isValueNullButRequired(valueInit, required)){
            errors.push({"message" : "Select a value"});
            component.set("v.isValid", false);
        }

        inputSelect.set("v.errors", errors);
    },

    isValueInOptions : function(value, options){
        if(value === ''){
            return true;
        }

        for(var i in options){
            if(value === options[i].text){
                return true;
            }
        }

        return false;
    },

    isValueNullButRequired : function(value, required){
        if(required && (value === '' || typeof value === 'undefined')){
            return true;
        }

        return false;
    }
})