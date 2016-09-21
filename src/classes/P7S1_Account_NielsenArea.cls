public class P7S1_Account_NielsenArea {

    private static List<P7S1_PostalCode2State__c> cachedListPCs {
        get {
            if (cachedListPCs == null) {
                cachedListPCs = [
                    SELECT P7S1_NielsenArea__c, P7S1_PostalCodeFrom__c, P7S1_PostalCodeTo__c
                      FROM P7S1_PostalCode2State__c
                     ORDER BY P7S1_PostalCodeFrom__c
                ];
            }
            return cachedListPCs;
        }
        set;
    }

    public static void setNielsenArea(Map <Id, Account> mapAccount, List <Account> listAccount, Boolean bIsUpdate) {

        for (Account objAcc : listAccount) {

            String sPostalCode = objAcc.BillingPostalCode;

            // If no country, empty nielsen area
            if (objAcc.BillingCountry == null) {
                objAcc.NielsenAreaCode__c = null;
                continue;
            }

            // If country not D, => 'AL'
            if (objAcc.BillingCountry != 'D') {
                objAcc.NielsenAreaCode__c = 'AL';
                continue;
            }


            // Continue if update and postalcode or country didn't change
            if (bIsUpdate){
                if (sPostalCode == mapAccount.get(objAcc.ID).BillingPostalCode && objAcc.BillingCountry == mapAccount.get(objAcc.ID).BillingCountry
                && objAcc.NielsenAreaCode__c == mapAccount.get(objAcc.ID).NielsenAreaCode__c)
                    continue;
            }


            // First reset it, in case it does not find a Nielsen Area
            objAcc.NielsenAreaCode__c = null;

                        // if it is not a valid postal code
            if (!CheckValidPostalCode(sPostalCode)){
                objAcc.NielsenAreaCode__c = '??';
                continue;
            }


            // Get the right Nielsen Area for this postal code
            for (P7S1_PostalCode2State__c p : cachedListPCs) {

                // Convert PostalCodes to numbers to determine nielsen area
                Integer iPostalCode = Integer.valueOf(sPostalCode);
                Integer iFrom       = Integer.valueOf(p.P7S1_PostalCodeFrom__c);
                Integer iTo         = Integer.valueOf(p.P7S1_PostalCodeTo__c);

                // Check if this is the right Intervall
                if (iPostalCode <= iTo && iPostalCode >= iFrom) {
                    objAcc.NielsenAreaCode__c = p.P7S1_NielsenArea__c;
                    break;
                }
            }
        }
    }


    public static Boolean CheckValidPostalCode(String sPostalCode) {
        if(sPostalCode == null) return false;

        return Pattern.matches('[0-9]{5}',sPostalCode);
    }
}