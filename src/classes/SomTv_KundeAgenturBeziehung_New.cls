public with sharing class SomTv_KundeAgenturBeziehung_New{

    public SomTv_KundeAgenturBeziehung__c objNewKAB { get; set; }
    public String sKverkaeufer { get; set; }
    public String sPAverkaeufer { get; set; }
    public String sEAverkaeufer { get; set; }
    public Account objAccount { get; set; }    

    

    public SomTv_KundeAgenturBeziehung_New(){
        
        objAccount = new Account();
        
        // Get Account ID from URL
        ID idAccount = null;
        String sType = '';
        if(ApexPages.currentPage().getParameters().containsKey('id')){
            idAccount = ApexPages.currentPage().getParameters().get('id');
            sType = ApexPages.currentPage().getParameters().get('type');
        }            


        // If he found the account ID get the Data
        if(idAccount != null){
        
            objAccount = [SELECT ID FROM Account WHERE ID = :idAccount limit 1];

            objNewKAB = new SomTv_KundeAgenturBeziehung__c(Name = 'wird automatisch befüllt');
            
            // Startdate = 01.01 of this year
            objNewKAB.GueltigVon__c = Date.newInstance(Date.today().year(), 1, 1);
            
            
            if(sType == 'kunde')      
                objNewKAB.Kunde__c = objAccount.ID;
            
            if(sType == 'agentur')      
                objNewKAB.Agentur__c = objAccount.ID;            
        }    
    }



    public PageReference saveData(){
        
        List<SomTv_Verkaeuferzuordnung__c> listVZ = new List<SomTv_Verkaeuferzuordnung__c>();
        
        // Create Verkäuferzuordnungen     
        if(sKverkaeufer != null) 
            listVZ.add(createVZ('TV_Kundenverkäufer', sKverkaeufer, objNewKAB.GueltigVon__c));    
        
        if(sEAverkaeufer != null) 
            listVZ.add(createVZ('TV_Einkaufsagenturverkäufer', sEAverkaeufer, objNewKAB.GueltigVon__c));    
        
        if(sPAverkaeufer != null){   
            sPAverkaeufer = sPAverkaeufer == 'default' ? sEAverkaeufer : sPAverkaeufer; 
            listVZ.add(createVZ('TV_Planungsagenturverkäufer', sPAverkaeufer, objNewKAB.GueltigVon__c));            
        }
        
        try{
            
            insert objNewKAB;
            
            for(SomTv_Verkaeuferzuordnung__c o : listVZ)
                o.SomTv_KdAgenturBeziehung__c  = objNewKAB.ID;
            
            insert listVZ;
            
            PageReference p1 = new PageReference('/' + objNewKAB.ID);
            p1.setRedirect(true);
            return p1;
            
        }catch(Exception e){
            System.debug('###' + e.getMessage());
        }
        
        return null;
    }
    
    
    public PageReference cancel(){
        PageReference p1 = new PageReference('/' + objAccount.ID);
        p1.setRedirect(true);
        return p1;
    }
    

    public SomTv_Verkaeuferzuordnung__c createVZ(String sRolle, ID userID, Date gueltigVon){
        SomTv_Verkaeuferzuordnung__c objVZ = new SomTv_Verkaeuferzuordnung__c();
        objVZ.SomTv_Verkaeuferrolle__c = sRolle; 
        objVZ.SomTv_GueltigVon__c = gueltigVon;
        objVZ.SomTv_Verkaeufer__c = userID;
        
        return objVZ;
    }     
    
    
    // Get Kundenverkaeufer Picklist
    public List<SelectOption> getKundenverkaeufer(){
        List<SelectOption> listKundenverkeufer = new List<SelectOption>();
        
        for(AccountTeamMember atm : [SELECT UserId, User.Name FROM AccountTeamMember WHERE AccountID = :objNewKAB.Kunde__c AND TeamMemberRole = 'TV_Kundenverkäufer'])
            listKundenverkeufer.add(new SelectOption(atm.UserId, atm.User.Name));        
        
        return listKundenverkeufer;
    }
    
    
    
    public List<SelectOption> getEinkaufsagenturverkaeufer(){
        List<SelectOption> listEAverkeufer = new List<SelectOption>();
        
        for(AccountTeamMember atm : [SELECT UserId, User.Name FROM AccountTeamMember WHERE AccountID = :objNewKAB.Agentur__c AND TeamMemberRole = 'TV_Einkaufsagenturverkäufer'])
            listEAverkeufer.add(new SelectOption(atm.UserId, atm.User.Name));        
        
        return listEAverkeufer;
    }    
    
    
    public List<SelectOption> getPlanungsagenturverkaeufer(){
        List<SelectOption> listPAverkeufer = new List<SelectOption>();
        
        listPAverkeufer.add(new SelectOption('default', 'wie Einkaufsagenturverkäufer'));
        
        for(User u : [SELECT Name FROM user WHERE Profile.Name like 'SomTv_Sales%' order by Name])
            listPAverkeufer.add(new SelectOption(u.ID, u.Name));        
        
        return listPAverkeufer;
    }        
}