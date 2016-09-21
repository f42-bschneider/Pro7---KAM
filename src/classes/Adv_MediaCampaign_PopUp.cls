/*
    This class controls execution of pop up alert.
    Whenever a Field M(Field : SomDig_DienstleistungbezogenePositionen__c) is greater than
    N(Field : SomDig_Dienstleistungspositionen__c ) it will show an alert.
*/
public class Adv_MediaCampaign_PopUp {

    //Class Variables
    public Boolean i_bcheckM{get;set;}
    public String i_surl{get;set;}

    //Constructor
    public Adv_MediaCampaign_PopUp(ApexPages.StandardController sc){
        i_bcheckM = false;
        ADvendio__MediaCampaign__c I_oMediaId = (ADvendio__MediaCampaign__c)sc.getRecord();

        //Set of phases for which alert will be shown
        Set<String> I_sPhasesList = new Set<String>{'Stage 25%','Offer on Request','Stage 75%','Stage 90%','Booked'};

        //Quering Media Campaingn Record
        List<ADvendio__MediaCampaign__c> I_oMediaRecordList = new List<ADvendio__MediaCampaign__c>([Select id,SomDig_DienstleistungbezogenePositionen__c,SomDig_Dienstleistungspositionen__c, SomDig_DienstleistungbezogeneHelp__c, SomDig_DienstleistungspositionenHelp__c
                                                    from ADvendio__MediaCampaign__c
                                                    where id=:I_oMediaId.Id AND ADvendio__Stage__c in: I_sPhasesList]);

        //Checking whether M(Field : SomDig_DienstleistungbezogenePositionen__c) > N (Field : SomDig_Dienstleistungspositionen__c )
        if(I_oMediaRecordList.size() > 0){
            ADvendio__MediaCampaign__c I_oMediaRecord = I_oMediaRecordList.get(0);
            if(I_oMediaRecord.SomDig_DienstleistungbezogenePositionen__c != I_oMediaRecord.SomDig_DienstleistungbezogeneHelp__c ||
                I_oMediaRecord.SomDig_Dienstleistungspositionen__c != I_oMediaRecord.SomDig_DienstleistungspositionenHelp__c){

                if(I_oMediaRecord.SomDig_DienstleistungbezogenePositionen__c > I_oMediaRecord.SomDig_Dienstleistungspositionen__c ){
                    i_bcheckM = true;
                }
            }
            else
            {
                 i_bcheckM = false;
            }
        }
    }
}