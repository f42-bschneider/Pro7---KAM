/*
#Oktober 2015
#Author: Reza Sarwari
#Beschreibung: Diese Klasse wir von einem Inbound-Email-Service verwendet. Die Klasse erstellt für jede eingehende E-Mail einen Case.
Auserdem wird die Email nach bestimmten Inhalten geparst und bei Felerhaften Inhalten in den Case, Case-Kommentare gesschrieben. 
Die Inhalte der Case-Commentare sind in Custom Labels abgelegt. Die Klasse erstellt ausserdem einen Datensatz im Objekt "Mitarbeiter" und 
befüllt den Mitarbeiter-Datensatz mit allen eintreffenden Inhalten aus der E-Mail.
*/
global class P7S1_Emp_Serviceweb implements Messaging.InboundEmailHandler {

global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {

 // Create an InboundEmailResult object for returning the result of the Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        // Add the email plain text and other values into the local variables:        
        String myPlainText = email.plainTextBody;  
        String sEmailAddress = null;
        // String sUsername = null;
        String sFirstname = null;
        String sLastname = null;
        String sComment = null;
        String sAustrittsdatum = null;
        Date dAustrittsdatum = null;
        String sTitle = null;
        String sWindowsID = null;
        String sColleague = null;
        String sOrganisation = null;
        String sManager = null;
    	String sFirma = null;
        String sPhone = null;
        
        // Define existing and new Objects
        Case objNewCase = new Case();
        P7S1_Emp__c objNewEmp = new P7S1_Emp__c();
        Contact objContact;
        
        try {
            
            
            
            Map<String, String> EmailValues = readEmailValues(myPlainText);
            system.debug('** EmailValues: ' + EmailValues);
            
            sEmailAddress = EmailValues.get('Email');
            if (sEmailAddress != null) sEmailAddress = sEmailAddress.trim();
			
            sFirstname = EmailValues.get('Vorname');
            if (sFirstname != null) sFirstname = sFirstname.trim();
            
            sLastname = EmailValues.get('Nachname');
            if (sLastname != null) sLastname = sLastname.trim();
            
            /* Führt mit Zeilenumbruch zu Fehlern. Daher auskommentiert 
            sComment = EmailValues.get('Begründung');
            if (sComment != null) sComment = sComment.trim();
            */
            sAustrittsdatum = EmailValues.get('Austrittsdatum');
            if (sAustrittsdatum != null && sAustrittsdatum != '01.01.0001') {
                sAustrittsdatum = sAustrittsdatum.trim();
                dAustrittsdatum = date.valueOf(sAustrittsdatum.split('\\.')[2]+'-'+sAustrittsdatum.split('\\.')[1]+'-'+sAustrittsdatum.split('\\.')[0]);
            }
            
            sTitle = EmailValues.get('Funktion');
            if (sTitle != null) sTitle = sTitle.trim();
            
            sWindowsID = EmailValues.get('Windows-Kennung');
            if (sWindowsID != null) sWindowsID = sWindowsID.trim();
            
            sColleague = EmailValues.get('Kollege');
            if (sColleague != null) sColleague = sColleague.trim();
            
            sOrganisation = EmailValues.get('Organisation');
            if (sOrganisation != null) sOrganisation = sOrganisation.trim();
            
            sManager = EmailValues.get('Manager');
            if (sManager != null) sManager = sManager.trim();
            
            sFirma = EmailValues.get('Firma');
            if (sFirma != null) sFirma = sFirma.trim();
            
            sPhone = EmailValues.get('Telefon');
            if (sPhone != null) sPhone = sPhone.trim();
            
            // Create Case
            // Add a new Case to the contact record we just found above.
            objNewCase.Description = myPlainText;
            objNewCase.Status = 'Inbound Email';
            objNewCase.Subject = email.subject.left(10) + ' ' + sEmailAddress;
            // Insert the new Case
            insert objNewCase;
            
            List<Contact> listContact = new List<Contact>([SELECT 	ID, Name, FirstName, LastName, Email, AccountID 
                                                           FROM 	Contact 
                                                           WHERE 	P7S1_Sphere__c='SomDe' AND 
                                                           			Email = :sEmailAddress AND 
                                                           			Email != null]);
            // If there is more than one contact with the same email address,
            // write a CaseComment:
            if (listContact.size() > 1) {
                CaseComment objCaseComment = new CaseComment();
                objCaseComment.ParentID = objNewCase.ID;
                objCaseComment.CommentBody = System.label.P7S1_Emp_Serviceweb_ContactEmailDuplicate+' ' + sEmailAddress;
                insert objCaseComment;
                
            }
            if (listContact.size() == 1)
                objContact = listContact[0];
            
            // Check if User exists with this Username:
            List<User> listUser = new List<User>([select ID from User where UserName = :sEmailAddress]);   
            if (listUser.size() > 0) {
                CaseComment objCaseComment = new CaseComment();
                objCaseComment.ParentID = objNewCase.ID;
                objCaseComment.CommentBody = System.Label.P7S1_Emp_Serviceweb_UsernameDuplicate  + ' ' + sEmailAddress;
                insert objCaseComment;
            }
            
            
            // Create new Employee record:
            objNewEmp.P7S1_Comp__c = System.Label.P7S1_Emp_Serviceweb_DefaultCompID;
            objNewEmp.P7S1_Email__c = sEmailAddress;          
            objNewEmp.P7S1_Username__c  = sEmailAddress;
            objNewEmp.P7S1_Firstname__c = sFirstname;
            objNewEmp.P7S1_Lastname__c  = sLastname;
            objNewEmp.P7S1_DateExit__c = dAustrittsdatum;
            objNewEmp.P7S1_ManagerText__c = sManager;
            objNewEmp.P7S1_CompText__c = sFirma;
            objNewEmp.P7S1_Department__c = sOrganisation;
            objNewEmp.P7S1_Title__c = sTitle;
            objNewEmp.P7S1_Colleague__c = sColleague;
            objNewEmp.P7S1_WindowsID__c = sWindowsID;
            objNewEmp.P7S1_Phone__c = sPhone;
            
            if (objContact != null) {
                objNewEmp.P7S1_Contact__c  = objContact.ID;
                objNewCase.ContactID = objContact.ID; 
            }
            
            // Logic for Organisation. (P7S1_Comp__c)
            List<P7S1_Comp__c> listFirma = new List<P7S1_Comp__c>([SELECT ID FROM P7S1_Comp__c WHERE Name = :sFirma ORDER BY createdDate DESC LIMIT 1]);
            if(!listFirma.isEmpty()) {
                P7S1_Comp__c objComp = listFirma[0];
                objNewEmp.P7S1_Comp__c = objComp.ID;
            } else {
                CaseComment objCaseComment = new CaseComment();
                objCaseComment.ParentID = objNewCase.ID;
                objCaseComment.CommentBody = System.Label.P7S1_Emp_Serviceweb_CompNotFound  + ' ' + sFirma;
                insert objCaseComment;
            }
            
            // Logic for Kollege
            if (sColleague != null) {
                String[] sColleagueSplit = sColleague.split(' ',2);
                List<P7S1_Emp__c> listColleague = new List<P7S1_Emp__c>([SELECT P7S1_Profile__c, P7S1_Role__c, P7S1_Sphere__c, P7S1_Unit__c FROM P7S1_Emp__c WHERE P7S1_Firstname__c = :sColleagueSplit[1] AND P7S1_Lastname__c = :sColleagueSplit[0]]);
                if(!listColleague.isEmpty()) {
                    P7S1_Emp__c objColleague = listColleague[0];
                    objNewEmp.P7S1_Profile__c = objColleague.P7S1_Profile__c;
                    objNewEmp.P7S1_Unit__c = objColleague.P7S1_Unit__c;
                    objNewEmp.P7S1_Role__c = objColleague.P7S1_Role__c;
                    objNewEmp.P7S1_Sphere__c = objColleague.P7S1_Sphere__c;
                    
                } else {
                    CaseComment objCaseComment = new CaseComment();
                    objCaseComment.ParentID = objNewCase.ID;
                    objCaseComment.CommentBody = System.Label.P7S1_Emp_Serviceweb_ColleagueNotFound  + ' :' + sColleague;
                    insert objCaseComment;
                }                
            }
            
            // Logic for Manager
            if (sManager != null) {
                String[] sManagerSplit = sManager.split(' ',2);
                List<P7S1_Emp__c> listManager = new List<P7S1_Emp__c>([SELECT ID FROM P7S1_Emp__c WHERE P7S1_Firstname__c = :sManagerSplit[1] AND P7S1_Lastname__c = :sManagerSplit[0]]);
                if(!listManager.isEmpty()) {
                    P7S1_Emp__c objManager = listManager[0];
                    objNewEmp.P7S1_Manager__c = objManager.ID;
                } else {
                    CaseComment objCaseComment = new CaseComment();
                    objCaseComment.ParentID = objNewCase.ID;
                    objCaseComment.CommentBody = System.Label.P7S1_Emp_Serviceweb_ManagerNotFound +' ' + sManager;
                    insert objCaseComment;
                }
            }          
            
            
            // Insert the new EMP
            insert objNewEmp;
            
            // Update Case with new EMP-ID
            objNewCase.P7S1_Mitarbeiter__c = objNewEmp.Id; 
            update objNewCase;    
            
            // Set the result to true. No need to send an email back to the user with an error message
            result.success = true;
            // Return the result for the Apex Email Service
            return result;
    
        } catch (Exception e) {
            System.debug('** Exception in P7S1_UserAdmin_ServiceWeb: ' + e.getMessage());
            
            String sMessage = e.getMessage();
            
            if (sMessage.contains('DUPLICATE_VALUE') && sMessage.contains('P7S1_Username__c')) {
                CaseComment objCaseComment = new CaseComment();
                objCaseComment.ParentID = objNewCase.ID;
                objCaseComment.CommentBody = System.Label.P7S1_Emp_Serviceweb_UsernameDuplicate  + ' ' + sEmailAddress;     
                insert objCaseComment;         
                
                System.debug('** sMessage: ' + sMessage);
                
                Integer iDublicateIDPos = sMessage.lastIndexOf('a0E');
                System.debug('** iDublicateIDPos: ' + iDublicateIDPos);
                
                if (iDublicateIDPos != -1) {
                    String sDublicateID = sMessage.substring(iDublicateIDPos,iDublicateIDPos+15);
                    System.debug('** sDublicateID: ' + sDublicateID);
                    
                    ID dublicateID = sDublicateID.trim();
                    
                    // Update Case with new EMP-ID
                    objNewCase.P7S1_Mitarbeiter__c = dublicateID; 
                    update objNewCase;
                }     
            }
                 
            // Return the result for the Apex Email Service
            result.message = sMessage;
            result.success = true;
            return result;
            
        }
    }
    
    public static Map<String,String> readEmailValues(String sEmailContent) {
        
        // Add a new EMP to the contact record we just found above.
        Map<String, String> EmailValues = new Map<String, String>();
        for (string s : sEmailContent.split('\\n')) {
            if (!s.contains('=')) continue;
            system.debug('** s: ' + s);
        
            integer iSeparator = s.indexof('=');
            string sKey = s.substring(0,iSeparator);
            string sValue = s.substring(iSeparator+1);
            EmailValues.put(sKey,sValue);
        }
        
        return EmailValues;
    }

}