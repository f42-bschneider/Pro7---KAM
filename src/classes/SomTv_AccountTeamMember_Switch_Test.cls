@isTest
public class SomTv_AccountTeamMember_Switch_Test{


    public static testMethod void testSaveWithoutAddingAgenturSplit(){
    
        String sRole = 'TV_Planungsagenturverkäufer';
        
        // Create test Data
        Account objAcc = cls_P7S1_TestData.createTestAccount(true);
        Account objAcc2 = cls_P7S1_TestData.createTestAccount(true);
        
        
        // Get User to create AccountTeamMember
        ID userIDSales = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomTv_Sales');
        User objUserSales = [SELECT ID FROM User WHERE ID = :userIDSales];
        AccountTeamMember objATMSales = createAccountTeamMember(true, objAcc, objUserSales, sRole);
        
        // Create a Beziehung and Verkäuferzuordnung for this User
        SomTv_KundeAgenturBeziehung__c objBeziehung = createSomTvKundeAgenturBeziehung(true, objAcc, objAcc2);
        SomTv_Verkaeuferzuordnung__c objVerkaeuferzuordnung = createSomTvVerkaeuferzuordnung(true, objBeziehung, objUserSales, sRole);
        
        
        
        
        ID userIDAF = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomTv_ADFactory');
        User objUserAf = [SELECT ID FROM User WHERE ID = :userIDAF];        
        AccountTeamMember objATMAf = createAccountTeamMember(true, objAcc, objUserAf, sRole);        
        
        
        // Start Test
        Test.startTest();
    
        // Create Class and StandardController
        PageReference pageRef = Page.SomTv_AccountTeamMember_Switch;
        Test.setCurrentPage(pageRef);
        system.currentPageReference().getParameters().put('id', objAcc.Id);
        system.currentPageReference().getParameters().put('type', 'agentur');
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objAcc);
        SomTv_AccountTeamMember_Switch  con = new SomTv_AccountTeamMember_Switch(sc);        


        // Get Rollen-Picklist
        List<SelectOption> listRoles = con.getRollen();
        System.assert(!listRoles.isEmpty());        
        
        
        // Choose a Role
        con.sRolle = 'TV_Planungsagenturverkäufer';
        
        
        // Get Olduser Picklist
        List<SelectOption> listOldUser = con.getOldUser();        
        System.assert(!listOldUser.isEmpty());                

        
        // Choose a User
        con.sOldUserID = objUserSales.ID;


        
        // Get Newuser Picklist
        List<SelectOption> listNewUser = con.getNewUser();        
        System.assert(!listNewUser.isEmpty());                
        
        
        // Run in Error
        con.save();        
        
        
        // Choose a User
        con.sNewUserID = objUserAf.ID;        

        
        // init List of Wrapper Objects
        con.initListBeziehungWrapper();
        System.assert(!con.listBW.isEmpty());             
        
        
        // Run in Error
        con.save();            
        
        
        // Check all Boxes
        for(SomTv_AccountTeamMember_Switch.BeziehungWrapper o : con.listBW)
            o.bChecked = true;
        
        
        // Save
        con.save();
        
        
        Test.stopTest();    
    }



    // TODO: Move to cls_P7S1_TestData
    public static AccountTeamMember createAccountTeamMember(Boolean insertObject,Account account, User user, String sRole) {
        AccountTeamMember AccountTeamMember = new AccountTeamMember();
        AccountTeamMember.UserID = user.ID;
        AccountTeamMember.accountID = account.ID;        
        AccountTeamMember.TeamMemberRole = sRole;
        if (insertObject) insert AccountTeamMember;
        return AccountTeamMember;
    }
    
    public static SomTv_KundeAgenturBeziehung__c createSomTvKundeAgenturBeziehung(Boolean insertObject,Account accountAgentur, Account accountKunde) {
        SomTv_KundeAgenturBeziehung__c KundeAgenturBeziehung = new SomTv_KundeAgenturBeziehung__c();
        KundeAgenturBeziehung.Agentur__c = accountAgentur.ID;
        KundeAgenturBeziehung.Kunde__c = accountKunde.ID;     
        KundeAgenturBeziehung.GueltigVon__c = System.today().addMonths(-1);
        if (insertObject) insert KundeAgenturBeziehung;
        
        return KundeAgenturBeziehung;
    }    
    
    
    
    public static SomTv_Verkaeuferzuordnung__c createSomTvVerkaeuferzuordnung(Boolean insertObject, SomTv_KundeAgenturBeziehung__c beziehung, User user, String sRole) {
        SomTv_Verkaeuferzuordnung__c verkaeuferzuordnung = new SomTv_Verkaeuferzuordnung__c();
        verkaeuferzuordnung.SomTv_KdAgenturBeziehung__c = beziehung.ID;
        verkaeuferzuordnung.SomTv_Verkaeufer__c = user.ID;        
        verkaeuferzuordnung.SomTv_Verkaeuferrolle__c = sRole;
        if (insertObject) insert verkaeuferzuordnung;
        
        return verkaeuferzuordnung;
    }        


}