@IsTest
private class H8FlowValidationCollectionJsonTest {

    @IsTest
    static void buildJsonForRecordCollection() {
        H8FlowValidationCollectionJson.Request requestItem =
            new H8FlowValidationCollectionJson.Request();
        requestItem.dataKey = 'budgetRecords';
        requestItem.objectApiName = 'Account';
        requestItem.records = new List<SObject>{
            new Account(Name = 'First Record'),
            new Account(Name = 'Second Record')
        };
        List<H8FlowValidationCollectionJson.Response> results =
            H8FlowValidationCollectionJson.buildJson(
                new List<H8FlowValidationCollectionJson.Request>{ requestItem }
            );

        System.assertEquals(1, results.size(), 'One response should be returned.');
        System.assertEquals('budgetRecords', results[0].dataKey, 'The data key should be copied through.');
        System.assertEquals('Account', results[0].objectApiName, 'The collection object API name should be preserved.');
        System.assertEquals(true, results[0].isCollection, 'Collection mode should always be returned.');
        System.assert(results[0].objectData.startsWith('['), 'The payload should be a JSON array.');
        System.assert(results[0].objectData.contains('"Name":"Second Record"'), 'The payload should include all supplied records.');
    }

    @IsTest
    static void buildJsonRejectsMissingRecords() {
        H8FlowValidationCollectionJson.Request requestItem =
            new H8FlowValidationCollectionJson.Request();
        requestItem.dataKey = 'invalid';
        requestItem.objectApiName = 'Account';

        try {
            H8FlowValidationCollectionJson.buildJson(
                new List<H8FlowValidationCollectionJson.Request>{ requestItem }
            );
            System.assert(false, 'An exception should be thrown when records are not provided.');
        } catch (AuraHandledException exceptionValue) {
            System.assertNotEquals(null, exceptionValue, 'The invalid request should raise an AuraHandledException.');
        }
    }
}
