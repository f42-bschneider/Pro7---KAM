({
	initTableSorter : function(component){
		var oppPipeTable = component.find("oppPipeTable").getElement();
		jQuery.tablesorter.defaults.resort = false;
		jQuery(oppPipeTable).tablesorter({
			headers : {
				0 : {sorter : false}
			}
		});
	},

	initFixedHeader : function(component){
		var oppPipeTable = component.find("oppPipeTable").getElement();
		jQuery(oppPipeTable).tableHeadFixer();
	},

	updateTableSorter : function(component){
        if(typeof jQuery !== 'undefined'){
			var oppPipeTable = component.find("oppPipeTable").getElement();
			jQuery(oppPipeTable).trigger("update");
		}
	},

	sendOppPipeSummaryEvt: function(component, event) {

		var summaryItems = component.get("v.summaryItems"),
		oppId = event.target.dataset.id,
		opp;

		for(var i in summaryItems){
			if(summaryItems[i].Id == oppId){
				opp = summaryItems[i];
				break;
			}
		}

		opp.sobjectType = "Opportunity";

		component.getEvent("summaryItemClick").setParams({"opp":opp}).fire();
	},

	handleTableHeaderClick : function(component, event, helper){
        var oppPipeTable 	= component.find("oppPipeTable").getElement();
		var element 		= event.srcElement;

		var isAsc;
		if(jQuery(event.srcElement).find("i").hasClass("fa-sort-asc")){
			isAsc = false;
		} else {
			isAsc = true;
		}

		jQuery(oppPipeTable).find("i>.fa").addClass("fa-sort");
		jQuery(oppPipeTable).find("i").removeClass("fa-sort-asc");
		jQuery(oppPipeTable).find("i").removeClass("fa-sort-desc");

		if(isAsc){
			jQuery(event.srcElement).find("i").addClass("fa-sort-asc");
		} else {
			jQuery(event.srcElement).find("i").addClass("fa-sort-desc");
		}
	},

	handleStatusChange : function(component, oppId){

		var summaryItems = component.get("v.summaryItems"),
		index = 0;

		//Get specific Opportunity element
		for(var i in summaryItems){
			if(summaryItems[i].Id == oppId){
				index = i;
				break;
			}
		}

		var status = summaryItems[i].StageName,
		probability;

		// Lost, Cancelled
		if(status == 'Closed Lost' || status == 'Cancelled' || status == 'Storniert'){
			probability = 0;
		}
		// Potential
		else if(status == 'Potential' || status == 'Potenzial'){
			probability = 0;
		}
		// Contacted
		else if(status == 'Contacted' || status == 'Erstgespräch Bedarf/Bestand'){
			probability = 5;
		}
		// Contacted
		else if(status == 'In Briefing' || status == 'In Briefing/Erstgespräch'){
			probability = 10;
		}
		// M2N
		else if(status == 'M2N (Mandate to Negotiate)' || status == 'Rabatt freigegeben'){
			probability = 15;
		}
		// Deal approval
		else if(status == 'Deal Approval' || status == 'Deal approval'){
			probability = 75;
		}
		// Parked
		else if(status == 'Parked'){
			probability = 0;
		}
		// Parked
		else if(status == 'Closed Won'){
			probability = 100;
		}
		else {
			probability = 0;
		}

		summaryItems[index].Probability = probability;
		component.set("v.itemChangedStage", true);
		component.set("v.summaryItems["+index+"]", summaryItems[index]);
	}
})