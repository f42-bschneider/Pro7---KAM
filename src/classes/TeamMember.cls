/**
* Handle Account and Opportunity TeamMember lifecycle
* @author stefan.voss@advendio.com
**/
global without sharing class TeamMember implements Database.Batchable<SObject>, Schedulable{


  public static final Set<String> AUTOMATED_SOM_TV_ATM_ROLES	= new Set<String>{'Leadverkäufer','Planununsagenturverkäufer','Kundenverkäufer','Einkaufsagenturverkäufer'};

  Map<String, Batch> batchTypByName;
  public static final String BATCH_SOMTV_UPDATE_ACCOUNT_TEAM_MEMBER	= 'SomTv AccountTeamMemberUpdate';
  public Batch selectedBatch	= null;

  public TeamMember() {
    batchTypByName	= new Map<String, Batch>();

    Batch tvATM_Update			= new Batch();
    tvATM_Update.name			= BATCH_SOMTV_UPDATE_ACCOUNT_TEAM_MEMBER;
    tvATM_Update.baseQuery		= 'select Id from Account';
    tvATM_Update.whereClause	= '';
    tvATM_Update.batchSize		= 100;
    batchTypByName.put(BATCH_SOMTV_UPDATE_ACCOUNT_TEAM_MEMBER, tvATM_Update);
  }

  /**
  * Batching and Scheduling
  **/
  /* Global Parameter */

  public void chooseBatch(String batchName) {
    selectedBatch	= batchTypByName.get(batchName);
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(selectedBatch.getQuery());
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope){

    if (selectedBatch.name.equals(BATCH_SOMTV_UPDATE_ACCOUNT_TEAM_MEMBER)) {
      somTv_AccountTeamMemberUpdate((List<Account>) scope);
    }
  }

  global void finish(Database.BatchableContext bc){}

  // Scheduler
  global void execute(SchedulableContext sc) {
    // run AccountTeamMember Update
    TeamMember tm	= new TeamMember();
    tm.chooseBatch(TeamMember.BATCH_SOMTV_UPDATE_ACCOUNT_TEAM_MEMBER);

    Database.executeBatch(tm, tm.selectedBatch.batchSize);

  }

  public void startBatch(String batchName, String whereClause) {
    chooseBatch(batchName);
    if (whereClause != null) {
      selectedBatch.whereClause	= whereClause;
    }
    if (!Test.isRunningTest()) {
      Database.executeBatch(this, selectedBatch.batchSize);
    }
  }

  public List<AccountTeamMember> getExistingAccountTeamMember(Set<Id> accIds) {
    try {
      return [select Id, AccountId, UserId from AccountTeamMember where AccountId IN : accIds and TeamMemberRole IN :AUTOMATED_SOM_TV_ATM_ROLES];
    }
    catch(Exception e) {
      return new List<AccountTeamMember>();
    }
  }

  public void somTv_AccountTeamMemberUpdate(Set<Id> accIds) {

    Map<Id, Map<Id, SomTv_Verkaeuferzuordnung__c>> validVKZs	= new Map<Id, Map<Id, SomTv_Verkaeuferzuordnung__c>>();
    for (SomTv_Verkaeuferzuordnung__c vkz : [select  Id, SomTv_Verkaeufer__c, SomTv_Verkaeuferrolle__c,
                             SomTv_KdAgenturBeziehung__r.Kunde__c, SomTv_KdAgenturBeziehung__r.Agentur__c
                          from SomTv_Verkaeuferzuordnung__c where (SomTv_KdAgenturBeziehung__r.Kunde__c IN : accIds
                                            or SomTv_KdAgenturBeziehung__r.Agentur__c IN : accIds)
                                            and SomTv_GueltigVon__c <= TODAY
                                            and (SomTv_GueltigBis__c >= TODAY or SomTv_GueltigBis__c = null)
                                            and SomTv_Verkaeufer__r.IsActive = true]) {

      if (!validVKZs.containsKey(vkz.SomTv_KdAgenturBeziehung__r.Kunde__c)) {
        validVKZs.put(vkz.SomTv_KdAgenturBeziehung__r.Kunde__c, new Map<Id, SomTv_Verkaeuferzuordnung__c>());
      }
      if (!validVKZs.containsKey(vkz.SomTv_KdAgenturBeziehung__r.Agentur__c)) {
        validVKZs.put(vkz.SomTv_KdAgenturBeziehung__r.Agentur__c, new Map<Id, SomTv_Verkaeuferzuordnung__c>());
      }

      validVKZs.get(vkz.SomTv_KdAgenturBeziehung__r.Kunde__c).put(vkz.SomTv_Verkaeufer__c, vkz);
      validVKZs.get(vkz.SomTv_KdAgenturBeziehung__r.Agentur__c).put(vkz.SomTv_Verkaeufer__c, vkz);

    }
    validVKZs.remove(null);

    system.debug(validVKZs);

    List<AccountTeamMember> atmToDelete	= new List<AccountTeamMember>();
    Map<Id, Set<Id>> existingATM	= new Map<Id, Set<Id>>();

    for (AccountTeamMember atm : getExistingAccountTeamMember(accIds)) {
      system.debug(atm);
      if (validVKZs.isEmpty() || (!validVKZs.containsKey(atm.AccountId) || (validVKZs.containsKey(atm.AccountId) && !validVKZs.get(atm.AccountId).containsKey(atm.UserId)))) {
        atmToDelete.add(atm);
      }
      else {
        if (!existingATM.containsKey(atm.AccountId)) {
          existingATM.put(atm.AccountId, new Set<Id>());
        }
        existingATM.get(atm.AccountId).add(atm.UserId);
      }
    }

    List<AccountTeamMember> atmToInsert	= new List<AccountTeamMember>();
    for (Id accId : validVKZs.keySet()) {
      for (Id userId : validVKZs.get(accId).keySet()) {
        if (!existingATM.containsKey(accId) || (existingATM.containsKey(accId) && !existingATM.get(accId).contains(userId))) {
          atmToInsert.add(new AccountTeamMember(AccountId=accId, UserId=userId, TeamMemberRole=validVKZs.get(accId).get(userId).SomTv_Verkaeuferrolle__c));
        }
      }
    }

    if (!atmToDelete.isEmpty()) {
      delete atmToDelete;
    }
    if (!atmToInsert.isEmpty()) {
      insert atmToInsert;
    }
  }

  private void somTv_AccountTeamMemberUpdate(List<Account> accs) {
    Set<Id> accIds	= new Set<Id>();
    for (Account acc : accs) {
      accIds.add(acc.Id);
    }

    somTv_AccountTeamMemberUpdate(accIds);
  }

  @isTest
  public static void testValidation() {
    Account kunde	= new Account(Name='TestKunde', ProRex_Rolle__c='Kunde', SomTv_HilfsfeldProRexRolle__c='Kunde');
    Account agentur	= new Account(Name='TestAgentur', ProRex_Rolle__c='Agentur', SomTv_HilfsfeldProRexRolle__c='Agentur');
    insert new List<Account>{kunde, agentur};

    SomTV_KundeAgenturBeziehung__c kaBez1	= new SomTV_KundeAgenturBeziehung__c(Kunde__c=kunde.Id, GueltigVon__c=system.today(), GueltigBis__c=system.today()+2);
    SomTV_KundeAgenturBeziehung__c kaBez2	= new SomTV_KundeAgenturBeziehung__c(Kunde__c=kunde.Id, Agentur__c=agentur.Id, GueltigVon__c=system.today(), GueltigBis__c=system.today()+2);
    insert new List<SomTV_KundeAgenturBeziehung__c>{kaBez1, kaBez2};
    SomTv_Verkaeuferzuordnung__c vkz1	= new SomTv_Verkaeuferzuordnung__c(SomTv_KdAgenturBeziehung__c=kaBez1.Id, SomTv_Verkaeufer__c=Userinfo.getUserId(), SomTv_Verkaeuferrolle__c='Leadverkäufer', SomTv_GueltigVon__c=system.today(), SomTv_GueltigBis__c=system.today()+2);
    SomTv_Verkaeuferzuordnung__c vkz2	= new SomTv_Verkaeuferzuordnung__c(SomTv_KdAgenturBeziehung__c=kaBez2.Id, SomTv_Verkaeufer__c=Userinfo.getUserId(), SomTv_Verkaeuferrolle__c='Leadverkäufer', SomTv_GueltigVon__c=system.today(), SomTv_GueltigBis__c=system.today()+2);

    insert new List<SomTv_Verkaeuferzuordnung__c>{vkz1, vkz2};

    TeamMember tm	= new TeamMember();
    Map<Id, Set<Id>> invalidUser;

    // Test 1
    system.debug('#### TEST 1 #####');
    tm.somTv_AccountTeamMemberUpdate(new List<Account>{kunde});
    List<AccountTeamMember> atms1	= tm.getExistingAccountTeamMember(new Set<Id>{kunde.Id});
    system.assertEquals(1, atms1.size());

    // Test 2
    system.debug('#### TEST 2 #####');
    tm.somTv_AccountTeamMemberUpdate(new List<Account>{agentur});
    List<AccountTeamMember> atms2	= tm.getExistingAccountTeamMember(new Set<Id>{agentur.Id});
    system.assertEquals(1, atms2.size());

    // Test 3
    system.debug('#### TEST 3 #####');
    tm.somTv_AccountTeamMemberUpdate(new List<Account>{kunde, agentur});
    List<AccountTeamMember> atms3	= tm.getExistingAccountTeamMember(new Set<Id>{kunde.Id, agentur.Id});
    system.assertEquals(2, atms3.size());

    // Test 4
    system.debug('#### TEST 4 #####');
    delete vkz1;
    tm.somTv_AccountTeamMemberUpdate(new List<Account>{kunde, agentur});
    List<AccountTeamMember> atms4	= tm.getExistingAccountTeamMember(new Set<Id>{kunde.Id, agentur.Id});
    system.assertEquals(2, atms4.size());

    // Test 5
    system.debug('#### TEST 5 #####');
    delete vkz2;
    tm.somTv_AccountTeamMemberUpdate(new List<Account>{agentur});
    List<AccountTeamMember> atms5	= tm.getExistingAccountTeamMember(new Set<Id>{agentur.Id});
    system.assertEquals(0, atms5.size());

    // Test 6
    tm.startBatch(TeamMember.BATCH_SOMTV_UPDATE_ACCOUNT_TEAM_MEMBER, null);
  }
}