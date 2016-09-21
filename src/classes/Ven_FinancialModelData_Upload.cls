/**
* Choose a XML file, have it read by an external webservice which returns a JSON structure to be parsed.
* Create Ven_Financial_Model_Data__c records for an Opportunity connect to Ven_Key_Performance_Indicator__c
* @author stefan.voss@advendio.com
**/
public with sharing class Ven_FinancialModelData_Upload {

    /** WebService URL and Name **/
    private static final String SERVICE_URL  = 'https://exchange.advendio.com:8080/VenturesFinancialModelUploadService';
    private static final String SERVICE_NAME = '/VenturesFinancialModelUploadService';

    /** Ven_Financial_Model_Version__c RecordType DeveloperNames **/
    private static final String RT_FMV_PLAN   = 'Ven_Plan_Data';
    private static final String RT_FMV_ACTUAL = 'Ven_Actual_Data';
    private static final String RT_FMV_BUDGET = 'Ven_Budget_Data';
    
    /** Ven_Financial_Model_Version__c RecordTypes by DeveloperName **/
    private Map<String, RecordType> recordTypesByName;

    /** Wizard Steps **/
    public Boolean isStep1 {get;set;}
    public Boolean isStep2 {get;set;}
    public Boolean isStep3 {get;set;}

    /** enable Testing mode (Webservice is not called - hardcoded JSON String is used) **/
    private Boolean isTest = false;

    /** File content (set by VF Page) + String correspondent **/
    public Blob fileContent {get;set;}
    private String fileContentString {get;set;}
    public  String responseString {get;set;}

    /** FinacialModuleVersionWrapper objects**/
    public FinacialModuleVersionWrapper plan {get;set;}
    public FinacialModuleVersionWrapper actual {get;set;}
    public FinacialModuleVersionWrapper budget {get;set;}

    public Set<String> unMatchedKPIs {get;set;}
    public Boolean unMatchedKPIsIsEmpty {get;set;}

    /** Opportunity-Record Id - any data will be saved for this Opportunity **/
    private Id opportunityId;

    /** Opportunity-Record **/
    public Opportunity opp {get;set;}

    /** KPI (Ven_Key_Performance_Indicator__c) Id by Name **/
    private Map<String, Id> kpiByName  = null;

    /** Controller for VF Page **/
    public Ven_FinancialModelData_Upload(ApexPages.Standardcontroller controller) {
        opportunityId  = controller.getId();
        isTest      = stringToBoolean(ApexPages.currentPage().getParameters().get('isTest'));

        recordTypesByName  = getFMVersionRecordTypes();
        unMatchedKPIs    = new Set<String>();
        unMatchedKPIsIsEmpty= true;
        plan        = new FinacialModuleVersionWrapper(RT_FMV_PLAN);
        actual        = new FinacialModuleVersionWrapper(RT_FMV_ACTUAL);
        budget        = new FinacialModuleVersionWrapper(RT_FMV_BUDGET);
        gotoStep1();
        prepareFMVersions();
        opp        = getOpportunity();
    }

    private Boolean stringToBoolean(String value) {
        return value == null || value == '' || value == 'false' ? false : true;
    }

    public void gotoStep1() {
        isStep1      = true;
        isStep2      = false;
        isStep3      = false;
    }

    public void gotoStep2() {
        isStep1      = false;
        isStep2      = true;
        isStep3      = false;
    }

    public void gotoStep3() {
        isStep1      = false;
        isStep2      = false;
        isStep3      = true;
    }

    /** Go back calling Opportunity (used in VF Page)
    * @return PageReference
    **/
    public PageReference backToOpp() {
        return new PageReference('/' + opportunityId);
    }

    /** starts the process (used in VF Page) **/
    public void upload() {

        if (fileContent == null) {
            setError('Please choose a file');
            return;
        }
        fileContentString  = EncodingUtil.base64Encode(fileContent);
        fileContent  = null;
        gotoStep2();
        doRequest();
    }

    /**
    * add a message to queue used by VF Page
    * @param Severity to be used
    * @param Message as String
    **/
    private void setMessage(ApexPages.Severity severity, String msg) {
        ApexPages.addMessage(new ApexPages.Message(severity, msg));
    }

    /**
    * add an ERROR message
    * @param Message as String
    **/
    private void setError(String msg) {
        setMessage(ApexPages.severity.ERROR, msg);
    }

    /**
    * add an INFO message
    * @param Message as String
    **/
    private void setInfo(String msg) {
        setMessage(ApexPages.severity.INFO, msg);
    }

    /**
    * create potential new FinacialModuleVersionWrapper objects (plan, actual, budget)
    **/
    private void prepareFMVersions() {

        for (Ven_Financial_Model_Version__c fmv : getFMVersions()) {
            system.debug(fmv);
            if (fmv.RecordType.DeveloperName.equals(RT_FMV_PLAN)) {
                if (plan.version == null) {
                    plan.version    = fmv.Ven_version_number__c;
                    plan.isProtected  = fmv.ven_write_protection__c;
                    plan.newVersion    = updateFMVersion(plan.version, plan.isProtected);
                    plan.existsSF    = true;
                    plan.fmVersion    = createFMVersion(plan);
                }
            }
            if (fmv.RecordType.DeveloperName.equals(RT_FMV_BUDGET)) {
                if (budget.version == null) {
                    budget.version    = fmv.Ven_version_number__c;
                    budget.isProtected  = fmv.ven_write_protection__c;
                    budget.newVersion  = updateFMVersion(budget.version, budget.isProtected);
                    budget.existsSF    = true;
                    budget.fmVersion  = createFMVersion(budget);
                }
            }
            if (fmv.RecordType.DeveloperName.equals(RT_FMV_ACTUAL)) {
                if (actual.version == null) {
                    actual.version    = fmv.Ven_version_number__c;
                    actual.isProtected  = fmv.ven_write_protection__c;
                    actual.newVersion  = updateFMVersion(actual.version, actual.isProtected);
                    actual.existsSF    = true;
                    actual.fmVersion  = createFMVersion(actual);
                }
            }
        }

        if (plan.version == null) {
            plan.fmVersion  = createFMVersion(plan);
        }
        if (actual.version == null) {
            actual.fmVersion  = createFMVersion(actual);
        }
        if (budget.version == null) {
            budget.fmVersion  = createFMVersion(budget);
        }
    }

    /**
    * construct a new Ven_Financial_Model_Version__c record
    * @param FinacialModuleVersionWrapper holding needed data
    * @return a new Ven_Financial_Model_Version__c
    **/
    private Ven_Financial_Model_Version__c createFMVersion(FinacialModuleVersionWrapper fmVersionWrapper) {
        Ven_Financial_Model_Version__c fmVersion  = new Ven_Financial_Model_Version__c();
        fmVersion.Ven_Opportunity__c  = opportunityId;
        fmVersion.Ven_version_number__c  = fmVersionWrapper.newVersion;
        fmVersion.RecordTypeId  = recordTypesByName.get(fmVersionWrapper.typ).Id;
        system.debug(fmVersion);
        return fmVersion;
    }

    /**
    * calculate next version number
    * @param recent version-number
    * @param isProtected identifier
    * @return double version-number
    **/
    private Double updateFMVersion(Decimal version, Boolean isProtected) {
        Double newVersion    = 0;
        if (version == null) {
            newVersion  = 0.1;
        }
        else {
            String versionString  = version.toPlainString();
            system.debug(versionString);
            if (!isProtected) {
                String versionStringPart1  = versionString.substring(0, versionString.lastIndexOf('.')+1);
                String versionStringPart2  = versionString.substring(versionString.lastIndexOf('.')+1, versionString.length());

                newVersion          = Double.valueOf((versionStringPart1 + String.valueOf(Integer.valueOf(versionStringPart2) + 1)));
            }
            else {
                String versionStringPart1  = versionString.substring(0, versionString.lastIndexOf('.'));
                newVersion          = Double.valueOf(versionStringPart1)+1;
            }
        }

        return newVersion;
    }

    /**
    * get Opportunity data
    * @return Opportunity object
    **/
    private Opportunity getOpportunity() {
        try {
            return [select Id, Name from Opportunity where Id = :opportunityId];
        }
        catch (Exception e) {
            setError('Opportunity ungültig: ' + e.getMessage());
            return null;
        }
    }

    /**
    * get any Ven_Financial_Model_Version__c to the Opportunity
    * @return List of Ven_Financial_Model_Version__c
    **/
    private List<Ven_Financial_Model_Version__c> getFMVersions() {
        try {
            return [select Id, Ven_write_protection__c, Ven_version_number__c, RecordType.DeveloperName from Ven_Financial_Model_Version__c where Ven_Opportunity__c = :opportunityId order By RecordType.DeveloperName, Ven_version_number__c desc];
        }
        catch (Exception e) {
            return new List<Ven_Financial_Model_Version__c>();
        }
    }

    /**
    * get any Ven_Financial_Model_Version__c RecordTypes
    * @return Map of RecordTypes
    **/
    private Map<String, RecordType> getFMVersionRecordTypes() {
        recordTypesByName  = new Map<String, RecordType>();
        for (RecordType rt : [select Id, DeveloperName from RecordType where SObjectType = 'Ven_Financial_Model_Version__c']) {
            recordTypesByName.put(rt.DeveloperName, rt);
        }
        return recordTypesByName;
    }

    /**
    * get a KPI by it's name
    * @param KPI-Name
    * @return KPI Id
    **/
    private Id getKPIByName(String kpiName) {
        if (kpiByName == null) {
            kpiByName  = new Map<String, Id>();
            for (Ven_Key_Performance_Indicator__c kpi : [select Id, Name from Ven_Key_Performance_Indicator__c]) {
                kpiByName.put(kpi.Name, kpi.Id);
            }
        }
        if (kpiByName.containsKey(kpiName)) {
            return kpiByName.get(kpiName);
        }
        return null;
    }

    /**
    * convert a string (yyyy-mm-dd) into a date
    * @param date-string
    * @return converted date
    **/
    private Date stringToDate(String dateString) {
        Date d  = null;

        if (dateString != null) {
            List<String> dateParts  = dateString.split('-');
            if (dateParts.size() == 3) {
                d  = Date.newInstance(Integer.valueOf(dateParts.get(0)), Integer.valueOf(dateParts.get(1)), Integer.valueOf(dateParts.get(2)));
            }
        }

        return d;
    }

    /**
    * construct Ven_Financial_Model_Data__c records and set it's values using data stored as FinacialModuleSST
    * store data in FinancialModelVersionWrapper objects
    * @param a FinacialModuleSST object
    **/
    private void setFinancialModelValues(FinacialModuleSST fmSST) {

        // create "Plan" Ven_Financial_Model_Data__c records
        if (fmSST.plan != null) {
            for (FinacialModuleWrapper fmWrapper : fmSST.plan) {
                plan.existsXLS          = true;
                Ven_Financial_Model_Data__c fm  = new Ven_Financial_Model_Data__c();
                fm.Key_Performance_Indicator__c  = getKPIByName(fmWrapper.Name);
                fm.Ven_Datum__c          = stringToDate(fmWrapper.datum);
                fm.Name              = fmWrapper.Name + ' - ' + fmWrapper.datum;
                fm.Ven_Value__c          = fmWrapper.value;
                fm.Financial_Model_Version__r  = plan.fmVersion;
                system.debug(fm);
                if (fm.Key_Performance_Indicator__c != null) {
                    plan.financialModels.add(fm);
                }
                else {
                    unMatchedKPIs.add(fmWrapper.Name);
                    unMatchedKPIsIsEmpty  = false;
                }
            }
        }

        // create "Actual" Ven_Financial_Model_Data__c records
        if (fmSST.actual != null) {
            for (FinacialModuleWrapper fmWrapper : fmSST.actual) {
                actual.existsXLS        = true;
                Ven_Financial_Model_Data__c fm  = new Ven_Financial_Model_Data__c();
                fm.Key_Performance_Indicator__c  = getKPIByName(fmWrapper.Name);
                fm.Ven_Datum__c          = stringToDate(fmWrapper.datum);
                fm.Name              = fmWrapper.Name + ' - ' + fmWrapper.datum;
                fm.Ven_Value__c          = fmWrapper.value;
                fm.Financial_Model_Version__r  = actual.fmVersion;
                system.debug(fm);
                if (fm.Key_Performance_Indicator__c != null) {
                    actual.financialModels.add(fm);
                }
                else {
                    system.debug(fmWrapper.Name);
                    unMatchedKPIs.add(fmWrapper.Name);
                    unMatchedKPIsIsEmpty  = false;
                }
            }
        }

        // create "Budget" Ven_Financial_Model_Data__c records
        if (fmSST.budget != null) {
            for (FinacialModuleWrapper fmWrapper : fmSST.budget) {
                budget.existsXLS        = true;
                Ven_Financial_Model_Data__c fm  = new Ven_Financial_Model_Data__c();
                fm.Key_Performance_Indicator__c  = getKPIByName(fmWrapper.Name);
                fm.Ven_Datum__c          = stringToDate(fmWrapper.datum);
                fm.Name              = fmWrapper.Name + ' - ' + fmWrapper.datum;
                fm.Ven_Value__c          = fmWrapper.value;
                fm.Financial_Model_Version__r  = budget.fmVersion;
                system.debug(fm);
                if (fm.Key_Performance_Indicator__c != null) {
                    budget.financialModels.add(fm);
                }
                else {
                    unMatchedKPIs.add(fmWrapper.Name);
                    unMatchedKPIsIsEmpty  = false;
                }
            }
        }
    }

    private String betterErrorMessage(String errorMsg) {
        if (errorMsg == 'Exception: Unable to recognize OLE stream') {
            return 'Chosen file is not a valid XLS file.';
        }
        else {
            return errorMsg;
        }
    }

    /**
    * create Ven_Financial_Model_Version__c and Ven_Financial_Model_Data__c in SF
    * VF action
    **/
    public void updateSF() {
        List<Ven_Financial_Model_Version__c> fmVersions  = new List<Ven_Financial_Model_Version__c>();
        List<Ven_Financial_Model_Data__c> fmDatas    = new List<Ven_Financial_Model_Data__c>();

        if (plan.doUpdate) {
            fmVersions.add(plan.fmVersion);
            fmDatas.addAll(plan.financialModels);
        }
        if (actual.doUpdate) {
            fmVersions.add(actual.fmVersion);
            fmDatas.addAll(actual.financialModels);
        }
        if (budget.doUpdate) {
            fmVersions.add(budget.fmVersion);
            fmDatas.addAll(budget.financialModels);
        }

        if (!fmVersions.isEmpty()) {
            upsert fmVersions;
        }

        for (Ven_Financial_Model_Data__c fmData : plan.financialModels) {
            fmData.Financial_Model_Version__c  = plan.fmVersion.Id;
        }
        for (Ven_Financial_Model_Data__c fmData : actual.financialModels) {
            fmData.Financial_Model_Version__c  = actual.fmVersion.Id;
        }
        for (Ven_Financial_Model_Data__c fmData : budget.financialModels) {
            fmData.Financial_Model_Version__c  = budget.fmVersion.Id;
        }

        if (!fmDatas.isEmpty()) {
            upsert fmDatas;
        }

        gotoStep3();
    }

    /**
    * parse webservice response and process this data
    * @param a HttpResponse object
    **/
    public void getResponse(HttpResponse res) {
        try {
            JSONParser parser = JSON.createParser(res.getBody());

            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.START_OBJECT)) {

                    FinacialModuleSST fmSST = (FinacialModuleSST)parser.readValueAs(FinacialModuleSST.class);
                    system.debug(fmSST);
                    if (fmSST.error  != null) {
                        setError(betterErrorMessage(fmSST.error));
                    }
                    else {
                        if (fmSST.info  != null) {
                            for (String info : fmSST.info) {
                                setInfo(info);
                            }
                        }

                        setFinancialModelValues(fmSST);
                    }
                    parser.skipChildren();
                }
            }
        }
        catch (Exception e) {
            system.debug(e);
            setError(res.getBody());
            setError(e.getMessage());
            setError(e.getStackTraceString());
        }
    }

    /**
    * call webservice request preparation and sending and response- handling afterwards
    **/
    public void doRequest() {
        HttpRequest req    = null;
        HttpResponse res  = null;

        req  = createRequest();
        res  = sendRequest(req);
        getResponse(res);
    }


    /**
    * call webservice request preparation and sending and response- handling afterwards
    * @param a HttpResponse object
    **/
    private HttpRequest createRequest() {
        HttpRequest req  = new HttpRequest();

        req.setEndpoint(SERVICE_URL + SERVICE_NAME);
        req.setMethod('POST');
        req.setBody('id=' + EncodingUtil.urlEncode(opportunityId, 'UTF-8') + '&filecontent=' + Encodingutil.urlEncode(fileContentString, 'UTF-8'));
        req.setTimeout(120000);

        fileContent      = null;
        fileContentString  = null;

        return req;
    }

    private HttpResponse sendRequest(HttpRequest req) {
        HttpResponse res  = new HttpResponse();
        Http http  = new Http();
        if (!isTest && !Test.isRunningTest()) {
            try {
                res = http.send(req);
            } catch(System.CalloutException e) {
                setError(e.getMessage());
            } catch(Exception e) {
                setError(e.getMessage());
            }
        } else {

            res.setBody('{"plan":[{"value":"12","name":"Test KPI","datum":"2013-11-01","key":"Financing cash flow2013-11-01"},{"value":"25","name":"Financing cash flow","datum":"2013-12-01","key":"Financing cash flow2013-12-01"}],"actual":[{"value":"123","name":"Financing cash flow","datum":"2013-11-01","key":"Financing cash flow2013-11-01"}],"budget":[{"value":"12","name":"Test KPI","datum":"2013-11-01","key":"Financing cash flow2013-11-01"}],"info":["No planned-sheet found"]}');
        }
        return res;
    }

    /**
    * inner class to store data (temporary)
    **/
    public class FinacialModuleVersionWrapper {
        /* existing version */
        public Double version {get;set;}
        /* new version */
        public Double newVersion {get;set;}
        /* determines if this version will be imported to SF */
        public Boolean doUpdate {get;set;}
        /* determines if this version is proteced in SF */
        public Boolean isProtected {get;set;}
        /* Version exists in SF */
        public Boolean existsSF {get;set;}
        /* Version exists Excel-File */
        public Boolean existsXLS {get;set;}

        public Ven_Financial_Model_Version__c fmVersion {get;set;}
        public List<Ven_Financial_Model_Data__c> financialModels {get;set;}
        public String typ {get;set;}

        public FinacialModuleVersionWrapper(String typ) {
            this.newVersion      = 0.1;
            this.existsSF      = false;
            this.existsXLS      = false;
            this.doUpdate      = false;
            this.version      = null;
            this.financialModels  = new List<Ven_Financial_Model_Data__c>();
            this.typ        = typ;
        }
    }

    /**
    * inner class to store data (temporary)
    **/
    public class FinacialModuleWrapper {
        String name {get;set;}
        Double value {get;set;}
        String datum {get;set;}
    }


    /**
    * inner class to store JSONObject data
    **/
    public class FinacialModuleSST {
        List<FinacialModuleWrapper> plan {get;set;}
        List<FinacialModuleWrapper> actual {get;set;}
        List<FinacialModuleWrapper> budget {get;set;}
        String error {get;set;}
        List<String> info {get;set;}

        public FinacialModuleSST() {
            plan  = new List<FinacialModuleWrapper>();
            actual  = new List<FinacialModuleWrapper>();
            budget  = new List<FinacialModuleWrapper>();
        }
    }
}