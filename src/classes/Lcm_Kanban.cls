public class Lcm_Kanban{

    public String sReleaseID { get; set; }
    public String sProject { get; set; } 
    public String sUser { get; set; }        
    public Map<ID, User> mapUser { get; set; }
    private List<Lcm_Release__c> listReleases;
    public Set<ID> setUserIDs;

    public Lcm_Kanban(){
        sProject = 'Alle';
        sUser = 'Alle';        
    
        // User map for photos
        mapUser = new Map<ID, User>([SELECT ID, SmallPhotoUrl FROM User WHERE isActive = true]);
        listReleases = [SELECT ID, Name, Lcm_StartDate__c, Lcm_EndDate__c FROM Lcm_Release__c WHERE Lcm_RemainingDays__c > -28 order by Lcm_StartDate__c];
        
        setUserIDs = new Set<ID>();        
    }

    public List<SelectOption> getReleases(){
      List<SelectOption> listOptions = new List<SelectOption>();

      for(Lcm_Release__c o : listReleases)
          listOptions.add(new SelectOption(o.ID, o.Name));

       return listOptions;
    }
    
    public List<SelectOption> getProjects(){
        List<SelectOption> listOptions = new List<SelectOption>();
        
        for( Schema.PicklistEntry f : Case.Projekt__c.getDescribe().getPicklistValues())
            listOptions.add(new SelectOption(f.getLabel(), f.getValue()));

       return listOptions;
    }    



    public List<SelectOption> getUsers(){
        List<SelectOption> listOptions = new List<SelectOption>();
        
        List<User> listUsers = new List<User>([SELECT ID, Name FROM User WHERE ID IN :setUserIDs order by Name]);
        for( User u : listUsers)
            listOptions.add(new SelectOption(u.ID, u.Name));

       return listOptions;
    }    
    
    

    // Get Stations
    public List<String> getStations(){
         List<String> listStations = new List<String>();
         for( Schema.PicklistEntry f : Case.Lcm_KanStation__c.getDescribe().getPicklistValues())
              listStations.add(f.getValue());

         return listStations;
    }


    // Map with Column and Cases on VF
    public Map<String, List<Ticket>> getTickets(){
        Map<String, List<Ticket>> mapTickets = new Map<String, List<Ticket>>();
        for(String s : getStations())
            mapTickets.put(s, new List<Ticket>());

        if (sReleaseID == null)
            setDefaultReleaseId();
        
        for(Case c : [SELECT ID, Rank__c, Projekt__c, Subject,CaseNumber, Lcm_KanStation__c, Lcm_KanColor__c, Lcm_KanStatus__c, OwnerID, Owner.FirstName, Owner.LastName FROM Case WHERE Lcm_Release__c = :sReleaseID order by Owner.FirstName]){
            if(sProject != 'Alle' && sProject != c.Projekt__c) continue;
            if(sUser != 'Alle' && sUser != c.OwnerID) continue;
                        
            if(mapTickets.containsKey(c.Lcm_KanStation__c)){
                mapTickets.get(c.Lcm_KanStation__c).add(new Ticket(c, mapUser.get(c.OwnerID).SmallPhotoUrl));
                
                if(c.Lcm_KanStation__c != 'Backlog' && c.Lcm_KanStation__c != null)
                    setUserIDs.add(c.OwnerID);
            }
        }    

        return mapTickets;
    }

    /* If there is no release ID present, set it via 1 of 2 ways:
     * - check if there's a url parameter named 'sReleaseId'
     * - find the current release for this week
     */
    private void setDefaultReleaseId() {
        if (ApexPages.currentPage().getParameters().containsKey('sReleaseId')) {
            this.sReleaseID = ApexPages.currentPage().getParameters().get('sReleaseId');
        } else {
            for (Lcm_Release__c release : listReleases) {
                if (Date.today() >= release.Lcm_StartDate__c && Date.today() <= release.Lcm_EndDate__c) {
                    this.sReleaseID = release.Id;
                    break;
                }
            }
        }
    }


    public class Ticket{

        public Case objCase { get; set; }
        public String photoUrl { get; set; }

        public Ticket(Case c, String photoUrl){
            this.objCase = c;
            this.photoUrl = photoUrl;
        }
    }
}