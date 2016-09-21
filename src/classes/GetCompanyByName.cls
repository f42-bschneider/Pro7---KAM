/**
*
* This function should return a list of Accounts with their assigned P7S1_ExternalIds as response.
*
*/

@RestResource(urlMapping='/GetCompanyByName/*')
global with sharing class GetCompanyByName {

	@HttpGet
	global static void doGet() {

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');

		// read param in
		String companyName = RestContext.request.params.get('Name');

		System.debug('>>>> GetCompanyByName param in ' + companyName);

		// response
		ResponseWrapper response = new ResponseWrapper();
		response.request.put('Name', companyName);

		// pre condition
		// param in must not be null

		if (String.isEmpty(companyName)) {
			response.status.put('success', 'false');
			response.status.put('error', 'param Name is missing');

			res.statusCode = 400;
			res.responseBody = blob.valueOf(JSON.serialize(response));

			return;
		}

		try {
			// Wild card
			if (companyName.indexOf('*') > -1) {
				companyName = '%' + companyName.replaceAll('\\*', '') + '%';
			}

			// all pre condition ok
			List < Account > accounts = [SELECT AccountNumber, Name, RecordType.Name, Accountname_Kurzform__c,Parent.AccountNumber, (SELECT Name FROM P7S1_ExternalId__r WHERE P7S1_Source__c = 'ProSa/ProSedi') FROM Account WHERE Name LIKE :companyName];

			response.results = new Map<String,Object>();
			List<Map<String,Object>> records = new List<Map<String,Object>>();

			for (Account acc : accounts) {

				Map<String,Object> rec = new Map<String,Object>();
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
				records.add(rec);

			}

			response.results.put('Account', records);

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
}