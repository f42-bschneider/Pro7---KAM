public with sharing class SomTv_Opportunity_AgenturSplit{

    public static Integer iRowIndex { get; set; }
    public Set<ID> setAgenturSplitIDs { get; set; }
    public List<AgenturWrapper> listWrapper { get; set; }
    public Integer iDelIndex {get; set;}
    public Opportunity objOpp {get;set;}

    
    // Constructor
    public SomTv_Opportunity_AgenturSplit(ApexPages.StandardController con){
        
        // For Opportunity   
        objOpp = new Opportunity();     
        ID idOpp = null;
        String sRetUrlParam = '';
        String sRecordID = '';
        
        
        
        if(ApexPages.currentPage().getParameters().containsKey('retURL')){
            sRetUrlParam = ApexPages.currentPage().getParameters().get('retURL');
            sRecordID = sRetUrlParam.subString(1, sRetUrlParam.length());
        }
        
        
        // Get Opportunity, if button on related List clicked
        if(sRecordID.startsWith('006'))
            idOpp = sRecordID;
        
        
        // If the user edited, get "id"
        if(ApexPages.currentPage().getParameters().containsKey('id')){
            ID idAS = ApexPages.currentPage().getParameters().get('id');

            SomTv_Agentursplit__c objAS = [SELECT SomTv_Opportunity__c FROM SomTv_Agentursplit__c WHERE ID = :idAS];
            idOpp = objAS.SomTv_Opportunity__c;
        }
        

        // If the user edited, get "delid"
        if(ApexPages.currentPage().getParameters().containsKey('delid')){
            ID idAS = ApexPages.currentPage().getParameters().get('delid');

            SomTv_Agentursplit__c objAS = [SELECT SomTv_Opportunity__c FROM SomTv_Agentursplit__c WHERE ID = :idAS];
            idOpp = objAS.SomTv_Opportunity__c;
        }
        
        if(idOpp != null)
            objOpp = [SELECT ID, Name FROM Opportunity WHERE ID = :idOpp];        
        
        // Set index to 0. The index is the Identifier for the elements of the list
        iRowIndex = 0;
        
        // Initialize Lists and sets
        listWrapper = new List<agenturWrapper>();
        setAgenturSplitIDs = new Set<ID>();
        
        initListAgenturWrapper();
    }
    
    
    // Init List to create Table
    public void initListAgenturWrapper(){
        // clear list, in case it had values
        listWrapper.clear();
        
        // Fill wrapperlist
        for(SomTv_Agentursplit__c o : [SELECT SomTv_Agentur__c, SomTv_Agentur__r.Name, Name, SomTv_Prozent_Anteil__c FROM SomTv_Agentursplit__c WHERE SomTv_Opportunity__c = :objOpp.ID order by SomTv_Agentur__r.Name]){
             setAgenturSplitIDs.add(o.ID);
             listWrapper.add(new AgenturWrapper(o, false));       
        }
             
        // Add empty row
        addRow();             
    }
    
    
    // Save Method
    public PageReference saveAgentursplits(){
        List<SomTv_Agentursplit__c> listUpdateAS = new List<SomTv_Agentursplit__c>();
        List<SomTv_Agentursplit__c> listInsertAS = new List<SomTv_Agentursplit__c>();
        
        // Sum of Anteile
        Integer iSum = 0;
        
        // Go through Wrapper List
        for(AgenturWrapper o : listWrapper){         
            
            // You can only delete new ones
            if(!o.bPlaceHolder)
                if(setAgenturSplitIDs.contains(o.objAS.ID))
                   setAgenturSplitIDs.remove(o.objAS.ID);
 
            
            if(o.objAS.SomTv_Agentur__c != null){
                // If it is an existing one update
                if(!o.bPlaceHolder)
                    listUpdateAS.add(o.objAS);
                
                // If it is an new one insert                    
                if(o.bPlaceHolder)
                    listInsertAS.add(o.objAS);                    
                
                // Calulate Sum    
                if(o.objAS.SomTv_Prozent_Anteil__c != null)    
                    iSum += Integer.valueOf(o.objAS.SomTv_Prozent_Anteil__c);    
            }
        }
        
        
        // Check if sum Anteile is 100
        if(iSum != 100){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Die Summe der Anteile ist nicht 100!');
            ApexPages.addMessage(myMsg);
            return null;                
        }
        
        try{        
            // Do DML                
            update listUpdateAS;
            insert listInsertAS;
                       
         }catch(DMLException e){
            System.Debug('####' + e);    
            return null;                 
         }

         
        // Delete those from the set, which where not in the list
        if(setAgenturSplitIDs.size() > 0){
            List<SomTv_Agentursplit__c> listdeleteAS = new List<SomTv_Agentursplit__c>([SELECT ID FROM SomTv_Agentursplit__c WHERE ID IN :setAgenturSplitIDs]);        
            delete listdeleteAS;
        }    

        // Refresh list
        iRowIndex = 0;
        initListAgenturWrapper();
        
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Ihre Änderungen wurden erfolgreich durchgeführt!');
        ApexPages.addMessage(myMsg);
        return null;  
    }
    
    
    public PageReference addRow(){
        // Get highest Index
        listWrapper.add(new AgenturWrapper(new SomTv_Agentursplit__c(SomTv_Opportunity__c = objOpp.ID), true, getHighestIndex() + 1));
        
        return null;
    } 
    
    
    public Integer getHighestIndex(){
        Integer iHighestIndex = 0;
        for(AgenturWrapper a : listWrapper)
            if(a.iIndex > iHighestIndex)
                iHighestIndex = a.iIndex;
        
        return iHighestIndex;
    }
    
    // Delete From View
    public PageReference delAgenturSplit(){
        for(Integer i = 0; i < listWrapper.size(); i++)
           if(listWrapper.get(i).iIndex == iDelIndex)
                listWrapper.remove(i);

        return null;            
    }
    

    // Wrapper Class    
    public class AgenturWrapper {
        
        public Integer iIndex { get; set; }
        public SomTv_Agentursplit__c objAS { get; set; }
        public Boolean bPlaceHolder { get; set; }
        
        public agenturWrapper(SomTv_Agentursplit__c objAS, Boolean bPlaceHolder){
            this.objAS = objAS;
            this.bPlaceHolder = bPlaceHolder;
            this.iIndex = iRowIndex;
            iRowIndex++;
        }
        
        public agenturWrapper(SomTv_Agentursplit__c objAS, Boolean bPlaceHolder, Integer iIndex){
            this.objAS = objAS;
            this.bPlaceHolder = bPlaceHolder;
            this.iIndex = iIndex;
        }           
    }
}