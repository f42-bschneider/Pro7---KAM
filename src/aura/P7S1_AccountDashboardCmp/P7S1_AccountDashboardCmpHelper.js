({
            /**************************************
            *   Get data from controller
            **************/
	doLoadData: function(component, helper) {
                var action = component.get("c.getAccessData");
                action.setParams({"accountId" : component.get("v.accountId"), "accountIndexId" : component.get("v.accountIndexId")});

                action.setCallback(this, function(a){
                    if(a.getState() === 'SUCCESS'){

                        //Fade Dashboard in
                        var fadDiv = component.find("fadiv");
                        $A.util.addClass(fadDiv, "fadingIn");

                        var data = a.getReturnValue();
                        component.set("v.ctrlData", data);

                        //Show log after the source is loaded
                        if(data.imgId !== null && data.imgId !== ""){
                            document.getElementById("logo").style.display = 'inline';
                        }
                    } else {
                        $A.log("error");
                    }
                });

                $A.enqueueAction(action);
            },

            /**************************************
            *   Do redirect to the correct page if button is pressed
            **************/
            doAccRedirect: function(component, event) {
                var accId = component.get("v.accountId");
                window.open( "/" + accId, "_parent");
            },

            /**************************************
            *   Do redirect to the correct approval if button is pressed
            **************/
            doApprovalRedirect: function(component, event){
                var elementId = event.srcElement.getAttribute("id");
                var data = component.get("v.ctrlData");
                if(elementId === "accUeb"){
                    window.open( data.urls[0], "_parent");
                }else if(elementId === "accAuf"){
                    window.open( data.urls[1], "_parent");
                }else if(elementId === "logoInt"){
                    window.open( data.urls[2], "_parent");
                }
            }
})