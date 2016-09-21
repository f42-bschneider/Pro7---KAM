/*
09.2015, Reza Sarwari:
This class updates all records on CampaignShare if the campaign-status changes from any value to "Abgeschlossen" or "Abgebrochen".
It set's the CampaignAccessLevel for all manual CampaignShare records to "Read".
*/
public with sharing class SomTv_CampaignShare_SetReadOnly {
	
    public static void updateSharingRecords(List<Campaign> listCampaigns, Map<ID,Campaign> oldMap) {
        Set<ID> changedCampaigns = new Set<ID>();
    
        // Check which Campaigns have changed status to 'Abgeschlossen' or 'Abgebrochen'.
        for (Campaign objCampaign : listCampaigns) {
            Campaign oldCampaign = oldMap.get(objCampaign.Id);
            if( (oldCampaign.status != 'Abgeschlossen' && objCampaign.Status == 'Abgeschlossen') || (oldCampaign.status != 'Abgebrochen' && objCampaign.Status == 'Abgebrochen') ) {
                changedCampaigns.add(objCampaign.Id);
            }
        }
        
        // Update all the related CampaignShare and set access level to 'read'.
        List<CampaignShare> listCampaignShares = new List<CampaignShare>([SELECT CampaignAccessLevel FROM CampaignShare 
                                                                         WHERE  CampaignId IN :changedCampaigns AND RowCause = 'Manual']);
        for (CampaignShare objCampaignShare : listCampaignShares) {
            objCampaignShare.CampaignAccessLevel = 'Read';
        }
        
        update listCampaignShares;
    }
}