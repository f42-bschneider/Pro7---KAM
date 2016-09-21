/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_BatchAccountTeamMemberHelper
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.2
* @ date        2016/02/16
* @description
* @last change	VVR: 03.03.2016: Added new ORDER BY and move AccIDs in only for TV_Kundenverkäufer
* @objects
* =================================================================
*/
public without sharing class P7S1_BatchAccountTeamMemberHelper {
    /* Constructor */
    /*********************/
    public P7S1_BatchAccountTeamMemberHelper(){
    }


	/****************************
	Batch_Execute
	*/
    public void Batch_Execute(List<sObject> lstObjects){
		set<ID> activeUserIDs = new set<ID>();
		List<AccountTeamMember> insertAccTeamMember = new List<AccountTeamMember>();
		map<ID,Account> accMap = new Map<ID,Account>();
		List<Account> lstAccount = new List<Account>();
		set<ID> accIDs = new set<ID>();
		for (User u:[select id from user where isactive = true]){
			activeUserIDs.add(u.id);
		}

        if( !(lstObjects == null || lstObjects.isEmpty())){
			for(sObject objA :lstObjects){
				SomTv_Verkaeuferzuordnung__c vkz = (SomTv_Verkaeuferzuordnung__c)objA;
				if(activeUserIDs.contains(vkz.SomTv_Verkaeufer__c)) {
					if(vkz.SomTv_Verkaeuferrolle__c == 'TV_Kundenverkäufer'){
						insertAccTeamMember.add(populateAccTeamMember(vkz.SomTv_KdAgenturBeziehung__r.Kunde__c,vkz.SomTv_Verkaeufer__c,'TV_Kundenverkäufer'));
						accIDs.add(vkz.SomTv_KdAgenturBeziehung__r.Kunde__c);
					}
					if(accMap.containsKey(vkz.SomTv_KdAgenturBeziehung__r.Kunde__c)){
						Account a = accMap.get(vkz.SomTv_KdAgenturBeziehung__r.Kunde__c);
						fillAccountVerkaeufer(a,vkz.SomTv_Verkaeuferrolle__c,vkz.SomTv_Verkaeufer__c);
						accMap.put(vkz.SomTv_KdAgenturBeziehung__r.Kunde__c,a);
					}
					else{
						Account a = new Account(id=vkz.SomTv_KdAgenturBeziehung__r.Kunde__c);
						fillAccountVerkaeufer(a,vkz.SomTv_Verkaeuferrolle__c,vkz.SomTv_Verkaeufer__c);
						accMap.put(vkz.SomTv_KdAgenturBeziehung__r.Kunde__c,a);
					}
				}
			}
			for(Account a:accMap.values()){
				lstAccount.add(a);
			}
        }
        if(!lstAccount.isEmpty()){
        	deleteOldAccTeamMember(accIDs,'TV_Kundenverkäufer');
            update lstAccount;

        	if(!insertAccTeamMember.isEmpty()){
                //insert insertAccTeamMember;
                Database.SaveResult[] lsr = Database.insert(insertAccTeamMember,false);

                //Create AccountShare because of read/write access to Account
                list<AccountShare> newShare = new list<AccountShare>();
                Integer newcnt=0;
                for(Database.SaveResult sr:lsr){
                    if(sr.isSuccess()){
                        newShare.add(new AccountShare(UserOrGroupId=insertAccTeamMember[newcnt].UserId, AccountId=insertAccTeamMember[newcnt].Accountid, AccountAccessLevel='Edit',OpportunityAccessLevel='None'));
                    }
                    newcnt++;
                }
                //insert newShare;
                Database.insert(newShare, false);
            }

        }
    }

	/*****************************
    * fill Account User Lookups with verkaeufer IDs depending on role
    *****/
	void fillAccountVerkaeufer(Account a, string roleName,id verkaeuferID){
		if(roleName == 'TV_Kundenverkäufer') a.SOM_TVKundenverkaeufer__c = verkaeuferID;
		if(roleName == 'TV_Einkaufsagenturverkäufer') a.SOM_Einkaufsagenturverkaeufer__c = verkaeuferID;
		if(roleName == 'TV_Planungsagenturverkäufer') a.SOM_Planungsagenturverkaeufer__c = verkaeuferID;
    }

	/*****************************
    * Create AccountTeamMember
    *****/
    private AccountTeamMember populateAccTeamMember(ID accID,ID userID, string roleName){

        //Create new ATM
        AccountTeamMember newATM = new AccountTeamMember();
        newATM.AccountId = accID;
        newATM.TeamMemberRole = roleName;
        newATM.UserId = userID;
        return newATM;
    }

    private void deleteOldAccTeamMember(set<ID> accIDs,string roleName){
		//Delete old ATM TV_Kundenverkäufer
        list<AccountTeamMember> lstOldATM = [SELECT Id FROM AccountTeamMember WHERE AccountId IN :accIDs AND TeamMemberRole = :roleName];
        delete lstOldATM;
    }

    /****************************
	Batch_Finish
	*/
    public void Batch_Finish(){
       // %
    }


    /* BuildSearchString() */
    /********************/
    public String buildSearchString(){
        // build soql search string
		return 'Select s.SomTv_Verkaeuferrolle__c, s.SomTv_Verkaeufer__c, SomTv_KdAgenturBeziehung__r.SomTv_RelevanteBeziehung__c,s.SomTv_KdAgenturBeziehung__r.Kunde__c, s.SomTv_KdAgenturBeziehung__c, s.SomTv_GueltigVon__c, s.SomTv_GueltigBis__c From SomTv_Verkaeuferzuordnung__c s'+
				' where s.SomTv_GueltigVon__c <=TODAY AND (s.SomTv_GueltigBis__c >= TODAY OR s.SomTv_GueltigBis__c = NULL) AND s.SomTv_KdAgenturBeziehung__r.SomTv_RelevanteBeziehung__c = true AND (s.SomTv_Verkaeuferrolle__c = \'TV_Kundenverkäufer\' OR s.SomTv_Verkaeuferrolle__c = \'TV_Einkaufsagenturverkäufer\' OR s.SomTv_Verkaeuferrolle__c = \'TV_Planungsagenturverkäufer\') ORDER BY s.SomTv_KdAgenturBeziehung__r.Kunde__c';
    }

}