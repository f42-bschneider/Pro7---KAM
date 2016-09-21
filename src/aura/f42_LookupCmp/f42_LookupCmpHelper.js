({
	searchLookups : function(component, helper) {
		var searchTerm 		= component.get("v.searchTerm");

		if(searchTerm.length >= 2){
			var labelApiName 	= component.get("v.labelApiName");
			var objType 		= component.get("v.objType");

			var action 			= component.get("c.getLookups");

			action.setParams({"objType" : objType, "searchTerm" : searchTerm, "labelApiName" : labelApiName});

			action.setCallback(this, function(a){
				if(a.getState() == 'SUCCESS'){
					if(a.getReturnValue().length > 0){
						component.set("v.lookupObjs", a.getReturnValue());
					}
					else {
						toastr.info("No results");
						component.set("v.lookupObjs", []);
					}					
				}
				else {
					toastr.info("Something went wrong. Try again or contact your administrator");
				}
			});

			$A.enqueueAction(action);
		}
		else {
			toastr.info("At least two letters required");
		}		
	},

	selectObj : function(component, event){
		var objId 		= event.target.dataset.objid;
		var objLabel 	= event.target.dataset.objlabel;

		component.set("v.objId", objId);
		component.set("v.objLabel", objLabel);

		var modal 	= component.find("lookupModal").getElement();
        jQuery(modal).modal('hide');
	},

	handleChange : function(component){
		var objId 		= component.get("v.objId");
		var objOutput 	= component.find("objOutput");
		var required 	= component.get("v.required");

		component.set("v.isValid", true);

		if(required && (typeof objId == 'undefined' || objId === '')){
			component.set("v.isValid", false);
			component.set("v.objLabel", "");
		}
	}
})