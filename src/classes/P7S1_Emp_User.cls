public with sharing class P7S1_Emp_User{

    /*
     * Sync user based on Mitarbeiter/Emp object
     */

    // Queueable Teil kann nicht im Test ausgeführt werden.
    public static Boolean i_bIsTest = false;

    // aus Rollenname Id ermitteln
    private static Map<String,Id> i_oMapRoles = new Map<String,Id>();

    // Änderungen an User, die mit Queueable durchgeführt werden müssen (IsActive, ProfileId)
    private static Map<Id,User> i_oMapUserQueue = new Map<Id,User>();

    public static void syncInsert(List<P7S1_Emp__c> newEmpList) {
        // beim Insert soll KEIN Sync erfolgen, auch nicht indirekt mit nachgelagertem Update!
        for (P7S1_Emp__c emp : newEmpList) {
            emp.P7S1_Sync__c = false;
        }
    }
    
    public static void setName(List<P7S1_Emp__c> newEmpList) {
        // on insert, set name with format '<firstname> <lastname> (<firmaname>)'
        for (P7S1_Emp__c emp : newEmpList) {
            emp.Name = getFormattedName(emp);
        }
    }
    
    public static String getFormattedName(P7S1_Emp__c emp) {
        String formattedName = emp.P7S1_Firstname__c + ' ' + emp.P7S1_Lastname__c + ' (' + emp.P7S1_CompName__c + ')';
        return formattedName.left(80);
    }


    public static void sync(Map<Id, P7S1_Emp__c> newEmpMap) {
        String l_sSandbox = cls_P7S1_Utils.getSandboxName(true);

        system.debug('### Sync EmpIds: ' + newEmpMap.keyset());

        for (UserRole l_oRole : [SELECT Id, DeveloperName FROM UserRole]) {
        i_oMapRoles.put(l_oRole.DeveloperName, l_oRole.Id);
    }

        // convert Username and EMail to LowerCase (same behavior as on User-Object)
        for (P7S1_Emp__c emp : newEmpMap.values()) {
            if (emp.P7S1_Username__c != null) {
                emp.P7S1_Username__c = emp.P7S1_Username__c.toLowerCase();
                emp.P7S1_Email__c = emp.P7S1_Email__c.toLowerCase();
            }
        }


        Map<Id, P7S1_Emp__c> empMap = new Map<Id, P7S1_Emp__c>();
        Set<String> l_sSetUsernames = new Set<String>();

        // Only proceed if 'Sync' checkbox on emp is true and emp has a username
        for (P7S1_Emp__c emp : newEmpMap.values()) {
            if (emp.P7S1_Sync__c && emp.P7S1_Username__c != null) {
                empMap.put(emp.Id, emp);
                l_sSetUsernames.add(emp.P7S1_Username__c + l_sSandbox);
                system.debug('### Username: ' + emp.P7S1_Username__c);
            }
        }
        system.debug('### l_sSetUsernames: ' + l_sSetUsernames);

        if (!empMap.isEmpty()) {
            // Initialize lists which will be used later to insert/update users
            List<User> usersToInsert = new List<User>();
            List<User> usersToUpdate = new List<User>();

            // Build a map of usernames and corresponding users
            Map<String, List<User>> l_oMapUsernameUser = new Map<String, List<User>>();
            for (P7S1_Emp__c emp : empMap.values()) {
                l_oMapUsernameUser.put(emp.P7S1_Username__c + l_sSandbox, new List<User>());
            }
            for (User usr : [SELECT Username FROM User WHERE Username IN :l_sSetUsernames]) {
            system.debug('### Found User: ' + usr.Username);
            l_oMapUsernameUser.get(usr.Username).add(usr);
        }

            // Iterate all emps and get the list of users with the emp's usernames
            for (Id empId : empMap.keySet()) {
                P7S1_Emp__c l_oEmp = empMap.get(empId);
                List<User> usersForEmp = l_oMapUsernameUser.get(l_oEmp.P7S1_Username__c + l_sSandbox);

                // If there is no user with the emp's username, create a new one with the P7S1_Emp__c lookup and core data fields
                if (usersForEmp.isEmpty()) {
                    if (l_oEmp.P7S1_Lastname__c != null) {
                        User l_oUsr = new User();
                        fillValues(l_oUsr, l_oEmp, true, l_sSandbox);
                        usersToInsert.add(l_oUsr);
                    }

                    // If there are users with the emp's username: set P7S1_Emp__c lookup and transfer core data fields
                } else {
                    for (User l_oUsr : usersForEmp) {
                        fillValues(l_oUsr, l_oEmp, false, l_sSandbox);
                        usersToUpdate.add(l_oUsr);
                    }
                }
            }

            // Insert/update users where applicable
            if (!usersToInsert.isEmpty()) {
                Database.DMLOptions dlo = new Database.DMLOptions();
                dlo.EmailHeader.triggerUserEmail = true;
                database.insert(usersToInsert, dlo);
                //insert usersToInsert;
            }

            if (!usersToUpdate.isEmpty()) update usersToUpdate;

            // Set P7S1_User__c on all emp datasets
            usersToInsert.addAll(usersToUpdate);
            for (User usr : usersToInsert) {
                newEmpMap.get(usr.P7S1_Emp__c).P7S1_User__c = usr.Id;
            }

            }

        P7S1_Emp_UserQueue l_oQueue = new P7S1_Emp_UserQueue();
        l_oQueue.i_oMapUserQueue = i_oMapUserQueue;


        if (!i_bIsTest) {
            ID jobID = System.enqueueJob(l_oQueue);
        }

        }

    private static void fillValues (User p_oUsr, P7S1_Emp__c p_oEmp, Boolean p_bInsert, String p_sSandbox){
        System.Debug('+++++fillValues');         
    
        String l_sAlias;
        User l_oUserQueue = new User();
        l_oUserQueue.Id = p_oUsr.Id;
        l_oUserQueue.IsActive = p_oEmp.P7S1_IsActive__c;
        l_oUserQueue.ProfileId = cls_P7S1_Utils.getProfileId(p_oEmp.P7S1_Profile__c);
        l_oUserQueue.UserRoleId = i_oMapRoles.get(p_oEmp.P7S1_Role__c);
        i_oMapUserQueue.put(p_oUsr.Id, l_oUserQueue);

        // values, only for Insert
        if ( p_bInsert) {
            p_oUsr.TimeZoneSidKey = 'Europe/Berlin';
            p_oUsr.LocaleSidKey = 'de_DE';
            p_oUsr.LanguageLocaleKey = 'de';

            l_sAlias = (p_oEmp.P7S1_LastName__c + 'xx').left(2);
            l_sAlias += (p_oEmp.P7S1_FirstName__c + 'xx').left(2);
            p_oUsr.Alias = l_sAlias;
            p_oUsr.ProfileId = cls_P7S1_Utils.getProfileId(p_oEmp.P7S1_Profile__c);
            //p_oUsr.UserRoleId = i_oMapRoles.get(p_oEmp.P7S1_Role__c);
            p_oUsr.Email = p_oEmp.P7S1_Email__c;
        }

        p_oUsr.Username = p_oEmp.P7S1_Username__c + p_sSandbox;
        p_oUsr.P7S1_Emp__c = p_oEmp.Id;
        p_oUsr.FirstName = p_oEmp.P7S1_Firstname__c;
        p_oUsr.LastName = p_oEmp.P7S1_Lastname__c;

        p_oUsr.CompanyName = p_oEmp.P7S1_CompName__c;
        p_oUsr.ProRexId__c= p_oEmp.P7S1_EmpNo__c;
        p_oUsr.P7S1_Unit__c = p_oEmp.P7S1_Unit__c == '- No Unit -' ? null : p_oEmp.P7S1_Unit__c;        

        //p_oUsr.CommunityNickname = p_oEmp.; //TODO

        p_oUsr.P7S1_Sphere__c = p_oEmp.P7S1_Sphere__c;
        p_oUsr.EmailEncodingKey = 'UTF-8';

        p_oUsr.UserPermissionsMarketingUser = true;
        
        

        
        List<P7S1_Emp__c> listManager = new List<P7S1_Emp__c>([SELECT P7S1_User__c, P7S1_User__r.IsActive FROM P7S1_Emp__c WHERE ID = :p_oEmp.P7S1_Manager__c]);
        if(!listManager.isEmpty() && listManager[0].P7S1_User__r.IsActive){
            p_oUsr.ManagerId = listManager[0].P7S1_User__c;
        }else if(p_oEmp.P7S1_Manager__c == null || (!listManager.isEmpty() && !listManager[0].P7S1_User__r.IsActive))
            p_oUsr.ManagerId = null;



    }
}