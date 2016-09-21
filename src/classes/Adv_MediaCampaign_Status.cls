public with sharing class Adv_MediaCampaign_Status extends TriggerController {

    public Adv_MediaCampaign_Status(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                    List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems
    ) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    protected override void runAfterInsert() {
        updateCampaignStatus((List<ADvendio__Campaign_Item__c>)lstNewItems, null);
    }

    protected override void runAfterUpdate() {
        updateCampaignStatus((List<ADvendio__Campaign_Item__c>)lstNewItems, (Map<Id, ADvendio__Campaign_Item__c>)mapOldItems);
    }

    protected override void runAfterDelete() {
        updateCampaignStatus((List<ADvendio__Campaign_Item__c>)lstOldItems, null);
    }

    /*
        Method Name  : updateCampaignStatus
        Parameters   : list of Campaign Line Items
        Return Type  : void
        Description  : This method is used to update the Status based Campaign Line Item Status
                        1. If All Campaign Line Items have "Entwurf" status then it will update the Campaign Status to "neu"
                        2. If Campaign Line Items have "Entwurf" or "Pausiert" or "abgelaufen-erfüllt" or "abgelaufen-unterliefert" status
                            then it will update the Campaign Status to "to do"
                        3. If Campaign Line Items have "Bereit" or "Auslieferung-normal" or "Auslieferung-@Risk" status
                            then it will update the Campaign Status to "planmässig"
        Created By   : Cognizant Technology Solutions
    */
    private void updateCampaignStatus(List<ADvendio__Campaign_Item__c> p_oListCampaignItems, Map<Id, ADvendio__Campaign_Item__c> p_oMapOldCampaignItems) {

        // Only continue if there are any items which have a changed status
        Boolean any_status_fields_changed = false;
        for (ADvendio__Campaign_Item__c new_CampaignItem : p_oListCampaignItems) {
            if (p_oMapOldCampaignItems == null || new_CampaignItem.SomDig_PositionStatus__c != p_oMapOldCampaignItems.get(new_CampaignItem.Id).SomDig_PositionStatus__c)
                any_status_fields_changed = true;
                break;
        }

        if (any_status_fields_changed) {
            //variables declaration
            Map<Id, List<ADvendio__Campaign_Item__c>> l_oMapIdCampaignList = new Map<Id, List<ADvendio__Campaign_Item__c>>();
            Set<Id> l_iSetMediaCampaignIds = new set<Id>();
            //updated campaign Record Ids List
            List<ADvendio__MediaCampaign__c> l_oListUpdateMediaCampaigns= new List<ADvendio__MediaCampaign__c>();
            //updated campaign Record Ids and  Status Map
            Map<Id, String> l_sMapUpdatedCampaign = new Map<Id, String>();
            //fetches the Campaign Line Item List.
            List<ADvendio__Campaign_Item__c> l_oListAllCampaignItems = new List<ADvendio__Campaign_Item__c>();

            // Prepare the List of Campaign Ids
            for (ADvendio__Campaign_Item__c l_oCampaignItem : p_oListCampaignItems) {
                l_iSetMediaCampaignIds.add(l_oCampaignItem.ADvendio__Media_Campaign__c);
            }

            if (l_iSetMediaCampaignIds != null && l_iSetMediaCampaignIds.size() > 0) {
                //fetches the Campaign Line Item List based on Campaign Ids
                l_oListAllCampaignItems = [
                    SELECT Id, SomDig_PositionStatus__c, ADvendio__Media_Campaign__c, ADvendio__Media_Campaign__r.SomDig_StatusPAMCockpit__c
                      FROM ADvendio__Campaign_Item__c
                     WHERE ADvendio__Media_Campaign__c IN :l_iSetMediaCampaignIds
                       AND ADvendio__Media_Campaign__r.SomDig_StatusPAMCockpit__c != 'neu'
                       AND ADvendio__Media_Campaign__r.SomDig_StatusPAMCockpit__c != 'Non AdServer'
                       AND SomDig_PositionStatus__c != 'NonAdServer'
                ];

                if (l_oListAllCampaignItems != null && l_oListAllCampaignItems.size() > 0) {

                    //Fetches the Campaign Records from Campaign Line Item records and put into Map.
                    for (ADvendio__Campaign_Item__c l_oCampaignItem : l_oListAllCampaignItems) {
                        if (l_oMapIdCampaignList.get(l_oCampaignItem.ADvendio__Media_Campaign__c) != null) {
                            List<ADvendio__Campaign_Item__c> l_oListAllCampignItems = l_oMapIdCampaignList.get(l_oCampaignItem.ADvendio__Media_Campaign__c);
                            l_oListAllCampignItems.add(l_oCampaignItem);
                            l_oMapIdCampaignList.put(l_oCampaignItem.ADvendio__Media_Campaign__c, l_oListAllCampignItems);
                        } else {
                            List<ADvendio__Campaign_Item__c> l_oListAllCampignItems = new List<ADvendio__Campaign_Item__c>();
                            l_oListAllCampignItems.add(l_oCampaignItem);
                            l_oMapIdCampaignList.put(l_oCampaignItem.ADvendio__Media_Campaign__c, l_oListAllCampignItems);
                        }
                    }
                }
            }

            for (ADvendio__Campaign_Item__c lineitem : p_oListCampaignItems) {
                if (lineitem.SomDig_PositionStatus__c == 'NonAdServer')
                    break;

                List<ADvendio__Campaign_Item__c> l_oListAllCampignItems = l_oMapIdCampaignList.get(lineitem.ADvendio__Media_Campaign__c);
                if (l_oListAllCampignItems != null && l_oListAllCampignItems.size() > 0) {

                    Integer n_lineItemCount = l_oListAllCampignItems.size();
                    Integer entwurf = 0, abgelaufen = 0, pausiert = 0, bereit = 0;
                    /*
                        1. If All Campaign Line Items have "Entwurf" status then it will update the Campaign Status to "neu"
                        2. If Campaign Line Items have "Entwurf" or "Pausiert" or "abgelaufen-erfüllt" or "abgelaufen-unterliefert" status
                            then it will update the Campaign Status to "to do"
                        3. If Campaign Line Items have "Bereit" or "Auslieferung-normal" or "Auslieferung-@Risk" status
                            then it will update the Campaign Status to "planmässig"
                    */
                    for (ADvendio__Campaign_Item__c l_oCampaignItem : l_oListAllCampignItems) {

                        if (l_oCampaignItem.SomDig_PositionStatus__c == 'Entwurf')
                            entwurf++;
                        if (l_oCampaignItem.SomDig_PositionStatus__c == 'abgelaufen-erfüllt' || l_oCampaignItem.SomDig_PositionStatus__c == 'abgelaufen-unterliefert')
                            abgelaufen++;
                        if (l_oCampaignItem.SomDig_PositionStatus__c == 'pausiert')
                            pausiert++;
                        if (l_oCampaignItem.SomDig_PositionStatus__c == 'bereit' || l_oCampaignItem.SomDig_PositionStatus__c == 'Auslieferung-normal' || l_oCampaignItem.SomDig_PositionStatus__c == 'Auslieferung-@Risk')
                            bereit++;

                        if (n_lineItemCount == entwurf) {
                            l_sMapUpdatedCampaign.put(l_oCampaignItem.ADvendio__Media_Campaign__c, 'neu');
                        } else if (entwurf > 0 || abgelaufen > 0 || pausiert > 0 || (bereit < n_lineItemCount && bereit > 0)) {
                            l_sMapUpdatedCampaign.put(l_oCampaignItem.ADvendio__Media_Campaign__c, 'to do');
                        } else if (bereit == n_lineItemCount) {
                            l_sMapUpdatedCampaign.put(l_oCampaignItem.ADvendio__Media_Campaign__c, 'planmässig');
                        }
                    }
                }
            }

            // Check if there are necessary updates on the MediaCampaigns
            Boolean any_MediaCampaigns_changed = false;
            for (ADvendio__Campaign_Item__c l_oCampaignItem : l_oListAllCampaignItems) {
                if (l_oCampaignItem.ADvendio__Media_Campaign__r.SomDig_StatusPAMCockpit__c != l_sMapUpdatedCampaign.get(l_oCampaignItem.ADvendio__Media_Campaign__c)) {
                    any_MediaCampaigns_changed = true;
                    break;
                }
            }

            //update the Campaign Status.
            if (any_MediaCampaigns_changed && l_sMapUpdatedCampaign != null && l_sMapUpdatedCampaign.size() > 0) {
                List<ADvendio__MediaCampaign__c> l_oListMediaCampaigns = [
                    SELECT Id, SomDig_StatusPAMCockpit__c
                      FROM ADvendio__MediaCampaign__c
                     WHERE Id In :l_sMapUpdatedCampaign.keyset()
                ];

                for (ADvendio__MediaCampaign__c l_oMediaCampaign : l_oListMediaCampaigns) {
                    l_oMediaCampaign.SomDig_StatusPAMCockpit__c = l_sMapUpdatedCampaign.get(l_oMediaCampaign.Id);
                    l_oListUpdateMediaCampaigns.add(l_oMediaCampaign);
                }

                if (l_oListUpdateMediaCampaigns != null && l_oListUpdateMediaCampaigns.size() > 0)
                    update l_oListUpdateMediaCampaigns;
            }
        }
    }

}