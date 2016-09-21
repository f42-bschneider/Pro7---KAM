public with sharing class Som_Kontaktbericht_Trigger {

    // Method to create Kontaktbericht Teilnehmer from selected Contact and Owner ON INSERT
    public static void InsertTn(Map<Id, Som_Kontaktbericht__c> kbs) {
        // get ContactIds for related Users
        Set<Id> userIds = new Set<Id>();
        for (Som_Kontaktbericht__c kb : kbs.values()) {
            userIds.add(kb.OwnerId);
        }
        Map<Id,Id> UserConMap = getUserConMap(userIds);
        // create Teilnehmer list to insert in db
        List<Som_KontaktberichtContact__c> tnlist = new List<Som_KontaktberichtContact__c>();
        for (Id kbid : kbs.keySet()) {
            Som_Kontaktbericht__c kb = kbs.get(kbid);

            // create Teilnehmer for related Contact
            Som_KontaktberichtContact__c tnc = new Som_KontaktberichtContact__c();
            tnc.Som_Contact__c = kb.Som_Contact__c;
            tnc.Som_Kontaktbericht__c = kb.Id;
            tnlist.add(tnc);

            // create Teilnehmer for Owner (Creator) of the Kontaktbericht (only when it's not the same contact as above)
            Id contactId = UserConMap.get(kb.OwnerId);
            if (contactId != null && contactId != kb.Som_Contact__c) {
                Som_KontaktberichtContact__c tno = new Som_KontaktberichtContact__c();
                tno.Som_Contact__c = contactId;
                tno.Som_Kontaktbericht__c = kb.Id;
                tnlist.add(tno);
            }
        }
        if (!tnlist.IsEmpty()) insert tnlist;
    }

    // Method to caluclate Max Date for each Type and every Division
    public static void UpdateKBdates(Set<Id> sobj_ids, string vartype) {
        Set<Id> acc_ids = new Set<Id>();
        Set<Id> kbids = new Set<Id>();
        if (vartype == 'acc') {
            acc_ids = sobj_ids;
        }
        else {
            for (Som_Kontaktbericht__c kb : [Select Som_Account__c from Som_Kontaktbericht__c where Id in :sobj_ids]) {
                acc_ids.add(kb.Som_Account__c);
            }
        }
    
        // get all Kontaktbericht from affected Accounts and store in List for each account
        Map<Id,List<Som_Kontaktbericht__c>> AccKbMap = new Map<Id,List<Som_Kontaktbericht__c>>();
        for (Som_Kontaktbericht__c kb : [Select Id, Som_Account__c, Som_Datum__c, Som_GrundDesKontakts__c from Som_Kontaktbericht__c where Som_Account__c in :acc_ids order by Som_Account__c]) {
            List<Som_Kontaktbericht__c> kblist = new List<Som_Kontaktbericht__c>();
            if (AccKbMap.containsKey(kb.Som_Account__c)) kblist = AccKbMap.get(kb.Som_Account__c);
            kblist.add(kb);
            AccKbMap.put(kb.Som_Account__c, kblist);
            kbids.add(kb.id);
        }
        
        
        System.debug('** UpdateKBdates AccKbMap: ' +AccKbMap);
        System.debug('** UpdateKBdates kbids: ' +kbids);
        
        // get relevant Divisions for each KB
        Map<Id,Set<String>> KbDivMap = getKbDivMap(kbids);

        // get Accounts with actual Dates and update Max dates if changed
        List<Account> updatelist = new List<Account>();
        for (Account a : [Select Id,
                            Som_AdF_LetzterPersoenlicherTermin__c, Som_AdF_LetzterTelefonTermin__c, Som_AdF_LetzterVeranstaltungsTermin__c,
                            Som_DIG_LetzterPersoenlicherTermin__c, Som_DIG_LetzterTelefonTermin__c, Som_DIG_LetzterVeranstaltungsTermin__c,
                            Som_TV_LetzterPersoenlicherTermin__c, Som_TV_LetzterTelefonTermin__c, Som_TV_LetzterVeranstaltungsTermin__c,
                            Som_AT_LetzterPersoenlicherTermin__c, Som_AT_LetzterTelefonTermin__c, Som_AT_LetzterVeranstaltungsTermin__c
                                from Account where Id in :acc_ids]) {
            // define variables for each account
            Datetime adf_per, adf_tel, adf_ver,
                     dig_per, dig_tel, dig_ver,
                     tv_per,  tv_tel,  tv_ver,
                     at_per,  at_tel,  at_ver;
                                    
            if (AccKbMap.get(a.Id) != null) {
                
                // assign date from Kontaktbericht to variables for all relevant divisions and types
                for (Som_Kontaktbericht__c kb : AccKbMap.get(a.Id)) {
                    
                    // check if relevant TN is available
                    if (KbDivMap.containsKey(kb.Id)) {
                        
                        Set<String> divset = KbDivMap.get(kb.Id);
                        if (kb.Som_GrundDesKontakts__c == 'persönlicher Termin') {
                            if (divset.contains('AdFactory') && (adf_per == null || adf_per < kb.Som_Datum__c)) adf_per = kb.Som_Datum__c;
                            if (divset.contains('Digital')   && (dig_per == null || dig_per < kb.Som_Datum__c)) dig_per = kb.Som_Datum__c;
                            if (divset.contains('TV')        && (tv_per  == null || tv_per  < kb.Som_Datum__c)) tv_per  = kb.Som_Datum__c;
                            if (divset.contains('AT')        && (at_per  == null || at_per  < kb.Som_Datum__c)) at_per  = kb.Som_Datum__c;
                        }
                        else if (kb.Som_GrundDesKontakts__c == 'Telefonat') {
                            if (divset.contains('AdFactory') && (adf_tel == null || adf_tel < kb.Som_Datum__c)) adf_tel = kb.Som_Datum__c;
                            if (divset.contains('Digital')   && (dig_tel == null || dig_tel < kb.Som_Datum__c)) dig_tel = kb.Som_Datum__c;
                            if (divset.contains('TV')        && (tv_tel  == null || tv_tel  < kb.Som_Datum__c)) tv_tel  = kb.Som_Datum__c;
                            if (divset.contains('AT')        && (at_tel  == null || at_tel  < kb.Som_Datum__c)) at_tel  = kb.Som_Datum__c;
                        }
                        else if (kb.Som_GrundDesKontakts__c == 'Veranstaltung/Messe') {
                            if (divset.contains('AdFactory') && (adf_ver == null || adf_ver < kb.Som_Datum__c)) adf_ver = kb.Som_Datum__c;
                            if (divset.contains('Digital')   && (dig_ver == null || dig_ver < kb.Som_Datum__c)) dig_ver = kb.Som_Datum__c;
                            if (divset.contains('TV')        && (tv_ver  == null || tv_ver  < kb.Som_Datum__c)) tv_ver  = kb.Som_Datum__c;
                            if (divset.contains('AT')        && (at_ver  == null || at_ver  < kb.Som_Datum__c)) at_ver  = kb.Som_Datum__c;
                        }
                    }
                }
            }

            // update Accountfields if changes are necessary
            if (adf_per != a.Som_AdF_LetzterPersoenlicherTermin__c || adf_tel != a.Som_AdF_LetzterTelefonTermin__c || adf_ver != a.Som_AdF_LetzterVeranstaltungsTermin__c ||
                dig_per != a.Som_DIG_LetzterPersoenlicherTermin__c || dig_tel != a.Som_DIG_LetzterTelefonTermin__c || dig_ver != a.Som_DIG_LetzterVeranstaltungsTermin__c ||
                tv_per  != a.Som_TV_LetzterPersoenlicherTermin__c  || tv_tel  != a.Som_TV_LetzterTelefonTermin__c  || tv_ver  != a.Som_TV_LetzterVeranstaltungsTermin__c  ||
                at_per  != a.Som_AT_LetzterPersoenlicherTermin__c  || at_tel  != a.Som_AT_LetzterTelefonTermin__c  || at_ver  != a.Som_AT_LetzterVeranstaltungsTermin__c) {
                a.Som_AdF_LetzterPersoenlicherTermin__c   = adf_per;
                a.Som_AdF_LetzterTelefonTermin__c         = adf_tel;
                a.Som_AdF_LetzterVeranstaltungsTermin__c  = adf_ver;
                a.Som_DIG_LetzterPersoenlicherTermin__c   = dig_per;
                a.Som_DIG_LetzterTelefonTermin__c         = dig_tel;
                a.Som_DIG_LetzterVeranstaltungsTermin__c  = dig_ver;
                a.Som_TV_LetzterPersoenlicherTermin__c    = tv_per ;
                a.Som_TV_LetzterTelefonTermin__c          = tv_tel ;
                a.Som_TV_LetzterVeranstaltungsTermin__c   = tv_ver ;
                a.Som_AT_LetzterPersoenlicherTermin__c    = at_per ;
                a.Som_AT_LetzterTelefonTermin__c          = at_tel ;
                a.Som_AT_LetzterVeranstaltungsTermin__c   = at_ver ;
                updatelist.add(a);
            }
        }
        if (!updatelist.isEmpty()) update updatelist;
    }

    // create Map of UserId with corresponding ContactId
    static Map<Id,Id> getUserConMap(Set<Id> userIds) {
        Map<Id,Id> UserConMap = new Map<Id,Id>();
        for (P7S1_Emp__c e : [Select Id, P7S1_Contact__c, P7S1_User__c from P7S1_Emp__c where P7S1_User__c in :userIds]) {
            UserConMap.put(e.P7S1_User__c, e.P7S1_Contact__c);
        }
        return UserConMap;
    }

    // create Map with Set of Divisions for each Kontaktbericht depending on Teilnehmer
    static Map<Id,Set<String>> getKbDivMap(Set<Id> kbids) {
        
        Map<Id,Set<String>> KbDivMap = new Map<Id,Set<String>>();
        
        for (Som_KontaktberichtContact__c tn : [Select Id, Som_Contact__c, Som_Contact__r.Som_KontaktberichtTeilnehmerVon__c, Som_Kontaktbericht__c 
            from Som_KontaktberichtContact__c 
            where Som_Kontaktbericht__c in :kbids order by Som_Kontaktbericht__c LIMIT 10000]) {
        
            Set<String> divset = KbDivMap.containsKey(tn.Som_Kontaktbericht__c) ? KbDivMap.get(tn.Som_Kontaktbericht__c) : new Set<String>();
            
            System.debug('** UpdateKBdates tn.Som_Contact__r.Som_KontaktberichtTeilnehmerVon__c: ' +tn.Som_Contact__r.Som_KontaktberichtTeilnehmerVon__c);
            
            if (tn.Som_Contact__r.Som_KontaktberichtTeilnehmerVon__c != null) {
                divset.add(tn.Som_Contact__r.Som_KontaktberichtTeilnehmerVon__c);
            }
            
            KbDivMap.put(tn.Som_Kontaktbericht__c, divset);
        }
        return KbDivMap;
    }
}