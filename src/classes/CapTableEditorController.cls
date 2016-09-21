/**<pre>

For debugging:
for (Ven_Share__c[] shares: [SELECT id FROM Ven_Share__c]) {
    delete shares;
}

Execute this in the SF Developer Console execute anonymous when the update for the CapTable Oct 2013 is deployed.
It inserts Founder's and SV's shares as share objects
String SEVEN_VENTURES_ACCOUNTNUMBER = '1';
public Account sevenVenturesAcc {get; private set;}  
{
    Account [] accList = [SELECT id,name FROM Account WHERE AccountNumber=:SEVEN_VENTURES_ACCOUNTNUMBER];
    System.assertEquals(1,accList.size(),'There must be exactly one account with the AccountNumber '+SEVEN_VENTURES_ACCOUNTNUMBER);
    sevenVenturesAcc = accList[0];
}	
Ven_Share__c[] sharesToInsert = new List<Ven_Share__c>();
for (Ven_Round__c round : [
    SELECT id,Ven_Account__c,Ven_SV_Equity_Share__c,Ven_Founders_Equity_Share__c,Ven_Aktiv__c FROM Ven_Round__c
]) {
    sharesToInsert.add(new Ven_Share__c(
         Ven_Account__c      = round.Ven_Account__c
        ,Ven_Round__c        = round.id
        ,Ven_Shareholder__c  = round.Ven_Account__c
        ,Ven_Shares__c       = round.Ven_SV_Equity_Share__c
    ));
    sharesToInsert.add(new Ven_Share__c(
         Ven_Account__c      = round.Ven_Account__c
        ,Ven_Round__c        = round.id
        ,Ven_Shareholder__c  = sevenVenturesAcc.id
        ,Ven_Shares__c       = round.Ven_Founders_Equity_Share__c
    ));    
}
insert sharesToInsert;

@author: ADvendio.com (helge.kosuch@advendio.com)
 </pre>*/
public with sharing class CapTableEditorController {
	static final boolean DEBUG = false;
	public final String SEVEN_VENTURES_ACCOUNTNUMBER;
	{ SEVEN_VENTURES_ACCOUNTNUMBER = Test.isRunningTest()?'1':Ven_Settings__c.getInstance().Ven_SvAccountNumber__c;
	}
	public Account sevenVenturesAcc {get; private set;}  
	{
		Account [] accList = [SELECT id,name FROM Account WHERE AccountNumber=:SEVEN_VENTURES_ACCOUNTNUMBER];
		System.assertEquals(1,accList.size(),'There must be exactly one account with the AccountNumber '+SEVEN_VENTURES_ACCOUNTNUMBER);
		sevenVenturesAcc = accList[0];
	}	
	public boolean renderAsPdf {get; set;} { renderAsPdf = false; }
	/** This is so short because all controller accesses in the page go through this to enable easy moving to components. */
	public CapTableEditorController getC() {
		return this;
	}  	
	/**<pre>
	Because the size page is set to one, this list will always contain only one value.
	</pre>*/
	public List<Ven_Round__c> getRecordsOfCurrentSetControllerPage() {
		return (List<Ven_Round__c>) setController.getRecords();
	}
	/**<pre> showSVAndFoundersFieldsFlag: The field, in contrast to the shares of Seven Ventures and the Founders must only be displayed on the very first round before it
	 is inserted for the first time. After that regular share will have been created for these two.
	</pre>*/
	public boolean showSVAndFoundersFieldsFlag {get; private set;} {showSVAndFoundersFieldsFlag=false;/* Will be set to true by createFirstRound(...)*/}
	public String pageSize {get;set;}
	public ApexPages.StandardSetController setController {get;set;}
	public Boolean editFlag {get; set;}
	public Account acc {get; private set;}
	public boolean getOldRoundsExistFlag() {
		return roundsOld.size() != 0;
	}	
	/** roundsOld contains all rounds but the newestRound 
	 * 
	 * The round with the highest round number (which is the most recent) is contained in oldRounds[0]!
	 * 
	 * */
	public List<Ven_Round__c> roundsOld {get; private set;} 
	public class NewestRoundWrapper {
		private Ven_Round__c newestRound;
		
		public Ven_Round__c getNewestRound() {
			return newestRound;
		}		
		public void setNewestRound(Ven_Round__c newValue) {
			newestRound = newValue;
		}				
		public boolean newestRoundIsInDatabase = false;		

		public List<Ven_Share__c> getNewestRoundShares() {
			return newestRoundShares;
		}		
		public List<Ven_Share__c> newestRoundShares; {newestRoundShares = new List<Ven_Share__c>();}
		
		/** previousNewestRound. After the user has clicked on "New Round", this contains the round that was displayed before the
		 * editor with the new one is displayed. 
		 * 
		 * May contain null if the newestRound is the only round.
		 * 
		 * At this time this is needed to:
		 * 1) set Ven_Aktiv__c to false
		 **/
		public Ven_Round__c previousNewestRound {get; private set;}		

		/** At this time used if the user wants to delete a specific share */
		private Map<Id,Ven_Share__c> sharesOfNewestRoundById;
	}	
	public List<Ven_Share__c> getNewestRoundShares() {
		return this.newestRoundWrapperInstance.getNewestRoundShares();
	}	
	public NewestRoundWrapper newestRoundWrapperInstance = new NewestRoundWrapper(); 
	
	public Ven_Round__c getNewestRound() {
		return newestRoundWrapperInstance.getNewestRound();
	}	
	public Boolean getRoundsExistFlag() {
		return newestRoundWrapperInstance.getNewestRound() != null;
	}
	/** 
	* add a message to queue used by VF Page
	* @param Severity to be used
	* @param Message as String 
	**/
	private void setMessage(ApexPages.Severity severity, String msg) {
		ApexPages.addMessage(new ApexPages.Message(severity, msg));
	}
	/** 
	* add an ERROR message
	* @param Message as String 
	**/
	private void setError(String msg) {
		setMessage(ApexPages.severity.ERROR, msg);
	}
	/** 
	* add an INFO message
	* @param Message as String 
	**/
	private void setInfo(String msg) {
		setMessage(ApexPages.severity.INFO, msg);
	}
	/**<pre>
	This is called from the constructor and 
	e. g. this is called from delete.	
	</pre>*/
	private void requery() {		
		try {
			this.newestRoundWrapperInstance.setNewestRound(null); // This is important in order to make "Cancel" work for the first round.
			
			// Do NOT make this an instance variable! For that the code below must be changed!! 
			final List<Ven_Round__c> roundsAll = [
                SELECT Id, Ven_G_ltig_ab__c, Ven_Aktiv__c, Ven_all_Shares__c, Ven_Category__c, Ven_Founders_Equity_Share__c, Ven_SV_Equity_Share__c, Ven_SV_Share__c, 
					 Ven_Round_Number__c, Ven_Total_Share_Value__c, Ven_Wert_Founder__c, Ven_Wert_pro_Anteil__c, Ven_Wert_SV__c,
					 (SELECT Id, Ven_Round__c, Ven_Share__c, Ven_Shareholder__c, Ven_Shareholder__r.Name, Ven_Shares__c, Ven_Wert__c
					  FROM Ven_Shares__r ORDER BY name)
				FROM Ven_Round__c WHERE Ven_Account__c=:acc.id ORDER BY Ven_Round_Number__c DESC
			];

			this.setController = new ApexPages.StandardSetController(roundsAll);
			setController.setPageSize(1);
			if (roundsAll.size()==0) {
				return;
			}
			this.newestRoundWrapperInstance.setNewestRound(roundsAll[0]);
			this.newestRoundWrapperInstance.newestRoundShares = this.newestRoundWrapperInstance.getNewestRound().Ven_Shares__r;
			this.newestRoundWrapperInstance.newestRoundIsInDatabase = true; 
			System.assertNotEquals(null,this.newestRoundWrapperInstance.getNewestRound());
			sharesOfNewestRoundByIdRefresh();
			this.roundsOld = roundsAll;
			this.roundsOld.remove(0); // roundsAll is invalid now
			this.newestRoundWrapperInstance.previousNewestRound = roundsOld.size()==0 ? null : roundsOld[0];
			
		} catch(Exception e) {
			setError(e.getMessage());
			throw e;
		}
	}	
	/**<pre>
	(Re-)initialize the map sharesOfNewestRoundById from newestRoundWrapperInstance.newestRoundShares
	</pre>*/
	void sharesOfNewestRoundByIdRefresh() {
		this.newestRoundWrapperInstance.sharesOfNewestRoundById = new Map<Id,Ven_Share__c>(this.newestRoundWrapperInstance.newestRoundShares);
	}
	public CapTableEditorController(ApexPages.StandardController stdController) { //constructor
		this((Account)stdController.getRecord());
	}	
	public CapTableEditorController(Account accParam) { //constructor
		this.acc = accParam;

		requery();
	}	
	public PageReference saveRoundButton() {	
		final Date newestRoundGueltigAbBuffered = this.newestRoundWrapperInstance.getNewestRound().Ven_G_ltig_ab__c;
		final Ven_Round__c prevRoundBuffered = this.newestRoundWrapperInstance.previousNewestRound;
		final Date previousNewestRoundGueltigAbBuffered = prevRoundBuffered==null?null:prevRoundBuffered.Ven_G_ltig_ab__c;
		
		if (newestRoundGueltigAbBuffered            !=null // a date is always required now
			&&
			(
				previousNewestRoundGueltigAbBuffered == null // requested by customer this any date is fine if the prev has no date
				||
				(
					/*roundsOld.size() == 0
					|| */
					newestRoundGueltigAbBuffered > previousNewestRoundGueltigAbBuffered
				)
			)
		){
			saveRound();
			editFlag = false;
		} else {
			saveRoundButtonFail();
			return null;
		}

		return null;
	}
	void saveRoundButtonFail() {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
				'Das Gültigkeitsdatum einer neuen Runde muss nach dem der vorherigen Runde liegen und darf nicht leer sein.'
				+   ( DEBUG ?
					'newestRoundGueltigAbBuffered=='+this.newestRoundWrapperInstance.getNewestRound().Ven_G_ltig_ab__c
					+', this.newestRoundWrapperInstance.previousNewestRound.Ven_G_ltig_ab__c=='
					+ this.newestRoundWrapperInstance.previousNewestRound.Ven_G_ltig_ab__c
					+', roundsOld.size()=='+roundsOld.size()
					: '' 
					)
				)
			); 		
	}
	void recalcSumOfShares() {
		recalcSumOfShares(null);
	}
	
	void recalcSumOfShares(Id shareId) {
		// Re-calc total number of shares
		Decimal sum = 0;

		for (Ven_Share__c share: this.newestRoundWrapperInstance.newestRoundShares) {

			if (shareId != null && share.Id == shareId) {
				continue;
			}
			sum += ClsHelper.nullToZero(share.Ven_Shares__c);
		}
		
		this.newestRoundWrapperInstance.getNewestRound().Ven_all_Shares__c = sum;
	}	
	public PageReference deleteShare() {
		try {
			Id shareId = Apexpages.currentPage().getParameters().get('shareToBeDeletedId');
			System.assertNotEquals(shareId,null,'shareId is null');

			delete this.newestRoundWrapperInstance.sharesOfNewestRoundById.get(shareId);
			this.newestRoundWrapperInstance.sharesOfNewestRoundById.remove(shareId);
			
			recalcSumOfShares(shareId);
			upsert this.newestRoundWrapperInstance.getNewestRound(); // This recalculates the formulas, especially the percentages.
			requery();
		}
		catch(Exception e) {
			setError(e.getMessage());
			throw e;
		}
		return null;
	}	
	/**<pre> deleteRoundButton(): Should be renamed to deleteNewestRoundButton(), because that is what is does.

	</pre>*/
	public PageReference deleteRoundButton() {
		editFlag = false;
		newShare = null; // Otherwise this share would be deleted if the user would cancel later.
		System.assert(newestRoundWrapperInstance.newestRoundIsInDatabase
			, 'Fail: Someone tried to delete a round which was not inserted to the DB yet.'
		);		
		if (this.newestRoundWrapperInstance.getNewestRound() == null) {
			System.debug('this.newestRoundWrapperInstance.getNewestRound() == null');	
		} else {
			delete this.newestRoundWrapperInstance.getNewestRound();
		}			
		if (roundsOld.size()>0) {
			this.newestRoundWrapperInstance.setNewestRound(roundsOld.remove(0)); //TODOk 10
			this.newestRoundWrapperInstance.previousNewestRound = roundsOld.size()==0 ? null : roundsOld[0];
			this.newestRoundWrapperInstance.getNewestRound().Ven_Aktiv__c = true;
			upsert this.newestRoundWrapperInstance.getNewestRound();
			this.newestRoundWrapperInstance.newestRoundIsInDatabase = true;
		} else {
			this.newestRoundWrapperInstance.setNewestRound(null);
			this.newestRoundWrapperInstance.previousNewestRound = null;
			this.newestRoundWrapperInstance.newestRoundIsInDatabase = false;
		}		
		// Now we requery to be on the safe side. Some of the lines above are probably not needed because of this.
		// They are kept anyhow, in case we want to remove the requery() later.
		// If you don't requery, at least something like this is needed:
		// this.setController = new ApexPages.StandardSetController(roundsAll);
		// setController.setPageSize(1);
		requery();	
		return null;
	}	
	void saveRound() {
		try {
			if ( ! this.newestRoundWrapperInstance.newestRoundIsInDatabase && this.newestRoundWrapperInstance.previousNewestRound!=null) {
				// The newest round is not in the database yet and there is a previousNewestRound !
				// Then let's add the previous round to the list of old rounds:
				roundsOld.add(0,this.newestRoundWrapperInstance.previousNewestRound);
			}
			newShare = null; // Remove the reference in newShare, because otherwise this share would be deleted if the user would cancel later.
			if (this.newestRoundWrapperInstance.previousNewestRound != null) {
				// There is a previousNewestRound!
				// Mark is as not active:
				this.newestRoundWrapperInstance.previousNewestRound.Ven_Aktiv__c = false;
				upsert this.newestRoundWrapperInstance.previousNewestRound;
				this.newestRoundWrapperInstance.previousNewestRound = null;
			}	
			this.newestRoundWrapperInstance.getNewestRound().Ven_Aktiv__c = true;
			upsert this.newestRoundWrapperInstance.getNewestRound();			
			this.newestRoundWrapperInstance.newestRoundIsInDatabase = true;
			// Loop over shares
			Ven_Share__c [] newestRoundShares = this.newestRoundWrapperInstance.newestRoundShares;
			for (Ven_Share__c share : newestRoundShares) {
				// Fill lookups in shares with round id
				if (share.Ven_Round__c == null) {
					share.Ven_Round__c = this.newestRoundWrapperInstance.getNewestRound().Id;
				}
			}	
			if (showSVAndFoundersFieldsFlag) {
				showSVAndFoundersFieldsFlag = false;
				// We are saving the first round!
				// Then we must:
				// Add the share of SevenVentures:
				newestRoundShares.add(new Ven_Share__c( // This is a separate insert because in the display later they are sorted by CreatedDate and we want this first.
					  Ven_Round__c = this.newestRoundWrapperInstance.getNewestRound().Id
					, Ven_Account__c = acc.Id 
					, Ven_Shareholder__c = sevenVenturesAcc.id
					, Ven_Shares__c = this.newestRoundWrapperInstance.getNewestRound().Ven_SV_Equity_Share__c // sic! The first in plural, the secound in singular, this is correct.
				));				
				// Add the share of the Founders now!:
				newestRoundShares.add(new Ven_Share__c( // This is a separate insert because in the display later they are sorted by CreatedDate and we want this second.
					  Ven_Round__c = this.newestRoundWrapperInstance.getNewestRound().Id
					, Ven_Account__c = acc.Id     // Yes, both Account and Shareholder point to the same account record, the current account.
					, Ven_Shareholder__c = acc.Id // Yes, both Account and Shareholder point to the same account record, the current account.
					, Ven_Shares__c = this.newestRoundWrapperInstance.getNewestRound().Ven_Founders_Equity_Share__c // sic! The first in plural, the secound in singular, this is correct.
				));
			}
			recalcSumOfShares();		
			// Upsert the shares:
			upsert newestRoundShares;	
			upsert this.newestRoundWrapperInstance.getNewestRound();			
			requery(); // needed to retrieve new formula values. At this time the share percentages.		
		}
		catch(Exception e) {
			setError(e.getMessage());
			throw e;
		}
	}
	/**<pre>
	Called by the button "Runde anlegen".
	</pre>*/
	public PageReference createFirstRound() {	
		try {
			showSVAndFoundersFieldsFlag = true;
			editFlag = true;
			this.newestRoundWrapperInstance.setNewestRound(new Ven_Round__c(Ven_Account__c=acc.id,Ven_Round_Number__c=1));
			this.newestRoundWrapperInstance.newestRoundShares = new List<Ven_Share__c>();
			
			// The shares of SevenVentures and the founders are not added here. They are created when the first round is inserted into the DB.
			
			this.setController = new ApexPages.StandardSetController(new List<Ven_Round__c>());
			setController.setPageSize(1);
			
			sharesOfNewestRoundByIdRefresh();
	
			this.roundsOld = new List<Ven_Round__c>();
		}
		catch(Exception e) {
			throw e;
			setError(e.getMessage());
		}		
		return null;
	}	
	Ven_Round__c roundToBeDeletedIfCanceled = null;	
	List<Ven_Share__c> previousNewestRoundShares;
	/**<pre>
	This is called by the button "New Round".
	The shares of SevenVentures and the founders are added automatically because all shares of the old round are copied.
	</pre>*/
	public PageReference newRound() {	
		try {	
			editFlag = true;
			
			System.assertNotEquals(null,this.newestRoundWrapperInstance.getNewestRound());
			System.assertNotEquals(null,this.newestRoundWrapperInstance.getNewestRound().Ven_Round_Number__c
				,'The round number of the round '+this.newestRoundWrapperInstance.getNewestRound().id+' is null. This is not allowed.'
			);			
			Ven_Round__c newRound = new Ven_Round__c(
				Ven_Account__c					= acc.id,
				Ven_Round_Number__c				= this.newestRoundWrapperInstance.getNewestRound().Ven_Round_Number__c + 1,
				Ven_Founders_Equity_Share__c	= this.newestRoundWrapperInstance.getNewestRound().Ven_Founders_Equity_Share__c,
				Ven_all_Shares__c				= this.newestRoundWrapperInstance.getNewestRound().Ven_all_Shares__c,
				Ven_SV_Equity_Share__c			= this.newestRoundWrapperInstance.getNewestRound().Ven_SV_Equity_Share__c,
				Ven_Category__c					= this.newestRoundWrapperInstance.getNewestRound().Ven_Category__c,
				Ven_Wert_pro_Anteil__c			= this.newestRoundWrapperInstance.getNewestRound().Ven_Wert_pro_Anteil__c,
				Ven_G_ltig_ab__c    			= this.newestRoundWrapperInstance.getNewestRound().Ven_G_ltig_ab__c,
				Ven_Aktiv__c 					= true
			);			
	//		insert newRound;
	//		roundToBeDeletedIfCanceled = newRound;	
			// copy shares to new round
			System.debug('this.newestRoundWrapperInstance.getNewestRound().Ven_Shares__r');
			System.debug(this.newestRoundWrapperInstance.getNewestRound().Ven_Shares__r);
			//delete, debug code: System.assertNotEquals(0,this.newestRoundWrapperInstance.getNewestRound().Ven_Shares__r.size(),this.newestRoundWrapperInstance.getNewestRound().Ven_Shares__r.size());
		
			previousNewestRoundShares = this.newestRoundWrapperInstance.newestRoundShares;
			this.newestRoundWrapperInstance.newestRoundShares = new List<Ven_Share__c>();
			// Copy the shares of the previous round: 
			for (Ven_Share__c share :  this.newestRoundWrapperInstance.getNewestRound().Ven_Shares__r) {
				this.newestRoundWrapperInstance.newestRoundShares.add(new Ven_Share__c(
					Ven_Account__c = acc.id ,Ven_Shareholder__c = share.Ven_Shareholder__c ,Ven_Shares__c = share.Ven_Shares__c
				));
			}			
	//		insert this.newestRoundWrapperInstance.newestRoundShares;		
			this.newestRoundWrapperInstance.previousNewestRound = this.newestRoundWrapperInstance.getNewestRound();
			this.newestRoundWrapperInstance.setNewestRound(newRound);
		}
		catch(Exception e) {
			setError(e.getMessage());
			throw e;
		}
		return null;
	}
	public PageReference cancel() {		
		try {
			if (roundToBeDeletedIfCanceled !=null) {
				delete roundToBeDeletedIfCanceled;
				roundToBeDeletedIfCanceled = null;
			}			
			if (newShare != null) {
				delete newShare;
				newShare = null;
			}
			requery(); // This is important, otherwise the edited values are still displayed. 			
			if (editFlag) {
				editFlag = false;
				return null;
			} else {
				// return to the accounts page
				return new PageReference('/'+acc.id);
			}
		}
		catch(Exception e) {
			setError(e.getMessage());
			throw e;
		}
	}
	public PageReference edit() {
		editFlag = true;
		return null;
	}		
	Ven_Share__c newShare;	
	public PageReference newShare() {
		try {
			// Create a new share and store it in an instance field, to be able to delete it, if the user hits "Cancel"
			newShare = new Ven_Share__c(Ven_Round__c = this.newestRoundWrapperInstance.getNewestRound().Id, Ven_Account__c = acc.Id);
	
			insert newShare; // Not inserting here but later fails.
	
			editFlag = true;
			requery();
		}
		catch(Exception e) {
			setError(e.getMessage());
			throw e;
		}		
		return null;
	}
}