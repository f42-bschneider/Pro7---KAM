public with sharing class Adv_CampaignItem_DeliverPrio extends TriggerController {

    public Adv_CampaignItem_DeliverPrio(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
                                        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems) {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    // 'Empty' constructor for test class Adv_CampaignItem_DeliverPrio_Test
    public Adv_CampaignItem_DeliverPrio() {}

    protected override void runBeforeInsert() {
        calculatePriority((List<ADvendio__Campaign_Item__c>) lstNewItems);
    }

    protected override void runBeforeUpdate() {
        calculatePriority((List<ADvendio__Campaign_Item__c>) lstNewItems);
    }


    /*
     * Static variable for the list of all SomDig_DeliverPrio__c datasets
     */
    @testvisible private static List<SomDig_DeliverPrio__c> cachedPrioDatasets {
        get {
            if (cachedPrioDatasets == null) {
                cachedPrioDatasets = [
                    SELECT Id, SomDig_Gueltig_ab__c, SomDig_Gueltig_bis__c, SomDig_Abrechungsart__c, SomDig_Ad_Type__c,
                           SomDig_Belegungseinheitstyp__c, SomDig_Mediagattungsdifferenzierung__c, SomDig_Rotationstyp__c,
                           SomDig_Werbeform_Kurzform__c, SomDig_Auftragstyp__c, SomDig_Prio__c
                      FROM SomDig_DeliverPrio__c
                  ORDER BY SomDig_Werbeform_Kurzform__c DESC, SomDig_Rotationstyp__c DESC
                ];
            }
            return cachedPrioDatasets;
        }
        set;
    }

    /*
     * Static variable for the SomDig_PrioModell_Fehler email template
     */
    private static Boolean emailTemplateMissing = false;
    private static EmailTemplate cachedEmailTemplate {
        get {
            if (emailTemplateMissing) {
                return null;
            } else {
                if (cachedEmailTemplate == null) {
                    String name = 'SomDig_PrioModell_Fehler';
                    try {
                        cachedEmailTemplate = [SELECT Id, Name, body FROM EmailTemplate WHERE developername = :name];
                    } catch (Exception e) {
                        System.debug('Email template not found: ' + name);
                        emailTemplateMissing = true;
                    }
                }
                return cachedEmailTemplate;
            }
        }
        set;
    }

    /**
     * Search for an avialable priority for each campaign item.
     * If some exist it will be assigned to the current Campaign Item
     * Else an E-Mail notification will be send to the current user and the admin
     *
     */
    private void calculatePriority(List<ADvendio__Campaign_Item__c> listNewItems) {
        /**
         * Holds elements that meets the following criteria:
         * - ADvendio__from_Date__c >= prio.SomDig_Gueltig_ab__c
         * - ADvendio__until_Date__c <= prio.SomDig_Gueltig_bis__c
         * - SomDig_MediagattungsDifferenzierung__c == prio.SomDig_Mediagattungsdifferenzierung__c
         * - SomDig_AdvertisingFormShortform__c == prio.SomDig_Werbeform_Kurzform__c
         * - SomDig_Auftragstyp__c == prio.SomDig_Auftragstyp__c
         * - ADvendio__Billing_category__c == prio.SomDig_Abrechungsart__c
         * - SomDig_Rotationstyp__c == prio.SomDig_Rotationstyp__c
         * - SomDig_NetworkType__c == prio.SomDig_Belegungseinheitstyp__c
         */
        List<SomDig_DeliverPrio__c> step1 = new List<SomDig_DeliverPrio__c>();

        /**
         * The same as step1 but WITHOUT
         * - SomDig_AdvertisingFormShortform__c == prio.SomDig_Werbeform_Kurzform__c
         */
        List<SomDig_DeliverPrio__c> step2 = new List<SomDig_DeliverPrio__c>();

        /**
         * The same as step1 but WITHOUT
         * - SomDig_AdvertisingFormShortform__c == prio.SomDig_Werbeform_Kurzform__c
         * - SomDig_Rotationstyp__c == prio.SomDig_Rotationstyp__c
         */
        List<SomDig_DeliverPrio__c> step3 = new List<SomDig_DeliverPrio__c>();

        List<ADvendio__Campaign_Item__c> toManyElementsError = new List<ADvendio__Campaign_Item__c>();

        // List contains Campaign items where no valid 'SomDig_DeliverPrio__c' is available
        List<ADvendio__Campaign_Item__c> noPriorityError = new List<ADvendio__Campaign_Item__c>();

        if (mapNewItems != null) {
            /**
             * For each Campaign item go through all available 'SomDig_DeliverPrio__c'
             */
            for (ADvendio__Campaign_Item__c campaignItem : listNewItems) {
                if (cachedPrioDatasets.isEmpty()) {
                    System.debug('Priority List is empty');
                    noPriorityError.add(campaignItem);
                    continue;
                }

                for (SomDig_DeliverPrio__c prio : cachedPrioDatasets) {
                    Boolean isDatevalid = false;
                    Boolean isAbrechnungsart = false;
                    Boolean isAuftragstyp = false;
                    Boolean isBelegungseinheit = false;
                    Boolean isMediagattungsdifferenz = false;
                    Boolean isRotationstyp = false;
                    Boolean isWerbeform_Kurzform = false;

                    System.debug('###Prio: Prio' + prio.SomDig_Prio__c);

                    if (campaignItem.ADvendio__from_Date__c >= prio.SomDig_Gueltig_ab__c && campaignItem.ADvendio__until_Date__c <= prio.SomDig_Gueltig_bis__c) {
                        isDateValid = true;
                    }
                    if (campaignItem.SomDig_MediagattungsDifferenzierung__c == prio.SomDig_Mediagattungsdifferenzierung__c) {
                        isMediagattungsdifferenz = true;
                    }
                    String shortform = campaignItem.SomDig_AdvertisingFormShortform__c;
                    if (shortform != null && shortform.equals(prio.SomDig_Werbeform_Kurzform__c)) {
                        isWerbeform_Kurzform = true;
                    }
                    String auftragstyp = campaignItem.SomDig_Auftragstyp__c;
                    if (auftragstyp != null && auftragstyp == prio.SomDig_Auftragstyp__c) {
                        isAuftragstyp = true;
                    }
                    if (campaignItem.ADvendio__Billing_category__c.equals(prio.SomDig_Abrechungsart__c)) {
                        isAbrechnungsart = true;
                    }
                    if (campaignItem.SomDig_Rotationstyp__c == prio.SomDig_Rotationstyp__c) {
                        isRotationstyp = true;
                    }
                    if (campaignItem.SomDig_NetworkType__c == prio.SomDig_Belegungseinheitstyp__c) {
                        isBelegungseinheit = true;
                    }

                    System.debug('###Prio: isAbrechnungsart ' + isAbrechnungsart);
                    System.debug('###Prio: isAuftragstyp ' + isAuftragstyp);
                    System.debug('###Prio: isBelegungseinheit ' + isBelegungseinheit);
                    System.debug('###Prio: isMediagattungsdifferenz ' + isMediagattungsdifferenz);
                    System.debug('###Prio: isRotationstyp ' + isRotationstyp);
                    System.debug('###Prio: isWerbeform_Kurzform ' + isWerbeform_Kurzform);

                    // If true add this item to the list: step1
                    if (isDateValid && isAbrechnungsart && isAuftragstyp && isBelegungseinheit && isMediagattungsdifferenz && isRotationstyp && isWerbeform_Kurzform) {
                        System.debug('###Prio: Step1');
                        if (step1.isEmpty()) {
                            System.debug('###Prio: Step1-Ok');
                            campaignItem.ADvendio__Priority__c = prio.SomDig_Prio__c;
                            campaignItem.ADvendio__AdType__c = prio.SomDig_Ad_Type__c;
                            break;
                        } else {
                            System.debug('###Prio: Step1-Fehler');
                            toManyElementsError.add(campaignItem);
                        }

                    // If true add this item to the list: step2
                    } else if (isDateValid && isAbrechnungsart && isAuftragstyp && isBelegungseinheit && isMediagattungsdifferenz && isRotationstyp && prio.SomDig_Werbeform_Kurzform__c == null) {
                        System.debug('###Prio: Step2');
                        if (step2.isEmpty()) {
                            System.debug('###Prio: Step2-Ok');
                            campaignItem.ADvendio__Priority__c = prio.SomDig_Prio__c;
                            campaignItem.ADvendio__AdType__c = prio.SomDig_Ad_Type__c;
                            break;
                        } else {
                            System.debug('###Prio: Step2-Fehler');
                            toManyElementsError.add(campaignItem);
                        }

                    // If true add this item to the list: step3
                    } else if (isDateValid && isAbrechnungsart && isAuftragstyp && isBelegungseinheit && isMediagattungsdifferenz && prio.SomDig_Werbeform_Kurzform__c == null && prio.SomDig_Rotationstyp__c == null ) {
                        System.debug('###Prio: Step3');
                        if (step3.isEmpty()) {
                            System.debug('###Prio: Step3-Ok');
                            campaignItem.ADvendio__Priority__c = prio.SomDig_Prio__c;
                            campaignItem.ADvendio__AdType__c = prio.SomDig_Ad_Type__c;
                            break;
                        } else {
                            System.debug('###Prio: Step3-Fehler');
                            toManyElementsError.add(campaignItem);
                        }
                    } else {
                       // noPriorityError.add(campaignItem);
                    }
                }
            }
        }
        if (!toManyElementsError.isEmpty()) {
            sendToManyElementsNotification(toManyElementsError);
        }
        if (!noPriorityError.isEmpty()) {
            sendNoPriorityFoundNotification(noPriorityError);
        }
    }


    /**
     * Sends an E-Mail to the current user and the admin with all campaign items where two or more priorities are found.
     * This can just occur in a case when the trigger that checks if a new inserted 'SomDig_DeliverPrio__c' is already available, is not running.
     * @see SomDig_Prio_DoubleChck
     */
    @TestVisible private void sendToManyElementsNotification(List<ADvendio__Campaign_Item__c> listCampaignItems) {
        String[] toRecipients = new String[]{ UserInfo.getUserEmail() };
        String[] ccRecipients = new String[]{ 'salesforce-admins@prosiebensat1.de' };

        sendNotification(listCampaignItems, toRecipients, ccRecipients);

        System.debug('E-Mail To Many Elements Error versendet');
    }

    /**
     * Sends an E-Mail to the current user with all campaign items where no priority could be found.
     */
    @TestVisible private void sendNoPriorityFoundNotification(List<ADvendio__Campaign_Item__c> listCampaignItems) {
        String[] toRecipients = new String[]{ UserInfo.getUserEmail() };

        // keine Benachrichtigung an Admins, KV01462, 02.10.2014
        //String[] ccRecipients = new String[]{ 'salesforce-admins@prosiebensat1.de' };

        sendNotification(listCampaignItems, toRecipients, null);

        System.debug('E-Mail NoPriorityFound versendet');
    }

    /* Helper method for sending email notifications
     * Accepts lists of campaignItems, to-Addresses and cc-Addresses
     */
    private void sendNotification(List<ADvendio__Campaign_Item__c> listCampaignItems, List<String> toRecipients, List<String> ccRecipients) {
        if (cachedEmailTemplate != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toRecipients);
            if (ccRecipients != null)
                mail.setCcAddresses(ccRecipients);

            String body = cachedEmailTemplate.body;
            String replace = '';
            for (ADvendio__Campaign_Item__c item : listCampaignItems) {
                replace += 'https://' + ClsHelper.getSfSubdomain() + '.salesforce.com/' + item.Id + '\n';
            }

            String newBody = body.replace('{!campaignItemPrioError}', replace);
            mail.setPlainTextBody(newBody);

            if (!System.Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
            }
        }
    }

}