/**
 * @author: ADvendio.com (helge.kosuch@advendio.com)
 */

public with sharing class InvestmentSummaryController {
    
	public class InvestmentSummaryControllerException extends Exception{ 
	}	    
    
    final static Id medialeistungsVertragsRecordTypeId; 
    static { 
    	final String failMsg = 'Could not find Contract RecordType Medialeistungsvertrag';
    	
        try {
       		medialeistungsVertragsRecordTypeId = ClsHelper.queryMedialeistungsVertragsRecordTypeId();
        } catch (Exception e) {
            throw new InvestmentSummaryControllerException(failMsg, e);
        }

   		if (medialeistungsVertragsRecordTypeId == null) {
            throw new InvestmentSummaryControllerException(failMsg);
   		}        
    }
    
    

	public Ven_Round__c currentRound {get; private set;}
    
    public PdfGenerator pdfGeneratorInstance {get; private set;}
    {
        pdfGeneratorInstance = new PdfGenerator();
    }
    
    static final Boolean DEBUG = ClsHelper.isSandboxOrgFlag;
    
    public String getStyleEverywhere() {
        return pdfGeneratorInstance.renderAsPdf?'':'width: 900px;'; 
    }

    public PageReference pdfNewPageReference() { 
        return pdfGeneratorInstance.pdfNewPageReference(opp.id);
    }   

    // Do not try to include this in a test method. It will fail with "getContent not allowed in test methods"
    public PageReference pdfSaveAsAttachment() { 
        return pdfGeneratorInstance.pdfSaveAsAttachment(opp.id, 'Investment_Summary',  false);
    }
    
    public ContractTerms termsInstance {get; private set;}

    public List<Ven_Share__c> shares {get; private set;} 

    private Opportunity oppPrivate;
    public Opportunity opp {get {return oppPrivate;}}
    public String capTable {get; private set;} 
    
    public Competitors competitorsInstance {get; private set;}    

    public class Competitors {
        private List<Ven_Competitors__c> competitors {get; private set;}
        public String listOfNames {get; private set;} 
        public String description {get; private set;} 
        
        public Competitors(Opportunity opp) {
            competitors = [SELECT id,Ven_Competitor__c, Ven_Informationen_zum_competitor__c 
                    FROM Ven_Competitors__c WHERE Ven_Account_Key_Player_Competition__c=:opp.accountId
            ];
            
            listOfNames = ClsHelper.newStringWithSeparators(competitors,'Ven_Competitor__c', ' / ');
            description = ClsHelper.newStringWithSeparators(competitors,'Ven_Informationen_zum_competitor__c', ' / ');
        }
    }
    
    public TeamMembers teamMembersInstance {get; private set;}
    
    // This is called from other test methods.
    public static void testTeamMembers(Opportunity opp) {
	    TeamMembers members = new TeamMembers(opp);
        
        members.getDealTeam();

		OpportunityTeamMember  otMember = new OpportunityTeamMember();
        
        members.setNames(otMember,'Industry Expert');
        members.setNames(otMember,'Account Manager');
        members.setNames(otMember,'Deal Analyst');
        members.setNames(otMember,'Media Expert');
        members.setNames(otMember,'Source');
    } 
    
    public class TeamMembers {
        String expertName = '-';
        String ownerName = '-';
        String analystName = '-';

        public String mediaExpert {get; private set;}
        {
            mediaExpert = '-';
        }
        public String sourcePerson {get; private set;}
        {
            sourcePerson = '-';
        }
        
        // This is just not private for the test method
        void setNames(OpportunityTeamMember otMember, String str) {
            if (str=='Industry Expert') {
                expertName = otMember.user.lastname;
            } else if (str=='Account Manager') {
                ownerName = otMember.user.lastname;
            } else if (str=='Deal Analyst') {
                analystName = otMember.user.lastname;
            } else if (str=='Media Expert') {
                mediaExpert = otMember.user.lastname;
            } else if (str=='Source') {
                sourcePerson = otMember.user.lastname;        
            }
        }   
        
        TeamMembers(Opportunity opp) {
            for (OpportunityTeamMember member: opp.OpportunityTeamMembers) {
                setNames(member, member.TeamMemberRole);
            }        
        } // end method
        
        public String getDealTeam() { 
            return expertName 
            + ' / ' + ownerName 
            + ' / ' + analystName;
        }
    }
    
    public String getManagementTeam() {
        return getManagementTeam(opp.OpportunityContactRoles);
    }
    
    private static String getManagementTeam(List<OpportunityContactRole> opportunityContactRoles) {
        String str = '';
        
        for (OpportunityContactRole contactRole : opportunityContactRoles) {
            str += contactRole.contact.name + ' (' + contactRole.role + ')<br/>';
        }
        return str;     
    }

    public InvestmentSummaryController() { //constructor
        this(ApexPages.currentPage().getParameters().get('id'));
    }
    
    public InvestmentSummaryController(ApexPages.StandardController stdController) { //constructor
        this(((Opportunity)stdController.getRecord()).id);
    }
    
    public InvestmentSummaryController(Id oppId) { //constructor
        
        oppPrivate = [SELECT
            id
            ,(SELECT id
                ,User.lastname 
                ,TeamMemberRole // a picklist
                FROM OpportunityTeamMembers
            )
            ,(SELECT id
                          ,role // a picklist
              ,Contact.Name
              FROM OpportunityContactRoles WHERE Contact.Kontakt_f_r_das_Investment_Summary__c	= true
            )
            ,(SELECT id
              FROM Vertr_ge_Sevenventures__r // Ven_Vertrag_SevenVentures__c
              WHERE RecordTypeId=:medialeistungsVertragsRecordTypeId AND Ven_Contract_Status__c='Signed'
            )
            ,Account.id
            ,Account.name
            ,Account.Ven_Business_Model__c
            ,Account.Ven_USP__c
            ,Account.Ven_Year_of_Founding__c
            FROM Opportunity WHERE id=:oppId
        ];
        
        /*
        Ven_Contract_Terms__c contractTerms = [ SELECT
        FROM Ven_Contract_Terms__c WHERE Ven_Vertrag_SevenVentures_del__c=:opp.account.];
                */
        
        teamMembersInstance = new TeamMembers(opp);

        shares = new List<Ven_Share__c>(); 
        currentRound = capTablesAdd(shares, opp.accountId);        
        
        termsInstance = new ContractTerms(opp.Vertr_ge_Sevenventures__r);
        
        competitorsInstance = new Competitors(opp);
    }
    
        
    private static Ven_Round__c capTablesAdd(List<Ven_Share__c> shares, Id accountId) {
 
        Ven_Round__c mostRecentRound = new Ven_Round__c(
                Ven_all_Shares__c = 0.0
                ,Ven_Round_Number__c = 0.0
                ,Ven_Founders_Equity_Share__c = 0.0
                ,Ven_Category__c =''
            ); 
        
        { // init 
            List<Ven_Round__c> rounds = [SELECT id
    		,Ven_Round_Number__c
            ,Ven_Founders_Equity_Share__c
            ,Ven_all_Shares__c
            ,Ven_SV_Equity_Share__c
            ,Ven_SV_Share__c                             
            ,Ven_Category__c                          
            FROM Ven_Round__c WHERE Ven_Account__c=:accountId];                            
            
            // Find the most recent round, which is the one with highest round number:
            for (Ven_Round__c round : rounds) {
                if (round.Ven_Round_Number__c>mostRecentRound.Ven_Round_Number__c) {
                    mostRecentRound = round;
                }
            }
        }
        
        shares.addAll([SELECT id
                    ,Ven_Shareholder__r.name
                    ,Ven_Shares__c
                    ,Ven_Share__c
                  FROM Ven_Share__c WHERE Ven_Round__c=:mostRecentRound.id]);

        return mostRecentRound;
    }
    
    public static void deleteRounds(Id accId) {
        for (List<Ven_Round__c> o : [SELECT id FROM Ven_Round__c WHERE Ven_account__c=:accId] ) {
            delete o;
        }
    }    
    
    @isTest 
    static void testInvestmentSummaryController() {
        Account acc = ClsHelper.newTestAccount(
            System.UserInfo.getUserId()
            , 'Test account 1'
        );
        System.debug('UserId=='+System.UserInfo.getUserId());
        insert acc;
        Opportunity opp = ClsHelper.insertTestOpp(acc.id); 
        
        Ven_Vertrag_SevenVentures__c vertrag = ClsHelper.insertVertrag(opp.id, medialeistungsVertragsRecordTypeId);
        insert new Ven_Standart_Terms__c(Ven_Abschnitt__c = 'Example Abschnittsname');
        ClsHelper.insertTerms(vertrag.id); 
        ClsHelper.insertRounds1And2AndShares(acc.id);
        
        InvestmentSummaryController controller = new InvestmentSummaryController(opp.id);
        
        controller.getStyleEverywhere();
		controller.pdfNewPageReference();        
        controller.getManagementTeam();
      
        InvestmentSummaryController.testTeamMembers(opp); 
    }     
}