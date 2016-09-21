@isTest
public class SomTv_KundeAgenturBez_ValidateData_Test{

  private static final string VALIDATION_DUPLICATE_KABEZ_IN_LIST  = 'Kunde-Agentur-Beziehung gibt es bereits';
  private static final string VALIDATION_DUPLICATE_KABEZ_IN_SF  = 'Kunde-Agentur-Beziehung gibt es bereits';

  public static testMethod void testValidation() {
    Account acc  = new Account(Name='Testaccount GmbH', ProRex_Rolle__c='Kunde', SomTv_HilfsfeldProRexRolle__c='Kunde', Som_Rechtsform__c='GmbH');
    insert acc;
    
    SomTV_KundeAgenturBeziehung__c kaBez1  = new SomTV_KundeAgenturBeziehung__c(Kunde__c=acc.Id, GueltigVon__c=system.today(), Gueltigbis__c=system.today()+2);
    SomTV_KundeAgenturBeziehung__c kaBez2  = new SomTV_KundeAgenturBeziehung__c(Kunde__c=acc.Id, GueltigVon__c=system.today());
    SomTV_KundeAgenturBeziehung__c kaBez3  = new SomTV_KundeAgenturBeziehung__c(Kunde__c=acc.Id, GueltigVon__c=system.today()-2, Gueltigbis__c=system.today()-1);
    
    try {
      insert new List<SomTV_KundeAgenturBeziehung__c>{kaBez1,kaBez2,kaBez3};
    }
    catch (Exception e) {
      system.assert(e.getMessage().contains(VALIDATION_DUPLICATE_KABEZ_IN_LIST));
    }
    
    insert kaBez1;
    try {
      insert(kaBez2);
    }
    catch (Exception e) {
      system.assert(e.getMessage().contains(VALIDATION_DUPLICATE_KABEZ_IN_SF));
    }
    
    update kaBez1;
    
    delete kaBez1;
    
    undelete kaBez1;
    
  }
}