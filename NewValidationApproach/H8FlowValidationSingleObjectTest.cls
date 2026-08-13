@IsTest
private class H8FlowValidationSingleObjectTest {

    @IsTest
    static void buildObjectForSingleRecord() {
        H8FlowValidationSingleObject.Request requestItem =
            new H8FlowValidationSingleObject.Request();
        requestItem.dataKey = 'account';
        requestItem.objectApiName = 'Account';
        requestItem.objectData = '{"Name":"Single Record","AccountNumber":"12345"}';

        List<H8FlowValidationSingleObject.Response> results =
            H8FlowValidationSingleObject.buildObject(
                new List<H8FlowValidationSingleObject.Request>{ requestItem }
            );

        System.assertEquals(1, results.size(), 'One response should be returned.');
        System.assertEquals('account', results[0].dataKey, 'The data key should be copied through.');
        System.assertEquals('Account', results[0].objectApiName, 'The object API name should be preserved.');
        System.assertEquals(false, results[0].isCollection, 'Single object mode should always be returned.');
        System.assertNotEquals(null, results[0].record, 'A record should be returned.');
        System.assertEquals('Single Record', (String)results[0].record.get('Name'), 'The JSON should deserialize into the expected record.');
    }

    @IsTest
    static void buildObjectRejectsMissingObjectData() {
        H8FlowValidationSingleObject.Request requestItem =
            new H8FlowValidationSingleObject.Request();
        requestItem.dataKey = 'invalid';
        requestItem.objectApiName = 'Account';

        try {
            H8FlowValidationSingleObject.buildObject(
                new List<H8FlowValidationSingleObject.Request>{ requestItem }
            );
            System.assert(false, 'An exception should be thrown when objectData is not provided.');
        } catch (AuraHandledException exceptionValue) {
            System.assertNotEquals(null, exceptionValue, 'The invalid request should raise an AuraHandledException.');
        }
    }
}
