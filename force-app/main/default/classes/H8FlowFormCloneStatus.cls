/**
 * @description       : method that is used to check the status of the metadata deployment
 * @author            : daniel@hyphen8.com
 * @last modified on  : 26-06-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormCloneStatus {
    
    @AuraEnabled
    public static String checkDeployStatus(String deploymentId, Boolean includeDetails) {
        String metadataEndpoint = System.URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/m/64.0';
        String sessionId = UserInfo.getSessionId();

        String body = '<?xml version="1.0" encoding="UTF-8"?>'
            + '<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
            + 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
            + 'xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">'
            + '<env:Header>'
            + '<SessionHeader xmlns="http://soap.sforce.com/2006/04/metadata">'
            + '<sessionId>' + sessionId + '</sessionId>'
            + '</SessionHeader>'
            + '</env:Header>'
            + '<env:Body>'
            + '<checkDeployStatus xmlns="http://soap.sforce.com/2006/04/metadata">'
            + '<asyncProcessId>' + deploymentId + '</asyncProcessId>'
            + '<includeDetails>' + includeDetails + '</includeDetails>'
            + '</checkDeployStatus>'
            + '</env:Body>'
            + '</env:Envelope>';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(metadataEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '""');
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new CalloutException('Failed to call Metadata API: ' + res.getBody());
        }

        String metadataNamespace = 'http://soap.sforce.com/2006/04/metadata';

        Dom.Document doc = new Dom.Document();
        doc.load(res.getBody());

        Dom.XmlNode root = doc.getRootElement();

        Dom.XmlNode bodyNode = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XmlNode responseNode = bodyNode.getChildElement('checkDeployStatusResponse', metadataNamespace);
        Dom.XmlNode resultNode = responseNode.getChildElement('result', metadataNamespace);
        Dom.XmlNode statusNode = resultNode.getChildElement('status', metadataNamespace);

        String status = statusNode.getText();
        return status;
    }
}