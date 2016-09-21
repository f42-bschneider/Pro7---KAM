global class SomTv_DwhPortfoliocheck implements Messaging.InboundEmailHandler{

   global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        // Start the Log process
       
        try {
            Lcm_Log__c log = new Lcm_Log__c();
            log.Lcm_Info_1__c = 'Sender: '+envelope.fromAddress;
            log.Lcm_Info_2__c = 'Subject: '+email.subject.left(240);
            log.Lcm_Info_3__c = 'Body: '+email.plainTextBody.left(240);
            log.lcm_source__c = 'SomTv_Portfoliocheck';
            log.Lcm_Info_4__c = 'Attachments:';
            
            if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) 
                    log.Lcm_Info_4__c += '\n' + email.binaryAttachments[i].filename + ' (' + email.binaryAttachments[i].body.size()/1024 + ' KB) ';
            
            }
            insert log;
            
        } catch(Exception e) {
            system.debug('** error in SomTv_DwhPortfoliocheck: ' + e.getMessage());
        }
        
        // Start the Document replacement process
        ID folderID = System.Label.SomTv_PortfoliocheckFolderId;

        if (email.binaryAttachments != null){
            List<Document> listDocuments = new List<Document>();

            // Get Existing Document
            List<Document> listDoc = new List<Document>([SELECT ID FROM Document WHERE FolderID = :folderID]);
            Document objExistingDoc;

            if(!listDoc.isEmpty())
                objExistingDoc = listDoc[0];

            for(Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {

                if(bAttachment.fileName.endsWith('.xls') || bAttachment.fileName.endsWith('.xlsx')){

                    // Update Existing Doc
                    if(objExistingDoc != null){
                        objExistingDoc.Body = bAttachment.body;
                        update objExistingDoc;
                    }else{
                    // Insert a new one for the first time
                        Document objDoc = new Document();
                        objDoc.Name = 'Portfoliocheck.xlsx';
                        objDoc.Body = bAttachment.body;
                        objDoc.FolderID = folderID;
                        listDocuments.add(objDoc);
                    }
                }
            }
            insert listDocuments;
       }

       return result;
   }
}