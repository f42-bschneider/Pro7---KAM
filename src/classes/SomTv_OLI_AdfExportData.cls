public with sharing class SomTv_OLI_AdfExportData
{

    /*
     * TODO: 
     * FieldMappingHandler umstellen auf interne verwendung von:
     * - List<Schema.SObjectField> (reihenfolge der Felder)
     * - Map<Schema.SObjectField, String> Pfad zum Feld
     */ 
    
    public class FactSheetExportException extends System.Exception{}
    
    private List<OpportunityLineItem> opportunityLineItems;
    public Integer count {get{ return opportunityLineItems.size();} private set;}
    public List<List<Object>> records {get; private Set;}
    public FieldMappingHandler fsh;
    public Id adfProjectId;
    
    public SomTv_OLI_AdfExportData(Id adfProjectId)
    {
        this.adfProjectId = adfProjectId;
        //        fsh = new FieldSetHandler(); 
        fsh = new HardCodedFieldMapper();
        this.opportunityLineItems = (List<OpportunityLineItem>)Database.query(buildQuery());
        this.records = getRecords();
    }
    
    private List<List<Object>> getRecords()
    {
        List<List<Object>> result = new List<List<Object>>();
        for(String fieldPath : fsh.fieldPaths)
        {
            List<Object> fieldValues = new List<Object>();
            fieldValues.add(fsh.fieldLabels.get(fieldPath));
            for(OpportunityLineItem oli : this.opportunityLineItems)
            {
                fieldValues.add(formatValue(getValue(oli,fieldPath)));
            }
            result.add(fieldValues);
        }
        return result;
    }
    
    @TestVisible
    private String buildQuery()
    {
        String query = '';
        query += 'SELECT ';
        query += String.join(fsh.fieldPaths, ', ');  
        query += ' From OpportunityLineItem WHERE ';
        query += 'Opportunity.CloseDate >= '+String.valueOf(Date.newInstance(Date.today().year(), 1, 1));
        query += ' AND Opportunity.CloseDate <= '+ String.valueOf(Date.newInstance(Date.today().year(), 12, 31));
        query += ' AND Opportunity.SomTv_AdFProjekt__c = \''+adfProjectId+'\'';
        query += ' ORDER BY Product2.Name, SomTv_SendeDatumVon__c';
        return query;
    }
    
    public static Object formatValue(Object value)
    {
        if(value == NULL) return ' ';//throw new FactSheetExportException();
        if(Value instanceof String)
        {
            String str = (String)value;
            value = str.replace('<br>', ' ');
        }
        return value;
    }
    
    public static Object getValue(SObject obj, String fieldPath)
    {
        If (fieldPath == NULL) return NULL;
        If (obj == NULL) return NULL;
        
        system.debug('got Path: '+fieldPath);
        if(fieldPath.contains('.'))
        {
            List<String> tempPath = fieldPath.split('\\.',2);
            system.debug('splitting path: '+tempPath);
            SObject referencedRecord = obj.getSObject(tempPath[0]);
            system.debug('referencedRecord: '+referencedRecord);
            return getValue(referencedRecord, tempPath[1]);
        }
        else
        {
            system.debug('getting value from field: '+fieldPath);
            return obj.get(fieldPath);
        }
    }
    
    
    public abstract class FieldMappingHandler
    {
        public List<String> fieldPaths = new List<String>();
        public Map<String,String> fieldLabels = new Map<String,String>();
        
        public FieldMappingHandler()
        {
            init();
        }
        
        protected abstract void init();
    } 
    
    public class HardCodedFieldMapper extends FieldMappingHandler
    {
        protected override void init()
        {
            addFieldPaths();
            addFieldLabels();
        }
        
        private void addFieldPaths()
        {
            fieldPaths.add('Opportunity.Account.Name');
            fieldPaths.add('Opportunity.SomTv_MutterOpportunity__r.Name');
            fieldPaths.add('SomTv_Kundenprodukt__c');
            fieldPaths.add('Opportunity.SomTv_Externe_ID__r.Name');
            fieldPaths.add('Opportunity.SomTv_ProSedi_ID_Rechnungsadresse__r.Name');
            fieldPaths.add('Opportunity.SomTv_Agentur__r.Name');
            fieldPaths.add('Opportunity.SomTv_Beziehung__r.ConnectionReceivedId');
            fieldPaths.add('Product2.Name');
            //'SomTv_AdFProductHelper__r.Name');
            fieldPaths.add('SomTv_Sponsoring__c');
            fieldPaths.add('SomTv_Fremdbezug__c');
            fieldPaths.add('SomTv_NrGoodwill__c');
            fieldPaths.add('SomTv_Geschaeftsart__c');
            fieldPaths.add('SomTv_Tarifart__c');
            fieldPaths.add('SomTv_Detail_Informationen__c');
            fieldPaths.add('SomTv_Sender__c');
            fieldPaths.add('SomTv_Genre__c');
            fieldPaths.add('SomTv_UmfeldFormat__c');
            fieldPaths.add('SomTv_SendeDatumVon__c');
            fieldPaths.add('SomTv_SendeDatumBis__c');
            fieldPaths.add('SomTv_SendeZeitVon__c');
            fieldPaths.add('SomTv_SendeZeitBis__c');
            fieldPaths.add('SomTv_Wochentag__c');
            fieldPaths.add('SomTv_Sendezeit__c');
            fieldPaths.add('SomTv_Ausstrahlung__c');
            fieldPaths.add('SomTv_Folgen__c');
            fieldPaths.add('Description');
            fieldPaths.add('SomTv_OpenerAnzahl__c');
            fieldPaths.add('SomTv_OpenerSek__c');
            fieldPaths.add('SomTv_CloserAnzahl__c');
            fieldPaths.add('SOmTv_CloserSek__c');
            fieldPaths.add('SomTv_ReminderAnzahl__c');
            fieldPaths.add('SomTv_ReminderSek__c');
            fieldPaths.add('SomTv_ScharnierAnzahl__c');
            fieldPaths.add('SomTv_ScharnierSek__c');
            fieldPaths.add('SomTv_SplitsSpots__c');
            fieldPaths.add('SomTv_TechnischeLaenge__c');
            fieldPaths.add('SomTv_AbzurechnendeLaenge__c');
            fieldPaths.add('SomTv_NrProzent__c');
            fieldPaths.add('SomTv_NrGoodwillInEUR__c');
            fieldPaths.add('UnitPrice');
            fieldPaths.add('SomTv_DispoPreisprozent__c');
            fieldPaths.add('SomTv_MB1Bezahlt__c');
            fieldPaths.add('BR__c');
            fieldPaths.add('SomTv_AE_inProzent__c');
            fieldPaths.add('SomTv_Skonto__c');
            fieldPaths.add('SomTv_MN3__c');
            fieldPaths.add('SomTv_Yield__c');
            fieldPaths.add('Opportunity.SomTV_Innerhalb_Commitment__c');
            fieldPaths.add('SomTv_Faktura__c');
            fieldPaths.add('Opportunity.SomTv_Konvergent__c');
            fieldPaths.add('SomTv_Buchungssystem__c');
            fieldPaths.add('SomTv_Umsatzaenderung__c');
            fieldPaths.add('SomTv_FakturaInfofeld__c');
            fieldPaths.add('Opportunity.SomTv_ErlaeuterungGeschaeftsvorfall_del__c');
            fieldPaths.add('Opportunity.SomTv_AdFProjekt__r.SomTv_SomTvSales__r.Name');
            fieldPaths.add('Opportunity.SomTv_AdFProjekt__r.SomTv_DigitalSales__r.Name');
            fieldPaths.add('Opportunity.SomTv_AdFProjekt__r.SomTv_AdFConceptAdSales__r.Name');
            fieldPaths.add('Opportunity.SomTv_AdFProjekt__r.SomTv_AdFProjectManager__r.Name');
            fieldPaths.add('Opportunity.SomTv_AdFProjekt__r.SomTv_AgencyServiceTeam__c');
        }
        
        
        private void addFieldLabels()
        {
            fieldLabels.put('Opportunity.Account.Name', 'Account Name');
            fieldLabels.put('Opportunity.SomTv_MutterOpportunity__r.Name', 'Mutter Opportunity');
            fieldLabels.put('SomTv_Kundenprodukt__c', 'Kundenprodukt');
            fieldLabels.put('Opportunity.SomTv_Externe_ID__r.Name', 'ProSedi ID buchender Kunde');
            fieldLabels.put('Opportunity.SomTv_ProSedi_ID_Rechnungsadresse__r.Name', 'ProSedi ID Rechnungsadresse');
            fieldLabels.put('Opportunity.SomTv_Agentur__r.Name', 'Agentur');
            fieldLabels.put('Opportunity.SomTv_Beziehung__r.ConnectionReceivedId', 'Beziehung');
            fieldLabels.put('Product2.Name', 'Product Name');
            fieldLabels.put('SomTv_AdFProductHelper__r.Name', 'Product Name');
            fieldLabels.put('SomTv_Sponsoring__c', 'Sponsoring');
            fieldLabels.put('SomTv_Fremdbezug__c', 'Fremdbezug');
            fieldLabels.put('SomTv_NrGoodwill__c', 'NR/Goodwill/Diverse');
            fieldLabels.put('SomTv_Geschaeftsart__c', 'Geschäftsart');
            fieldLabels.put('SomTv_Tarifart__c', 'Tarifart');
            fieldLabels.put('SomTv_Detail_Informationen__c', 'Detail-Informationen');
            fieldLabels.put('SomTv_Sender__c', 'Sender');
            fieldLabels.put('SomTv_Genre__c', 'Genre');
            fieldLabels.put('SomTv_UmfeldFormat__c', 'Umfeld / Format');
            fieldLabels.put('SomTv_SendeDatumVon__c', 'Sendedatum von');
            fieldLabels.put('SomTv_SendeDatumBis__c', 'Sendedatum bis');
            fieldLabels.put('SomTv_SendeZeitVon__c', 'Sendezeit von');
            fieldLabels.put('SomTv_SendeZeitBis__c', 'Sendezeit bis');
            fieldLabels.put('SomTv_Wochentag__c', 'Wochentag');
            fieldLabels.put('SomTv_Sendezeit__c', 'Sendemonat');
            fieldLabels.put('SomTv_Ausstrahlung__c', 'Ausstrahlung');
            fieldLabels.put('SomTv_Folgen__c', 'Folgen');
            fieldLabels.put('Description', 'Line Description');
            fieldLabels.put('SomTv_OpenerAnzahl__c', 'Opener Anzahl');
            fieldLabels.put('SomTv_OpenerSek__c', 'Opener Sek');
            fieldLabels.put('SomTv_CloserAnzahl__c', 'Closer Anzahl');
            fieldLabels.put('SOmTv_CloserSek__c', 'Closer Sek');
            fieldLabels.put('SomTv_ReminderAnzahl__c', 'Reminder Anzahl');
            fieldLabels.put('SomTv_ReminderSek__c', 'Reminder Sek');
            fieldLabels.put('SomTv_ScharnierAnzahl__c', 'Scharnier Anzahl');
            fieldLabels.put('SomTv_ScharnierSek__c', 'Scharnier Sek');
            fieldLabels.put('SomTv_SplitsSpots__c', 'Splits/Spots');
            fieldLabels.put('SomTv_TechnischeLaenge__c', 'Technische Länge');
            fieldLabels.put('SomTv_AbzurechnendeLaenge__c', 'Abzurechnende Länge');
            fieldLabels.put('SomTv_NrProzent__c', 'NR (%)');
            fieldLabels.put('SomTv_DispoPreisprozent__c', 'Dispo-Preisprozent');
            fieldLabels.put('BR__c', 'BR (%)');
            fieldLabels.put('SomTv_AE_inProzent__c', 'AE (%)');
            fieldLabels.put('SomTv_Skonto__c', 'Skonto');
            fieldLabels.put('SomTv_Yield__c', 'Yield');
            fieldLabels.put('Opportunity.SomTV_Innerhalb_Commitment__c', 'Innerhalb Commitment / Zubuchung');
            fieldLabels.put('SomTv_Faktura__c', 'Faktura');
            fieldLabels.put('Opportunity.SomTv_Konvergent__c', 'konvergent');
            fieldLabels.put('SomTv_Buchungssystem__c', 'Buchungssystem');
            fieldLabels.put('SomTv_Umsatzaenderung__c', 'Umsatzänderung');
            fieldLabels.put('SomTv_FakturaInfofeld__c', 'Faktura Infofeld');
            fieldLabels.put('Opportunity.SomTv_ErlaeuterungGeschaeftsvorfall_del__c', 'Erläuterung Geschäftsvorfall');
            fieldLabels.put('Opportunity.SomTv_AdFProjekt__r.SomTv_SomTvSales__r.Name', 'AdFProjekt: Verkäufer SOM-TV Sales');
            fieldLabels.put('Opportunity.SomTv_AdFProjekt__r.SomTv_DigitalSales__r.Name', 'AdFProjekt: Verkäufer SOM Digital Sales');
            fieldLabels.put('Opportunity.SomTv_AdFProjekt__r.SomTv_AdFConceptAdSales__r.Name', 'AdFProjekt: Verkäufer AdF Concept Sales');
            fieldLabels.put('Opportunity.SomTv_AdFProjekt__r.SomTv_AdFProjectManager__r.Name', 'AdFProjekt: AdF Project Manager');
            fieldLabels.put('Opportunity.SomTv_AdFProjekt__r.SomTv_AgencyServiceTeam__c', 'AdFProjekt: Agency Service Team');
            
            //Currency
            fieldLabels.put('SomTv_NrGoodwillInEUR__c', 'NR/Goodwill/Diverse in EUR');
            fieldLabels.put('UnitPrice', 'Verkaufspreis in EUR');
            fieldLabels.put('SomTv_MB1Bezahlt__c', 'MB1 (bezahlt) in EUR');
            fieldLabels.put('SomTv_MN3__c', 'MN3 in EUR');
        }
    }
}