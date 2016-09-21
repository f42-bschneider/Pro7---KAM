public with sharing class P7S1_AnmeldungDigitalDetox_Controller {

    private final String DEFAULT_LANGUAGE = 'de_DE';

    public P7S1_B2BAktionsmitgliederFeedback__c feedback { get; set; }
    public String code { get; set; }
    public String email { get; set; }
    public String language { get; set; }

    public P7S1_AnmeldungDigitalDetox_Controller() {
        String feedbackCode = apexpages.currentpage().getparameters().get('code');
        String feedbackPagenumber = apexpages.currentpage().getparameters().get('p');

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
                     P7S1_Koerpergroesse__c, P7S1_Schuhgrosse__c, P7S1_ZustimmungKosten__c,

                P7S1_LanguageCode__c

                FROM P7S1_B2BAktionsmitgliederFeedback__c
                WHERE P7S1_Registrierungscode__c =: feedbackCode
                LIMIT 1
            ];
            code = apexpages.currentpage().getparameters().get('code');
            email = apexpages.currentpage().getparameters().get('email');

            language = feedback.P7S1_LanguageCode__c;

        } catch (Exception ex) {
            this.feedback = new P7S1_B2BAktionsmitgliederFeedback__c();
            language = DEFAULT_LANGUAGE;
        }

        try {
          this.wizardPageNumber = feedbackPagenumber == null ? 1 : Integer.valueOf(feedbackPagenumber);
        } catch (Exception ex){
           this.wizardPageNumber = 1;
        }
    }


    public Integer wizardPageNumber { get; set;}

    public PageReference increaseWizardPageNumber() {
        System.debug('!!! UPDATE FEEDBACK === ' + feedback);
        System.debug('!!! wizardPageNumber = ' + this.wizardPageNumber);
        //update feedback;
        return null;
    }


    public PageReference decreaseWizardPageNumber() {
        PageReference pageref = Page.P7S1_AnmeldungDigitalDetox;
        pageref.getParameters().put('code', this.code);
        pageref.getParameters().put('email', this.email);
        pageref.getParameters().put('p', String.valueOf(this.wizardPageNumber));
        pageref.setRedirect(true);
        return pageref;
    }

    public PageReference setCodeNumber() {
      return null;
    }

    @RemoteAction
    public static Boolean isfeedback(String code, String email) {

       return [SELECT COUNT() FROM P7S1_B2BAktionsmitgliederFeedback__c WHERE P7S1_Registrierungscode__c =: code AND P7S1_EMail__c =: email] > 0;

    }




}