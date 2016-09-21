@isTest
public class SomTv_DwhPortfoliocheck_Test{

    public static testMethod void testSomTv_DwhPortfoliocheck_Test(){
      
      // Send 2 Mails. One in case its the first Email and one for the other Cases.
      
      // Send first Email 
      // create a new email and envelope object
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
       // setup the data for the email
      email.subject = 'Create Contact';
      email.fromAddress = 'someaddress@email.com';
      email.plainTextBody = 'email body';
       
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'file.xls';
      attachment.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };


      // call the email service class and test it with the data in the testMethod
      SomTv_DwhPortfoliocheck testInbound = new SomTv_DwhPortfoliocheck();
      testInbound.handleInboundEmail(email, env);    
      
      
      
      
      // Send email twice    
      testInbound.handleInboundEmail(email, env);      
      
    }
}