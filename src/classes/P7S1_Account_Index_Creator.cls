/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_Account_Index_Creator.cls
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.3
* @ date         26.10.2015
* @description
* @last change  03.11.2015 VVR Added delete method
                01.12.2015 VVR Added validation for index only for Account.P7S1_AccountIndexErzeugen__c = true
                09.12.2015 VVR Patch for Name with only 80 letters                
* @objects     Account, P7S1_AccountIndex__c
* =================================================================
*/
public without sharing class P7S1_Account_Index_Creator extends TriggerController {

    @Testvisible static boolean doUpdate = true;

    /**
    * Methodname    P7S1_Account_Index_Creator
    * @description  Constructor
    * @param        Trigger based values
    * @return       -
    */
    public P7S1_Account_Index_Creator(Boolean isAfter, Boolean isBefore,
        Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    /**
    * Methodname    runAfterInsert
    * @description  Call upsert method after insert
    * @param        -
    * @return       void
    */
    protected override void runAfterInsert() {
        upsertAccountIndex(lstNewItems);
    }

    /**
    * Methodname    runAfterUpdate
    * @description  Call upsert method after insert
    * @param        -
    * @return       void
    */
    protected override void runAfterUpdate() {
        if(doUpdate) upsertAccountIndexUpdate(lstNewItems,(map<id,Account>)mapNewItems,(map<id,Account>)mapOldItems);
    }

    /**
    * Methodname    runAfterDelete
    * @description  Call delete method after delete
    * @param        -
    * @return       void
    */
    protected override void runBeforeDelete() {
        deleteAccountIndex(lstOldItems);
    }

    /**
    * Methodname    upsertAccountIndex
    * @description  Cast object to account and create AccountIndex upsert List
    * @param        List<sObject>
    * @return       void
    */
    static void upsertAccountIndex(List<sObject> lstNewItems){
        List<P7S1_AccountIndex__c> upsAccIndexList = new List<P7S1_AccountIndex__c>();
        for(sObject o : lstNewItems){
            Account a = (Account)o;
            system.debug('######### new flag in insert: ' + a.P7S1_AccountIndexErzeugen__c);
            //Change Request 1.12.2015 Nur wenn Account.P7S1_AccountIndexErzeugen__c = True soll der AccountIndex angelegt bzw. upgedatet werden.
            if(a.P7S1_AccountIndexErzeugen__c) upsAccIndexList.add(prefillAccIndexObject((Account)o));
        }
        if(!upsAccIndexList.isEmpty())upsertAccountIndex(upsAccIndexList);
    }

    /**
    * Methodname    upsertAccountIndexUpdate
    * @description  Cast object to account and create AccountIndex upsert List, check changed values
    * @param        List<sObject>,Map<Id, Account>,Map<Id, Account>
    * @return       void
    */
    static void upsertAccountIndexUpdate(List<sObject> lstNewItems,Map<Id, Account> mapNewItems,Map<Id, Account> mapOldItems){
        List<P7S1_AccountIndex__c> upsAccIndexList = new List<P7S1_AccountIndex__c>();
        List<Account> delAccIndexList = new List<Account>();
        for(sObject o : lstNewItems){
            Account a = (Account)o;
            system.debug('### map old: ' + mapOldItems.get(a.id).OwnerID);
            system.debug('### map new: ' + mapNewItems.get(a.id).OwnerID);
            system.debug('######### old flag ' + mapOldItems.get(a.id).P7S1_AccountIndexErzeugen__c);
            system.debug('######### new flag ' + mapNewItems.get(a.id).P7S1_AccountIndexErzeugen__c);
            
            if((mapNewItems.get(a.id).OwnerID != mapOldItems.get(a.id).OwnerID) || (mapNewItems.get(a.id).P7S1_AccountIndexErzeugen__c != mapOldItems.get(a.id).P7S1_AccountIndexErzeugen__c)){
                system.debug('#####__#### IN CHANGE');
                if(a.P7S1_AccountIndexErzeugen__c){
                    upsAccIndexList.add(prefillAccIndexObject((Account)o));
                }
                else{
                    system.debug('#####__#### IN DELETE');
                    delAccIndexList.add(a);
                }
            }
            else{
                //Change Request 1.12.2015 Nur wenn Account.P7S1_AccountIndexErzeugen__c = True soll der AccountIndex angelegt bzw. upgedatet werden.
                system.debug('#####__#### IN UPSERT');
                if(a.P7S1_AccountIndexErzeugen__c) upsAccIndexList.add(prefillAccIndexObject((Account)o));
            }
        }
        if(!upsAccIndexList.isEmpty())upsertAccountIndex(upsAccIndexList);
        if(!delAccIndexList.isEmpty())deleteAccountIndex((List<sObject>)delAccIndexList);
    } 

    /**
    * Methodname    upsertAccountIndex
    * @description  DML Upsert of AccountIndex
    * @param        List<P7S1_AccountIndex__c>
    * @return       void
    */
    static void upsertAccountIndex(List<P7S1_AccountIndex__c> upsAccIndexList){
        Database.UpsertResult [] cr = Database.upsert(upsAccIndexList,P7S1_AccountIndex__c.P7S1_External_ID__c.getDescribe().getSObjectField(),false);
    }

    /**
    * Methodname    prefillAccIndexObject
    * @description  prefill AccountIndex object with accountdata
    * @param        Account
    * @return       P7S1_AccountIndex__c
    */
    static P7S1_AccountIndex__c prefillAccIndexObject(Account a){
        P7S1_AccountIndex__c ai = new P7S1_AccountIndex__c();
        ai.P7S1_Account__c = a.id;
        ai.P7S1_Accountname__c = a.name.left(100);
        ai.name = a.name.left(80);
        ai.P7S1_External_ID__c = a.id;
        ai.P7S1_Accountnumber__c = a.AccountNumber;
        ai.P7S1_AccountSource__c = a.AccountSource;
        ai.P7S1_Type__c = a.Type;
        ai.P7S1_Description__c = a.Description;
        ai.P7S1_ShippingStreet__c = a.ShippingStreet;
        ai.P7S1_ShippingCountry__c = a.ShippingCountry;
        ai.P7S1_ShippingCity__c = a.ShippingCity;
        ai.P7S1_ShippingPostalCode__c = a.ShippingPostalCode;
        ai.P7S1_Email__c = a.SomTv_AccountEMail__c;
        ai.P7S1_Fax__c = a.Fax;
        ai.P7S1_Handelsregisternummer__c = a.SomTv_HandelsregisternummerHRB__c;
        ai.P7S1_KonzernAgenturverbundZugehoerigkeit__c = a.P7S1_KonzernAgenturverbundZugehoerigkeit__c;
        ai.P7S1_Planumsatz__c = a.P7S1_Planumsatz__c;
        ai.P7S1_BillingStreet__c = a.BillingStreet;
        ai.P7S1_BillingCountry__c = a.BillingCountry;
        ai.P7S1_BillingCity__c = a.BillingCity;
        ai.P7S1_BillingPostalCode__c = a.BillingPostalCode;
        ai.P7S1_Rechtsform__c = a.Som_Rechtsform__c;
        ai.P7S1_Steuerkennzeichen__c = a.P7S1_Steuerkennzeichen__c;
        ai.P7S1_Steuernummer__c = a.SomTv_Steuernummer__c;
        ai.P7S1_Phone__c = a.Phone;
        ai.P7S1_AccountOwnerLookup__c = a.OwnerID;
        ai.P7S1_FirmeninhaberVorname__c = a.SomTv_FirmeninhaberVorname__c;
        ai.P7S1_FirmeninhaberNachname__c = a.SomTv_FirmeninhaberNachname__c;
        ai.P7S1_ParentAccountLookup__c = a.ParentID;
        ai.P7S1_UstIdNr__c = a.P7S1_UstIdNr__c;
        ai.P7S1_Website__c = a.Website;
        ai.SomTv_Top1Wirtschaftsbereich__c = a.SomTv_Top1Wirtschaftsbereich__c;
        ai.SomTv_Top1Wirtschaftsgruppe__c = a.SomTv_Top1Wirtschaftsgruppe__c;
        ai.SomTv_Accounttypen__c = a.SomTv_Accounttypen__c;
        // Set Owner
        ai.OwnerID = a.OwnerID;
        ai.SOM_DigitalSales__c = a.SOM_DigitalSales__c;
        ai.SOM_Einkaufsagenturverkaeufer__c = a.SOM_Einkaufsagenturverkaeufer__c;
        ai.SOM_Planungsagenturverkaeufer__c = a.SOM_Planungsagenturverkaeufer__c;
        ai.SOM_TVKundenverkaeufer__c = a.SOM_TVKundenverkaeufer__c;
        ai.SOM_DooHSales__c = a.SOM_DooHSales__c;
        return ai;
    }

    /**
    * Methodname    upsertAccountIndex
    * @description  Cast object to account and create AccountIndex upsert List
    * @param        List<sObject>
    * @return       void
    */
    static void deleteAccountIndex(List<sObject> lstNewItems){
        List<P7S1_AccountIndex__c> delAccIndexList = new List<P7S1_AccountIndex__c>();
        Set<Id> accIDs = new Set<ID>();
        for(sObject o : lstNewItems){
            Account a = (Account)o;
            accIDs.add(a.id);
        }
        for(P7S1_AccountIndex__c ai:[select id from P7S1_AccountIndex__c where P7S1_Account__c IN :accIDs]){
            delAccIndexList.add(ai);
        }
        Database.deleteResult [] cr = Database.delete(delAccIndexList);
    }

}