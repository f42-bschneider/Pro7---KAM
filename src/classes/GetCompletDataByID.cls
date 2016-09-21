/**
*
* This function should return all specified attributes for the given unique IDs in one response. Is there is no result for one of the given IDs an error
("No data found") should be returned.
This function is actually a combi-request of 3.2. GetAddressesByCompanyID, 3.5. GetPersonByID, and 3.6. GetPersonByID. The results of each
single function will just be returned together.

*/

@RestResource(urlMapping='/GetCompletDataByID/*')
global with sharing class GetCompletDataByID {


@HttpGet
    global static void doGet() {
    
    	
    
	    	RestRequest req = RestContext.request;
	        RestResponse res = RestContext.response;
	        res.addHeader('Content-Type', 'application/json');
	        
	        // read param in 
	        String pProRexCompanyID = RestContext.request.params.get('ProRex-Company-ID');
	        String pProRexPersonID = RestContext.request.params.get('ProRex-Person-ID');
	     
	     	
			// response
			ResponseWrapper response = new ResponseWrapper();
			response.request.put('ProRex-Company-ID',pProRexCompanyID);
			response.request.put('ProRex-Person-ID',pProRexPersonID);
			
			// pre condition
			// param in must not be null
			
			if (String.isEmpty(pProRexCompanyID) || String.isEmpty(pProRexPersonID)) {
				response.status.put('success','false');
				response.status.put('error','param ProRex-Company-ID,Person are missing');	
				
				res.statusCode = 400;
	            res.responseBody = blob.valueOf(JSON.serialize(response));
	            
	            return;
	           		
			}
			
			
		try {		
			
	        	// prepare response
	        	response.results = new Map<String,Object>();
	       
	       		// query
	        	Map<String,Object> contactdata = GetPersonByID.queryGetPersonByID(pProRexPersonID);
	        	Map<String,Object> accountdata = GetCompanyByID.queryGetCompanyByID(pProRexCompanyID);
	        	Map<String,Object> addressdata = GetAddressesByCompanyID.queryGetAddressesByCompanyID(pProRexCompanyID);
	        	
	        	if (contactdata==null || accountdata==null) {
	        		
	        		// no contact found -> error
	        		res.statusCode = 400;
	        		response.status.put('success','false');
					response.status.put('error','No data found');
					
					res.responseBody = blob.valueOf(JSON.serialize(response));
					
					return;	
				
	        		
	        	}
	        
	        	response.results.put('Account-Data ',accountdata);
	        	response.results.put('Address-Data ',addressdata);
	        	response.results.put('Contact-Data',contactdata);
	        	
	          	
	            res.statusCode = 200;
	            res.responseBody = blob.valueOf(JSON.serialize(response));
	            
	            System.debug('>>>> GetCompanyByName' + JSON.serializePretty(response));
	            
	           
	        
    	} catch(Exception ex) {
    		
    		response.status.put('success','false');
			response.status.put('error',ex.getMessage());	
				
			res.statusCode = 400;
			
			res.responseBody = blob.valueOf(JSON.serialize(response));
	
    	}
	        
       
    }
}