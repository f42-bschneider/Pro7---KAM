public with sharing class Ven_KPI_ChooseTemplate {

    /** Helper objects */
    public Ven_KeyPerformanceIndicatorTemplateEntry__c kpiteInputHelper {get;set;} // .Ven_KeyPerformanceIndicatorTemplate__c / .Ven_KeyPerformanceIndicatorBlock__c
    public Opportunity oppInputHelper {get;set;} // .CloseDate

    /** Render on Page */
    public Boolean renderKPITemplatePB {get;set;}
    public Boolean renderNewKPITemplatePB {get;set;}
    public Boolean renderAddedKPIBlocks {get;set;}
    public Boolean renderNewKPIBlockPB {get;set;}

    /** New objects */
    public Ven_KeyPerformanceIndicatorTemplate__c newKPITemplate {get;set;}
    public Ven_KeyPerformanceIndicatorBlock__c newKPIBlock {get;set;}

    /** Opportunity Id as string */
    private String oppIdStr;

    /** Selected KPI Ids */
    private Set<Id> selKPIIds;

    /**
     * To remove KPI Blocks from a KPI Template.
     * Key:
     *  KPI Block Id
     * Value:
     *  KPI Block Object
     */
    public Map<Id, Ven_KeyPerformanceIndicatorBlock__c> kpiBlockMap {get;set;}

    /** KPI Block Id To Remove */
    public String kpiBlockIdToRemove {get;set;}

    /** For the Pagination methods */
    public ApexPages.StandardSetController setController {get; private set;}

    /** This KPI Rows are displayed in the Pagination Block Table */
    public List<KPIrow> currentKPIrows {get;set;}

    /** How many KPI Rows on one page in the Pagination Block Table */
    public String pageSize {get;set;}

    /** Select All Checkbox value */
    public Boolean inputSelectAllChecked {get;set;}

    //public List<KPIrow> kpiRows {get;set;}
    //public Integer empSize {get; set;}


    /* ************************************************************************************* */


    /**
     * Constructor.
     */
    public Ven_KPI_ChooseTemplate(ApexPages.StandardController controller) { // TODO: ApexPages.StandardController ?
        this.oppIdStr = ApexPages.currentPage().getParameters().get('oppId');

        this.kpiteInputHelper = new Ven_KeyPerformanceIndicatorTemplateEntry__c();
        this.oppInputHelper = new Opportunity();
        showKPITemplatePB();
    }

    /**
     * The KPI Template Page Block will be rendered.
     */
    private void showKPITemplatePB() {
        this.renderKPITemplatePB = true;
        this.renderNewKPITemplatePB = false;
    }


    /* ************************************************************************************* */


    /**
     * ACTION.
     *
     * Creates a new KPI Template.
     */
    public void actionNewKPITemplate() {
        this.newKPITemplate = new Ven_KeyPerformanceIndicatorTemplate__c();
        this.kpiBlockMap = new Map<Id, Ven_KeyPerformanceIndicatorBlock__c>();
        this.renderAddedKPIBlocks = false;
        this.inputSelectAllChecked = false;

        showNewKPITemplate();
    }

    /**
     * The New KPI Template Page Block and the KPI Block Page Block will be rendered.
     */
    private void showNewKPITemplate() {
        this.renderKPITemplatePB = false;
        this.renderNewKPITemplatePB = true;
        this.renderNewKPIBlockPB = false;
    }

    /**
     * ACTION.
     *
     * Opens the Strategic Report Page.
     * Page Parameters:
     *  - kpiTemplateId
     *  - date
     *  - oppId
     *  - renderAs
     */
    public PageReference openStrategicReport() {
        if (this.kpiteInputHelper.Ven_KeyPerformanceIndicatorTemplate__c != null && this.oppInputHelper.CloseDate != null) {
            PageReference pageRef = Page.Ven_KPI_StrategicReport;
            pageRef.getParameters().put('kpiTemplateId', this.kpiteInputHelper.Ven_KeyPerformanceIndicatorTemplate__c);
            pageRef.getParameters().put('date', this.oppInputHelper.CloseDate.format());
            pageRef.getParameters().put('oppId', this.oppIdStr);
            pageRef.getParameters().put('renderAs', 'pdf');
            return pageRef;
        }

        return null;
    }


    /* ************************************************************************************* */


    /**
     * ACTION.
     *
     * The selected KPI Block will be added to the new KPI Template.
     */
    public void actionAddToKPITemplate() {
        if (this.kpiteInputHelper.Ven_KeyPerformanceIndicatorBlock__c != null) {
            List<Ven_KeyPerformanceIndicatorBlock__c> kpiBlocks = [SELECT Id, Name, Ven_MonthlyView__c, Ven_YearToDateView__c, Ven_FullYearView__c, Ven_Last6MonthsView__c
            FROM Ven_KeyPerformanceIndicatorBlock__c
            WHERE Id = :this.kpiteInputHelper.Ven_KeyPerformanceIndicatorBlock__c];

            this.kpiBlockMap.put(kpiBlocks.get(0).Id, kpiBlocks.get(0));
            this.kpiteInputHelper.Ven_KeyPerformanceIndicatorBlock__c = null;
            this.renderAddedKPIBlocks = true;
        }
    }

    /**
     * ACTION.
     *
     * Creates a new KPI Block.
     */
    public void actionNewKPIBlock() {
        this.newKPIBlock = new Ven_KeyPerformanceIndicatorBlock__c();
        this.selKPIIds = new Set<Id>();
        this.setController = new ApexPages.StandardSetController(Database.getQueryLocator(String.escapeSingleQuotes(getKPIQueryStr())));
        this.currentKPIrows = getKPIrows(this.setController.getRecords());
        this.pageSize = String.valueOf(this.setController.getPageSize());

        showNewKPIBlock();
    }

    /**
     * Creates KPI Rows.
     *
     * @param kpis
     *      KPI objects
     *
     * @return
     *    KPI Rows
     */
    private List<KPIrow> getKPIrows(List<Ven_Key_Performance_Indicator__c> kpis) {
        List<KPIrow> kpiRows = new List<KPIrow>();

        for (Ven_Key_Performance_Indicator__c kpi : kpis) {
            Boolean checked;

            if (!this.selKPIIds.contains(kpi.Id)) {
                checked = false;
            } else {
                checked = true;
            }

            kpiRows.add(new KPIrow(kpi, checked));
        }

        return kpiRows;
    }

    /**
     * The New KPI Block Page Block and the KPI Rows Page Block will be rendered.
     */
    private void showNewKPIBlock() {
        this.renderNewKPITemplatePB = false;
        this.renderNewKPIBlockPB = true;
    }

    /**
     * ACTION.
     *
     * Saves the new KPI Template.
     */
    public void saveNewKPITemplate() {
        if (this.newKPITemplate.Name != null) {
            if (!this.kpiBlockMap.isEmpty()) {
                insert this.newKPITemplate;

                List<Ven_KeyPerformanceIndicatorTemplateEntry__c> kpiTemplateEntriesToInsert = new List<Ven_KeyPerformanceIndicatorTemplateEntry__c>();

                for (Ven_KeyPerformanceIndicatorBlock__c kpiBlock : this.kpiBlockMap.values()) {
                    Ven_KeyPerformanceIndicatorTemplateEntry__c newKPITemplateEntry = new Ven_KeyPerformanceIndicatorTemplateEntry__c();
                    newKPITemplateEntry.Ven_KeyPerformanceIndicatorTemplate__c = this.newKPITemplate.Id;
                    newKPITemplateEntry.Ven_KeyPerformanceIndicatorBlock__c = kpiBlock.Id;
                    kpiTemplateEntriesToInsert.add(newKPITemplateEntry);
                }

                insert kpiTemplateEntriesToInsert;

                this.kpiteInputHelper.Ven_KeyPerformanceIndicatorTemplate__c = this.newKPITemplate.Id;

                showKPITemplatePB();
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Ein Template muss mindestens ein Block enthalten.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Sie müssen einen Template Namen vergeben.'));
        }
    }

    /**
     * ACTION.
     *
     * Removes a KPI Block from the new KPI Template.
     */
    public void actionRemoveKPIBlock() {
        if (this.kpiBlockIdToRemove != null && this.kpiBlockIdToRemove != '') {
            this.kpiBlockMap.remove(Id.valueOf(this.kpiBlockIdToRemove));
            this.kpiBlockIdToRemove = null;

            if (this.kpiBlockMap.isEmpty()) {
                this.renderAddedKPIBlocks = false;
            }
        }
    }

    /**
     * ACTION.
     *
     * Back to KPI Template Page Block.
     */
    public void backToKPITemplatePB() {
        showKPITemplatePB();
    }


    /* ************************************************************************************* */


    /**
     * ACTION.
     *
     * Saves the new KPI Block.
     */
    public void saveNewKPIBlock() {
        checkSelIdSet();

        if (this.newKPIBlock.Name != null) {
            if (!this.selKPIIds.isEmpty()) {
                insert this.newKPIBlock;

                List<Ven_KeyPerformanceIndicatorBlockEntry__c> kpiBlockEntriesToInsert = new List<Ven_KeyPerformanceIndicatorBlockEntry__c>();

                for (Id selKPIId : this.selKPIIds) {
                    Ven_KeyPerformanceIndicatorBlockEntry__c newKPIBlockEntry = new Ven_KeyPerformanceIndicatorBlockEntry__c();
                    newKPIBlockEntry.Ven_KeyPerformanceIndicatorBlock__c = this.newKPIBlock.Id;
                    newKPIBlockEntry.Ven_KeyPerformanceIndicator__c = selKPIId;
                    kpiBlockEntriesToInsert.add(newKPIBlockEntry);
                }

                insert kpiBlockEntriesToInsert;

                this.kpiBlockMap.put(this.newKPIBlock.Id, this.newKPIBlock);
                this.renderAddedKPIBlocks = true;

                showNewKPITemplate();
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Ein Block muss mindestens ein KPI enthalten.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Sie müssen ein Block Namen vergeben.'));
        }
    }

    /**
     * Compares the KPI rows with the selected KPI Ids.
     */
    private void checkSelIdSet() {
        for (KPIrow kpiRow : this.currentKPIrows) {
            if (kpiRow.checked) {
                this.selKPIIds.add(kpiRow.kpi.Id);
            } else {
                if (this.selKPIIds.contains(kpiRow.kpi.Id)) {
                    this.selKPIIds.remove(kpiRow.kpi.Id);

                    if (this.inputSelectAllChecked) {
                        this.inputSelectAllChecked = false;
                    }
                }
            }
        }
    }

    /**
     * ACTION.
     *
     * Back to new KPI Template Page Block.
     */
    public void backToNewKPITemplatePB() {
        showNewKPITemplate();
    }

    /**
     * ACTION.
     *
     * Toggles all checkboxes.
     */
    public void toggleCheckboxes() {
        if (this.inputSelectAllChecked) {
            this.selKPIIds.addAll(getAllKPIIds());
            toggleCurrentCheckboxes(true);
        } else {
            this.selKPIIds.clear();
            toggleCurrentCheckboxes(false);
        }

        checkSelIdSet();
    }

    /**
     * Toggles all checkboxes.
     */
    private void toggleCurrentCheckboxes(Boolean inputValue) {
        for (KPIrow kpiRow : this.currentKPIrows) {
            kpiRow.checked = inputValue;
        }
    }

    /**
     * Gets all KPI Ids.
     *
     * @return
     *    all KPI Ids
     */
    private List<Id> getAllKPIIds() {
        List<Id> allKPIIds = new List<Id>();

        for (Ven_Key_Performance_Indicator__c kpi : Database.query(String.escapeSingleQuotes(getKPIQueryStr()))) {
            allKPIIds.add(kpi.Id);
        }

        return allKPIIds;
    }

    /**
     * Gets the KPI Query String.
     *
     * @return
     *    the KPI Query String
     */
    private String getKPIQueryStr() {
        String kpiQueryStr = 'SELECT Id, Name, Ven_Category_KPI__c, Ven_Description__c, Ven_Filter__c, Ven_Sub_Category__c, Ven_Supplier__c, Ven_Unit__c'
        + ' FROM Ven_Key_Performance_Indicator__c'
        + ' ORDER BY Name ASC';

        return kpiQueryStr;
    }


    /* ********************************************************* */
    /* Pagination                                                */
    /* ********************************************************* */

    /**
     * Jumps to the first page.
     */
    public void first() {
        checkSelIdSet();
        this.setController.first();
        this.currentKPIrows = getKPIrows(this.setController.getRecords());
    }

    /**
     * Jumps to the last page.
     */
    public void last() {
        checkSelIdSet();
        this.setController.last();
        this.currentKPIrows = getKPIrows(this.setController.getRecords());
    }

    /**
     * Jumps to the next page.
     */
    public void next() {
        checkSelIdSet();
        this.setController.next();
        this.currentKPIrows = getKPIrows(this.setController.getRecords());
    }

    /**
     * Jumps to the previous page.
     */
    public void previous() {
        checkSelIdSet();
        this.setController.previous();
        this.currentKPIrows = getKPIrows(this.setController.getRecords());
    }

    /**
     * Sets the page size.
     */
    public void setPageSize() {
        if (this.pageSize != null && this.pageSize.isNumeric()) {
            checkSelIdSet();
            this.setController.setPageSize(Integer.valueOf(this.pageSize));
            this.currentKPIrows = getKPIrows(this.setController.getRecords());
        }
    }

    /**
     * Gets the Current Result Size From.
     *
     * @return the Current Result Size From
     */
    public Integer getCurrentResultSizeFrom() {
        Integer currentResultSizeFrom = (this.setController.getPageNumber() * this.setController.getPageSize()) - this.setController.getPageSize() + 1;

        return currentResultSizeFrom;
    }

    /**
     * Gets the Current Result Size To.
     *
     * @return the Current Result Size To
     */
    public Integer getCurrentResultSizeTo() {
        Integer currentResultSizeTo = (this.setController.getPageNumber() * this.setController.getPageSize()) - this.setController.getPageSize() + this.setController.getRecords().size();

        return currentResultSizeTo;
    }

    /**
     * Gets the Page Number Size.
     *
     * @return the Page Number Size
     */
    public Integer getPageNumberSize() {
        Integer pageNumberSize = Decimal.valueOf(this.setController.getResultSize()).divide(Decimal.valueOf(this.setController.getPageSize()), 0, system.RoundingMode.UP).intValue();

        return pageNumberSize;
    }


    /* ********************************************************* */
    /* Classes                                                   */
    /* ********************************************************* */

    public class KPIrow {
        public Ven_Key_Performance_Indicator__c kpi {get;set;}
        public Boolean checked {get;set;}

        public KPIrow(Ven_Key_Performance_Indicator__c kpi, Boolean checked) {
            this.kpi = kpi;
            this.checked = checked;
        }
    }
}