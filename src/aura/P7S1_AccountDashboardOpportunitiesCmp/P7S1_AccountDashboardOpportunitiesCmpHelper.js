({
            /**************************************
            *   Get data from controller
            **************/
	doLoadData: function(component, helper) {
                var action = component.get("c.getOpportunityData");
                action.setParams({"accountId" : component.get("v.accountId"),
                                              "isAccountIndex" : component.get("v.isAccountIndex")});

                action.setCallback(this, function(a){
                    if(a.getState() === 'SUCCESS'){
                        component.set("v.oppData", helper.roundValues(a.getReturnValue(), helper));
                    } else {
                        var error = component.find("err");
                        $A.util.addClass(error, "errorFadingIn");
                    }
                    component.set("v.showSpinner", false);
                });

                $A.enqueueAction(action);
	},

            /**************************************
            *   Round values
            **************/
            roundValues: function(data, helper){
                data.sumOpen = helper.MoneyFormat(data.sumOpen);
                data.sumClosed = helper.MoneyFormat(data.sumClosed);
                data.target = helper.MoneyFormat(data.target);

                for(var i=0; i<data.tableData.length; i+=1){
                    data.tableData[i].open = helper.MoneyFormat(data.tableData[i].open);
                    data.tableData[i].closed = helper.MoneyFormat(data.tableData[i].closed);
                    data.tableData[i].yield = Math.round(data.tableData[i].yield);
                }

                return data;
            },

            /**************************************
            *   Format data depending on amount - 2015-12-10 AS
            **************/
	MoneyFormat: function MoneyFormat(labelValue) {

                if(Math.abs(Number(labelValue)) >= 1.0e+9){
                    return Math.round(Math.abs(Number(labelValue)) / 1.0e+9 *100) / 100 + $A.get("$Label.c.P7S1_AccDashboard_Opp_Billion");
                }else if(Math.abs(Number(labelValue)) >= 1.0e+6){
                    return Math.round(Math.abs(Number(labelValue)) / 1.0e+6 *100) / 100 + $A.get("$Label.c.P7S1_AccDashboard_Opp_Million");
                }else if(Math.abs(Number(labelValue)) >= 1.0e+3){
                    return Math.round(Math.abs(Number(labelValue)) / 1.0e+3 *100) / 100 + $A.get("$Label.c.P7S1_AccDashboard_Opp_Thousan");
                }else if(Math.abs(Number(labelValue)) > 0){
                    return Math.abs(Number(labelValue));
                }else{
                    return labelValue;
                }
	}
})