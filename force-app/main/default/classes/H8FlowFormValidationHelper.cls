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
        return Test.isRunningTest() ? testForm : [SELECT MasterLabel, DeveloperName, Validation_Flow_API_Name__c, (SELECT MasterLabel, Order__c,
                                                    (SELECT MasterLabel, CustomErrorMessage__c, Order__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c, IsFlowValidation__c, FlowValidationType__c
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
        return Test.isRunningTest() ? testForm : [SELECT MasterLabel, DeveloperName, Validation_Flow_API_Name__c, (SELECT MasterLabel, Order__c,
                                                    (SELECT MasterLabel, CustomErrorMessage__c, Order__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c, IsFlowValidation__c, FlowValidationType__c
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
        return Test.isRunningTest() ? testForm : [SELECT MasterLabel, DeveloperName, Validation_Flow_API_Name__c, (SELECT MasterLabel, Order__c,
                                (SELECT MasterLabel, CustomErrorMessage__c, Order__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c, IsFlowValidation__c, FlowValidationType__c
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

    /**
    * @description          method to return a forms flow validations
    * @param                validationFlowName 
    * @param                flowFormName        
    * @param                flowFormSectionName        
    * @param                flowFormSectionPageName        
    * @param                recordId        
    * @return               Map<String, List<String>> Validations messages mapped to their type
    **/
    public static Map<String, List<String>> getFlowValidations(String validationFlowName, String flowFormName, String flowFormSectionName, String flowFormSectionPageName, String recordId){
        Map<String, Object> params = new Map<String, Object>();
        params.put('recordId', recordId);
        params.put('H8FlowFormName', flowFormName);
        params.put('H8FlowFormSectionName', flowFormSectionName);
        params.put('H8FlowFormSectionPageName', flowFormSectionPageName);
        
        Flow.Interview validationFlow = Flow.Interview.createInterview(validationFlowName, params);
        validationFlow.start();
        List<H8FlowFormFlowValidationResults> validationResults=(List<H8FlowFormFlowValidationResults>)validationFlow.getvariableValue('validationResults');
        if(Test.isRunningTest()) {
            validationResults = H8FlowFormValidationTest.getMockFlowValidationResult();
        }
        Map<String, List<String>> results = new Map<String, List<String>>();
        if(validationResults != null) {
            for(H8FlowFormFlowValidationResults validationResult:validationResults) {
                results.put(validationResult.validationFieldType, validationResult.validationMessages);
            }    
        }        
        return results;
    }
}