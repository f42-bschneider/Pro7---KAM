({
	showToast : function(component, event, helper) {

                var type,
                msg,
                params = event.getParam('arguments'),
                toaster = component.find("toaster");

                $A.util.removeClass(toaster, 'slds-theme--success');
                $A.util.removeClass(toaster, 'slds-theme--warning');
                $A.util.removeClass(toaster, 'slds-theme--error');
                $A.util.removeClass(toaster, 'hideIt');

                if(params){
                    type = params.type;
                    msg = params.msg;

                    if(type === 'success'){
                        //***Success
                        $A.util.addClass(toaster, 'slds-theme--success');
                    }else if(type === 'warning'){
                        //***Warning
                        $A.util.addClass(toaster, 'slds-theme--warning');
                    }else if(type === 'error'){
                        //***Error
                        $A.util.addClass(toaster, 'slds-theme--error');
                    }

                    component.set("v.text", msg);
                }

                window.setTimeout($A.getCallback(function(){
                    helper.hideToast(component);
                }), 3000);

	},

            hideToast : function(component){
                if(component.isValid){
                    var toaster = component.find("toaster");
                    $A.util.addClass(toaster, 'hideIt');
                }
            }
})