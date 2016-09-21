/**
  @author: ADvendio.com (helge.kosuch@advendio.com)
  
  
 */

public with sharing class PdfGenerator {

	/** May be modified from outside: */
    public String htmlStyleEverywhere =  'width: 900px;';
	
    static final Boolean DEBUG = ClsHelper.isSandboxOrgFlag;
    
    static final String renderAsPdfUrlParameterName = 'renderAsPdf';
    static final String renderAsPdfUrlParameterTrueValue = 'true';

    /**
     To set this ad (?/&)+"renderAsPdf=true" to the URL
     */
    public Boolean renderAsPdf {get; private set;}
    {
        renderAsPdf = ApexPages.currentPage().getParameters().get(renderAsPdfUrlParameterName) == renderAsPdfUrlParameterTrueValue;
    }

    /** Called by {!pdfGeneratorInstance.styleEverywhere}.
     * This is only for styles which are to be different depending upon if this is rendered as pdf or html.
     */
    public String getStyleEverywhere() {
        return renderAsPdf ? '' : htmlStyleEverywhere; 
    }
    
    public PageReference pdfNewPageReference(Id objectId) {
        PageReference pdfPageReference = System.currentPageReference();
        pdfPageReference.getParameters().put('id',objectId);
        pdfPageReference.getParameters().put(renderAsPdfUrlParameterName,renderAsPdfUrlParameterTrueValue);
        pdfPageReference.getParameters().put(SAVE_PAGE_PARAM_NAME,'false');
        renderAsPdf = true;
        return pdfPageReference;
    }
        
    public PageReference pdfSaveAsAttachment(
        Id objectId
        /** testFlag is needed because otherwise you get "Methods defined as TestMethod do not support getContent 
         * call, test skipped" in the test. */
        , String filename
        , Boolean testFlag
    ) {       
        
        PageReference pdfPageReference = pdfNewPageReference(objectId); 
        Blob pdfBlob;
        
        if (testFlag) {
            pdfBlob = Blob.valueof('Sarah');
        } else {
            // Keep this block small to keep test coverage high!
            pdfBlob = pdfPageReference.getContentAsPDF();
            /* Gotchas: Do not try to render this page any differently than the page the controller displayed 
             first, for example by changing url parameters. This mostly fails and costs much time to debug.
             Instead use pdfSaveAsAttachmentIfSaveParam(...), see there. */
            
        } 

        // Attach the pdf document to the opportunity or whatever object the variable objectId refers to:
        Attachment attachment = new Attachment(parentId = objectId, name = filename + '.pdf', body = pdfBlob);
        insert attachment;

        String returnUrl = '/' + objectId + '#' + ((String)objectId).substring(0,15) +'_RelatedNoteList_target'; 

        return new PageReference(returnUrl);
    }
    
    public static final String SAVE_PAGE_PARAM_NAME = 'save';
    
    /**<pre> Does the same as pdfSaveAsAttachment(...), but only if the page param "save" is "true".

	Use example:
	Controller:
	    public PageReference calledByPageActionAttribute() { 
	    	return pdfGeneratorInstance.pdfSaveAsAttachmentIfSaveParam(
	    		OPP_ID
	    		,'Contract Request: '+(vertrag==null?'':vertrag.Ven_Opportunity__r.name+' - '+vertrag.RecordType.name) //=filename
	    		,false
			);
	    }    
	    
	Page:
		<apex:page renderas="{!IF(pdfGeneratorInstance.renderAsPdf,'pdf','html')}" action="{!calledByPageActionAttribute}">
		
		<!-- Link that lets the user save the pdf: -->
		<a href="/apex/ContractRequest?id={!c.OPP_ID}&vertragsid={!vertrag.id}&renderAsPdf=true&save=true">
			                    	Save to Opportunity</a>
		 
	</pre>*/

    public PageReference pdfSaveAsAttachmentIfSaveParam(Id objectId, String filename, Boolean testFlag) {
    	
    	final String saveParam = System.currentPageReference().getParameters().get(SAVE_PAGE_PARAM_NAME);
    	if (saveParam!=null && saveParam.equals('true')) {
	        return pdfSaveAsAttachment(objectId,filename,testFlag);
    	} else {
    		return null;
    	}
    }      
    
    @isTest  
    static void test() {
        Account acc = ClsHelper.newTestAccount(System.UserInfo.getUserId(),'uoiuwerouqda');
        insert acc;
        PdfGenerator pGenerator = new PdfGenerator();
        pGenerator.pdfSaveAsAttachment(acc.id,'testfilename',true /*==testFlag*/);
        pGenerator.getStyleEverywhere();
    } 
          
}