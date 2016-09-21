public with sharing class SomDig_Prognose_ListEdit{

    public String recordID { get; set; }
    public String sFilter { get; set; }
    public Boolean bMyRecords { get; set; }
    public String sSortOrder { get; set; }
    public Integer iQ1 { get; set; }
    public Integer iQ2 { get; set; }
    public Integer iQ3 { get; set; }
    public Integer iQ4 { get; set; }
    public Integer iIP { get; set; }
    public Integer iIS { get; set; }
    public Integer iTV { get; set; }
    
    
    public SomDig_Prognose_ListEdit(){
        bMyRecords = true;
    }
    

    public List<SomDig_Prognose__c> getListPrognosen(){
        String sQuery = 'SELECT ID, SomDig_WtAgBeziehung__r.SomDig_UmsatzGesamtAj__c ,SomDig_PrognoseGesamt__c, SomDig_AccountBeziehungsname__c, SomDig_Inhaber__c, SomDig_WtAgBeziehung__c,SomDig_Vertriebsteam__c,  Name, SomDig_PrognoseQ1__c, SomDig_PrognoseQ2__c, SomDig_PrognoseQ3__c, SomDig_PrognoseQ4__c, SomDig_MedDiffInPage__c, SomDig_MedDiffRest__c, SomDig_MedDiffInStream__c FROM SomDig_Prognose__c WHERE SomDig_RelativesJahr__c = \'AJ\'';
        
        if(bMyRecords)
            sQuery += ' AND SomDig_WtAgBeziehung__r.SomDig_BeziehungInhaber__c = \'' + UserInfo.getUserId()  + '\'';
                
        
        if(sFilter != 'all' && sFilter != null && !bMyRecords)
            sQuery += ' AND SomDig_Vertriebsteam__c = \'' + sFilter + '\'';


        if(sSortOrder == null) sQuery += ' order by Name';
        else  sQuery += ' order by ' + sSortOrder;

        return Database.query(sQuery);
    }


    public PageReference cancel(){

        PageReference p1 = new PageReference('/a0B/o');
        p1.setRedirect(true);
        return p1;
    }


    public PageReference save(){

        SomDig_Prognose__c objPrognose = [SELECT ID FROM SomDig_Prognose__c WHERE ID = :recordID limit 1];

        objPrognose.SomDig_PrognoseQ1__c         = iQ1;
        objPrognose.SomDig_PrognoseQ2__c         = iQ2;
        objPrognose.SomDig_PrognoseQ3__c         = iQ3;
        objPrognose.SomDig_PrognoseQ4__c         = iQ4;
        objPrognose.SomDig_MedDiffInStream__c    = iIS;
        objPrognose.SomDig_MedDiffInPage__c      = iIP;
        objPrognose.SomDig_MedDiffRest__c        = iTV;

        try{
            update objPrognose;

        }catch(Exception e){
            System.Debug('###' + e.getMessage());
        }

        return null;
    }
}