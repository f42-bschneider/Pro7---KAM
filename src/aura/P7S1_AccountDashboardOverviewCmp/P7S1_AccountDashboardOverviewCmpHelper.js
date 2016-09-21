({
            /**************************************
            *   Get data from controller
            **************/
	doLoadData: function(component, helper) {
                var action = component.get("c.getOverviewData");
                action.setParams({"accountId" : component.get("v.accountId")});

                action.setCallback(this, function(a){
                    if(a.getState() === 'SUCCESS'){
                        component.set("v.ovData", helper.groupValues(a.getReturnValue()));
                    } else {
                        var error = component.find("err");
                        $A.util.addClass(error, "errorFadingIn");
                    }
                    component.set("v.showSpinner", false);
                });

                $A.enqueueAction(action);
            },

            /**************************************
            *   Group values
            **************/
            groupValues: function(data){

                for(var i=0; i<data.length; i+=1){
                    data[i].endOfGroup = false;
                    if(i !== 0 && data[i].grp !== data[i-1].grp){
                        data[i-1].endOfGroup = true;
                    }
                }

                return data;
            }
})