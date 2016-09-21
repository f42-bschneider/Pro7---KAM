({
	validateSelect: function(component, value) {
		var required = component.get("v.required");
		component.set("v.isValid", false);
		component.find("select2").set("v.errors", null);

		if(required && (value === '' || typeof value === 'undefined')){
			component.find("select2").set("v.errors", [{message:"Select a value"}]);
		}else{
			component.set("v.isValid", true);
			component.set("v.value", value);
		}
	},

	changeValue : function(component, helper){
		var value 		= component.get("v.value");
		var select2 	= component.find("select2").getElement();
		var required 	= component.get("v.required");

		component.set("v.isValid", true);
		component.find("select2").set("v.errors", null);

		if(required && (typeof value == 'undefined' || value === '')){
			component.set("v.isValid", false);
			component.find("select2").set("v.errors", [{message:"Select a value"}]);
			jQuery(select2).val("").trigger("change");
		}else if(required && !helper.isValueInOptions(component)){
			component.find("select2").set("v.errors", [{message:"Invalid value "+ value}]);
			component.set("v.isValid", false);
		}else{
			jQuery(select2).val(value).trigger("change");

		}
	},

	checkRequired : function(component, helper){
		var required 	= component.get("v.required");
		var value 	= component.get("v.value");

		component.set("v.isValid", true);
		component.find("select2").set("v.errors", null);

		if(required && (value === '' || typeof value === 'undefined')){
			component.find("select2").set("v.errors", [{message:"Select a value"}]);
			component.set("v.isValid", false);
		}else if(required && !helper.isValueInOptions(component)){
			component.find("select2").set("v.errors", [{message:"Select a value"}]);
			component.set("v.isValid", false);
		}
	},

	isValueInOptions : function(component){
		var options = component.get("v.options");
		var value = component.get("v.value");

		for(var i in options){
			if(value === options[i].text){
				return true;
			}
		}

		return false;
	}
})