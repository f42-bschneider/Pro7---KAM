({
	doCheckValid : function(component, event, helper){
		helper.checkValid(component);
	},

	doSetEffYield : function(component, event, helper){
		helper.setEffYield(component, helper);
	},

	doHandleOppPipeDetailOppEvent : function(component, event, helper){
		var currency = event.getParam("currency");

		if(currency != null){
			component.set("v.currencyy", currency);
		}
	},
})