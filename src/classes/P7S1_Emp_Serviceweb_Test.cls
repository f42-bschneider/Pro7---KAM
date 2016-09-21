@isTest
public class P7S1_Emp_Serviceweb_Test {
    
    static testMethod void testForCorrectValues() {
        
        // Prepare mail and envelope.
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Insert Organisation, Kollege & Manager
        P7S1_Comp__c objComp = cls_P7S1_TestData.createTestFirma(False);
        objComp.Name = 'Company Name';
        insert objComp;
        
        P7S1_Emp__c objKollege = cls_P7S1_TestData.createTestMitarbeiter(False, objComp);
        objKollege.P7S1_Firstname__c = 'Kollege';
        objKollege.P7S1_Unit__c = '71M';
        objKollege.P7S1_Role__c = 'CRM';
        insert objKollege;
        
        P7S1_Emp__c objManager = cls_P7S1_TestData.createTestMitarbeiter(True, objComp);
        
        // Set mail body, email matches the inserted Contact.
        email.subject = 'BOO01234567 - Antrag Salesforce';
        email.plainTextBody = 'Benutzername=Test\nVorname=BeGoode\nNachname=JBG\nBemerkungen=hello\nAustrittsdatum=19.07.2015\nEmail=j@rhcp.com\nKollege='+objKollege.P7S1_Lastname__c + ' ' + objKollege.P7S1_Firstname__c +'\nFirma=' + objComp.Name + '\nManager='+objManager.P7S1_Lastname__c + ' ' + objManager.P7S1_Firstname__c +'';
        
        Test.startTest();
        
        // Instantiate the service, and run once.
        P7S1_Emp_Serviceweb cls = new P7S1_Emp_Serviceweb();
        cls.handleInboundEmail(email, env);
        
        Test.stopTest();
        
        // Asserts
        List<P7S1_Emp__c> listTestEmp = new List<P7S1_Emp__c>([SELECT	P7S1_Comp__c, P7S1_Manager__c, P7S1_Colleague__c,
                                                               		  	P7S1_Unit__c, P7S1_Profile__c, P7S1_Role__c
                                                               FROM 	P7S1_Emp__c
                                                               WHERE  	P7S1_Email__c = 'j@rhcp.com'
                                                               LIMIT  	1]);
        
        P7S1_Emp__c testEmp = listTestEmp[0];
        
        // Found and matched the Organization correctly.
        System.assertEquals(objComp.ID, testEmp.P7S1_Comp__c);
        
        // Found and matched the Manager correctly.
        System.assertEquals(objManager.ID, testEmp.P7S1_Manager__c);  
        
        System.assertEquals(objKollege.P7S1_Profile__c, testEmp.P7S1_Profile__c);
        System.assertEquals(objKollege.P7S1_Role__c, testEmp.P7S1_Role__c);
        System.assertEquals(objKollege.P7S1_Unit__c, testEmp.P7S1_Unit__c);
        
    }
    
    /**
     * Test for exceptions, casecomments where Kollege/Manager/Firma was not found.
     */
    static testMethod void testForBadValues() {
        
        // Prepare mail and envelope.
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        Contact con = cls_P7S1_TestData.createTestContact(false);
        con.Email = 'j@rhcp.com';
        insert con;
        
        Contact conDuplicate = cls_P7S1_TestData.createTestContact(false);
        conDuplicate.Email = 'j@rhcp.com';
        
        
        // Set mail body, email matches the inserted Contact.
        email.subject = 'BOO01234567 - Antrag Salesforce';
        email.plainTextBody = 'Benutzername=Test\nVorname=BeGoode\nNachname=JBG\nBemerkungen=hello\nAustrittsdatum=19.07.2015\nEmail=j@rhcp.com\nKollege=KollegeLastName KollegeFirstName\nFirma=FirmaName\nManager=ManagerLastName ManagerFirstName';
        
        Test.startTest();
        
        // Instantiate the service, and run once.
        P7S1_Emp_Serviceweb cls = new P7S1_Emp_Serviceweb();
        cls.handleInboundEmail(email, env);
        
        insert conDuplicate;
        
        cls.handleInboundEmail(email, env); // For duplicate value exception?
        Test.stopTest();

        
        // Asserts
        List<P7S1_Emp__c> listTestEmp = new List<P7S1_Emp__c>([SELECT	P7S1_Comp__c, P7S1_Manager__c, P7S1_Colleague__c,
                                                               		  	P7S1_Unit__c, P7S1_Profile__c, P7S1_Role__c
                                                               FROM 	P7S1_Emp__c
                                                               WHERE  	P7S1_Email__c = 'j@rhcp.com'
                                                               LIMIT  	1]);
        P7S1_Emp__c testEmp = listTestEmp[0];
        
        // Found and matched the Organization correctly.
        System.assertEquals(System.Label.P7S1_Emp_Serviceweb_DefaultCompID, testEmp.P7S1_Comp__c);
        
        // Found and matched the Manager correctly.
        System.assertEquals(null, testEmp.P7S1_Manager__c);  
        
        System.assertEquals(null, testEmp.P7S1_Profile__c);
        System.assertEquals(null, testEmp.P7S1_Role__c);
        System.assertEquals(null, testEmp.P7S1_Unit__c);
        
    }
    
}