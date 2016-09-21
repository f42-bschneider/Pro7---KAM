/**
*
* This function should return all defined attributes for an Account given by a ProRex-Company-ID.

*
*/

@RestResource(urlMapping='/GetCompanyByID/*')
global with sharing class GetCompanyByID {
	@HttpGet
	global static void doGet() {

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');

		// read param in
		String pProRexId = RestContext.request.params.get('ProRexId__c');

		System.debug('>>>> GetCompanyByName param in ' + pProRexId);



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

			// query the data
			Map<String,Object> record = queryGetCompanyByID(pProRexId);
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
    * Query the company by pProRexId
    *
    * @param pProRexId Company Pro rex Id
    * @return an Account in a Map
    */
	public static Map<String,Object> queryGetCompanyByID(String pProRexId) {

		//query
		List < Account > accounts = [SELECT AccountNumber, Name, RecordType.Name, Accountname_Kurzform__c,Parent.AccountNumber, (SELECT Name FROM P7S1_ExternalId__r WHERE P7S1_Source__c = 'ProSa/ProSedi') FROM Account WHERE AccountNumber =: pProRexId];

		if (!accounts.isEmpty()) {


			Map<String,Object> rec = new Map<String,Object>();

			for (Account acc : accounts) {

				rec.put('Name', acc.Name);
				rec.put('ProRexId__c', acc.AccountNumber);
				rec.put('RecordType.Name', acc.RecordType.Name);
				rec.put('Accountname_Kurzform__c', acc.Accountname_Kurzform__c);
				rec.put('Parent.ProRexId__c', acc.Parent.AccountNumber);
				rec.put('Industry', '');

				// handle the nested query
				List<Map<String,String>> p7s1records = new List<Map<String,String>>();
				for (P7S1_ExternalId__c p7s1 : acc.P7S1_ExternalId__r) {
					Map<String,String> p7s1rec = new Map<String,String>();
					p7s1rec.put('Name', p7s1.Name);

					p7s1records.add(p7s1rec);
				}

				rec.put('P7S1_ExternalId__c', p7s1records);
			}

			return rec;
		}
		return null;
	}

}