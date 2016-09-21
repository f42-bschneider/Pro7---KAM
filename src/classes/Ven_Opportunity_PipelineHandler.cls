public with sharing class Ven_Opportunity_PipelineHandler extends TriggerController{
    /**
    * @Methodname   Ven_Opportunity_PipelineHandler
    * @description  Constructor
    * @param        Trigger based values
    * @return       -
    */
    public Ven_Opportunity_PipelineHandler(Boolean isAfter, Boolean isBefore,
        Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    /**
    * @Methodname       runBeforeUpdate
    * @description  
    * @param            -
    * @return           void
    */
    protected override void runBeforeUpdate() {
        // VVR: 05.11.2015: Unterscheidung für VEN RecordTypes
        try{
            updateTotalValues(lstNewItems);
        }
        catch(Exception e){}
    }


    /**
    * @Methodname       updateTotalValues
    * @description  
    * @param            List<sObject>
    * @return           void
    */
    static void updateTotalValues(List<sObject> lstNewItems){
        system.debug(LoggingLevel.ERROR, 'START OppPipelineHandler');

        Map<Id, Opportunity> oppId2Opp                  = buildOppId2Opp(lstNewItems);

        Map<Id, Decimal> oppId2TotalGmvCurrentYear      = new Map<Id, Decimal>();
        Map<Id, Decimal> oppId2TotalCashCurrentYear     = new Map<Id, Decimal>();
        Map<Id, Decimal> oppId2TotalGmvNextYear         = new Map<Id, Decimal>();
        Map<Id, Decimal> oppId2TotalCashNextYear        = new Map<Id, Decimal>();

        buildTotalMaps(oppId2Opp.keySet(), oppId2TotalGmvCurrentYear, oppId2TotalCashCurrentYear, oppId2TotalGmvNextYear, oppId2TotalCashNextYear);

        for(Id oppId : oppId2Opp.keySet()){
            Opportunity opp                     = oppId2Opp.get(oppId);
            opp.Ven_TotalGmvCurrentYear__c      = oppId2TotalGmvCurrentYear.get(oppId).round(System.roundingMode.CEILING);
            opp.Ven_TotalCashCurrentYear__c     = oppId2TotalCashCurrentYear.get(oppId).round(System.roundingMode.CEILING);

            opp.Ven_TotalGmvNextYear__c         = oppId2TotalGmvNextYear.get(oppId).round(System.roundingMode.CEILING);
            opp.Ven_TotalCashNextYear__c        = oppId2TotalGmvNextYear.get(oppId).round(System.roundingMode.CEILING);
            
            Decimal somLikelihood               = Ven_Utility.getSomLikelihoodByEffYield(opp.Ven_EffectiveYield__c);

            opp.Ven_NetPotentialCurrentYear__c  = (opp.Ven_TotalGmvCurrentYear__c * (opp.Ven_EffectiveYield__c/100) * (somLikelihood/100) * (opp.Probability/100)).round(System.roundingMode.CEILING);
            opp.Ven_NetPotentialNextYear__c     = (opp.Ven_TotalGmvNextYear__c * (opp.Ven_EffectiveYield__c/100) * (somLikelihood/100) * (opp.Probability/100)).round(System.roundingMode.CEILING);
        }
    }

    /**
    * @Methodname       getOppId2Opp
    * @description  
    * @param            List<sObject>
    * @return           List<Opportunity>
    */
    static Map<Id, Opportunity> buildOppId2Opp(List<sObject> lstNewItems){
        Map<Id, Opportunity> oppId2Opp = new Map<Id, Opportunity>();

        for(sObject obj : lstNewItems){
            Opportunity opp = (Opportunity) obj;
            oppId2Opp.put(opp.Id, opp);
        }

        return oppId2Opp;
    }

    /**
    * @Methodname       getOppId2Opp
    * @description  
    * @param            List<sObject>
    * @return           List<Opportunity>
    */
    static void buildTotalMaps(Set<Id> oppIds, Map<Id, Decimal> oppId2TotalGmvCurrentYear, Map<Id, Decimal> oppId2TotalCashCurrentYear, Map<Id, Decimal> oppId2TotalGmvNextYear, Map<Id, Decimal> oppId2TotalCashNextYear){
        Decimal thisYear = Date.today().year();
        Decimal nextYear = thisYear+1;

        for(AggregateResult ar : [  SELECT Ven_Opp__c oppId, SUM(Ven_Amount__c) totalGmv, SUM(Ven_Cash__c) totalCash 
                                    FROM Ven_OppPipeline__c 
                                    WHERE Ven_Opp__c IN :oppIds AND Ven_Year__c = :thisYear
                                    GROUP BY Ven_Opp__c]){

            oppId2TotalGmvCurrentYear.put((Id) ar.get('oppId'), (Decimal) ar.get('totalGmv'));
            oppId2TotalCashCurrentYear.put((Id) ar.get('oppId'), (Decimal) ar.get('totalCash'));
        }

        for(AggregateResult ar : [  SELECT Ven_Opp__c oppId, SUM(Ven_Amount__c) totalGmv, SUM(Ven_Cash__c) totalCash 
                                    FROM Ven_OppPipeline__c 
                                    WHERE Ven_Opp__c IN :oppIds AND Ven_Year__c = :nextYear
                                    GROUP BY Ven_Opp__c]){

            oppId2TotalGmvNextYear.put((Id) ar.get('oppId'), (Decimal) ar.get('totalGmv'));
            oppId2TotalCashNextYear.put((Id) ar.get('oppId'), (Decimal) ar.get('totalCash'));
        }   
    }
}