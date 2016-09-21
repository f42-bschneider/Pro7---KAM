/**
*
* Holds the json response

The JSON response should contains at least 3 parts:
Request-Part: here should all parameters in request be given (again).
Status-Part: here should be the process status returned. For the case if there is an error, the error-message is to return.
Results-Part: here are all results to list.

{
 "request": {
 "name": "coca*"
 },
 "status": {
 "success": "true",
 "error": ""
 },
 "results": {
	 "Account": [{"name" : "coca cola"},..]
 }
}


*
*/

global with sharing class ResponseWrapper {
	
	public Map<String,String> request = new Map<String,String>();
	public Map<String,String> status = new Map<String,String>();
	
	public Map<String,Object> results;
	
	
	public ResponseWrapper() {
	
		status.put('success','true');
		status.put('error','');
			
	}
	
}