public without sharing class P7S1_Process_Acc_SetRecType {
    /* Method for use in Process Builder to update RecordType after initial Account Check */
    
    /************************************************************************
    TO DO Testclass:
        create Account with custom RT
        check RT "zu überprüfen"
        uncheck Fields "zu überprüfen" and "zu überprüfen Sales Steering"
        update Account
        check RT is set back to custom RT and field Prev RT is empty
    ************************************************************************/
    
    @InvocableMethod(label='Account Update the RecordType' description='Method called for an RecordTypeUpdate with Variables')
    public static void UpdateAccountRecordType(List<AccRecTypeVar> ProcessVars) {
        AccRecTypeVar pv = ProcessVars[0];
        try {
            Account a = new Account(Id = pv.AccId, RecordTypeId = (Id) pv.RecTypeId, P7S1_PreviousRecordTypeId__c = null);
            update a;
/*
            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
            mail.setSaveAsActivity(false);
            mail.setSubject('Error in Process for Account RecordType');
            mail.setPlainTextBody('No Error in Process for Account RecordType'
                                  + '\nin class P7S1_Process_Acc_SetRecType'
                                  + '\n\nfor Account with Id: ' + pv.AccId
		          				  + '\nand RecordType with Id: ' + pv.RecTypeId
                				  + '\n\nby User : ' + Userinfo.getName() + ' (Id: ' + Userinfo.getUserId() + ')');
            mail.setToAddresses(new String[] { 'tobias.forstmeier@p7s1applications.de' });
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
*/
        }
        catch(exception e) {
            system.debug('Error: ' + e.getMessage());
            
            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
            mail.setSaveAsActivity(false);
            mail.setSubject('Error in Process for Account RecordType');
            mail.setPlainTextBody('Error in Process for Account RecordType'
                                  + '\nin class P7S1_Process_Acc_SetRecType'
                                  + '\n\n' + string.valueOf(e.getMessage())
                                  + '\n\nfor Account with Id: ' + pv.AccId
		          				  + '\nand RecordType with Id: ' + pv.RecTypeId
                				  + '\n\nby User : ' + Userinfo.getName() + ' (Id: ' + Userinfo.getUserId() + ')');
            mail.setToAddresses(new String[] { 'tobias.forstmeier@p7s1applications.de' });
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    public class AccRecTypeVar {
        @InvocableVariable(required=true)
        public Id AccId;
        @InvocableVariable(required=true)
        public string RecTypeId;
    }
}