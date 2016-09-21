@isTest
public class SomTv_KundeAgenturBeziehung_New_Test{

    public static testMethod void testKundenagenturbeziehungNew(){    
        // Create Test Data
        Account objAccAgentur = cls_P7S1_TestData.createTestAccount(true);    
        Account objAccKunde = cls_P7S1_TestData.createTestAccount(true);            
    
        // Create Account Team members
        
        // Get User to create AccountTeamMember
        ID userIDSales = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomTv_Sales');
        User objUserSales = [SELECT ID FROM User WHERE ID = :userIDSales];
        AccountTeamMember objATMSales = createAccountTeamMember(true, objAccKunde, objUserSales, 'TV_Kundenverkäufer');        
        
        ID userIDAF = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomTv_ADFactory');
        User objUserAf = [SELECT ID FROM User WHERE ID = :userIDAF];        
        AccountTeamMember objATMAf = createAccountTeamMember(true, objAccAgentur, objUserAf, 'TV_Einkaufsagenturverkäufer');        
                
        
        ID userIDMarketing = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomTv_Marketing');
        User objUserMarketing = [SELECT ID FROM User WHERE ID = :userIDMarketing];        



        Test.startTest();        
        
        PageReference pageRef = Page.SomTv_KundeAgenturBeziehung_New;
        Test.setCurrentPage(pageRef);
        system.currentPageReference().getParameters().put('id', objAccAgentur.Id);
        system.currentPageReference().getParameters().put('type', 'agentur');        
        
        
        SomTv_KundeAgenturBeziehung_New con = new SomTv_KundeAgenturBeziehung_New();
        con.objAccount = objAccAgentur;
        con.objNewKAB.Kunde__c = objAccKunde.ID;        
        
        // Get picklists
        List<SelectOption> listKundenverkaeufer = con.getKundenverkaeufer();
        System.assert(listKundenverkaeufer.size() > 0);
        
        List<SelectOption> listEinkaufsagenturverkaeufer = con.getEinkaufsagenturverkaeufer();
        System.assert(listEinkaufsagenturverkaeufer.size() > 0);
        
        List<SelectOption> listPlanungsagenturverkaeufer = con.getPlanungsagenturverkaeufer();
        System.assert(listPlanungsagenturverkaeufer.size() > 0);                
        
        
        // Test saving
        
        // Fill out 
        con.sKverkaeufer     = objUserSales.ID;
        con.sEAverkaeufer    = objUserAf.ID;
        con.sPAverkaeufer    = objUserMarketing.ID;        

        
        // Save
        con.saveData();
        
        
        // Check if records are inserted
        List<SomTv_KundeAgenturBeziehung__c> listKB = new List<SomTv_KundeAgenturBeziehung__c>([SELECT ID FROM SomTv_KundeAgenturBeziehung__c WHERE Kunde__c = :objAccKunde.ID AND Agentur__c = :objAccAgentur.ID]);
        System.assert(listKB.size() == 1);
        
        
        List<SomTv_Verkaeuferzuordnung__c> listVZ = new List<SomTv_Verkaeuferzuordnung__c>([SELECT ID FROM SomTv_Verkaeuferzuordnung__c WHERE SomTv_KdAgenturBeziehung__c = :listKB[0].ID]);
        System.assert(listVZ.size() == 3);        
                
        
        con.cancel();
        
        
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

}