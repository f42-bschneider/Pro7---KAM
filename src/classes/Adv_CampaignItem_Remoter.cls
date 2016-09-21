// Class for KV 02429
// Remote button for: Submit_to_AdServerCustom
global with sharing class Adv_CampaignItem_Remoter {
    
    public ID campaignID { get; set; }

    public Adv_CampaignItem_Remoter(){
        campaignID = apexpages.currentpage().getparameters().get('mcID');
    }
    
    @RemoteAction
    global static String checkAvailability(String recordIDs) {
        
        String result = '';
        
        List<ID> setCampIDs = recordIDs.split(',');
        
        // History vom startdate für Step 8 benötigt.
        List<ADvendio__Campaign_Item__c> listCI = new List<ADvendio__Campaign_Item__c>([SELECT Name, RecordType.DeveloperName, ADvendio__Days__c, SomDig_Positionsnr__c, SomDig_DurationAtBooking__c, ADvendio__LastBookingProcess__c, ADvendio__LastAvailabilityForecast__c, SomDig_LastOptimizationActivationDate__c, ADvendio__BookingQuantity__c,ADvendio__Availability__c, ADvendio__Billing_category__c, ADvendio__Media_Campaign__r.SomDig_Verfuegbarkeitsrelevant__c , SomDig_PositionStatus__c, ADvendio__Rate_Discount_4_Name__c, ADvendio__Media_Campaign__r.RecordType.Name, 
                                                                                       (SELECT CreatedDate FROM Histories WHERE Field = 'ADvendio__from_Date__c')
                                                                                        FROM ADvendio__Campaign_Item__c WHERE ID IN :setCampIDs]);
        
        

        ////// Pre-check, bei einer Position Sonderrabatt?
        for(ADvendio__Campaign_Item__c o : listCI){
            System.Debug('####' + o.ADvendio__Media_Campaign__r.RecordType.Name);        
            String sRabatt = o.ADvendio__Rate_Discount_4_Name__c;
            if((sRabatt == 'Nachlieferung' || sRabatt == 'Kompensation' || sRabatt == 'Storno mit Leistungsfluss' || sRabatt == 'Storno ohne Leistungsfluss') && o.ADvendio__Media_Campaign__r.RecordType.Name == 'Angebot')
                return 'Bei mindestens einer Position ist ein unzulässiger Sonderrabatt hinterlegt.';    
        }

        
        ////// Criteria 1: ist Auftragstyp der betroffenden Kampagne "Verfügbarkeitsrelevant"? -> wenn nein, übermitteln
        System.Debug('###Step1');
        if(!listCI[0].ADvendio__Media_Campaign__r.SomDig_Verfuegbarkeitsrelevant__c)
            return 'success';
            
            
        ////// Criteria 2: haben alle Positionen im Angebotsstatus eine Positionsnummer ungleich Null und 0?    
        for(ADvendio__Campaign_Item__c o : listCI){
            if(o.ADvendio__Media_Campaign__r.RecordType.Name == 'Angebot' && (o.SomDig_Positionsnr__c == null || o.SomDig_Positionsnr__c == '0'))
                return 'Bitte erst Dokument erstellen.';
        }


        ////// Criteria 3: Positionsstatus "An Adserver übermitteln"? -> wenn nein, stop
        System.Debug('###Step3');        
        for(ADvendio__Campaign_Item__c o : listCI)
            if(!(o.SomDig_PositionStatus__c == 'An Adserver übermitteln' || o.SomDig_PositionStatus__c == 'NonAdserver'))
                result += 'Die Kampagnenposition ' + o.Name  + ' ist nicht im Status "An Adserver übermitteln".';

        if(result != '')
            return result;



        ////// Criteria 4: Ist mindestens eine Abrechnugsart CPM? -> wenn nein, stop
        System.Debug('###Step4');
        List<ADvendio__Campaign_Item__c> listCICPM = new List<ADvendio__Campaign_Item__c>();
        Set<ID> setCPMIDs = new Set<ID>();
        for (ADvendio__Campaign_Item__c o : listCI)
            if(o.ADvendio__Billing_category__c == 'CPM'){
                listCICPM.add(o);        
                setCPMIDs.add(o.ID);
            }

        if(listCICPM.isEmpty())
            return 'success';
        
        
        //////// Ab hier weiter mit CMPs

        
        // Criteria 5: Gab es eine Optimierung in den letzten 24h
        System.Debug('###Step4');     
        Datetime dt = System.now().addDays(-1);
        Set<ID> setOptimizedCIs = new Set<ID>();
        
        // Get CIs which are optimized
        /*for(ADvendio__OptimizingChange__c o : [SELECT ID, ADvendio__CampaignItem__c FROM ADvendio__OptimizingChange__c WHERE 
                                               ADvendio__OptimizingVersion__r.ADvendio__DateOfActivation__c != null AND 
                                               ADvendio__OptimizingVersion__r.ADvendio__DateOfActivation__c > :dt AND 
                                               ADvendio__CampaignItem__c IN :setCPMIDs])
            setOptimizedCIs.add(o.ADvendio__CampaignItem__c);
          */  

            
        List<ADvendio__Campaign_Item__c> listCPMNotOptimized = new List<ADvendio__Campaign_Item__c>();                    
        for (ADvendio__Campaign_Item__c o : listCICPM)
            if(o.SomDig_LastOptimizationActivationDate__c == null || o.SomDig_LastOptimizationActivationDate__c < dt)
                listCPMNotOptimized.add(o);        
        
        // Wenn keine nicht Optimiert wurde
        if(listCPMNotOptimized.isEmpty())
            return 'success';
            
 
        //////// Ab hier weiter mit CPMs (listCPMNotOptimized)        
        
        
        // Criteria 6: Verfügbarkeitsabfrage durchgeführt?
        System.Debug('###Step5');        
        for(ADvendio__Campaign_Item__c o : listCPMNotOptimized)
            if(o.ADvendio__Availability__c == null)
                result += 'Verfügbarkeitsabfrage nicht durchgeführt bei ' + o.Name + '.\n';

        if(result != '')
            return result;        
        
       
        
        // Criteria 7: Verfügbarkeitsabfrage <3h?
        System.Debug('###Step6');        
        for(ADvendio__Campaign_Item__c o : listCPMNotOptimized)
            if(o.RecordType.DeveloperName != 'Packet' && o.ADvendio__LastAvailabilityForecast__c.addHours(3) < System.now() )
                result += 'Verfügbarkeitsabfrage ist älter als 3 Stunden bei: ' + o.Name  + '.\n';

        if(result != '')
            return result;                
            
            

        // Criteria 8: ADvendio__LastAvailabilityForecast__c
        //ADvendio__BookingQuantity__c - ADvendio__Availability__c <= 0
        System.Debug('###Step7');        
        List<ADvendio__Campaign_Item__c> listNoAvailability = new List<ADvendio__Campaign_Item__c>();                    
        for (ADvendio__Campaign_Item__c o : listCPMNotOptimized){
            if(o.ADvendio__BookingQuantity__c > o.ADvendio__Availability__c)
                listNoAvailability.add(o);                        
        }
        if(listNoAvailability.isEmpty())
            return 'success';        

        
        
        //////// Ab hier weiter mit listNoAvailability
        
        
        // Criteria 9: gibt es ein letztes Datum der Durchbuchung? wenn ja, wurde die laufzeit verlängert? 
        // nur wenn alle verlängert übergeben
        // ansonsten weiter        
        System.Debug('###Step8');                
        
        Integer iNumberOfIncreasedDates = 0;
        for (ADvendio__Campaign_Item__c o : listNoAvailability){            
            if(o.ADvendio__LastBookingProcess__c != null) {           
                
                Boolean bDurationNotChangedAfterLastBookingProcess = false;
                for(ADvendio__Campaign_Item__History h : o.Histories)
                    if(h.CreatedDate > o.ADvendio__LastBookingProcess__c)
                        bDurationNotChangedAfterLastBookingProcess = false;
            
                if(o.SomDig_DurationAtBooking__c > o.ADvendio__Days__c && bDurationNotChangedAfterLastBookingProcess)
                    iNumberOfIncreasedDates++;               
            }
        }
        

        if(iNumberOfIncreasedDates == listNoAvailability.size())
            return 'success';  



        // Criteria 10: is Teamlead
        System.Debug('###Step9');                
        List<Group> listGroup = new List<Group>([SELECT ID FROM Group WHERE Name = 'SomDig_TeamLead' LIMIT 1]);
        Set<ID> setUsersinGroup = GetUserIdsFromGroup(listGroup[0].ID);
        if(setUsersinGroup.contains(UserInfo.getUserId()))
            return 'success';  

        
        return 'Für eine der Positionen ist nicht ausreichend Verfügbarkeit vorhanden.';
    }
    
    public static Set<id> GetUserIdsFromGroup(Id groupId){
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        
        for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId]){
            if (((String)m.UserOrGroupId).startsWith(userType))
                result.add(m.UserOrGroupId);
            else if (((String)m.UserOrGroupId).startsWith(groupType))
                result.addAll(GetUSerIdsFromGroup(m.UserOrGroupId));

        }
        return result;  
    }   
}