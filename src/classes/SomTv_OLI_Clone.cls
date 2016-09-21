/**
 * Purpose:  Clone the Salesforce standard object OpportunityLineItem
 * Created Date: June 20, 2014
 * Created By: ADVENDIO
 */
public with sharing class SomTv_OLI_Clone {

  public list<OpportunityLineItem> listOppLineItem {get; set;}

  public SomTv_OLI_Clone(){
    listOppLineItem = new list<OpportunityLineItem>();

    // list ID of OpportunityLineItem to Clone
    List<string> listOpptId = ApexPages.CurrentPage().getParameters().get('opptIds').split(',');

    // Query Source OpportunityLineItem to Clone
    Schema.DescribeSObjectResult describeResult = OpportunityLineItem.sObjectType.getDescribe();
    Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();

    String query = 'SELECT ';
        for (String fieldName : fieldsMap.keySet()){
            // Don't get TotalPrice
            if ('TotalPrice'.equalsignorecase(fieldname)) {
              continue;
            }

            Schema.DescribeFieldResult f = fieldsMap.get(fieldName).getDescribe();

            //Some field can create but not updatable, except field-reference to master object
            if(f.isUpdateable() || (f.getType()==Schema.DisplayType.REFERENCE && f.isCreateable() && !f.isUpdateable())) {
                // should by pass all readonly field
                query += fieldName + ',';
            }
        }
        query = query.substring(0, query.length()-1);
        query += ' FROM OpportunityLineItem Where Id IN :listOpptId';

    listOppLineItem = Database.query(query);

    // Assign OpportunityLineItem to class Wrapper to display value on VF-Page
    for(OpportunityLineItem opptItem :listOppLineItem){
      opptItem.SomTv_NumberOfTimesToClone__c = 1;
    }
  }

  /*
     * Start Cloning the OpportunityLineItem
     */
  public PageReference startClone(){
    SavePoint sp = Database.setSavepoint();
        try {
          // Create a new list of OpportunityLineItem to Save
          List<OpportunityLineItem> listOpptLineItemToSave = new List<OpportunityLineItem>();

            for(OpportunityLineItem oppt :listOppLineItem){

              // Number of Time to Clone : allowed value is digit only, and must be greater than 0
              if(oppt.SomTv_NumberOfTimesToClone__c < 1 ){
                String errMsg = system.Label.SomTv_NumberOfTimesToClone + ': ' + System.Label.SomTv_ErrMsgNumberOfTimesToClone;
                this.displayErrMsg(errMsg);
                return null;
              }

              // loop and assign fields value to to OpportunityLineItem to save
              for(Integer i=0; i<oppt.SomTv_NumberOfTimesToClone__c; i++){
                OpportunityLineItem opptLineItem = oppt.clone(false, true, false, false);
                opptLineItem.SomTv_NumberOfTimesToClone__c = null;

                listOpptLineItemToSave.add(opptLineItem);
              }
            }

            // saving list of OpportunityLineItem
            if(!listOpptLineItemToSave.isEmpty()) insert listOpptLineItemToSave;

            // return to previous page
            String retURL = Apexpages.currentPage().getParameters().get('retURL');
          String p = Apexpages.currentPage().getParameters().get('p');
          Pagereference page;

          // Back to newly clone OpportunityLineItem — clone a single OpportunityLineItem
            if(p=='s' && listOpptLineItemToSave.size() > 0){
              String id = listOpptLineItemToSave.get(listOpptLineItemToSave.size()-1).Id;
              page = new PageReference('/'+Id );
            }
            // Back to last location - clone multiple OpportunityLineItems
            else{
            page = new PageReference(retURL);
            }
            page.setRedirect(true);
            return page;
        }
        catch(Exception e) {
            this.displayErrMsg(e.getMessage());
            Database.rollback(sp);
            return null;
        }
    }

    /*
     * Add Error Message to VF-Page
     */
    public void displayErrMsg(String strMsg){
      ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '<ul style="padding:0;margin:0;"><li>'+strMsg+'</li></ul>');
        ApexPages.addMessage(msg);
    }

    /*
     * Back to previous page
     */
    public PageReference back(){
        String retURL = Apexpages.currentPage().getParameters().get('retURL');
        Pagereference page = new PageReference(retURL);
        page.setRedirect(true);
        return page;
    }

}