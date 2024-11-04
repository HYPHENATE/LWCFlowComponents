/**
 * @description       : flow form validations helper class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 04-11-2024
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
        return Test.isRunningTest() ? testForm : [SELECT MasterLabel, (SELECT MasterLabel, Order__c,
                                                    (SELECT MasterLabel, CustomErrorMessage__c, Order__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c
                                                        FROM H8_Flow_Form_Section_Validations__r ORDER BY Order__c ASC NULLS LAST)
                                                            FROM H8_Flow_Form_Sections__r ORDER BY Order__c ASC) FROM H8_Flow_Form__mdt WHERE DeveloperName=:formAPIName WITH SECURITY_ENFORCED LIMIT 1];
    }

    /**
    * @description          apex method to return just a specific section within a form
    * @param                formAPIName 
    * @param                sectionName 
    * @return               H8_Flow_Form__mdt 
    **/
    public static H8_Flow_Form__mdt getSpecificSectionForm(String formAPIName, String sectionName){
        return Test.isRunningTest() ? testForm : [SELECT MasterLabel, (SELECT MasterLabel, Order__c,
                                                    (SELECT MasterLabel, CustomErrorMessage__c, Order__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c
                                                        FROM H8_Flow_Form_Section_Validations__r ORDER BY Order__c ASC NULLS LAST)
                                                            FROM H8_Flow_Form_Sections__r WHERE MasterLabel=:sectionName ORDER BY Order__c ASC) FROM H8_Flow_Form__mdt WHERE DeveloperName=:formAPIName WITH SECURITY_ENFORCED LIMIT 1];
    }

    /**
    * @description          apex method to return a specific page within a form
    * @param                formAPIName 
    * @param                pageName 
    * @return               H8_Flow_Form__mdt 
    **/
    public static H8_Flow_Form__mdt getSpecificPageForm(String formAPIName, String pageName){
        return Test.isRunningTest() ? testForm : [SELECT MasterLabel, (SELECT MasterLabel, Order__c,
                                (SELECT MasterLabel, CustomErrorMessage__c, Order__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c
                                    FROM H8_Flow_Form_Section_Validations__r WHERE Page__c=:pageName ORDER BY Order__c ASC NULLS LAST)
                                        FROM H8_Flow_Form_Sections__r ORDER BY Order__c ASC) FROM H8_Flow_Form__mdt WHERE DeveloperName=:formAPIName WITH SECURITY_ENFORCED LIMIT 1];
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
    public static SObject getProcessingRecord(String recordId, String primaryObjectAPIName, Set<String> soqlFields){
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
            SObject parentObject = currentRecord.getSObject(listOfFieldValues[0]);
            return parentObject.get(listOfFieldValues[1]);
        } else {
            return currentRecord.get(fieldAPIName);
        }
    }
}