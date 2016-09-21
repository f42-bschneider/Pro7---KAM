public class Adv_CampaignItem_Forwarder{
    
    public ADvendio__Campaign_Item__c objCI;
    public Boolean bIsDelete;
    public Boolean bIsUpdate;
    
    public Adv_CampaignItem_Forwarder(ApexPages.standardController con){
    
        objCI = (ADvendio__Campaign_Item__c) con.getRecord();
        objCI = [SELECT ADvendio__from_Date__c ,ADvendio__Rate_Discount_4_Name__c, ADvendio__Media_Campaign__c, ADvendio__Media_Campaign__r.RecordType.Name FROM ADvendio__Campaign_Item__c WHERE ID = :objCI.ID];    
        
        bIsDelete = false;
        
        if(ApexPages.currentPage().getParameters().containsKey('delID'))
            bIsDelete = true;
    }

    public PageReference forward(){

        String sRCName = objCI.ADvendio__Media_Campaign__r.RecordType.Name;
        
        if(bIsDelete){
            if(sRCName == 'Angebot' || objCI.ADvendio__Rate_Discount_4_Name__c == 'Storno ohne Leistungsfluss'){
                PageReference p1 = new PageReference('/' + objCI.ADvendio__Media_Campaign__c);
                
                delete objCI;            
                
                p1.setRedirect(true);
                return p1;
            }
            
            
            if(sRCName == 'Auftrag')
                return pagereferenceOpti();
        }
            

        // If its not delete, it is update
        if(!bIsDelete){
            if(sRCName == 'Angebot')
                return pagereferenceKEM();
            
            if(sRCName == 'Auftrag'){
                if(objCI.ADvendio__from_Date__c > Date.today())
                    return pagereferenceKEM();                
                else
                    return pagereferenceOpti();
            }
        }
           
        return null;
    }
    
    public PageReference pagereferenceKEM(){
        
        PageReference p1 = Page.ADvendio__MediaConfiguration;
        p1.getParameters().put('retURL', '/' + objCI.ADvendio__Media_Campaign__c);                
        p1.getParameters().put('wrapMassAction', '1');                
        p1.getParameters().put('scontrolCaching', '1');                
        p1.getParameters().put('id', objCI.ADvendio__Media_Campaign__c);                                
        p1.setRedirect(true);
        return p1;
    }
    
    public PageReference pagereferenceOpti(){
        
        PageReference p1 = Page.ADvendio__Optimizer;
        p1.getParameters().put('mcId', objCI.ADvendio__Media_Campaign__c);
        p1.getParameters().put('records', objCI.ID);                
        p1.setRedirect(true);
        return p1;        
    }    
}