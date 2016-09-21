/**
 * If you want to create a new view search for 'insert new view here' and enter your code.
 */
public with sharing class Ven_KPI_StrategicReport {
  public String renderAs {get;set;}
  public PageHeader pageHeader {get;set;}
  public List<KpiTable> kpiTables {get;set;}
  
  public static Pattern KPIFormatPattern  = Pattern.compile('(\\D{0,1})(\\d{0,1})'); //non-digit + digit
  
  
  /**
   * Constructor.
   */
  public Ven_KPI_StrategicReport(ApexPages.StandardController stdController) { // TODO: ApexPages.StandardController ?

    this.renderAs = ApexPages.currentPage().getParameters().get('renderAs');
    Id kpiTemplateId = Id.valueOf(ApexPages.currentPage().getParameters().get('kpiTemplateId'));
    String dateStr = ApexPages.currentPage().getParameters().get('date');
    Id oppId = Id.valueOf(ApexPages.currentPage().getParameters().get('oppId'));
    
    Opportunity opp = getOpportunity(oppId);
    this.pageHeader = getPageHeader(opp.Account.Name, opp.LastModifiedDate.date().format(), opp.LastModifiedBy.Name, dateStr);
    
    Set<Id> kpiBlockIds = getKPIBlockIds(kpiTemplateId);
    List<Ven_KeyPerformanceIndicatorBlock__c> kpiBlocksWithKPIs = getKPIBlocksWithKPIs(kpiBlockIds);
    this.kpiTables = getKpiTables(kpiBlocksWithKPIs, Date.parse(dateStr), oppId);
    
    setTaskLines(oppId);
  }
  
  /**
   * Gets the Opportunity based on the Opportunity Id.
   *
   * @param oppId
   *      Opportunity Id
   *
   * @return
   *    Opportunity
   */
  private Opportunity getOpportunity(Id oppId) {
    Opportunity opp;
    
    List<Opportunity> oppList = [SELECT Id, Account.Name, LastModifiedDate, LastModifiedBy.Name
                    FROM Opportunity
                    WHERE Id = :oppId];
    
    if (oppList.size() == 1) {
      opp = oppList.get(0);
    }
    
    return opp;
  }
  
  /**
   * Creates the Page Header which is displayed on the PDF.
   *
   * @param accountName
   *      Account Name
   * @param lastModified
   *      Last Modified Date as string
   * @param lastUpdate
   *      Last Update By
   * @param periodStr
   *      Period Date as string
   *
   * @return
   *    Page Header
   */
  private PageHeader getPageHeader(String accountName, String lastModified, String lastUpdate, String periodStr) {
    PageHeader pageHeader = new PageHeader();
    pageHeader.accountName = accountName;
    pageHeader.lastModified = lastModified;
    pageHeader.lastUpdate = lastUpdate;
    
    Date period = Date.parse(periodStr);
    pageHeader.period = period.month() + ' ' + period.year();
    
    return pageHeader;
  }
  
  
  /* ******************************************************************************* */
  
  
  /**
   * Gets the KPI Block Ids based on the KPI Template Id.
   *
   * @param kpiTemplateId
   *      KPI Template Id
   *
   * @return
   *    KPI Block Ids
   */
  private Set<Id> getKPIBlockIds(Id kpiTemplateId) {
    Set<Id> kpiBlockIds = new Set<Id>();
    
    for (Ven_KeyPerformanceIndicatorTemplateEntry__c kpiTemplateEntry : [SELECT Id, Ven_KeyPerformanceIndicatorBlock__c
                                    FROM Ven_KeyPerformanceIndicatorTemplateEntry__c
                                    WHERE Ven_KeyPerformanceIndicatorTemplate__c = :kpiTemplateId]) {
      
      if (kpiTemplateEntry.Ven_KeyPerformanceIndicatorBlock__c != null) {
        kpiBlockIds.add(kpiTemplateEntry.Ven_KeyPerformanceIndicatorBlock__c);
      }
    }
    
    return kpiBlockIds;
  }
  
  /**
   * Gets the KPI Blocks and the KPIs as children lists based on the KPI Block Ids.
   *
   * @param kpiBlockIds
   *      KPI Block Ids
   *
   * @return
   *    KPI Blocks and the KPIs as children lists
   */
  private List<Ven_KeyPerformanceIndicatorBlock__c> getKPIBlocksWithKPIs(Set<Id> kpiBlockIds) {
    /* insert new view here */
    List<Ven_KeyPerformanceIndicatorBlock__c> kpiBlocksWithKPIs = [SELECT Id, Name, Ven_MonthlyView__c, Ven_YearToDateView__c, Ven_FullYearView__c, Ven_Last6MonthsView__c,
                                      (SELECT Id,
                                      Ven_KeyPerformanceIndicator__r.Name
                                      FROM Ven_KPIBlockEntries__r)
                                    FROM Ven_KeyPerformanceIndicatorBlock__c
                                    WHERE Id IN :kpiBlockIds];
    
    return kpiBlocksWithKPIs;
  }
  
  /**
   * Creates KPI Tables which are displayed on the PDF.
   *
   * @param kpiBlocksWithKPIs
   *      KPI Blocks and the KPIs as children lists
   * @param period
   *      Period Date
   * @param oppId
   *      Opportunity Id
   *
   * @return
   *    KPI Tables
   */
  private List<KpiTable> getKpiTables(List<Ven_KeyPerformanceIndicatorBlock__c> kpiBlocksWithKPIs, Date period, Id oppId) {
    List<KpiTable> kpiTables = new List<KpiTable>();
    Map<String, List<Ven_KeyPerformanceIndicatorBlock__c>> kpiBlocksMap = getKPIBlocksMap(kpiBlocksWithKPIs);
    
    for (List<Ven_KeyPerformanceIndicatorBlock__c> kpiBlocks : kpiBlocksMap.values()) {
      kpiTables.add(new KpiTable(kpiBlocks, period, oppId));
    }
    
    return kpiTables;
  }
  
  /**
   * Groups the KPI Blocks in KPI Tables.
   *
   * @param kpiBlocksWithKPIs
   *      KPI Blocks and the KPIs as children lists
   *
   * @return
   *    grouped KPI Blocks as map
   */
  private Map<String, List<Ven_KeyPerformanceIndicatorBlock__c>> getKPIBlocksMap(List<Ven_KeyPerformanceIndicatorBlock__c> kpiBlocksWithKPIs) {
    /**
     * Key:
     *  e.g. MonthlyView#YearToDateView#FullYearView
     * Value:
     *  KPI Blocks with the same View Checkboxes checked.
     */
    Map<String, List<Ven_KeyPerformanceIndicatorBlock__c>> kpiBlocksMap = new Map<String, List<Ven_KeyPerformanceIndicatorBlock__c>>();
    
    for (Ven_KeyPerformanceIndicatorBlock__c kpiBlockWithKPIs : kpiBlocksWithKPIs) {
      String tableKey = getTableKey(kpiBlockWithKPIs);
      
      if (!kpiBlocksMap.containsKey(tableKey)) {
        kpiBlocksMap.put(tableKey, new List<Ven_KeyPerformanceIndicatorBlock__c>());
      }
      
      kpiBlocksMap.get(tableKey).add(kpiBlockWithKPIs);
    }
    
    return kpiBlocksMap;
  }
  
  /**
   * Creates the Table Key.
   * Checks which View Checkbox is checked.
   * 
   * @param kpiBlock
   *      a KPI Block
   *
   * @return
   *    the Table Key
   */
  private String getTableKey(Ven_KeyPerformanceIndicatorBlock__c kpiBlock) {
    String tableKey = '';
    
    if (kpiBlock.Ven_MonthlyView__c) {
      tableKey = addMapKeyPart(tableKey, 'MonthlyView');
    }
    
    if (kpiBlock.Ven_YearToDateView__c) {
      tableKey = addMapKeyPart(tableKey, 'YearToDateView');
    }
    
    if (kpiBlock.Ven_FullYearView__c) {
      tableKey = addMapKeyPart(tableKey, 'FullYearView');
    }
    
    if (kpiBlock.Ven_Last6MonthsView__c) {
      tableKey = addMapKeyPart(tableKey, 'Last6MonthsView');
    }
    
    /* insert new view here */
    
    return tableKey;
  }
  
  /**
   * Adds a Key Part to a Key.
   *
   * @param mapKey
   *      a Key
   * @param mapKeyPart
   *      a Key Part to add
   *
   * @return
   *    extended Key Part
   */
  private String addMapKeyPart(String mapKey, String mapKeyPart) {
    if (mapKey != '') {
      mapKey += '#' + mapKeyPart;
    } else {
      mapKey = mapKeyPart;
    }
    
    return mapKey;
  }
  
  
  
  /* ******************************************************************************* */
  /* Classes                                                                         */
  /* ******************************************************************************* */
  
  /* ************ Page Header Class ************ */
  
  /**
   * Page Header.
   */
  public class PageHeader {
    public String accountName {get;set;}
    public String lastModified {get;set;}
    public String lastUpdate {get;set;}
    public String period {get;set;}
    
    public PageHeader() {
      
    }
  }
  
  
  /* ************ Table Classes ************ */
  
  /**
   * Table.
   */
  public class KpiTable {
    public Map<Integer, KpiTableColumn> kpiTableColumnMap {get;set;}
    public List<KpiTableRow> kpiTableRows {get;set;}
    
    public NameView nameView;
    public MonthlyView monthlyView;
    public YearToDateView yearToDateView;
    public FullYearView fullYearView;
    public Last6MonthsView last6MonthsView;
    /* insert new view here */
    
    private Boolean hasMonthlyView;
    private Boolean hasYearToDateView;
    private Boolean hasFullYearView;
    private Boolean hasLast6MonthsView;
    /* insert new view here */
    
    /**
     * Constructor.
     *
     * @param kpiBlocks
     *      KPI Blocks
     * @param period
     *      Period Date
     * @param oppId
     *      Opportunity Id
     */
    public KpiTable(List<Ven_KeyPerformanceIndicatorBlock__c> kpiBlocks, Date period, Id oppId) {
      checkViews(kpiBlocks.get(0));
      setViews(kpiBlocks, period, oppId);
      setKpiTableColumnMap();
      setKpiTableRows();
    }
    
    /**
     * Checks which Views are checked.
     *
     * @param kpiBlock
     *      a KPI Block of this KPI Table
     */
    private void checkViews(Ven_KeyPerformanceIndicatorBlock__c kpiBlock) {
      if (kpiBlock.Ven_MonthlyView__c) {
        this.hasMonthlyView = true;
      } else {
        this.hasMonthlyView = false;
      }
      
      if (kpiBlock.Ven_YearToDateView__c) {
        this.hasYearToDateView = true;
      } else {
        this.hasYearToDateView = false;
      }
      
      if (kpiBlock.Ven_FullYearView__c) {
        this.hasFullYearView = true;
      } else {
        this.hasFullYearView = false;
      }
      
      if (kpiBlock.Ven_Last6MonthsView__c) {
        this.hasLast6MonthsView = true;
      } else {
        this.hasLast6MonthsView = false;
      }
      
      /* insert new view here */
    }
    
    /**
     * Creates the Views for this KPI Table.
     *
     * @param kpiBlocks
     *      KPI Blocks
     * @param period
     *      Period Date
     * @param oppId
     *      Opportunity Id
     */
    private void setViews(List<Ven_KeyPerformanceIndicatorBlock__c> kpiBlocks, Date period, Id oppId) {
      Map<String, List<KPIObj>> kpiObjBlockMap = getKPIObjBlockMap(kpiBlocks, period, oppId); // TODO: do this before new table loop ?
      
      setName(kpiObjBlockMap);
      
      if (this.hasMonthlyView) {
        setMonthlyView(kpiObjBlockMap, period);
      }
      
      if (this.hasYearToDateView) {
        setYearToDateView(kpiObjBlockMap, period);
      }
      
      if (this.hasLast6MonthsView) {
        setLast6MonthsView(kpiObjBlockMap, period);
      }
      
      if (this.hasFullYearView) {
        setFullYearView(kpiObjBlockMap, period);
      }
      
      /* insert new view here */
    }
    
    private Integer getIntValue(Decimal value) {
      if (value == null) {
        return 0;
      }
      else {
        return value.intValue();
      }
    }
    
    /**
     * Creates a KPIObj list for each KPI Block.
     *
     * @param kpiBlocks
     *      KPI Blocks
     * @param period
     *      Period Date
     * @param oppId
     *      Opportunity Id
     *
     * @return
     *    KPI Objects grouped by KPI Block Name
     */
    private Map<String, List<KPIObj>> getKPIObjBlockMap(List<Ven_KeyPerformanceIndicatorBlock__c> kpiBlocks, Date period, Id oppId) {
      /**
       * Key:
       *  KPI Block Name
       * Value:
       *  KPIObj objects
       */
      Map<String, List<KPIObj>> kpiObjBlockMap = new Map<String, List<KPIObj>>();
      
      /**
       * Key:
       *  KPI Id
       * Value:
       *  KPI Block Name
       */
      Map<Id, String> kpiBlockNameMap = new Map<Id, String>();
      
      for (Ven_KeyPerformanceIndicatorBlock__c kpiBlock : kpiBlocks) {
        for (Ven_KeyPerformanceIndicatorBlockEntry__c kpiBlockEntry : kpiBlock.Ven_KPIBlockEntries__r) {
          kpiBlockNameMap.put(kpiBlockEntry.Ven_KeyPerformanceIndicator__c, kpiBlock.Name); // TODO: kpiBlock as value ?
        }
      }
      
      /**
       * Key:
       *  KPI Id
       * Value:
       *  KPIObj object
       */
      Map<Id, KPIObj> kpiObjMap = new Map<Id, KPIObj>();
      
      Set<Id> kpiIds = kpiBlockNameMap.keySet(); // for the Database.query
      
      for (Ven_Financial_Model_Data__c financialModelData : Database.query(String.escapeSingleQuotes(getFinancialModelDataQryStr(period)))) {
        if (!kpiObjMap.containsKey(financialModelData.Key_Performance_Indicator__c)) {
          kpiObjMap.put(financialModelData.Key_Performance_Indicator__c, new KPIObj(financialModelData.Key_Performance_Indicator__r.Name, financialModelData.Key_Performance_Indicator__r.Ven_Format__c));
        }
        
        if (financialModelData.Financial_Model_Version__r.RecordType.DeveloperName == 'Ven_Plan_Data') {
          kpiObjMap.get(financialModelData.Key_Performance_Indicator__c).planDataList.add(financialModelData);
        } else if (financialModelData.Financial_Model_Version__r.RecordType.DeveloperName == 'Ven_Actual_Data') {
          kpiObjMap.get(financialModelData.Key_Performance_Indicator__c).actualDataList.add(financialModelData);
        } else if (financialModelData.Financial_Model_Version__r.RecordType.DeveloperName == 'Ven_Budget_Data') {
          kpiObjMap.get(financialModelData.Key_Performance_Indicator__c).budgetDataList.add(financialModelData);
        }
      }
      
      for (String kpiId : kpiObjMap.keySet()) {
        if (!kpiObjBlockMap.containsKey(kpiBlockNameMap.get(kpiId))) {
          kpiObjBlockMap.put(kpiBlockNameMap.get(kpiId), new List<KPIObj>());
        }
        
        kpiObjBlockMap.get(kpiBlockNameMap.get(kpiId)).add(kpiObjMap.get(kpiId));
      }
      
      return kpiObjBlockMap;
    }
    
    /**
     * Creates the Financial Model Data Query String.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Financial Model Data Query String
     */
    private String getFinancialModelDataQryStr(Date period) {
      String financialModelDataQryStr = 'SELECT Id, Name, Ven_Value__c, Ven_Datum__c, Month__c, Year__c,'
                      + ' Key_Performance_Indicator__c, Key_Performance_Indicator__r.Name, Key_Performance_Indicator__r.Ven_Format__c,'
                      + ' Financial_Model_Version__r.RecordType.DeveloperName'
                      + ' FROM Ven_Financial_Model_Data__c'
                      + ' WHERE Key_Performance_Indicator__c IN :kpiIds'
                      + ' AND Financial_Model_Version__r.Ven_Opportunity__c = :oppId';
      
      Date firstOfLastYear = Date.newInstance(period.addYears(-1).year(), 1, 1);
      Date lastOfThisYear = Date.newInstance(period.year(), 12, 31);
      
      financialModelDataQryStr += ' AND Ven_Datum__c >= ' + String.valueOf(firstOfLastYear);
      financialModelDataQryStr += ' AND Ven_Datum__c <= ' + String.valueOf(lastOfThisYear);
      
      return financialModelDataQryStr;
    }
    
    /**
     * Creates the Name Column (always the first Column in a KPI Table).
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     */
    private void setName(Map<String, List<KPIObj>> kpiObjBlockMap) {
      this.nameView = new NameView(kpiObjBlockMap);
    }
    
    /**
     * Creates the Monthly View Columns.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    private void setMonthlyView(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.monthlyView = new MonthlyView(kpiObjBlockMap, period);
    }
    
    /**
     * Creates the Year-to-Date View Columns.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    private void setYearToDateView(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.yearToDateView = new YearToDateView(kpiObjBlockMap, period);
    }
    
    /**
     * Creates the Full Year View Columns.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    private void setFullYearView(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.fullYearView = new FullYearView(kpiObjBlockMap, period);
    }
    
    /**
     * Creates the Last 6 months View Columns.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    private void setLast6MonthsView(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.last6MonthsView = new Last6MonthsView(kpiObjBlockMap, period);
    }
    
    /* insert new view here */
    
    /**
     * Adds the KPI View Columns to the KPI Table Columns.
     */
    private void setKpiTableColumnMap() {
      this.kpiTableColumnMap = new Map<Integer, KpiTableColumn>();
      Integer tablePos = this.kpiTableColumnMap.size();
      
      for (Integer viewPos : this.nameView.getKpiViewColumnMap().keySet()) {
        tablePos++;
        this.kpiTableColumnMap.put(tablePos, this.nameView.getKpiViewColumnMap().get(viewPos));
      }
      
      if (this.hasMonthlyView) {
        for (Integer viewPos : this.monthlyView.getKpiViewColumnMap().keySet()) {
          tablePos++;
          this.kpiTableColumnMap.put(tablePos, this.monthlyView.getKpiViewColumnMap().get(viewPos));
        }
      }
      
      if (this.hasYearToDateView) {
        for (Integer viewPos : this.yearToDateView.getKpiViewColumnMap().keySet()) {
          tablePos++;
          this.kpiTableColumnMap.put(tablePos, this.yearToDateView.getKpiViewColumnMap().get(viewPos));
        }
      }
      
      if (this.hasLast6MonthsView) {
        for (Integer viewPos : this.last6MonthsView.getKpiViewColumnMap().keySet()) {
          tablePos++;
          this.kpiTableColumnMap.put(tablePos, this.last6MonthsView.getKpiViewColumnMap().get(viewPos));
        }
      }
      
      if (this.hasFullYearView) {
        for (Integer viewPos : this.fullYearView.getKpiViewColumnMap().keySet()) {
          tablePos++;
          this.kpiTableColumnMap.put(tablePos, this.fullYearView.getKpiViewColumnMap().get(viewPos));
        }
      }
      
      /* insert new view here */
    }
    
    /**
     * Adds KPI View Rows (Cells) to the KPI Table Rows.
     */
    private void setKpiTableRows() {
      this.kpiTableRows = new List<KpiTableRow>();
      
      this.kpiTableRows = addToKpiTableRow(this.kpiTableRows, this.nameView.getKpiViewRows());
      
      if (this.hasMonthlyView) {
        this.kpiTableRows = addToKpiTableRow(this.kpiTableRows, this.monthlyView.getKpiViewRows());
      }
      
      if (this.hasYearToDateView) {
        this.kpiTableRows = addToKpiTableRow(this.kpiTableRows, this.yearToDateView.getKpiViewRows());
      }
      
      if (this.hasLast6MonthsView) {
        this.kpiTableRows = addToKpiTableRow(this.kpiTableRows, this.last6MonthsView.getKpiViewRows());
      }
      
      if (this.hasFullYearView) {
        this.kpiTableRows = addToKpiTableRow(this.kpiTableRows, this.fullYearView.getKpiViewRows());
      }
      
      /* insert new view here */
    }
    
    /**
     * Adds KPI View Rows (Cells) to the KPI Table Rows.
     *
     * @param kpiTableRows
     *      KPI Table Rows
     * @param rowsWithCellsToAdd
     *      KPI View Rows (Cells) to add
     *
     * @return
     *    extended KPI Table Rows
     */
    private List<KpiTableRow> addToKpiTableRow(List<KpiTableRow> kpiTableRows, List<KpiTableRow> rowsWithCellsToAdd) {
      if (!kpiTableRows.isEmpty() && kpiTableRows.size() == rowsWithCellsToAdd.size()) {
        for (Integer i=0; i<kpiTableRows.size(); i++) {
          Map<String, KpiTableCell> kpiTableCellMap = rowsWithCellsToAdd.get(i).kpiTableCellMap;
          
          for (String columnKey : kpiTableCellMap.keySet()) {
            kpiTableRows.get(i).kpiTableCellMap.put(columnKey, kpiTableCellMap.get(columnKey));
          }
        }
      } else {
        kpiTableRows.addAll(rowsWithCellsToAdd);
      }
      
      return kpiTableRows;
    }
  }
  
  
  /**
   * Column.
   */
  public class KpiTableColumn {
    public String headerTitle {get;set;}
    public Integer headerTitleColspan {get;set;}
    public String headerTitleBackgroundColor {get;set;}
    public String headerDateStr {get;set;}
    public String cellKey {get;set;}
    
    /**
     * Constructor.
     *
     * @param cellKey
     *      e.g. 'MonthlyViewLastYearACT'
     */
    public KpiTableColumn(String cellKey) {
      this.cellKey = cellKey;
    }
    
    /**
     * Sets the Header Title of this Column.
     *
     * @param headerTitle
     *      e.g. 'Monthly View'
     * @param headerTitleColspan
     *      value for 'colspan' (td tag attribute)
     * @param headerTitleBackgroundColor
     *      value for 'background-color' (html style attribute)
     */
    public void setHeaderTitle(String headerTitle, Integer headerTitleColspan, String headerTitleBackgroundColor) {
      this.headerTitle = headerTitle;
      this.headerTitleColspan = headerTitleColspan;
      this.headerTitleBackgroundColor = headerTitleBackgroundColor;
    }
    
    /**
     * Sets the Header Title of this Column.
     * Sets the Background Color to default.
     *
     * @param headerTitle
     *      e.g. 'Monthly View'
     * @param headerTitleColspan
     *      value for 'colspan' (td tag attribute)
     */
    public void setHeaderTitle(String headerTitle, Integer headerTitleColspan) {
      this.headerTitle = headerTitle;
      this.headerTitleColspan = headerTitleColspan;
      this.headerTitleBackgroundColor = '#FFFFFF';
    }
    
    /**
     * Sets the Header Title of this Column.
     * Sets the Colspan to default.
     * Sets the Background Color to default.
     *
     * @param headerTitle
     *      e.g. 'Monthly View'
     */
    public void setHeaderTitle(String headerTitle) {
      this.headerTitle = headerTitle;
      this.headerTitleColspan = 1;
      this.headerTitleBackgroundColor = '#FFFFFF';
    }
    
    /**
     * Sets the Header Title Colspan of this Column.
     *
     * @param headerTitleColspan
     *      value for 'colspan' (td tag attribute)
     */
    public void setHeaderTitleColspan(Integer headerTitleColspan) {
      this.headerTitleColspan = headerTitleColspan;
    }
    
    /**
     * Sets the Header Title Background Color of this Column.
     *
     * @param headerTitleBackgroundColor
     *      value for 'background-color' (html style attribute)
     */
    public void setHeaderTitleBackgroundColor(String headerTitleBackgroundColor) {
      this.headerTitleBackgroundColor = headerTitleBackgroundColor;
    }
    
    /**
     * Sets the Header Date String.
     *
     * @param headerDateStr
     *      Header Date String
     */
    public void setHeaderDateStr(String headerDateStr) {
      this.headerDateStr = headerDateStr;
    }
  }
  
  
  /**
   * Row.
   */
  public class KpiTableRow {
    public Map<String, KpiTableCell> kpiTableCellMap {get;set;}
    
    /**
     * Constructor.
     */
    public KpiTableRow() {
      this.kpiTableCellMap = new Map<String, KpiTableCell>();
    }
  }
  
  
  /**
   * Cell.
   */
  public class KpiTableCell {
    public String value {get;set;}
    public String backgroundColor {get;set;}
    public String fontWeight {get;set;}
    public String borderBottom {get;set;}
    
    /**
     * Constructor.
     * These html style attributes are set to default:
     *  - backgroound-color
     *  - font-weight
     *  - border-bottom
     *
     * @param value
     *      the value of this Cell
     */
    public KpiTableCell(String value) {
      this.value = value;
      this.backgroundColor = '#FFFFFF';
      this.fontWeight = 'normal';
      this.borderBottom = 'none';
    }
    
    /**
     * Constructor.
     * The value is set to blank.
     * These html style attributes are set to default:
     *  - backgroound-color
     *  - font-weight
     *  - border-bottom
     */
    public KpiTableCell() {
      this.value = '';
      this.backgroundColor = '#FFFFFF';
      this.fontWeight = 'normal';
      this.borderBottom = 'none';
    }
  }

  /* ************ View Classes ************ */
  
  /**
   * View.
   */
  public virtual class View {
    private Date period;

    public KpiTableColumn columnName;
    public KpiTableColumn columnEmptyBefore;
    public KpiTableColumn columnLastYearACT;
    public KpiTableColumn columnLastMonthACT;
    public KpiTableColumn columnThisMonthBDT;
    public KpiTableColumn columnThisMonthACT;
    public KpiTableColumn columnLastYearFYACT;
    public KpiTableColumn columnThisYearFYBDT;
    public KpiTableColumn columnEmptyBetween;
    public KpiTableColumn columnLastYearACTDeviation;
    public KpiTableColumn columnLastMonthACTDeviation;
    public KpiTableColumn columnThisMonthBDTDeviation;
    public KpiTableColumn columnLastYearFYACTDeviation;
    public KpiTableColumn columnMonth6ACT;
    public KpiTableColumn columnMonth5ACT;
    public KpiTableColumn columnMonth4ACT;
    public KpiTableColumn columnMonth3ACT;
    public KpiTableColumn columnMonth2ACT;
    
    /* (insert new view here) */
    
    public Map<Integer, KpiTableColumn> kpiViewColumnMap;
    public List<KpiTableRow> kpiViewRows;
    /*
    private String normalizeKPIFormat(String format) {
      if (format.isAlpha) {
        format  += '0';
      } else if (format.isNumeric) {
        format  = 'X' + format;
      }
      else {
        format  = 'X0';
      }
      
      return format;
    }
    */
    private String formatValue(Decimal value, String format) {
      //format  = normalizeKPIFormat(format);
      if (format == null) {
        format  = '';
      }
      Matcher KPIFormatMatcher  = Ven_KPI_StrategicReport.KPIFormatPattern.matcher(format);
      Integer decimals  = 0;
      String shortFormat  = '';
      
      if (KPIFormatMatcher.matches()) {
        if (value != null && value != 0) {
          if (KPIFormatMatcher.group(1) == 'K') {
            value  = value / 1000;
            shortFormat  = 'K';
          }
          else if (KPIFormatMatcher.group(1) == 'M') {
            value  = value / 1000000;
            shortFormat  = 'M';
          }
        }
        if (KPIFormatMatcher.group(2) != null && KPIFormatMatcher.group(2) != '') {
          decimals  = Integer.valueOf(KPIFormatMatcher.group(2));
        }
      }
      
      String formattedValue  = ClsHelper.formatDecimal(value, decimals, /*Userinfo.getLocale()*/ 'en_US');
      
      return formattedValue != null ? formattedValue + shortFormat : formattedValue;
    }
    
    /**
     * Creates the Date String for a Last Year Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a Last Year Column
     */
    public String getColumnLastYearHeaderDateStr(Date period) {
      return String.valueOf(period.addYears(-1).month()) + '-' + String.valueOf(period.addYears(-1).year());
    }
    
    /**
     * Creates the Date String for a Last Month Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a Last Month Column
     */
    public String getColumnLastMonthHeaderDateStr(Date period) {
      return String.valueOf(period.addMonths(-1).month()) + '-' + String.valueOf(period.addMonths(-1).year());
    }
    
    /**
     * Creates the Date String for a This Month Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a This Month Column
     */
    public String getColumnThisMonthHeaderDateStr(Date period) {
      return String.valueOf(period.month()) + '-' + String.valueOf(period.year());
    }
    
    /**
     * Creates the Date String for a Last Year (Full Year) Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a Last Year (Full Year) Column
     */
    public String getColumnLastYearHeaderFYDateStr(Date period) {
      return 'FY-' + String.valueOf(period.addYears(-1).year());
    }
    
    /**
     * Creates the Date String for a This Year (Full Year) Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a This Year (Full Year) Column
     */
    public String getColumnThisYearHeaderFYDateStr(Date period) {
      return 'FY-' + String.valueOf(period.year());
    }
    
    /**
     * Creates the Date String for a Month 6 Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a Month 6 Column
     */
    public String getColumnMonth6HeaderDateStr(Date period) {
      return String.valueOf(period.addMonths(-5).month()) + '-' + String.valueOf(period.addMonths(-5).year());
    }
    
    /**
     * Creates the Date String for a Month 5 Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a Month 5 Column
     */
    public String getColumnMonth5HeaderDateStr(Date period) {
      return String.valueOf(period.addMonths(-4).month()) + '-' + String.valueOf(period.addMonths(-4).year());
    }
    
    /**
     * Creates the Date String for a Month 4 Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a Month 4 Column
     */
    public String getColumnMonth4HeaderDateStr(Date period) {
      return String.valueOf(period.addMonths(-3).month()) + '-' + String.valueOf(period.addMonths(-3).year());
    }
    
    /**
     * Creates the Date String for a Month 3 Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a Month 3 Column
     */
    public String getColumnMonth3HeaderDateStr(Date period) {
      return String.valueOf(period.addMonths(-2).month()) + '-' + String.valueOf(period.addMonths(-2).year());
    }
    
    /**
     * Creates the Date String for a Month 2 Column.
     *
     * @param period
     *      Period Date
     *
     * @return
     *    the Date String for a Month 2 Column
     */
    public String getColumnMonth2HeaderDateStr(Date period) {
      return String.valueOf(period.addMonths(-1).month()) + '-' + String.valueOf(period.addMonths(-1).year());
    }
    
    /* (insert new view here) */
    
    /**
     * Gets all Columns in this View.
     *
     * @return
     *    all Columns in this View
     */
    public Map<Integer, KpiTableColumn> getKpiViewColumnMap() {
      return this.kpiViewColumnMap;
    }
    
    /**
     * Gets all Rows in this View.
     *
     * @return
     *    all Rows in this View
     */
    public List<KpiTableRow> getKpiViewRows() {
      return this.kpiViewRows;
    }
    
    /**
     * Creates a KPI Table Cell for a Block Line.
     * Font Weight and Border Bottom styles are set.
     *
     * @param value
     *      the value of this Cell
     *
     * @return
     *    a KPI Table Cell for a Block Line
     */
    public KpiTableCell getBlockLineKpiTableCell(String value) {
      KpiTableCell kpiTableCell = new KpiTableCell(value);
      
      if (value != '') {
        kpiTableCell.fontWeight = 'bold';
      }
      
      kpiTableCell.borderBottom = '2px #94B3D6 solid';
      
      return kpiTableCell;
    }

    /**
     * Formates the Cell value.
     *
     * @param value
     *      value as decimal
     *
     * @return
     *    value as string
     */
    public String formatData(Decimal value) {
      String valueStr = '';
      
      valueStr = value.format();
      
      return valueStr;
    }
    
    /**
     * Formates the Cell value (%).
     *
     * @param value
     *      value as integer
     *
     * return
     *    value as string
     */
    public String formatData(Integer value) {
      String valueStr = '';
      
      if (value != null) {
        valueStr = value.format() + '%';
      }
      
      return valueStr;
    }
  }
  
  
  /**
   * Name View.
   */
  public class NameView extends View {
    
    /**
     * Constructor.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     */
    public NameView(Map<String, List<KPIObj>> kpiObjBlockMap) {
      setColumnName();
      
      setKpiViewColumnMap();
      setKpiViewRows(kpiObjBlockMap);
    }
    
    /**
     * Creates the Name Column.
     */
    private void setColumnName() {
      this.columnName = new KpiTableColumn('Name');
      this.columnName.setHeaderTitle(''); // TODO: ?
      this.columnName.setHeaderDateStr('');
    }
    
    /**
     * Puts all Name View Columns in a map.
     */
    private void setKpiViewColumnMap() {
      this.kpiViewColumnMap = new Map<Integer, KpiTableColumn>();
      this.kpiViewColumnMap.put(1, this.columnName);
    }
    
    /**
     * Adds all Name View Rows to a list.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     */
    private void setKpiViewRows(Map<String, List<KPIObj>> kpiObjBlockMap) {
      this.kpiViewRows = new List<KpiTableRow>();
      Boolean isFirstBlockInTable = true; // TODO: pageBreaks
      
      for (String blockName : kpiObjBlockMap.keySet()) {
        KpiTableRow kpiBlockHeaderViewRow = new KpiTableRow();
        
        kpiBlockHeaderViewRow.kpiTableCellMap.put('Name', getBlockLineKpiTableCell(blockName));
        
        this.kpiViewRows.add(kpiBlockHeaderViewRow);
        
        for (KPIObj kpiObj : kpiObjBlockMap.get(blockName)) {
          KpiTableRow kpiViewRow = new KpiTableRow();
          
          KpiTableCell kpiTableCell = new KpiTableCell(kpiObj.kpiName);
          kpiTableCell.fontWeight = 'bold';
          kpiViewRow.kpiTableCellMap.put('Name', kpiTableCell);
          
          this.kpiViewRows.add(kpiViewRow);
        }
      }
    }
  }
  
  
  /**
   * Monthly View.
   */
  public class MonthlyView extends View {
    
    /**
     * Constructor.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    public MonthlyView(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.period = period;
      
      setColumnEmptyBefore();
      setColumnLastYearACT(period);
      setColumnLastMonthACT(period);
      setColumnThisMonthBDT(period);
      setColumnThisMonthACT(period);
      setColumnEmptyBetween();
      setColumnLastYearACTDeviation(period);
      setColumnLastMonthACTDeviation(period);
      setColumnThisMonthBDTDeviation(period);
      
      setKpiViewColumnMap();
      setKpiViewRows(kpiObjBlockMap, period);
    }
    
    /**
     * Creates a Empty Column.
     */
    private void setColumnEmptyBefore() {
      this.columnEmptyBefore = new KpiTableColumn('MonthlyViewEmptyBefore');
      this.columnEmptyBefore.setHeaderTitle('');
    }
    
    /**
     * Creates the Last Year ACT Column.
     */
    private void setColumnLastYearACT(Date period) {
      this.columnLastYearACT = new KpiTableColumn('MonthlyViewLastYearACT');
      this.columnLastYearACT.setHeaderTitle('Monthly View', 4, '#FF9900');
      this.columnLastYearACT.setHeaderDateStr(getColumnLastYearHeaderDateStr(period));
    }
    
    /**
     * Creates the Last Month ACT Column.
     */
    private void setColumnLastMonthACT(Date period) {
      this.columnLastMonthACT = new KpiTableColumn('MonthlyViewLastMonthACT');
      this.columnLastMonthACT.setHeaderDateStr(getColumnLastMonthHeaderDateStr(period));
    }
    
    /**
     * Creates the This Month BDT Column.
     */
    private void setColumnThisMonthBDT(Date period) {
      this.columnThisMonthBDT = new KpiTableColumn('MonthlyViewThisMonthBDT');
      this.columnThisMonthBDT.setHeaderDateStr(getColumnThisMonthHeaderDateStr(period));
    }
    
    /**
     * Creates the This Month ACT Column.
     */
    private void setColumnThisMonthACT(Date period) {
      this.columnThisMonthACT = new KpiTableColumn('MonthlyViewThisMonthACT');
      this.columnThisMonthACT.setHeaderDateStr(getColumnThisMonthHeaderDateStr(period));
    }
    
    /**
     * Creates a Empty Column.
     */
    private void setColumnEmptyBetween() {
      this.columnEmptyBetween = new KpiTableColumn('MonthlyViewEmptyBetween');
      this.columnEmptyBetween.setHeaderTitle('');
    }
    
    /**
     * Creates the Last Year ACT Deviation Column.
     */
    private void setColumnLastYearACTDeviation(Date period) {
      this.columnLastYearACTDeviation = new KpiTableColumn('MonthlyViewLastYearACTDeviation');
      this.columnLastYearACTDeviation.setHeaderTitle('Deviation Actuals vs.', 3, '#FFCC99');
      this.columnLastYearACTDeviation.setHeaderDateStr(getColumnLastYearHeaderDateStr(period));
    }
    
    /**
     * Creates the Last Month ACT Deviation Column.
     */
    private void setColumnLastMonthACTDeviation(Date period) {
      this.columnLastMonthACTDeviation = new KpiTableColumn('MonthlyViewLastMonthACTDeviation');
      this.columnLastMonthACTDeviation.setHeaderDateStr(getColumnLastMonthHeaderDateStr(period));
    }
    
    /**
     * Creates the This Month BDT Deviation Column.
     */
    private void setColumnThisMonthBDTDeviation(Date period) {
      this.columnThisMonthBDTDeviation = new KpiTableColumn('MonthlyViewThisMonthBDTDeviation');
      this.columnThisMonthBDTDeviation.setHeaderDateStr(getColumnThisMonthHeaderDateStr(period));
    }
    
    /**
     * Puts all Monthly View Columns in a map.
     */
    private void setKpiViewColumnMap() {
      this.kpiViewColumnMap = new Map<Integer, KpiTableColumn>();
      this.kpiViewColumnMap.put(1, this.columnEmptyBefore);
      this.kpiViewColumnMap.put(2, this.columnLastYearACT);
      this.kpiViewColumnMap.put(3, this.columnLastMonthACT);
      this.kpiViewColumnMap.put(4, this.columnThisMonthBDT);
      this.kpiViewColumnMap.put(5, this.columnThisMonthACT);
      this.kpiViewColumnMap.put(6, this.columnEmptyBetween);
      this.kpiViewColumnMap.put(7, this.columnLastYearACTDeviation);
      this.kpiViewColumnMap.put(8, this.columnLastMonthACTDeviation);
      this.kpiViewColumnMap.put(9, this.columnThisMonthBDTDeviation);
    }
    
    /**
     * Adds all Monthly View Rows to a list.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    private void setKpiViewRows(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.kpiViewRows = new List<KpiTableRow>();
      Boolean isFirstBlockInTable = true; // TODO: pageBreaks
      
      for (String blockName : kpiObjBlockMap.keySet()) {
        KpiTableRow kpiBlockHeaderViewRow = new KpiTableRow();
        
        if (!isFirstBlockInTable) {
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewEmptyBefore', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewLastYearACT', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewLastMonthACT', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewThisMonthBDT', getBlockLineKpiTableCell(''));
          
          KpiTableCell cellMonthlyViewThisMonthACT = getBlockLineKpiTableCell('');
          cellMonthlyViewThisMonthACT.backgroundColor = '#FFCC99';
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewThisMonthACT', cellMonthlyViewThisMonthACT);
          
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewEmptyBetween', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewLastYearACTDeviation', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewLastMonthACTDeviation', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewThisMonthBDTDeviation', getBlockLineKpiTableCell(''));
        } else {
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewEmptyBefore', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewLastYearACT', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewLastMonthACT', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewThisMonthBDT', getBlockLineKpiTableCell('BDT'));
          
          KpiTableCell cellMonthlyViewThisMonthACT = getBlockLineKpiTableCell('ACT');
          cellMonthlyViewThisMonthACT.backgroundColor = '#FFCC99';
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewThisMonthACT', cellMonthlyViewThisMonthACT);
          
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewEmptyBetween', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewLastYearACTDeviation', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewLastMonthACTDeviation', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('MonthlyViewThisMonthBDTDeviation', getBlockLineKpiTableCell('BDT'));
          
          isFirstBlockInTable = false;
        }
        
        this.kpiViewRows.add(kpiBlockHeaderViewRow);
        
        for (KPIObj kpiObj : kpiObjBlockMap.get(blockName)) {
          DataMonthlyView dataMonthlyView = new DataMonthlyView(kpiObj.actualDataList, kpiObj.budgetDataList, period);
          
          KpiTableRow kpiViewRow = new KpiTableRow();
          kpiViewRow.kpiTableCellMap.put('MonthlyViewEmptyBefore', new KpiTableCell());
          kpiViewRow.kpiTableCellMap.put('MonthlyViewLastYearACT', new KpiTableCell(formatValue(dataMonthlyView.lastYearACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('MonthlyViewLastMonthACT', new KpiTableCell(formatValue(dataMonthlyView.lastMonthACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('MonthlyViewThisMonthBDT', new KpiTableCell(formatValue(dataMonthlyView.thisMonthBDT,kpiObj.format)));
          
          KpiTableCell cellMonthlyViewThisMonthACT = new KpiTableCell(formatValue(dataMonthlyView.thisMonthACT,kpiObj.format));
          cellMonthlyViewThisMonthACT.backgroundColor = '#FFCC99';
          kpiViewRow.kpiTableCellMap.put('MonthlyViewThisMonthACT', cellMonthlyViewThisMonthACT);
          
          kpiViewRow.kpiTableCellMap.put('MonthlyViewEmptyBetween', new KpiTableCell());
          kpiViewRow.kpiTableCellMap.put('MonthlyViewLastYearACTDeviation', new KpiTableCell(formatValue(dataMonthlyView.lastYearDeviationACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('MonthlyViewLastMonthACTDeviation', new KpiTableCell(formatValue(dataMonthlyView.lastMonthDeviationACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('MonthlyViewThisMonthBDTDeviation', new KpiTableCell(formatValue(dataMonthlyView.thisMonthDeviationBDT,kpiObj.format)));
          
          this.kpiViewRows.add(kpiViewRow);
        }
      }
    }
  }
  
  
  /**
   * Year To Date View.
   */
  public class YearToDateView extends View {
    
    /**
     * Constructor.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    public YearToDateView(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.period = period;
      
      setColumnEmptyBefore();
      setColumnLastYearACT(period);
      setColumnThisMonthBDT(period);
      setColumnThisMonthACT(period);
      setColumnEmptyBetween();
      setColumnLastYearACTDeviation(period);
      setColumnThisMonthBDTDeviation(period);
      
      setKpiViewColumnMap();
      setKpiViewRows(kpiObjBlockMap, period);
    }
    
    /**
     * Creates a Empty Column.
     */
    private void setColumnEmptyBefore() {
      this.columnEmptyBefore = new KpiTableColumn('YearToDateViewEmptyBefore');
      this.columnEmptyBefore.setHeaderTitle('');
    }
    
    /**
     * Creates the Last Year ACT Column.
     */
    private void setColumnLastYearACT(Date period) {
      this.columnLastYearACT = new KpiTableColumn('YearToDateViewLastYearACT');
      this.columnLastYearACT.setHeaderTitle('Year-to-Date View', 3, '#6699FF');
      this.columnLastYearACT.setHeaderDateStr(getColumnLastYearHeaderDateStr(period));
    }
    
    /**
     * Creates the This Month BDT Column.
     */
    private void setColumnThisMonthBDT(Date period) {
      this.columnThisMonthBDT = new KpiTableColumn('YearToDateViewThisMonthBDT');
      this.columnThisMonthBDT.setHeaderDateStr(getColumnThisMonthHeaderDateStr(period));
    }
    
    /**
     * Creates the This Month ACT Column.
     */
    private void setColumnThisMonthACT(Date period) {
      this.columnThisMonthACT = new KpiTableColumn('YearToDateViewThisMonthACT');
      this.columnThisMonthACT.setHeaderDateStr(getColumnThisMonthHeaderDateStr(period));
    }
    
    /**
     * Creates a Empty Column.
     */
    private void setColumnEmptyBetween() {
      this.columnEmptyBetween = new KpiTableColumn('YearToDateViewEmptyBetween');
      this.columnEmptyBetween.setHeaderTitle('');
    }
    
    /**
     * Creates the Last Year ACT Deviation Column.
     */
    private void setColumnLastYearACTDeviation(Date period) {
      this.columnLastYearACTDeviation = new KpiTableColumn('YearToDateViewLastYearACTDeviation');
      this.columnLastYearACTDeviation.setHeaderTitle('Deviation Actuals vs.', 2, '#99CCFF');
      this.columnLastYearACTDeviation.setHeaderDateStr(getColumnLastYearHeaderDateStr(period));
    }
    
    /**
     * Creates the This Month BDT Deviation Column.
     */
    private void setColumnThisMonthBDTDeviation(Date period) {
      this.columnThisMonthBDTDeviation = new KpiTableColumn('YearToDateViewThisMonthBDTDeviation');
      this.columnThisMonthBDTDeviation.setHeaderDateStr(getColumnThisMonthHeaderDateStr(period));
    }
    
    /**
     * Puts all Year-to-Date View Columns in a map.
     */
    private void setKpiViewColumnMap() {
      this.kpiViewColumnMap = new Map<Integer, KpiTableColumn>();
      this.kpiViewColumnMap.put(1, this.columnEmptyBefore);
      this.kpiViewColumnMap.put(2, this.columnLastYearACT);
      this.kpiViewColumnMap.put(3, this.columnThisMonthBDT);
      this.kpiViewColumnMap.put(4, this.columnThisMonthACT);
      this.kpiViewColumnMap.put(5, this.columnEmptyBetween);
      this.kpiViewColumnMap.put(6, this.columnLastYearACTDeviation);
      this.kpiViewColumnMap.put(7, this.columnThisMonthBDTDeviation);
    }
    
    /**
     * Adds all Year-to-Date View Rows to a list.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    private void setKpiViewRows(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.kpiViewRows = new List<KpiTableRow>();
      Boolean isFirstBlockInTable = true; // TODO: pageBreaks
      
      for (String blockName : kpiObjBlockMap.keySet()) {
        KpiTableRow kpiBlockHeaderViewRow = new KpiTableRow();
        
        if (!isFirstBlockInTable) {
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewEmptyBefore', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewLastYearACT', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewThisMonthBDT', getBlockLineKpiTableCell(''));
          
          KpiTableCell cellYearToDateViewThisMonthACT = getBlockLineKpiTableCell('');
          cellYearToDateViewThisMonthACT.backgroundColor = '#99CCFF';
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewThisMonthACT', cellYearToDateViewThisMonthACT);
          
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewEmptyBetween', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewLastYearACTDeviation', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewThisMonthBDTDeviation', getBlockLineKpiTableCell(''));
        } else {
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewEmptyBefore', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewLastYearACT', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewThisMonthBDT', getBlockLineKpiTableCell('BDT'));
          
          KpiTableCell cellYearToDateViewThisMonthACT = getBlockLineKpiTableCell('ACT');
          cellYearToDateViewThisMonthACT.backgroundColor = '#99CCFF';
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewThisMonthACT', cellYearToDateViewThisMonthACT);
          
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewEmptyBetween', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewLastYearACTDeviation', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('YearToDateViewThisMonthBDTDeviation', getBlockLineKpiTableCell('BDT'));
          
          isFirstBlockInTable = false;
        }
        
        this.kpiViewRows.add(kpiBlockHeaderViewRow);
        
        for (KPIObj kpiObj : kpiObjBlockMap.get(blockName)) {
          DataYearToDateView dataYearToDateView = new DataYearToDateView(kpiObj.actualDataList, kpiObj.budgetDataList, period);
          
          KpiTableRow kpiViewRow = new KpiTableRow();
          kpiViewRow.kpiTableCellMap.put('YearToDateViewEmptyBefore', new KpiTableCell());
          kpiViewRow.kpiTableCellMap.put('YearToDateViewLastYearACT', new KpiTableCell(formatValue(dataYearToDateView.lastYearACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('YearToDateViewThisMonthBDT', new KpiTableCell(formatValue(dataYearToDateView.thisMonthBDT,kpiObj.format)));
          
          KpiTableCell cellYearToDateViewThisMonthACT = new KpiTableCell(formatValue(dataYearToDateView.thisMonthACT,kpiObj.format));
          cellYearToDateViewThisMonthACT.backgroundColor = '#99CCFF';
          kpiViewRow.kpiTableCellMap.put('YearToDateViewThisMonthACT', cellYearToDateViewThisMonthACT);
          
          kpiViewRow.kpiTableCellMap.put('YearToDateViewEmptyBetween', new KpiTableCell());
          kpiViewRow.kpiTableCellMap.put('YearToDateViewLastYearACTDeviation', new KpiTableCell(formatValue(dataYearToDateView.lastYearDeviationACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('YearToDateViewThisMonthBDTDeviation', new KpiTableCell(formatValue(dataYearToDateView.thisMonthDeviationBDT,kpiObj.format)));
          
          this.kpiViewRows.add(kpiViewRow);
        }
      }
    }
  }
  
  
  /**
   * Full Year View.
   */
  public class FullYearView extends View {
    
    /**
     * Constructor.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    public FullYearView(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.period = period;
      
      setColumnEmptyBefore();
      setColumnLastYearFYACT(period);
      setColumnThisYearFYBDT(period);
      setColumnEmptyBetween();
      setColumnLastYearFYACTDeviation(period);
      
      setKpiViewColumnMap();
      setKpiViewRows(kpiObjBlockMap, period);
    }
    
    /**
     * Creates a Empty Column.
     */
    private void setColumnEmptyBefore() {
      this.columnEmptyBefore = new KpiTableColumn('FullYearViewEmptyBefore');
      this.columnEmptyBefore.setHeaderTitle('');
    }
    
    /**
     * Creates the Last Year FY ACT Column.
     */
    private void setColumnLastYearFYACT(Date period) {
      this.columnLastYearFYACT = new KpiTableColumn('FullYearViewLastYearFYACT');
      this.columnLastYearFYACT.setHeaderTitle('Full Year View', 2, '#989898');
      this.columnLastYearFYACT.setHeaderDateStr(getColumnLastYearHeaderFYDateStr(period));
    }
    
    /**
     * Creates the This Year FY BDT Column.
     */
    private void setColumnThisYearFYBDT(Date period) {
      this.columnThisYearFYBDT = new KpiTableColumn('FullYearViewThisYearFYBDT');
      this.columnThisYearFYBDT.setHeaderDateStr(getColumnThisYearHeaderFYDateStr(period));
    }
    
    /**
     * Creates a Empty Column.
     */
    private void setColumnEmptyBetween() {
      this.columnEmptyBetween = new KpiTableColumn('FullYearViewEmptyBetween');
      this.columnEmptyBetween.setHeaderTitle('');
    }
    
    /**
     * Creates the Last Year FY ACT Deviation Column.
     */
    private void setColumnLastYearFYACTDeviation(Date period) {
      this.columnLastYearFYACTDeviation = new KpiTableColumn('FullYearViewLastYearFYACTDeviation');
      this.columnLastYearFYACTDeviation.setHeaderTitle('Deviation', 1, '#D8D8D8');
      this.columnLastYearFYACTDeviation.setHeaderDateStr(getColumnLastYearHeaderFYDateStr(period));
    }
    
    /**
     * Puts all Full Year View Columns in a map.
     */
    private void setKpiViewColumnMap() {
      this.kpiViewColumnMap = new Map<Integer, KpiTableColumn>();
      this.kpiViewColumnMap.put(1, this.columnEmptyBefore);
      this.kpiViewColumnMap.put(2, this.columnLastYearFYACT);
      this.kpiViewColumnMap.put(3, this.columnThisYearFYBDT);
      this.kpiViewColumnMap.put(4, this.columnEmptyBetween);
      this.kpiViewColumnMap.put(5, this.columnLastYearFYACTDeviation);
    }
    
    /**
     * Adds all Full Year View Rows to a list.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    private void setKpiViewRows(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.kpiViewRows = new List<KpiTableRow>();
      Boolean isFirstBlockInTable = true; // TODO: pageBreaks
      
      for (String blockName : kpiObjBlockMap.keySet()) {
        KpiTableRow kpiBlockHeaderViewRow = new KpiTableRow();
        
        if (!isFirstBlockInTable) {
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewEmptyBefore', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewLastYearFYACT', getBlockLineKpiTableCell(''));
          
          KpiTableCell cellFullYearViewThisYearFYBDT = getBlockLineKpiTableCell('');
          cellFullYearViewThisYearFYBDT.backgroundColor = '#D8D8D8';
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewThisYearFYBDT', cellFullYearViewThisYearFYBDT);
          
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewEmptyBetween', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewLastYearFYACTDeviation', getBlockLineKpiTableCell(''));
        } else {
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewEmptyBefore', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewLastYearFYACT', getBlockLineKpiTableCell('ACT'));
          
          KpiTableCell cellFullYearViewThisYearFYBDT = getBlockLineKpiTableCell('BDT');
          cellFullYearViewThisYearFYBDT.backgroundColor = '#D8D8D8';
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewThisYearFYBDT', cellFullYearViewThisYearFYBDT);
          
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewEmptyBetween', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('FullYearViewLastYearFYACTDeviation', getBlockLineKpiTableCell('ACT'));
          
          isFirstBlockInTable = false;
        }
        
        this.kpiViewRows.add(kpiBlockHeaderViewRow);
        
        for (KPIObj kpiObj : kpiObjBlockMap.get(blockName)) {
          DataFullYearView dataFullYearView = new DataFullYearView(kpiObj.actualDataList, kpiObj.budgetDataList, period);
          
          KpiTableRow kpiViewRow = new KpiTableRow();
          kpiViewRow.kpiTableCellMap.put('FullYearViewEmptyBefore', new KpiTableCell());
          kpiViewRow.kpiTableCellMap.put('FullYearViewLastYearFYACT', new KpiTableCell(formatValue(dataFullYearView.lastYearFYACT,kpiObj.format)));
          
          KpiTableCell cellFullYearViewThisYearFYBDT = new KpiTableCell(formatValue(dataFullYearView.thisYearFYBDT,kpiObj.format));
          cellFullYearViewThisYearFYBDT.backgroundColor = '#D8D8D8';
          kpiViewRow.kpiTableCellMap.put('FullYearViewThisYearFYBDT', cellFullYearViewThisYearFYBDT);
          
          kpiViewRow.kpiTableCellMap.put('FullYearViewEmptyBetween', new KpiTableCell());
          kpiViewRow.kpiTableCellMap.put('FullYearViewLastYearFYACTDeviation', new KpiTableCell(formatValue(dataFullYearView.lastYearFYDeviationACT,kpiObj.format)));
          
          this.kpiViewRows.add(kpiViewRow);
        }
      }
    }
  }
  
  
  /**
   * Last 6 Months View.
   */
  public class Last6MonthsView extends View {
    
    /**
     * Constructor.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    public Last6MonthsView(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.period = period;
      
      setColumnEmptyBefore();
      setColumnMonth6ACT(period);
      setColumnMonth5ACT(period);
      setColumnMonth4ACT(period);
      setColumnMonth3ACT(period);
      setColumnMonth2ACT(period);
      setColumnThisMonthACT(period);
      
      setKpiViewColumnMap();
      setKpiViewRows(kpiObjBlockMap, period);
    }
    
    /**
     * Creates a Empty Column.
     */
    private void setColumnEmptyBefore() {
      this.columnEmptyBefore = new KpiTableColumn('Last6MonthsViewEmptyBefore');
      this.columnEmptyBefore.setHeaderTitle('');
    }
    
    /**
     * Creates the Month 6 ACT Column.
     */
    private void setColumnMonth6ACT(Date period) {
      this.columnMonth6ACT = new KpiTableColumn('Last6MonthsViewMonth6ACT');
      this.columnMonth6ACT.setHeaderTitle('Last 6 months', 6, '#F57171');
      this.columnMonth6ACT.setHeaderDateStr(getColumnMonth6HeaderDateStr(period));
    }
    
    /**
     * Creates the Month 5 ACT Column.
     */
    private void setColumnMonth5ACT(Date period) {
      this.columnMonth5ACT = new KpiTableColumn('Last6MonthsViewMonth5ACT');
      this.columnMonth5ACT.setHeaderDateStr(getColumnMonth5HeaderDateStr(period));
    }
    
    /**
     * Creates the Month 4 ACT Column.
     */
    private void setColumnMonth4ACT(Date period) {
      this.columnMonth4ACT = new KpiTableColumn('Last6MonthsViewMonth4ACT');
      this.columnMonth4ACT.setHeaderDateStr(getColumnMonth4HeaderDateStr(period));
    }
    
    /**
     * Creates the Month 3 ACT Column.
     */
    private void setColumnMonth3ACT(Date period) {
      this.columnMonth3ACT = new KpiTableColumn('Last6MonthsViewMonth3ACT');
      this.columnMonth3ACT.setHeaderDateStr(getColumnMonth3HeaderDateStr(period));
    }
    
    /**
     * Creates the Month 2 ACT Column.
     */
    private void setColumnMonth2ACT(Date period) {
      this.columnMonth2ACT = new KpiTableColumn('Last6MonthsViewMonth2ACT');
      this.columnMonth2ACT.setHeaderDateStr(getColumnMonth2HeaderDateStr(period));
    }
    
    /**
     * Creates the This Month ACT Column.
     */
    private void setColumnThisMonthACT(Date period) {
      this.columnThisMonthACT = new KpiTableColumn('Last6MonthsViewThisMonthACT');
      this.columnThisMonthACT.setHeaderDateStr(getColumnThisMonthHeaderDateStr(period));
    }
    
    /**
     * Puts all Last 6 Months View Columns in a map.
     */
    private void setKpiViewColumnMap() {
      this.kpiViewColumnMap = new Map<Integer, KpiTableColumn>();
      this.kpiViewColumnMap.put(1, this.columnEmptyBefore);
      this.kpiViewColumnMap.put(2, this.columnMonth6ACT);
      this.kpiViewColumnMap.put(3, this.columnMonth5ACT);
      this.kpiViewColumnMap.put(4, this.columnMonth4ACT);
      this.kpiViewColumnMap.put(5, this.columnMonth3ACT);
      this.kpiViewColumnMap.put(6, this.columnMonth2ACT);
      this.kpiViewColumnMap.put(7, this.columnThisMonthACT);
    }
    
    /**
     * Adds all Last 6 Months View Rows to a list.
     *
     * @param kpiObjBlockMap
     *      KPI Objects grouped by KPI Block Name
     * @param period
     *      Period Date
     */
    private void setKpiViewRows(Map<String, List<KPIObj>> kpiObjBlockMap, Date period) {
      this.kpiViewRows = new List<KpiTableRow>();
      Boolean isFirstBlockInTable = true; // TODO: pageBreaks
      
      for (String blockName : kpiObjBlockMap.keySet()) {
        KpiTableRow kpiBlockHeaderViewRow = new KpiTableRow();
        
        if (!isFirstBlockInTable) {
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewEmptyBefore', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth6ACT', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth5ACT', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth4ACT', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth3ACT', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth2ACT', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewThisMonthACT', getBlockLineKpiTableCell(''));
        } else {
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewEmptyBefore', getBlockLineKpiTableCell(''));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth6ACT', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth5ACT', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth4ACT', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth3ACT', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewMonth2ACT', getBlockLineKpiTableCell('ACT'));
          kpiBlockHeaderViewRow.kpiTableCellMap.put('Last6MonthsViewThisMonthACT', getBlockLineKpiTableCell('ACT'));
          
          isFirstBlockInTable = false;
        }
        
        this.kpiViewRows.add(kpiBlockHeaderViewRow);
        
        for (KPIObj kpiObj : kpiObjBlockMap.get(blockName)) {
          DataLast6MonthsView dataLast6MonthsView = new DataLast6MonthsView(kpiObj.actualDataList, period);
          
          KpiTableRow kpiViewRow = new KpiTableRow();
          kpiViewRow.kpiTableCellMap.put('Last6MonthsViewEmptyBefore', new KpiTableCell());
          kpiViewRow.kpiTableCellMap.put('Last6MonthsViewMonth6ACT', new KpiTableCell(formatValue(dataLast6MonthsView.month6ACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('Last6MonthsViewMonth5ACT', new KpiTableCell(formatValue(dataLast6MonthsView.month5ACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('Last6MonthsViewMonth4ACT', new KpiTableCell(formatValue(dataLast6MonthsView.month4ACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('Last6MonthsViewMonth3ACT', new KpiTableCell(formatValue(dataLast6MonthsView.month3ACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('Last6MonthsViewMonth2ACT', new KpiTableCell(formatValue(dataLast6MonthsView.month2ACT,kpiObj.format)));
          kpiViewRow.kpiTableCellMap.put('Last6MonthsViewThisMonthACT', new KpiTableCell(formatValue(dataLast6MonthsView.thisMonthACT,kpiObj.format)));
          
          this.kpiViewRows.add(kpiViewRow);
        }
      }
    }
  }
  
  
  /* insert new view here */
  
  
  /* ************ KPIObj Class ************ */
  
  public class KPIObj {
    public String kpiName;
    public List<Ven_Financial_Model_Data__c> planDataList;
    public List<Ven_Financial_Model_Data__c> actualDataList;
    public List<Ven_Financial_Model_Data__c> budgetDataList;
    public String format;
    
    /**
     * Constructor.
     *
     * @param kpiName
     *      KPI Name
     */
    public KPIObj(String kpiName, String format) {
      this.kpiName = kpiName;
      this.format = format;
      this.planDataList = new List<Ven_Financial_Model_Data__c>();
      this.actualDataList = new List<Ven_Financial_Model_Data__c>();
      this.budgetDataList = new List<Ven_Financial_Model_Data__c>();
    }
  }
  
  
  /* ************ Data Classes ************ */
  
  /**
   * Data.
   */
  public virtual class Data {
    
    /**
     * Calculates the Deviation value.
     *
     * @param decimalValue1
     *      value to compare with
     * @param decimalValue2
     *      current value
     *
     * @return
     *    the Deviation value
     */
    public Integer calculateDeviation(Decimal decimalValue1, Decimal decimalValue2) {
      Integer integerValue;
      
      if (decimalValue1 != 0) {
        Boolean bothNegative = false;
        Boolean negativeAndPositive = false;
        
        if (decimalValue1 < 0 && decimalValue2 < 0) {
          bothNegative = true;
        } else if (decimalValue1 < 0 || decimalValue2 < 0) {
          negativeAndPositive = true;
        }
        
        if (decimalValue1 > decimalValue2) {
          integerValue = ((100 / decimalValue1) * decimalValue2).round(system.RoundingMode.HALF_UP).intValue();
          
          if (!bothNegative) {
            integerValue = 100 - integerValue;
          } else {
            integerValue = integerValue - 100;
          }
          
          if (!negativeAndPositive) {
            integerValue = integerValue - (integerValue * 2);
          }
        } else if (decimalValue1 < decimalValue2) {
          integerValue = ((100 / decimalValue2) * decimalValue1).round(system.RoundingMode.HALF_UP).intValue();
          
          if (!bothNegative) {
            integerValue = 100 - integerValue;
          } else {
            integerValue = integerValue - 100;
          }
        } else {
          integerValue = 0;
        }
      }
      
      return integerValue;
    }
  }
  
  
  /**
   * Data Monthly View
   */
  public class DataMonthlyView extends Data {
    public Decimal lastYearACT;
    public Decimal lastMonthACT;
    public Decimal thisMonthACT;
    public Integer lastYearDeviationACT;
    public Integer lastMonthDeviationACT;
    public Decimal thisMonthBDT;
    public Integer thisMonthDeviationBDT;
    
    private Integer periodMonth;
    private Integer periodYear;
    private Integer periodLastYear;
    private Integer periodLastMonth;
    private Integer periodLastMonthYear;
    
    /**
     * Constructor.
     *
     * @param actualDataList
     *      actual data to summarize
     * @param budgetDataList
     *      budget data to summarize
     * @param period
     *      Period Date
     */
    public DataMonthlyView(List<Ven_Financial_Model_Data__c> actualDataList, List<Ven_Financial_Model_Data__c> budgetDataList, Date period) {
      this.periodMonth = period.month();
      this.periodYear = period.year();
      this.periodLastYear = period.addYears(-1).year();
      this.periodLastMonth = period.addMonths(-1).month();
      this.periodLastMonthYear = period.addMonths(-1).year();
      
      calculateACT(actualDataList);
      calculateBDT(budgetDataList);
      calculateDeviation();
    }
    
    /**
     * Calculates actual data for the Monthly View.
     *
     * @param actualDataList
     *      actual data to summarize
     */
    private void calculateACT(List<Ven_Financial_Model_Data__c> actualDataList) {
      this.lastYearACT = 0;
      this.lastMonthACT = 0;
      this.thisMonthACT = 0;
      
      for (Ven_Financial_Model_Data__c actualData : actualDataList) {
        if (actualData.Ven_Value__c != null) {
          if (actualData.Month__c == this.periodMonth && actualData.Year__c == String.valueOf(this.periodLastYear)) {
            this.lastYearACT += actualData.Ven_Value__c;
          } else if (actualData.Month__c == this.periodLastMonth && actualData.Year__c == String.valueOf(this.periodLastMonthYear)) {
            this.lastMonthACT += actualData.Ven_Value__c;
          } else if (actualData.Month__c == this.periodMonth && actualData.Year__c == String.valueOf(this.periodYear)) {
            this.thisMonthACT += actualData.Ven_Value__c;
          }
        }
      }
    }
    
    /**
     * Calculates budget data for the Monthly View.
     *
     * @param budgetDataList
     *      budget data to summarize
     */
    private void calculateBDT(List<Ven_Financial_Model_Data__c> budgetDataList) {
      this.thisMonthBDT = 0;
      
      for (Ven_Financial_Model_Data__c budgetData : budgetDataList) {
        if (budgetData.Ven_Value__c != null) {
          if (budgetData.Month__c == this.periodMonth && budgetData.Year__c == String.valueOf(this.periodYear)) {
            this.thisMonthBDT += budgetData.Ven_Value__c;
          }
        }
      }
    }
    
    /**
     * Calculates the Deviation values for the Monthly View.
     */
    private void calculateDeviation() {
      if (this.thisMonthACT != 0) {
        this.lastYearDeviationACT = calculateDeviation(this.lastYearACT, this.thisMonthACT);
        this.lastMonthDeviationACT = calculateDeviation(this.lastMonthACT, this.thisMonthACT);
        this.thisMonthDeviationBDT = calculateDeviation(this.thisMonthBDT, this.thisMonthACT);
      }
    }
  }
  
  
  /**
   * Data Year-to-Date View
   */
  public class DataYearToDateView extends Data {
    public Decimal lastYearACT;
    public Decimal thisMonthACT;
    public Integer lastYearDeviationACT;
    public Decimal thisMonthBDT;
    public Integer thisMonthDeviationBDT;
    
    private Date periodStartLastYear;
    private Date periodEndLastYear;
    private Date periodStartThisYear;
    private Date periodEndThisYear;
    
    /**
     * Constructor.
     *
     * @param actualDataList
     *      actual data to summarize
     * @param budgetDataList
     *      budget data to summarize
     * @param period
     *      Period Date
     */
    public DataYearToDateView(List<Ven_Financial_Model_Data__c> actualDataList, List<Ven_Financial_Model_Data__c> budgetDataList, Date period) {
      this.periodStartLastYear = Date.newInstance(period.addYears(-1).year(), 1, 1);
      this.periodEndLastYear = Date.newInstance(period.addYears(-1).year(), period.addMonths(1).month(), 1);
      this.periodStartThisYear = Date.newInstance(period.year(), 1, 1);
      this.periodEndThisYear = Date.newInstance(period.year(), period.addMonths(1).month(), 1);
      
      calculateACT(actualDataList);
      calculateBDT(budgetDataList);
      calculateDeviation();
    }
    
    /**
     * Calculates actual data for the Year-to-Date View.
     *
     * @param actualDataList
     *      actual data to summarize
     */
    private void calculateACT(List<Ven_Financial_Model_Data__c> actualDataList) {
      this.lastYearACT = 0;
      this.thisMonthACT = 0;
      
      for (Ven_Financial_Model_Data__c actualData : actualDataList) {
        if (actualData.Ven_Value__c != null) {
          if (actualData.Ven_Datum__c >= this.periodStartLastYear && actualData.Ven_Datum__c < this.periodEndLastYear) {
            this.lastYearACT += actualData.Ven_Value__c;
          } else if (actualData.Ven_Datum__c >= this.periodStartThisYear && actualData.Ven_Datum__c < this.periodEndThisYear) {
            this.thisMonthACT += actualData.Ven_Value__c;
          }
        }
      }
    }
    
    /**
     * Calculates budget data for the Year-to-Date View.
     *
     * @param budgetDataList
     *      budget data to summarize
     */
    private void calculateBDT(List<Ven_Financial_Model_Data__c> budgetDataList) {
      this.thisMonthBDT = 0;
      
      for (Ven_Financial_Model_Data__c budgetData : budgetDataList) {
        if (budgetData.Ven_Value__c != null) {
          if (budgetData.Ven_Datum__c >= this.periodStartThisYear && budgetData.Ven_Datum__c < this.periodEndThisYear) {
            this.thisMonthBDT += budgetData.Ven_Value__c;
          }
        }
      }
    }
    
    /**
     * Calculates the Deviation values for the Year-to-Date View.
     */
    private void calculateDeviation() {
      if (this.thisMonthACT != 0) {
        this.lastYearDeviationACT = calculateDeviation(this.lastYearACT, this.thisMonthACT);
        this.thisMonthDeviationBDT = calculateDeviation(this.thisMonthBDT, this.thisMonthACT);
      }
    }
  }
  
  
  /**
   * Data Full Year View
   */
  public class DataFullYearView extends Data {
    public Decimal lastYearFYACT;
    public Integer lastYearFYDeviationACT;
    public Decimal thisYearFYBDT;
    
    private Integer periodYear;
    private Integer periodLastYear;
    
    /**
     * Constructor.
     *
     * @param actualDataList
     *      actual data to summarize
     * @param budgetDataList
     *      budget data to summarize
     * @param period
     *      Period Date
     */
    public DataFullYearView(List<Ven_Financial_Model_Data__c> actualDataList, List<Ven_Financial_Model_Data__c> budgetDataList, Date period) {
      this.periodYear = period.year();
      this.periodLastYear = period.addYears(-1).year();
      
      calculateACT(actualDataList);
      calculateBDT(budgetDataList);
      calculateDeviation();
    }
    
    /**
     * Calculates actual data for the Full Year View.
     *
     * @param actualDataList
     *      actual data to summarize
     */
    private void calculateACT(List<Ven_Financial_Model_Data__c> actualDataList) {
      this.lastYearFYACT = 0;
      
      for (Ven_Financial_Model_Data__c actualData : actualDataList) {
        if (actualData.Ven_Value__c != null) {
          if (actualData.Year__c == String.valueOf(this.periodLastYear)) {
            this.lastYearFYACT += actualData.Ven_Value__c;
          }
        }
      }
    }
    
    /**
     * Calculates budget data for the Full Year View.
     *
     * @param budgetDataList
     *      budget data to summarize
     */
    private void calculateBDT(List<Ven_Financial_Model_Data__c> budgetDataList) {
      this.thisYearFYBDT = 0;
      
      for (Ven_Financial_Model_Data__c budgetData : budgetDataList) {
        if (budgetData.Ven_Value__c != null) {
          if (budgetData.Year__c == String.valueOf(this.periodYear)) {
            this.thisYearFYBDT += budgetData.Ven_Value__c;
          }
        }
      }
    }
    
    /**
     * Calculates the Deviation values for the Full Year View.
     */
    private void calculateDeviation() {
      if (this.thisYearFYBDT != 0) {
        if (this.lastYearFYACT != 0) {
          this.lastYearFYDeviationACT = calculateDeviation(this.lastYearFYACT, this.thisYearFYBDT);
        }
      }
    }
  }
  
  /**
   * Data Last 6 Months View
   */
  public class DataLast6MonthsView {
    public Decimal month6ACT;
    public Decimal month5ACT;
    public Decimal month4ACT;
    public Decimal month3ACT;
    public Decimal month2ACT;
    public Decimal thisMonthACT;
    
    private Integer periodMonth6Month;
    private Integer periodMonth6Year;
    private Integer periodMonth5Month;
    private Integer periodMonth5Year;
    private Integer periodMonth4Month;
    private Integer periodMonth4Year;
    private Integer periodMonth3Month;
    private Integer periodMonth3Year;
    private Integer periodMonth2Month;
    private Integer periodMonth2Year;
    private Integer periodThisMonth;
    private Integer periodThisYear;
    
    /**
     * Constructor.
     *
     * @param actualDataList
     *      actual data to summarize
     * @param period
     *      Period Date
     */
    public DataLast6MonthsView(List<Ven_Financial_Model_Data__c> actualDataList, Date period) {
      this.periodMonth6Month = period.addMonths(-5).month();
      this.periodMonth6Year = period.addMonths(-5).year();
      this.periodMonth5Month = period.addMonths(-4).month();
      this.periodMonth5Year = period.addMonths(-4).year();
      this.periodMonth4Month = period.addMonths(-3).month();
      this.periodMonth4Year = period.addMonths(-3).year();
      this.periodMonth3Month = period.addMonths(-2).month();
      this.periodMonth3Year = period.addMonths(-2).year();
      this.periodMonth2Month = period.addMonths(-1).month();
      this.periodMonth2Year = period.addMonths(-1).year();
      this.periodThisMonth = period.month();
      this.periodThisYear = period.year();
      
      calculateACT(actualDataList);
    }
    
    /**
     * Calculates actual data for the Last 6 Months View.
     *
     * @param actualDataList
     *      actual data to summarize
     */
    private void calculateACT(List<Ven_Financial_Model_Data__c> actualDataList) {
      this.month6ACT = 0;
      this.month5ACT = 0;
      this.month4ACT = 0;
      this.month3ACT = 0;
      this.month2ACT = 0;
      this.thisMonthACT = 0;
      
      for (Ven_Financial_Model_Data__c actualData : actualDataList) {
        if (actualData.Ven_Value__c != null) {
          if (actualData.Month__c == this.periodMonth6Month && actualData.Year__c == String.valueOf(this.periodMonth6Year)) {
            this.month6ACT += actualData.Ven_Value__c;
          } else if (actualData.Month__c == this.periodMonth5Month && actualData.Year__c == String.valueOf(this.periodMonth5Year)) {
            this.month5ACT += actualData.Ven_Value__c;
          } else if (actualData.Month__c == this.periodMonth4Month && actualData.Year__c == String.valueOf(this.periodMonth4Year)) {
            this.month4ACT += actualData.Ven_Value__c;
          } else if (actualData.Month__c == this.periodMonth3Month && actualData.Year__c == String.valueOf(this.periodMonth3Year)) {
            this.month3ACT += actualData.Ven_Value__c;
          } else if (actualData.Month__c == this.periodMonth2Month && actualData.Year__c == String.valueOf(this.periodMonth2Year)) {
            this.month2ACT += actualData.Ven_Value__c;
          } else if (actualData.Month__c == this.periodThisMonth && actualData.Year__c == String.valueOf(this.periodThisYear)) {
            this.thisMonthACT += actualData.Ven_Value__c;
          }
        }
      }
    }
  }
  
  /* insert new view here */
  
  
  /* ******************************************************************************* */
  
  
  public Date heute {get;set;}
  public List<TaskLine> taskLines {get; private set;}
  
  private void setTaskLines(Id oppId) {
    this.heute = system.today();
    List<Task> tasks = getActionTrackingTask(oppId);
    this.taskLines = new List<TaskLine>();
    
    if (tasks != null && !tasks.isEmpty()) {
      for (Task t : tasks) {
        system.debug(t);
        TaskLine tl      = new TaskLine();
        tl.activities    = t.Description;
        if (t.ActivityDate != null) {
          tl.dueDate      = t.ActivityDate;
          tl.dueDateString  = t.ActivityDate.format();
          tl.effectiveDate  = t.ActivityDate.format();
        }
        tl.impact      = null;
        tl.lever      = t.Type;
        tl.rationale    = t.Subject;
        tl.status      = t.Status;
        tl.owner      = 'test';
        //tl.owner      = t.Who != null ? t.Who.FirstName + ' ' + t.Who.LastName : t.Owner.Name;
        tl.isClosed      = t.IsClosed;
        system.debug(tl);
        taskLines.add(tl);
      }
    }
  }
  
  public class TaskLine {
    public String lever {get; private set;}
    public String rationale {get; private set;}
    public String activities {get; private set;}
    public String impact {get; private set;}
    public String owner {get; private set;}
    public Date dueDate {get; private set;}
    public String dueDateString {get; private set;}
    public String effectiveDate {get; private set;}
    public String status {get; private set;}
    public Boolean isClosed {get; private set;}
  }
  
  
  private List<Task> getActionTrackingTask(Id oppId) {
    //Lever Rationale Activities Impact (quant.) Owner Due Date Effective Date Status
    return [SELECT Id ,Status, ActivityDate, Who.FirstName, Who.LastName, Owner.Name, Subject, Description, Type, IsClosed
        FROM Task WHERE WhatId =:oppId
        order BY ActivityDate asc];
  }
}