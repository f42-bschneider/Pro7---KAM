/*
    Used to link Formate object's record with AdServerId object's records.
*/
public class cls_P7S1_Format_AdServerLinking{
    List<ADvendio__AdServer_ID__c> i_oListAdServer;
    String i_sFormatId;
    public String i_sSearchText {get;set;}
    public List<cls_ModelClass> i_clsModelList{get;set;}
    Set<Id> i_sAdServerIds;
    public P7S1_Format__c i_oFormatObj{get;set;}

    //Constructor
    public cls_P7S1_Format_AdServerLinking() {
        i_clsModelList = new List<cls_ModelClass>();
        i_sAdServerIds = new Set<Id>();
        i_oListAdServer = new List<ADvendio__AdServer_ID__c>();

        //Getting formate object's record Id
        i_sFormatId = ApexPages.CurrentPage().getParameters().get('formatId');

        if(i_sFormatId != null)
            i_oFormatObj = [SELECT Id, Name FROM P7S1_Format__c WHERE Id=:i_sFormatId];

        if(i_sFormatId != null){
            i_oListAdServer = [SELECT Name,ADvendio__AdServer_Login__c,ADvendio__AdServer_Name__c,P7S1_Format__c ,
                          ADvendio__AdServer_ID__c,ADvendio__UniqueKey__c,SomDig_MediagattungsSegment__c,
                          ADvendio__Parent_AdServer_ID__c,ADvendio__Site__c
                          FROM ADvendio__AdServer_ID__c Where P7S1_Format__c =: i_sFormatId];
        }

        //Creating assigned records list
        if(i_oListAdServer.size() > 0){
            for(ADvendio__AdServer_ID__c I_AdObj : i_oListAdServer){
                cls_ModelClass I_cls_Model = new cls_ModelClass();
                I_cls_Model.i_Check = true;
                I_cls_Model.i_oAdObj = I_AdObj;
                i_clsModelList.add(I_cls_Model);
                i_sAdServerIds.add(I_AdObj.id);
            }
        }

        //Show message when recods are aleardy assigned to formate object
        if(i_clsModelList.size() > 0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Following records are already assigned to format object.If you want to assign more records than use search to get records.'));
    }

    //To search AdServerIds's records
    public void Search() {
        List<cls_ModelClass> I_clsTempModelList = new List<cls_ModelClass>();
        for(cls_ModelClass I_obj : i_clsModelList){
            if(I_obj.i_Check)
                I_clsTempModelList.add(I_obj);
        }
        i_clsModelList = new List<cls_ModelClass>();
        i_clsModelList = I_clsTempModelList;

        //Search Text
        String I_sTempSearchText = '';
        if(i_sSearchText != null && i_sSearchText.trim().length() > 0){
            if(i_sSearchText.contains('*')){
                I_sTempSearchText = i_sSearchText;
                I_sTempSearchText = I_sTempSearchText.remove('*');
                I_sTempSearchText = 'like \'%'+ I_sTempSearchText + '%\' ';
            }else{
                I_sTempSearchText = i_sSearchText;
                I_sTempSearchText = 'like \''+I_sTempSearchText+'\' ';
            }
        }

        i_oListAdServer = new List<ADvendio__AdServer_ID__c>();
        String I_sType = 'Ad Unit';
        String I_sRType = 'DFP';

        String I_sQuery = 'SELECT Name,ADvendio__AdServer_Login__c,ADvendio__AdServer_Name__c,P7S1_Format__c ,'+
                         'ADvendio__AdServer_ID__c,ADvendio__UniqueKey__c,SomDig_MediagattungsSegment__c, '+
                         'ADvendio__Parent_AdServer_ID__c,ADvendio__Site__c '+
                         'FROM ADvendio__AdServer_ID__c '+
                         'Where RecordType.Name =: I_sRType '+
                         'AND ADvendio__Type__c =: I_sType '+
                         'AND (Name ' + I_sTempSearchText +
                         'OR ADvendio__AdServer_Name__c '+ I_sTempSearchText +
                         'OR ADvendio__AdServer_Login__r.Name '+ I_sTempSearchText +')';

        i_oListAdServer = Database.Query(I_sQuery);

        if(i_oListAdServer.size() > 0){
            if(i_oListAdServer.size() >= 1000){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'More than 1000 records found.Please narrow your search criteria.'));

                I_sQuery = 'SELECT Name,ADvendio__AdServer_Login__c,ADvendio__AdServer_Name__c,P7S1_Format__c ,'+
                         'ADvendio__AdServer_ID__c,ADvendio__UniqueKey__c,SomDig_MediagattungsSegment__c, '+
                         'ADvendio__Parent_AdServer_ID__c,ADvendio__Site__c '+
                         'FROM ADvendio__AdServer_ID__c '+
                         'Where RecordType.Name =: I_sRType '+
                         'AND ADvendio__Type__c =: I_sType '+
                         'AND (Name ' + I_sTempSearchText +
                         'OR ADvendio__AdServer_Name__c '+ I_sTempSearchText +
                         'OR ADvendio__AdServer_Login__r.Name '+ I_sTempSearchText +') LIMIT 1000';

                i_oListAdServer = Database.Query(I_sQuery);

                for(ADvendio__AdServer_ID__c I_AdObj : i_oListAdServer){
                    cls_ModelClass I_cls_Model = new cls_ModelClass();
                    I_cls_Model.i_Check = false;
                    I_cls_Model.i_oAdObj = I_AdObj;
                    if(i_sAdServerIds.contains(I_AdObj.Id))
                        continue;
                    if(i_clsModelList.size() < 1000)
                        i_clsModelList.add(I_cls_Model);
                }
            }else{
                for(ADvendio__AdServer_ID__c I_AdObj : i_oListAdServer){
                    cls_ModelClass I_cls_Model = new cls_ModelClass();
                    I_cls_Model.i_Check = false;
                    I_cls_Model.i_oAdObj = I_AdObj;
                    if(i_sAdServerIds.contains(I_AdObj.Id))
                        continue;
                    if(i_clsModelList.size() < 1000)
                        i_clsModelList.add(I_cls_Model);

                }
            }
        }
    }

    /*
        To link Formate records with AdServerId.
        Assign new AdServerId to Formate Object.
        Returning to formate record's detail page.
        @return pg
    */
    public PageReference save() {
        List<ADvendio__AdServer_ID__c> I_oTempListAdServer = new List<ADvendio__AdServer_ID__c>();
        for(cls_ModelClass I_obj : i_clsModelList){
            if(I_obj.i_Check){
                I_obj.i_oAdObj.P7S1_Format__c = i_sFormatId;
            }else{
                if(i_sAdServerIds.contains(I_obj.i_oAdObj.Id)){
                    I_obj.i_oAdObj.P7S1_Format__c = null;
                }
            }
            I_oTempListAdServer.add(I_obj.i_oAdObj);
        }

        //Updateing AdServerId's Records
        update I_oTempListAdServer;
        PageReference pg = new PageReference('/'+i_sFormatId);
        pg.setRedirect(true);
        return pg;
    }

    //To cancel submission of records
    public PageReference Cancel(){
        PageReference pg = new PageReference('/'+i_sFormatId);
        pg.setRedirect(true);
        return pg;
    }

    //Wrapper class
    public class cls_ModelClass{
        public Boolean i_Check{get;set;}
        public ADvendio__AdServer_ID__c i_oAdObj{get;set;}
    }
}