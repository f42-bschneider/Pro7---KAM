({
    buildTopicOptions : function(component) {
        var result = [],
        accPlan = component.get("v.accPlan");

        for(var i=0; i<accPlan.stratProfileTopics.length; i+=1){
            var stratProf = accPlan.stratProfileTopics[i];

            result.push({
                "label" : stratProf.Name,
                "value" : stratProf.Som_Template__c,
                "class" : "optionClass"
            });
        }

        result[0].selected = true;

        return result;
    },

    setProfSummary : function(component, templateId){
        var accPlanStrats = component.get("v.accPlan.stratProfileTopics"),
        result;

        for(var i=0; i<accPlanStrats.length; i+=1){
            if(templateId === accPlanStrats[i].Som_Template__c){
                result = {
                    "stratProfId" : accPlanStrats[i].Id,
                    "Description" : accPlanStrats[i].Som_Description__c
                };

                component.set("v.profSummary", result);
                break;
            }
        }
    },

    setProfDetails : function(component, templateId){
        var accPlanDetails = component.get("v.accPlan.accPlanDetails"),
        result = [];

        for(var i=0; i<accPlanDetails.length; i+=1){
            for(var j=0; j<accPlanDetails[i].stratProfileTopics.length; j+=1){
                if(templateId === accPlanDetails[i].stratProfileTopics[j].Som_Template__c){
                    result.push({
                        "Name" : accPlanDetails[i].accPlanDetail.Som_KamTeam__r.Name,
                        "Description" : accPlanDetails[i].stratProfileTopics[j].Som_Description__c,
                        "stratProfId" : accPlanDetails[i].stratProfileTopics[j].Id
                    });

                    break;
                }
            }
        }

        component.set("v.profDetails", result);
    },

    setSummaryStratProf : function(component, stratProfId, value){
        var accPlan = component.get("v.accPlan");

        for(var i=0; i<accPlan.stratProfileTopics.length; i+=1){
            var stratProf = accPlan.stratProfileTopics[i];

            if(stratProf.Id === stratProfId){
                accPlan.stratProfileTopics[i].Som_Description__c = value;
                component.set("v.accPlan", accPlan);
                break;
            }
        }
    },

    setDetailStratProf : function(component, stratProfId, value){
        var accPlanDetails = component.get("v.accPlan.accPlanDetails");

        for(var i=0; i<accPlanDetails.length; i+=1){
            for(var j=0; j<accPlanDetails[i].stratProfileTopics.length; j+=1){
                if(stratProfId === accPlanDetails[i].stratProfileTopics[j].Id){
                    accPlanDetails[i].stratProfileTopics[j].Som_Description__c = value;
                    component.set("v.accPlan.accPlanDetails", accPlanDetails);
                    break;
                }
            }
        }
    }
})