@isTest
public class cls_P7S1_Format_AdServerLinking_Test{
    @isTest
    private static void testFormat_AdServerLinking(){
        P7S1_Format__c I_oFormatObj = new P7S1_Format__c();
        I_oFormatObj.P7S1_GueltigVon__c = System.today();
				I_oFormatObj.P7S1_GueltigBis__c = System.today().addDays(1);
        insert I_oFormatObj;

        String I_sRdTypeId = [Select SobjectType, Name From RecordType Where sobjecttype =: 'ADvendio__AdServer_ID__c' AND Name =: 'DFP'].Id;
        System.assert(I_sRdTypeId != null,'Record Type not found');

        ADvendio__AdServer_ID__c I_oAdServerIdObj = new ADvendio__AdServer_ID__c();
        I_oAdServerIdObj.Name = 'adscale';
        I_oAdServerIdObj.RecordTypeId = I_sRdTypeId;
        I_oAdServerIdObj.P7S1_Format__c = I_oFormatObj.Id;
        I_oAdServerIdObj.ADvendio__Type__c = 'Ad Unit';
        insert I_oAdServerIdObj;

        ADvendio__AdServer_ID__c I_oAdServerIdO = new ADvendio__AdServer_ID__c();
        I_oAdServerIdO.Name = 'adscale';
        I_oAdServerIdO.RecordTypeId = I_sRdTypeId;
        I_oAdServerIdO.ADvendio__Type__c = 'Ad Unit';
        insert I_oAdServerIdO;

        ApexPages.CurrentPage().getParameters().put('formatId',I_oFormatObj.Id);
        cls_P7S1_Format_AdServerLinking I_clsOb = new cls_P7S1_Format_AdServerLinking();
        I_clsOb.i_sSearchText = 'adscale';
        I_clsOb.Search();
        PageReference I_pg2 = I_clsOb.Save();
        System.assert(I_pg2 != null);
        PageReference I_pg3 = I_clsOb.Cancel();
        System.assert(I_pg3 != null);

        List<ADvendio__AdServer_ID__c> I_oAdServerList = new List<ADvendio__AdServer_ID__c>();
        for(Integer i = 0;i < 1000;i++){
            ADvendio__AdServer_ID__c I_oAdServerIdOb = new ADvendio__AdServer_ID__c();
            I_oAdServerIdOb.Name = 'test'+i;
            I_oAdServerIdOb.RecordTypeId = I_sRdTypeId;
            I_oAdServerIdOb.ADvendio__Type__c = 'Ad Unit';
            I_oAdServerList.add(I_oAdServerIdOb);
        }
        insert I_oAdServerList;

        cls_P7S1_Format_AdServerLinking I_clsObj = new cls_P7S1_Format_AdServerLinking();
        I_clsObj.i_sSearchText = 't*';
        I_clsObj.Search();
        PageReference I_pg = I_clsObj.Save();
        System.assert(I_pg != null);
        PageReference I_pg1 = I_clsObj.Cancel();
        System.assert(I_pg1 != null);

    }
}