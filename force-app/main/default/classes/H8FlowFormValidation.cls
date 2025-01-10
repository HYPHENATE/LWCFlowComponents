/**
 * @description       : master form flow validation class for validating an entire form submission looking for errors
 * @author            : daniel@hyphen8.com
 * @last modified on  : 04-11-2024
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

    /**
    * @description          Aura Method to perform validations on flow forms
    * @param                recordId 
    * @param                primaryObjectAPIName 
    * @param                formAPIName 
    * @return               String 
    **/
    @AuraEnabled
    public static String validateCompleteForm(String recordId, String primaryObjectAPIName, String formAPIName){
        try {
            formDetails = H8FlowFormValidationHelper.getCompleteForm(formAPIName);
            getValidationFields();
            currentRecord = H8FlowFormValidationHelper.getProcessingRecord(recordId, primaryObjectAPIName, validationFields);
            if(formDetails.Validation_Flow_API_Name__c != null) {
                flowValidations = H8FlowFormValidationHelper.getFlowValidations(formDetails.Validation_Flow_API_Name__c, formDetails.DeveloperName, null, null, recordId);     
            }
            validateCurrentRecord();
            return generateResponse(true, '');
        } catch (Exception e) {
            return generateResponse(false, e.getMessage());
        }
    }

    /**
    * @description          private method to store the validation fields and validation values where provided
    **/
    private static void getValidationFields(){
        //DC 10/01/25 Work around to resolve issue where querying all related meta data for forms and sections and validations are ordered only returns the first validation
        // requery all validation for all sections in order and SObjectIndex map the section id which should leave validations for that section in order
        List<H8_Flow_Form_Section_Validation__mdt> allSectionValidations = [SELECT H8_Flow_Form_Section__c, MasterLabel, CustomErrorMessage__c, Order__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c, IsFlowValidation__c, FlowValidationType__c FROM H8_Flow_Form_Section_Validation__mdt WHERE H8_Flow_Form_Section__c In:formDetails.H8_Flow_Form_Sections__r ORDER BY Order__c ASC NULLS LAST];
        //Create SObjectIndex by H8_Flow_Form_Section__c
        SObjectIndex validationsBySection = new SObjectIndex('H8_Flow_Form_Section__c').putAll(allSectionValidations);

        for(H8_Flow_Form_Section__mdt formSection:formDetails.H8_Flow_Form_Sections__r){
            //Old logic to iterate on formSection.H8_Flow_Form_Section_Validations__r
            //List<H8_Flow_Form_Section_Validation__mdt> formSectionValidations = formSection.H8_Flow_Form_Section_Validations__r;
            List<H8_Flow_Form_Section_Validation__mdt> formSectionValidations = Test.isRunningTest() ? formSection.H8_Flow_Form_Section_Validations__r : (List<H8_Flow_Form_Section_Validation__mdt>)validationsBySection.getAll(formSection.Id);
            for(H8_Flow_Form_Section_Validation__mdt formSectionValidation:formSectionValidations){
                if(!formSectionValidation.IsFlowValidation__c) {                
                    validationFields.add(formSectionValidation.FieldAPIName__c);
                    storeValidationValue(formSectionValidation);
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
                List<String> validationMessages = flowValidations.get(validation.FlowValidationType__c);
                if(validationMessages != null && validationMessages.size()>0) {
                    for(String validationMessage:validationMessages) {
                        generateError(sectionName, validation, validationMessage);
                    }
                }                
            } else {
                Object fieldValue = H8FlowFormValidationHelper.getFieldValue(currentRecord, validation.FieldAPIName__c);
                Object expectedValue = validationValue.containsKey(validation.FieldAPIName__c) ? validationValue.get(validation.FieldAPIName__c) : null;
                if(null == fieldValue || (null != expectedValue && expectedValue != fieldValue)){
                    generateError(sectionName, validation, validation.QuestionName__c);
                }
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

    /**
    * @description          private method used to generate the response
    * @param                success 
    * @param                message         
    * @return               String 
    **/
    private static String generateResponse(Boolean success, String message){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeBooleanField('success', success);
            gen.writeStringField('message', message);
            gen.writeBooleanField('hasErrors', validationErrors.size() > 0);
            gen.writeBooleanField('isValid', validationErrors.size() == 0);
            gen.writeFieldName('sections');
            gen.writeStartArray();
            for(String section:validationErrors.keySet()){
                gen.writeStartObject();
                    gen.writeStringField('sectionName', section);
                    Map<String, List<String>> pageErrors = validationErrors.get(section);
                    gen.writeFieldName('pages');
                    gen.writeStartArray();
                        for(String pageName:pageErrors.keySet()){
                            gen.writeStartObject();
                                gen.writeStringField('pageName', pageName);
                                gen.writeFieldName('errors');
                                List<String> errors = pageErrors.get(pageName);
                                gen.writeStartArray();
                                for(String error:errors){
                                    gen.writeStartObject();
                                        gen.writeStringField('questionName', error);
                                    gen.writeEndObject();
                                }
                                gen.writeEndArray();
                            gen.writeEndObject();
                        }
                    gen.writeEndArray();
                gen.writeEndObject();
            }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }
}