/**
 * @description       : Invocable utility for packaging Flow record collections
 *                      into a reusable H8FlowFormFlowValidationDataItem JSON payload.
 * @author            : daniel@hyphen8.com
 * @last modified on  : 12-08-2026
 * @last modified by  : OpenAI
**/
public with sharing class H8FlowValidationCollectionJson {

    public class Request {
        @InvocableVariable(required=true)
        public String dataKey;

        @InvocableVariable(required=true)
        public String objectApiName;

        @InvocableVariable(required=true)
        public List<SObject> records;
    }

    public class Response {
        @InvocableVariable
        public String dataKey;

        @InvocableVariable
        public String objectApiName;

        @InvocableVariable
        public Boolean isCollection;

        @InvocableVariable
        public String objectData;
    }

    @InvocableMethod(
        label='Build Flow Validation Collection JSON'
        description='Serializes a Flow record collection into a validation data item payload.'
    )
    public static List<Response> buildJson(List<Request> requests) {
        List<Response> responses = new List<Response>();

        if (requests == null) {
            return responses;
        }

        for (Request requestItem : requests) {
            responses.add(buildResponse(requestItem));
        }

        return responses;
    }

    private static Response buildResponse(Request requestItem) {
        if (requestItem == null) {
            throw new AuraHandledException('A validation data item request is required.');
        }

        if (String.isBlank(requestItem.dataKey)) {
            throw new AuraHandledException('dataKey is required.');
        }

        if (String.isBlank(requestItem.objectApiName)) {
            throw new AuraHandledException('objectApiName is required.');
        }

        if (requestItem.records == null || requestItem.records.isEmpty()) {
            throw new AuraHandledException('records is required.');
        }

        Response responseItem = new Response();
        responseItem.dataKey = requestItem.dataKey;
        responseItem.objectApiName = requestItem.objectApiName;
        responseItem.isCollection = true;
        responseItem.objectData = JSON.serialize(requestItem.records);

        return responseItem;
    }
}
