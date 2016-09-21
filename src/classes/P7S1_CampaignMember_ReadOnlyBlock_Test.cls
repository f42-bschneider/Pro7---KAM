@isTest
public class P7S1_CampaignMember_ReadOnlyBlock_Test {
   
     static testMethod void CampaignMember_UpdateSharingRecords() {
        Test.startTest();
        
        ID profileID = [select ID FROM Profile WHERE Name = 'Marketing-Benutzer' or Name = 'Marketing User'].ID;  
                  
        User user = new User( alias = 'test123', email='test123@noemail.com',
                              emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                              localesidkey='en_US', profileid = profileID, country = 'United States', IsActive = true,
                              timezonesidkey='America/Los_Angeles', username = 'tester@noemail.com');
       
        insert user;
        
        system.runAs(user) {
            Campaign cam = new Campaign(Name = 'Test Campaign', Status = 'Planung');
            insert cam;            
        }
        
        Campaign cam = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1];
        
        CampaignShare cs = new CampaignShare(CampaignID = cam.Id, CampaignAccessLevel = 'Edit', RowCause = 'Manual', UserOrGroupId = UserInfo.getUserID());
        insert cs;
        
        Contact objContact = new Contact(FirstName = 'Test-FistName', LastName = 'Test-LastName', Email = 'testmail@test.com');
        insert objContact;
        
        CampaignMember cm = new CampaignMember(CampaignId = cam.ID, ContactId = objContact.ID, Status = 'Sent');
        insert cm;
        Test.stopTest();
    }
}