public class Adv_OptimizingVersion_Forwarder{

    public Boolean bIsDelete;
    
    public ADvendio__OptimizingVersion__c objOV;
    public Adv_OptimizingVersion_Forwarder(ApexPages.standardController con){
    
        objOV = (ADvendio__OptimizingVersion__c) con.getRecord();
        objOV = [SELECT ID, ADvendio__DateOfActivation__c, ADvendio__MediaCampaign__c FROM ADvendio__OptimizingVersion__c WHERE ID = :objOV.ID];    
        
        bIsDelete = false;
        
        if(ApexPages.currentPage().getParameters().containsKey('delID'))
            bIsDelete = true;        
    }

    public PageReference forward(){
        
        if(objOV.ADvendio__DateOfActivation__c == null && bIsDelete){
            delete objOV;

            PageReference p1 = new PageReference ('/' + objOV.ADvendio__MediaCampaign__c);
            p1.setRedirect(true);
            return p1;
        }
        
        
        PageReference p1 = Page.ADvendio__Optimizer;
        p1.getParameters().put('scontrolCaching', '1');                        
        p1.getParameters().put('id', objOV.ID);                
        p1.setRedirect(true);
        return p1;
    }
}