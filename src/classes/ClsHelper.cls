public with sharing class ClsHelper {

    /** ##################################################################################
    ######################################################################################
    SHARE (SomTv und Ven)
    ######################################################################################
    */

    public static final Boolean isSandboxOrgFlag;
    static {
        // final Id sandboxOrgId = '00DM00000011YYA'; // = SomTvTest
        //final Id sandboxOrgId = '00DM0000001Xhn4MAC'; // = SevenVentures-Dev-Sandbox
        final Id sandboxOrgId = '00DM000000143n4'; // = SomTvSst-Sandbox
        isSandboxOrgFlag = UserInfo.getOrganizationId() == sandboxOrgId ; // Don't try to inline "sandboxOrgId". with cast to (Id) it will result in an error, without the cast it is error prone to id15 vs id18
    }



    /** Test with SeeAllData=true you need to take precautions if an account with this name already exists,
    which would make the test fail!

    Examples:
    Account acc = newTestAccount(System.UserInfo.getUserId(), 'Test account 1');
    Account acc = newTestAccount(insertTestUser().id, 'Test account 1');
    insert acc;
    */
    public static Account newTestAccount(ID userId, final String name) {
        Account acc = new Account();
        acc.Name = name;
        acc.OwnerId=userId;
        acc.BillingStreet='12345';
        acc.BillingCity='Test';
        acc.Phone='12456796';
        acc.BillingCountry='test';
        acc.BillingPostalCode='134697';
        acc.BillingState='test';

        return acc; // It is better to return the object instead of an ID in order to enable the user to update the object with more values.
    }


    /** ##################################################################################
    ######################################################################################
    Ven
    ######################################################################################
    */

    /**
     * Get the string presentation of a integer number based on given locale.
     * @param    value    Integer value to format.
     * @param    locale    Locale to use. If not defined, the current user locale is used.
     * @return    The formatted string.
     */
    public static String formatInteger(Integer value, String locale) {
        if (value == null) return null;

        Boolean    isNegative = false;

        String s = String.valueOf(value).trim();
        if (s.startsWith('-')) {
            s = s.substring(1, s.length());
            isNegative = true;
        }

        String    ts = '.';

        String    tmp;
        Integer    i = 3;

        while (s.length() > i) {
            tmp = s.substring(0, s.length() - i) + ts + s.substring(s.length() - i);
            s = tmp;
            i += 4;
        }

        if (isNegative) s = '-' + s;

        return s;
    }

    /**
     * Get the string presentation of a decimal number based on given locale.
     * @param    value        Decimal value to use.
     * @param    scale        Scale to use. If set to null or 0, value will be formatted as Integer.
     * @param    locale        Locale to use. If not defined, the current user locale is used.
     * @return    The formatted string.
     */
    public static String formatDecimal(Decimal value, Integer scale, String locale) {
        if (value == null) return null;

       // String s = formatInteger(value.intValue(), locale);
        Integer sInt = (value.intValue());


        if (sInt == null || scale == null || scale <= 0) {
            return formatInteger(sInt, locale);
        }

        Boolean    isNegative = value < 0 ? true : false;

        Decimal    fraction = Math.abs(value - (isNegative == true ? Math.ceil(value) : Math.floor(value)));
        String    tmp = fraction.setScale(scale, System.Roundingmode.HALF_UP).toPlainString();
        Integer    idx = tmp.indexOf('.');

        if (idx > 0) {
            String sTmp = tmp.substring(0, idx);

            if (isNegative) {
                sTmp = '-' + sTmp;
            }

            sInt = sInt + Integer.valueOf(sTmp);

            tmp = tmp.substring(idx+1);
        }

        return formatInteger(sInt, locale) + ',' + tmp;
    }


    public static Id queryMedialeistungsVertragsRecordTypeId() {
        return [SELECT id FROM RecordType WHERE name='Medialeistungsvertrag (inkl. EP Light)' LIMIT 1].get(0).id;
    }

    public static Ven_Vertrag_SevenVentures__c insertVertrag(Id oppId, Id recordTypeIdParam) {

        Ven_Vertrag_SevenVentures__c vertrag = new Ven_Vertrag_SevenVentures__c(
            Ven_Opportunity__c=oppId
            , RecordTypeId=recordTypeIdParam
            , Ven_Contract_Status__c='Signed'
            , Service_Level__c='Bronze'
        );

        System.assertNotEquals(null,ClsHelper.queryMedialeistungsVertragsRecordTypeId(), 'RecordTypeId==null!');
        insert vertrag;
        System.debug('Vertrags-Id=='+vertrag.id);
        return vertrag;
    }

    /** insert test objects in exec anon:
    * testClassInstance.insertTerms(InvestmentSummaryController.testClassInstance.vertragsId);
    */
    public static void insertTerms(Id vertragsId) {

        // Delete all terms of the vertrag
        for (List<Ven_Contract_Terms__c> o : [SELECT id FROM Ven_Contract_Terms__c WHERE Ven_Vertrag_SevenVentures__c=:vertragsId] ) {
            delete o;
        }

        Ven_Contract_Terms__c[] ctList = newTermListWithAllStandardTerms(vertragsId);

        // Mark every second term as not gültig
        for (Integer i = 0; i<ctList.size() ; i+=2 ) {
            ctList[i].Ven_G_ltig__c = false;
            ctList[i].Ven_Kommentar_warum_nicht_g_ltig__c = 'Bsp Wert in Ven_Kommentar_warum_nicht_g_ltig__c';
            ctList[i].Ven_Abweichender_Term__c = 'Bspwert in Ven_Abweichender_Term__c';
        }

        insert ctList;
    }

    /**
     * Include all standard terms into the contract.
     */
    public static Ven_Contract_Terms__c[] newTermListWithAllStandardTerms(Id vertragsId) {

        Ven_Standart_Terms__c[] stList = [SELECT id FROM Ven_Standart_Terms__c];

        Ven_Contract_Terms__c[] ctList = new List<Ven_Contract_Terms__c>();
        for (Ven_Standart_Terms__c st: stList) {
            Ven_Contract_Terms__c ct = new Ven_Contract_Terms__c(
                Ven_Standard_Term_kurz__c = st.id
                ,Ven_Vertrag_SevenVentures__c = vertragsId
                ,Ven_G_ltig__c = true
            );

            ctList.add(ct);
        }
        return ctList;
    }

    public static void deleteAndInsert(final String fieldToMatch, final String typeName, final SObject newSObject) {
        for (List<SObject> o : Database.query('SELECT id FROM '+typeName+' WHERE '+fieldToMatch+'=\''+newSObject.get(fieldToMatch)+'\'')) {
            delete o;
        }

        insert newSObject;
    }

    public static String nullToEmptyString(String input) {
        return input == null ? '' : input;
    }

    @isTest
    static void testNullToEmptyString() {
        System.assertEquals('',nullToEmptyString(null));
        System.assertEquals('Sarah',nullToEmptyString('Sarah'));
    }

    public static Decimal nulltoZero(Decimal d) {
        return d==null ? 0.0 : d;
    }

    @isTest
    static void testNulltoZero() {
        System.assertEquals(0.0,nulltoZero(null));
        System.assertEquals(5.0,nulltoZero(5.0));
    }


    public static String newStringWithSeparators(final List<SObject> theList, String fieldName, String separator) {
        String str = '';
        for (SObject currentSObject: theList) {
            str += currentSObject.get(fieldName);
            str += separator;
        }
        return str.left(str.length()-separator.length());  // remove the last separator
    }

    public static String getFullDescription(Exception e) {
        return nullToEmptyString(e.getTypeName())
                + ', Msg: ' + nullToEmptyString(e.getMessage())
                + ', stackTrace: '+nullToEmptyString(e.getStackTraceString());
    }

    public static void addMessage(Exception e, Boolean DEBUG, String userMsg) {
        if(Test.isRunningTest() || DEBUG) {
            String testMsg = ClsHelper.getFullDescription(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, testMsg)); // no html allowed
            System.debug(testMsg);
            throw e;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, userMsg)); // no html allowed
            System.debug( ClsHelper.getFullDescription(e) + '. This message was displayed to the user:' + userMsg);
        }
    }

    public static Opportunity insertTestOpp(ID accountId) {
        Opportunity opp = new Opportunity(AccountId=accountId, Name='test', StageName='something', closeDate=Date.today().addDays(12));

        { // Set Opp to isWon. This is often needed for tests.
            String nameOfAWonStage = [SELECT Masterlabel FROM OpportunityStage WHERE isWon=true].get(0).MasterLabel;
            opp.StageName = nameOfAWonStage;
        }

        insert opp;

        return opp; // It is better to return the object instead of an ID in order to enable the user to update the object with more values.
    }

    /**
    This is used from CapTableEditorController.cls and InvestmentSummaryController.cls

    In exec anon you probably want to use:
    Id accId = '001M000000Omu6E';
    InvestmentSummaryController.deleteRounds(accId);
    InvestmentSummaryController.insertRounds1And2AndShares(accId);

    @return: A share is returned for a trigger which wants to delete a share to test the delete trigger event
    */
    public static Ven_Share__c insertRounds1And2AndShares(Id accId) {
        Account shareHolderAcc = ClsHelper.newTestAccount(System.UserInfo.getUserId(), 'Big Holding Clone');
        insert shareHolderAcc;

        Ven_Round__c round1 = new Ven_Round__c(Ven_account__c =accId, Ven_all_Shares__c=100, Ven_Category__c='A'
                                               ,Ven_Founders_Equity_Share__c=25
                                               ,Ven_Round_Number__c=1
                                               ,Ven_SV_Equity_Share__c=30
        );
        insert round1;

        Ven_Share__c share1 = new Ven_Share__c(Ven_account__c =accId
                                              ,Ven_Shareholder__c=shareHolderAcc.id
                                              ,Ven_Shares__c=55
                                              ,Ven_Round__c = round1.id
        );
        insert share1;

        Ven_Round__c round2 = new Ven_Round__c(Ven_account__c =accId, Ven_all_Shares__c=100, Ven_Category__c='A'
                                              ,Ven_Founders_Equity_Share__c=20
                                              ,Ven_Round_Number__c=2
                                              ,Ven_SV_Equity_Share__c=25
                                              ,Ven_Aktiv__c = true
        );
        insert round2;

        Ven_Share__c share2 = new Ven_Share__c(Ven_account__c =accId
                                              ,Ven_Shareholder__c=shareHolderAcc.id
                                              ,Ven_Shares__c=65
                                              ,Ven_Round__c = round2.id
        );
        insert share2;

        return share2;

    }

    public static String getSfHost() {
        return System.URL.getSalesforceBaseUrl().getHost().replace('-api','');
    }

    public static String getSfSubdomain() {
        String host = null;
        List<String> parts = getSfHost().split('\\.');

        if (parts.size() == 3) {
            host = parts[0];
        } else if(parts.size() == 5) {
            host = parts[1];
        }
        return host;
    }

}