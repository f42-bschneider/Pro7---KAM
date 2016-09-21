({
	getOppPipeData : function(component, helper){
		component.set("v.renderSpinner", true);

		var action = component.get("c.getOppPipeData");

		action.setCallback(this, function(a){
			if(a.getState() == 'SUCCESS'){
				var result = a.getReturnValue();
				console.log(result);

				if(result.userRole == result.imRoleId){
					component.set("v.isIm", true);
				}
				else if(result.userRole == result.scoutRoleId){
					component.set("v.isScout", true);
				}
				else if(result.userRole == result.analystRoleId){
					component.set("v.isAnalyst", true);
				}

				this.setSummaryItemsVisibility(result, null, true, false);

				component.set("v.oppPipeData", result);
				component.set("v.showButtons", true);
				component.set("v.renderSpinner", false);
				component.set("v.summaryItemsCopy", JSON.parse(JSON.stringify(result.summaryItems)));
			} else {
				//toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
				console.log("error");
				console.log(a.getError())
				component.set("v.renderSpinner", false);
			}
		});

		$A.enqueueAction(action);
	},

	setSummaryItemsVisibility : function(oppPipeData, opp, pipeVisibility, prePipeVisibility){

		if(oppPipeData != null){
			for(var i in oppPipeData.summaryItems){
				var item = oppPipeData.summaryItems[i];

				if(item.StageName == 'In Briefing' || item.StageName == 'M2N (Mandate to Negotiate)' || item.StageName == 'Deal approval'){
					oppPipeData.summaryItems[i].showItem = pipeVisibility;
				}
				else if(item.StageName == 'Potential' || item.StageName == 'Contacted'){
					oppPipeData.summaryItems[i].showItem = prePipeVisibility;
				}
				else {
					oppPipeData.summaryItems[i].showItem = false;
				}
			}
		}
		else if(opp != null){
			if(opp.StageName == 'In Briefing' || opp.StageName == 'M2N (Mandate to Negotiate)' || opp.StageName == 'Deal approval'){
				opp.showItem = pipeVisibility;
			}
			else if(opp.StageName == 'Potential' || opp.StageName == 'Contacted'){
				opp.showItem = prePipeVisibility;
			}
			else {
				opp.showItem = true;
			}
		}
	},

	initToastr : function(){
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

	newOpp : function(component, helper){
		var oppPipeDetail = helper.createNewOppPipeDetail();

		var oppPipeData = component.get("v.oppPipeData");

		if(oppPipeData.userRole == oppPipeData.imRoleId){
			oppPipeDetail.opp.OwnerId = oppPipeData.userId;
		}
		else if(oppPipeData.userRole == oppPipeData.scoutRoleId){
			oppPipeDetail.opp.Ven_Scount__c = oppPipeData.userId;
		}
		else if(oppPipeData.userRole == oppPipeData.analystRoleId){
			oppPipeDetail.opp.Ven_Analyst__c = oppPipeData.userId;
		}

		component.set("v.oppPipeDetail", oppPipeDetail);
		component.set("v.isSummary", false);
		component.set("v.isNewOpp", true);
	},

	createNewOppPipeDetail : function(){
		var oppPipeDetail 										= {};
		oppPipeDetail.opp 										= {};
		oppPipeDetail.opp.Id 									= null;
		oppPipeDetail.opp.Name 									= '';
		/*oppPipeDetail.opp.netPotCurYear 		= 0;
		oppPipeDetail.opp.netPotNextYear 		= 0;
		oppPipeDetail.opp.estCashCurrentYear 	= 0;
		oppPipeDetail.opp.estPrapCurrentYear 	= 0;
		oppPipeDetail.opp.cashInvest 			= 0;*/
		oppPipeDetail.opp.Ven_EstimateCashYieldCurrentYear__c 	= 0;
		oppPipeDetail.opp.Ven_EstimatePrapYieldCurrentYear__c 	= 0;
		oppPipeDetail.opp.Ven_CashInvest__c 					= 0;
		oppPipeDetail.opp.Ven_NetPotentialCurrentYear__c 		= 0;
		oppPipeDetail.opp.Ven_NetPotentialNextYear__c 			= 0;

		var currentYear = new Date().getFullYear();

		oppPipeDetail.currentYear 				= {};
		oppPipeDetail.currentYear.totalAmount 	= 0;
		oppPipeDetail.currentYear.totalCash 	= 0;
		oppPipeDetail.currentYear.year 			= currentYear;

		var curMonths = [];
		for(i = 1; i <= 12; i++){
			//curMonths.push({"amount":0, "cash":0, "month":i, "year":currentYear});
			curMonths.push({
				"Id" 				: null,
				"Ven_Amount__c"		: 0,
				"Ven_Cash__c"		: 0,
				"Ven_Month__c"		: i,
				"Ven_Year__c"		: currentYear,
				"isValid"			: true
			});
		}

		oppPipeDetail.currentYear.oppPipeMonths = curMonths;

		oppPipeDetail.nextYear 				= {};
		oppPipeDetail.nextYear.totalAmount 	= 0;
		oppPipeDetail.nextYear.totalCash 	= 0;
		oppPipeDetail.nextYear.year 		= currentYear+1;

		var nextMonths = [];
		for(i = 1; i <= 12; i++){
			//nextMonths.push({"amount":0, "cash":0, "month":i, "year":currentYear+1});
			nextMonths.push({
				"Id" 				: null,
				"Ven_Amount__c"		: 0,
				"Ven_Cash__c"		: 0,
				"Ven_Month__c"		: i,
				"Ven_Year__c"		: currentYear+1,
				"isValid"			: true
			});
		}

		oppPipeDetail.nextYear.oppPipeMonths = nextMonths;

		return oppPipeDetail;
	},

	doDetail : function(component, event, helper){
		component.set("v.renderSpinner", true);

		var opp = event.getParam("opp"),
		getOppPipeDetail = component.get("c.getOppPipeDetail");

		getOppPipeDetail.setParams({"opp": opp});

		getOppPipeDetail.setCallback(this, function(resp){
			if(resp.getState() == 'SUCCESS'){

				component.set("v.setProbability", false);
				component.set("v.oppPipeDetail", helper.fillOpp(resp.getReturnValue()));
				component.set("v.isSummary", false);
				component.set("v.isNewOpp", false);
				component.set("v.renderSpinner", false);
			}
			else {
				component.set("v.renderSpinner", false);
				console.log("error");
			}
		});

		$A.enqueueAction(getOppPipeDetail);
	},

	setPipeBtns : function(component, pipeBtnValue, prePipeBtnValue){

		if(pipeBtnValue){
			$A.util.removeClass(component.find("pipeBtn"), "btn-default");
			$A.util.addClass(component.find("pipeBtn"), "btn-primary");
			$A.util.addClass(component.find("prePipeBtn"), "btn-default");
			$A.util.removeClass(component.find("prePipeBtn"), "btn-primary");
		}
		else {
			$A.util.addClass(component.find("pipeBtn"), "btn-default");
			$A.util.removeClass(component.find("pipeBtn"), "btn-primary");
			$A.util.removeClass(component.find("prePipeBtn"), "btn-default");
			$A.util.addClass(component.find("prePipeBtn"), "btn-primary");
		}

		component.set("v.isPipeBtnSelected", pipeBtnValue);
		component.set("v.isPrePipeBtnSelected", prePipeBtnValue);
	},

	fillOpp : function(opd){
		var oppPipeDetail 										= {};
		oppPipeDetail.opp 										= {};
		oppPipeDetail.opp.Ven_EstimateCashYieldCurrentYear__c 	= 0;
		oppPipeDetail.opp.Ven_EstimatePrapYieldCurrentYear__c 	= 0;
		oppPipeDetail.opp.Ven_CashInvest__c 					= 0;
		oppPipeDetail.opp.Ven_NetPotentialCurrentYear__c 		= 0;
		oppPipeDetail.opp.Ven_NetPotentialNextYear__c 			= 0;
		oppPipeDetail.opp.StageName 							= '';
		oppPipeDetail.opp.Probability 							= 0;
		oppPipeDetail.opp.Ven_Stage_Finished_Subcategory__c 	= '';
		oppPipeDetail.opp.Ven_Comment__c 						= '';
		oppPipeDetail.opp.Ven_Vertical__c 						= '';
		oppPipeDetail.opp.Ven_SubCategory__c 					= '';
		oppPipeDetail.opp.Ven_DealType__c 						= '';
		oppPipeDetail.opp.Ven_DealCategory__c 					= '';
		oppPipeDetail.opp.Ven_Country__c 						= '';
		oppPipeDetail.opp.CurrencyIsoCode 						= '';
		oppPipeDetail.opp.Ven_TargetPL__c						= '';
		oppPipeDetail.opp.OwnerId 								= '';
		oppPipeDetail.opp.Ven_Im2__c 							= '';
		oppPipeDetail.opp.Ven_Scount__c 						= '';
		oppPipeDetail.opp.Ven_Analyst__c 						= '';

		oppPipeDetail = opd;

		if($A.util.isUndefinedOrNull(oppPipeDetail.opp.Ven_EstimatePrapYieldCurrentYear__c)){
			oppPipeDetail.opp.Ven_EstimatePrapYieldCurrentYear__c = 0;
		}

		if($A.util.isUndefinedOrNull(oppPipeDetail.opp.Ven_EstimateCashYieldCurrentYear__c) ){
			oppPipeDetail.opp.Ven_EstimateCashYieldCurrentYear__c = 0;
		}

		if($A.util.isUndefinedOrNull(oppPipeDetail.opp.Ven_CashInvest__c)){
			oppPipeDetail.opp.Ven_CashInvest__c = 0;
		}

		// handle opps that were not created by the opp pipe app
		var currentYear = new Date().getFullYear();

		if($A.util.isUndefinedOrNull(oppPipeDetail.currentYear.oppPipeMonths[0])){
			var curMonths = [];

			for(i = 1; i <= 12; i++){
				curMonths.push({	"Ven_Amount__c"		: 0,
									"Ven_Cash__c"		: 0,
									"Ven_Month__c"		: i,
									"Ven_Year__c"		: currentYear,
									"isValid"			: true});
			}

			oppPipeDetail.currentYear.oppPipeMonths = curMonths;
		}

		if($A.util.isUndefinedOrNull(oppPipeDetail.nextYear.oppPipeMonths[0])){
			var nextMonths 	= [];

			for(i = 1; i <= 12; i++){
				nextMonths.push({	"Ven_Amount__c"		: 0,
									"Ven_Cash__c"		: 0,
									"Ven_Month__c"		: i,
									"Ven_Year__c"		: (currentYear+1),
									"isValid"			: true});
			}

			oppPipeDetail.nextYear.oppPipeMonths = nextMonths;
		}

		return oppPipeDetail;
	},

	saveOpps : function(component, helper){
		component.set("v.renderSpinner", true);

		var saveOpps = component.get("c.saveOpps"),
		opps = this.getOppsByIds(component);

		saveOpps.setParams({"opps" : opps});

		saveOpps.setCallback(this, function(resp){
			if(resp.getState() == 'SUCCESS'){
				var changedOpps = resp.getReturnValue(),
				summaryItems = component.get("v.oppPipeData.summaryItems");

				for(var i in changedOpps){
					this.setSummaryItemsVisibility(null, changedOpps[i], component.get("v.isPipeBtnSelected"), component.get("v.isPrePipeBtnSelected"));
					var index = this.getIndex(component, changedOpps[i].Id);
					summaryItems[index] = changedOpps[i];
				}

				component.set("v.oppPipeData.summaryItems", summaryItems);
				component.set("v.summaryItemsCopy", JSON.parse(JSON.stringify(component.get("v.oppPipeData.summaryItems"))));
				component.set("v.changedOppIds", []);
				component.set("v.summaryItemsChanged", false);
				component.set("v.renderSpinner", false);
				toastr.success($A.get("$Label.c.Ven_lbl_Saved"));
			}
			else {
				console.log("error");
				console.log(resp.getError());
				component.set("v.renderSpinner", false);
				toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
			}
		});

		$A.enqueueAction(saveOpps);
	},

	getIndex : function(component, oppId){
		var summaryItems = component.get("v.oppPipeData.summaryItems"),
		index = 0;

		for(var i in summaryItems){
			if(oppId == summaryItems[i].Id){
				index = i;
				break;
			}
		}

		return index;
	},

	getOppsByIds : function(component){
		var changedOppIds = component.get("v.changedOppIds"),
		oppIds = Object.keys(changedOppIds),
		opps = [],
		summaryItems = component.get("v.oppPipeData.summaryItems");

		for(var i in summaryItems){
			if(oppIds.indexOf(summaryItems[i].Id) != -1){
				summaryItems[i].sobjectType = "Opportunity";
				opps.push(summaryItems[i]);
			}
		}

		return opps;
	},

	save : function(component, helper){
		component.set("v.renderSpinner", true);

		var isOppValid 	= component.get("v.isOppValid");
		var isPipeValid = component.get("v.isPipeValid");

		if(isOppValid && isPipeValid){
			var oppPipeDetail 	= component.get("v.oppPipeDetail"),
			opp 				= oppPipeDetail.opp,
			oppPipes 			= helper.buildOppPipes(helper, oppPipeDetail),
			saveOppPipeDetail 	= component.get("c.saveOppPipeDetail");

			opp.sobjectType = 'Opportunity';

			delete opp.Account;

			saveOppPipeDetail.setParams({
				"opp" 			: opp,
				"oppPipes" 		: oppPipes
			});

			saveOppPipeDetail.setCallback(this, function(a){
				if(a.getState() == 'SUCCESS'){
					//component.set("v.oppPipeData", a.getReturnValue());
					helper.setOppInOppPipeData(a.getReturnValue(), component, false);
					component.set("v.isSummary", true);
					component.set("v.renderSpinner", false);
					component.set("v.summaryItemsChanged", false);
					toastr.success($A.get("$Label.c.Ven_lbl_Saved"));
				} else {
					toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
					component.set("v.renderSpinner", false);
				}
			});

			$A.enqueueAction(saveOppPipeDetail);
		}
		else {
			toastr.warning($A.get("$Label.c.Ven_lbl_CompleteFields"));
			component.set("v.renderSpinner", false);
		}
	},

	setOppInOppPipeData : function(opp, component, isDelete){
		var summaryItems = component.get("v.oppPipeData.summaryItems"),
		isNewOpp = true;

		this.setSummaryItemsVisibility(null, opp, component.get("v.isPipeBtnSelected"), component.get("v.isPrePipeBtnSelected"));

		for(var i in summaryItems){
			if(summaryItems[i].Id == opp.Id){
				if(isDelete){
					summaryItems.splice(i,1);
					break;
				}
				else {
					summaryItems[i] = opp;
					isNewOpp = false;
					break;
				}
			}
		}

		if(isNewOpp && !isDelete){
			summaryItems.unshift(opp);
		}

		component.set("v.oppPipeData.summaryItems", summaryItems);
	},

	buildOppPipes : function(helper, oppPipeDetail){
		var oppPipes = [];

		var currentYearMonths = oppPipeDetail.currentYear.oppPipeMonths;
		for(var i in currentYearMonths){
			var month = currentYearMonths[i];
			month.sobjectType = "Ven_OppPipeline__c";
			delete month.isValid;
			oppPipes.push(month);
			//oppPipes.push(helper.buildOppPipe(currentYearMonths[i], oppPipeDetail.oppFields));
		}

		var nextYearMonths = oppPipeDetail.nextYear.oppPipeMonths;
		for(var i in nextYearMonths){
			//oppPipes.push(helper.buildOppPipe(nextYearMonths[i], oppPipeDetail.oppFields));
			var month = nextYearMonths[i];
			delete month.isValid;
			month.sobjectType = "Ven_OppPipeline__c";
			oppPipes.push(month);
		}

		return oppPipes;
	},

	buildOpp : function(opp){

		return {
			"sobjectType" 							: "Opportunity",
			"Id" 									: opp.id,
			"Name"									: opp.oppName,
			"Ven_DealType__c"						: opp.dealType,
			"Ven_DealCategory__c" 					: opp.subIndustry,
			"Ven_SubCategory__c"					: opp.subCat,
			"Ven_CashInvest__c"						: opp.cashInvest,
			"Ven_International__c" 					: opp.international,
			"Ven_TargetPL__c"						: opp.targetPL,
			"StageName" 							: opp.oppStatus,
			"Ven_Stage_Finished_Subcategory__c"		: opp.reason,
			"Ven_Comment__c" 						: opp.comment,
			"Ven_Country__c" 						: opp.country,
			"Ven_EstimateCashYieldCurrentYear__c"	: opp.estCashCurrentYear,
			"Ven_EstimatePrapYieldCurrentYear__c" 	: opp.estPrapCurrentYear,
			"Ven_EffectiveYield__c" 				: opp.estEffectiveYield,
			"Probability" 							: opp.clientLikelihood,
			"Ven_Country__c" 						: opp.country,
			"Ven_Vertical__c"						: opp.vertical,
			"OwnerId" 								: opp.im1,
			"Ven_Im2__c"							: opp.im2,
			"Ven_Scout__c"							: opp.scout,
			"Ven_Analyst__c"						: opp.analyst,
			"CloseDate" 							: opp.closeDate,
			"AccountId" 							: opp.accId,
			"CurrencyIsoCode"						: opp.currencyy,
			"Ven_Ep__c" 							: opp.ep,
			"Ven_EpLight__c" 						: opp.epLight,
			"Ven_RevShare__c" 						: opp.revShare
		}
	},

	cancel : function(component){
		component.set("v.isSummary", true);
	},

	discard : function(component){
		component.set("v.renderSpinner", true);

		var opp 	= component.get("v.oppPipeDetail.opp");
		var action 	= component.get("c.deleteOppPipeDetail");

		action.setParams({ "oppId" : opp.Id });

		action.setCallback(this, function(a){
			if(a.getState() == 'SUCCESS'){
				this.setOppInOppPipeData(opp, component, true);
				//component.set("v.oppPipeData", a.getReturnValue());
				component.set("v.isSummary", true);
				component.set("v.renderSpinner", false);
			}
			else {
				toastr.error($A.get("$Label.c.Ven_lbl_ContactAdmin"));
				component.set("v.renderSpinner", false);
			}
		});

		$A.enqueueAction(action);
	},

	export2Csv : function(component, helper){
		//var rows 	= helper.buildJson(component, helper);
		component.set("v.renderSpinner", true);

		var rows 				= [],
		getExportData 			= component.get("c.getExportData");

		getExportData.setCallback(this, function(resp){
			if(resp.getState() == 'SUCCESS'){
				var exportData =  resp.getReturnValue();

				for(var i in exportData){
					var row 		= {};
					var opp 		= exportData[i].opp;
					var currentYear = exportData[i].currentYear;
					var nextYear 	= exportData[i].nextYear;

					helper.setOppJson(row, opp, component, helper);
					helper.setYearJson(row, currentYear);
					helper.setYearJson(row, nextYear);

					row["Net Potential "+ currentYear.year] 	= this.setOppValue(opp.Ven_NetPotentialCurrentYear__c, 0);
					row["Net Potential "+ nextYear.year] 		= this.setOppValue(opp.Ven_NetPotentialNextYear__c, 0);
					row["Total Net Potential"] 			= this.setOppValue(opp.Ven_TotalNetPotential__c, 0);

					rows.push(row);
				}

				var csv 	= helper.json2CsvConverter(rows, ";");

				if (navigator.userAgent.search("Trident") >= 0) {
					helper.createCsvIe(csv, "Export_Pipeline");
				}
				else {
					helper.createCsv(csv, "Export_Pipeline");
				}

				component.set("v.renderSpinner", false);
			}
			else {
				component.set("v.renderSpinner", false);
				console.log("error");
			}
		});

		$A.enqueueAction(getExportData);
	},

	setYearJson : function(row, year){
		var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

		if(year.oppPipeMonths.length != 0){
			for(var j in year.oppPipeMonths){
				var month = year.oppPipeMonths[j];
				row["GMV "+months[j]+" "+year.year] = this.setOppPipeMonthValue(month.Ven_Amount__c);
			}
		}
		else {
			for(var i in months){
				row["GMV "+months[i]+" "+year.year] = 0;
			}
		}

		row["Total GMV "+year.year] = year.totalAmount;
	},

	setOppPipeMonthValue : function(value){
		return $A.util.isUndefinedOrNull(value) ? 0 : value;
	},

	setOppJson : function(row, opp, component, helper){
		row["Id"] 						= helper.setOppValue(opp.Id,'');
		row["Account"] 					= helper.setOppValue(opp.Account.Name,'');
		row["Opportunity"] 				= helper.setOppValue(opp.Name,'');
		row["Vertical"] 				= helper.setOppValue(opp.Ven_Vertical__c,'');
		row["Sub Industry"]				= helper.setOppValue(opp.Ven_DealCategory__c,'');
		row["Deal Type"]				= helper.setOppValue(opp.Ven_DealType__c,'');
		row["Sub Category"] 			= helper.setOppValue(opp.Ven_SubCategory__c,'');
		row["Country"] 					= helper.getPicklistLabel(component.get("v.oppPipeData.selectOptLsts.countries"), opp.Ven_Country__c);
		row["International"] 			= helper.setOppValue(opp.Ven_International__c,'');
		row["Currency"] 				= helper.setOppValue(opp.CurrencyIsoCode,'');
		row["Target P/L"] 				= helper.setOppValue(opp.Ven_TargetPL__c,'');
		row["EP"] 						= helper.setOppValue(opp.Ven_Ep__c,'');
		row["EP light"] 				= helper.setOppValue(opp.Ven_EpLight__c,'');
		row["Rev Share"] 				= helper.setOppValue(opp.Ven_RevShare__c,'');
		row["IM1"] 						= helper.getPicklistLabel(component.get("v.oppPipeData.selectOptLsts.ims"), opp.OwnerId);
		row["IM2"] 						= helper.getPicklistLabel(component.get("v.oppPipeData.selectOptLsts.ims"), opp.Ven_Im2__c);
		row["Scout"]					= helper.getPicklistLabel(component.get("v.oppPipeData.selectOptLsts.scouts"), opp.Ven_Scout__c);
		row["Analyst"]					= helper.getPicklistLabel(component.get("v.oppPipeData.selectOptLsts.analysts"), opp.Ven_Analyst__c);
		row["Status"]					= helper.setOppValue(opp.StageName,'');
		row["Last Edited By"]			= helper.setOppValue(opp.Ven_LastModifiedBy__c,'');
		row["Last Edited On"]			= helper.setOppValue(opp.Ven_LastModifiedDate__c,'');
		row["Account Created Date"]		= helper.setOppValue(opp.Account.CreatedDate,'');
		row["Opportunity Created Date"]	= helper.setOppValue(opp.CreatedDate,'');
		row["Contacted"]				= helper.setOppValue(opp.Ven_Contacted__c,'');
		row["M2N"]						= helper.setOppValue(opp.Ven_m2n__c,'');
		row["Deal Approval"]			= helper.setOppValue(opp.Ven_DealApproval__c,'');
		row["Closed Won"]				= helper.setOppValue(opp.Ven_ClosedWon__c,'');
		row["Closed Lost"]				= helper.setOppValue(opp.Ven_ClosedLost__c,'');
		row["Parked"]					= helper.setOppValue(opp.Ven_Parked__c,'');
		row["Cancelled"]				= helper.setOppValue(opp.Ven_Cancellation__c,'');
		row["Reason"] 					= helper.setOppValue(opp.Ven_Reason__c,'');
		row["Comment"] 					= helper.setOppValue(opp.Ven_Comment__c,'');
		row["Client Likelihood"] 		= helper.setOppValue(opp.Probability,'');
		row["Cash Yield"] 				= helper.setOppValue(opp.Ven_EstimateCashYieldCurrentYear__c,'');
		row["pRAP Yield"] 				= helper.setOppValue(opp.Ven_EstimatePrapYieldCurrentYear__c,'');
		row["Effective Yield"] 			= helper.setOppValue(opp.Ven_EffectiveYield__c,'');
		row["Cash Invest"]				= helper.setOppValue(opp.Ven_CashInvest__c,'');
	},

	setOppValue : function(value, def){
		return $A.util.isUndefinedOrNull(value) ? def : value;
	},

	getPicklistLabel : function(options, value){
		for(var i in options){
			if(options[i].text == value){
				return options[i].label;
			}
		}

		return "";
	},



	json2CsvConverter : function(JSONData, Separator){
		//If JSONData is not an object then JSON.parse will parse the JSON string in an Object
	    var arrData = typeof JSONData != 'object' ? JSON.parse(JSONData) : JSONData;

	    var CSV = '';
	    //Set Report title in first row or line

	    //This condition will generate the Label/Header
	    var rowHead = "";

	    //This loop will extract the label from 1st index of on array
	    for (var index in arrData[0]) {

	        //Now convert each value to string and comma-seprated
	        rowHead += index + Separator;
	    }

	    rowHead = rowHead.slice(0, -1);

	    //append Label row with line break
	    CSV += rowHead + '\r\n';

	    //1st loop is to extract each row
	    for (var i = 0; i < arrData.length; i++) {
	        var row = "";

	        //2nd loop will extract each column and convert it in string comma-seprated
	        for (var index in arrData[i]) {
	            row += '"' + arrData[i][index] + '"'+Separator;
	        }

	        row.slice(0, row.length - 1);

	        //add a line break after each row
	        CSV += row + '\r\n';
	    }

	    if (CSV == '') {
	        console.log("Invalid data");
	        return;
	    }

	    return CSV;
	},

	createCsv : function(csv, fileName){
		//Initialize file format you want csv or xls
	    var uri = 'data:text/csv;charset=utf-8,' + escape(csv);

	    //this trick will generate a temp <a /> tag
	    var link = document.createElement("a");
	    link.href = uri;

	    //set the visibility hidden so it will not effect on your web-layout
	    link.style = "visibility:hidden";
	    link.download = fileName + ".csv";

	    //this part will append the anchor tag and remove it after automatic click
	    document.body.appendChild(link);
	    link.click();
	    document.body.removeChild(link);
	},

	createCsvIe : function(csv, fileName){
		var oWin = window.open();
	    oWin.document.write('sep=,\r\n' + csv);
	    oWin.document.close();
	    oWin.document.execCommand('SaveAs', true, fileName + ".csv");
	    oWin.close();
	}
})