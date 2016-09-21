/**
* Represents the user object with the relevant fields for the P7S1_Liferay_RestService returned from the liferay REST call
* @author  Sebastian Listl
* @version 0.1, 2014-08-31
* @see P7S1_Liferay_RestService
*/
public with sharing class P7S1_Liferay_User {

  public static Integer STATUS_ACTIVE = 0;
  public static Integer STATUS_INACTIVE = 5;

  public long userId  {get;set;}
  public Integer status  {get;set;}
  public Boolean deleted {get;set;}

  	public P7S1_Liferay_User(){
		this.deleted = false;
  	}
  	public P7S1_Liferay_User(long userId, Integer status ){
	    this.userId  = userId;
	    this.status  = status;
	    this.deleted = false;
  	}
  	public P7S1_Liferay_User(long userId, Integer status, Boolean deleted ){
	    this.userId  = userId;
	    this.status  = status;
	    this.deleted = deleted;
  	}

  public static P7S1_Liferay_User parse(String json) {
        return (P7S1_Liferay_User) System.JSON.deserialize(json, P7S1_Liferay_User.class);
    }
    public String toJson(){
      return JSON.serialize( this );
    }

}