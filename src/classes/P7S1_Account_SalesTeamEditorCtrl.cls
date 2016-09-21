/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_Account_SalesTeamEditorCtrl
* @author:          BS factory42
* @email:           bschneider@factory42.com
* @version:         V0.3
* @date:            2016-01-18
* @last change:		VVR: 15.02.2016 - New ChangeRequest Martin Unsinn: Populate TV Kundenverkäufer if AccTeamRole exists
*									- Only Customer will create AccTeamMember and update UserLookup
*									- Fill UserLookups on Customer Account from Agency
* @description:    Controller for VF to edit Sales-Team
* @objects:         Account, SomTv_KundeAgenturBeziehung__c, SomTv_Verkaeuferzuordnung__c
* =================================================================
*/
public without sharing class P7S1_Account_SalesTeamEditorCtrl {

    //**********private**********
    private String accId;
    private Date firstOfYear;
    private Boolean errorKVKAgency;
    //**********public**********
    public Account currentAccount {get;set;}
    public Account customerAccount {get;set;}
    public SomTv_KundeAgenturBeziehung__c objKAB {get;set;}
    public list<SomTv_KundeAgenturBeziehung__c> lstKAB {get;set;}
    public list<vkzSelect> lstVkZ {get;set;}
    public String accType {get;set;}
    public String tvSalesEavName {get;set;}
    public String tvSalesEavId {get;set;}
    public Boolean showKAB {get;set;}
    public Boolean showModal {get;set;}
    public Boolean hasAccess {get;set;}

    /*****************************
    * Constructor
    *****/
    public P7S1_Account_SalesTeamEditorCtrl() {

        //Initiate
        firstOfYear = date.newInstance(Date.today().year(), 1, 1);
        objKAB = new SomTv_KundeAgenturBeziehung__c(GueltigVon__c = firstOfYear);
        showKAB = false;
        showModal = false;
        errorKVKAgency = false;
        hasAccess = checkAccessRights();
        lstVkZ = prefillVkZ();

        //Check Parameters
        Map<String, String> mapParam = Apexpages.currentPage().getParameters();
        if(mapParam != null){
            if(mapParam.containsKey('accId')){
                accId = mapParam.get('accId');
            }
        }

        //Load Account data
        if(accId != null){
            currentAccount = loadAccData(accId);
        }
    }

    /*****************************
    * Check access rights
    *****/
    private Boolean checkAccessRights(){
        //Only members of Sales Steering group are allowed to enter the VF
        if([SELECT Id FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId() AND Group.Name = 'P7S1_ProfilesSomTv_SalesSteering'].size() > 0){
            return true;
        }
        if([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() AND (Profile.Name = 'Systemadministrator' OR Profile.Name = 'System Administrator' )].size() > 0){
            return true;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.P7S1_SalesTeam_Error_Access));
        return false;
    }

    /*****************************
    * Load Account data
    *****/
    private Account loadAccData(String idAcc){
        Account acc = [SELECT Id,SOM_TVKundenverkaeufer__c,SOM_TVKundenverkaeufer__r.Firstname,SOM_TVKundenverkaeufer__r.Lastname, Name, Owner.Name, SomTv_Accounttypen__c FROM Account WHERE Id =: idAcc LIMIT 1];

        //Calculate Account type
        if(acc != null){
            if(acc.SomTv_Accounttypen__c == 'Agentur' || acc.SomTv_Accounttypen__c == 'Agenturverbund'){
                accType = 'agency';
                objKAB.Agentur__c = acc.Id;
            }else{
                accType = 'customer';
                objKAB.Kunde__c = acc.Id;
                objKAB.SomTv_RelevanteBeziehung__c = true;
        		// New ChangeRequest Martin Unsinn 15.02.2016: Populate TV Kundenverkäufer if AccTeamRole exists
        		try{
        			AccountTeamMember atm = [SELECT Id,User.Firstname,User.Lastname,UserID FROM AccountTeamMember WHERE AccountId = :acc.id AND TeamMemberRole = 'TV_Kundenverkäufer' limit 1];
					tvSalesEavName = atm.User.Firstname + ' ' + atm.User.Lastname;
        			tvSalesEavId = atm.UserID;
        		}
        		catch(Exception e){
        			if(acc.SOM_TVKundenverkaeufer__c !=NULL){
        				tvSalesEavName = acc.SOM_TVKundenverkaeufer__r.Firstname + ' ' + acc.SOM_TVKundenverkaeufer__r.Lastname;
        				tvSalesEavId = acc.SOM_TVKundenverkaeufer__c;
        			}
        		}
            }
        }

        return acc;
    }

    /*****************************
    * Prefill list of SomTv_Verkaeuferzuordnung__c
    *****/
    private list<vkzSelect> prefillVkZ(){
        list<vkzSelect> newListVkZ = new list<vkzSelect>();
        newListVkZ.add(new vkzSelect(new SomTv_Verkaeuferzuordnung__c(SomTv_Verkaeuferrolle__c = 'TV_Kundenverkäufer', SomTv_GueltigVon__c = firstOfYear), 'KVK'));
        newListVkZ.add(new vkzSelect(new SomTv_Verkaeuferzuordnung__c(SomTv_Verkaeuferrolle__c = 'TV_Einkaufsagenturverkäufer', SomTv_GueltigVon__c = firstOfYear), 'EAV'));
        newListVkZ.add(new vkzSelect(new SomTv_Verkaeuferzuordnung__c(SomTv_Verkaeuferrolle__c = 'TV_Planungsagenturverkäufer', SomTv_GueltigVon__c = firstOfYear), 'PAV'));
        return newListVkZ;
    }

    /*****************************
    * Prefill KVK with TV_Kundenverkäufer from Customer
    *****/
    public void prefillKVK(){
        list<AccountTeamMember> lstAtmKVK = [SELECT UserId, User.Name FROM AccountTeamMember WHERE AccountId = :objKAB.Kunde__c AND TeamMemberRole = 'TV_Kundenverkäufer'];
        if(!lstAtmKVK.isEmpty()){
            for(AccountTeamMember atm : lstAtmKVK){
                lstVkZ[0].text = atm.User.Name;
                lstVkZ[0].id = atm.UserId;
                errorKVKAgency = false;
            }
        }else{
            errorKVKAgency = true;
            addErrorKVKOnCustomer();
        }
    }

    private void addErrorKVKOnCustomer(){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.P7S1_SalesTeam_Error_KVK));
    }

    /*****************************
    * Prefill EAV/PAV if Agency and tvSalesEavIdis empty - Change Request KV 03396 - BS 23.02.16
    *****/
    public void prefillEavPav(){
        system.debug(accType +'##'+ tvSalesEavName +'##'+ tvSalesEavId);
        if(accType == 'agency' && (tvSalesEavName == null || tvSalesEavName == '...' || tvSalesEavId == '')){
            for(AccountTeamMember atm : [SELECT UserId, User.Name FROM AccountTeamMember WHERE AccountId = :currentAccount.Id AND TeamMemberRole = 'TV_Einkaufsagenturverkäufer']){
                tvSalesEavName = atm.User.Name;
                tvSalesEavId = atm.UserId;
                lstVkZ[1].text = atm.User.Name;
                lstVkZ[1].id = atm.UserId;
                lstVkZ[2].text = atm.User.Name;
                lstVkZ[2].id = atm.UserId;
            }
        }
    }

    /*****************************
    * Remote action for user autocomplete
    *****/
    @RemoteAction
    public static List<User> searchUser(String searchTerm, String figure, String curAgency, String curCust, String curAccId, String curAccType) {

        //Get Role Ids - Parent roles 71M Digital and 71M TV Sales
        set<Id> parentRoles = new Set<ID>{Label.P7S1_SalesTeam_Role_Digital, Label.P7S1_SalesTeam_Role_Tv};
        Set<Id> allSubRoleIds = getAllSubRoleIds(parentRoles);
        allSubRoleIds.addAll(parentRoles);

        //Standard query
        String soql = 'SELECT Id, Name FROM User WHERE isActive = true AND Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' ';

        //Only EAV
        // || (figure == '0' && curAccType == 'agency')
        /*if(figure == '2'){
            String inputAcc = figure == '2' ? curAgency : curAccId;
            set<String> userIds = new set<String>();
            for(AccountTeamMember atm : [SELECT UserId FROM AccountTeamMember WHERE AccountId = :inputAcc AND TeamMemberRole = 'TV_Einkaufsagenturverkäufer']){
                userIds.add(atm.UserId);
            }
            soql += ' AND Id IN :userIds';
        }*/
        if(figure == '2' || (figure == '1' && curAccType == 'agency')){
            String roleStr = figure == '1' ? 'TV_Kundenverkäufer' : 'TV_Einkaufsagenturverkäufer';
            String inputAcc = figure == '1' ? curCust : curAgency;
            set<String> userIds = new set<String>();
            for(AccountTeamMember atm : [SELECT UserId FROM AccountTeamMember WHERE AccountId = :inputAcc AND TeamMemberRole = :roleStr]){
                userIds.add(atm.UserId);
            }
            soql += ' AND Id IN :userIds';
        }else{
            soql += ' AND UserRoleId IN :allSubRoleIds ';
        }

        //Query User return list to autocomplete
        List<User> lstUser = Database.query(soql);
        return lstUser;
    }

    /*****************************
    * Query Role hierarchy
    *****/
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[SELECT Id FROM UserRole WHERE ParentRoleId IN :roleIds AND ParentRoleID != null]) {
            currentRoleIds.add(userRole.Id);
        }
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }

    /*****************************
    * Change tvSalesEav
    *****/
    public void changeTvSalesEav(){
        for(vkzSelect vs : lstVkZ){
            if((accType == 'customer' && vs.vkz.SomTv_Verkaeuferrolle__c == 'TV_Kundenverkäufer') || (accType == 'agency' && vs.vkz.SomTv_Verkaeuferrolle__c == 'TV_Einkaufsagenturverkäufer')){
                vs.text = tvSalesEavName;
                vs.id = tvSalesEavId;
            }
        }
    }

    /*****************************
    * Check values before saving
    *****/
    public PageReference checkBeforeSave(){

        //Check is all fields are filled
        if(!checkRelevantFields()){
            return null;
        }

        //Check if there are still relevant KABs
        if(showKAB && !showModal && !checkKABs()){
            openModal();
            return null;
        }

        return saveData();
    }

    /*****************************
    * Save as relevant or not relevant
    *****/
    public PageReference saveRelevant(){
        //Sett old KAB to not relevant
        for(SomTv_KundeAgenturBeziehung__c kab : lstKAB){
            kab.SomTv_RelevanteBeziehung__c = false;
        }
        update lstKAB;

        PageReference pr = saveData();
        return pr;
    }

    public PageReference saveNotRelevant(){
        objKAB.SomTv_RelevanteBeziehung__c = false;
        return saveData();
    }

    /*****************************
    * Saving data
    *****/
    public PageReference saveData(){

        //Close panel
        closeModal();

        //Set savepoint for rollback if error occurs
        Savepoint sp = Database.setSavepoint();
        try {

            if(showKAB){
                String tvSalesUser;
                String tvSalesPAVUser;

                //Mapping TeamMemberRole to sales field
                map<String, String> mapRole2Field = new map<String, String>();
                mapRole2Field.put('TV_Kundenverkäufer', 'SOM_TVKundenverkaeufer__c');
                mapRole2Field.put('TV_Einkaufsagenturverkäufer', 'SOM_Einkaufsagenturverkaeufer__c');
                mapRole2Field.put('TV_Planungsagenturverkäufer', 'SOM_Planungsagenturverkaeufer__c');

                //Create KAB
                insert objKAB;

                //Create SomTv_Verkaeuferzuordnung__c
                list<SomTv_Verkaeuferzuordnung__c> lstInsertVkz = new list<SomTv_Verkaeuferzuordnung__c>();
                for(vkzSelect vkzs : lstVkZ){
                    //Set Account fields
                    currentAccount.put(mapRole2Field.get(vkzs.vkz.SomTv_Verkaeuferrolle__c), vkzs.id);

                    //Set user for AccountTeam
                    if(vkzs.type == 'KVK'){
                        tvSalesUser = vkzs.id;
                    }
					if(vkzs.type == 'PAV'){
                        tvSalesPAVUser = vkzs.id;
                    }


                    //Set SomTv_Verkaeuferzuordnung__c
                    vkzs.vkz.SomTv_KdAgenturBeziehung__c = objKAB.Id;
                    vkzs.vkz.SomTv_Verkaeufer__c = vkzs.id;
                    lstInsertVkz.add(vkzs.vkz);

                    //If Kunde = Agentur only TV_Kunderverkäufer has to be filled
                    if(objKAB.Agentur__c == objKAB.Kunde__c){
                        break;
                    }
                }
                insert lstInsertVkz;

                //Update Customer Account if relevant
                if(objKAB.SomTv_RelevanteBeziehung__c && accType == 'customer'){
                    update currentAccount;

                    //Create AccountTeamMember for TV_Kundenverkäufer
                    createAccTeamMember(tvSalesUser,'TV_Kundenverkäufer');
                }
                //Update Customer Account if relevant, but started from agency account
                if(objKAB.SomTv_RelevanteBeziehung__c && accType == 'agency'){
					customerAccount = new Account(id = objKAB.Kunde__c,
												  SOM_TVKundenverkaeufer__c = tvSalesUser,
												  SOM_Einkaufsagenturverkaeufer__c = tvSalesEavId,
												  SOM_Planungsagenturverkaeufer__c = tvSalesPAVUser
												  );
					update customerAccount;
                    //Create AccountTeamMember for TV_Kundenverkäufer
                    createAccTeamMember(tvSalesUser,'TV_Kundenverkäufer');
                }

            }else{

                if(accType == 'customer'){
                    createAccTeamMember(tvSalesEavId,'TV_Kundenverkäufer');
                    currentAccount.put('SOM_TVKundenverkaeufer__c', tvSalesEavId);
	    }
			   /** Change Request 15.02.2016 by Martin Unsinn:Feld „relevante Beziehung“ darf sich nur auf den Kunden-Account durchschlagen, nicht auf die Agentur.
			   Disabled check and Accountupdate for Agency
               if(accType == 'agency'){
                    createAccTeamMember(tvSalesEavId,'TV_Einkaufsagenturverkäufer');
                    currentAccount.put('SOM_Einkaufsagenturverkaeufer__c', tvSalesEavId);
                }else{
                    currentAccount.put('SOM_TVKundenverkaeufer__c', tvSalesEavId);
                }
                **/
                 update currentAccount;
            }

            // Change Request KV 03396 - BS 23.02.16
            if(accType == 'agency' && !checkMemberInAccTeam(currentAccount.Id, tvSalesEavId, 'TV_Einkaufsagenturverkäufer')){
                createAccTeamMember(tvSalesEavId,'TV_Einkaufsagenturverkäufer');
            }

        } catch(Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.P7S1_SalesTeam_Error_Save + e.getMessage()));
            return null;
        }

        return cancel();
    }

    /*****************************
    * Check AccountTeam for member
    *****/
    private Boolean checkMemberInAccTeam(String strAccId, String strUserId, String strRole){
        list<AccountTeamMember> lstCheckAtm = [SELECT Id FROM AccountTeamMember WHERE AccountId = :strAccId AND UserId = :strUserId AND TeamMemberRole = :strRole];
        if(lstCheckAtm.isEmpty()) return false;
        else return true;
    }

    /*****************************
    * Create AccountTeamMember for TV_Kundenverkäufer
    *****/
    private void createAccTeamMember(String tvSalesUser, string roleName){

        //Delete old ATM TV_Kundenverkäufer
        list<AccountTeamMember> lstOldATM = [SELECT Id FROM AccountTeamMember WHERE AccountId = :objKAB.Kunde__c AND TeamMemberRole = :roleName];
        delete lstOldATM;

        //Create new ATM
        AccountTeamMember newATM = new AccountTeamMember();
        if(roleName == 'TV_Kundenverkäufer') newATM.AccountId = objKAB.Kunde__c;
        if(roleName == 'TV_Einkaufsagenturverkäufer') newATM.AccountId = objKAB.Agentur__c;
        newATM.TeamMemberRole = roleName;
        newATM.UserId = tvSalesUser;
        insert newATM;

        //Create AccountShare because of read/write access to Account
        Database.insert(new AccountShare(UserOrGroupId=newATM.UserId, AccountId=newATM.Accountid, AccountAccessLevel='Edit',OpportunityAccessLevel='None'), false);
    }

    /*****************************
    * Check relevant fields
    *****/
    private Boolean checkRelevantFields(){

        system.debug('tvSalesEavName: '+ tvSalesEavName +'##### tvSalesEavId: '+ tvSalesEavId +'##### showKAB: '+ showKAB +'##### objKAB: '+ objKAB.Agentur__c +'##### Kunde__c:'+ objKAB.Kunde__c);

        if(errorKVKAgency){
            addErrorKVKOnCustomer();
            return false;
        }

        //All sales members have to be filled
        if((tvSalesEavName == null || tvSalesEavName == '...' || tvSalesEavId == '') && (!showKAB || objKAB.Agentur__c != objKAB.Kunde__c)){
        	system.debug('### Message in tvSalesEavName');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.P7S1_SalesTeam_Error_Missing));
            return false;
        }

        if(showKAB){
            for(vkzSelect sel : lstVkZ){
                sel.showError = false;
                if(sel.text == null || sel.text == '...' || sel.id == ''){
                	system.debug('### Message in showKAB');
                	// Message ...
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.P7S1_SalesTeam_Error_Missing+': '+sel.type));
                    sel.showError = true;
                    return false;
                }
                //If Kunde = Agentur only TV_Kunderverkäufer has to be filled
                if(objKAB.Agentur__c == objKAB.Kunde__c){
                    break;
                }
            }
        }

        return true;
    }

    /*****************************
    * Check for multiple relevant
    *****/
    private Boolean checkKABs(){
        lstKAB = [SELECT Kunde__c, Agentur__c, Id, GueltigVon__c, GueltigBis__c FROM SomTv_KundeAgenturBeziehung__c WHERE SomTv_RelevanteBeziehung__c  = true AND Kunde__c =: objKAB.Kunde__c];
        if(showKAB && objKAB.SomTv_RelevanteBeziehung__c && lstKAB.size() > 0){
            return false;
        }
        return true;
    }

    /*****************************
    * Handle modal panel
    *****/
    public void closeModal(){
        showModal = false;
    }

    public void openModal(){
        showModal = true;
    }

    /*****************************
    * Change Account Owner reference
    *****/
    public PageReference changeAccOwner(){
        PageReference pr = new PageReference('/' + accId + '/a?keepTeam=1&keepSalesTeam=1&sendMail=1&retURL=%2Fapex%2FP7S1_Account_SalesTeamEditor%3FaccId%3D' + accId);
        pr.setRedirect(true);
        return pr;
    }

    /*****************************
    * Cancel
    *****/
    public PageReference cancel(){
        PageReference pr = new PageReference('/' + accId);
        pr.setRedirect(true);
        return pr;
    }

    /*****************************
    * Wrapper for SomTv_Verkaeuferzuordnung__c
    *****/
    public class vkzSelect{

        public SomTv_Verkaeuferzuordnung__c vkz {get;set;}
        public String text {get;set;}
        public String id {get;set;}
        public String type {get;set;}
        public Boolean showError {get;set;}

        public vkzSelect(SomTv_Verkaeuferzuordnung__c vkz, String type){
            this.vkz = vkz;
            this.type = type;
        }

    }

}