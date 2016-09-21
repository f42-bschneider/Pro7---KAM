@isTest
public class P7S1_Account_NielsenArea_Test{

    public static testMethod void AccountNielsenAreaTest(){
        
        // Create Nielsen Areas
        createTestPostalCode2State(true, '32001', '33829', '2', 'Nordrhein-Westfalen');        
        createTestPostalCode2State(true, '10001', '14330', '5', 'Berlin');        

        
        
        // Test: billing country empty
        Account objAccount1 = cls_P7S1_TestData.createTestAccount(false);
        objAccount1.BillingCountry = null;
        insert objAccount1;

        objAccount1 = [SELECT NielsenAreaCode__c FROM Account WHERE ID = :objAccount1.ID];
        System.assert(objAccount1.NielsenAreaCode__c == null);        
        
        // Test: Country != D
        Account objAccount2 = cls_P7S1_TestData.createTestAccount(false);
        objAccount2.BillingCountry = 'F';
        insert objAccount2;

        objAccount2 = [SELECT NielsenAreaCode__c FROM Account WHERE ID = :objAccount2.ID];
        System.assert(objAccount2.NielsenAreaCode__c == 'AL');                

        
        
        
        // Test: PostalCode null
        Account objAccount3 = cls_P7S1_TestData.createTestAccount(false);
        objAccount3.BillingCountry = 'D';
        objAccount3.BillingPostalCode = null;
        insert objAccount3;

        objAccount3 = [SELECT NielsenAreaCode__c FROM Account WHERE ID = :objAccount3.ID];
        System.assert(objAccount3.NielsenAreaCode__c == '??');             
        
        
        
        // Test: Success Test
        Account objAccount4 = cls_P7S1_TestData.createTestAccount(false);
        objAccount4.BillingCountry = 'D';
        objAccount4.BillingPostalCode = '32002';
        insert objAccount4;

        objAccount4 = [SELECT NielsenAreaCode__c FROM Account WHERE ID = :objAccount4.ID];
        System.assert(objAccount4.NielsenAreaCode__c == '2');
        
        // Update Test
        objAccount4.BillingPostalCode = '10002';
        update objAccount4;
        
        objAccount4 = [SELECT NielsenAreaCode__c FROM Account WHERE ID = :objAccount4.ID];
        System.assert(objAccount4.NielsenAreaCode__c == '5');        
    }
    
    public static P7S1_PostalCode2State__c createTestPostalCode2State(Boolean bIsInsert, String sPostalCodeFrom, String sPostalCodeTo, String sNielsenArea, String sState){
        P7S1_PostalCode2State__c objPC2State = new P7S1_PostalCode2State__c();
        objPC2State.P7S1_PostalCodeFrom__c = sPostalCodeFrom;
        objPC2State.P7S1_PostalCodeTo__c = sPostalCodeTo;           
        objPC2State.P7S1_NielsenArea__c  = sNielsenArea;          
        objPC2State.P7S1_State__c = sState;
        if(bIsInsert) insert objPC2State;
        return objPC2State;
    }
}