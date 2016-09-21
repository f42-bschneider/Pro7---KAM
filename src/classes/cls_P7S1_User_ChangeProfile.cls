public without sharing class cls_P7S1_User_ChangeProfile {
    // ^-> this is critical!
    
    private static final String PAGE_URL = '/vfp_P7S1_User_ChangeProfile';
    private static final String SITE_NAME = 'ChangeProfile';
    private String PUBLIC_SITE_ROOT { get { return SiteUrl(); } set; }
     
    public User currentUser { get; private set; }
    public Profile[] profileList { get; private set; }
    public User[] userList { get; private set; }
    
    public Site site;
    public Organization org { get { return org = [Select Id, InstanceName, IsSandbox, Name, OrganizationType from Organization];} set;}
    public string ShowPanel { get; set; }
    
    string SiteUrl() {
        site = [SELECT Id, Subdomain, UrlPathPrefix FROM Site WHERE Name = :SITE_NAME AND SiteType = 'Visualforce' limit 1];
        string url = 'https://';
		url += (org.IsSandbox ? (UserInfo.getUserName().substringAfterLast('.').toLowerCase() + '-') : '');
        url += site.Subdomain.toLowerCase();
        url += (org.IsSandbox ? ('.' + org.InstanceName.toLowerCase()) : '');
        url += '.force.com/'; 
        url += (site.UrlPathPrefix != null ? site.UrlPathPrefix : '');
        return url;
    }
    string LoginUrl(string s) {
        string url = 'https://';
        url += org.InstanceName.toLowerCase();
        url += '.salesforce.com/servlet/servlet.su?oid=';
        url += string.valueOf(org.Id).subString(0,15);
        url += '&suorgadminid='; 
        url += s;
        url += '&retURL=%2F005%3Fsetupid%3DManageUsers&targetURL=%2Fhome%2Fhome.jsp';
        return url;
    }
    
    // Vars for debugging
    public Boolean debug { get; set; }
    public String debugRequestURL { get; set; }
    public String debugResponseBody { get; set; }
    
    // Constructor
    public cls_P7S1_User_ChangeProfile() {}
    
    // Reroute inital action to the right place
    public PageReference initialize() {
        String profileId = ApexPages.currentPage().getParameters().get('profileId');
        return profileId == null ? initializeView() : initializeUpdate();
    }
    
    public PageReference initializeView() {
        ShowPanel = null;
        System.Debug ( '###View');
        currentUser = [ 
            select Id, Name, UserName, ProfileId, Profile.UserLicenseId, Profile.Name, Email, P7S1_ShowTestuserLinks__c
              from User
             where Id = :UserInfo.getUserId()
             limit 1
        ];
        
        if (UserInfo.getProfileId() == Id.valueOf('00e20000000lfOjAAI')) {
            ShowPanel = 'Admin';
            userList = [
                select Id, Name from User
                    where P7S1_UserType__c = 'System_Tester'
                    and isActive = true
                order by Name asc
                limit 100
            ];
        }
        else if (org.isSandbox && currentUser.P7S1_ShowTestuserLinks__c) { 
            ShowPanel = 'Tester';
            profileList = [
                select Id, Name
                    from Profile
                where UserLicenseId = :currentUser.Profile.UserLicenseId
                    and Id != :currentUser.Profile.Id 
                    and
                	(name like 'Som%'
	                or name like 'Ven%'
	                or name like 'Aer%'
	                or name like 'Sgn%')
                order by Name asc
                limit 100
            ];
        }
        
        return null;
    }
    
    public List<Selectoption> getProfiles(){
        selProfile = null;
        List<Selectoption> options = new List<Selectoption>();
        options.add(new Selectoption('', '-- None --'));
        for (Profile p : profileList) {
            options.add(new Selectoption(p.id, p.Name));
        }
        return options;
    }
    public string selProfile;
    public string getSelectedProfile() { return selProfile; }
    public void setSelectedProfile(string s) { this.selProfile = s; }
    
    public List<Selectoption> getTestUser(){
        selUserId = null;
        List<Selectoption> options = new List<Selectoption>();
        options.add(new Selectoption('', '-- None --'));
        for (User u : userList) {
            options.add(new Selectoption(u.id, u.Name));
        }
        return options;
    }
    public string selUserId;
    public string getSelectedUserId() { return selUserId; }
    public void setSelectedUserId(string s) { this.selUserId = s; }
    
    
    public PageReference initializeUpdate() {
        System.Debug ( '###Update');
        try {
            String profileId = ApexPages.currentPage().getParameters().get('profileId');
            String userId = ApexPages.currentPage().getParameters().get('userId');
            
            System.Debug ( '###ProfileId: ' + profileId);
            System.Debug ( '###UserId: ' + userId);
            debug = true;
            if (org.isSandbox) update new User(Id = userId, ProfileId = profileId);
        } catch (System.Exception pException) {
            System.Debug ( '###Update-Catch');
            ApexPages.addMessages(pException);
        }
        
        return null;
    }
    
    public PageReference selectProfile() {
        System.Debug ( '###selectProfil');
        if (selProfile != null) {
            String profileId = selProfile;
            String remoteURL = PUBLIC_SITE_ROOT +  PAGE_URL  + '?profileId=' + profileId + '&userId=' + UserInfo.getUserId();
            
            System.Debug ( '###Change-URL: ' + remoteURL);
            
            // Try the outbound call
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('GET');
            httpRequest.setEndpoint(remoteURL);
            
            // Run it - here is the magic...
            HttpResponse httpResponse = new Http().send(httpRequest);
            
            // Debugging?
            if (debug == true) {
                debugRequestURL = remoteURL;
                debugResponseBody = httpResponse.getBody();
            }
            
            return initializeView();
        }
        else {
            return null;
            
        }
    }
    
    public PageReference LoginAsTester() {
        Pagereference pr = (selUserId == null) ? null : new Pagereference(LoginUrl(selUserId));
        return pr;
    }
    
}