/**
 * Unit-Testing and Code Converage for classes Adv_CampaignItem_Commitment
 */
@isTest
public class Adv_CampaignItem_Commitment_Test {
    private static SomDig_Commitment__c comm;
    private static ADvendio__MediaCampaign__c mc;

    public static String mockEditPageBody = '<label for="testinput">TestLabel</label><input id="testinput" type="Text" value=""/>';
    
    /**
     * Init test data
     */
    static {
        comm                                    = cls_P7S1_TestData.createSomDigCommitment(false, cls_P7S1_TestData.createTestWTAG(true, null, null));
        comm.SomDig_Agentur_Rabatt__c           = 11.1;
        comm.SomDig_Kundenrabatt_InStream__c    = 20.1;
        insert comm;

        mc  = cls_P7S1_TestData.createTestMediaCampaign(false, [SELECT Id, SomDig_WtAgBeziehung__r.Id FROM SomDig_Commitment__c WHERE Id =:comm.Id].SomDig_WtAgBeziehung__r);
        mc.SomDig_Commitment__c         = comm.Id;
        insert mc;
        
        Adv_CampaignItem_Commitment.tranCommitmentToMediaCamp(comm, mc);
        update mc;
    }
    
    @isTest (seeAllData=false)
    public static void testTrigger(){
        
        System.Test.startTest();
        
        mc  = [SELECT Id, ADvendio__Rate_Discount_3__c, SomDig_Kundenrabatt_InPage__c, ADvendio__IsApproved__c FROM ADvendio__MediaCampaign__c WHERE Id =:mc.Id];
        
        system.assertEquals(comm.SomDig_Kundenrabatt_InPage__c, mc.SomDig_Kundenrabatt_InPage__c);
        system.assertEquals(comm.SomDig_Agentur_Rabatt__c, mc.ADvendio__Rate_Discount_3__c);
        system.assertEquals(true, mc.ADvendio__IsApproved__c);
        
        ADvendio__Campaign_Item__c ci   = cls_P7S1_TestData.createTestCampaignItem(true, mc);
        ci  = [SELECT Id, ADvendio__Ad_Price__r.ADvendio__Ad_Spec__c FROM ADvendio__Campaign_Item__c WHERE Id =:ci.Id];
        update new ADvendio__Ad_Specs__c(Id=ci.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__c, SomDig_MediagattungsDifferenzierung__c=Adv_CampaignItem_Commitment.INPAGE_IND);
        
        ci  = [SELECT Id, ADvendio__Rate_Discount_2_custom__c, ADvendio__Rate_Discount_3_custom__c, SomDig_RabatteFreigegebenCheck__c FROM ADvendio__Campaign_Item__c WHERE Id =:ci.Id];
        system.assertEquals(mc.ADvendio__Rate_Discount_3__c, ci.ADvendio__Rate_Discount_3_custom__c);
        system.assertEquals(mc.SomDig_Kundenrabatt_InPage__c, ci.ADvendio__Rate_Discount_2_custom__c);
        
        ci.ADvendio__Rate_Discount_4__c = 5.0;
        update ci;
        
        ci  = [SELECT Id, ADvendio__Media_Campaign__r.ADvendio__IsApproved__c, SomDig_RabatteFreigegebenCheck__c FROM ADvendio__Campaign_Item__c WHERE Id =:ci.Id];
        system.assertEquals(true, ci.SomDig_RabatteFreigegebenCheck__c);
        system.assertEquals(true, ci.ADvendio__Media_Campaign__r.ADvendio__IsApproved__c);
        
        mc.SomDig_Sonderrabatt_InPage__c    = 50.0;
        update mc;
        
        ci  = [SELECT Id, ADvendio__Media_Campaign__r.ADvendio__IsApproved__c, SomDig_RabatteFreigegebenCheck__c FROM ADvendio__Campaign_Item__c WHERE Id =:ci.Id];
        system.assertEquals(true, ci.SomDig_RabatteFreigegebenCheck__c);
        system.assertEquals(true, ci.ADvendio__Media_Campaign__r.ADvendio__IsApproved__c);
        
        mc.SomDig_Sonderrabatt_InPage__c    = 66.0;
        update mc;
        
        mc  = [SELECT Id, SomDig_Sonderrabatt_InPage__c, ADvendio__IsApproved__c FROM ADvendio__MediaCampaign__c WHERE Id =:mc.Id];
       
        //system.assertEquals(false, mc.ADvendio__IsApproved__c);
        
        System.Test.stopTest();
    }
    
    /**
     * Test generateUrl
     */
    static testmethod void testGenerateUrl() {
        System.Test.startTest();
        //Return standard edit page URL
        String editUrl = Adv_CampaignItem_Commitment.generateUrl(comm.Id);
        System.assert(editUrl.contains('/e?nooverride=1&retURL=/'+comm.Id), 'This is not edit page URL');
        System.Test.stopTest();
    }
}