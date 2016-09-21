/**
 * A controller for the VF page KampagnenMailLinkGen.
 */
public with sharing class KampagnenMailLinkGenController {
    /** Name of the Site to use for finding the force.com Site. */
    private static final String SITE_NAME = 'SomTv_Update_B2B_Aktionsmitglied_Status';

    /** Site-Name given by URL */
    public String sSiteName { public get; public set; }
    
    /** Selected Status in the VF page. */
    public String selectedStatus { public get; public set; }

    /** List of random generated code */
    public Set<String> listRANDCodes { public get; public set; }
    
    /** Defined redirect-URL in the VF page. */
    public String redirURL { public get; public set; }

    /** Defined email in the VF page. */
    public String emailAddr { public get; public set; }

    /** Send eMail via SF? */
    public Boolean emailViaSF { public get; public set; }

    /** Generated Link? */
    public String generatedLink { public get; private set; }

    /** Actual Campaign. */
    private Campaign campaign;

    public CampaignMember objCampaignMember { public get; public set; }
        
        
    /** Campaign status. */
    private List<CampaignMemberStatus> campaignMemberStatus;

    /** The Force.com Site. */
    private Site site;
    
    private Site site_refusal;

    /** The organization. */
    private Organization org;
	
    /**  List of new Feedback records */
    public List<P7S1_B2BAktionsmitgliederFeedback__c> listFeedbackRecords { public get; public set; }
    
    
    /*
     * KV: 02764
     * Generate invite links for all campaign-members
    */
    public String sAction { public get; public set; }

    public String generatedAcceptLink { public get; public set; }

    public String generatedRefusalLink { public get; public set; }

    public String campaignmemberID { public get; public set; }


    /**
     * Constructor.
     */
    public KampagnenMailLinkGenController() {
        system.debug('** Constructor()' );

        String campaignId = ApexPages.currentPage().getParameters().get('kid');
        
        sSiteName = ApexPages.currentPage().getParameters().get('site_name');
		
        campaign = new Campaign();
        campaignMemberStatus = new List<CampaignMemberStatus>();

        if (campaignId != null) {
            for (Campaign cm : [SELECT Id FROM Campaign WHERE Id = :campaignId]) {
                campaign = cm;
                break;
            }

            campaignMemberStatus = [SELECT Id, label FROM CampaignMemberStatus WHERE Campaignid = :campaignId];
        }

        redirURL = 'http://';
        emailAddr = null;
        emailViaSF = false;
        generatedLink = null;
		
        // Get the Site
        
        if (sSiteName == '' || sSiteName == null) {  
    
            for (Site s : [SELECT Id, Subdomain, UrlPathPrefix FROM Site WHERE Name = :SITE_NAME AND SiteType = 'Visualforce']) {
                site = s;
                break;
            }
                
        } else {            
            for (Site s : [SELECT Id, Subdomain, UrlPathPrefix, AdminId  FROM Site WHERE Name = :sSiteName]) {
                site = s;
                break;
            }
            //site_refusal = [SELECT Id, Subdomain, UrlPathPrefix FROM Site WHERE Name = :SITE_NAME AND SiteType = 'Visualforce' limit 1];
        }
        
        
        // Get the Site
        for (Organization o : [SELECT InstanceName, IsSandbox FROM Organization]) {
            org = o;
            break;
        }
        
        listRANDCodes = new Set<String>();
        
        listFeedbackRecords = new List<P7S1_B2BAktionsmitgliederFeedback__c>();
    }

    /**
     * Start requested action via URL Parameter "sAction"
    */
    public PageReference dispatch() {
        system.debug('** dispatch()' );

        String campaignId = ApexPages.currentPage().getParameters().get('kid');
        
        sAction = ApexPages.currentPage().getParameters().get('sAction');

        if (sAction == 'generateInviteLinks')
            return generateInviteLinks(campaignId);

        if (sAction == 'generateInviteLinks_MOUNTAIN_2016')
            return generateInviteLinks(campaignId);
        
        return null;
    }

    public PageReference generateInviteLinks (String campaignId) {
		system.debug('** generateInviteLinks()' );
        
        if (campaignId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No campaign defined.'));
            return null;
        }

        for (CampaignMemberStatus cms : campaignMemberStatus) {
            if (cms.Label == 'Sent') selectedStatus = cms.ID;
        }
        emailViaSF = true;

        Campaign objCampaign = [select ID, P7S1_Landingpage__c from Campaign where Id = :campaignId];

        redirURL = objCampaign.P7S1_Landingpage__c;

        List<CampaignMember> listCampaignMember = new List<CampaignMember>([select ID, P7S1_Absagelink__c, P7S1_Zusagelink__c, Contact.Salutation, ContactID, Contact.Email, Contact.LastName, Contact.FirstName, 
                                                                            Contact.MobilePhone, Contact.Account.Name, Contact.Account.BillingCity, Contact.Account.BillingPostalCode, Contact.Account.BillingStreet
                                                                            from CampaignMember where CampaignID = :campaignId]);
        for (CampaignMember o : listCampaignMember) {
			if (o.P7S1_Zusagelink__c != null && o.P7S1_Zusagelink__c != '') continue;
            
            campaignmemberID = o.ID;
			objCampaignMember = o;
                
            generateLink();

            o.P7S1_Zusagelink__c = generatedAcceptLink;
            o.P7S1_Absagelink__c = generatedRefusalLink;
        }

        if (ApexPages.hasMessages(ApexPages.Severity.ERROR))
            return null;

        if (!listCampaignMember.isEmpty()) {
            update listCampaignMember;
			upsert listFeedbackRecords P7S1_B2BAktionsmitgliedID__c;
        }    
    
        PageReference redirect = new PageReference('/'+campaignId);
        redirect.setRedirect(true);
        return redirect;

    }

    /**
     * Get the campaign member status option list.
     * @return A list of <code>Selectoption</code>
     */
    public List<Selectoption> getStatus(){
        selectedStatus = null;

        List<Selectoption> optoins = new List<Selectoption>();
        optoins.add(new Selectoption('', '-- None --'));
        for (CampaignMemberStatus cms : campaignMemberStatus) {
            optoins.add(new Selectoption(cms.id, cms.label));
        }
        return optoins;
    }

    /**
     * Generate the link.
     *
     * @return  A PageReference object. Actually <code>null</code>
     */
    public Pagereference generateLink() {
        generatedLink = null;

        if (site == null && sSiteName == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Force.com site with name \'' + SITE_NAME + '\' defined.'));
        }

        if (Campaign == null || Campaign.Id == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No campaign defined.'));
        }

        if (sAction == null && (selectedStatus == null || selectedStatus == '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No status selected.'));
        }

        if (redirURL == null || redirURL == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No redirect URL defined - OR - field Landingpage is empty.'));
        }

        if (!emailViaSF && (emailAddr == null || emailAddr == '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No email address defined.'));
        }

        if (ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
            return null;
        }


        // For a SB, the Force.com site host name looks like:
        //   SBName-Subdomain.SBInstanceName.force.com
        // But there is not possible to get the SBName in APEX!

        // p7s1 special solution:
        //String sandboxName = UserInfo.getUserName().substringAfterLast('.');
        
        generatedLink = 'http://' + (org.IsSandbox ? (UserInfo.getUserName().substringAfterLast('.').toLowerCase() + '-') : '') +
            site.Subdomain.toLowerCase() + (org.IsSandbox ? ('.' + org.InstanceName.toLowerCase()) : '') + '.force.com/' +
            (site.UrlPathPrefix != null ? site.UrlPathPrefix : '');

        if (sAction == null) {
            generatedLink += '?'+('statusId=' + EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(selectedStatus)), 'UTF-8')) + '&amp;' +
                             ('campId=' + EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(Campaign.Id)), 'UTF-8')) + '&amp;' +
               ('redirURL=' + EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(redirURL)), 'UTF-8')) + '&amp;';
            if (emailViaSF)
                generatedLink += ('userId={!Contact.Id}');
            else
                generatedLink += ('email=' + EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(emailAddr)), 'UTF-8'));

        } else if (sAction == 'generateInviteLinks') {
            generatedLink += '?'+('campaignMemberId=' + EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(campaignmemberID)), 'UTF-8')) + '&amp;';

            generatedAcceptLink = generatedLink + 'sAction=Zusage';
            generatedRefusalLink = generatedLink + 'sAction=Absage';
            
        } else if (sAction == 'generateInviteLinks_MOUNTAIN_2016') {
            
            String sCode = 'xemptyx';
            
            while (!listRANDCodes.contains(sCode)) {
                sCode = generateRandomString(10);
                listRANDCodes.add(sCode);
            }
            generatedAcceptLink = generatedLink +'?Code='+sCode;
            generatedRefusalLink = generatedLink + '/P7S1_AnmeldungDigitalDetox_Absage?Code='+sCode;
          
            // Create Feedback record
            String cmID = objCampaignMember.ID;
            cmID = cmID.substring(0,15);
            
            listFeedbackRecords.add(new P7S1_B2BAktionsmitgliederFeedback__c(
                P7S1_B2BAktionsmitgliedID__c = cmID,
                P7S1_Registrierungscode__c = sCode,
                P7S1_Anrede__c = objCampaignMember.Contact.Salutation,
                P7S1_Contact__c  = objCampaignMember.ContactID,
                P7S1_EMail__c   = objCampaignMember.Contact.Email,
                P7S1_Firma__c   = objCampaignMember.Contact.Account.Name,
                P7S1_Mobil__c   = objCampaignMember.Contact.MobilePhone,
                P7S1_Name__c   = objCampaignMember.Contact.LastName, 
                P7S1_Ort__c	  = objCampaignMember.Contact.Account.BillingCity,
                P7S1_PLZ__c   = objCampaignMember.Contact.Account.BillingPostalCode,
                P7S1_Strasse__c   = objCampaignMember.Contact.Account.BillingStreet,
                P7S1_Vorname__c   = objCampaignMember.Contact.FirstName
            ));
        }
        return null;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
    	return randStr; 
	}

    
}