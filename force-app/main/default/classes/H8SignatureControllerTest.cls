/**
 * @description       : H8SignatureController test class for testing the signature upload functionality
 * @author            : daniel@hyphen8.com
 * @last modified on  : 17-07-2025
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8SignatureControllerTest {
    
    static TestRecordSource testRecordSource = new TestRecordSource();

    @isTest 
    static void testFileUploadSuccess(){

        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
        .asVariant('FormValidation')
        .withInsert();

        Test.startTest();
            String recordId = account.Id;
            String signatureName = 'TestSignature';
            String dataUrl = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR422NgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgY';
            String contentVersionId = H8SignatureController.processSignature(recordId, signatureName, dataUrl);
            System.assertNotEquals(null, contentVersionId, 'Content Version ID should not be null');
        Test.stopTest();
    }

    @isTest 
    static void testFileUploadError(){

        Test.startTest();
            try {
                String recordId = '001000000000001'; // Invalid record ID
                String signatureName = 'TestSignature';
                String dataUrl = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR422Ng';
                String contentVersionId = H8SignatureController.processSignature(recordId, signatureName, dataUrl);
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Script-thrown exception'), 'Expected exception message not found');
            }
        Test.stopTest();
    }

    @isTest 
    static void testFileGetSuccess(){

        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
        .asVariant('FormValidation')
        .withInsert();
        String recordId = account.Id;
        String signatureName = 'TestSignature';
        String dataUrl = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR422NgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgYGBgY';
        String contentVersionId = H8SignatureController.processSignature(recordId, signatureName, dataUrl);

        Test.startTest();
            String base64Body = H8SignatureController.getBase64Image(contentVersionId);
            System.assertNotEquals(null, base64Body, 'we always expect the body to be returned here');
        Test.stopTest();

    }

    @isTest 
    static void testFileGetFailure(){
        Test.startTest();
            try {
                String base64Body = H8SignatureController.getBase64Image('dsdfasdasdadas');
            } catch (Exception e){
                System.debug(e.getMessage());
                System.assert(e.getMessage().contains('Invalid'), 'Expected exception message not found');
            }
        Test.stopTest();
    }
}