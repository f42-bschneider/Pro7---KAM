global class Lcm_MetadataAnalyzer implements Schedulable {

    public Map<String, String> data;

    private static Organization ORG {
        get {
            if (ORG == null) {
                ORG = [SELECT CreatedDate FROM Organization LIMIT 1];
            }
            return ORG;
        }
        set;
    }


    public Lcm_MetadataAnalyzer() {
        this.data = new Map<String, String>();
    }

    public void run() {
        compareRoles();
        compareProfiles();
        sendEmail();
    }

    public void compareRoles() {
        Map<String, Schema.PicklistEntry> picklistMap = new Map<String, Schema.PicklistEntry>();
        Map<String, UserRole> roleMap = new Map<String, UserRole>();

        for (Schema.PicklistEntry entry : P7S1_Emp__c.P7S1_Role__c.getDescribe().getPicklistValues()) {
            picklistMap.put(entry.getValue(), entry);
        }

        for (UserRole role : [SELECT DeveloperName FROM UserRole ORDER BY DeveloperName]) {
            roleMap.put(role.DeveloperName, role);
        }

        String info = '';

        for (String name : roleMap.keySet()) {
            if (!picklistMap.containsKey(name)) {
                info += 'Existiert nur im Setup: ' + name + '\n';
            }
        }

        for (String name : picklistMap.keySet()) {
            if (!roleMap.containsKey(name)) {
                info += 'Existiert nur in der Mitarbeiter-Picklist: ' + name + '\n';
            }
        }

        if (info.length() > 0) data.put('Rollen', info);
    }

    public void compareProfiles() {
        Map<String, Schema.PicklistEntry> picklistMap = new Map<String, Schema.PicklistEntry>();
        Map<String, Profile> profileMap = new Map<String, Profile>();

        for (Schema.PicklistEntry entry : P7S1_Emp__c.P7S1_Profile__c.getDescribe().getPicklistValues()) {
            if (entry.getValue() == 'Systemadministrator') continue;
            picklistMap.put(entry.getValue(), entry);
        }

        for (Profile p : [SELECT Name FROM Profile WHERE UserLicense.Name = 'Salesforce' AND CreatedDate > :ORG.CreatedDate ORDER BY Name]) {
            profileMap.put(p.Name, p);
        }

        String info = '';

        for (String name : profileMap.keySet()) {
            if (!picklistMap.containsKey(name)) {
                info += 'Existiert nur im Setup: ' + name + '\n';
            }
        }

        for (String name : picklistMap.keySet()) {
            if (!profileMap.containsKey(name)) {
                info += 'Existiert nur in der Mitarbeiter-Picklist: ' + name + '\n';
            }
        }

        if (info.length() > 0) data.put('Profile', info);
    }

    private void sendEmail() {
        if (!data.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            setMailRecipients(mail);
            setMailSubject(mail);
            setMailBody(mail);

            Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }

    private void setMailRecipients(Messaging.SingleEmailMessage mail) {
        mail.setToAddresses(new List<String>{ 'robert.kuerzinger@p7s1applications.de' });
    }

    private void setMailSubject(Messaging.SingleEmailMessage mail) {
        mail.setSubject('Metadata Analyzer Report');
    }

    private void setMailBody(Messaging.SingleEmailMessage mail) {
        String sandbox = URL.getSalesforceBaseUrl().getHost().substringBefore('.').substringAfterLast('--');

        String body = '';
        body += 'Org: ' + (sandbox == '' ? 'Prod' : sandbox) + '\n\n';
        for (String scope : data.keySet()) {
            body += scope + '\n';
            body += '----------------------------\n';
            body += data.get(scope) + '\n';
        }
        mail.setPlainTextBody(body);
    }


    global void execute(SchedulableContext context) {
        new Lcm_MetadataAnalyzer().run();
    }

}