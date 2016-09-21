/**
* Class 'Som_Kontaktbericht'
* Creates a Kontaktbericht Template with Attendees based on an Event
* @author stefan.voss@advendio.com
*
**/

public without sharing class cls_Som_Kontaktbericht {

	/** Event-Record Id - Kontaktbericht will be connected to this Event **/
	private Id eventId;
	
	/** Controller for VF Page **/
	public cls_Som_Kontaktbericht(ApexPages.Standardcontroller controller) {
		eventId				= controller.getId();
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

	/** Go back calling Event (used in VF Page) 
	* @return PageReference
	**/
	public PageReference backToEvent() {
		return new PageReference('/' + eventId);
	}

	public PageReference createVisitReport() {
		String idString = '';
		List<Som_KontaktberichtContact__c> tnList = new List<Som_KontaktberichtContact__c>();
		Map<Id, Som_KontaktberichtContact__c> attendeeByConId = new Map<Id, Som_KontaktberichtContact__c>();
		Som_Kontaktbericht__c vreport;
		Boolean existingVR = false;
	
		Event event = new Event();
	
		try {
			event = [select DurationInMinutes, Description, Subject,ActivityDateTime, Id,OwnerId ,AccountId,WhoId,WhatId, Account.RecordType.DeveloperName, Account.RecordType.Name from Event where Id =: eventId];
			if (event != null) {

				for (Som_Kontaktbericht__c vr : [select Id, (select Id, Som_Contact__c from Teilnehmer__r) from Som_Kontaktbericht__c where Som_EreignisReferenz__c =: event.Id limit 1]) {
					existingVR	= true;
					vreport = vr;
					if (vr.Teilnehmer__r != null) {
						for (Som_KontaktberichtContact__c att : vr.Teilnehmer__r) {
							attendeeByConId.put(att.Som_Contact__c, att);
						}
					}
				}
				if (!existingVR) {
					vreport = new Som_Kontaktbericht__c();
				}

				vreport.Name					= event.Subject.length() > 80 ? event.Subject.substring(0,80) : event.Subject;
				vreport.Som_Datum__c			= event.ActivityDateTime;
				vreport.Som_Dauer__c			= event.DurationInMinutes;
				vreport.Som_EreignisReferenz__c	= event.Id;
				vreport.OwnerId					= event.OwnerId;
				vreport.Som_Account__c			= event.AccountId;
				vreport.Som_Contact__c			= event.WhoId;
				vreport.Som_Beschreibung__c		= 'Auftragsentwicklung seit dem letzten Termin: \n\nGeplante Marketingspendings: \n\nProduktlaunches: \n\nKommunikationsstrategie: \n\nCrossmedia: ';

				if (existingVR) {
					update vreport;
				}
				else {
					insert vreport;
				}
		
				for (EventAttendee attendee : [select Id, AttendeeId from EventAttendee where EventId =: event.Id]) {
		
					Som_KontaktberichtContact__c tn = new Som_KontaktberichtContact__c();
		
					if (attendee != null) {
						idString	= attendee.AttendeeId;
		
						if (idString.substring(0,3) == '005') {
							User user = [select CompanyName, FirstName, LastName from User where Id =: attendee.AttendeeId];
		
							if (user != null) {
								if (user.FirstName	== null) {
									user.FirstName	= '';
								}
								if (user.CompanyName	== null) {
									user.CompanyName	= '';
								}
		
								try { 
									Contact contact = [select Id from Contact where LastName =: user.LastName and FirstName =: user.FirstName and Account.Name =: user.CompanyName limit 1];

									if (attendeeByConId != null && attendeeByConId.get(contact.Id) != null) {
										attendeeByConId.remove(contact.Id);
										continue;
									}
									if (contact != null) {
										tn.Som_Contact__c			= contact.Id;
										tn.Som_Kontaktbericht__c	= vreport.Id;
										tnList.add(tn);
									}
								}
								catch (Exception e) {
									setError('An Error occurred. Please contact your Administrator. (' + event.id + ') - '+e.getMessage());
									return null;
								}
							}
						}
						else if (idString.substring(0,3) == '003') {
							
							if (attendeeByConId != null && attendeeByConId.get(idString) != null) {
								attendeeByConId.remove(idString);
								continue;
							}
	
							tn.Som_Contact__c			= attendee.AttendeeId;
							tn.Som_Kontaktbericht__c	= vreport.Id;
							tnList.add(tn);
						}
					}
				}
		
				if (!tnList.isEmpty()) {
					insert tnList;
				}

				if (attendeeByConId != null && !attendeeByConId.isEmpty()) {
					delete attendeeByConId.values();
				}
				return new PageReference('/' + vreport.Id);

				/*
				setError('The Event\'s Account is invalid');
				return null;
				*/
			}
			setError('This Event is invalid');
			return null;
		}
		catch(Exception e) {
			if (vreport != null && vreport.id != null && !existingVR) {
				delete vreport;
			}
			setError('An Error occurred. Please contact your Administrator. (' + event.id + ') - '+e.getMessage());
			return null;
		}
	}

	public class KontaktberichtException extends Exception {}

	public static testMethod void createVisitReportTest() {

		Account acc = [select Id from Account where RecordType.DeveloperName != 'ung_ltiger_Account' limit 1];
	
		Opportunity opp = new Opportunity(
			AccountId = acc.Id,
			Name='Test Opp',
			Probability=1,
			StageName='testPhase',
			Type='New',
			CloseDate=System.today()
			);

		insert opp;
		
		Contact con = new contact(
			LastName='Muster',
			Salutation='Herr',
			Email='test@iaminvalid.invalid',
			AccountId=acc.id);

		insert con;

		Event event_1 = new Event(Type='Visit', StartDateTime=system.now(), DurationInminutes=60, Description='Test für Visitreports', Subject='Test VisitReport', WhatId=acc.Id, WhoId=con.Id);
		insert event_1;
		
		Test.startTest();
		
		ApexPages.Standardcontroller ctrl	= new ApexPages.Standardcontroller(event_1);
		cls_Som_Kontaktbericht kb			= new cls_Som_Kontaktbericht(ctrl);
		kb.createVisitReport();
		
		ApexPages.Standardcontroller ctrl2	= new ApexPages.Standardcontroller(event_1);
		cls_Som_Kontaktbericht kb2			= new cls_Som_Kontaktbericht(ctrl2);
		kb2.createVisitReport();
		
		Test.stopTest();
		
	}
}