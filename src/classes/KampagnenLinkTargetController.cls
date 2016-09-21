/**
 * A controller for the VF page KampagnenLinkTarget.
 */
global without sharing class KampagnenLinkTargetController {
	/**
	 * Constructor.
	 */    
	public KampagnenLinkTargetController() {
	}

	/**
	 * Update the status of a campaign member.
	 * @return	A PageReference object.
	 */
	public PageReference updateMember(){
	   try {
			String campaignId = ApexPages.currentPage().getParameters().get('campId');
			String statusId = ApexPages.currentPage().getParameters().get('statusId');
			String redirectURL = ApexPages.currentPage().getParameters().get('redirURL');
			String userEmail = ApexPages.currentPage().getParameters().get('email');
			String userId = ApexPages.currentPage().getParameters().get('userId');
            
            /* Reza Sarwari: sAction gives us the possibility to use this code more dynamically.
				For instance to save acception or refusal of CampainMember */
            String sAction = ApexPages.currentPage().getParameters().get('sAction');
			String campaignMemberId = ApexPages.currentPage().getParameters().get('campaignMemberId');
           
               
			// some values are base64encoded. See KampagnenMailLinkGenController.cls for details
			System.debug('\n\n campaignId: ' + campaignId + ', statusId: ' + statusId + ', redirectURL: ' + redirectURL + ', userId: ' + userId + ', userEmail: ' + userEmail + '\n');

            
            if (sAction == null || sAction == '') { 
                
                if (campaignId == null || campaignId.equals(''))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Campaign-Id defined.'));
                else
                    campaignId = EncodingUtil.base64Decode(EncodingUtil.urlDecode(campaignId, 'UTF-8')).toString();
                
                
                if (statusId == null || statusId.equals(''))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Status-Id defined.'));
                 else 
                    statusId = EncodingUtil.base64Decode(EncodingUtil.urlDecode(statusId, 'UTF-8')).toString();
                
                if (userEmail != null)
                    userEmail = EncodingUtil.base64Decode(EncodingUtil.urlDecode(userEmail, 'UTF-8')).toString();
                			
                if ((userId == null || userId.equals('')) && (userEmail == null || userEmail.equals(''))) 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No User-Identification defined.'));
                
                
                if (redirectURL == null || redirectURL.equals('')) 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Redirect-URL defined.'));
                else 
                    redirectURL = EncodingUtil.base64Decode(EncodingUtil.urlDecode(redirectURL, 'UTF-8')).toString();
                
            } else {
                
                if (campaignMemberId == null || campaignMemberId.equals('')) 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Campaign-Member-Id defined.'));
                else 
                    campaignMemberId = EncodingUtil.base64Decode(EncodingUtil.urlDecode(campaignMemberId, 'UTF-8')).toString();
            }
            
           System.debug('** \n\n campaignId: ' + campaignId + ', statusId: ' + statusId + ', redirectURL: ' + redirectURL + ', userId: ' + userId + ', userEmail: ' + userEmail + '\n');
			
			//get by email if no userid is set 
			if (sAction == null || sAction == '') { 
                if ((userId == null || userId.equals('')) && (userEmail != null && !userEmail.equals(''))) {
                    Contact contact = [SELECT Id FROM Contact WHERE email = :userEmail LIMIT 1];
                    if (contact == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No contact found by email.'));
                    } else {
                        userId = contact.Id;
                    }
                }
            }
            
			if (ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
				return null;
			}
			
            if (sAction == null || sAction == '') {
                if (userId != null && !userId.equals('')) {
                    CampaignMemberStatus campaignMemberStatus = null;
                    for (CampaignMemberStatus cms : [SELECT Id, label FROM CampaignMemberStatus WHERE Id = :statusId]) {
                        campaignMemberStatus = cms;
                        break;
                    }
                    if (campaignMemberStatus == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown status: ' + statusId + '.'));
                        return null;
                    }
    
                    CampaignMember campaignMember = null;
                    for (CampaignMember cm : [SELECT Id, ContactId, CampaignId, Status FROM CampaignMember WHERE ContactId = :userId AND CampaignId = :campaignId]) {
                        campaignMember = cm;
                        break;
                    }
					
                    if (campaignMember == null) {
                        campaignMember = new CampaignMember(CampaignId = campaignId, ContactId = userId, Status = campaignMemberStatus.Label);
                        insert campaignMember;
                    } else {
                        campaignMember.Status = campaignMemberStatus.Label;
                        update campaignMember;
                    }
               } 
                
            } else if (sAction == 'Zusage' || sAction == 'Absage') {
                
                CampaignMember campaignMember = null;
                for (CampaignMember cm : [SELECT Status, Campaign.P7S1_Landingpage__c FROM CampaignMember WHERE ID = :campaignMemberId]) {
                    campaignMember = cm;
                    break;
                }
                
                // Set default Landing-Page from Custom Label or from Campaign:
                redirectURL = System.Label.KampagnenLinkTargetController_Default_Landingpage;
                if (CampaignMember.Campaign.P7S1_Landingpage__c != null) {
                    redirectURL = CampaignMember.Campaign.P7S1_Landingpage__c;
                }
                
                
                // Override Landing-Page if needed:
                if (campaignMember.Status == 'Absage' && sAction == 'Absage') {
                    redirectURL = System.Label.P7S1_CampaignMemberForwarder_LandingPage_SieHabenBereitsAbgesagt;
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sie haben bereits abgesagt. Eine Zusage ist daher leider nicht mehr möglich.'));
                } else {
                
                    if (campaignMember.Status == 'Zusage' && sAction == 'Zusage') {
                        redirectURL = System.Label.P7S1_CampaignMemberForwarder_LandingPage_SieHabenBereitsZugesagt;
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sie haben bereits zugesagt.'));
                        
                    }
                
               		campaignMember.Status = sAction;
                	update campaignMember;
                } 
            }
		    
            if (!redirectURL.startsWith('http')) 
                  redirectURL = 'http://'+redirectURL; 
           
			PageReference redirect = new PageReference(redirectURL);
            redirect.setRedirect(true);
            system.debug('** redirect: ' + redirect);
           
            return redirect;
           
		} catch (Exception e) {
            System.debug('** Exception ');
            ApexPages.addMessages(e);
		}

		return null;
	}
}