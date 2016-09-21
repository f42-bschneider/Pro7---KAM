({
            /**************************************
            *   Get data from controller
            **************/
	doLoadData: function(component, helper) {
                var accountId = component.get("v.accountId");

                if(accountId){

                    var action = component.get("c.getMediaData");
                    action.setParams({"accountId" : accountId});

                    action.setCallback(this, function(a){
                        if(a.getState() === 'SUCCESS'){
                            component.set("v.nielsenData", helper.groupValues(a.getReturnValue(), helper));
                        } else {
                            var error = component.find("err");
                            $A.util.addClass(error, "errorFadingIn");
                        }
                        component.set("v.showSpinner", false);
                    });
                    $A.enqueueAction(action);
                }
            },

            /**************************************
            *   Hide media name if it is already in list
            **************/
            groupValues: function(data, helper){

                var group = '';
                for(var i=0; i<data.mediaData.length; i+=1){

                    //Format values
                    data.mediaData[i].value = helper.MoneyFormat(data.mediaData[i].value);

                    //Group values
                    var current = data.mediaData[i].media;
                    if(current === group){
                        data.mediaData[i].media = '';
                    }
                    group = current;
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