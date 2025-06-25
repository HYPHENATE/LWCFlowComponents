/**
 * @description       : controller class to support with the screen for selection a flow form to clone
 * @author            : daniel@hyphen8.com
 * @last modified on  : 25-06-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormCloneController {

    private static List<H8_Flow_Form__mdt> flowForms;
    public static List<H8_Flow_Form__mdt> testFlowForms = new List<H8_Flow_Form__mdt>();
    
    /**
    * @description          pull back a list of flow forms
    * @return               String 
    **/
    @AuraEnabled 
    public static String getFlowForms() {
        getFlowFormsMetadata();
        return generateResponse();
    }

    /**
    * @description          method to pull in the actual metadata
    **/
    private static void getFlowFormsMetadata(){
        flowForms = !Test.isRunningTest() ? [SELECT Id, MasterLabel, DeveloperName, Type__c, Status__c, Validation_Flow_API_Name__c FROM H8_Flow_Form__mdt] : testFlowForms;
    }

    /**
    * @description          method to generate a json response
    * @return               String 
    **/
    private static String generateResponse(){
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('forms');
        generator.writeStartArray();
        for(H8_Flow_Form__mdt flowForm : flowForms){
            generator.writeStartObject();
                generator.writeStringField('masterLabel', flowForm.MasterLabel);
                generator.writeStringField('developerName', flowForm.DeveloperName);
                generator.writeStringField('type', null != flowForm.Type__c ? flowForm.Type__c : '');
                generator.writeStringField('status', null != flowForm.Status__c ? flowForm.Status__c : '');
                generator.writeStringField('validationFlowAPIName', null != flowForm.Validation_Flow_API_Name__c ? flowForm.Validation_Flow_API_Name__c : '');
            generator.writeEndObject();
        }
        generator.writeEndArray();
        generator.writeEndObject();
        return generator.getAsString();
    }
}