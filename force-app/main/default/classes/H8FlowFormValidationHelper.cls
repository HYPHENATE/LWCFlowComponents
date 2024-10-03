/**
 * @description       : flow form validations helper class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 03/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormValidationHelper {

    public static H8_Flow_Form__mdt testForm;
    
    /**
    * @description          apex method to return a complete form for processing all validations 
    * @param                formAPIName 
    * @return               H8_Flow_Form__mdt 
    **/
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

    /**
    * @description          apex method to return just a specific section within a form
    * @param                formAPIName 
    * @param                sectionName 
    * @return               H8_Flow_Form__mdt 
    **/
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

    /**
    * @description          apex method to return a specific page within a form
    * @param                formAPIName 
    * @param                pageName 
    * @return               H8_Flow_Form__mdt 
    **/
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

    /**
    * @description          apex method to build the soql query and pull out the record for processing
    * @param                recordId 
    * @param                primaryObjectAPIName 
    * @param                soqlFields 
    * @return               SObject        
    **/

    //TODO UPDATE List<String> soqlFields to be a Set
    //Suppress SOQLInjection
    public static SObject getProcessingRecord(String recordId, String primaryObjectAPIName, List<String> soqlFields){
        soqlFields.add('Id');
        String validationFieldOutput = String.join(soqlFields, ',');
        String validationQuery = 'SELECT ' + validationFieldOutput + ' FROM ' + primaryObjectAPIName + ' WHERE Id=:recordId';
        return Database.query(String.escapeSingleQuotes(validationQuery));
    }

    /**
    * @description          method to get a field value
    * @param                currentRecord 
    * @param                fieldAPIName        
    * @return               Object 
    **/
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

    /**
    * @description          method to get the parent lookup field
    * @param                fieldString 
    * @return               String 
    **/
    private static String getParentLookupFieldAPIName(String fieldString){
        return fieldString.contains('__r') ? fieldString.replace('__r','__c') : fieldString;
    }
}