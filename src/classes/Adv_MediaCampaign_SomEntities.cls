/*
KV 02260
Creates an AdServerTeamAssignment when a Mediacampaign is Created
*/

public class Adv_MediaCampaign_SomEntities {

    public static void createAdServerTeamAssignment(List<sObject> lstNewItems){
    
        List<ADvendio__AdServer_ID__c> listAdID = new List<ADvendio__AdServer_ID__c>([SELECT ID FROM ADvendio__AdServer_ID__c WHERE Name = 'SOM_entities']);
        
        List<ADvendio__AdServerTeamAssignment__c> listNewASTA = new List<ADvendio__AdServerTeamAssignment__c>();
        if(!listAdID.isEmpty()){
            for(sObject ci : lstNewItems){            
                listNewASTA.add(new ADvendio__AdServerTeamAssignment__c(Name = 'SOM_entities', ADvendio__MediaCampaign__c = ci.ID, ADvendio__AdServerID__c = listAdID[0].ID));
            }        
        }
        
        insert listNewASTA;
    }           
}