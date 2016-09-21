({
	loadData: function(component, event, helper) {
                helper.doLoadData(component, helper);
            },

            onAccountIdSet : function(component, event, helper){
                var accountId,
                params = event.getParam('arguments');

                if(params){
                    component.set("v.accountId", params.accountId);
                    helper.doLoadData(component, helper);
                }
            }
})