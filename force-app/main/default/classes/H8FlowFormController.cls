/**
 * @description       : Meta-driven form flow controller. 
 *                      Responsible for retrieving form metadata (form + sections) 
 *                      from Custom Metadata Types and returning it in JSON format 
 *                      for use in Flow/Aura components.
 *                      This class focuses only on data retrieval and JSON structure,
 *                      not validation logic (that’s handled separately).
 * 
 * @author            : daniel@hyphen8.com
 * @last modified on  : 12-09-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormController {
    
    // Holds the form metadata record being processed
    private static H8_Flow_Form__mdt form;
    
    // Test injection variables (allow stubbing metadata in unit tests)
    public static H8_Flow_Form__mdt formTest;
    public static List<H8_Flow_Form_Section__mdt> formSectionsTest;

    /**
     * @description  Aura-exposed method that retrieves the form metadata 
     *               (form + sections) and serializes it to JSON.
     *               - Used by client-side components to render the structure of a form.
     *               - Handles error catching and returns an error JSON if retrieval fails.
     * 
     * @param   formAPIName        the DeveloperName of the form (H8_Flow_Form__mdt)
     * @param   sectionsToExclude  list of section DeveloperNames that should not be included
     * @return  String             JSON string with form and section details, or error JSON
     */
    @AuraEnabled 
    public static String getForm(String formAPIName, List<String> sectionsToExclude){
        try {
            getFormMeta(formAPIName, sectionsToExclude);
            return generateFormSectionResponse();
        } catch (Exception e){
            return generateErrorResponse(e.getMessage());
        }
    }

    /**
     * @description  Queries the form metadata and related sections. 
     *               - Retrieves a single H8_Flow_Form__mdt by DeveloperName.
     *               - Also retrieves its ordered sections and nested validation records.
     *               - Excludes sections if their DeveloperName is in sectionsToExclude.
     * 
     * @param   formAPIName        the DeveloperName of the form
     * @param   sectionsToExclude  list of section DeveloperNames to filter out
     */
    private static void getFormMeta(String formAPIName, List<String> sectionsToExclude){
        form = Test.isRunningTest() ? formTest : [SELECT Id, MasterLabel, DeveloperName, MasterObject__r.QualifiedAPIName, (SELECT Id, DeveloperName, Flow_API_Name__c, Icon_Name__c, Order__c, MasterLabel, Use_Custom_Label__c, (SELECT Id, DeveloperName FROM H8_Flow_Form_Section_Validations__r) FROM H8_Flow_Form_Sections__r WHERE DeveloperName NOT IN :sectionsToExclude ORDER BY Order__c ASC) FROM H8_Flow_Form__mdt WHERE DeveloperName = :formAPIName WITH SECURITY_ENFORCED LIMIT 1];
    }

    /**
     * @description  Generates the JSON response for a form and its sections. 
     *               - Includes the form developer name, master object, and all sections. 
     *               - Each section includes metadata like label, API name, order, 
     *                 icon details, flow API name, and validation flags. 
     *               - Section labels can be replaced with a custom label if flagged.
     *               - All boolean flags (hasIcon, hasConfiguredValidations, etc.) 
     *                 help the client-side component know what to display.
     * 
     * @return  String  JSON string with form + section metadata
     * 
     * Example structure:
     * {
     *   "success": true,
     *   "formDeveloperName": "My_Form",
     *   "masterObject": "Account",
     *   "sections": [
     *     {
     *       "label": "Contact Details",
     *       "sectionName": "Contact_Section",
     *       "sectionOrder": 1,
     *       "icon": "contact",
     *       "hasIcon": true,
     *       "flow": "Contact_Flow",
     *       "hasValidationError": false,
     *       "hasValidationWarning": false,
     *       "hasValidationSuccess": false,
     *       "hasConfiguredValidations": true,
     *       "id": "m0XYZ0000008Abc..."
     *     }
     *   ]
     * }
     */
    private static String generateFormSectionResponse(){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeBooleanField('success', true);
            gen.writeStringField('formDeveloperName', form.DeveloperName != null ? form.DeveloperName : '');
            gen.writeStringField('masterObject', form.MasterObject__r.QualifiedAPIName != null ? form.MasterObject__r.QualifiedAPIName : '');
            gen.writeFieldName('sections');
            gen.writeStartArray();
            List<H8_Flow_Form_Section__mdt> formSections = Test.isRunningTest() ? formSectionsTest : form.H8_Flow_Form_Sections__r;
            for(H8_Flow_Form_Section__mdt section : formSections){
                gen.writeStartObject();
                    // Section label (custom label if configured, otherwise master label but always ensure master label is provided so we can support multilanguage configurations)
                    gen.writeStringField('customLabel', section.MasterLabel);
                    if(section.Use_Custom_Label__c){
                        String labelValue = Label.get(null, section.MasterLabel);
                        gen.writeStringField('label', labelValue != null ? labelValue : section.MasterLabel);
                    } else {
                        gen.writeStringField('label', section.MasterLabel);
                    }
                    
                    gen.writeStringField('sectionName', section.DeveloperName);
                    gen.writeNumberField('sectionOrder', section.Order__c != null ? section.Order__c : 0);
                    gen.writeStringField('icon', section.Icon_Name__c != null ? section.Icon_Name__c : '');
                    gen.writeBooleanField('hasIcon', section.Icon_Name__c != null);
                    gen.writeStringField('flow', section.Flow_API_Name__c);
                    
                    // Validation flags - defaulted to false here, 
                    // to be updated when validation logic is applied
                    gen.writeBooleanField('hasValidationError', false);
                    gen.writeBooleanField('hasValidationWarning', false);
                    gen.writeBooleanField('hasValidationSuccess', false);

                    // Whether any validations are configured for this section
                    List<H8_Flow_Form_Section_Validation__mdt> validations = section.H8_Flow_Form_Section_Validations__r;
                    gen.writeBooleanField('hasConfiguredValidations', validations.size() > 0);

                    gen.writeIdField('id', section.Id);
                gen.writeEndObject();
            }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
     * @description  Generates a simple error JSON response. 
     *               - Used when an exception occurs during form retrieval.
     * 
     * @param   message  error message to return
     * @return  String   JSON string with success=false and the error message
     * 
     * Example:
     * {
     *   "success": false,
     *   "message": "Form not found"
     * }
     */
    private static String generateErrorResponse(String message){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeBooleanField('success', false);
            gen.writeStringField('message', message);
        gen.writeEndObject();
        return gen.getAsString();
    }
}