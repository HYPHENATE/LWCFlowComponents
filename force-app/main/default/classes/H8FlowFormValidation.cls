/**
 * @description       : master form flow validation class for validating an entire form submission looking for errors
 * @author            : daniel@hyphen8.com
 * @last modified on  : 03-10-2024
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormValidation {
    
    private static H8_Flow_Form__mdt formDetails;
    private static Set<String> validationFields = new Set<String>();
    private static SObject currentRecord;
    private static Map<String, Map<String, List<H8_Flow_Form_Section_Validation__mdt>>> mapOfValidations = new Map<String, Map<String, List<H8_Flow_Form_Section_Validation__mdt>>>();
    private static Map<String, Map<String, List<String>>> validationErrors = new Map<String, Map<String, List<String>>>();
    private static Map<String, Object> validationValue = new Map<String, Object>();

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
        for(H8_Flow_Form_Section__mdt formSection:formDetails.H8_Flow_Form_Sections__r){
            for(H8_Flow_Form_Section_Validation__mdt formSectionValidation:formSection.H8_Flow_Form_Section_Validations__r){
                validationFields.add(formSectionValidation.FieldAPIName__c);
                storeValidationValue(formSectionValidation);
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
                for(H8_Flow_Form_Section_Validation__mdt validation:validations){
                    Object fieldValue = H8FlowFormValidationHelper.getFieldValue(currentRecord, validation.FieldAPIName__c);
                    Object expectedValue = validationValue.containsKey(validation.FieldAPIName__c) ? validationValue.get(validation.FieldAPIName__c) : null;
                    if(null == fieldValue || (null != expectedValue && expectedValue != fieldValue)){
                        generateError(sectionName, validation);
                    }
                } 
            }
        }
    }

    private static void generateError(String sectionName, H8_Flow_Form_Section_Validation__mdt validation){
        String pageName = null != validation.Page__c ? validation.Page__c : 'NOPAGESCONFIGURED';
        Map<String, List<String>> pageErrors = validationErrors.containsKey(sectionName) ? validationErrors.get(sectionName) : new Map<String, List<String>>();
        List<String> currentErrors = pageErrors.containsKey(pageName) ? pageErrors.get(pageName) : new List<String>();
        currentErrors.add(validation.QuestionName__c);
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