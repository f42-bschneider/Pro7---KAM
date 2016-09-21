/**
* This function should return the email address for a given ProRex-Person-ID.
*
*/


@RestResource(urlMapping='/GetEMailByPersonID/*')
global with sharing class GetEMailByPersonID {

@HttpGet
    global static void doGet() {
    
    	
    
	    	RestRequest req = RestContext.request;
	        RestResponse res = RestContext.response;
	        res.addHeader('Content-Type', 'application/json');
	        
	        // read param in 
	        String pProRexId = RestContext.request.params.get('ProRexId__c');
	     
	        System.debug('>>>> GetEMailByPersonID param in ' + pProRexId);
	     
				
			
			// response
			ResponseWrapper response = new ResponseWrapper();
			response.request.put('ProRexId__c',pProRexId);
			
			// pre condition
			// param in must not be null
			
			if (String.isEmpty(pProRexId)) {
				response.status.put('success','false');
				response.status.put('error','param ProRexId__c is missing');	
				
				res.statusCode = 400;
	            res.responseBody = blob.valueOf(JSON.serialize(response));
	            
	            return;
	           		
			}
			
			
		try {		
			
	         
				// all pre condition ok
	       	 	List<Contact> contacts = [SELECT ProRexId__c, Email FROM Contact WHERE ProRexId__c =: pProRexId];
				
				response.results = new Map<String,Object>();
				response.results.put('Contact',null);
				
				if (!contacts.isEmpty()) {
					
					Map<String,Object> rec = new Map<String,Object>();
					
		        	for (Contact con : contacts) {
		        		rec.put('ProRexId__c',con.ProRexId__c);
		        		rec.put('Email',con.Email);
		        		
		        	}
		        	
		        	response.results.put('Contact',rec);
				}
	        	

	            res.statusCode = 200;
	            res.responseBody = blob.valueOf(JSON.serialize(response));
	            
	            System.debug('>>>> GetEMailByPersonID' + JSON.serializePretty(response));
	            
	           
	        
    	} catch(Exception ex) {
    		
    		response.status.put('success','false');
			response.status.put('error',ex.getMessage());	
				
			res.statusCode = 400;
			
			res.responseBody = blob.valueOf(JSON.serialize(response));
			
	            
    		
    	}
	        
       
    }
}