/**
 * @description       : Invocable utility for converting a validation data item JSON payload
 *                      back into a single Flow record.
 * @author            : daniel@hyphen8.com
 * @last modified on  : 12-08-2026
 * @last modified by  : OpenAI
**/
public with sharing class H8FlowValidationSingleObject {

    public class Request {
        @InvocableVariable(required=true)
        public String dataKey;

        @InvocableVariable(required=true)
        public String objectApiName;

        @InvocableVariable(required=true)
        public String objectData;
    }

    public class Response {
        @InvocableVariable
        public String dataKey;

        @InvocableVariable
        public String objectApiName;

        @InvocableVariable
        public Boolean isCollection;

        @InvocableVariable
        public SObject record;
    }

    @InvocableMethod(
        label='Build Flow Validation Single Object'
        description='Deserializes a validation data item payload into a single Flow record.'
    )
    public static List<Response> buildObject(List<Request> requests) {
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
        validateRequest(requestItem);

        Type objectType = resolveType(requestItem.objectApiName);
        SObject parsedRecord = (SObject)JSON.deserialize(requestItem.objectData, objectType);

        Response responseItem = new Response();
        responseItem.dataKey = requestItem.dataKey;
        responseItem.objectApiName = requestItem.objectApiName;
        responseItem.isCollection = false;
        responseItem.record = parsedRecord;

        return responseItem;
    }

    private static void validateRequest(Request requestItem) {
        if (requestItem == null) {
            throw new AuraHandledException('A validation data item request is required.');
        }

        if (String.isBlank(requestItem.dataKey)) {
            throw new AuraHandledException('dataKey is required.');
        }

        if (String.isBlank(requestItem.objectApiName)) {
            throw new AuraHandledException('objectApiName is required.');
        }

        if (String.isBlank(requestItem.objectData)) {
            throw new AuraHandledException('objectData is required.');
        }
    }

    private static Type resolveType(String objectApiName) {
        Type objectType = Type.forName('Schema.' + objectApiName);
        if (objectType == null) {
            throw new AuraHandledException('Unknown objectApiName: ' + objectApiName);
        }
        return objectType;
    }
}
