@isTest
public class SomTv_CampaignShare_SetReadOnly_Test {
   
     static testMethod void CampaignMember_UpdateSharingRecords() {
        Test.startTest();
    	
        ID profileID = [select ID FROM Profile WHERE Name = 'Marketing-Benutzer' or Name = 'Marketing User'].ID;  
                  
        User user = new User( alias = 'test123', email='test123@noemail.com',
                              emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                              localesidkey='en_US', profileid = profileID, country = 'United States', IsActive = true,
                              timezonesidkey='America/Los_Angeles', username = 'tester@noemail.com');
       
        insert user;
		
        Campaign cam;
        //system.runAs(user) {
            cam = new Campaign(Name = 'Test Campaign', Status = 'Planung');
            insert cam;            
        ///}
        
        CampaignShare cs = new CampaignShare(CampaignID = cam.Id, CampaignAccessLevel = 'Edit', RowCause = 'Manual', 
                                             UserOrGroupId = user.ID);
        insert cs;
        
        cam.Status = 'Abgeschlossen';
        update cam;
        
        CampaignShare csUpdated = [select ID, CampaignAccessLevel FROM CampaignShare WHERE ID =: cs.ID];
        
        System.assertEquals('Read', csUpdated.CampaignAccessLevel, 'Campaign-Trigger did not update CampaignShare record!');
        
        Test.stopTest();
    }
}