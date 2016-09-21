/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* P7S1_OpportunityTeamMember_Handler_Test.cls
* @author       vvonrekowski factory42 GmbH
* @email        vvonrekowski@factory42.com
* @version      V0.1
* @ date        28.10.2015
* @description
* @last change
* @objects     Opportuniy, OpportunityTeamMember
* =================================================================
*/
@isTest
private class P7S1_OpportunityTeamMember_Handler_Test {

    /*
    @isTest static void testCreateAnalystOpportunity() {
            Test.startTest();
            Account a = cls_P7S1_TestData.createTestAccount(true);
            Opportunity o = cls_P7S1_TestData.createTestOpportunity(false,a);
            o.RecordTypeID = [select id from RecordType where SobjectType = 'Opportunity' and developername = :P7S1_OpportunityTeamMember_Handler.RECTYP_OPP].id;
            insert o;
            system.assertEquals(1,[select count() from OpportunityTeamMember where OpportunityID = :o.id]);
            Test.stopTest();
    }
    */


}