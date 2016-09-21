/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_WtAgBeziehung_DigitalOwner.cls
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.1
* @ date        20.01.2016
* @description
* @last change
* @objects      Account, SomDig_WtAgBeziehung__c
* =================================================================
*/
public without sharing class P7S1_WtAgBeziehung_DigitalOwner extends TriggerController {


    /**
    * Methodname    P7S1_WtAgBeziehung_DigitalOwner
    * @description  Constructor
    * @param        Trigger based values
    * @return       -
    */
    public P7S1_WtAgBeziehung_DigitalOwner(Boolean isAfter, Boolean isBefore,
        Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

   /**
    * Methodname    runAfterInsert
    * @description  Call upsert method after insert
    * @param        -
    * @return       void
    */
    protected override void runAfterInsert() {
        writeDigitalOwner(lstNewItems);
    }

    /**
    * Methodname    runAfterUpdate
    * @description  Call upsert method after insert
    * @param        -
    * @return       void
    */
    protected override void runAfterUpdate() {
    	writeDigitalOwner(lstNewItems);
    }

    /**
    * Methodname    runAfterDelete
    * @description  Call delete method after delete
    * @param        -
    * @return       void
    */
    protected override void runAfterDelete() {
        writeDigitalOwner(lstOldItems);
    }

     /**
    * Methodname    writeDigitalOwner
    * @description  Calculate Aggregate Result
    * @param        List<sObject>
    * @return       void
    */
	static void writeDigitalOwner(List<sObject> lstItems){
		set<ID> activeUserIDs = new set<ID>();
		set<ID> accIDs = new set<ID>();
		List<Account> updAccList = new List<Account>();
		List<AccountTeamMember> atmList = new List<AccountTeamMember>();

		for (User u:[select id from user where isactive = true]){
			activeUserIDs.add(u.id);
		}

        for(sObject o : lstItems){
            SomDig_WtAgBeziehung__c wtag = (SomDig_WtAgBeziehung__c)o;
            accIDs.add(wtag.SomDig_Werbetreibender__c);
        }

		map<string,string> accountUserMap = aggregateResultMap(accIDs);
		for(string s:accountUserMap.keyset()){
			if(activeUserIDs.contains(accountUserMap.get(s))) updAccList.add(new Account(id=s,SOM_DigitalSales__c = accountUserMap.get(s)));
		}
		for(Account a:updAccList){
			atmList.add(populateAccountTeamMember(a.id,a.SOM_DigitalSales__c));
		}

		if(Test.isRunningTest()) deleteOldAccTeamMember(accIDs,'Digital_Sales');
		update updAccList;
                        //insert atmList;
                        Database.SaveResult[] lsr = Database.insert(atmList,false);

                        //Create AccountShare because of read/write access to Account
                        list<AccountShare> newShare = new list<AccountShare>();
                        Integer newcnt=0;
                        for(Database.SaveResult sr:lsr){
                            if(sr.isSuccess()){
                                newShare.add(new AccountShare(UserOrGroupId=atmList[newcnt].UserId, AccountId=atmList[newcnt].Accountid, AccountAccessLevel='Edit',OpportunityAccessLevel='None'));
                            }
                            newcnt++;
                        }
                        Database.insert(newShare, false);
	}


   /**
    * Methodname    aggregateResultMap
    * @description  get aggregateResults for WtAg
    * @param        set<ID>
    * @return       map<string,string>
    */
	static map<string,string> aggregateResultMap(set<ID> accIDs){
		map<string,string> accountUserMap = new map<string,string>();
		list<AggregateResult>groupedResults = new list<AggregateResult>();
		groupedResults= [SELECT P7S1_GroupedId__c, SUM(SomDig_PrognoseGesamtAj__c),SUM(SomDig_UmsatzGesamtAj__c) FROM SomDig_WtAgBeziehung__c  where SomDig_Werbetreibender__c in :accIDs and P7S1_GroupedId__c !=NULL AND P7S1_GroupedId__c !='' GROUP BY P7S1_GroupedId__c];
		string AccID = '';
		decimal lastSumPrognose = 0;
		decimal lastSumUmsatz = 0;
		decimal maxValue = -1;
		for (AggregateResult ar : groupedResults){
			string groupID = (string)ar.get('P7S1_GroupedId__c');
			if(AccID != groupID.left(15)){
				maxValue = -1;
			}
			if(maxValue < (decimal)ar.get('expr0') || maxValue < (decimal)ar.get('expr1')){
				if(AccID == ''){
					AccID = groupID.left(15);
				}
				if(AccID != groupID.left(15)){
					AccID = groupID.left(15);
					lastSumPrognose = 0;
					lastSumUmsatz = 0;
				}

				if(AccID == groupID.left(15) && (lastSumPrognose <= (decimal)ar.get('expr0') || lastSumUmsatz <= (decimal)ar.get('expr1')) ){
					lastSumPrognose = (decimal)ar.get('expr0');
					lastSumUmsatz = (decimal)ar.get('expr1');
					accountUserMap.put(''+groupID.left(15),''+groupID.right(15));
				}
				if((decimal)ar.get('expr0') <(decimal)ar.get('expr1')){
					maxValue = (decimal)ar.get('expr1');
				}
				else{
					maxValue = (decimal)ar.get('expr0');
				}
			}
		}
		return 	accountUserMap;
	}

   /**
    * Methodname    populateAccountTeamMember
    * @description  populate AccountTeamMember for Account
    * @param        ID,ID
    * @return       AccountTeamMember
    */
	static AccountTeamMember populateAccountTeamMember(ID accID,ID userID){
		AccountTeamMember atm = new AccountTeamMember();
		atm.AccountId = accID;
		atm.UserId = userID;
		atm.TeamMemberRole = 'Digital_Sales';
		return atm;
	}

   /**
    * Methodname    deleteOldAccTeamMember
    * @description  populatedeleteOldAccTeamMember AccountTeamMember for Account
    * @param        ID,string
    * @return       void
    */
    static void deleteOldAccTeamMember(set<ID> accIDs,string roleName){
		//Delete old ATM
        list<AccountTeamMember> lstOldATM = [SELECT Id FROM AccountTeamMember WHERE AccountId IN :accIDs AND TeamMemberRole = :roleName];
        delete lstOldATM;
    }
}