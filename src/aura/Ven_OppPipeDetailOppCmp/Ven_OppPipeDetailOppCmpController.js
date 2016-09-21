({
	doHandleChange : function(component, event, helper){
		helper.checkValid(component);
	},

	doHandleStatusChange : function(component, event, helper){
		helper.handleStatusChange(component);
	},

	doHandleCommentChange : function(component, event, helper){
		component.set("v.opp.comment", event.srcElement.value);
	},

	doHandleCountryChange : function(component, event, helper){
		helper.handleCountryChange(component);
	},

	doHandleOwnerChange : function(component, event, helper){
		helper.handleOwnerChange(component);
	},

	doHandleNameChange : function(component, event, helper){
		helper.handleNameChange(component);
	},

	doHandleCurrencyChange : function(component, event, helper){
		helper.handleCurrencyChange(component);
	},

	doHandleClientLikelihoodChange : function(component, event, helper){
		helper.handleClientLikelihoodChange(component);
	},
})