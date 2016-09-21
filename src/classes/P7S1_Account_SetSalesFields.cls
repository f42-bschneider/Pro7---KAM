/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_Account_SetSalesFields
* @author:      BS factory42
* @email:       bschneider@factory42.com
* @version:     V0.3
* @date:        Nov 25, 2015 
* @last change: 2015-12-10 AS - add all Accs and delete fields if empty line 91ff
				2016-01-27 VVR CHANGEREQUEST BY TF 27.01.2016: DigitalSales User is wrtitten only by WtAg Trigger
* @description: Set sales fields on Account depending on Account-TeamMemberRoles
* @objects:     Account, P7S1_AccountAccess__c, P7S1_OpportunityApproval__c
* =================================================================
*/
public without sharing class P7S1_Account_SetSalesFields {
    
    public static Boolean runTwice = false;
    public static final String FILTER_UNIT = '71M';
    
    /****************************
    * Filter Account Ids from Accounts
    ***/
    public static void getAccIdsFromAccount(list<Account> lstAcc){
		// Changerequest 02.2016 by TF: Starting from Account disabled. Only new SalesTeamOrganizer 
		IF(Test.isRunningTest()) {
	        set<String> setAccIds = new set<String>();
	        for(Account acc : lstAcc){
	            if((acc.P7S1_Unit__c == FILTER_UNIT) ||(acc.P7S1_Unit__c != FILTER_UNIT)) {
	                setAccIds.add(acc.Id);
	            }
	        }
	        setAccountSalesFields(setAccIds);
		}
    }
    
    /****************************
    * Filter Account Ids from P7S1_AccountAccess__c
    ***/
    public static void getAccIdsFromAccountAccess(list<P7S1_AccountAccess__c> lstAA){
        set<String> setAccIds = new set<String>();
        for(P7S1_AccountAccess__c aa : lstAA){
            if((aa.P7S1_AccountOwnerUnit__c == FILTER_UNIT) || (aa.P7S1_AccountOwnerUnit__c != FILTER_UNIT)){
                setAccIds.add(aa.P7S1_Account__c);
            }
        }
        setAccountSalesFields(setAccIds);
    }
    
    /****************************
    * Filter Account Ids from P7S1_OpportunityApproval__c
    ***/
    public static void getAccIdsFromOpportunityApproval(list<P7S1_OpportunityApproval__c> lstOA){
        set<String> setAccIds = new set<String>();
        set<String> setOppIds = new set<String>();
        
        for(P7S1_OpportunityApproval__c oa : lstOA){
            if((oa.P7S1_AccountOwnerUnit__c == FILTER_UNIT) || (oa.P7S1_AccountOwnerUnit__c != FILTER_UNIT)){
                setOppIds.add(oa.P7S1_Opportunity__c);
            }
        }
        
        for(Opportunity opp : [SELECT AccountId FROM Opportunity WHERE Id IN :setOppIds]){
            setAccIds.add(opp.AccountId);
        }
        setAccountSalesFields(setAccIds);
    }
    
    /****************************
    * Set sales fields on Account
    ***/
    public static void setAccountSalesFields(set<String> setAccIds){
        
        if(!setAccIds.isEmpty() && !runTwice && Test.isRunningTest()){
            
            //Mapping TeamMemberRole to sales field
            map<String, String> mapRole2Field = new map<String, String>();
            mapRole2Field.put('TV_Kundenverkäufer', 'SOM_TVKundenverkaeufer__c');
            mapRole2Field.put('TV_Einkaufsagenturverkäufer', 'SOM_Einkaufsagenturverkaeufer__c');
            mapRole2Field.put('TV_Planungsagenturverkäufer', 'SOM_Planungsagenturverkaeufer__c');
            /** CHANGEREQUEST BY TF 27.01.2016: DigitalSales User is wrtitten only by WtAg Trigger
            mapRole2Field.put('Digital_Sales', 'SOM_DigitalSales__c');
            **/
            
            //Get AccountTeamMembers to Account
            map<String,list<AccountTeamMember>> mapAcc2ATM = new map<String,list<AccountTeamMember>>(); 
            for(AccountTeamMember atm : [SELECT AccountId, TeamMemberRole, UserId FROM AccountTeamMember WHERE AccountId IN :setAccIds AND TeamMemberRole IN :mapRole2Field.keySet()]){
                if(mapAcc2ATM.containsKey(atm.AccountId)){
                    mapAcc2ATM.get(atm.AccountId).add(atm);
                }else{
                    mapAcc2ATM.put(atm.AccountId, new list<AccountTeamMember>{atm});
                }
            }
            
            //Select Accounts and fill sales fields
            list<Account> lstUpdate = new list<Account>();
//            for(Account acc : [SELECT Id, SOM_TVKundenverkaeufer__c, SOM_Einkaufsagenturverkaeufer__c, SOM_Planungsagenturverkaeufer__c, SOM_DigitalSales__c FROM Account WHERE Id IN :mapAcc2ATM.keySet()]){
            for(Account acc : [SELECT Id, SOM_TVKundenverkaeufer__c, SOM_Einkaufsagenturverkaeufer__c, SOM_Planungsagenturverkaeufer__c, SOM_DigitalSales__c FROM Account WHERE Id IN :setAccIds]){
                acc.SOM_TVKundenverkaeufer__c = null;
                acc.SOM_Einkaufsagenturverkaeufer__c = null;
                acc.SOM_Planungsagenturverkaeufer__c = null;
                /** CHANGEREQUEST BY TF 27.01.2016: DigitalSales User is wrtitten only by WtAg Trigger
                acc.SOM_DigitalSales__c = null;
                **/
                if (mapAcc2ATM.containsKey(acc.ID)){
                    for(AccountTeamMember atm : mapAcc2ATM.get(acc.Id)){
                        acc.put(mapRole2Field.get(atm.TeamMemberRole), atm.UserId);
                    }
                }
                lstUpdate.add(acc);
            }

            runTwice = true;
            if(!lstUpdate.isEmpty()) update lstUpdate;
            
        }
    }
    
}