({
	doInit : function(component, event, helper){
		helper.getOppPipeData(component, helper);
		component.set("v.isPipeBtnSelected", true);
		component.set("v.isPrePipeBtnSelected", false);
		component.set("v.summaryItemsChanged", false);

		$A.util.removeClass(component.find("pipeBtn"), "btn-default");
		$A.util.addClass(component.find("pipeBtn"), "btn-primary");
		$A.util.addClass(component.find("prePipeBtn"), "btn-default");
		$A.util.removeClass(component.find("prePipeBtn"), "btn-primary");
	},

	doInitScripts : function(component, event, helper){
		helper.initToastr();
	},

	doHandleOppPipeSummaryEvt : function(component, event, helper){
		helper.doDetail(component, event, helper);
	},

	doHome : function(component, event, helper){
		window.location = "/home/home.jsp";
	},

	doExport : function(component, event, helper){
		helper.export2Csv(component, helper);
	},

	doNewOpp : function(component, event, helper){
		helper.newOpp(component, helper);
	},

	doSave : function(component, event, helper){
		helper.save(component, helper);
	},

	doCancel : function(component, event, helper){
		helper.cancel(component);
	},

	doDelete : function(component, event, helper){
		helper.discard(component);
	},

	onPipeBtnClick : function(component, event, helper){
		component.set("v.renderSpinner", true);
		helper.setPipeBtns(component, true, false);

		var oppPipeData = component.get("v.oppPipeData");
		helper.setSummaryItemsVisibility(oppPipeData, null, true, false);
		component.set("v.oppPipeData", oppPipeData);
		component.set("v.summaryItemsChanged", false);
		component.set("v.renderSpinner", false);
	},

	onPrePipeBtnClick : function(component, event, helper){
		component.set("v.renderSpinner", true);
		helper.setPipeBtns(component, false, true);

		var oppPipeData = component.get("v.oppPipeData");
		helper.setSummaryItemsVisibility(oppPipeData, null, false, true);
		component.set("v.oppPipeData", oppPipeData);
		component.set("v.summaryItemsChanged", false);
		component.set("v.renderSpinner", false);
	},

	onSummaryItemChange : function(component, event, helper){
		component.set("v.summaryItemsChanged", true);

		var changedOppIds = component.get("v.changedOppIds"),
		changedOppId = event.getParam("oppId");

		changedOppIds[changedOppId] = changedOppId;
		component.set("v.changedOppIds", changedOppIds);
	},

	onTableSave : function(component, event, helper){
		helper.saveOpps(component);
	},

	onTableCancel : function(component, event, helper){
		component.set("v.renderSpinner", true);

		var summaryItems = component.get("v.summaryItemsCopy");

		for(var i in summaryItems){
			helper.setSummaryItemsVisibility(null, summaryItems[i], component.get("v.isPipeBtnSelected"), component.get("v.isPrePipeBtnSelected"));
		}

		component.set("v.oppPipeData.summaryItems", JSON.parse(JSON.stringify(summaryItems)));
		component.set("v.summaryItemsChanged", false);
		component.set("v.changedOppIds", []);

		component.set("v.renderSpinner", false);
	}
})