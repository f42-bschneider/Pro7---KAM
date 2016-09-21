/**
* ===================================================================
* (c) factory42 GmbH 2016, Germany, All rights reserved
* P7S1_Account_SalesTeamEditor_Test
* @author:          BS / VVR factory42
* @email:           bschneider@factory42.com
* @version:         V0.1
* @date:            2016-01-27
* @last change:
* @description:    Test for Controller for VF to edit Sales-Team
* @objects:         Account, SomTv_KundeAgenturBeziehung__c, SomTv_Verkaeuferzuordnung__c
* =================================================================
*/
@isTest
private class P7S1_Account_SalesTeamEditor_Test {

    public static testMethod void testSalesTeamEditorAgentur(){

        Account AccAgentur = cls_P7S1_TestData.createTestAccount(false);
        AccAgentur.SomTv_Accounttypen__c = 'Agentur';
        insert AccAgentur;
        Account AccKunde = cls_P7S1_TestData.createTestAccount(true);

        ID userIDSales = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomTv_Sales');
        User UserSales = [SELECT ID FROM User WHERE ID = :userIDSales];
        AccountTeamMember ATMSales = createAccountTeamMember(true, AccKunde, UserSales, 'TV_Kundenverkäufer');

        ID userIDAF = cls_P7S1_TestData.USER_MAP_PROFILE.get('SomTv_ADFactory');
        User UserAf = [SELECT ID FROM User WHERE ID = :userIDAF];
        AccountTeamMember ATMAf = createAccountTeamMember(true, AccAgentur, UserAf, 'TV_Einkaufsagenturverkäufer');

        Test.startTest();

        PageReference pageRef = Page.P7S1_Account_SalesTeamEditor;
        Test.setCurrentPage(pageRef);
        system.currentPageReference().getParameters().put('accId', AccAgentur.Id);
        P7S1_Account_SalesTeamEditorCtrl con = new P7S1_Account_SalesTeamEditorCtrl();
        //String searchTerm, String figure, String curAgency, String curCust, String curAccId, String curAccType
        P7S1_Account_SalesTeamEditorCtrl.searchUser('Tester', '0', AccAgentur.Id,AccKunde.id,AccKunde.id, 'agency');
        con.checkBeforeSave();
        con.SaveNotRelevant();

        Test.stopTest();
    }

    public static testMethod void testSalesTeamEditorKunde(){

        Account AccAgentur = cls_P7S1_TestData.createTestAccount(true);
        Account AccKunde = cls_P7S1_TestData.createTestAccount(true);


        Test.startTest();

        PageReference pageRef = Page.P7S1_Account_SalesTeamEditor;
        Test.setCurrentPage(pageRef);
        system.currentPageReference().getParameters().put('accId', AccKunde.Id);
        P7S1_Account_SalesTeamEditorCtrl con = new P7S1_Account_SalesTeamEditorCtrl();
        con.lstKAB = new list<SomTv_KundeAgenturBeziehung__c>();
        con.checkBeforeSave();
        con.SaveRelevant();
        con.changeAccOwner();
        con.Cancel();
        con.changeTvSalesEav();
        con.openModal();
        con.prefillKVK();
        con.prefillEavPav();
        Test.stopTest();
    }

    public static AccountTeamMember createAccountTeamMember(Boolean insertObject,Account account, User user, String sRole) {
        AccountTeamMember AccountTeamMember = new AccountTeamMember();
        AccountTeamMember.UserID = user.ID;
        AccountTeamMember.accountID = account.ID;
        AccountTeamMember.TeamMemberRole = sRole;
        if (insertObject) insert AccountTeamMember;
        return AccountTeamMember;
    }

}