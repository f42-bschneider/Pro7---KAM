({
	doInitScripts : function(component, event, helper){
		toastr.options = {
			"closeButton": true,
			"debug": false,
			"newestOnTop": false,
			"progressBar": true,
			"positionClass": "toast-bottom-right",
			"preventDuplicates": false,
			"onclick": null,
			"showDuration": "300",
			"hideDuration": "1000",
			"timeOut": "4000",
			"extendedTimeOut": "1000",
			"showEasing": "swing",
			"hideEasing": "linear",
			"showMethod": "fadeIn",
			"hideMethod": "fadeOut"
		}
	},

	doSearchLookups : function(component, event, helper) {
		helper.searchLookups(component, helper);
	},

	doOpenModal : function(component, event, helper){
		var modal 	= component.find("lookupModal").getElement();
        jQuery(modal).modal();
	},

	doSelectObj : function(component, event, helper){
		helper.selectObj(component, event);
	},

	doHandleChange : function(component, event, helper){
		helper.handleChange(component);
	},
})