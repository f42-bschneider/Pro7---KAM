public with sharing class P7S1_NLP_PortalPageController {

    public class NLPException Extends System.Exception
    {
        
    }
    
    
    @TestVisible
    private NewsletterChangeHandler changeHandler;
    private NewsletterListHandler listHandler;
    private P7S1_PortalLogin__c portalLogin;
    @TestVisible
    private Id portalLoginId
    {
        get;
        set
        {
            if(value != portalLoginId)
            {
                portalLoginId = value;
                system.debug('portalLoginId changed to: '+portalLoginId);
                this.portalLogin = [select id, P7S1_Contact__c, P7S1_EMail__c  from P7S1_PortalLogin__c where id = :portalLoginId];
            }
        }
    }
    
    private void init(Id PortalloginId)
    {
        this.changeHandler = new NewsletterChangeHandler();
        this.portalLoginId = PortalloginId;
        List<P7S1_Newsletter__c> newsletters = getAllActiveNewsletters(this.portalLogin);
        this.listHandler =  new NewsletterlistHandler(newsletters,this);
    }
    
    @TestVisible
    private P7S1_NLP_PortalPageController(Id PortalloginId)
    {
        init(PortalloginId);
    }
    
    public P7S1_NLP_PortalPageController()
    {
        
        init(decryptId(ApexPages.currentPage().getParameters().get('pid')));
        
    }
    
    public void addToChangeHandler(P7S1_NLP_NewsletterWrapper nl)
    {
        this.changeHandler.addWrapper(nl);
    }
    
    public void removeFromChangeHandler(P7S1_NLP_NewsletterWrapper nl)
    {
        this.changeHandler.removeWrapper(nl);
    }
    
    public String getLoginEmail()
    {
        return portalLogin.P7S1_EMail__c;
    }
    
    public List<P7S1_NLP_NewsletterWrapper> getSender()
    {
        return listHandler.sender;
    }  
    
    public List<P7S1_NLP_NewsletterWrapper> getSpecials()
    {
        return listHandler.special;
    }  
    
    public List<P7S1_NLP_NewsletterWrapper> getNewsletters()
    {
        return listHandler.newsletter;
    }  
    
    public void save()
    {
        changeHandler.saveChanges(portalLogin);
        
        init(portalLoginId);
    }
    
    
    /*
     * queries all available Newsletters with abonements of the current 'User'
	 */
    public static List<P7S1_Newsletter__c> getAllActiveNewsletters(P7S1_PortalLogin__c login)
    {
        return [
            SELECT
            	Id, name, P7S1_Startdatum__c, P7S1_Enddatum__c, P7S1_Kategorie__c, P7S1_Beschreibung__c,
            	P7S1_Frequenz__c, P7S1_Version__c, P7S1_Textfett__c, P7S1_Textfarbe__c, P7S1_Aktiv__c,
            	(
                    SELECT 
                    	Id, P7S1_Contact__c, P7S1_Newsletter__c, P7S1_PortalLogin__c, P7S1_AbgeschlossenAm__c,
                    	P7S1_Kuendigungsdatum__c, P7S1_Aktiv__c
                    FROM Abonnements__r
                    WHERE P7S1_PortalLogin__c = :login.Id
                )
            FROM P7S1_Newsletter__c 
            WHERE P7S1_Aktiv__c = true
            ORDER BY P7S1_Sortierung__c
        ];
    }

    public static Boolean isNewsletterActive(P7S1_Newsletter__c newsletter)
    {
        return newsletter.P7S1_Aktiv__c;
    }
    
    public static String encryptId(Id portalLoginId)
    {
        //if id doesn't exist the errorpage will be shown automaticaly
        try
        {
            P7S1_PortalLogin__c login = [SELECT Id, P7S1_PortalId__c FROM P7S1_PortalLogin__c WHERE ID = :portalLoginId]; 
             return login.P7S1_PortalId__c;
        }
        catch(Exception exc)
        {
            throw new NLPException('Error while Encrypting');
        }     
    }
    
    public static Id decryptId(String encrPortalLoginId)
    {
        //if id doesn't exist the errorpage will be shown automaticaly
        try
        {
            P7S1_PortalLogin__c login = [SELECT Id, P7S1_PortalId__c FROM P7S1_PortalLogin__c WHERE P7S1_PortalId__c = :encrPortalLoginId];   
            return login.Id;   
        }
        catch(Exception exc)
        {
            throw new NLPException('Error while Decrypting');
        }
    }
    
    public class NewsletterlistHandler
    {
        public List<P7S1_NLP_NewsletterWrapper> sender {get; private set;}
        public List<P7S1_NLP_NewsletterWrapper> special {get; private set;}
        public List<P7S1_NLP_NewsletterWrapper> newsletter {get; private set;}
        
        public NewsletterlistHandler(List<P7S1_Newsletter__c> newsletters, P7S1_NLP_PortalPageController ctrl)
        {
            this.sender = new List<P7S1_NLP_NewsletterWrapper>();
            this.special = new List<P7S1_NLP_NewsletterWrapper>();   
            this.newsletter = new List<P7S1_NLP_NewsletterWrapper>();
            
            for(P7S1_Newsletter__c nl : newsletters)
            {
                if(!isNewsletterActive(nl)) continue;
                
                if(nl.P7S1_Kategorie__c == 'Specials') special.add(new P7S1_NLP_NewsletterWrapper(nl, ctrl));
                if(nl.P7S1_Kategorie__c == 'Newsletter') newsletter.add(new P7S1_NLP_NewsletterWrapper(nl, ctrl));
                if(nl.P7S1_Kategorie__c == 'Sender') sender.add(new P7S1_NLP_NewsletterWrapper(nl, ctrl));
            }
        }
    }
    
    private without sharing class NewsletterChangeHandler
    {
        @testVisible
        private Set<P7S1_NLP_NewsletterWrapper> changedWrappers;
        
        public NewsletterChangeHandler()
        {
            changedWrappers = new Set<P7S1_NLP_NewsletterWrapper>();
        }
        
        public void addWrapper(P7S1_NLP_NewsletterWrapper wrapper)
        {
            this.changedWrappers.add(wrapper);
        }

        public void removeWrapper(P7S1_NLP_NewsletterWrapper wrapper)
        {
            this.changedWrappers.remove(wrapper);
        }
        
        public void saveChanges(P7S1_PortalLogin__c login)
        {
            List<P7S1_Abonnement__c> abonementsToUpsert = new List<P7S1_Abonnement__c>();
			for(P7S1_NLP_NewsletterWrapper wrapper : changedWrappers)
            {
                P7S1_Abonnement__c abo = new P7S1_Abonnement__c();
                if(wrapper.abonement == NULL)
                {
                    abo.P7S1_Contact__c = login.P7S1_Contact__c;
                    abo.P7S1_PortalLogin__c = login.Id;
                    abo.P7S1_AbgeschlossenAm__c = DateTime.now();
                    abo.P7S1_Newsletter__c = wrapper.newsletter.Id;
                }
                else
                {
                    abo = wrapper.abonement;
                    if(wrapper.isChecked)
                    {
                        abo.P7S1_Kuendigungsdatum__c = NULL;
                        abo.P7S1_AbgeschlossenAm__c = DateTime.now();
                    }
                    else
                    {
                        abo.P7S1_Kuendigungsdatum__c = DateTime.now();
                    }
                }
                abonementsToUpsert.add(abo);
            }
            upsert abonementsToUpsert;
        }
        
    }
    
}