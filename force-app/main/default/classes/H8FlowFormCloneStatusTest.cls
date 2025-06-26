/**
 * @description       : H8FlowFormCloneStatus test class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 26-06-2025
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8FlowFormCloneStatusTest {
    
    private class MockMetadataCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setStatusCode(200);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?>'
                + '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">'
                + '  <env:Body>'
                + '    <checkDeployStatusResponse xmlns="http://soap.sforce.com/2006/04/metadata">'
                + '      <result>'
                + '        <status>Succeeded</status>'
                + '      </result>'
                + '    </checkDeployStatusResponse>'
                + '  </env:Body>'
                + '</env:Envelope>');
            return res;
        }
    }

    @isTest
    static void testCheckDeployStatus_Success() {
        Test.setMock(HttpCalloutMock.class, new MockMetadataCallout());
        
        Test.startTest();
            String status = H8FlowFormCloneStatus.checkDeployStatus('1234567890', true);
            System.assertEquals('Succeeded', status, 'Status should match mock response');
        Test.stopTest();
        
    }

    private class MockErrorCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    @isTest
    static void testCheckDeployStatus_Error() {
        Test.setMock(HttpCalloutMock.class, new MockErrorCallout());
        
        Test.startTest();
            try {
                String status = H8FlowFormCloneStatus.checkDeployStatus('fail-id', false);
                System.assert(false, 'Expected exception not thrown');
            } catch (CalloutException ex) {
                System.assert(ex.getMessage().contains('Failed to call Metadata API'), 'Exception should match expected message');
            }
        Test.stopTest();
    }
}