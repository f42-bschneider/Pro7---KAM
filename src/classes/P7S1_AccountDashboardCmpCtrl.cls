public without sharing class P7S1_AccountDashboardCmpCtrl {

    private static final String QUEUE_MEDIABOARD = Label.P7S1_AccDash_MediaBoard;
    private static final String FOLDER_LOGOS = Label.P7S1_AccDash_LogoFolder;
    private static final String DEFAULT_LOGO = Label.P7S1_AccDash_DefaultLogo;
    private static final String AA_ACCOUNT_FIELD_ID = Label.P7S1_AccDash_AccAccess_AccFieldId;
    private static final String RECID_AI_AU = Schema.SObjectType.P7S1_AccountAccess__c.getRecordTypeInfosByName().get('Account Übernahme').getRecordTypeId();
    private static final String RECID_AI_AT = Schema.SObjectType.P7S1_AccountAccess__c.getRecordTypeInfosByName().get('Aufnahme ins Account Team').getRecordTypeId();
    private static final String RECID_AI_LI = Schema.SObjectType.P7S1_AccountAccess__c.getRecordTypeInfosByName().get('Logo Integration').getRecordTypeId();
    private static final String PREFIX_AA = P7S1_AccountAccess__c.sObjectType.getDescribe().getKeyPrefix();

    /******************************************************************************************************************************************************
    * Data for Media view
    ************/
    @AuraEnabled
    public static NielsenData getMediaData(String accountId){

        //Current year
        Integer year = Date.today().year();

        //Load Data
        return loadNielsenData(accountId, year);
    }

    /*************************
    * Get Nielsen data from db
    ************/
    private static NielsenData loadNielsenData(String accountId, Integer year){

        //Period start
        Datetime dt = datetime.newInstance(2015,1,1);
        String monthJan = dt.format('MMM');
        String monthEnd = '';

        String yearStr = String.valueOf(year);
        String lastYearStr = String.valueOf(year-1);
        set<String> years = new set<String>{yearStr, lastYearStr};
        set<String> periods = new set<String>{'GJ', 'YTM'};
        map<String, String> mapPeriod2Label = new map<String, String>{yearStr + 'YTM' => Label.P7S1_AccDash_lbl_YTM, lastYearStr + 'YTM' => Label.P7S1_AccDash_lbl_LYTM, lastYearStr + 'GJ' => Label.P7S1_AccDash_lbl_LY};

        String soql = 'SELECT P7S1_Year__c, P7S1_ZeitraumTyp__c, P7S1_MklGruppeTv__c, P7S1_MklGruppeDigital__c, P7S1_MklGruppePrint__c, P7S1_MklGruppeRest__c, P7S1_GesamtMkl__c, ' +
                      '       P7S1_MklSoaTv__c, P7S1_MklSoaDigital__c, P7S1_MklSoaPrint__c, P7S1_MklSoaRest__c, P7S1_Last_Entry_Date__c ' +
                      '  FROM P7S1_NielsenDataAggr__c ' +
                      ' WHERE P7S1_Account__c = \'' + accountId + '\' ' +
                      '   AND P7S1_Year__c IN :years ' +
                      '   AND P7S1_ZeitraumTyp__c IN :periods ' +
                      ' ORDER BY P7S1_Year__c DESC, P7S1_ZeitraumTyp__c DESC';

        Integer cnt = 1;
        list<String> lstCss = new list<String>{'#9FF781', '#A9D0F5', '#F3F781'};
        list<MediaData> lstData = new list<MediaData>();
        for(P7S1_NielsenDataAggr__c nda : Database.query(soql)){
            String key = nda.P7S1_Year__c + nda.P7S1_ZeitraumTyp__c;
            if(mapPeriod2Label.containsKey(key)){

                //Medienklassen
                if(nda.P7S1_GesamtMkl__c != null && nda.P7S1_GesamtMkl__c != 0){
                    lstData.add(new MediaData('TV', mapPeriod2Label.get(key), ((decimalNull(nda.P7S1_MklGruppeTv__c) * 100) / nda.P7S1_GesamtMkl__c).round(), null, lstCss[cnt-1], 10+cnt));
                    lstData.add(new MediaData('Digital', mapPeriod2Label.get(key), ((decimalNull(nda.P7S1_MklGruppeDigital__c) * 100) / nda.P7S1_GesamtMkl__c).round(), null, lstCss[cnt-1], 20+cnt));
                    lstData.add(new MediaData('Print', mapPeriod2Label.get(key), ((decimalNull(nda.P7S1_MklGruppePrint__c) * 100) / nda.P7S1_GesamtMkl__c).round(), null, lstCss[cnt-1], 30+cnt));
                    lstData.add(new MediaData('Rest', mapPeriod2Label.get(key), ((decimalNull(nda.P7S1_MklGruppeRest__c) * 100) / nda.P7S1_GesamtMkl__c).round(), null, lstCss[cnt-1], 40+cnt));
                }

                //SoA
                if(key == yearStr + 'YTM'){
/***
                    if(nda.P7S1_MklGruppeTv__c != null && nda.P7S1_MklGruppeTv__c != 0 ) lstData.add(new MediaData('TV', 'SoA', ((decimalNull(nda.P7S1_MklSoaTv__c) / nda.P7S1_MklGruppeTv__c) * 100).round(), decimalNull(nda.P7S1_MklSoaTv__c), '#F5A9A9',10));
                    if(nda.P7S1_MklGruppeDigital__c != null && nda.P7S1_MklGruppeDigital__c != 0) lstData.add(new MediaData('Digital', 'SoA', ((decimalNull(nda.P7S1_MklSoaDigital__c) / nda.P7S1_MklGruppeDigital__c) * 100).round(), decimalNull(nda.P7S1_MklSoaDigital__c), '#F5A9A9', 20));
                    if(nda.P7S1_MklGruppePrint__c != null && nda.P7S1_MklGruppePrint__c != 0) lstData.add(new MediaData('Print', 'SoA', ((decimalNull(nda.P7S1_MklSoaPrint__c) / nda.P7S1_MklGruppePrint__c) * 100).round(), decimalNull(nda.P7S1_MklSoaPrint__c), '#F5A9A9', 30));
                    if(nda.P7S1_MklGruppeRest__c != null && nda.P7S1_MklGruppeRest__c != 0) lstData.add(new MediaData('Rest', 'SoA', ((decimalNull(nda.P7S1_MklSoaRest__c) / nda.P7S1_MklGruppeRest__c) * 100).round(), decimalNull(nda.P7S1_MklSoaRest__c), '#F5A9A9', 40));
***/
                    if(nda.P7S1_MklGruppeTv__c != null && nda.P7S1_MklGruppeTv__c != 0 ) lstData.add(new MediaData('TV', 'SoA', ((decimalNull(nda.P7S1_MklSoaTv__c) / nda.P7S1_GesamtMkl__c) * 100).round(), decimalNull(nda.P7S1_MklSoaTv__c), '#F5A9A9',10));
                    if(nda.P7S1_MklGruppeDigital__c != null && nda.P7S1_MklGruppeDigital__c != 0) lstData.add(new MediaData('Digital', 'SoA', ((decimalNull(nda.P7S1_MklSoaDigital__c) / nda.P7S1_GesamtMkl__c) * 100).round(), decimalNull(nda.P7S1_MklSoaDigital__c), '#F5A9A9', 20));
                    if(nda.P7S1_MklGruppePrint__c != null && nda.P7S1_MklGruppePrint__c != 0) lstData.add(new MediaData('Print', 'SoA', ((decimalNull(nda.P7S1_MklSoaPrint__c) / nda.P7S1_GesamtMkl__c) * 100).round(), decimalNull(nda.P7S1_MklSoaPrint__c), '#F5A9A9', 30));
                    if(nda.P7S1_MklGruppeRest__c != null && nda.P7S1_MklGruppeRest__c != 0) lstData.add(new MediaData('Rest', 'SoA', ((decimalNull(nda.P7S1_MklSoaRest__c) / nda.P7S1_GesamtMkl__c) * 100).round(), decimalNull(nda.P7S1_MklSoaRest__c), '#F5A9A9', 40));

                    //Period end
                    if(nda.P7S1_Last_Entry_Date__c != null){
                        Date dateEnd = nda.P7S1_Last_Entry_Date__c;
                        dt = datetime.newInstance(dateEnd.year(), dateEnd.month(), dateEnd.day());
                        monthEnd = dt.format('MMM');
                    }
                }
            }
            cnt++;
        }

        //Sort entries
        lstData.sort();

        //Period string
        String header = Label.P7S1_AccDash_lbl_Medienmix;
        String period = '';
        if(monthEnd == '') period = 'n.A.';
        else if(monthEnd == monthJan) period = monthJan + ' ' + year;
        else period = monthJan + ' - ' + monthEnd + ' ' + year;
        header = header.replace('#period#', period);

        return new NielsenData(header, lstData);
    }

    /*************************
    * Check if Decimal is null
    ************/
    private static Decimal decimalNull(Decimal input){
        if(input == null) return 0;
        else return input;
    }

    /*************************
    * Wrapper
    ************/
    public class NielsenData{
        @AuraEnabled
        public String header;
        @AuraEnabled
        public list<MediaData> mediaData;

        public NielsenData(String header, list<MediaData> mediaData){
            this.header     = header;
            this.mediaData  = mediaData;
        }
    }

    public class MediaData implements Comparable{
        @AuraEnabled
        public String media;
        @AuraEnabled
        public String period;
        @AuraEnabled
        public Decimal percent;
        @AuraEnabled
        public Decimal value;
        @AuraEnabled
        public String css;
        @AuraEnabled
        public Integer cnt;

        public MediaData(String media, String period, Decimal percent, Decimal value, String css, Integer cnt){
            this.media      = media;
            this.period     = period;
            this.percent    = percent;
            this.css        = css;
            this.cnt        = cnt;
            this.value      = value;
        }

        //Custom sort
        public Integer compareTo(Object compareTo){
            MediaData other = (MediaData) compareTo;
            Integer returnValue = 0;
            if(cnt > other.cnt){
                returnValue = 1;
            }else if(cnt < other.cnt){
                returnValue = -1;
            }
            return returnValue;
        }
    }

    /******************************************************************************************************************************************************
    * Data for Opportunity view
    ************/
    @AuraEnabled
    public static OppData getOpportunityData(String accountId, Boolean isAccountIndex){

        Boolean showYield = false; //Not needed at this moment - 12.11.15 BS

        //Add data from 71M Digital
        map<String, TableData> mapData = new map<String, TableData>();
        loadOpportunityDataDigital(accountId, mapData);

        //Get data from db other units
        loadOpportunityData(accountId, true, mapData);
        loadOpportunityData(accountId, false, mapData);

        //Sum and calculate values
        Decimal sumOpen = 0;
        Decimal sumClosed = 0;
        list<TableData> lstTable = new list<TableData>();
        for(TableData td : mapData.values()){
            //Special naming for 71M Unit
            if(td.unit == '71M') td.unit = '71M TV';

            //Calculate sums
            sumOpen += td.open;
            sumClosed += td.closed;
            lsttable.add(td);
        }

        /******** not needed - BS 13.11.15
        //Get target From Account
        Decimal target = [SELECT P7S1_Planumsatz__c FROM Account WHERE Id =:accountID LIMIT 1].P7S1_Planumsatz__c;
        if(target == null) target = 0;
        */

        return new OppData(showYield, lstTable, sumClosed, sumOpen, 0);
    }

    /*************************
    * Get Opp data from db
    ************/
    private static void loadOpportunityData(String accId, Boolean open, map<String, TableData> mapData){
/** replaced CloseDate with P7S1_OpportunityDashboardDate__c  **/

        String soql = 'SELECT Owner.P7S1_Unit__c unit, SUM(' + Label.P7S1_AccDash_Amount + ') amount' +
                      '  FROM Opportunity ' +
                      ' WHERE P7S1_OpportunityDashboardDate__c = THIS_YEAR ' +
                      '   AND isClosed = ' + (open ? ' false' : ' true') +
                      (open ? '' : '   AND isWon = true ') +
                      '   AND Account.Id = \'' + accId + '\' ' +
                      ' GROUP BY Owner.P7S1_Unit__c';

        for(AggregateResult ar : Database.query(soql)){
            String key = (String)ar.get('unit');
            Decimal amount = decimalNull((Decimal) ar.get('amount'));
            if(mapData.containsKey(key)){
                if(open) mapData.get(key).open += amount;
                else mapData.get(key).closed += amount;
            }else{
                if(open) mapData.put(key, new TableData(key, 0, amount, 0));
                else mapData.put(key, new TableData(key, amount, 0, 0));
            }
        }
    }

    private static void loadOpportunityDataDigital(String accId, map<String, TableData> mapData){
        Account digitalAcc = [SELECT SomDig_UmsatzGesamtAJ__c, SomDig_PrognoseGesamtAj__c FROM Account WHERE Id = :accId];
        if(digitalAcc != null){
            Decimal digUmsatz = decimalNull(digitalAcc.SomDig_UmsatzGesamtAJ__c)*0.98;
            Decimal digPrognose = decimalNull(digitalAcc.SomDig_PrognoseGesamtAj__c)*0.98;
            Decimal digAbweichung = digPrognose - digUmsatz;
            if(digUmsatz > 0 || digAbweichung > 0){
                mapData.put('71M Digital', new TableData('71M Digital', digUmsatz, digAbweichung, 0));
            }
        }
    }

    /*************************
    * Outer Wrapper
    ************/
    public class OppData{
        @AuraEnabled
        public Boolean showYield;
        @AuraEnabled
        public list<TableData> tableData;
        @AuraEnabled
        public Decimal sumClosed;
        @AuraEnabled
        public Decimal sumOpen;
        @AuraEnabled
        public Decimal target;
        @AuraEnabled
        public Boolean targetReached;

        public OppData(Boolean showYield, list<TableData> tableData, Decimal sumClosed, Decimal sumOpen, Decimal target){
            this.showYield      = showYield;
            this.tableData      = tableData;
            this.sumClosed      = sumClosed;
            this.sumOpen        = sumOpen;
            this.target         = target;
            this.targetReached  = (sumClosed >= target);
        }
    }

    /*************************
    * Inner Wrapper
    ************/
    public class TableData{
        @AuraEnabled
        public String unit;
        @AuraEnabled
        public Decimal closed;
        @AuraEnabled
        public Decimal open;
        @AuraEnabled
        public Decimal yield;

        public TableData(String unit, Decimal closed, Decimal open, Decimal yield){
            this.unit       = unit;
            this.closed     = closed;
            this.open       = open;
            this.yield      = yield;
        }
    }

    /******************************************************************************************************************************************************
    * Data for overview of Account
    ************/

    @AuraEnabled
    public static list<OvData> getOverviewData(String accountId){

        Boolean isAuthorized = userIsAuthorized(accountId);
        Boolean isGerman = (UserInfo.getLanguage() == 'de');

        //Get data out of custom setting
        map<String, OvData> mapAPI2OvData = new map<String, OvData>();
        map<String, OvData> mapAPI2Special = new map<String, OvData>();
        for(P7S1_AccountDashboardFields__c adf : [SELECT Name, P7S1_API_Field_on_Account__c, P7S1_Custom_Label__c, P7S1_Custom_Label_EN__c, P7S1_Order__c, P7S1_Is_Link__c, P7S1_Parent_ID_Field__c, P7S1_Needs_Authorization__c, P7S1_Group__c, P7S1_MA_only__c FROM P7S1_AccountDashboardFields__c ORDER BY P7S1_Order__c]){
            if(adf.Name == 'LastContacted'){
                mapAPI2Special.put(adf.Name, new OvData((isGerman ? adf.P7S1_Custom_Label__c : adf.P7S1_Custom_Label_EN__c), getLastContacted(accountId), adf.P7S1_Is_Link__c, adf.P7S1_Parent_ID_Field__c, (adf.P7S1_Needs_Authorization__c ? isAuthorized : true), adf.P7S1_Order__c, adf.P7S1_Group__c));
            }else if((adf.P7S1_MA_only__c && hasAccess2CustomPermission(UserInfo.getUserId(), 'MA_User')) || !adf.P7S1_MA_only__c ){
                mapAPI2OvData.put(adf.P7S1_API_Field_on_Account__c, new OvData((isGerman ? adf.P7S1_Custom_Label__c : adf.P7S1_Custom_Label_EN__c), null, adf.P7S1_Is_Link__c, adf.P7S1_Parent_ID_Field__c, (adf.P7S1_Needs_Authorization__c ? isAuthorized : true), adf.P7S1_Order__c, adf.P7S1_Group__c));
            }
        }

        String fieldNames = '';
        for(String s : mapAPI2OvData.keySet()){
            fieldNames += (s + ',');
        }

        String soql = 'SELECT ' + fieldNames.substring(0, fieldNames.length()-1) +
                      '  FROM Account ' +
                      ' WHERE Id = \'' + accountId + '\' ';

        //Assign values to fields
        for(Account a : Database.query(soql)){
            for(String key : mapAPI2OvData.keySet()){
                mapAPI2OvData.get(key).value = getValueFromRelation(a, key);
                if(mapAPI2OvData.get(key).isLink){
                    mapAPI2OvData.get(key).linkValue = getValueFromRelation(a, mapAPI2OvData.get(key).linkValue);
                }
                if(mapAPI2OvData.get(key).value == null || mapAPI2OvData.get(key).value == '') mapAPI2OvData.remove(key);
            }
        }

        //Fill list to show in frontend and sort by order
        list<OvData> lstOv = new list<OvData>();
        if(!mapAPI2OvData.isEmpty()){
            lstOv = new list<OvData>(mapAPI2OvData.values());
        }
        if(!mapAPI2Special.isEmpty()){
            lstOv.addAll(mapAPI2Special.values());
        }

        lstOv.sort();
        return lstOv;
    }

    /*************************
    * Get field value from relation
    ************/
    private static String getValueFromRelation(Account a, String relation){

        if(relation == 'AccountTeam') return 'acc/accteammemberlist.jsp?id=' + a.Id;

        String[] elements = relation.split('\\.');
        sObject sobj = a;
        for(Integer i=0; i<elements.size()-1; i++){
            if(sobj.getSObject(elements[i]) == null){
                return '';
            }else{
                sobj = sobj.getSObject(elements[i]);
            }
        }

        if(sobj.get(elements[elements.size()-1]) == null){
            return '';
        }else{
            return (String) sobj.get(elements[elements.size()-1]);
        }
    }

    /*************************
    * Get last contacted
    ************/
    private static String getLastContacted(String accountId){

        String query = 'SELECT ';
        set<String> setFields = new set<String>();

        //Iterate through fields
        for(Schema.FieldSetMember f : getFieldsFromFieldset()) {
            query += f.getFieldPath() + ', ';
            setFields.add(f.getFieldPath());
        }
        query += 'Id, Name FROM Account WHERE Id =:accountId LIMIT 1';

        Account acc = Database.query(query);

        Datetime dt = null;
        for(String field : setFields){
            if(dt == null || (DateTime) acc.get(field) > dt){
                dt = (DateTime) acc.get(field);
            }
        }

        return (dt == null ? '' : dt.format('dd.MM.yyyy HH:mm'));  //AS 2015-12-13
    }

    public static List<Schema.FieldSetMember> getFieldsFromFieldset() {
        return SObjectType.Account.FieldSets.P7S1_Last_Contacted.getFields();
    }

    /*************************
    * Wrapper
    ************/
    public class OvData implements Comparable{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean isLink;
        @AuraEnabled
        public String linkValue;
        @AuraEnabled
        public Boolean showValue;
        @AuraEnabled
        public Decimal showOrder;
        @AuraEnabled
        public Decimal grp;
        @AuraEnabled
        public Boolean endOfGroup;

        public OvData(String label, String value, Boolean isLink, String linkValue, Boolean showValue, Decimal showOrder, Decimal grp){
            this.label      = label;
            this.value      = value;
            this.isLink     = isLink;
            this.linkValue  = linkValue;
            this.showValue  = showValue;
            this.showOrder  = showOrder;
            this.grp        = grp;
            this.endOfGroup = false;
        }

        //Custom sort
        public Integer compareTo(Object compareTo){
            OvData ovData = (OvData) compareTo;
            Integer returnValue = 0;
            if(showOrder > ovData.showOrder){
                returnValue = 1;
            }else if(showOrder < ovData.showOrder){
                returnValue = -1;
            }
            return returnValue;
        }
    }

    /******************************************************************************************************************************************************
    * Helper
    ************/

    /*************************
    * Get current User Data
    ************/
    private static Boolean userIsAuthorized(String accountId){
        //Get User data
        User currentUser = [SELECT Id, P7S1_Unit__c, Profile.Id FROM User WHERE Id =:UserInfo.getUserId()];
        User accUser = [SELECT Id, P7S1_Unit__c FROM User WHERE Id IN (SELECT OwnerId FROM Account WHERE Id =: accountId) LIMIT 1];

        //Get admin profile
        String adminId = Label.ProfileIdAdmin;
        Profile admin = [SELECT Id FROM Profile WHERE Id =:adminId];

        //Get members of Media Board queue
        set<String> mediaBoardMember = new set<String>();
        for(Group grp : [SELECT Id FROM Group WHERE type='Queue' AND Name = :QUEUE_MEDIABOARD LIMIT 1]){
            for(GroupMember gm : [SELECT UserOrGroupId From GroupMember WHERE GroupId = :grp.Id]){
                mediaBoardMember.add(gm.UserOrGroupId);
            }
        }

        //Only users of same unit or owner can see special data
        if(accUser.Id != currentUser.Id && accUser.P7S1_Unit__c != currentUser.P7S1_Unit__c && !mediaBoardMember.contains(currentUser.Id) && currentUser.Profile.Id != admin.Id){
            return false;
        }

        return true;
    }

    /*************************
    * Get logo for unit
    ************/
    private static map<String, String> getLogoForUnit(){
        map<String, String> mapUnit2Logo = new map<String, String>();

        for(Folder folder : [SELECT Id FROM Folder WHERE Name =:FOLDER_LOGOS LIMIT 1]){
            for(Document doc : [SELECT Id, Name FROM Document WHERE FolderId =:folder.Id]){
                mapUnit2Logo.put(doc.Name, doc.Id);
            }
        }

        return mapUnit2Logo;
    }

    /*************************
    * Checks if User has already access to account
    ************/
    @AuraEnabled
    public static AccessData getAccessData(String accountId, String accountIndexId){

        //Check for Account access
        Boolean hasAccess = false;
        for(USerRecordAccess ura : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId =:accountId LIMIT 1]){
            hasAccess = ura.HasReadAccess;
        }

        //Get additional logo naming fields
        map<String, String> mapUnit2Field = getUnit2AdditionalLogoField();
        set<String> setNamingFields = new set<String>(mapUnit2Field.values());

        //Get Account information
        String soql = 'SELECT ' + String.join(new list<String>(setNamingFields), ',') + (setNamingFields.isEmpty() ? '' : ',') + ' Name, Owner.Name, Owner.P7S1_Unit__c, P7S1_Dash_Severity__c, P7S1_Dash_Message__c FROM Account WHERE Id =: accountId LIMIT 1';
        Account acc = Database.query(soql);

        list<String> listUrls = new list<String>();
        if(!hasAccess){
            P7S1_AccountIndex__c accIndex = [SELECT Id, Name FROM P7S1_AccountIndex__c WHERE Id = :accountIndexId LIMIT 1];
            String urlFirst = '/' + PREFIX_AA + '/e?CF' + AA_ACCOUNT_FIELD_ID + '=' + acc.Name + '&' + AA_ACCOUNT_FIELD_ID + '_lkid=' + acc.Id + '&retURL=%2F' + accIndex.Id;
            listUrls.add(urlFirst + '&RecordType=' + RECID_AI_AU + '&Name=' + accIndex.Name + ' - Übernahme');
            listUrls.add(urlFirst + '&RecordType=' + RECID_AI_AT + '&Name=' + accIndex.Name + ' - Team Aufnahme');
            listUrls.add(urlFirst + '&RecordType=' + RECID_AI_LI + '&Name=' + accIndex.Name + ' - Logo Integration');
        }

        //Get Logos
        map<String, String> mapUnit2Logo = getLogoForUnit();

        //Get logo document id
        String unit = DEFAULT_LOGO;

        /************************* NEW - BS 29.02.2016 *************************/
        if(acc.Owner.P7S1_Unit__c != null && acc.Owner.P7S1_Unit__c != ''){
        	if(mapUnit2Field.containsKey(acc.Owner.P7S1_Unit__c)){
        		//Dynamically read rules for naming
        		unit = acc.Owner.P7S1_Unit__c + ' - ' + acc.get(mapUnit2Field.get(acc.Owner.P7S1_Unit__c));
        	}else{
        		//Standard
        		unit = unit = acc.Owner.P7S1_Unit__c;
        	}
        }

        /************************* OLD - BS 29.02.2016 *************************
        //Sonderfall: Bei Unit d&a Sales soll das Cluster-Logo angezeigt werden
        if(acc.Owner.P7S1_Unit__c == 'd&a Sales') {unit = acc.Owner.P7S1_Unit__c + ' - ' + acc.P7S1_DandACluster__c;}
        //Regelfall: Nimm das der Unit zugeordnete Logo
        else if(acc.Owner.P7S1_Unit__c != null && acc.Owner.P7S1_Unit__c != '')  unit = acc.Owner.P7S1_Unit__c;
        */

        String imgId = mapUnit2Logo.containsKey(unit) ? mapUnit2Logo.get(unit) : '';

        //Get units of AccountTeam
        set<String> setTeamUntits = new set<String>();
        for(AccountTeamMember atm : [SELECT User.P7S1_Unit__c FROM AccountTeamMember WHERE AccountId = :accountId AND User.P7S1_Unit__c != :unit]){
            String logoName = atm.User.P7S1_Unit__c + '_sm';
            if(mapUnit2Logo.containsKey(logoName)) setTeamUntits.add(mapUnit2Logo.get(logoName));
        }

        return new AccessData(hasAccess, imgId, acc, new List<String>(setTeamUntits), listUrls);
    }

    /*************************
    * Checks access to Custom Permission
    ************/
    private static map<String,String> getUnit2AdditionalLogoField(){
    	map<String, String> mapUnit2Field = new map<String,String>();
    	for(P7S1_AccDash_Logo_Dependencies__c ld : [SELECT P7S1_Unit__c, P7S1_Logo_Naming_Field__c FROM P7S1_AccDash_Logo_Dependencies__c]){
    		mapUnit2Field.put(ld.P7S1_Unit__c, ld.P7S1_Logo_Naming_Field__c);
    	}
    	return mapUnit2Field;
    }

    /*************************
    * Checks access to Custom Permission
    ************/
    private static Boolean hasAccess2CustomPermission(String user2Check, String permissionDevName){

        list<CustomPermission> lstCPs = [SELECT Id FROM CustomPermission WHERE DeveloperName =:permissionDevName];
        if(lstCPs.isEmpty()) return false;

        set<Id> setCPIds = (new Map<Id,CustomPermission>(lstCPs)).keySet();

        list<SetupEntityAccess> lstAccess = [SELECT SetupEntityId
                               FROM SetupEntityAccess
                            WHERE SetupEntityId IN :setCPIds
                                  AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :user2Check)];

        if(lstAccess.isEmpty()) return false;
        else return true;
    }

    public class AccessData{
        @AuraEnabled
        public Boolean hasAccAccess;
        @AuraEnabled
        public String imgId;
        @AuraEnabled
        public Account acc;
        @AuraEnabled
        public list<String> teamUnits;
        @AuraEnabled
        public list<String> urls;

        public AccessData(Boolean hasAccess, String imgId, Account acc, list<String> teamUnits, list<String> urls){
            this.hasAccAccess   = hasAccess;
            this.imgId          = imgId;
            this.acc            = acc;
            this.teamUnits      = teamUnits;
            this.urls           = urls;
        }
    }
}