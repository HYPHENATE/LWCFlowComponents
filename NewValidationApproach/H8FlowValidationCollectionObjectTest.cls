@IsTest
private class H8FlowValidationCollectionObjectTest {

    @IsTest
    static void buildObjectForRecordCollection() {
        H8FlowValidationCollectionObject.Request requestItem =
            new H8FlowValidationCollectionObject.Request();
        requestItem.dataKey = 'contacts';
        requestItem.objectApiName = 'Contact';
        requestItem.objectData = '[{"FirstName":"Demo","LastName":"Person"},{"FirstName":"Second","LastName":"Person"}]';

        List<H8FlowValidationCollectionObject.Response> results =
            H8FlowValidationCollectionObject.buildObject(
                new List<H8FlowValidationCollectionObject.Request>{ requestItem }
            );

        System.assertEquals(1, results.size(), 'One response should be returned.');
        System.assertEquals('contacts', results[0].dataKey, 'The data key should be copied through.');
        System.assertEquals('Contact', results[0].objectApiName, 'The object API name should be preserved.');
        System.assertEquals(true, results[0].isCollection, 'Collection object mode should always be returned.');
        System.assertEquals(2, results[0].records.size(), 'Both records should be returned.');
        System.assertEquals('Demo', (String)results[0].records[0].get('FirstName'), 'The first record should deserialize correctly.');
        System.assertEquals('Second', (String)results[0].records[1].get('FirstName'), 'The second record should deserialize correctly.');
    }

    @IsTest
    static void buildObjectRejectsNonArrayPayload() {
        H8FlowValidationCollectionObject.Request requestItem =
            new H8FlowValidationCollectionObject.Request();
        requestItem.dataKey = 'invalid';
        requestItem.objectApiName = 'Contact';
        requestItem.objectData = '{"FirstName":"Demo","LastName":"Person"}';

        try {
            H8FlowValidationCollectionObject.buildObject(
                new List<H8FlowValidationCollectionObject.Request>{ requestItem }
            );
            System.assert(false, 'An exception should be thrown when objectData is not a JSON array.');
        } catch (AuraHandledException exceptionValue) {
            System.assertNotEquals(null, exceptionValue, 'The invalid request should raise an AuraHandledException.');
        }
    }
}
