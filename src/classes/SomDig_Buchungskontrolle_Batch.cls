public with sharing class SomDig_Buchungskontrolle_Batch implements Schedulable {

    public void execute(SchedulableContext SC) {
        startBuchungskontrolle();
    }

    @future(callout=true)
    public static void startBuchungskontrolle() {
        String username = EncodingUtil.urlEncode(Label.BuchungskontrolleSalesforceUsername,'UTF-8');
        String password = EncodingUtil.urlEncode(Label.BuchungskontrolleSalesforcePasswort,'UTF-8');
        String token =    EncodingUtil.urlEncode(Label.BuchungskontrolleSalesforceToken,'UTF-8');
        String endpoint = EncodingUtil.urlEncode(Label.BuchungskontrolleSalesforceUrl,'UTF-8');
        Http binding = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(Label.BuchungskontrolleUrl + '?username=' + username + '&password=' + password + '&token=' + token + '&endpoint=' + endpoint);
        HttpResponse res = binding.send(req);
    }

}