/**
 * @description       : Apex controller for display page level validation errors within a flow
 * @author            : daniel@hyphen8.com
 * @last modified on  : 10-09-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormPageValidation {

    private static H8_Flow_Form__mdt formDetails;
    private static Set<String> validationFields = new Set<String>();
    private static SObject currentRecord;
    private static List<H8_Flow_Form_Section_Validation__mdt> pageValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
    private static Map<String, Object> validationValue = new Map<String, Object>();
    private static List<String> currentErrors = new List<String>();
    private static Map<String, List<String>> flowValidations = new Map<String, List<String>>();
    private static Boolean hasActiveFlowValidations = false;
    
    
    /**
    * @description              aura method to validate an individual page and display the errors
    * @param                    recordId 
    * @param                    formName 
    * @param                    parentObjectAPIName 
    * @param                    pageName 
    * @return                   String 
    **/
    @AuraEnabled 
    public static String validatePage(String recordId, String formName, String parentObjectAPIName, String pageName){
        try {
            formDetails = H8FlowFormValidationHelper.getSpecificPageForm(formName, pageName);
            getValidationFields();
            currentRecord = H8FlowFormValidationHelper.getProcessingRecord(recordId, parentObjectAPIName, validationFields);
            if(hasActiveFlowValidations) {
                flowValidations = H8FlowFormValidationHelper.getFlowValidations(formDetails.Validation_Flow_API_Name__c, formDetails.DeveloperName, null, pageName, recordId, new List<String>());     
            }
            validateCurrentRecord();
            return H8FlowFormResponseGenerator.generateFormPageResponse(true, '', currentErrors);
        } catch (Exception e){
            return H8FlowFormResponseGenerator.generateFormPageResponse(false, e.getLineNumber() + ': ' + e.toString(), currentErrors);
        }
    }

    /**
    * @description          private method to store the validation fields and validation values where provided
    **/
    private static void getValidationFields(){
        for(H8_Flow_Form_Section__mdt formSection:formDetails.H8_Flow_Form_Sections__r){
            for(H8_Flow_Form_Section_Validation__mdt formSectionValidation:formSection.H8_Flow_Form_Section_Validations__r){
                if(!formSectionValidation.IsFlowValidation__c) {
                    validationFields.add(formSectionValidation.FieldAPIName__c);
                    storeValidationValue(formSectionValidation);
                } else {
                    hasActiveFlowValidations = true;
                }
                pageValidations.add(formSectionValidation);
            }
        }
    }

    /**
    * @description      private method to store validation values
    * @param            pageValidation 
    **/
    private static void storeValidationValue(H8_Flow_Form_Section_Validation__mdt pageValidation){
        if(null != pageValidation.Validation_Value__c){
            if(pageValidation.DataType__c == 'Boolean'){
                validationValue.put(pageValidation.FieldAPIName__c, Boolean.valueOf(pageValidation.Validation_Value__c));
            } else if(pageValidation.DataType__c == 'String'){
                validationValue.put(pageValidation.FieldAPIName__c, pageValidation.Validation_Value__c);
            } else if(pageValidation.DataType__c == 'Integer'){
                validationValue.put(pageValidation.FieldAPIName__c, Integer.valueOf(pageValidation.Validation_Value__c));
            } else if(pageValidation.DataType__c == 'Decimal'){
                validationValue.put(pageValidation.FieldAPIName__c, Decimal.valueOf(pageValidation.Validation_Value__c));
            } else {
                validationValue.put(pageValidation.FieldAPIName__c, pageValidation.Validation_Value__c);
            }
        }
    }

    /**
    * @description          private method to validate the record against the validation configuration
    **/
    private static void validateCurrentRecord(){
        for(H8_Flow_Form_Section_Validation__mdt validation:pageValidations){
            if(validation.IsFlowValidation__c) {
                handleFlowValidationErrors(validation);              
            } else {
                handleCustomValidationErrors(validation);
            }
        } 
    }

    private static void handleFlowValidationErrors(H8_Flow_Form_Section_Validation__mdt validation){
        List<String> validationMessages = flowValidations.get(validation.FlowValidationType__c);
        if(validationMessages != null && validationMessages.size()>0) {
            for(String validationMessage:validationMessages) {
                currentErrors.add(validationMessage);
            }
        }
    }

    private static void handleCustomValidationErrors(H8_Flow_Form_Section_Validation__mdt validation){
        Object fieldValue = H8FlowFormValidationHelper.getFieldValue(currentRecord, validation.FieldAPIName__c);
        Object expectedValue = validationValue.containsKey(validation.FieldAPIName__c) ? validationValue.get(validation.FieldAPIName__c) : null;
        if(null == fieldValue || (null != expectedValue && expectedValue != fieldValue)){
            currentErrors.add(validation.QuestionName__c);
        }
    }
}