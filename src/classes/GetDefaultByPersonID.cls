/**
*
*
This function should return all specified attributes for a given ProRex-Person-ID. One Contact is always assigned to one Account and has only
one email address.

*/

@RestResource(urlMapping='/GetDefaultByPersonID/*')
global with sharing class GetDefaultByPersonID {

	public static final String ProRexPersonIDName ='ProRex-Person-ID';

@HttpGet
    global static void doGet() {



	    	RestRequest req = RestContext.request;
	        RestResponse res = RestContext.response;
	        res.addHeader('Content-Type', 'application/json');

	        // read param in
	        String pProRexPersonID  = RestContext.request.params.get(ProRexPersonIDName);


			// response
			ResponseWrapper response = new ResponseWrapper();
			response.request.put(ProRexPersonIDName,pProRexPersonID);

			// pre condition
			// param in must not be null

			if (String.isEmpty(pProRexPersonID)) {
				response.status.put('success','false');
				response.status.put('error','param pProRexPersonID is missing');

				res.statusCode = 400;
	            res.responseBody = blob.valueOf(JSON.serialize(response));

	            return;

			}


		try {

	         	// prepare response
	         	response.results = new Map<String,Object>();

	         	// query
	        	Map<String,Object> contactdata = GetPersonByID.queryGetPersonByID(pProRexPersonID);
	        	response.results.put('Contact-Data',contactdata);
	        	response.results.put('Account-Data ',null);
	        	response.results.put('Address-Data ',null);

	        	// contact found
	        	if (contactdata!=null && contactdata.get('Account.ProRexId__c')!=null) {

	        		//try to load the company linked
	        		String pProRexId = (String)contactdata.get('Account.ProRexId__c');

	        		Map<String,Object> addressdata = GetAddressesByCompanyID.queryGetAddressesByCompanyID(pProRexId);
	        		Map<String,Object> accountdata = GetCompanyByID.queryGetCompanyByID(pProRexId);

	        		response.results.put('Account-Data ',accountdata);
	        		response.results.put('Address-Data ',addressdata);
	        	}

	            res.statusCode = 200;
	            res.responseBody = blob.valueOf(JSON.serialize(response));

	            System.debug('>>>> GetDefaultByPersonID' + JSON.serializePretty(response));



    	} catch(Exception ex) {

    		response.status.put('success','false');
			response.status.put('error',ex.getMessage());

			res.statusCode = 400;

			res.responseBody = blob.valueOf(JSON.serialize(response));

    	}

    }

}