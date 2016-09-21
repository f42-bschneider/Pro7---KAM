public class P7S1_AnmeldungDigitalDetox_Absage {

    private final String DEFAULT_LANGUAGE = 'de_DE';

    public String language { get; set; }

    public P7S1_B2BAktionsmitgliederFeedback__c feedback { get; set; }

    public P7S1_AnmeldungDigitalDetox_Absage() {
        String feedbackCode = apexpages.currentpage().getparameters().get('code');
		system.debug('** feedbackCode:' + feedbackCode);
        
        try {
            this.feedback = [ 
                SELECT ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,CurrencyIsoCode,Id,
                     LastModifiedById,LastModifiedDate,Name,OwnerId,P7S1_Anrede__c,P7S1_Contact__c,P7S1_DatenschutzbedingungenAkzeptiert__c,
                     P7S1_EMail__c,P7S1_EventTeilnahme__c,P7S1_Firma__c,P7S1_Mobil__c,P7S1_Name__c,P7S1_Ort__c,
                     P7S1_PLZ__c,P7S1_Registrierungscode__c,P7S1_Strasse__c, P7S1_BonuskartenNr__c,
                     P7S1_Eishockey__c, P7S1_Eisstock__c, P7S1_Fluggesellschaft__c, P7S1_Abflugort__c,
                     P7S1_SkiSnowboard__c,  P7S1_SkischuheSnowboardschuhe__c,
                     P7S1_Skistoecke__c, P7S1_Veranstaltungsort__c, P7S1_Vorname__c,
                     P7S1_Skifahrer__c, P7S1_Snowboarder__c,
                     P7S1_Rechnungsadresse__c, P7S1_AbweichendeRechnungsadresse__c, P7S1_EigeneAnreise__c, P7S1_Gewicht__c,
                     P7S1_Koerpergroesse__c, P7S1_Schuhgrosse__c, P7S1_ZustimmungKosten__c,P7S1_B2BAktionsmitgliedID__c, P7S1_LanguageCode__c, P7S1_AnredeBrief__c

                FROM P7S1_B2BAktionsmitgliederFeedback__c
                WHERE P7S1_Registrierungscode__c =: feedbackCode
                LIMIT 1
            ];

            language = feedback.P7S1_LanguageCode__c;
            
            system.debug('** this.feedback 1:' + this.feedback);

        } catch (Exception ex) {
            this.feedback = new P7S1_B2BAktionsmitgliederFeedback__c();
            language = DEFAULT_LANGUAGE;
        }
    }
    
    public void absage(){
        system.debug('** this.feedback 2:' + this.feedback);
        
        this.feedback.P7S1_Status__c = 'Absage';
        update this.feedback;
        
        List<CampaignMember> listCM = new List<CampaignMember>([select ID, Status from CampaignMember where ID = :this.feedback.P7S1_B2BAktionsmitgliedID__c]);
        
        if (listCM.size() > 0) {
            listCM[0].Status = 'Zusage';
        	//update listCM;
        }
        
    }
}