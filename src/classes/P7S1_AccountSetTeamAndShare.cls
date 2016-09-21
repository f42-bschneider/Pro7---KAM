/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_AccountSetTeamAndShare
* @author:      BS factory42
* @email:       bschneider@factory42.com
* @version:     V0.1
* @date:        2015/11/09
* @last change: AS - changed AccountTeam member role name line 121
* @description: Remove AccountTeam members and AccountShare and set new ones called by AccountAccess trigger
* @objects:     P7S1_AccountAccess__c, AccountTeamMember, AccountShare
* =================================================================
*/
public without sharing class P7S1_AccountSetTeamAndShare {

    public static String RECTYPE_ACC_UEBERNAHME = Schema.SObjectType.P7S1_AccountAccess__c.getRecordTypeInfosByName().get('Account Übernahme').getRecordTypeId();
    public static String RECTYPE_AUFNAHME_ACC_TEAM = Schema.SObjectType.P7S1_AccountAccess__c.getRecordTypeInfosByName().get('Aufnahme ins Account Team').getRecordTypeId();

    static Map<String, P7S1_UnitRoleMapping__c> UNIT_ROLE_MAPPING = P7S1_UnitRoleMapping__c.getAll();

    public static String getRoleForUnit(String unit) {
        String role_prefix = unit;
        for (P7S1_UnitRoleMapping__c mapping : UNIT_ROLE_MAPPING.values()) {
            if (mapping.P7S1_Unit__c == unit) {
                role_prefix = mapping.P7S1_RolePrefix__c;
            }
        }
        return role_prefix;
    }

    /**********************
    * Filter by RecordType and call actions
    ***/
    public static void filterRecords(list<P7S1_AccountAccess__c> lstNew){

        list<P7S1_AccountAccess__c> lstUebernahme = new list<P7S1_AccountAccess__c>();
        list<P7S1_AccountAccess__c> lstAufnahme = new list<P7S1_AccountAccess__c>();

        for(P7S1_AccountAccess__c aa : lstNew){
            if(aa.RecordTypeId == RECTYPE_ACC_UEBERNAHME && aa.P7S1_IsApproved__c){
                lstUebernahme.add(aa);
            }else if(aa.RecordTypeId == RECTYPE_AUFNAHME_ACC_TEAM && aa.P7S1_IsApproved__c){
                lstAufnahme.add(aa);
            }
        }

        if(!lstUebernahme.isEmpty()){
            removeTeamAndShare(lstUebernahme);
        }

        if(!lstAufnahme.isEmpty()){
            addToTeamAndShare(lstAufnahme);
        }

    }

    /**********************
    * Remove AccountTeams and AccountShare and set Owner
    ***/
    private static void removeTeamAndShare(list<P7S1_AccountAccess__c> lstIn){

        //Collect AccountIds
        set<String> setAccIds = new set<String>();
        for(P7S1_AccountAccess__c aa : lstIn){
            setAccIds.add(aa.P7S1_Account__c);
        }

        //**************** Get Accounts with current Owner Units
        map<String, Account> mapId2Account = new map<String, Account>([SELECT Id, OwnerId, Owner.P7S1_Unit__c FROM Account WHERE Id IN :setAccIds]);

        //Get AccountTeamMember to remove
        list<AccountTeamMember> lstRemoveATM = new list<AccountTeamMember>();
        for(AccountTeamMember atm : [SELECT AccountId, UserId, User.P7S1_Unit__c FROM AccountTeamMember WHERE AccountId IN :mapId2Account.keySet()]){
            if(mapId2Account.containsKey(atm.AccountId) && mapId2Account.get(atm.AccountId).Owner.P7S1_Unit__c == atm.User.P7S1_Unit__c){
                lstRemoveATM.add(atm);
            }
        }

        if(!lstRemoveATM.isEmpty()){
            delete lstRemoveATM;
        }

        //**************** Get AccountShare to remove
        map<String, AccountShare> mapUserId2AccShare = new map<String, AccountShare>();
        set<String> setUserIds = new set<String>();
        for(AccountShare accs : [SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId IN :mapId2Account.keySet() AND RowCause NOT IN ('Owner','Rule','ImplicitParent')]){
            mapUserId2AccShare.put(accs.UserOrGroupId, accs);
            setUserIds.add(accs.UserOrGroupId);
        }

        list<AccountShare> lstRemoveAccShare = new list<AccountShare>();
        for(User u: [SELECT Id, P7S1_Unit__c FROM User WHERE Id IN :setUserIds]){
            if(mapUserId2AccShare.containsKey(u.Id) && mapId2Account.containsKey(mapUserId2AccShare.get(u.Id).AccountId)  && u.P7S1_Unit__c == mapId2Account.get(mapUserId2AccShare.get(u.Id).AccountId).Owner.P7S1_Unit__c){
                lstRemoveAccShare.add(mapUserId2AccShare.get(u.Id));
            }
        }

        if(!lstRemoveAccShare.isEmpty()){
            delete lstRemoveAccShare;
        }

        //**************** Set new Account Owner
        for(P7S1_AccountAccess__c aa : lstIn){
            if(mapId2Account.containsKey(aa.P7S1_Account__c)){
                mapId2Account.get(aa.P7S1_Account__c).OwnerId = aa.OwnerId;
            }
        }
        update mapId2Account.values();
    }

    /**********************
    * Add P7S1_AccountAccess__c Owner ro AccountTeam and Unit members to AccountShare
    ***/
    private static void addToTeamAndShare(list<P7S1_AccountAccess__c> lstIn){

        //Collect Owner of AccountAccess
        set<String> setUserIds = new set<String>();
        set<String> setAccIds = new set<String>();
        for(P7S1_AccountAccess__c aa : lstIn){
            setUserIds.add(aa.OwnerId);
            setAccIds.add(aa.P7S1_Account__c);
        }

        //Get Unit to User
        map<String, User> mapId2User = new map<String, User>([SELECT Id, P7S1_Unit__c FROM User WHERE Id IN :setUserIds AND isActive = true]);

        //**************** Create new AccountTeamMember
        list<AccountTeamMember> lstNewAccTeamMember = new list<AccountTeamMember>();
        for(P7S1_AccountAccess__c aa : lstIn){
            if(mapId2User.containsKey(aa.OwnerID)){
                AccountTeamMember atm = new AccountTeamMember(AccountId = aa.P7S1_Account__c,
                                                              UserId = aa.OwnerId,
                                                              TeamMemberRole = mapId2User.get(aa.OwnerId).P7S1_Unit__c);
                lstNewAccTeamMember.add(atm);
            }
        }

        if(!lstNewAccTeamMember.isEmpty()){
            insert lstNewAccTeamMember;
        }

        //Reset AccessLevels of created AccountShares
        list<AccountShare> lstUpdateAccShare = new list<AccountShare>();
        for(AccountShare accShare : [SELECT AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel FROM AccountShare WHERE UserOrGroupId IN :setUserIds AND AccountId IN :setAccIds]){
            accShare.AccountAccessLevel = 'Edit';
            accShare.ContactAccessLevel = 'Read';
            accShare.CaseAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'Read';
            lstUpdateAccShare.add(accShare);
        }

        if(!lstUpdateAccShare.isEmpty()){
            update lstUpdateAccShare;
        }

        /**************** Create new AccountShare entries -  JM/BS 01.04.2016 Not needed any more
        set<String> setRoles = new set<String>();
        for(User u : mapId2User.values()){
            setRoles.add(getRoleForUnit(u.P7S1_Unit__c) + '_Steering');
            setRoles.add(getRoleForUnit(u.P7S1_Unit__c) + '_Controlling');
        }

        //Get all needed Roles
        map<String, UserRole> mapId2Role = new map<String, UserRole>([SELECT DeveloperName, Id from UserRole WHERE DeveloperName IN :setRoles]);

        //Get all Users to specific Role
        map<String, set<User>> mapRole2Users = new map<String, set<User>>();
        for(User u : [SELECT Id, UserRole.DeveloperName FROM User WHERE IsActive = true AND UserRoleId IN :mapId2Role.keySet()]){
            if(mapRole2Users.containsKey(u.UserRole.DeveloperName)){
                mapRole2Users.get(u.UserRole.DeveloperName).add(u);
            }else{
                mapRole2Users.put(u.UserRole.DeveloperName, new set<User>{u});
            }
        }

        //Create new AccountShares
        list<AccountShare> lstNewAccShare = new list<AccountShare>();
        for(P7S1_AccountAccess__c aa : lstIn){
            if(mapId2User.containsKey(aa.OwnerId)){
                set<String> setRoleNames = new set<String>{getRoleForUnit(mapId2User.get(aa.OwnerId).P7S1_Unit__c) + '_Steering',
                                                           getRoleForUnit(mapId2User.get(aa.OwnerId).P7S1_Unit__c) + '_Controlling'};
                for(String role : setRoleNames){
                    if(mapRole2Users.containsKey(role)){
                        for(User u : mapRole2Users.get(role)){
                            AccountShare accShare = new AccountShare(AccountId = aa.P7S1_Account__c,
                                                                     AccountAccessLevel = 'Edit',
                                                                     CaseAccessLevel = 'Read',
                                                                     ContactAccessLevel = 'Read',
                                                                     OpportunityAccessLevel = 'Read',
                                                                     RowCause = 'Manual',
                                                                     UserOrGroupId = u.Id);
                            lstNewAccShare.add(accShare);
                        }
                    }
                }
            }
        }

        if(!lstNewAccShare.isEmpty()){
            insert lstNewAccShare;
        }
        ***********JM/BS 01.04.2016 Not needed any more*************/
    }

    /**********************
    * Add P7S1_AccountAccess__c Owner ro AccountTeam and Unit members to AccountShare - OLD METHODS - NEVER USED => Set AccShare depending on Role hirarchie
    ***
    private static void addToTeamAndShare(list<P7S1_AccountAccess__c> lstIn){

        //Collect Owner of AccountAccess
        set<String> setUserIds = new set<String>();
        set<String> setAccIds = new set<String>();
        for(P7S1_AccountAccess__c aa : lstIn){
            setUserIds.add(aa.OwnerId);
            setAccIds.add(aa.P7S1_Account__c);
        }

        //Get Unit to User
        map<String, User> mapId2User = new map<String, User>([SELECT Id, Name, P7S1_Unit__c FROM User WHERE Id IN :setUserIds AND isActive = true]);

        //**************** Create new AccountTeamMember
        list<AccountTeamMember> lstNewAccTeamMember = new list<AccountTeamMember>();
        for(P7S1_AccountAccess__c aa : lstIn){
            if(mapId2User.containsKey(aa.OwnerID)){
                AccountTeamMember atm = new AccountTeamMember(AccountId = aa.P7S1_Account__c,
                                                              UserId = aa.OwnerId,
                                                              TeamMemberRole = mapId2User.get(aa.OwnerId).P7S1_Unit__c); //Removed prefix "+ ' Sales' " - BS 18.03.2016
                lstNewAccTeamMember.add(atm);
            }
        }

        if(!lstNewAccTeamMember.isEmpty()){
            insert lstNewAccTeamMember;
        }

        //Reset AccessLevels of created AccountShares
        list<AccountShare> lstUpdateAccShare = new list<AccountShare>();
        for(AccountShare accShare : [SELECT AccountAccessLevel, ContactAccessLevel, CaseAccessLevel, OpportunityAccessLevel FROM AccountShare WHERE UserOrGroupId IN :setUserIds AND AccountId IN :setAccIds]){
            accShare.AccountAccessLevel = 'Edit';
            accShare.ContactAccessLevel = 'Read';
            accShare.CaseAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'Read';
            lstUpdateAccShare.add(accShare);
        }

        if(!lstUpdateAccShare.isEmpty()){
            update lstUpdateAccShare;
        }

        //**************** Create new AccountShare entries ****************
        set<String> setRoleNames = new set<String>();
        for(User u : mapId2User.values()){
            setRoleNames.add(getRoleForUnit(u.P7S1_Unit__c));
        }

        //Get Ids for parent roles
        map<String,set<String>> mapRoleName2RoleIds = new map<String, set<String>>();
        for(UserRole ur : [SELECT Id, DeveloperName from UserRole WHERE DeveloperName IN :setRoleNames]){
            mapRoleName2RoleIds.put(ur.DeveloperName.toLowerCase(), new set<String>{ur.Id});
        }

        //Get all child role Ids
        set<String> setAllRoleIds = new set<String>();
        for(String roleName : mapRoleName2RoleIds.keySet()){
            mapRoleName2RoleIds.get(roleName).addAll(getAllSubRoleIds(mapRoleName2RoleIds.get(roleName)));
            setAllRoleIds.addAll(mapRoleName2RoleIds.get(roleName));
        }

        //Get all Users to specific Role
        map<String, set<User>> mapRole2Users = new map<String, set<User>>();
        for(User u : [SELECT Id, Name, UserRoleId, UserRole.DeveloperName FROM User WHERE IsActive = true AND UserRoleId IN :setAllRoleIds]){
            if(mapRole2Users.containsKey(u.UserRoleId)){
                mapRole2Users.get(u.UserRoleId).add(u);
            }else{
                mapRole2Users.put(u.UserRoleId, new set<User>{u});
            }
        }

        //Create new AccountShares
        list<AccountShare> lstNewAccShare = new list<AccountShare>();

        for(P7S1_AccountAccess__c aa : lstIn){

            if(mapId2User.containsKey(aa.OwnerId)){

                String roleName = getRoleForUnit(mapId2User.get(aa.OwnerId).P7S1_Unit__c).toLowerCase();

                if(mapRoleName2RoleIds.containsKey(roleName)){
                    for(String roleId : mapRoleName2RoleIds.get(roleName)){

                        if(mapRole2Users.containsKey(roleId)){
                            for(User u : mapRole2Users.get(roleId)){

                                AccountShare accShare = new AccountShare(AccountId = aa.P7S1_Account__c,
                                                                     AccountAccessLevel = 'Edit',
                                                                     CaseAccessLevel = 'Read',
                                                                     ContactAccessLevel = 'Read',
                                                                     OpportunityAccessLevel = 'Read',
                                                                     RowCause = 'Manual',
                                                                     UserOrGroupId = u.Id);
                                lstNewAccShare.add(accShare);
                            }
                        }

                    }
                }

            }
        }

        if(!lstNewAccShare.isEmpty()){
            insert lstNewAccShare;
        }

    }
    */

    /**********************
    * Get all sub role ids - OLD METHODS - NEVER USED => Set AccShare depending on Role hirarchie
    ***
    private static set<String> getAllSubRoleIds(set<String> roleIds) {
        set<String> currentRoleIds = new set<String>();

        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select DeveloperName, Id from UserRole where ParentRoleID IN :roleIds AND ParentRoleID != null]) {
            currentRoleIds.add(userRole.Id);
        }

        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }

        return currentRoleIds;
    }
    */


}