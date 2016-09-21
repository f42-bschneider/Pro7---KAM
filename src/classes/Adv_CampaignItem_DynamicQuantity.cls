public with sharing class Adv_CampaignItem_DynamicQuantity extends TriggerController {

    public Adv_CampaignItem_DynamicQuantity(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    protected override void runBeforeUpdate() {
        calculateQuantityOfPacketComponentItem((List<ADvendio__Campaign_Item__c>) lstNewItems, (Map<Id, ADvendio__Campaign_Item__c>) mapNewItems, (Map<Id, ADvendio__Campaign_Item__c>) mapOldItems);
    }


    /**
     * Calculate the Quantity of Packet Component Items.
     *
     * @param   lstNewRecords   A list of ADvendio__Campaign_Item__c to check.
     * @param   lstNewRecords   A map of ADvendio__Campaign_Item__c to use for fast access.
     */
    private void calculateQuantityOfPacketComponentItem(List<ADvendio__Campaign_Item__c> lstNewRecords, Map<Id, ADvendio__Campaign_Item__c> mapNewRecords, Map<Id, ADvendio__Campaign_Item__c> mapOldRecords) {
        if(SomDig_SOQLOptimizer.iDynamicQuantityRun > 4) return;

        Map<Id, List<ADvendio__Campaign_Item__c>> mPacketItemId2ComponentItems = new Map<Id, List<ADvendio__Campaign_Item__c>>();

        // Get PacketItem Ids
        for (ADvendio__Campaign_Item__c ci : lstNewRecords) {
            if (ci.ADvendio__PacketItem__c != null && ci.ADvendio__Availability__c != mapOldRecords.get(ci.ID).ADvendio__Availability__c) {
                List<ADvendio__Campaign_Item__c> components = mPacketItemId2ComponentItems.get(ci.ADvendio__PacketItem__c);
                if (components == null) {
                    components = new List<ADvendio__Campaign_Item__c>();
                    mPacketItemId2ComponentItems.put(ci.ADvendio__PacketItem__c, components);
                }
                components.add(ci);
            }
        }

        if (mPacketItemId2ComponentItems.isEmpty()) {
            return;
        }

        // Check whether the type of placement referenced by one component campaign item is 'YouTube', and the BillingCategroy of packet and all components are 'CPM'.
        List<ADvendio__Campaign_Item__c> listCampaignItems = new List<ADvendio__Campaign_Item__c>([Select Id, ADvendio__Quantity__c,
                                                        ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Typ__c,
                                                        (Select Id, ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Typ__c
                                                         From ADvendio__PacketComponents__r
                                                         Where ADvendio__Billing_category__c='CPM')
                                                      From ADvendio__Campaign_Item__c
                                                      Where Id IN :mPacketItemId2ComponentItems.keySet()
                                                            AND ADvendio__Billing_category__c='CPM'
                                                            AND ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Distribution__c = 'Prorated']);
        System.Debug('++++++SELECT von DynamicQuantity');
        if(!listCampaignItems.isEmpty())
            SomDig_SOQLOptimizer.iDynamicQuantityRun++;

        for (ADvendio__Campaign_Item__c packetItem : listCampaignItems)
        {
            List<ADvendio__Campaign_Item__c> components = mPacketItemId2ComponentItems.get(packetItem.Id);

            // It is assuemed that all component items that belongs to a packet
            // will be always updated together!
            if (packetItem.ADvendio__PacketComponents__r.size() != components.size()) {
                // Not expected, just assume because of BillingCategroy.
                System.debug('\n\n Packet: ' +  packetItem.Id + ', expected number of components: ' + packetItem.ADvendio__PacketComponents__r.size() +
                             ', actual: ' + components.size() + '\n');
                continue;
            }

            Boolean hasYouTube = false;
            Boolean con = true;

            Decimal sumAvai = 0;

            for (ADvendio__Campaign_Item__c ci : components) {
                // Check whether the type of placement referenced by one component campaign item is 'YouTube'.
                if (!hasYouTube) {
                    String typ = null;

                    for (ADvendio__Campaign_Item__c packetComponent : packetItem.ADvendio__PacketComponents__r) {
                        if (ci.Id == packetComponent.Id) {
                            try {
                                typ = packetComponent.ADvendio__Ad_Price__r.ADvendio__Ad_Spec__r.ADvendio__Placement__r.SomDig_Typ__c;
                            } catch (Exception e) {
                            }
                            break;
                        }
                    }

                    if ('YouTube'.equals(typ)) {
                        hasYouTube = true;
                    }
                }

                // Should have a ADvendio__Availability__c and was done in the last 15 minutes.
                if (ci.ADvendio__Availability__c != null && ci.ADvendio__LastAvailabilityForecast__c != null &&
                    (System.now().millisecondGmt() - ci.ADvendio__LastAvailabilityForecast__c.millisecondGmt()) <= 300000)
                {
                    sumAvai = sumAvai + ci.ADvendio__Availability__c;
                } else {
                    con = false;
                    break;
                }
            }

            System.debug('\n\n Packet \'' +  packetItem.Id + '\', has YouTube components: ' + hasYoutube + ', condition fullfiled: ' + con + '\n');

            if (hasYouTube == true && con == true) {
                //for each package component campaign item, calculate the quantity proportionally based on its Availability
                //and the sum of the Availability of all package component campaign items
                calculateProratedPackageQuantity(packetItem, components, sumAvai);
            }
        }
    }

    /**
     * Calculate the quantity proportionally based on its Availability and the sum of the Availability of all package component campaign items.
     */
    public static void calculateProratedPackageQuantity(ADvendio__Campaign_Item__c packetItem, List<ADvendio__Campaign_Item__c> components, Decimal sumAvai) {
        List<ADvendio__Campaign_Item__c> cisToReorder = components.clone();
        Boolean moreReorderToDo = true;
        Decimal deliveredSum = 0;
        Decimal availableSum = 0;

        while (moreReorderToDo && !cisToReorder.isEmpty()) { // calculate the prorated factor
            moreReorderToDo = false;
            Integer i = 0;
            while (i < cisToReorder.size()) {
                ADvendio__Campaign_Item__c ci = cisToReorder[i];

                Decimal deliveredWithMinimum    = Math.max((ci.ADvendio__Delivered_Impressions__c == null ? 0 : ci.ADvendio__Delivered_Impressions__c), 10);
                // If there were more impressions delivered that would be calculated via the availability, we set prorated = delivered / package.quantity ...
                if (ci.ADvendio__Availability__c != null &&
                    Math.floor(ci.ADvendio__Availability__c / sumAvai * packetItem.ADvendio__Quantity__c) < deliveredWithMinimum) {
                    ci.ADvendio__Prorated__c = deliveredWithMinimum / packetItem.ADvendio__Quantity__c * 100.0;
                    // ... and add the factor x to sumAvai to keep the calculation of other Campaign Items correct.
                    deliveredSum += deliveredWithMinimum;
                    availableSum += ci.ADvendio__Availability__c;
                    // Factor x is calculated by the availability, delivered impressions and the sum of all availabilities.
                    // If other Campaign Items were adjusted previously, we have to add the availability and delivered impressions values to our calculation
                    Decimal x = (deliveredSum * sumAvai - packetItem.ADvendio__Quantity__c * availableSum ) / (packetItem.ADvendio__Quantity__c - deliveredSum);
                    sumAvai += x;
                    availableSum += x;
                    cisToReorder.remove(i);
                    moreReorderToDo = true;
                } else if (ci.ADvendio__Availability__c != null) { // recalculate the prorated factor for Campaign Items that have delivered less.
                    ci.ADvendio__Prorated__c = 100 * ci.ADvendio__Availability__c / sumAvai; // This line is called for each remaining item on the last run of the while loop.
                    i++;
                }
            }
        }
        if (cisToReorder.isEmpty()) { // If more impressions were delivered than sold throw an error
            for (ADvendio__Campaign_Item__c ci : components) {
                ci.addError(System.Label.ErrorProratedPackageTooMuchDelivery);
            }
        }
        Decimal totalQuantity = 0;
        for (ADvendio__Campaign_Item__c ci : components) { // calculate the quantity
            ci.ADvendio__Quantity__c = Math.floor(packetItem.ADvendio__Quantity__c * ci.ADvendio__Prorated__c / 100);

            //ci.ADvendio__Quantity__c = ci.ADvendio__Quantity__c < 10.0 ? 10.0 : ci.ADvendio__Quantity__c;
            totalQuantity += ci.ADvendio__Quantity__c;
        }

        if (totalQuantity != packetItem.ADvendio__Quantity__c) {
            components.get(components.size()-1).ADvendio__Quantity__c += packetItem.ADvendio__Quantity__c - totalQuantity;
        }
    }
}