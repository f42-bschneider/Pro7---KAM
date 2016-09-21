/*
#Date: Oktober 2015
#Author: Reza Sarwari
#Description: Checks if the current user has write access on the parent Campaign record. 
*/
public with sharing class P7S1_CampaignMember_ReadOnlyBlock {
   
    public static void CheckSharing(List<CampaignMember> listCampaignMember) {
        ID userID = UserInfo.getUserID();
        Set<Id> userOrGroupIds = new Set<Id>{userID};
            for(GroupMember gm : [SELECT ID, GroupId FROM GroupMember Where UserOrGroupId = :userId])
        {
            userOrGroupIds.add(gm.GroupId);
        }
        
        system.debug('** UserInfo.getProfileId(): ' +UserInfo.getProfileId());
        
        // Ignore if ProfileID is for the Site-Guest-User: "SomTv Update B2B Aktionsmitglied Status Profile"
        if (UserInfo.getProfileId().subString(0,15) != '00eD0000001QquT' &&
            UserInfo.getProfileId().subString(0,15) != '00e26000000LtyY' && 
            UserInfo.getProfileId().subString(0,15) != '00e57000001AuRD') {
            
            CampaignMember cm = listCampaignMember[0];
            
            system.debug('** userID: ' + userID);
            system.debug('** cm.CampaignId: ' + cm.CampaignId);
            
            List<CampaignShare> cs = new List<CampaignShare>([select  ID, CampaignId, IsDeleted, RowCause, CampaignAccessLevel, UserOrGroup.Name 
                                                           from  CampaignShare 
                                                           where CampaignId = :cm.CampaignId 
                                                              AND UserOrGroupID in :userOrGroupIds
                                                              //AND UserOrGroupID = :userID 
                                                              AND (CampaignAccessLevel = 'Edit' OR CampaignAccessLevel = 'All')
                                                           ]);
            
            system.debug('** cs: ' + cs);
            
            if (cs.isEmpty()) {
               for (CampaignMember camMem : listCampaignMember)
                   camMem.addError(System.Label.P7S1_CampaignMember_ReadOnlyBlock_Error);
            }   
        }    
    }   
}