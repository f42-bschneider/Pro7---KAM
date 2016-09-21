public with sharing class P7S1_TestdatageneratorAtmWtAg {
	static Final string WTNAME = 'Werbetreibender';
	static Final string AGNAME = 'Agentur';

	public static Account generateTestData(){
		Account wt = new Account();
        List<Account> accList = new List<Account>();
        List<SomDig_WtAgBeziehung__c> wtagList = new List<SomDig_WtAgBeziehung__c>();
        List<SomDig_Prognose__c> progList = new List<SomDig_Prognose__c>();
        List<SomDig_Umsatz__c> umsList = new List<SomDig_Umsatz__c>();

        //Create MediaGattung for Umsatz
		SomDig_Mediagattung__c m = new SomDig_Mediagattung__c();
		m.Name = 'Digital';
		insert m;

        // Agentur Accounts
        Account a_Agentur = cls_P7S1_TestData.createTestAccount(false);
        a_Agentur.name = AGNAME+'1';
        accList.add(a_Agentur);
        Account a_Agentur2 = cls_P7S1_TestData.createTestAccount(false);
        a_Agentur2.name = AGNAME+'2';
        accList.add(a_Agentur2);
        Account a_Agentur3 = cls_P7S1_TestData.createTestAccount(false);
        a_Agentur3.name = AGNAME+'3';
        accList.add(a_Agentur3);
        Account a_Agentur4 = cls_P7S1_TestData.createTestAccount(false);
        a_Agentur4.name = AGNAME+'4';
        accList.add(a_Agentur4);

        // Werbetreibende Accounts
        Account a_Werbetreibender = cls_P7S1_TestData.createTestAccount(false);
        a_Werbetreibender.name = WTNAME;
        accList.add(a_Werbetreibender);
        Account a_Werbetreibender2 = cls_P7S1_TestData.createTestAccount(false);
        a_Werbetreibender2.name = WTNAME+'2';
        accList.add(a_Werbetreibender2);
        Account a_WerbetreibenderDel = cls_P7S1_TestData.createTestAccount(false);
        a_WerbetreibenderDel.name = WTNAME+'Del';
        accList.add(a_WerbetreibenderDel);
        insert acclist;

        //Set WT Account for asserts
        wt = a_Werbetreibender;

        //WtAg Beziehungen
        SomDig_WtAgBeziehung__c wtag = cls_P7S1_TestData.createTestWTAG(false, a_Werbetreibender, a_Agentur);
        wtag.SomDig_BeziehungInhaber__c = Userinfo.getUserID();
        SomDig_WtAgBeziehung__c wtag2 = cls_P7S1_TestData.createTestWTAG(false, a_Werbetreibender, a_Agentur2);
        wtag2.SomDig_BeziehungInhaber__c = Userinfo.getUserID();
        SomDig_WtAgBeziehung__c wtag3 = cls_P7S1_TestData.createTestWTAG(false, a_Werbetreibender, a_Agentur3);
        wtag3.SomDig_BeziehungInhaber__c = Userinfo.getUserID();
        SomDig_WtAgBeziehung__c wtag4 = cls_P7S1_TestData.createTestWTAG(false, a_Werbetreibender, a_Agentur4);
        wtag4.SomDig_BeziehungInhaber__c = Userinfo.getUserID();
        SomDig_WtAgBeziehung__c wtag5 = cls_P7S1_TestData.createTestWTAG(false, a_Werbetreibender2, a_Agentur4);
        wtag4.SomDig_BeziehungInhaber__c = Userinfo.getUserID();
        wtagList.add(wtag);
        wtagList.add(wtag2);
        wtagList.add(wtag3);
        wtagList.add(wtag4);
        wtagList.add(wtag5);
        insert wtagList;

        //Prognose
		progList.add(populatePrognose(wtag.id,10));
		progList.add(populatePrognose(wtag2.id,5));
        progList.add(populatePrognose(wtag3.id,25));
        progList.add(populatePrognose(wtag4.id,20));
        progList.add(populatePrognose(wtag5.id,30));
        insert progList;

        //Umsatz
        for(integer i=1; i<5;i++){
			umsList.add(populateUmsatz(wtag.id,10,''+i,m.id));
			umsList.add(populateUmsatz(wtag2.id,5,''+i,m.id));
	        umsList.add(populateUmsatz(wtag3.id,25,''+i,m.id));
	        umsList.add(populateUmsatz(wtag4.id,20,''+i,m.id));
	        umsList.add(populateUmsatz(wtag4.id,20,''+i,m.id));
        }

        insert umsList;

        //update to start trigger for aggregate Results again
        update  wtagList;

		AccountTeamMember atm = new AccountTeamMember();
		atm.AccountId = wt.id;
		atm.UserId = Userinfo.getUserID();
		atm.TeamMemberRole = 'Digital_Sales';
		insert atm;
		update wt;

        delete a_WerbetreibenderDel;
        return wt;
	}

	static SomDig_Prognose__c populatePrognose(ID wtagID, integer proValue){
		SomDig_Prognose__c pro = new SomDig_Prognose__c();
		pro.SomDig_Jahr__c = ''+System.today().year();
        pro.SomDig_PrognoseQ1__c = proValue;
        pro.SomDig_PrognoseQ2__c = proValue;
        pro.SomDig_PrognoseQ3__c = proValue;
        pro.SomDig_PrognoseQ4__c = proValue;
        pro.SomDig_MedDiffInStream__c = 4*proValue;
        pro.SomDig_WtAgBeziehung__c = wtagID;
        return pro;
	}

	static SomDig_Umsatz__c populateUmsatz(ID wtagID, integer umsValue,string quartal, ID mediaGattung){
		SomDig_Umsatz__c ums = new SomDig_Umsatz__c();
		ums.SomDig_Jahr__c = ''+System.today().year();
        ums.SomDig_Mn2__c = umsValue;
        ums.SomDig_Mediagattung__c = mediaGattung;
        ums.SomDig_RelativesJahr__c = 'AJ';
        ums.SomDig_Quartal__c = quartal;
        ums.SomDig_WtAgBeziehung__c = wtagID;
        return ums;
	}
}