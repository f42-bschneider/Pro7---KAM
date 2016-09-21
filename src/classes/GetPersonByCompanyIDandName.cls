/**
*
*
This function should return a list of all Contacts for a given Account (ProRex-Company-ID). Optional the list of contacts could be filtered/limited by
Lastname or/and by Firstname of the contacts. Both name filters should be case insensitive, with * as allowed wildcard. Is no name filter specified
all Contacts for the Account should be returned.

*/

@RestResource(urlMapping='/GetPersonByCompanyIDandName/*')
global with sharing class GetPersonByCompanyIDandName {


@HttpGet
    global static void doGet() {



	    	RestRequest req = RestContext.request;
	        RestResponse res = RestContext.response;
	        res.addHeader('Content-Type', 'application/json');

	        // read param in
	        String pProRexId = RestContext.request.params.get('ProRexId__c');
	     	String pLastName = RestContext.request.params.get('LastName');
	     	String pFirstName = RestContext.request.params.get('FirstName');


			// response
			ResponseWrapper response = new ResponseWrapper();
			response.request.put('ProRexId__c',pProRexId);
			response.request.put('LastName',pLastName);
			response.request.put('FirstName',pFirstName);

			// pre condition
			// param in must not be null

			if (String.isEmpty(pProRexId)) {
				response.status.put('success','false');
				response.status.put('error','param ProRexId__c is missing');

				res.statusCode = 400;
	            res.responseBody = blob.valueOf(JSON.serialize(response));

	            return;

			}

			// Wild card
			if (String.isNotEmpty(pLastName) && pLastName.indexOf('*')>-1) {

				pLastName = '%' + pLastName.replaceAll('\\*','') + '%';
			}

			if (String.isNotEmpty(pFirstName) && pFirstName.indexOf('*')>-1) {

				pFirstName = '%' + pFirstName.replaceAll('\\*','') + '%';
			}


		try {


			// all pre condition ok
			String query ='SELECT ProRexId__c, Account.AccountNumber, FirstName, LastName, Title, Salutation,Birthdate, Phone, Fax, Email FROM Contact WHERE Account.AccountNumber =: pProRexId';

			if (String.isNotEmpty(pLastName)) {
				query +=  ' AND LastName LIKE :pLastName ';
			}
			if (String.isNotEmpty(pFirstName)) {
				query +=  ' AND FirstName LIKE :pFirstName ';
			}

			System.debug('>>>GetPersonByCompanyIDandName ' + query);


	        List<Contact> contacts = Database.query(query);

				response.results = new Map<String,Object>();
				List<Map<String,Object>> records = new List<Map<String,Object>>();

	        	for (Contact con : contacts) {

	        		Map<String,Object> rec = new Map<String,Object>();
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

	        		records.add(rec);

	        	}

	        	response.results.put('Contact',records);

	            res.statusCode = 200;
	            res.responseBody = blob.valueOf(JSON.serialize(response));

	            System.debug('>>>> GetPersonByCompanyIDandName' + JSON.serializePretty(response));



    	} catch(Exception ex) {

    		response.status.put('success','false');
			response.status.put('error',ex.getMessage());

			res.statusCode = 400;

			res.responseBody = blob.valueOf(JSON.serialize(response));



    	}


    }
}