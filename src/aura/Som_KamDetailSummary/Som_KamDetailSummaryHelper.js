({
    calcSum : function(component, event) {
        var details = component.get("v.accPlanDetails"),
        sumCashLastYear = 0,
        sumCashThisYear = 0,
        sumGap = 0;

        for(var i=0; i<details.length; i+=1){
            if(details[i].accPlanDetail.Som_Status__c != 'Created'){
                if(! $A.util.isEmpty(details[i].accPlanDetail.Som_PreviousCashIn__c)){
                    sumCashLastYear += details[i].accPlanDetail.Som_PreviousCashIn__c;
                }
                if(! $A.util.isEmpty(details[i].accPlanDetail.Som_TargetCashIn__c)){
                    sumCashThisYear += details[i].accPlanDetail.Som_TargetCashIn__c;
                }
                if(! $A.util.isEmpty(details[i].gap)){
                    sumGap += details[i].gap;
                }
            }
        }

        var gapOutput = component.find("gapSum");
        if(sumGap < 0){
            $A.util.addClass(gapOutput, "redFont");
        }else{
            $A.util.removeClass(gapOutput, "redFont");
        }

        component.set("v.summaries", [sumCashLastYear, sumCashThisYear, sumGap]);
    }
})