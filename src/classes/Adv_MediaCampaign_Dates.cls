public with sharing class Adv_MediaCampaign_Dates extends TriggerController {

    public Adv_MediaCampaign_Dates(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                   List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems
    ) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    protected override void runAfterInsert() {
        updateCampaignDates((List<ADvendio__Campaign_Item__c>)lstNewItems, null);
    }

    protected override void runAfterUpdate() {
        updateCampaignDates((List<ADvendio__Campaign_Item__c>)lstNewItems, (Map<Id, ADvendio__Campaign_Item__c>)mapOldItems);
    }

    protected override void runAfterDelete() {
        updateCampaignDates((List<ADvendio__Campaign_Item__c>)lstOldItems, null);
    }

    /*
        Method Name  : updateCampaignDates
        Parameters   : list of Campaign Line Items
        Return Type  : void
        Description  : This method is used to update the Dates of Media Campaign based Campaign Line Item Dates
        Created By   : Cognizant Technology Solutions
    */
    private void updateCampaignDates(List<ADvendio__Campaign_Item__c> p_oListCampaignItems, Map<Id, ADvendio__Campaign_Item__c> p_oMapOldCampaignItems) {

        // Only continue if there are any items which have changed date fields
        Boolean any_date_fields_changed = false;
        for (ADvendio__Campaign_Item__c new_CampaignItem : p_oListCampaignItems) {
            if ((p_oMapOldCampaignItems == null || new_CampaignItem.ADvendio__from_Date__c != p_oMapOldCampaignItems.get(new_CampaignItem.Id).ADvendio__from_Date__c) ||
                (p_oMapOldCampaignItems == null || new_CampaignItem.ADvendio__until_Date__c != p_oMapOldCampaignItems.get(new_CampaignItem.Id).ADvendio__until_Date__c)
            ) {
                any_date_fields_changed = true;
                break;
            }
        }

        if (any_date_fields_changed) {
            //variables declaration
            Map<Id, List<ADvendio__Campaign_Item__c>> l_oMapIdCampaignList = new Map<Id, List<ADvendio__Campaign_Item__c>>();
            Set<Id> l_iSetMediaCampaignIds = new Set<Id>();

            //updated campaign Record Ids List
            List<ADvendio__MediaCampaign__c> l_oListUpdateMediaCampaigns = new List<ADvendio__MediaCampaign__c>();

            //updated campaign Record Ids and  Status Map
            Map<Id, Date> l_sMapCampaignLetztesEnde = new Map<Id, Date>();
            Map<Id, Date> l_sMapCampaignNaechsterStart = new Map<Id, Date>();
            Map<Id, Date> l_sMapCampaignNaechstesEnde = new Map<Id, Date>();

            //fetches the Campaign Line Item List.
            List<ADvendio__Campaign_Item__c> l_oListAllCampaignItems = new List<ADvendio__Campaign_Item__c>();

            // Prepare the List of Campaign Ids
            for (ADvendio__Campaign_Item__c l_oCampaignItem : p_oListCampaignItems) {
                l_iSetMediaCampaignIds.add(l_oCampaignItem.ADvendio__Media_Campaign__c);
            }

            if (l_iSetMediaCampaignIds != null && l_iSetMediaCampaignIds.size() > 0) {
                //fetches the Campaign Line Item List based on Campaign Ids
                l_oListAllCampaignItems = [
                    SELECT Id, ADvendio__from_Date__c, ADvendio__until_Date__c,
                           ADvendio__Media_Campaign__c,
                           ADvendio__Media_Campaign__r.SomDig_LetzterPositionEnde__c,
                           ADvendio__Media_Campaign__r.SomDigNaechsterPositionStart__c,
                           ADvendio__Media_Campaign__r.SomDigNaechsterPositionEnde__c
                      FROM ADvendio__Campaign_Item__c
                     WHERE ADvendio__Media_Campaign__c IN :l_iSetMediaCampaignIds
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

            for (ADvendio__Campaign_Item__c l_oLineItem : p_oListCampaignItems) {
                List<ADvendio__Campaign_Item__c> l_oListCampaignItems = l_oMapIdCampaignList.get(l_oLineItem.ADvendio__Media_Campaign__c);

                if (l_oListCampaignItems != null && l_oListCampaignItems.size() > 0) {

                    Date l_dCampaignLetztesEnde, l_dCampaignNaechsterStart, l_dCampaignNaechstesEnde;
                    /*
                        1. If the until date is less than today and greater than previous until date, add to map
                        2. If the from date is greater than or equal to today and less than previous from date, add to map
                        3. If the until date is greater than or equal to today and less than previous until date, add to map
                    */
                    for (ADvendio__Campaign_Item__c l_oCampaignItem : l_oListCampaignItems) {
                        if (l_oCampaignItem.ADvendio__until_Date__c < System.today() && (l_dCampaignLetztesEnde == null || l_oCampaignItem.ADvendio__until_Date__c > l_dCampaignLetztesEnde))
                            l_dCampaignLetztesEnde = l_oCampaignItem.ADvendio__until_Date__c;

                        if (l_oCampaignItem.ADvendio__from_Date__c >= System.today() && (l_dCampaignNaechsterStart == null || l_oCampaignItem.ADvendio__from_Date__c < l_dCampaignNaechsterStart))
                            l_dCampaignNaechsterStart = l_oCampaignItem.ADvendio__from_Date__c;

                        if (l_oCampaignItem.ADvendio__until_Date__c >= System.today() && (l_dCampaignNaechstesEnde == null || l_oCampaignItem.ADvendio__until_Date__c < l_dCampaignNaechstesEnde))
                            l_dCampaignNaechstesEnde = l_oCampaignItem.ADvendio__until_Date__c;

                        l_sMapCampaignLetztesEnde.put(l_oCampaignItem.ADvendio__Media_Campaign__c, l_dCampaignLetztesEnde);
                        l_sMapCampaignNaechsterStart.put(l_oCampaignItem.ADvendio__Media_Campaign__c, l_dCampaignNaechsterStart);
                        l_sMapCampaignNaechstesEnde.put(l_oCampaignItem.ADvendio__Media_Campaign__c, l_dCampaignNaechstesEnde);
                    }
                }
            }

            // Check if there are necessary updates on the MediaCampaigns
            Boolean any_MediaCampaigns_changed = false;
            for (ADvendio__Campaign_Item__c l_oCampaignItem : l_oListAllCampaignItems) {
                if (l_oCampaignItem.ADvendio__Media_Campaign__r.SomDig_LetzterPositionEnde__c != l_sMapCampaignLetztesEnde.get(l_oCampaignItem.ADvendio__Media_Campaign__c) ||
                    l_oCampaignItem.ADvendio__Media_Campaign__r.SomDigNaechsterPositionStart__c != l_sMapCampaignNaechsterStart.get(l_oCampaignItem.ADvendio__Media_Campaign__c) ||
                    l_oCampaignItem.ADvendio__Media_Campaign__r.SomDigNaechsterPositionEnde__c != l_sMapCampaignNaechstesEnde.get(l_oCampaignItem.ADvendio__Media_Campaign__c)
                ) {
                    any_MediaCampaigns_changed = true;
                    break;
                }
            }

            //update the Campaign Dates
            if (any_MediaCampaigns_changed &&
                l_sMapCampaignLetztesEnde != null && l_sMapCampaignLetztesEnde.size() > 0 &&
                l_sMapCampaignNaechsterStart != null && l_sMapCampaignNaechsterStart.size() > 0 &&
                l_sMapCampaignNaechstesEnde != null && l_sMapCampaignNaechstesEnde.size() > 0) {

                List<ADvendio__MediaCampaign__c> l_oListMediaCampaigns = [
                    SELECT Id, SomDig_LetzterPositionEnde__c, SomDigNaechsterPositionStart__c, SomDigNaechsterPositionEnde__c
                      FROM ADvendio__MediaCampaign__c
                     WHERE Id IN :l_sMapCampaignNaechsterStart.keyset()
                ];
                for (ADvendio__MediaCampaign__c l_oMediaCampaign : l_oListMediaCampaigns) {
                    l_oMediaCampaign.SomDig_LetzterPositionEnde__c = l_sMapCampaignLetztesEnde.get(l_oMediaCampaign.Id);
                    l_oMediaCampaign.SomDigNaechsterPositionStart__c = l_sMapCampaignNaechsterStart.get(l_oMediaCampaign.Id);
                    l_oMediaCampaign.SomDigNaechsterPositionEnde__c = l_sMapCampaignNaechstesEnde.get(l_oMediaCampaign.Id);

                    l_oListUpdateMediaCampaigns.add(l_oMediaCampaign);
                }
                if (l_oListUpdateMediaCampaigns != null && l_oListUpdateMediaCampaigns.size() > 0)
                    update l_oListUpdateMediaCampaigns;
            }
        }
    }

}