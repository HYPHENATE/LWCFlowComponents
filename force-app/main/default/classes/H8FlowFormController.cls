/**
 * @description       : Meta driven form flow controller
 * @author            : daniel@hyphen8.com
 * @last modified on  : 17-04-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormController {
    
    private static H8_Flow_Form__mdt form;
    public static H8_Flow_Form__mdt formTest;
    public static List<H8_Flow_Form_Section__mdt> formSectionsTest;

    /**
    * @description          aura method to get the form section structure
    * @param                formAPIName 
    * @return               String 
    **/
    @AuraEnabled 
    public static String getForm(String formAPIName){
        try {
            getFormMeta(formAPIName);
            return generateFormSectionResponse();
        } catch (Exception e){
            return generateErrorResponse(e.getMessage());
        }
    }

    /**
    * @description          method to get the selected form and associated form sections in the correct order for processing
    * @param                formAPIName 
    **/
    private static void getFormMeta(String formAPIName){
        form = Test.isRunningTest() ? formTest : [SELECT Id, MasterLabel, DeveloperName,
                                            (SELECT Id, Flow_API_Name__c, Icon_Name__c, Order__c, MasterLabel, Use_Custom_Label__c
                                            FROM H8_Flow_Form_Sections__r
                                            ORDER BY Order__c ASC)
                                            FROM H8_Flow_Form__mdt 
                                            WHERE DeveloperName=:formAPIName 
                                            WITH SECURITY_ENFORCED
                                            LIMIT 1];
    }

    /**
    * @description          method to generate the json response for the form with form sections
    * @return               String 
    **/
    private static String generateFormSectionResponse(){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeBooleanField('success', true);
            gen.writeFieldName('sections');
            gen.writeStartArray();
            List<H8_Flow_Form_Section__mdt> formSections = Test.isRunningTest() ? formSectionsTest : form.H8_Flow_Form_Sections__r;
            for(H8_Flow_Form_Section__mdt section:formSections){
                gen.writeStartObject();
                    if(section.Use_Custom_Label__c){
                        String labelValue = Label.get(null, section.MasterLabel);
                        gen.writeStringField('label', null != labelValue ? labelValue : section.MasterLabel);
                    } else {
                        gen.writeStringField('label', section.MasterLabel);
                    }
                    gen.writeStringField('icon', section.Icon_Name__c != null ? section.Icon_Name__c : '');
                    gen.writeBooleanField('hasIcon', section.Icon_Name__c != null);
                    gen.writeStringField('flow', section.Flow_API_Name__c);
                    gen.writeBooleanField('hasValidationError', false);
                    gen.writeIdField('id', section.Id);
                gen.writeEndObject();
            }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
    * @description          method to generate an error response
    * @param                message 
    * @return               String 
    **/
    private static String generateErrorResponse(String message){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeBooleanField('success', false);
            gen.writeStringField('message', message);
        gen.writeEndObject();
        return gen.getAsString();
    }
}