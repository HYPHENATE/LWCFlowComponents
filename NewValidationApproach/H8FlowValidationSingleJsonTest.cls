@IsTest
private class H8FlowValidationSingleJsonTest {

    @IsTest
    static void buildJsonForSingleRecord() {
        H8FlowValidationSingleJson.Request requestItem =
            new H8FlowValidationSingleJson.Request();
        requestItem.dataKey = 'masterRecord';
        requestItem.objectApiName = 'Account';
        requestItem.record = new Account(Name = 'Single Record');

        List<H8FlowValidationSingleJson.Response> results =
            H8FlowValidationSingleJson.buildJson(
                new List<H8FlowValidationSingleJson.Request>{ requestItem }
            );

        System.assertEquals(1, results.size(), 'One response should be returned.');
        System.assertEquals('masterRecord', results[0].dataKey, 'The data key should be copied through.');
        System.assertEquals('Account', results[0].objectApiName, 'The object API name should be preserved.');
        System.assertEquals(false, results[0].isCollection, 'Single-record mode should always be returned.');
        System.assert(results[0].objectData.startsWith('{'), 'The payload should be a single JSON object.');
        System.assert(results[0].objectData.contains('"Name":"Single Record"'), 'The supplied record should be serialized.');
    }

    @IsTest
    static void buildJsonRejectsMissingRecord() {
        H8FlowValidationSingleJson.Request requestItem =
            new H8FlowValidationSingleJson.Request();
        requestItem.dataKey = 'invalid';
        requestItem.objectApiName = 'Account';

        try {
            H8FlowValidationSingleJson.buildJson(
                new List<H8FlowValidationSingleJson.Request>{ requestItem }
            );
            System.assert(false, 'An exception should be thrown when record is not provided.');
        } catch (AuraHandledException exceptionValue) {
            System.assertNotEquals(null, exceptionValue, 'The invalid request should raise an AuraHandledException.');
        }
    }
}
