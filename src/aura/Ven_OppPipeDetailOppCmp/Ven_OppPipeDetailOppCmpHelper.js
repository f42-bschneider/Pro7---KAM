({
	checkValid: function(component) {
		var verticalValid 			= component.get("v.verticalValid");
		var oppNameValid 			= component.get("v.oppNameValid");
		var subCatValid 			= component.get("v.subCatValid");
		var dealTypeValid 			= component.get("v.dealTypeValid");
		var dealCatValid 			= component.get("v.dealCatValid");
		var statusValid 			= component.get("v.statusValid");
		var reasonValid 			= component.get("v.reasonValid");
		var im1Valid 				= component.get("v.im1Valid");
		var countryValid 			= component.get("v.countryValid");
		var currencyValid 			= component.get("v.currencyValid");
		var clientLikelihoodValid 	= component.get("v.clientLikelihoodValid");
		var accValid 				= component.get("v.accValid");
		var isLostCancelled 		= component.get("v.isLostCancelled");
		var targetPl 				= component.get("v.targetPlValid");

		var isValid;

		if(isLostCancelled){
			isValid = 	verticalValid && 
						subCatValid && 
						dealTypeValid && 
						dealCatValid && 
						statusValid && 
						reasonValid &&  
						accValid &&
						im1Valid && 
						countryValid && 
						currencyValid && 
						clientLikelihoodValid &&
						targetPl &&
						oppNameValid
						? true : false;
		} else {			
			isValid = 	verticalValid && 
						subCatValid && 
						dealTypeValid && 
						dealCatValid && 
						statusValid && 
						accValid &&
						im1Valid && 
						countryValid && 
						currencyValid && 
						clientLikelihoodValid &&
						targetPl &&
						oppNameValid
						? true : false;
		}		

		component.set("v.isValid", isValid); 
	},

	handleStatusChange : function(component){
		var status = component.get("v.opp.StageName"),
		setProbability= component.get("v.setProbability"),
		probability;

		component.set("v.isLostCancelled", false);

		if(status == 'Closed Lost' || status == 'Cancelled' || status == 'Storniert'){
			component.set("v.isLostCancelled", true);
		}

		if(setProbability){
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

			component.set("v.opp.Probability", probability);
		}

		component.set("v.setProbability", true);

	},

	handleCountryChange : function(component) {
		var countryObj 	= component.get("v.countryInternational");
		var country 	= component.get("v.opp.Ven_Country__c");

		if(countryObj[country]){
			component.set("v.opp.Ven_International__c", true);
		} else {
			component.set("v.opp.Ven_International__c", false);
		}
	},

	handleOwnerChange : function(component){
		var im1 		= component.get("v.opp.OwnerId");
		var userRoles 	= component.get("v.userRoles");
		var austria 	= component.get("v.austriaRole");
		var switzerland	= component.get("v.switzerlandRole");

		if(userRoles[im1] == austria){
			component.set("v.opp.Ven_TargetPL__c", "Austria");
		}
		else if(userRoles[im1] == switzerland){
			component.set("v.opp.Ven_TargetPL__c", "Switzerland");
		}
		else {
			component.set("v.opp.Ven_TargetPL__c", "Germany");
		}
	},

	handleNameChange : function(component){
		var oppName = component.find("oppName");
		var isValid = true;

		if(!oppName.get("v.value") || 0 === oppName.get("v.value").length){
			oppName.set("v.errors", [{message:"Complete this field"}]);
			isValid = false;
		}
		else {
			oppName.set("v.errors", null);
		}

		component.set("v.oppNameValid", isValid);
	},

	handleCurrencyChange : function(component){
		
		var params = {
			"currency" 			: component.get("v.opp.CurrencyIsoCode"),
			"clientLikelihood" 	: null
		}

		$A.get("e.c:Ven_OppPipeDetailOppEvent").setParams(params).fire();
	},

	handleClientLikelihoodChange : function(component){
		
		var params = {
			"currency" 			: null,
			"clientLikelihood" 	: component.get("v.opp.Probability")
		}

		$A.get("e.c:Ven_OppPipeDetailOppEvent").setParams(params).fire();
	}
})