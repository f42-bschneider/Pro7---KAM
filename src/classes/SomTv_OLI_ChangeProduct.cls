public with sharing class SomTv_OLI_ChangeProduct {

    public OpportunityLineItem oli { get; set; }
    public List<Product2> availableProducts { get; set; }
    public String filterText { get; set; }

    /*
     * Constructor
     * - Instantiates OpportunityLineItem oli
     * - Creates initial list of available products
     */
    public SomTv_OLI_ChangeProduct() {
        Id oli_id = ApexPages.currentPage().getParameters().get('Id');

        if (oli_id == null) {
            addError('Bitte Id eines Opportunity Produkts übergeben.');
        } else {
            List<String> additional_fields = new List<String>{
                'Opportunity.Name', 'Opportunity.Pricebook2Id', 'Product2.Name',
                'PricebookEntry.Product2Id', 'PricebookEntry.Pricebook2Id', 'PricebookEntry.Pricebook2.Name'
            };
            String query = cls_P7S1_Utils.getStandardQuery('OpportunityLineItem', additional_fields);

            if (query != null) {
                query += ' WHERE Id = :oli_id';
                oli = Database.query(query);
            }

            retrieveProducts();
        }
    }

    /*
     * Change the Product2 of an OLI via the corresponding PricebookEntry and the SomTv_AdFProductHelper__c helper field (i.e. a lookup to Product2)
     * Updating the Product2Id/PricebookEntryId of an OLI is prohibited by Salesforce, therefore this is achieved by deleting the old OLI and creating a new one.
     *
     * Only succeeds if:
     * - SomTv_AdFProductHelper__c is given as a parameter and differs from the OLI's current Product2Id
     * - the chosen Product2 is active
     * - the chosen Product2 has an active PricebookEntry in the Pricebook which is connected via the current Product2/PricebookEntry
     */
    public PageReference changeProduct() {
        if (oli == null) {
            PageReference emptyPage = Page.SomTv_OLI_ChangeProduct;
            return emptyPage;

        } else if (oli.SomTv_AdFProductHelper__c == null) {
            addError('Bitte Produkt auswählen.');
            return null;

        } else if (oli.SomTv_AdFProductHelper__c == oli.PricebookEntry.Product2Id) {
            addError('Produkt hat sich nicht geändert.');
            return null;

        } else {
            PricebookEntry[] pricebook_entries = [
                SELECT Id, Pricebook2Id, Product2Id, UnitPrice, IsActive, Product2.IsActive
                    FROM PricebookEntry
                 WHERE Pricebook2Id = :oli.PricebookEntry.Pricebook2Id
                     AND Product2Id = :oli.SomTv_AdFProductHelper__c];

            if (pricebook_entries.isEmpty()) {
                addError('Produkt ist nicht in Preisbuch "' + oli.PricebookEntry.Pricebook2.Name + '" enthalten.');
                return null;

            } else {
                PricebookEntry pricebook_entry = pricebook_entries[0];

                if (!pricebook_entry.IsActive) {
                    addError('Preisbucheintrag ist nicht aktiv.');
                    return null;

                } else if (!pricebook_entry.Product2.IsActive) {
                    addError('Produkt ist nicht aktiv.');
                    return null;

                } else {
                    Savepoint sp = Database.setSavepoint();

                    try {
                        OpportunityLineItem new_oli = oli.clone();
                        new_oli.PricebookEntryId = pricebook_entry.Id;
                        new_oli.UnitPrice = pricebook_entry.UnitPrice;
                        new_oli.TotalPrice = null;
                        new_oli.SomTv_OliRabattierfaehig__c = false; // wird ggf. von Workflow wieder auf true gesetzt
                        new_oli.SomTv_AdFProductHelper__c = null;

                        delete oli;
                        insert new_oli;

                        PageReference oliPage = new ApexPages.StandardController(new_oli).edit();
                        oliPage.getParameters().put('retURL', new_oli.Id);
                        return oliPage;

                    } catch (Exception e) {
                        Database.rollback(sp);
                        addError(e.getMessage());
                        return null;
                    }
                }
            }
        }
    }

    /*
     * Returns a list of Product2 datasets
     * Optionally filtered by the filterText String which is set in the 'Filter' input field
     */
    public void retrieveProducts() {
        String soql =
            'SELECT Id, Name' +
            '    FROM Product2' +
            ' WHERE IsActive = true' +
            '     AND Id IN (SELECT Product2Id' +
            '                                FROM PriceBookEntry' +
            '                             WHERE IsActive = true' +
            '                                 AND Pricebook2Id = \'' + String.escapeSingleQuotes(oli.Opportunity.Pricebook2Id) + '\')';

        if (filterText != null && filterText != '')
                soql += ' AND Name LIKE \'%' + String.escapeSingleQuotes(filterText) + '%\'';
        soql += ' ORDER BY Name';

        availableProducts = Database.query(soql);
    }

    /*
     * Returns a list of SelectOptions for the availableProducts list
     */
    public List<SelectOption> getProducts() {
        List<SelectOption> options = new List<SelectOption>();
        for (Product2 product : availableProducts) {
            options.add(new SelectOption(product.Id, product.Name));
        }
        return options;
    }

    /*
     * Cancel the changeProduct operation and return to the OLI's detail page.
     */
    public PageReference cancel() {
        return new ApexPages.StandardController(oli).cancel();
    }

    /*
     * Add an error message to the page.
     */
    private void addError(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }

}