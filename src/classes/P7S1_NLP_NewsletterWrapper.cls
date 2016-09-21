public class P7S1_NLP_NewsletterWrapper {
    
    private P7S1_NLP_PortalPageController pagectrl;    
    public P7S1_Abonnement__c abonement;
    public P7S1_Newsletter__c newsletter {get;private set;}
    private Boolean isChanged;
    private Boolean checked;
        
    public override String toString()
    {
        string output = '';
        output += 'Newsletter: '+ newsletter.Name + ', ';
        output += 'Abo exists: '+ (abonement != NULL) + ', ';
        output += 'isChanged: '+ isChanged + ', ';
        output += 'checked: '+ checked + ', ';
        
        return output;
    }
    
    public Boolean isChecked {
        get
        {
            return checked;
        }
        set
        {
           setChecked(value); 
        }
    }
    
    public P7S1_NLP_NewsletterWrapper(P7S1_Newsletter__c newsletter, P7S1_NLP_PortalPageController pagectrl)
    {
        this.newsletter =  newsletter;
        this.abonement = newsletter.Abonnements__r != NULL && !newsletter.Abonnements__r.isEmpty() ? newsletter.Abonnements__r[0] : NULL;
        this.checked = this.abonement != NULL && this.abonement.P7S1_Kuendigungsdatum__c == NULL ? TRUE : FALSE;
        this.pagectrl = pagectrl;
        this.isChanged = false;
    }
    
    private void setChecked(Boolean value)
    {
        if(this.checked != value)
        {
            this.checked = value;
            this.isChanged = !this.isChanged;
            if (isChanged)
            {
                //active flag was changed
                pagectrl.addToChangeHandler(this);
            }
            else
            {
                //active flag was changed back
                pagectrl.removeFromChangeHandler(this);
            }
        }
    }
    
    public String Name
    {
        get{
        	return this.newsletter.name;
        }
    }
    
    public String Beschreibung
    {
        get
        {
           return this.newsletter.P7S1_Beschreibung__c;
        }    
    }
    
    public String Frequenz
    {
        get
        {
           return this.newsletter.P7S1_Frequenz__c;
        }    
    }

    public String Version
    {
        get
        {
           return this.newsletter.P7S1_Version__c;
        }    
    }
    
    public String Textfarbe
    {
        get
        {
           return this.newsletter.P7S1_Textfarbe__c;
        }    
    }
    
    public Boolean Textfett
    {
        get
        {
           return this.newsletter.P7S1_Textfett__c;
        }    
    }
}