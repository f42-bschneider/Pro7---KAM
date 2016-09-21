({
	initScripts: function(component) {
		var toggleBtn = component.find("toggleBtn").getElement();
		jQuery(toggleBtn).bootstrapToggle();
	},

	handleValueChange : function(component){
		var toggleBtn 	= component.find("toggleBtn").getElement();
		var value 	= component.get("v.value");

		if(value){
			jQuery(toggleBtn).bootstrapToggle('on');
		} else {
			jQuery(toggleBtn).bootstrapToggle('off');
		}
	}
})