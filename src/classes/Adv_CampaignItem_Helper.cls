public with sharing class Adv_CampaignItem_Helper {

    private static final Map<Id, Adv_CampaignItem_Helper> data = new Map<Id, Adv_CampaignItem_Helper>();


    public Id campaignItemId { get; set; }
    public Boolean isWaitingForCountries {
        get;
        set { isWaitingForCountries = value != null ? value : false; }
    }
    public Boolean isWaitingForRegions {
        get;
        set { isWaitingForRegions = value != null ? value : false; }
    }
    public Boolean isWaitingForCities {
        get;
        set { isWaitingForCities = value != null ? value : false; }
    }
    public Boolean isWaitingForKeyValues {
        get;
        set { isWaitingForKeyValues = value != null ? value : false; }
    }


    public Adv_CampaignItem_Helper(ADvendio__Campaign_Item__c campaignItem, ADvendio__Campaign_Item__c oldCampaignItem) {
        this.campaignItemId = campaignItem.Id;

        if (oldCampaignItem == null) {
            this.isWaitingForCountries = (campaignItem.ADvendio__SelectedCountryInformation__c != null);
            this.isWaitingForRegions   = (campaignItem.ADvendio__SelectedRegionInformation__c != null);
            this.isWaitingForCities    = (campaignItem.ADvendio__SelectedCityInformation__c != null);
            this.isWaitingForKeyValues = (campaignItem.ADvendio__AdKeyValues__c != null);
        } else {
            this.isWaitingForCountries = (campaignItem.ADvendio__SelectedCountryInformation__c != oldCampaignItem.ADvendio__SelectedCountryInformation__c);
            this.isWaitingForRegions   = (campaignItem.ADvendio__SelectedRegionInformation__c != oldCampaignItem.ADvendio__SelectedRegionInformation__c);
            this.isWaitingForCities    = (campaignItem.ADvendio__SelectedCityInformation__c != oldCampaignItem.ADvendio__SelectedCityInformation__c);
            this.isWaitingForKeyValues = (campaignItem.ADvendio__AdKeyValues__c != oldCampaignItem.ADvendio__AdKeyValues__c);
        }
    }


    public static Adv_CampaignItem_Helper load(Id theCampaignItemId) {
        return data.get(theCampaignItemId);
    }

    public static Adv_CampaignItem_Helper lazyLoad(ADvendio__Campaign_Item__c campaignItem, ADvendio__Campaign_Item__c oldCampaignItem) {
        Adv_CampaignItem_Helper helper = load(campaignItem.Id);
        if (helper == null) {
            helper = new Adv_CampaignItem_Helper(campaignItem, oldCampaignItem);
        }
        return helper;
    }

    public static Adv_CampaignItem_Helper lazyLoad(ADvendio__Campaign_Item__c campaignItem) {
        return lazyLoad(campaignItem, null);
    }

    public static Boolean allReady() {
        Boolean allReady = true;
        for (Adv_CampaignItem_Helper helper : data.values()) {
            if (!helper.isReady()) {
                allReady = false;
                break;
            }
        }
        return allReady;
    }

    public static Set<Id> getAllCampaignItemIds() {
        return data.keySet();
    }


    public void save() {
        data.put(campaignItemId, this);
    }

    public Boolean isReady() {
        return !(isWaitingForCountries || isWaitingForRegions || isWaitingForCities || isWaitingForKeyValues);
    }

}