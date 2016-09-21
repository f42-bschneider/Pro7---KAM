/*
KV 03080
*/
public class Adv_OptimizingChange_Handler{

    public static List<ADvendio__OptimizingChange__c> listNewOCs;

    // Creating an Optimizing Change Object
    public static ADvendio__OptimizingChange__c createOC (ID ciID, ID optiID, String sField, String sOrigValue, String sOptiValue){
        ADvendio__OptimizingChange__c objOC = new ADvendio__OptimizingChange__c();
        objOC.ADvendio__CampaignItem__c = ciID;
        objOC.ADvendio__OptimizingVersion__c = optiID;
        objOC.ADvendio__FieldName__c = sField;
        objOC.ADvendio__OriginalValue__c = sOrigValue;
        objOC.ADvendio__OptimizedValue__c = sOptiValue;

        return objOC;
    }


    // Creating an Optimizing Change Object for new Position
    public static ADvendio__OptimizingChange__c createOC (ID ciID, ID optiID, String sField, String sOrigValue, String sOptiValue, String ciIdentifier){
        ADvendio__OptimizingChange__c objOC = new ADvendio__OptimizingChange__c();
        objOC.ADvendio__CampaignItem__c = ciID;
        objOC.ADvendio__OptimizingVersion__c = optiID;
        objOC.ADvendio__FieldName__c = sField;
        objOC.ADvendio__OriginalValue__c = sOrigValue;
        objOC.ADvendio__OptimizedValue__c = sOptiValue;
        objOC.ADvendio__NewCiIdentifier__c = ciIdentifier;

        return objOC;
    }

    // Map CampaignItemID with Map of Fieldname & Optimizing change for existing CIs
    public static Map<ID, Map<String, ADvendio__OptimizingChange__c>> getCIOptiMap(List<ADvendio__OptimizingChange__c> lstNewItems){

        Map<ID, Map<String, ADvendio__OptimizingChange__c>> mapCIOpti = new Map<ID, Map<String, ADvendio__OptimizingChange__c>>();
        for(ADvendio__OptimizingChange__c o : lstNewItems){
            if(!mapCIOpti.containsKey(o.ADvendio__CampaignItem__c))
                mapCIOpti.put(o.ADvendio__CampaignItem__c, new Map<String, ADvendio__OptimizingChange__c>{o.ADvendio__FieldName__c => o});
            else
                mapCIOpti.get(o.ADvendio__CampaignItem__c).put(o.ADvendio__FieldName__c, o);
        }

        return mapCIOpti;
    }



    // Map CampaignItemID with Map of Fieldname & Optimizing change for New
    public static Map<ID, Map<String, ADvendio__OptimizingChange__c>> getCIOptiMapNewOnly(List<ADvendio__OptimizingChange__c> lstNewItems){

        Map<ID, Map<String, ADvendio__OptimizingChange__c>> mapCIOpti = new Map<ID, Map<String, ADvendio__OptimizingChange__c>>();
        for(ADvendio__OptimizingChange__c o : lstNewItems){
            if(o.ADvendio__NewCiIdentifier__c == null) continue;
            if(!mapCIOpti.containsKey(o.ADvendio__NewCiIdentifier__c))
                mapCIOpti.put(o.ADvendio__NewCiIdentifier__c, new Map<String, ADvendio__OptimizingChange__c>{o.ADvendio__FieldName__c => o});
            else
                mapCIOpti.get(o.ADvendio__NewCiIdentifier__c).put(o.ADvendio__FieldName__c, o);
        }

        return mapCIOpti;
    }


    // Map CampaignItemID with Map of Fieldname & Optimizing change for all CIs
    public static Map<ID, Map<String, ADvendio__OptimizingChange__c>> getCIOptiMapAll(List<ADvendio__OptimizingChange__c> lstNewItems){

        Map<ID, Map<String, ADvendio__OptimizingChange__c>> mapCIOpti = new Map<ID, Map<String, ADvendio__OptimizingChange__c>>();
        for(ADvendio__OptimizingChange__c o : lstNewItems){
            ID identifier = o.ADvendio__NewCiIdentifier__c != null ? o.ADvendio__NewCiIdentifier__c :  o.ADvendio__CampaignItem__c;

            if(!mapCIOpti.containsKey(identifier))
                mapCIOpti.put(identifier, new Map<String, ADvendio__OptimizingChange__c>{o.ADvendio__FieldName__c => o});
            else
                mapCIOpti.get(identifier).put(o.ADvendio__FieldName__c, o);
        }

        return mapCIOpti;
    }


    /** Returns true if the list of OptimizingChanges represent a single OptimizingVersion */
    public static Boolean isSingleOptimizingVersion(List<ADvendio__OptimizingChange__c> listOCs) {
        Set<Id> ovIdsSet = new Set<Id>();
        for (ADvendio__OptimizingChange__c oc : listOCs) {
            ovIdsSet.add(oc.ADvendio__OptimizingVersion__c);
        }
        return ovIdsSet.size() == 1;
    }


    // TODO: in TestData auslagern
    public static ADvendio__OptimizingVersion__c optimizingVersion_TestData;
    public static ADvendio__OptimizingChange__c optimizingChange_TestData;
    public static ADvendio__OptimizingVersion__c createTestOptimizingVersion(Boolean isInsert){
        optimizingVersion_TestData = new ADvendio__OptimizingVersion__c();
        if (isInsert) insert optimizingVersion_TestData;
        return optimizingVersion_TestData;
    }
    public static ADvendio__OptimizingChange__c createTestOptimizingChange(Boolean isInsert, ADvendio__OptimizingVersion__c objOV, ADvendio__Campaign_Item__c objCI){
        optimizingChange_TestData = new ADvendio__OptimizingChange__c();
        optimizingChange_TestData.ADvendio__OptimizingVersion__c = objOV.Id;
        optimizingChange_TestData.ADvendio__CampaignItem__c = objCI.Id;
        if (isInsert) insert optimizingChange_TestData;
        return optimizingChange_TestData;
    }

}