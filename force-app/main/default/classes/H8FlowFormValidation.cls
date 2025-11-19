/**
 * @description       : master form flow validation class for validating an entire form submission looking for errors
 * @author            : daniel@hyphen8.com
 * @last modified on  : 07-10-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormValidation {
    
    private static H8_Flow_Form__mdt formDetails;
    private static Set<String> validationFields = new Set<String>();
    private static SObject currentRecord;
    private static Map<String, Map<String, List<H8_Flow_Form_Section_Validation__mdt>>> mapOfValidations = new Map<String, Map<String, List<H8_Flow_Form_Section_Validation__mdt>>>();
    private static Map<String, Map<String, List<String>>> validationErrors = new Map<String, Map<String, List<String>>>();
    private static Map<String, Object> validationValue = new Map<String, Object>();
    private static Map<String, List<String>> flowValidations = new Map<String, List<String>>();
    private static Boolean hasActiveFlowValidations = false;
    

    /**
    * @description          Aura Method to perform validations on flow forms
    * @param                recordId 
    * @param                primaryObjectAPIName 
    * @param                formAPIName 
    * @return               String 
    **/
    @AuraEnabled
    public static String validateCompleteForm(String recordId, String primaryObjectAPIName, String formAPIName, List<String> sectionsToNotDisplay){
        try {
            formDetails = H8FlowFormValidationHelper.getCompleteForm(formAPIName, sectionsToNotDisplay);
            getValidationFields();
            currentRecord = H8FlowFormValidationHelper.getProcessingRecord(recordId, primaryObjectAPIName, validationFields);
            if(hasActiveFlowValidations) {
                flowValidations = H8FlowFormValidationHelper.getFlowValidations(formDetails.Validation_Flow_API_Name__c, formDetails.DeveloperName, null, null, recordId, sectionsToNotDisplay);             
            }
            validateCurrentRecord();
            return H8FlowFormResponseGenerator.generateFormValidationResponse(true, '', validationErrors, formDetails);
        } catch (Exception e) {
            return H8FlowFormResponseGenerator.generateFormValidationResponse(false, e.getLineNumber() + ': ' + e.toString(), validationErrors, null);
        }
    }

    /**
    * @description          private method to store the validation fields and validation values where provided
    **/
    private static void getValidationFields(){
        List<H8_Flow_Form_Section_Validation__mdt> allSectionValidations = [SELECT H8_Flow_Form_Section__c, MasterLabel, Use_Custom_Label__c, CustomErrorMessage__c, 
                                                                                    Order__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c, 
                                                                                    IsFlowValidation__c, FlowValidationType__c 
                                                                                    FROM H8_Flow_Form_Section_Validation__mdt 
                                                                                    WHERE Disabled__c=false 
                                                                                    AND H8_Flow_Form_Section__c In:formDetails.H8_Flow_Form_Sections__r 
                                                                                    WITH SECURITY_ENFORCED
                                                                                    ORDER BY Order__c ASC NULLS LAST];
        SObjectIndex validationsBySection = new SObjectIndex('H8_Flow_Form_Section__c').putAll(allSectionValidations);

        for(H8_Flow_Form_Section__mdt formSection:formDetails.H8_Flow_Form_Sections__r){
            List<H8_Flow_Form_Section_Validation__mdt> formSectionValidations = Test.isRunningTest() ? formSection.H8_Flow_Form_Section_Validations__r : (List<H8_Flow_Form_Section_Validation__mdt>)validationsBySection.getAll(formSection.Id);
            for(H8_Flow_Form_Section_Validation__mdt formSectionValidation:formSectionValidations){
                processFormSectionsValidationRecords(formSection, formSectionValidation);
            }
        }
    }

    private static void processFormSectionsValidationRecords(H8_Flow_Form_Section__mdt formSection, H8_Flow_Form_Section_Validation__mdt formSectionValidation){
        if(!formSectionValidation.IsFlowValidation__c) {                
            validationFields.add(formSectionValidation.FieldAPIName__c);
            storeValidationValue(formSectionValidation);
        } else {
            hasActiveFlowValidations = true;
        }
        String pageName = null != formSectionValidation.Page__c ? formSectionValidation.Page__c : 'NOPAGESCONFIGURED';
        Map<String, List<H8_Flow_Form_Section_Validation__mdt>> validationsPages = mapOfValidations.containsKey(formSection.MasterLabel) ?
                                                                        mapOfValidations.get(formSection.MasterLabel) :
                                                                        new Map<String, List<H8_Flow_Form_Section_Validation__mdt>>();
        List<H8_Flow_Form_Section_Validation__mdt> validationRecords = validationsPages.containsKey(pageName) ?
                                                                        validationsPages.get(pageName) :
                                                                        new List<H8_Flow_Form_Section_Validation__mdt>();
        validationRecords.add(formSectionValidation);
        validationsPages.put(pageName, validationRecords);
        mapOfValidations.put(formSection.MasterLabel, validationsPages);
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
        for(String sectionName:mapOfValidations.keySet()){
            Map<String, List<H8_Flow_Form_Section_Validation__mdt>> pageValidations = mapOfValidations.get(sectionName);
            for(String pageName:pageValidations.keySet()){
                List<H8_Flow_Form_Section_Validation__mdt> validations = pageValidations.get(pageName);
                generateErrorFromSection(validations, sectionName);
            }
        }
    }

    private static void generateErrorFromSection(List<H8_Flow_Form_Section_Validation__mdt> validations, String sectionName){
        for(H8_Flow_Form_Section_Validation__mdt validation:validations){
            if(validation.IsFlowValidation__c) {
                handleFlowValidationErrors(sectionName, validations, validation);              
            } else {
                handleCustomValidationErrors(sectionName, validation);
            }
        } 
    }

    private static void handleFlowValidationErrors(String sectionName, List<H8_Flow_Form_Section_Validation__mdt> validations, H8_Flow_Form_Section_Validation__mdt validation){
        List<String> validationMessages = flowValidations.get(validation.FlowValidationType__c);
        if(validationMessages != null && validationMessages.size()>0) {
            for(String validationMessage:validationMessages) {
                generateError(sectionName, validation, validationMessage);
            }
        }
    }

    private static void handleCustomValidationErrors(String sectionName, H8_Flow_Form_Section_Validation__mdt validation){
        Object fieldValue = H8FlowFormValidationHelper.getFieldValue(currentRecord, validation.FieldAPIName__c);
        Object expectedValue = validationValue.containsKey(validation.FieldAPIName__c) ? validationValue.get(validation.FieldAPIName__c) : null;
        if(null == fieldValue || (null != expectedValue && expectedValue != fieldValue)){
            if(validation.Use_Custom_Label__c){
                String labelValue = Label.get(null, validation.QuestionName__c);
                generateError(sectionName, validation, null != labelValue ? labelValue : validation.QuestionName__c);
            } else {
                generateError(sectionName, validation, validation.QuestionName__c);
            }
        }
    }

    private static void generateError(String sectionName, H8_Flow_Form_Section_Validation__mdt validation, String errorMessage){
        String pageName = null != validation.Page__c ? validation.Page__c : 'NOPAGESCONFIGURED';
        Map<String, List<String>> pageErrors = validationErrors.containsKey(sectionName) ? validationErrors.get(sectionName) : new Map<String, List<String>>();
        List<String> currentErrors = pageErrors.containsKey(pageName) ? pageErrors.get(pageName) : new List<String>();
        currentErrors.add(errorMessage);
        pageErrors.put(pageName, currentErrors);
        validationErrors.put(sectionName, pageErrors);
    }
}