// class for KV: 03672
public class Adv_MediaCampaign_FieldValidation{

    static List<GroupMember> cachedGMList {
          get {
             if (cachedGMList == null) {
                 cachedGMList = [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.Name = 'SomDig_TeamLead'];
              }
             return cachedGMList;
          }
          set;
    }

    public static void validate(List<ADvendio__MediaCampaign__c> lstNewItems, Map<Id, ADvendio__MediaCampaign__c> mapOldItems){      
        // Check if User is TeamLead
        Boolean bUserIsTeamlead = false;
        ID currentUserID = UserInfo.getUserId();
        for(GroupMember o : cachedGMList){
            if(o.UserOrGroupId == currentUserID){
                bUserIsTeamlead = true;
            }
        }            
        
     
        ID auftragRCID = cls_P7S1_Utils.getRecordTypeID('ADvendio__MediaCampaign__c', 'SomDig_Auftrag');
        for(ADvendio__MediaCampaign__c o : lstNewItems){
            if(o.SomDig_WtAgBeziehung__c != mapOldItems.get(o.ID).SomDig_WtAgBeziehung__c && o.RecordTypeID == auftragRCID){

                // If the Campaign is in the map it has more than 0 Invoices
                if(o.SomDig_SumReviewedAndInvoicedInvoices__c > 0 || !bUserIsTeamlead){
                    o.addError('Das Feld WT AG Beziehung auf der Mediakampagne darf nicht editiert werden.');
                }
            }
        }
    }
}