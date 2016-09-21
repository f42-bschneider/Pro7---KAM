/**
* Service for the outgoing Calls against the Liferay Rest API
* @author  Sebastian Listl
* @version 0.1, 2014-10-1
* @see P7S1_Liferay_RestClient
*/
public interface P7S1_Liferay_RestService {

  	/**
  	* activates an user in liferay via the rest api
  	* @since 0.1
  	* return staus informations to see if rest call was success full
   	* @see P7S1_Liferay_RestStatus
   	*/
  	P7S1_Liferay_RestStatus liferayUserActivate( Long userId );
  
	/**
  	* sets an user in liferay tod deleted via the rest api
  	* @since 0.1
  	* return staus informations to see if rest call was success full
   * @see P7S1_Liferay_RestStatus
   */
  	P7S1_Liferay_RestStatus liferayUserDelete(Long userId);

}