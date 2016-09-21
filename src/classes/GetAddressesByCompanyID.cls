/**
* This function should return the billing and the shipping address of an Account by ProRexId__c.
*

Change: 2015_04_21
Ticket: https://jira.sim-technik.de/browse/PRODIA-3471
Requirement: Country Deutschland => D, Österreich=>A

*/


@RestResource(urlMapping='/GetAddressesByCompanyID/*')
global with sharing class GetAddressesByCompanyID {

	@HttpGet
	global static void doGet() {



		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		res.addHeader('Content-Type', 'application/json');

		// read param in
		String pProRexId = RestContext.request.params.get('ProRexId__c');

		System.debug('>>>> GetAddressesByCompanyID param in ' + pProRexId);



		// response
		ResponseWrapper response = new ResponseWrapper();
		response.request.put('ProRexId__c', pProRexId);

		// pre condition
		// param in must not be null

		if (String.isEmpty(pProRexId)) {
			response.status.put('success', 'false');
			response.status.put('error', 'param ProRexId__c is missing');

			res.statusCode = 400;
			res.responseBody = blob.valueOf(JSON.serialize(response));

			return;

		}


		try {

			// prepare response
			response.results = new Map<String,Object>();

			// query thr addresses
			Map<String,Object> record = queryGetAddressesByCompanyID(pProRexId);
			response.results.put('Account', record);

			res.statusCode = 200;
			res.responseBody = blob.valueOf(JSON.serialize(response));

			System.debug('>>>> GetCompanyByName' + JSON.serializePretty(response));



		} catch(Exception ex) {

			response.status.put('success', 'false');
			response.status.put('error', ex.getMessage());

			res.statusCode = 400;

			res.responseBody = blob.valueOf(JSON.serialize(response));

		}


	}


    /**
    * Query the addresses by pProRexId
    *
    * @param pProRexId Company Pro rex Id
    * @return an Account Address in a Map
    */
	public static Map<String,Object> queryGetAddressesByCompanyID(String pProRexId) {
		String l_sCountry;

		// all pre condition ok
		List < Account > accounts = [SELECT AccountNumber, BillingStreet, BillingPostalCode, BillingCity, BillingCountry,ShippingStreet, ShippingPostalCode, ShippingCity, ShippingCountry, NielsenAreaCode__c FROM Account WHERE AccountNumber =: pProRexId];

		if (!accounts.isEmpty()) {
			Map<String,Object> rec = new Map<String,Object>();
			for (Account acc : accounts) {

				rec.put('ProRexId__c', acc.AccountNumber);
				rec.put('BillingStreet', acc.BillingStreet);
				rec.put('BillingPostalCode', acc.BillingPostalCode);
				rec.put('BillingCity', acc.BillingCity);
				rec.put('BillingCountry', modifyCountry(acc.BillingCountry));
				
				rec.put('ShippingStreet', acc.ShippingStreet);
				rec.put('ShippingPostalCode', acc.ShippingPostalCode);
				rec.put('ShippingCity', acc.ShippingCity);
				rec.put('ShippingCountry', modifyCountry(acc.ShippingCountry));
				rec.put('Nielsengebiet__c', acc.NielsenAreaCode__c);
			}

			return rec;
		}
		return null;

	}
	
	private static String modifyCountry (String p_sCountry) {
		
		if (p_sCountry == 'Deutschland') {
			p_sCountry = 'D';
		}
		if (p_sCountry == 'Österreich') {
			p_sCountry = 'A';
		}
		return p_sCountry;
	}
}