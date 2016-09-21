/**
* Handles information about the Liferay Rest API callout
* @author  Sebastian Listl
* @version 0.1, 2014-10-1
* @see P7S1_Liferay_RestClient
*/
public with sharing class P7S1_Liferay_RestStatus {
  public boolean success {get;set;}
  public String message {get;set;}

  public P7S1_Liferay_RestStatus(){}
  public P7S1_Liferay_RestStatus(boolean success){
    this.success = success;
  }

}