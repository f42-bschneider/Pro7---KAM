({
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