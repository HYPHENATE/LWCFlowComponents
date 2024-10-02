/**
 * @description       : Sample Description
 * @author            : daniel@hyphen8.com
 * @last modified on  : 02/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormValidationHelper {

    public static H8_Flow_Form__mdt testForm;
    
    public static H8_Flow_Form__mdt getCompleteForm(String formAPIName){
        return Test.isRunningTest() ? testForm : [SELECT MasterLabel, 
                            (SELECT MasterLabel, Order__c,
                                (SELECT MasterLabel, CustomErrorMessage__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c
                                    FROM H8_Flow_Form_Section_Validations__r)
                                        FROM H8_Flow_Form_Sections__r
                                        ORDER BY Order__c ASC)
                                            FROM H8_Flow_Form__mdt
                                                WHERE DeveloperName=:formAPIName
                                                    WITH SECURITY_ENFORCED
                                                    LIMIT 1];
    }

    public static H8_Flow_Form__mdt getSpecificSectionForm(String formAPIName, String sectionName){
        return Test.isRunningTest() ? testForm : [SELECT MasterLabel, 
                            (SELECT MasterLabel, Order__c,
                                (SELECT MasterLabel, CustomErrorMessage__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c
                                    FROM H8_Flow_Form_Section_Validations__r)
                                        FROM H8_Flow_Form_Sections__r
                                        WHERE MasterLabel=:sectionName
                                        ORDER BY Order__c ASC)
                                            FROM H8_Flow_Form__mdt
                                                WHERE DeveloperName=:formAPIName
                                                    WITH SECURITY_ENFORCED
                                                    LIMIT 1];
    }

    public static H8_Flow_Form__mdt getSpecificPageForm(String formAPIName, String pageName){
        return Test.isRunningTest() ? testForm : [SELECT MasterLabel, 
                            (SELECT MasterLabel, Order__c,
                                (SELECT MasterLabel, CustomErrorMessage__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c
                                    FROM H8_Flow_Form_Section_Validations__r WHERE Page__c=:pageName)
                                        FROM H8_Flow_Form_Sections__r
                                        ORDER BY Order__c ASC)
                                            FROM H8_Flow_Form__mdt
                                                WHERE DeveloperName=:formAPIName
                                                    WITH SECURITY_ENFORCED
                                                    LIMIT 1];
    }

    public static SObject getProcessingRecord(String recordId, String primaryObjectAPIName, List<String> soqlFields){
        soqlFields.add('Id');
        String validationFieldOutput = String.join(soqlFields, ',');
        String validationQuery = 'SELECT ' + validationFieldOutput + ' FROM ' + primaryObjectAPIName + ' WHERE Id=:recordId';
        return Database.query(validationQuery);
    }

    public static Object getFieldValue(SObject currentRecord, String fieldAPIName){
        if(fieldAPIName.contains('.')){
            List<String> listOfFieldValues = fieldAPIName.split('\\.');
            String lookupFieldName = getParentLookupFieldAPIName(listOfFieldValues[0]);
            SObject parentObject = currentRecord.getSObject(lookupFieldName);
            return parentObject.get(listOfFieldValues[1]);
        } else {
            return currentRecord.get(fieldAPIName);
        }
    }

    private static String getParentLookupFieldAPIName(String fieldString){
        return fieldString.contains('__r') ? fieldString.replace('__r','__c') : fieldString;
    }
}