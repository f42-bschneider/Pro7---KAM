/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_OpportunityTeamMember_Handler.cls
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.1
* @ date         28.10.2015
* @description
* @last change
* @objects     Opportuniy, OpportunityTeamMember
* =================================================================
*/
public without sharing class P7S1_OpportunityTeamMember_Handler extends TriggerController{

    /**
    * Methodname    P7S1_OpportunityTeamMemberHandler
    * @description  Constructor
    * @param        Trigger based values
    * @return       -
    */
    public P7S1_OpportunityTeamMember_Handler(Boolean isAfter, Boolean isBefore,
        Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }

    /**
    * Methodname        runAfterInsert
    * @description  Call insert method after insert
    * @param            -
    * @return           void
    */
    protected override void runAfterInsert() {
        //upsertOppTeamMembers(lstNewItems);
        //InsertOppTeamMember(lstNewItems);
    }

    /**
    * @methodname       runBeforeUpdate
    * @description      Call insert method before update
    * @param            -
    * @return           void
    */
    protected override void runBeforeUpdate(){
        //upsertOppTeamMembers(lstNewItems);
    }

    /**
    * @methodname       upsertOppTeamMembers
    * @description      delete current team members and create new ones
    * @param            -
    * @return           void
    */
    static void upsertOppTeamMembers(List<sObject> lstNewItems){
        Set<Id> oppIds                          = new Set<Id>();
        List<OpportunityTeamMember> otms        = new List<OpportunityTeamMember>();
        Map<ID, Schema.RecordTypeInfo> rtMap    = Schema.SObjectType.Opportunity.getRecordTypeInfosById();

        for(sObject obj : lstNewItems){
            Opportunity opp = (Opportunity) obj;
            oppIds.add(opp.Id);

            if(rtMap.get(opp.RecordTypeId).getName().startsWithIgnoreCase('ven')){
                // im1
                otms.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId = opp.OwnerId));

                // im2
                if(opp.Ven_Im2__c != null){
                    otms.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId = opp.Ven_Im2__c));
                }
                
                // scout
                if(opp.Ven_Scout__c != null){
                    otms.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId = opp.Ven_Scout__c));
                }

                // analyst
                if(opp.Ven_Analyst__c != null){
                    otms.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId = opp.Ven_Analyst__c));
                }   
            }           
        }
        
        delete [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId IN :oppIds];

        insert otms;
    }


    /**
    * Methodname        InsertOppTeamMember
    * @description  Check if current user who creates Opp is VenAnalyst and
                                    create OpportunityTeamMember
    * @param            List<sObject>
    * @return           void
    */
    @TestVisible static final string RECTYP_OPP = 'Ven_Default';
    static void InsertOppTeamMember(List<sObject> lstNewItems){
        List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
        set<ID> recTypeIds = new set<ID>();
        if(checkUserForTeamMember()){
            for(RecordType r : [select id from RecordType where SobjectType = 'Opportunity' and developername = :RECTYP_OPP ]){
                recTypeIds.add(r.id);
            }
            for(sObject obj : lstNewItems){
                Opportunity o = (Opportunity)obj;
                if(recTypeIds.contains(o.RecordTypeID)){
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.OpportunityId = o.id;
                    otm.TeamMemberRole = 'Ven Deal Analyst';
                    otm.UserId = UserInfo.getUserID();
                    oppTeamList.add(otm);
                }
            }
        }
        if(!oppTeamList.isEmpty()) insert oppTeamList;
    }

    /**
    * Methodname    InsertOppTeamMember
    * @description  Check if current user who creates Opp is VenAnalyst
    * @param        List<sObject>
    * @return       void
    */
    static boolean checkUserForTeamMember(){
        //To define: Criteria for Users and RecordType from Opp
        set<string> roleNames = new set<string>();
        roleNames.add('Analyst');
        roleNames.add('Scout');
        User u = [select id,P7S1_Unit__c,u.UserRole.Name,u.UserRoleId from User u where id = :UserInfo.getUserID()];
        boolean createTeamMember = false;
        if(u.P7S1_Unit__c == 'Analyst'){
            createTeamMember = true;
        }
        return createTeamMember;
    }
}