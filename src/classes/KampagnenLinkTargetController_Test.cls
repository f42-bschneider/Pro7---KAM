/**
 * Test class for KampagnenLinkTargetController.
 */
@IsTest
public class KampagnenLinkTargetController_Test {
	
	@IsTest
    public static void testKampagnenLinkTargetController1() {
		Test.startTest();

		// Test "no defined" parameters.
		PageReference pr = Page.KampagnenLinkTarget;               
        Test.setCurrentPageReference(pr);

        KampagnenLinkTargetController kltc = new KampagnenLinkTargetController();
        
        kltc.updateMember();
        
        System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR));
        
		Test.stopTest();
    }
       
    @IsTest
    public static void testKampagnenLinkTargetController2() {
		Test.startTest();
		
		// An Account
		Account acc1 = new Account(Name='A test account 1');
		insert acc1;

		// A contact
		Contact con1 = new Contact(firstName='Contact', LastName='Test', accountId = acc1.id, email='test@test.com');
		insert con1;

		// A Campaign
		Campaign cam1 = new Campaign(Name='A test campaign 1');		
		insert cam1;
		
		// CampaignMemberStatus
		CampaignMemberStatus cms1 = new CampaignMemberStatus(CampaignId=cam1.Id, Label='Versendet', SortOrder=3, IsDefault=true, HasResponded=false);
		insert cms1;
		
		// CampaignMemberStatus
		CampaignMemberStatus cms2 = new CampaignMemberStatus(CampaignId=cam1.Id, Label='Geantwortet', SortOrder=4, IsDefault=true, HasResponded=false);
		insert cms2;
		
		PageReference pr = Page.KampagnenLinkTarget;               
        Test.setCurrentPageReference(pr);

        // Now test functionality.
        System.currentPageReference().getParameters().put('campId', EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(cam1.Id)), 'UTF-8'));
        System.currentPageReference().getParameters().put('statusId', EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(cms1.Id)), 'UTF-8'));
        System.currentPageReference().getParameters().put('redirURL', EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf('https://a.dummy.com/')), 'UTF-8'));
        System.currentPageReference().getParameters().put('email', EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(con1.email)), 'UTF-8'));
 
        KampagnenLinkTargetController kltc = new KampagnenLinkTargetController();
        
        kltc.updateMember();
        
        CampaignMember campaignMember = null;
		for (CampaignMember cm : [SELECT Id, ContactId, CampaignId, Status FROM CampaignMember WHERE ContactId = :con1.Id AND CampaignId = :cam1.Id]) {
			campaignMember = cm;
			break;
		}        
        
        System.assertNotEquals(null, campaignMember);
        System.assertEquals('Versendet', campaignMember.Status);
        
        // Other Status
        System.currentPageReference().getParameters().put('statusId', EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(cms2.Id)), 'UTF-8'));
         		
		kltc = new KampagnenLinkTargetController();
        
        kltc.updateMember();
        
        campaignMember = null;
		for (CampaignMember cm : [SELECT Id, ContactId, CampaignId, Status FROM CampaignMember WHERE ContactId = :con1.Id AND CampaignId = :cam1.Id]) {
			campaignMember = cm;
			break;
		}        
        
        System.assertNotEquals(null, campaignMember);
        System.assertEquals('Geantwortet', campaignMember.Status);
        
        Test.stopTest();
    }
}