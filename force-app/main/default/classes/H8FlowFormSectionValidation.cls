/**
 * @description       : apex controller to support with generating validations for an entire section
 * @author            : daniel@hyphen8.com
 * @last modified on  : 07-10-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormSectionValidation {
    
    private static H8_Flow_Form__mdt formDetails;
    private static Set<String> validationFields = new Set<String>();
    private static SObject currentRecord;
    private static Map<String, List<H8_Flow_Form_Section_Validation__mdt>> sectionValidations = new Map<String, List<H8_Flow_Form_Section_Validation__mdt>>();
    private static Map<String, Object> validationValue = new Map<String, Object>();
    private static Map<String, List<String>> currentErrors = new Map<String, List<String>>();
    private static Map<String, List<String>> flowValidations = new Map<String, List<String>>();
    private static Boolean hasActiveFlowValidations = false;
    

    /**
    * @description              aura method to validate an entire section and display the errors
    * @param                    recordId 
    * @param                    formName 
    * @param                    parentObjectAPIName 
    * @param                    sectionName 
    * @return                   String 
    **/
    @AuraEnabled 
    public static String validatePage(String recordId, String formName, String parentObjectAPIName, String sectionName){
        
        try {
            formDetails = H8FlowFormValidationHelper.getSpecificSectionForm(formName, sectionName);
            getValidationFields();
            currentRecord = H8FlowFormValidationHelper.getProcessingRecord(recordId, parentObjectAPIName, validationFields);
            if(hasActiveFlowValidations) {
                flowValidations = H8FlowFormValidationHelper.getFlowValidations(formDetails.Validation_Flow_API_Name__c, formDetails.DeveloperName, sectionName, null, recordId, new List<String>());     
            }
            validateCurrentRecord();
            return H8FlowFormResponseGenerator.generateFormSectionResponse(true, '', currentErrors, formDetails);
        } catch (Exception e){
            return H8FlowFormResponseGenerator.generateFormSectionResponse(false, e.getLineNumber() + ': ' + e.toString(), currentErrors, null);
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
                String pageName = null != formSectionValidation.Page__c ? formSectionValidation.Page__c : 'NOPAGESCONFIGURED';
                List<H8_Flow_Form_Section_Validation__mdt> validationPages = sectionValidations.containsKey(pageName) ?
                                                                                sectionValidations.get(pageName) :
                                                                                new List<H8_Flow_Form_Section_Validation__mdt>();
                validationPages.add(formSectionValidation);
                sectionValidations.put(pageName, validationPages);
            }
        }
    }

    /**
    * @description      private method to store validation values
    * @param            sectionValidation 
    **/
    private static void storeValidationValue(H8_Flow_Form_Section_Validation__mdt sectionValidation){
        if(null != sectionValidation.Validation_Value__c){
            if(sectionValidation.DataType__c == 'Boolean'){
                validationValue.put(sectionValidation.FieldAPIName__c, Boolean.valueOf(sectionValidation.Validation_Value__c));
            } else if(sectionValidation.DataType__c == 'String'){
                validationValue.put(sectionValidation.FieldAPIName__c, sectionValidation.Validation_Value__c);
            } else if(sectionValidation.DataType__c == 'Integer'){
                validationValue.put(sectionValidation.FieldAPIName__c, Integer.valueOf(sectionValidation.Validation_Value__c));
            } else if(sectionValidation.DataType__c == 'Decimal'){
                validationValue.put(sectionValidation.FieldAPIName__c, Decimal.valueOf(sectionValidation.Validation_Value__c));
            } else {
                validationValue.put(sectionValidation.FieldAPIName__c, sectionValidation.Validation_Value__c);
            }
        }
    }

    /**
    * @description          private method to validate the record against the validation configuration
    **/
    private static void validateCurrentRecord(){
        for(String pageName:sectionValidations.keySet()){
            List<H8_Flow_Form_Section_Validation__mdt> validations = sectionValidations.get(pageName);
            for(H8_Flow_Form_Section_Validation__mdt validation:validations){
                if(validation.IsFlowValidation__c) {
                    handleFlowValidationErrors(validations, validation);
                } else {
                    handleCustomValidationErrors(validation);
                }
            } 
        }
    }

    private static void handleFlowValidationErrors(List<H8_Flow_Form_Section_Validation__mdt> validations, H8_Flow_Form_Section_Validation__mdt validation){
        List<String> validationMessages = flowValidations.get(validation.FlowValidationType__c);
        if(validationMessages != null && validationMessages.size()>0) {
            for(String validationMessage:validationMessages) {
                generateError(validation, validationMessage);
            }
        }
    }

    private static void handleCustomValidationErrors(H8_Flow_Form_Section_Validation__mdt validation){
        Object fieldValue = H8FlowFormValidationHelper.getFieldValue(currentRecord, validation.FieldAPIName__c);
        Object expectedValue = validationValue.containsKey(validation.FieldAPIName__c) ? validationValue.get(validation.FieldAPIName__c) : null;
        if(null == fieldValue || (null != expectedValue && expectedValue != fieldValue)){                   
            generateError(validation, validation.QuestionName__c);
        }
    }

    private static void generateError(H8_Flow_Form_Section_Validation__mdt validation, String errorMessage){
        String pageName = null != validation.Page__c ? validation.Page__c : 'NOPAGESCONFIGURED';
        List<String> pageErrors = currentErrors.containsKey(pageName) ? currentErrors.get(pageName) : new List<String>();
        pageErrors.add(errorMessage);
        currentErrors.put(pageName, pageErrors);
    }
}