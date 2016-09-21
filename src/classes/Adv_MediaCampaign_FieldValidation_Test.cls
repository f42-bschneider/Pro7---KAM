@isTest
public class Adv_MediaCampaign_FieldValidation_Test{

    public static testMethod void testUserIsNoTeamLead(){
        Test.startTest();
        // New MC
        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(false);    
        objMC.RecordTypeID = cls_P7S1_Utils.getRecordTypeId('ADvendio__MediaCampaign__c', 'SomDig_Auftrag');
        insert objMC;
          
        try{
            // Create WTAG            
            SomDig_WtAgBeziehung__c objNewWTAG = cls_P7S1_TestData.createTestWTAG(true, null, null);
            objMC.SomDig_WtAgBeziehung__c = objNewWTAG.ID;
            update objMC;             
            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Das Feld WT AG Beziehung auf der Mediakampagne darf nicht editiert werden.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);        
        }
         
        Test.stopTest();        
    }  
    
    
    public static testMethod void testUserIsTeamLead(){

        User objUserPAM = cls_P7S1_TestData.USER_FOR_PROFILE.get('SomDig_PAM');

        // Put User into public group
        Group  teamLeadGroup= [SELECT Id FROM Group WHERE Name = 'SomDig_TeamLead' limit 1];
        GroupMember objGM = new GroupMember(GroupId = teamLeadGroup.id); 
        objGM.UserOrGroupId = objUserPAM.ID;
        insert objGM;        

        System.runAs(objUserPAM) {
            Test.startTest();
                    
            // New MC
            ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(false);    
            objMC.RecordTypeID = cls_P7S1_Utils.getRecordTypeId('ADvendio__MediaCampaign__c', 'SomDig_Auftrag');
            insert objMC;
    
            // Create WTAG            
            SomDig_WtAgBeziehung__c objNewWTAG = cls_P7S1_TestData.createTestWTAG(true, null, null);
            objMC.SomDig_WtAgBeziehung__c = objNewWTAG.ID;
            update objMC;                        
            
            // Assert WTAG Changed
            objMC = [SELECT SomDig_WtAgBeziehung__c FROM ADvendio__MediaCampaign__c WHERE ID = :objMC.ID];
            System.assert(objMC.SomDig_WtAgBeziehung__c == objNewWTAG.ID);
        
            Test.stopTest();        
        }
    }       
    
    
    public static testMethod void testWithInvoices(){

        // Rollup
        P7S1_Rollup__c objRollup = new P7S1_Rollup__c();
        objRollup.Active__c = true;
        objRollup.ChildObject__c = 'ADvendio__Invoice__c';
        objRollup.ParentObject__c = 'ADvendio__MediaCampaign__c';
        objRollup.ParentResultField__c = 'SomDig_SumReviewedAndInvoicedInvoices__c';
        objRollup.RelationshipField__c = 'ADvendio__MediaCampaign__c';        
        objRollup.Type__c = 'Count';         
        objRollup.WhereCondition__c = 'ADvendio__Status__c = \'Invoiced\' OR ADvendio__Status__c = \'Reviewed\'';                        
        insert objRollup;

        // New MC
        ADvendio__MediaCampaign__c objMC = cls_P7S1_TestData.createTestMediaCampaign(false);    
        objMC.RecordTypeID = cls_P7S1_Utils.getRecordTypeId('ADvendio__MediaCampaign__c', 'SomDig_Auftrag');
        insert objMC;
        
        ADvendio__Invoice__c objInv = cls_P7S1_TestData.createTestInvoice(false, objMC);         
        objInv.ADvendio__Status__c = 'Invoiced';
        insert objInv;

        Test.startTest();
          
        try{
            // Create WTAG            
            SomDig_WtAgBeziehung__c objNewWTAG = cls_P7S1_TestData.createTestWTAG(true, null, null);
            objMC.SomDig_WtAgBeziehung__c = objNewWTAG.ID;
            update objMC;             
            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Das Feld WT AG Beziehung auf der Mediakampagne darf nicht editiert werden.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);        
            
            // Assert MC has Invoices
            objMC = [SELECT SomDig_SumReviewedAndInvoicedInvoices__c FROM ADvendio__MediaCampaign__c WHERE ID = :objMC.ID];            
            System.AssertEquals(objMC.SomDig_SumReviewedAndInvoicedInvoices__c, 1);                    
        }
         
        Test.stopTest();        
    }      
}