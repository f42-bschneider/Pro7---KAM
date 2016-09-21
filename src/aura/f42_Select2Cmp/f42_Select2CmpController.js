({
	scriptsLoaded : function(component, event, helper){

		var select2 = component.find("select2").getElement();
		jQuery(select2).select2();

		//BS Changed 18-05-16
		//if(!component.get("v.isInit")){
			helper.checkRequired(component, helper);
		//}

		var value = component.get("v.value");

		jQuery(select2).select2().on("select2-selecting",
			function(e) {
				e.stopPropagation();
          				helper.validateSelect(component, e.val);
          				component.getEvent("onChange").setParams({"value": value}).fire();
        		});

		//var value = component.get("v.value");

		if(typeof value !== 'undefined'){
			//jQuery(select2).val(value).trigger("change");
		}
	},

	onInit : function(component, event, helper){

		/*component.set("v.isInit", true);

		var value 		= component.get("v.value");
		var select2 	= component.find("select2").getElement();
		var required 	= component.get("v.required");

		console.log(component.find("select2").getElement());

		if(required && (typeof value == 'undefined' || value === '')){
			component.find("select2").set("v.errors", [{message:"Select a value"}]);
		}
		else if(required && !helper.isValueInOptions(component)){
			component.find("select2").set("v.errors", [{message:"Invalid value "+ value}]);
		}*/
	},

	doChangeValue : function(component, event, helper){
		helper.changeValue(component, helper);
	},

	doChangeRequired : function(component, event, helper){
		helper.checkRequired(component, helper);
	}
})