// class for KV: 02920
// This class prevents saving when some criteria are not met. See KV.
public class Adv_MediaCampaign_Conception{

    public static Set<ID> setConceptionUsers {
        get {
            if (setConceptionUsers == null) {
                setConceptionUsers = new Set<ID>();
                for(GroupMember o : [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.Name = 'SomDig_ConceptionUser'])
                    setConceptionUsers.add(o.UserOrGroupId);
            }
            return setConceptionUsers;
        }
        set;
    }

    public static void validate(Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate, List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems){
        for(ADvendio__MediaCampaign__c o : (List<ADvendio__MediaCampaign__c>) lstNewItems){
            if(o.SomDig_SACConceptionManager__c == null && setConceptionUsers.contains(UserInfo.getUserId())){
                o.addError('Das Feld SAC/Conception Manager auf der Mediakampagne darf nicht leer sein.');
            }
        }
    }
}