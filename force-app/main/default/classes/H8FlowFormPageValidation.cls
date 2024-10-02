/**
 * @description       : Sample Description
 * @author            : daniel@hyphen8.com
 * @last modified on  : 02/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormPageValidation {

    private static H8_Flow_Form__mdt formDetails;
    private static List<String> validationFields = new List<String>();
    private static SObject currentRecord;
    private static List<H8_Flow_Form_Section_Validation__mdt> pageValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
    private static Map<String, Object> validationValue = new Map<String, Object>();
    private static List<String> currentErrors = new List<String>();
    
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
            getForm(formName, pageName);
            System.debug(formDetails);
            getValidationFields();
            getValidationRecord(recordId, parentObjectAPIName);
            validateCurrentRecord();
            return generateResponse(true, '');
        } catch (Exception e){
            return generateResponse(false, e.getMessage());
        }
    }

    /**
    * @description          private method to get the current form > form section > form section validations
    * @param                formAPIName 
    * @param                pageName
    **/
    private static void getForm(String formAPIName, String pageName){
        formDetails = [SELECT MasterLabel, 
                            (SELECT MasterLabel, Order__c,
                                (SELECT MasterLabel, CustomErrorMessage__c, FieldAPIName__c, QuestionName__c, Validation_Value__c, DataType__c, Page__c
                                    FROM H8_Flow_Form_Section_Validations__r WHERE Page__c=:pageName ORDER BY Page__c ASC)
                                        FROM H8_Flow_Form_Sections__r
                                        ORDER BY Order__c ASC)
                                            FROM H8_Flow_Form__mdt
                                                WHERE DeveloperName=:formAPIName
                                                    WITH SECURITY_ENFORCED
                                                    LIMIT 1];
    }

    /**
    * @description          private method to store the validation fields and validation values where provided
    **/
    private static void getValidationFields(){
        for(H8_Flow_Form_Section__mdt formSection:formDetails.H8_Flow_Form_Sections__r){
            for(H8_Flow_Form_Section_Validation__mdt formSectionValidation:formSection.H8_Flow_Form_Section_Validations__r){
                validationFields.add(formSectionValidation.FieldAPIName__c);
                storeValidationValue(formSectionValidation);
                pageValidations.add(formSectionValidation);
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
    * @description          private method to build the soql query and query out the record we are processing
    * @param                recordId 
    * @param                primaryObjectAPIName 
    **/
    private static void getValidationRecord(String recordId, String primaryObjectAPIName){
        validationFields.add('Id');
        String validationFieldOutput = String.join(validationFields, ',');
        String validationQuery = 'SELECT ' + validationFieldOutput + ' FROM ' + primaryObjectAPIName + ' WHERE Id=:recordId';
        currentRecord = Database.query(validationQuery);
    }

    /**
    * @description          private method to validate the record against the validation configuration
    **/
    private static void validateCurrentRecord(){
        for(H8_Flow_Form_Section_Validation__mdt validation:pageValidations){
            Object fieldValue = getFieldValue(validation.FieldAPIName__c);
            Object expectedValue = validationValue.containsKey(validation.FieldAPIName__c) ? validationValue.get(validation.FieldAPIName__c) : null;
            handleNullFieldValue(fieldValue, validation);
            handleExpectedValue(fieldValue, expectedValue, validation);
        }
    }

    /**
    * @description          private method to handle null field that are configured for validation
    * @param                fieldValue 
    * @param                validation      
    **/
    private static void handleNullFieldValue(Object fieldValue, H8_Flow_Form_Section_Validation__mdt validation){
        if(null == fieldValue){
            String customErrorMessage = null != validation.CustomErrorMessage__c ? validation.CustomErrorMessage__c : 'Missing Value';
            String error = validation.QuestionName__c + '-' + customErrorMessage;
            currentErrors.add(error);
        }
    }

    /**
    * @description          private method to handle validation on field where an expected value is provided 
    * @param                fieldValue 
    * @param                expectedValue       
    * @param                validation 
    **/
    private static void handleExpectedValue(Object fieldValue, Object expectedValue, H8_Flow_Form_Section_Validation__mdt validation){
        if(null != expectedValue && expectedValue != fieldValue){
            String customErrorMessage = null != validation.CustomErrorMessage__c ? validation.CustomErrorMessage__c : 'Missing Value';
            String error = validation.QuestionName__c + '-' + customErrorMessage;
            currentErrors.add(error);
        }
    }

    /**
    * @description          private method to return the value from a lookup field
    * @param                fieldString 
    * @return               String         
    **/
    private static String getParentLookupFieldAPIName(String fieldString){
        return fieldString.contains('__r') ? fieldString.replace('__r','__c') : fieldString;
    }

    /**
    * @description          private method to get a standard field value on the current record
    * @param                fieldAPIName        
    * @return               Object 
    **/
    private static Object getFieldValue(String fieldAPIName){
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
            gen.writeBooleanField('hasValidationErrors', currentErrors.size() > 0);
            gen.writeFieldName('errors');
            gen.writeStartArray();
            for(String error:currentErrors){
                gen.writeStartObject();
                    List<String> errorMessages = error.split('-');
                    gen.writeStringField('questionName', errorMessages[0]);
                    gen.writeStringField('customError', errorMessages[1]);
                gen.writeEndObject();
            }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }
}