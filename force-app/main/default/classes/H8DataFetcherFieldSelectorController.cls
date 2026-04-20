/**
* @description       : controller for fetching fields of a specified Salesforce object. It provides a method to retrieve the fields and their metadata, which can be used in the UI for dynamic field selection.
* @author            : daniel@hyphen8.com
* @last modified on  : 13-04-2026
* @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8DataFetcherFieldSelectorController {
    
    /**
    * @description: Retrieves the fields of a specified Salesforce object.
    * @param objectName The name of the Salesforce object to retrieve fields from.
    * @return A list of Field objects representing the fields of the specified object.
    **/
    @AuraEnabled(cacheable=true)
    public static List<Field> getObjectFields(String objectName) {
        List<Field> fields = new List<Field>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        if (globalDescribe.containsKey(objectName)) {
            Schema.DescribeSObjectResult objectDescribe = globalDescribe.get(objectName).getDescribe();
            Map<String, Schema.SObjectField> objectFields = objectDescribe.fields.getMap();

            for (String fieldName : objectFields.keySet()) {
                Schema.SObjectField field = objectFields.get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                Field f = new Field(fieldDescribe.getName(), fieldDescribe.getLabel(), String.valueOf(fieldDescribe.getType()));
                fields.add(f);
            }
        }

        return fields;
    }

    public class Response {
        public String errorMessage;
        public List<Field> fields;
    }

    /**
    * @description: Inner class representing a field of a Salesforce object.
    **/
    public class Field {
        /**
        * @description: The name of the field.
        **/
        @AuraEnabled
        public String name;

        /**
        * @description: The label of the field.
        **/
        @AuraEnabled
        public String label;

        /**
        * @description: The data type of the field.
        **/
        @AuraEnabled
        public String type;
        @AuraEnabled public String parentObjectName;
        @AuraEnabled public String relationshipName;

        /**
        * @description: The constructor for the Field class.
        * @param name The name of the field.
        * @param label The label of the field.
        * @param type The data type of the field.
        **/
        public Field(String name, String label, String type) {
            this.name = name;
            this.label = label;
            this.type = type;
        }
    }
}