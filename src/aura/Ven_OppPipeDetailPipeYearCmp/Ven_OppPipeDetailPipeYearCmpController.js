({
	doSetSum: function(component, event, helper) {
		helper.setSum(component);
	},

	doHandleOppPipeDetailOppEvent : function(component, event, helper){
		var clientLikelihood = event.getParam("clientLikelihood");

		if(clientLikelihood != null){
			component.set("v.clientLikelihood", clientLikelihood);
			var totalNetPot = helper.calcTotalNetPot(component, helper);
			component.set("v.totalNetPot", totalNetPot);
		}
	},

	doHandleAmountChange : function(component, event, helper){
		var totalNetPot = helper.calcTotalNetPot(component, helper);
		component.set("v.totalNetPot", totalNetPot);
	},

	doHandleEffYieldChange : function(component, event, helper){
		var totalNetPot = helper.calcTotalNetPot(component, helper);
		component.set("v.totalNetPot", totalNetPot);
	}
})