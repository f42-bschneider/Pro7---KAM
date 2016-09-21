({
    onAccPlanSet : function(component, event, helper) {
        var params = event.getParam('arguments');

        if(params){
            component.set("v.accPlan", params.accPlan);
            var topicOptions = helper.buildTopicOptions(component);
            component.find("topic").set("v.options", topicOptions);

            helper.setProfSummary(component, topicOptions[0].value);
            helper.setProfDetails(component, topicOptions[0].value);

            component.set("v.previousTopic", topicOptions[0].value);
        }
    },

    onTopicChange : function(component, event, helper){
        var topicId = component.find("topic").get("v.value");
        if(component.isValid()){
            helper.setProfSummary(component, topicId);
            helper.setProfDetails(component, topicId);
            component.set("v.previousTopic", topicId);
        }
    },

    onSummaryDescriptionChange : function(component, event, helper){
        //*** Not vlaid with LS *** var stratProfId = event.getSource().getElement().parentNode.id,
        var stratProfId = event.getSource().get("v.referenceId"),
        value = event.getSource().get("v.value");

        if(component.isValid){
            helper.setSummaryStratProf(component, stratProfId, value);
        }
    },

    onDetailDescriptionChange : function(component, event, helper){
        //*** Not vlaid with LS *** var stratProfId = event.getSource().getElement().parentNode.id,
        var stratProfId = event.getSource().get("v.referenceId"),
        value = event.getSource().get("v.value");

        if(component.isValid()){
            helper.setDetailStratProf(component, stratProfId, value);
        }
    },

    onOk : function(component){
        component.getEvent("okClicked").fire();
    },

    onCancel : function(component){
        component.getEvent("cancelClicked").fire();
    }
})