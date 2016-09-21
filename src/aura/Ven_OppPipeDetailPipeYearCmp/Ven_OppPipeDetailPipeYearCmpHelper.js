({
	setSum : function(component) {
		var opms 	= component.get("v.oppPipeYear.oppPipeMonths");
		var sum 	= 0
		var isValid = true;

		for(var i in opms){
			if(opms[i].isValid){
				sum += parseInt(opms[i].Ven_Amount__c);
			}
			else {
				isValid = false;
			}
		}

		if(isValid){
			component.set("{!v.oppPipeYear.totalAmount}", sum);
		}

		component.set("v.isValid", isValid);
	},

	/* (opp.Ven_TotalGmvCurrentYear__c * (opp.Ven_EffectiveYield__c/100) * (somLikelihood/100) * (opp.Probability/100)).round(System.roundingMode.CEILING); */
	calcTotalNetPot : function(component, helper){
		var clientLikelihood 	= component.get("v.clientLikelihood"),
		totalAmount 		= component.get("v.oppPipeYear.totalAmount"),
		effYield 			= component.get("v.effYield"),
		somLikelihood 		= helper.getSomLikelihood(component);


		if($A.util.isUndefinedOrNull(totalAmount) || 
			$A.util.isUndefinedOrNull(effYield) || 
			$A.util.isUndefinedOrNull(somLikelihood) ||
			$A.util.isUndefinedOrNull(clientLikelihood)){
			return 0;
		}

		return Math.ceil(totalAmount * (effYield/100) * (somLikelihood/100) * (clientLikelihood/100));;
	},

	getSomLikelihood : function(component){
		var effYield 		= component.get("v.effYield");
		var somLikelihoods 	= component.get("v.somLikelihoods");

		for(var i in somLikelihoods){
			var slh = somLikelihoods[i];

			if(effYield >= slh.Ven_Min__c && effYield <= slh.Ven_Max__c){
				var month = new Date().getMonth()+1;

				if(month == 1){
					return slh.Ven_Jan__c;
				}
				else if(month == 2){
					return slh.Ven_Feb__c;
				}
				else if(month == 3){
					return slh.Ven_Mar__c;
				}
				else if(month == 4){
					return slh.Ven_Apr__c;
				}
				else if(month == 5){
					return slh.Ven_May__c;
				}
				else if(month == 6){
					return slh.Ven_Jun__c;
				}
				else if(month == 7){
					return slh.Ven_Jul__c;
				}
				else if(month == 8){
					return slh.Ven_Aug__c;
				}
				else if(month == 9){
					return slh.Ven_Sep__c;
				}
				else if(month == 10){
					return slh.Ven_Oct__c;
				}
				else if(month == 11){
					return slh.Ven_Nov__c;
				}
				else if(month == 12){
					return slh.Ven_Dec__c;
				}
			}
		}

		return null;
	}
})