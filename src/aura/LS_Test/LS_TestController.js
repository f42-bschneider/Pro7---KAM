({
            onInit : function(component, event, helper){
               helper.loadData(component, event);
            },

            onSave : function(component, event, helper){
                var detail = component.get("v.testDetail");
                var saveAccPlanDetail = component.get("c.doSave");

                saveAccPlanDetail.setParams({
                    "som" : detail,
                });

                saveAccPlanDetail.setCallback(this, function(resp){
                    var result = resp.getReturnValue();

                    if(component.isValid()){
                        helper.loadData(component, event);
                    }
                });

                $A.enqueueAction(saveAccPlanDetail);

            },

	myAction : function(component, event, helper) {
                /*
                var test = event.getParam("value");
                console.log('==>' + test);
                */

                //Toast test
                //component.find("toaster").callToast("success", "Testtext");
	},

            showOppmodal: function(component, event, helper) {
                //Toggle CSS styles for opening Modal
                helper.toggleClass(component,'backdrop','slds-backdrop--');
                helper.toggleClass(component,'modaldialog','slds-fade-in-');
            },

            hideModal : function(component, event, helper) {
                 //Toggle CSS styles for hiding Modal
                helper.toggleClassInverse(component,'backdrop','slds-backdrop--');
                helper.toggleClassInverse(component,'modaldialog','slds-fade-in-');
            }
})