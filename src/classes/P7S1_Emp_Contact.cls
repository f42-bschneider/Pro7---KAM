public with sharing class P7S1_Emp_Contact {

    /*
     * Sync contacts based on Mitarbeiter/Emp object
     */
    public static void sync(Map<Id, P7S1_Emp__c> newEmpMap, Map<Id, P7S1_Emp__c> oldEmpMap) {

        Map<Id, P7S1_Emp__c> empMap = new Map<Id, P7S1_Emp__c>();
        Set<String> emailAddresses = new Set<String>();

		// convert Username and Email to LowerCase (same behavior as on User-Object)
		for (P7S1_Emp__c emp : newEmpMap.values()) {
			if (emp.P7S1_Username__c != null) {
				emp.P7S1_Username__c = emp.P7S1_Username__c.toLowerCase();
				emp.P7S1_Email__c = emp.P7S1_Email__c.toLowerCase();
			}
		}

        // Only proceed if 'Sync' checkbox on emp is true and emp has a username
        for (P7S1_Emp__c emp : newEmpMap.values()) {
            if (emp.P7S1_Sync__c && emp.P7S1_Username__c != null) {
                empMap.put(emp.Id, emp);
                emailAddresses.add(emp.P7S1_Username__c);
            }
        }

        if (!empMap.isEmpty()) {
            // Initialize lists which will be used later to insert/update contacts
            List<Contact> contactsToInsert = new List<Contact>();
            List<Contact> contactsToUpdate = new List<Contact>();

            // Build a map of email addresses and corresponding contacts
            Map<String, List<Contact>> emailAddressesContactsMap = new Map<String, List<Contact>>();
            for (P7S1_Emp__c emp : empMap.values()) {
                emailAddressesContactsMap.put(emp.P7S1_Username__c, new List<Contact>());
            }
            for (Contact con : [SELECT Email FROM Contact WHERE P7S1_Sphere__c = 'SomDe' AND Email IN :emailAddresses]) {
                emailAddressesContactsMap.get(con.Email).add(con);
            }

            // Iterate all emps and get the list of contacts with the emp's email address
            for (Id empId : empMap.keySet()) {
                P7S1_Emp__c emp = empMap.get(empId);
                List<Contact> contactsForEmp = emailAddressesContactsMap.get(emp.P7S1_Username__c);

                // If there is no contact with the emp's email address, create a new one with the P7S1_Emp__c lookup and core data fields
                // Only works if P7S1_AccountId__c is set on emp (mandatory for Contact -> Account assignment)
                if (contactsForEmp.isEmpty()) {

                    /* TODO: wieder einkommentieren wenn Contact-Sync aktiviert werden soll:
                    if (emp.P7S1_Lastname__c != null && emp.P7S1_AccountId__c != null) {
                        Contact con = new Contact(
                            P7S1_Emp__c = empId,
                            Email = emp.P7S1_Username__c,
                            FirstName = emp.P7S1_Firstname__c,
                            LastName = emp.P7S1_Lastname__c,
                            AccountId = emp.P7S1_AccountId__c,
                            LeadSource = 'Other'
                        );
                        contactsToInsert.add(con);
                    }
                    */

                // If there are contacts with the emp's email address: set P7S1_Emp__c lookup and transfer core data fields
                } else {
                    for (Contact con : contactsForEmp) {
                        con.P7S1_Emp__c = empId;

                        /* TODO: wieder einkommentieren wenn Contact-Sync aktiviert werden soll:
                        con.Email = emp.P7S1_Username__c;
                        con.FirstName = emp.P7S1_Firstname__c;
                        con.LastName = emp.P7S1_Lastname__c;
                        */

                        contactsToUpdate.add(con);
                    }
                }
            }

            // Insert/update contacts where applicable

            /* TODO: wieder einkommentieren wenn Contact-Sync aktiviert werden soll:
            if (!contactsToInsert.isEmpty()) insert contactsToInsert;
            */

            if (!contactsToUpdate.isEmpty()) update contactsToUpdate;

            // Set P7S1_Contact__c on all emp datasets
            // No need to call update again as this happens in a before context
            contactsToInsert.addAll(contactsToUpdate);
            for (Contact con : contactsToInsert) {
                newEmpMap.get(con.P7S1_Emp__c).P7S1_Contact__c = con.Id;
            }
        }
    }

}