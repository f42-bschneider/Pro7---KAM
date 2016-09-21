public without sharing class P7S1_ApexResponse {

    //-------------------------------------------------------------------------
    // Properties
    //-------------------------------------------------------------------------
    @AuraEnabled 
    /**
     * Weather operation was successful or not
     */
    public Boolean isSuccess { get; set; }

    @AuraEnabled 
    /**
     * Additional message, most useful when operation had failed
     */
    public String message { get; set; }

    @AuraEnabled 
    /**
     * Key value map for response objects
     */
    public Map<Object, Object> values { get; set; }


    //-------------------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------------------
    /**
     * Default constructor when operation was successful without return data
     */
    public P7S1_ApexResponse(){
        this(true, '', null, null);
    }

    /**
     * Default constructor when operation was successful with return data
     */
    public P7S1_ApexResponse(Object key, Object value){
        this(true, '', key, value);
    }

    /**
     * Default constructor when operation has failed
     */
    public P7S1_ApexResponse(String message){
        this(false, message, null, null);
    }


    /**
     * Default constructor when operation was successfull return data map
     */
    public P7S1_ApexResponse(Map<Object, Object> response){
        this.isSuccess = true;
        this.message = '';
        this.values = response;
    }


    /**
     * Constructor, defines weather operation was successful
     */
    public P7S1_ApexResponse(Boolean isSuccess, String msg, Object key, Object value){
        this.isSuccess  = isSuccess;
        this.message    = msg;
        this.values     = new Map<Object, Object>();

        if(key != null)
        {
            this.values.put(key, value);
        }
    }
}