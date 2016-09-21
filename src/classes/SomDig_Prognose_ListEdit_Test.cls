@isTest
public class SomDig_Prognose_ListEdit_Test{


    public static testMethod void testSomDig_Prognose_ListEdit(){

        // Create Test Data
        Account objAccWT = cls_P7S1_TestData.createTestAccount(true);
        Account objAccAG = cls_P7S1_TestData.createTestAccount(true);

        SomDig_WtAgBeziehung__c objbeziehung = cls_P7S1_TestData.createTestWTAG(true, objAccWT, objAccAG);
        SomDig_Prognose__c objPrognose = createTestPrognose(true, objBeziehung);


        Test.startTest();

        SomDig_Prognose_ListEdit con = new SomDig_Prognose_ListEdit();
        con.sSortOrder = 'Name';
        con.sFilter = 'Vertrieb Berlin';

        List<SomDig_Prognose__c> listPrognosen = con.getListPrognosen();

        con.recordID = objPrognose.ID;
        con.save();
        con.cancel();

        System.assert(listPrognosen != null);

        Test.stopTest();
    }


    // TODO: move to cls_P7S1_TestData
    public static SomDig_Prognose__c createTestPrognose(Boolean insertObject, SomDig_WtAgBeziehung__c objBeziehung){

        SomDig_Prognose__c objPrognose = new SomDig_Prognose__c();
        objPrognose.SomDig_WtAgBeziehung__c = objBeziehung.ID;

        objPrognose.SomDig_PrognoseQ1__c = 1;
        objPrognose.SomDig_PrognoseQ2__c = 1;
        objPrognose.SomDig_PrognoseQ3__c = 1;
        objPrognose.SomDig_PrognoseQ4__c = 1;

        objPrognose.SomDig_MedDiffInStream__c = 1;
        objPrognose.SomDig_MedDiffInPage__c = 1;
        objPrognose.SomDig_MedDiffRest__c = 2;

        objPrognose.SomDig_RelativesJahr__c = 'AJ';

        if (insertObject) insert objPrognose;
        return objPrognose;
    }

}