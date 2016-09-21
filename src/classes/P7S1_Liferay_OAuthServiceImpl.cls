public class P7S1_Liferay_OAuthServiceImpl implements P7S1_Liferay_OAuthService {

    //public static String USERNAME = 'test@liferay.com';
    //public static String PASSWORD = 'silpioN48!';
    public static String USERNAME = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayRestApiUsername__c; 
    public static String PASSWORD = P7S1_Liferay_ConfigSettings__c.getInstance('DefaultSetting').P7S1_LiferayRestApiPassword__c; 
	public static String HEADER_KEY_AUTHORIZATION = 'Authorization';
	public static String AUTHORIZATION_TYPE_BASIC = 'BASIC ';

	
    public HttpRequest getBasicAuthRequest(String endpoint) {
        HttpRequest request = new HttpRequest();
		request.setEndpoint( endpoint );
		request.setHeader( HEADER_KEY_AUTHORIZATION, getBasicAauthorizationHeader());

		return request;
    }
    
	private String getBasicAauthorizationHeader(){
		Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
      	String authorizationHeader = AUTHORIZATION_TYPE_BASIC + EncodingUtil.base64Encode(headerValue);

      	return authorizationHeader;
	}
}