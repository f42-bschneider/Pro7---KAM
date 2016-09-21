global class Adv_OptimizingVersion_Attachment{

    webService static String attachPDFToOV(String sOVID, String sMKID, String version)
    {
        String sRet = '';
        try{
            PageReference pageRef = new PageReference('/apex/ADvendio__PDF?mcid=' + sMKID + '&versionid=' + sOVID);    
            Attachment obj = new Attachment();
            obj.Body = Test.isRunningTest() ? Blob.valueOf('TestContent') : pageRef.getContent();
            obj.Name = version + '.pdf';
            obj.ParentId = sMKID;
            obj.ContentType = 'application/pdf';
            insert obj;
            sRet = 'SUCCESS';
            
            return sRet;
        }catch(Exception ex){
            
            System.debug('####Error: ' + ex);
            sRet = ex.getMessage();
            return sRet;            
        }
    }
}