public with sharing class SomTv_AccountTeamMember_Switch{
    
    public String sRolle { get; set; }
    public Account objAccount { get; set; }
    public String sOldUserID { get; set; }
    public String sNewUserID { get; set; }    
    public List<BeziehungWrapper> listBW { get; set; }
    public String sBeziehungType { get; set; }
    public String sReturnToID { get; set; }    

    
    public SomTv_AccountTeamMember_Switch(ApexPages.StandardController objCon){     
        objAccount = (Account) objCon.getRecord();
        listBW = new List<BeziehungWrapper>();
        
        sBeziehungType = ApexPages.CurrentPage().getParameters().get('type');
        sReturnToID = ApexPages.CurrentPage().getParameters().get('retURLID');        
    }
    
     
    // Get Roles of the AccountTeamMembers in the Account
    public List<SelectOption> getRollen() {
         List<SelectOption> listRoles = new List<SelectOption>();
         
         listRoles.add(new SelectOption('', 'Bitte wählen'));       
         for( Schema.PicklistEntry f : SomTv_Verkaeuferzuordnung__c.SomTv_Verkaeuferrolle__c.getDescribe().getPicklistValues())
            listRoles.add(new SelectOption(f.getLabel(), f.getValue()));

         return listRoles;        
    }
    
    
    // Creates a picklist with user depending on the role chosen in the first picklist
    public List<SelectOption> getOldUser() {

        List<SelectOption> listUsers = new List<SelectOption>();        
        listUsers.add(new SelectOption('', 'Bitte wählen'));

        // Get Available Roles, to fill picklist
        for(AccountTeamMember u : [SELECT UserId, User.Name FROM AccountTeamMember WHERE 
                                   TeamMemberRole = :sRolle AND 
                                   AccountID = :objAccount.Id])
            listUsers.add(new SelectOption(u.UserId, u.User.Name));

        
        return listUsers; 
    } 
    
    
    // Creates a picklist with all users except of the chosen one
    public List<SelectOption> getNewUser() {

        List<SelectOption> listUsers = new List<SelectOption>();        
        listUsers.add(new SelectOption('', 'Bitte wählen'));

        // Get Available Roles, to fill picklist
        for(AccountTeamMember u : [SELECT UserId, User.Name FROM AccountTeamMember WHERE AccountID = :objAccount.Id AND TeamMemberRole = :sRolle AND UserId != :sOldUserID])
            listUsers.add(new SelectOption(u.UserId, u.User.Name));
        
        return listUsers;
    }     
    
    
    public void initListBeziehungWrapper(){
        listBW.clear();

        if(sOldUserID != null){        

            if(sBeziehungType == 'agentur'){
                for(SomTv_Verkaeuferzuordnung__c  vz : [SELECT ID, Name, SomTv_GueltigVon__c, SomTv_Verkaeuferrolle__c, SomTv_KdAgenturBeziehung__r.GueltigVon__c, SomTv_KdAgenturBeziehung__r.GueltigBis__c,  SomTv_KdAgenturBeziehung__r.Agentur__c, SomTv_KdAgenturBeziehung__r.Kunde__c FROM SomTv_Verkaeuferzuordnung__c  
                                                        WHERE SomTv_Verkaeufer__c = :sOldUserID 
                                                        AND SomTv_KdAgenturBeziehung__r.Agentur__c = :objAccount.Id 
                                                        AND SomTv_GueltigBis__c = null 
                                                        AND SomTv_Verkaeuferrolle__c = :sRolle
                                                        order by SomTv_KdAgenturBeziehung__r.Kunde__r.Name])
                    
                    listBW.add(new BeziehungWrapper(vz, false));
            }
            
            
            if(sBeziehungType == 'kunde'){
                for(SomTv_Verkaeuferzuordnung__c  vz : [SELECT ID, Name, SomTv_GueltigVon__c, SomTv_Verkaeuferrolle__c, SomTv_KdAgenturBeziehung__r.GueltigVon__c, SomTv_KdAgenturBeziehung__r.GueltigBis__c,  SomTv_KdAgenturBeziehung__r.Agentur__c, SomTv_KdAgenturBeziehung__r.Kunde__c FROM SomTv_Verkaeuferzuordnung__c  
                                                        WHERE SomTv_Verkaeufer__c = :sOldUserID 
                                                        AND SomTv_KdAgenturBeziehung__r.Kunde__c = :objAccount.Id 
                                                        AND SomTv_GueltigBis__c = null 
                                                        AND SomTv_Verkaeuferrolle__c = :sRolle
                                                        order by SomTv_KdAgenturBeziehung__r.Kunde__r.Name])
                    
                    listBW.add(new BeziehungWrapper(vz, false));
            }            
        }
    }
    
    public PageReference save(){
    
        // If nothing is checked
        if(sRolle == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Bitte wählen Sie eine Rolle aus.');
            ApexPages.addMessage(myMsg);
            return null;                
        }    

        if(sOldUserID == null || sNewUserID == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Bitte wählen Sie die Mitarbeiter aus.');
            ApexPages.addMessage(myMsg);
            return null;                
        }    
        
        
        if(listBW.isEmpty()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Es wurden keine Kundenagenturbeziehungen gefunden.');
            ApexPages.addMessage(myMsg);
            return null;                
        }            
    
        
        List<SomTv_Verkaeuferzuordnung__c> listNewVZ     = new List<SomTv_Verkaeuferzuordnung__c>();        
        List<SomTv_Verkaeuferzuordnung__c> listUpdateVZ  = new List<SomTv_Verkaeuferzuordnung__c>();
        
        
        for(BeziehungWrapper b : listBW){
            
            // only if checked
            if(!b.bChecked) continue;
            
            // Create VZ for the new one
            listNewVZ.add(createNewVZ(b.objVZ));            

            // Set Gültig bis to yesterday
            b.objVZ.SomTv_GueltigBis__c = System.today().addDays(-1);
            
            listUpdateVZ.add(b.objVZ);
        }
        
        // If nothing is checked
        if(listUpdateVZ.isEmpty()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Bitte wählen Sie mindestens einen Listeneintrag aus.');
            ApexPages.addMessage(myMsg);
            return null;                
        }

        
        try{
            update listUpdateVZ;
            insert listNewVZ;
        }catch(DMLException e){
            System.Debug('###' + e.getMessage());       
            return null;
        }

        // Remove user from account team for the role, if there are no VZs and the role
        Integer iNumberOfVZs = 0;
        
        if(sBeziehungType == 'agentur'){        
            iNumberOfVZs = [SELECT COUNT() FROM SomTv_Verkaeuferzuordnung__c  WHERE SomTv_Verkaeufer__c = :sOldUserID 
                            AND SomTv_GueltigBis__c = null                                
                            AND SomTv_KdAgenturBeziehung__r.Agentur__c = :objAccount.Id                                
                            AND SomTv_Verkaeuferrolle__c = :sRolle]; 
        }
        
        if(sBeziehungType == 'kunde'){        
            iNumberOfVZs = [SELECT COUNT() FROM SomTv_Verkaeuferzuordnung__c  WHERE SomTv_Verkaeufer__c = :sOldUserID 
                            AND SomTv_GueltigBis__c = null                                
                            AND SomTv_KdAgenturBeziehung__r.Kunde__c = :objAccount.Id                                
                            AND SomTv_Verkaeuferrolle__c = :sRolle]; 
        }        
        
        
        if(iNumberOfVZs == 0){
            List<AccountTeamMember> listATM = new List<AccountTeamMember>([SELECT ID FROM AccountTeamMember 
                                                                           WHERE TeamMemberRole = :sRolle 
                                                                           AND AccountID = :objAccount.Id
                                                                           AND UserId = :sOldUserID]);
            
            if(!listATM.isEmpty())
                delete listATM;
        }
            
        if(sReturnToID != null && sReturnToID != ''){
            PageReference p1 = new PageReference('/' + sReturnToID);
            p1.setRedirect(true);
            return p1;
        }

        // If there was not returl specified
        PageReference p1 = new PageReference('/apex/SomTv_AccountTeamMember_Switch?id=' + objAccount.ID  +  '&type=kunde&retURLID=');
        p1.setRedirect(true);
        return p1;          

    }
    
    public SomTv_Verkaeuferzuordnung__c createNewVZ(SomTv_Verkaeuferzuordnung__c objVZ){
    
        SomTv_Verkaeuferzuordnung__c objNewVZ = objVZ.clone();
        objNewVZ.SomTv_GueltigVon__c = System.Today();
        objNewVZ.SomTv_Verkaeufer__c = sNewUserID;    
        
        return objNewVZ;
    }
    
    
    public class BeziehungWrapper{
        
        public Boolean bChecked { get; set; }
        public SomTv_Verkaeuferzuordnung__c objVZ { get; set; }
        
        public BeziehungWrapper(SomTv_Verkaeuferzuordnung__c objVZ, Boolean bChecked){
            this.bChecked   = bChecked;
            this.objVZ      = objVZ;            
        }   
    }
}