/**
 * @author: ADvendio.com (helge.kosuch@advendio.com)
 * 
 * An instance of ContractTerms represents the ContractTerms which are used in one of the Contracts passed to the contructor. 
 * Each ContractTerm has a lookup pointing to a StandardTerm object.
 */

public with sharing class ContractTerms {
		
    /** AbschnittsSection represents a section on the VF page, with a title and a list of terms
        * Should be a subclass of Terms, but that is not allowed.
        * These will be displayed in a repeat on the VF page */
    public class AbschnittsSection {
        public String title {get; set;}
        
        /** If the following is false, the stardard term will not be displayed at all if it is not valid. */
        public Boolean displayStandardTerms {get; private set;}
        
        /** These will be displayed in a repeat on the VF page */
        public List<Ven_Contract_Terms__c> terms {get; set;}
    }
    
    /** Map aller AbschnittTerms des aktuellen Vertrags nach Abschnitt. */
	Map<String,AbschnittsSection> abschnittsSectionsByAbschnitt = new Map<String,AbschnittsSection>(); 
	
	/** This is list is needed for the repeat on the VF page */
	public List<AbschnittsSection> abschnittsSections {get; private set;}
	
	/** Test this with: 
	InvestmentSummaryController.Terms termsInstance = new InvestmentSummaryController.Terms(
					[SELECT id FROM Ven_Vertrag_SevenVentures__c WHERE id=: InvestmentSummaryController.testClassInstance.vertragsId]
	); 
	*/
	
	static final String INDIVIDUELLE_TERMS_TITLE_STR = 'Individuelle Terms';
	
	public ContractTerms(List<Ven_Vertrag_SevenVentures__c> vertraege) {  //constructor
		List<Ven_Contract_Terms__c> contractTerms = [SELECT id
			, Ven_Standard_Term_kurz__r.Ven_Abschnitt__c
			, Ven_Standard_Term_kurz__r.Ven_Standard_Term_Lang__c
			, Ven_G_ltig__c                          
			, Ven_Kommentar_warum_nicht_g_ltig__c      
            , Ven_Abweichender_Term__c                                         
			FROM Ven_Contract_Terms__c WHERE Ven_Vertrag_SevenVentures__c IN :vertraege
		];  
		
		System.debug('contractTerms=='+contractTerms);

		// populate abschnittsSectionsByAbschnitt map
		for (Ven_Contract_Terms__c term : contractTerms) {
            addTerm(abschnittsSectionsByAbschnitt,term);
		}
		
		{ // Make a list of the AbschnittsSections to display them on the page with the section "Individuelle Terms" at the end.
			abschnittsSections = new List<AbschnittsSection>();
			for (AbschnittsSection currentAbschnittsSection : abschnittsSectionsByAbschnitt.values()) {
				if (currentAbschnittsSection.title.equalsIgnoreCase(INDIVIDUELLE_TERMS_TITLE_STR)) {
					// don't add, will be added at the end
				} else {
					abschnittsSections.add(currentAbschnittsSection);
				}
			}
			
			abschnittsSections.add(abschnittsSectionsByAbschnitt.get(INDIVIDUELLE_TERMS_TITLE_STR));
		}
		
	} // end constructor
    
    static private void addTerm(Map<String,AbschnittsSection> abschnittsSectionsByAbschnitt, Ven_Contract_Terms__c term) {
        final String abschittsTitle = term.Ven_Standard_Term_kurz__r.Ven_Abschnitt__c;
        AbschnittsSection currentAbschnittsSection = abschnittsSectionsByAbschnitt.get(abschittsTitle);
        if ( currentAbschnittsSection == null) {
            // No map entry for this Abschnitt yet. Create one:
            currentAbschnittsSection = new AbschnittsSection();
            currentAbschnittsSection.title = abschittsTitle;
            currentAbschnittsSection.terms = new List<Ven_Contract_Terms__c>();
            
            /** Don't display standard terms in the section "Individuelle Terms": */
            currentAbschnittsSection.displayStandardTerms = ! (abschittsTitle!=null && abschittsTitle.equalsIgnoreCase(INDIVIDUELLE_TERMS_TITLE_STR));
            
            abschnittsSectionsByAbschnitt.put(abschittsTitle, currentAbschnittsSection);

        }
        currentAbschnittsSection.terms.add(term); 
    }
}