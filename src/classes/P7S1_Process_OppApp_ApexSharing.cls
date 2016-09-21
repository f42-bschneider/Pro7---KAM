public without sharing class P7S1_Process_OppApp_ApexSharing {
    /* Method for use in Process Builder to add Users for manual Sharing on Opportunity Approval */
    
    /************************************************************************
    TO DO Testclass:
        create Opportunity
		create Opportunity Approval
        check sharing
		start Approval
        check sharing
    ************************************************************************/
    
    @InvocableMethod(label='Manual Sharing for Opportunity Approval' description='Share Record with Approvers and delegates')
    public static void ShareOpportunityApproval(List<OppAppVar> OppAppVars) {
		OppAppVar oav = OppAppVars[0];
        Set<Id> uids = new Set<Id>();
        uids.add(oav.AccountOwner);
        uids.add(oav.TvKundenVerk);
        uids.add(oav.TvEinkAgVerk);
        uids.add(oav.TvPlanAgVerk);
        uids.add(oav.DigSales);
        Id oaid = oav.OppAppId;
    	
        try {
            List<P7S1_OpportunityApproval__Share> ApexShares = new List<P7S1_OpportunityApproval__Share>();
            for (User u : [Select Id, Name, ManagerId, DelegatedApproverId from User where Id in: uids and isactive = true]) {
                ApexShares.add(OppAppShare(oaid, u.Id));
                if (u.DelegatedApproverId != null) ApexShares.add(OppAppShare(oaid, u.DelegatedApproverId));
                if (u.ManagerId != null) ApexShares.add(OppAppShare(oaid, u.ManagerId));
            }
            insert ApexShares;
	    }
        catch(exception e) {
            system.debug('Error: ' + e.getMessage());
            
            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
            mail.setSaveAsActivity(false);
            mail.setSubject('Error in Process for Apex Sharing');
            mail.setPlainTextBody('Error in Process for Apex Sharing'
                                  + '\nin class P7S1_Process_OppApp_ApexSharing'
                                  + '\n\n' + string.valueOf(e.getMessage())
                                  + '\n\nfor OppShare with Id: ' + oaid
		          				  + '\n\nby User : ' + Userinfo.getName() + ' (Id: ' + Userinfo.getUserId() + ')');
            mail.setToAddresses(new String[] { 'tobias.forstmeier@p7s1applications.de' });
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    public static P7S1_OpportunityApproval__Share OppAppShare(Id oaid, Id uid) {
        P7S1_OpportunityApproval__Share oas = new P7S1_OpportunityApproval__Share();
        oas.UserOrGroupId = uid;
        oas.ParentId = oaid;
        oas.RowCause = Schema.P7S1_OpportunityApproval__Share.RowCause.P7S1_FreigabeAktuellerGenehmiger__c;
        oas.AccessLevel = 'edit';
        return oas;
    }
    
    public class OppAppVar {
        @InvocableVariable(required=true label='Opportunity Freigabe Id')
		public Id OppAppId;
        @InvocableVariable(required=true label='Account Owner Id')
		public Id AccountOwner;
        @InvocableVariable(label='TV Kundenverkäufer Id')
		public Id TvKundenVerk;
        @InvocableVariable(label='TV Einkaufsagenturverkäufer Id')
		public Id TvEinkAgVerk;
        @InvocableVariable(label='TV Planunsagenturverkäufer Id')
		public Id TvPlanAgVerk;
        @InvocableVariable(label='Digital Sales Id')
		public Id DigSales;
    }
}