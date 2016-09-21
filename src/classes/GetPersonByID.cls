/**
* This function should return all defined attributes for a Contact given by a ProRex-Person-ID
*
*/


@RestResource(urlMapping='/GetPersonByID/*')
global with sharing class GetPersonByID {


@HttpGet
    global static void doGet() {



	    	RestRequest req = RestContext.request;
	        RestResponse res = RestContext.response;
	        res.addHeader('Content-Type', 'application/json');

	        // read param in
	        String pProRexId = RestContext.request.params.get('ProRexId__c');

	        System.debug('>>>> GetPersonByID param in ' + pProRexId);



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

	         	// prepare response
	         	response.results = new Map<String,Object>();

	         	// query
	        	Map<String,Object> record = queryGetPersonByID(pProRexId);
	        	response.results.put('Contact',record);

	            res.statusCode = 200;
	            res.responseBody = blob.valueOf(JSON.serialize(response));

	            System.debug('>>>> GetPersonByID' + JSON.serializePretty(response));



    	} catch(Exception ex) {

    		response.status.put('success','false');
			response.status.put('error',ex.getMessage());

			res.statusCode = 400;

			res.responseBody = blob.valueOf(JSON.serialize(response));

    	}

    }


    /**
    * Query a Contact by pProRexId
    *
    * @param pProRexId Contact Pro rex Id
    * @return a Contact in a Map
    */
    public static Map<String,Object> queryGetPersonByID(String pProRexId) {


			// all pre condition ok
	        List<Contact> contacts = [SELECT ProRexId__c, Account.AccountNumber, FirstName, LastName, Title, Salutation,Birthdate, Phone, Fax, Email FROM Contact WHERE ProRexId__c =: pProRexId];

			if (!contacts.isEmpty()) {

				Map<String,Object> rec = new Map<String,Object>();

		        for (Contact con : contacts) {

		        		rec.put('ProRexId__c',con.ProRexId__c);
		        		rec.put('Account.ProRexId__c',con.Account.AccountNumber);
		        		rec.put('FirstName',con.FirstName);
		        		rec.put('LastName',con.LastName);
		        		rec.put('Title',con.Title);
		        		rec.put('Salutation',con.Salutation);
		        		rec.put('Birthdate',con.Birthdate);
		        		rec.put('Phone',con.Phone);
		        		rec.put('Fax',con.Fax);
		        		rec.put('Email',con.Email);

		        }


		        return rec;
			}

	        return null;
    }

}