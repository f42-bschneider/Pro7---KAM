/**
 *  The trigger controller class for sObject OpportunityLineItem.
 */
public with sharing class OpportunityLineItemTrigger extends TriggerController {
    /**
     * Constructor.
     * @see TriggerController   The base class of trigger controller.
     */
    public OpportunityLineItemTrigger(Boolean isAfter, Boolean isBefore,
            Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    /**
     * Override method to perform action before an insert operation was fired.
     * @see TriggerController#runBeforeInsert
     */
    protected override void runBeforeInsert() {
        copyDataFromOpportunity();
    }

    /**
     * Override method to perform action before an update operation was fired.
     * @see TriggerController#runBeforeUpdate
     */
    protected override void runBeforeUpdate() {
        copyDataFromOpportunity();
    }

    /**
     * Override method to perform action after a delete operation was fired.
     * @see TriggerController#runAfterDelete
     */
    protected override void runAfterDelete() {
        updateAdFactoryProject();
        updateOpportunityMN3();
    }

    /**
     * Override method to perform action after an insert operation was fired.
     * @see TriggerController#runAfterInsert
     */
    protected override void runAfterInsert() {
        updateAdFactoryProject();
        updateOpportunityMN3();
    }

    /**
     * Override method to perform action after an undelete operation was fired.
     * @see TriggerController#runAfterUndelete
     */
    protected override void runAfterUndelete() {
        updateAdFactoryProject();
        updateOpportunityMN3();
    }

    /**
     * Override method to perform action after an update operation was fired.
     * @see TriggerController#runAfterUpdate
     */
    protected override void runAfterUpdate() {
        updateAdFactoryProject();
        updateOpportunityMN3();
    }

    /**
     * Copy data from Opportunity.
     */
    private void copyDataFromOpportunity() {
        // Perform this action only for before events, so that OpportunityLienItems can be modifified directly without "update" them agaign.
        if (isBefore) {
            // Current redords to process.
            List<OpportunityLineItem> lstNewRecords = isDelete ? (List<OpportunityLineItem>)lstOldItems : (List<OpportunityLineItem>)lstNewItems;

            if (lstNewRecords != null) {
                Set<Id> oppIds = new Set<Id>();

                for (OpportunityLineItem oli : lstNewRecords) {
                    oppIds.add(oli.OpportunityId);
                }

                oppIds.remove(null);
                if (!oppIds.isEmpty()) {
                    Map<Id, Opportunity> mOpps = new Map<Id, Opportunity>([SELECT Id, SomTv_AdFProjekt__c FROM Opportunity WHERE Id IN :oppIds AND isDeleted = false]);

                    for (OpportunityLineItem oli : lstNewRecords) {
                        oli.SomTv_Projektname__c = mOpps.containsKey(oli.OpportunityId) ? mOpps.get(oli.OpportunityId).SomTv_AdFProjekt__c : null;
                    }
                }
            }
        }

        return;
    }

    /**
     * Update data in AdFactoryProject if required.
     */
    private void updateAdFactoryProject() {
        /*
        Es soll ein Trigger entwickelt werden, der, nach folgenden Bedingungen, Beträge der zugeordneten Oli´s im Objekt SomTv_AdfProjekt_c setzt bzw. berechnet.

        Folgende Berechnungen NUR für Oli.SomTv_OliRabattierfaehig__c=true:
        - SomTv_AdfProjekt_r.SomTv_MB3Rabattierfaehig__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Rabattierfaehig__c = SUM von Oli.SomTv_MB1__c
        - SomTv_AdfProjekt_r.SomTv_BRRabattierfaehig__c =
        (SUM von(Oli.SomTv_MB1__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Rabattierfaehig__c
        - SomTv_AdfProjekt_r.SomTv_MN1Rabattierfaehig__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Rabattierfaehig__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Rabattierfaehig__c = SUM von Oli.SomTv_MN3__c

        Folgende Berechnungen NUR für Oli.Product2.SomTv_Produkthierarchieebene1__c="3. Placements":
        - SomTv_AdfProjekt_r.SomTv_MB3Placements__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Placements__c = SUM von Oli.SomTv_MB1__c
        - SomTv_AdfProjekt_r.SomTv_BRPlacements__c =
        (SUM von(Oli.SomTv_MB1__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Placements__c
        - SomTv_AdfProjekt_r.SomTv_MN1Placements__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Placements__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Placements__c = SUM von Oli.SomTv_MN3__c

        Folgende Berechnungen NUR für Oli.Product2.SomTv_Produkthierarchieebene1__c="6. Lizenzierung":
        - SomTv_AdfProjekt_r.SomTv_MB3Lizenz__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Lizenz__c = SUM von Oli.SomTv_MB1__c
        - SomTv_AdfProjekt_r.SomTv_BRLizenz__c =
        (SUM von(Oli.SomTv_MB1__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Lizenz__c
        - SomTv_AdfProjekt_r.SomTv_MN1Lizenz__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Lizenz__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Lizenz__c = SUM von Oli.SomTv_MN3__c

        Folgende Berechnungen NUR für Oli.SomTv_OliRabattierfaehig__c=true && Oli.SomTv_Innerhalb_Commitment__c ="nein":
        - SomTv_AdfProjekt_r.SomTv_MB3Tvfrei__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Tvfrei__c = SUM von Oli.SomTv_MB1__c
        - SomTv_AdfProjekt_r.SomTv_BRTvfrei__c =
        (SUM von(Oli.SomTv_MB1__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Tvfrei__c
        - SomTv_AdfProjekt_r.SomTv_MN1Tvfrei__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Tvfrei__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Tvfrei__c = SUM von Oli.SomTv_MN3__c

        Folgende Berechnungen über ALLE Oli:
        - SomTv_AdfProjekt_r.SomTv_MB3Gesamt__c = SUM von Oli.SomTv_MB3_Kopf__c
        - SomTv_AdfProjekt_r.SomTv_MB1Gesamt__c = SUM von Oli.SomTv_MB1__c
        - SomTv_AdfProjekt_r.SomTv_BRGesamt__c =
        (SUM von(Oli.SomTv_MB1__c*Oli.BR__c)) / SomTv_AdfProjekt_r.SomTv_MB1Gesamt__c
        - SomTv_AdfProjekt_r.SomTv_MN1Gesamt__c = SUM von Oli.SomTV_MN1__c
        - SomTv_AdfProjekt_r.SomTv_MN2Gesamt__c = SUM von Oli.SomTv_MN2__c
        - SomTv_AdfProjekt_r.SomTv_MN3Gesamt__c = SUM von Oli.SomTv_MN3__c
        */

        // Update data only for after events.
        if (isAfter) {
            // Current redords to process.
            List<OpportunityLineItem> lstNewRecords	= isDelete ? (List<OpportunityLineItem>)lstOldItems : (List<OpportunityLineItem>)lstNewItems;
            // Old records, used to check whether rollup realy required.
            Map<Id, OpportunityLineItem> mapOldRecords = isUpdate ? (Map<Id, OpportunityLineItem>)mapOldItems : null;

            if (lstNewRecords != null) {
                Set<Id> adFactoryProjectIds = new Set<Id>();

                for (OpportunityLineItem oli : lstNewRecords) {
                    if (mapOldRecords == null) {
                        // Should be inserted, deleted, undeleted
                        adFactoryProjectIds.add(oli.SomTv_Projektname__c);  // SomTv_Projektname__c is actually a lookup, not a name.
                    } else {
                        // Should be updated
                        OpportunityLineItem oldOli = mapOldRecords.get(oli.Id);
                        if (oldOli == null ||
                            oli.UnitPrice != oldOli.UnitPrice ||
                            oli.SomTv_DispoPreisprozent__c != oldOli.SomTv_DispoPreisprozent__c ||
                            oli.SomTv_AE_inProzent__c != oldOli.SomTv_AE_inProzent__c ||
                            oli.SomTv_Skonto__c != oldOli.SomTv_Skonto__c ||
                            oli.SomTv_Projektname__c != oldOli.SomTv_Projektname__c ||
                            oli.SomTv_MB3_Kopf__c != oldOli.SomTv_MB3_Kopf__c ||
                            oli.SomTv_MB1__c != oldOli.SomTv_MB1__c ||
                            oli.BR__c != oldOli.BR__c ||
                            oli.SomTV_MN1__c != oldOli.SomTV_MN1__c ||
                            oli.SomTV_MN2__c != oldOli.SomTV_MN2__c ||
                            oli.SomTV_MN3__c != oldOli.SomTV_MN3__c ||
                            oli.SomTv_OliRabattierfaehig__c != oldOli.SomTv_OliRabattierfaehig__c ||
                            oli.SomTv_Produkthierarchiebene1__c != oldOli.SomTv_Produkthierarchiebene1__c ||
                            oli.SomTv_Innerhalb_Commitment__c != oldOli.SomTv_Innerhalb_Commitment__c)
                        {
                            // Conditions for data updating in AdFactoryProject changed.
                            adFactoryProjectIds.add(oli.SomTv_Projektname__c);	  // SomTv_Projektname__c is actually a lookup, not a name.
                            adFactoryProjectIds.add(oldOli.SomTv_Projektname__c);   // SomTv_Projektname__c is actually a lookup, not a name.
                        }
                    }
                }

                adFactoryProjectIds.remove(null);

                if (!adFactoryProjectIds.isEmpty()) {
                    AdfProjektChecker apc = new AdfProjektChecker();
                    //apc.setAdfProjektIds(adFactoryProjectIds);
                    //Database.executeBatch(apc, 10);

                    Database.BatchableContext bc = null;
                    List<SomTv_AdfProjekt__c> records = [SELECT Id FROM SomTv_AdfProjekt__c WHERE Id IN :adFactoryProjectIds AND isDeleted = false];
                    apc.execute(bc, records);
                }
            }
        }

        return;
    }

    /**
     * Update MN3__c in Opportunity if required.
     */
    private void updateOpportunityMN3() {
        // Update data only for after events.
        if (isAfter) {
            // Current redords to process.
            List<OpportunityLineItem> lstNewRecords	= isDelete ? (List<OpportunityLineItem>)lstOldItems : (List<OpportunityLineItem>)lstNewItems;
            // Old records, used to check whether rollup realy required.
            Map<Id, OpportunityLineItem> mapOldRecords = isUpdate ? (Map<Id, OpportunityLineItem>)mapOldItems : null;

            if (lstNewRecords != null) {
                Set<Id> oppIds = new Set<Id>();

                for (OpportunityLineItem oli : lstNewRecords) {
                    if (mapOldRecords == null) {
                        // Should be inserted, deleted, undeleted
                        oppIds.add(oli.OpportunityId);
                    } else {
                        // Should be updated
                        // SomTv_MN3__c = SomTv_MB1Bezahlt__c*(1-BR__c)*(1-SomTv_AE_inProzent__c)*(1-SomTv_Skonto__c)
                        // SomTv_MB1Bezahlt__c = IF(ISBLANK(TEXT(SomTv_NrGoodwill__c)), SomTv_MB1__c * SomTv_DispoPreisprozent__c, 0)
                        // SomTv_MB1__c = IF(ISBLANK(TEXT(SomTv_NrGoodwill__c)), UnitPrice , 0)
                        OpportunityLineItem oldOli = mapOldRecords.get(oli.Id);
                        if (oldOli == null ||
                            oli.UnitPrice != oldOli.UnitPrice ||
                            oli.SomTv_NrGoodwill__c != oldOli.SomTv_NrGoodwill__c ||
                            oli.SomTv_DispoPreisprozent__c != oldOli.SomTv_DispoPreisprozent__c ||
                            oli.SomTv_Skonto__c != oldOli.SomTv_Skonto__c ||
                            oli.SomTv_AE_inProzent__c != oldOli.SomTv_AE_inProzent__c ||
                            oli.BR__c != oldOli.BR__c)
                        {
                            // Conditions for data updating in Opportunity changed.
                            oppIds.add(oli.OpportunityId);
                        }
                    }
                }

                SomTv_Opportunity_ValidateData.updateMN3OfOpportinityByIds(oppIds);
            }
        }

        return;
    }


    /**
     * A test methode.
     */
    @isTest
    public static void testOpportunityLineItemTrigger() {
        Test.startTest();

        // Test AdFactoryProject
        Id recordTypeId = null;

        for (RecordType r : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'SomTv_Commitment' LIMIT 1]) {
            recordTypeId = r.Id;
        }
        System.assert(recordTypeId!=null, 'No RecordType \'SomTv_Commitment\' for Opportunity found!');

        Product2 prod = new Product2(Name = 'Test Product', SomTv_Produkthierarchieebene1__c='3. Placements');
        insert prod;

        PricebookEntry pbe = new PricebookEntry(UnitPrice=1, Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive=true, UseStandardPrice=false);
        insert pbe;

        SomTv_AdfProjekt__c ap = new SomTv_AdfProjekt__c();
        insert ap;

        Account acc = new Account(Name='Test Account', ProRex_Rolle__c='Kunde', SomTv_HilfsfeldProRexRolle__c='Kunde');
        insert acc;

        Opportunity opp = new Opportunity(Name='Test Opportunity', AccountId=acc.Id, RecordTypeId=recordTypeId, StageName='Angebot abgegeben', CloseDate=System.today(), Amount = 1000, SomTv_AdFProjekt__c = ap.Id);
        insert opp;

        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbe.Id, Quantity=1, TotalPrice=1, SomTv_MN3_1FS__c=100, SomTv_DispoPreisprozent__c=10, SomTv_OliRabattierfaehig__c=true);
        insert oli;

        oli = [SELECT Id, SomTv_MB3_Kopf__c FROM OpportunityLineItem WHERE Id = :oli.Id];
        ap  = [SELECT Id, SomTv_MB3Gesamt__c FROM SomTv_AdfProjekt__c WHERE Id = :ap.Id];

        oli.SomTv_MB3_Kopf__c = oli.SomTv_MB3_Kopf__c == null ? 0.0 : oli.SomTv_MB3_Kopf__c;
        ap.SomTv_MB3Gesamt__c = ap.SomTv_MB3Gesamt__c == null ? 0.0 : ap.SomTv_MB3Gesamt__c;

        System.assertEquals(oli.SomTv_MB3_Kopf__c, ap.SomTv_MB3Gesamt__c);

        //oli.SomTv_NrProzent__c = 15; --> auskommentiert, weil Feld gem CRMSALES-1018 gelöscht werden soll
        //update oli;

        //oli = [SELECT Id, SomTv_MB3_Kopf__c FROM OpportunityLineItem WHERE Id = :oli.Id];
        //ap  = [SELECT Id, SomTv_MB3Gesamt__c FROM SomTv_AdfProjekt__c WHERE Id = :ap.Id];

        //System.assertEquals(oli.SomTv_MB3_Kopf__c, ap.SomTv_MB3Gesamt__c);

        delete oli;

        ap  = [SELECT Id, SomTv_MB3Gesamt__c FROM SomTv_AdfProjekt__c WHERE Id = :ap.Id];

        System.assertEquals(0, ap.SomTv_MB3Gesamt__c);

        // Test MN3 of Opportunity
        recordTypeId = null;
        for (RecordType r : [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'SomTv_AdFactory' LIMIT 1]) {
            recordTypeId = r.Id;
        }
        System.assert(recordTypeId!=null, 'No RecordType \'SomTv_AdFactory\' for Opportunity found!');

        opp = new Opportunity(Name='Test Opportunity', AccountId=acc.Id, RecordTypeId=recordTypeId, StageName='Angebot abgegeben', CloseDate=System.today(), Amount = 1000);
        insert opp;

        oli = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pbe.Id, Quantity=1, TotalPrice=1, SomTv_MN3_1FS__c=100, SomTv_DispoPreisprozent__c=100);
        insert oli;

        opp = [SELECT Id, SomTV_MN3__c FROM Opportunity WHERE Id = :opp.Id];
        oli = [SELECT Id, SomTV_MN3__c FROM OpportunityLineItem WHERE Id = :oli.Id];
        System.assertEquals(opp.SomTV_MN3__c, oli.SomTV_MN3__c);

        Test.stopTest();
    }

}