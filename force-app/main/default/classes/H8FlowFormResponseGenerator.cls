/**
 * @description       : Helper class for generating JSON responses for form validation flows.
 *                      This centralizes JSON response creation so the validation logic 
 *                      (H8FlowFormValidation, H8FlowFormSectionValidation, H8FlowFormPageValidation) is not cluttered with JSONGenerator code.
 * @author            : daniel@hyphen8.com
 * @last modified on  : 07-10-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormResponseGenerator {

    private static Map<String, H8_Flow_Form_Section__mdt> mapOfFormSections = new Map<String, H8_Flow_Form_Section__mdt>();
    private static Map<String, String> mapOfFormValidationsLabels = new Map<String, String>();
    
    /**
     * @description  Builds a full validation response for an entire form submission. 
     *               - Includes success status, error state, and nested section/page/error details. 
     *               - The JSON structure looks like:
     *                 {
     *                   "success": true|false,
     *                   "message": "...",
     *                   "hasErrors": true|false,
     *                   "isValid": true|false,
     *                   "sections": [
     *                     {
     *                       "sectionName": "...",
     *                       "pages": [
     *                         {
     *                           "pageName": "...",
     *                           "errors": [
     *                             {"questionName": "..."},
     *                             ...
     *                           ]
     *                         }
     *                       ]
     *                     }
     *                   ]
     *                 }
     * @param   success          whether the validation call itself succeeded
     * @param   message          optional debug or error message
     * @param   validationErrors nested map of errors [section → page → error messages]
     * @return  String           JSON string representation of the validation results
     */
    public static String generateFormValidationResponse(Boolean success, String message, Map<String, Map<String, List<String>>> validationErrors, H8_Flow_Form__mdt formDetails){
        generateMapOfValues(formDetails);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeBooleanField('success', success);
            gen.writeStringField('message', message);
            gen.writeBooleanField('hasErrors', validationErrors.size() > 0);
            gen.writeBooleanField('isValid', validationErrors.size() == 0);
            gen.writeFieldName('sections');
            gen.writeStartArray();
            for(String section:validationErrors.keySet()){
                H8_Flow_Form_Section__mdt formSectionRecord = mapOfFormSections.get(section);
                gen.writeStartObject();
                    gen.writeStringField('sectionName', section);
                    gen.writeStringField('displayLabel', getDisplayLabel(formSectionRecord));
                    Map<String, List<String>> pageErrors = validationErrors.get(section);
                    gen.writeFieldName('pages');
                    gen.writeStartArray();
                        for(String pageName:pageErrors.keySet()){
                            gen.writeStartObject();
                                gen.writeStringField('pageName', pageName);
                                gen.writeStringField('displayLabel', mapOfFormValidationsLabels.containsKey(pageName) ? mapOfFormValidationsLabels.get(pageName) : 'NOPAGESCONFIGURED');
                                gen.writeFieldName('errors');
                                List<String> errors = pageErrors.get(pageName);
                                gen.writeStartArray();
                                for(String error:errors){
                                    gen.writeStartObject();
                                        gen.writeStringField('questionName', null != error ? error : System.Label.H8FFMissingQuestionNameInMetadata);
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

    /**
     * @description  Builds a validation response at the section level. 
     *               - Includes success status and page-level errors only (no nested sections).
     *               - The JSON structure looks like:
     *                 {
     *                   "success": true|false,
     *                   "message": "...",
     *                   "hasErrors": true|false,
     *                   "isValid": true|false,
     *                   "pages": [
     *                     {
     *                       "pageName": "...",
     *                       "errors": [
     *                         {"questionName": "..."},
     *                         ...
     *                       ]
     *                     }
     *                   ]
     *                 }
     * @param   success      whether the validation call itself succeeded
     * @param   message      optional debug or error message
     * @param   currentErrors map of page → error messages for this section
     * @return  String       JSON string representation of the section validation results
     */
    public static String generateFormSectionResponse(Boolean success, String message, Map<String, List<String>> currentErrors, H8_Flow_Form__mdt formDetails){
        generateMapOfValues(formDetails);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeBooleanField('success', success);
            gen.writeStringField('message', message);
            gen.writeBooleanField('hasErrors', currentErrors.size() > 0);
            gen.writeBooleanField('isValid', currentErrors.size() == 0);
            gen.writeFieldName('pages');
            gen.writeStartArray();
            for(String pageName:currentErrors.keySet()){
                gen.writeStartObject();
                    gen.writeStringField('pageName', pageName);
                    gen.writeStringField('displayLabel', mapOfFormValidationsLabels.containsKey(pageName) ? mapOfFormValidationsLabels.get(pageName) : 'NOPAGESCONFIGURED');
                    List<String> pageErrors = currentErrors.get(pageName);
                    gen.writeFieldName('errors');
                    gen.writeStartArray();
                        for(String error:pageErrors){
                            gen.writeStartObject();
                                gen.writeStringField('questionName', null != error ? error : System.Label.H8FFMissingQuestionNameInMetadata);
                            gen.writeEndObject();
                        }
                    gen.writeEndArray();
                gen.writeEndObject();
            }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }
    
    /**
     * @description  Builds a validation response at the page level. 
     *               - Includes success status and a flat list of errors for the page.
     *               - The JSON structure looks like:
     *                 {
     *                   "success": true|false,
     *                   "message": "...",
     *                   "hasValidationErrors": true|false,
     *                   "errors": [
     *                     {"questionName": "..."},
     *                     ...
     *                   ]
     *                 }
     * @param   success        whether the validation call itself succeeded
     * @param   message        optional debug or error message
     * @param   currentErrors  list of error messages for the page
     * @return  String         JSON string representation of the page validation results
     */
    public static String generateFormPageResponse(Boolean success, String message, List<String> currentErrors){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeBooleanField('success', success);
            gen.writeStringField('message', message);
            gen.writeBooleanField('hasValidationErrors', currentErrors.size() > 0);
            gen.writeFieldName('errors');
            gen.writeStartArray();
            for(String error:currentErrors){
                gen.writeStartObject();
                    gen.writeStringField('questionName', null != error ? error : System.Label.H8FFMissingQuestionNameInMetadata);
                gen.writeEndObject();
            }
            gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }

    private static void generateMapOfValues(H8_Flow_Form__mdt formDetails){
        if(null != formDetails){
            for(H8_Flow_Form_Section__mdt formSection:formDetails.H8_Flow_Form_Sections__r){
                mapOfFormSections.put(formSection.MasterLabel, formSection);
                List<H8_Flow_Form_Section_Validation__mdt> sectionValidations = formSection.H8_Flow_Form_Section_Validations__r;
                for(H8_Flow_Form_Section_Validation__mdt sectionValidation:sectionValidations){
                    String pageName = null != sectionValidation.Page__c ? sectionValidation.Page__c : 'NOPAGESCONFIGURED';
                    String pageOutputName = pageName != 'NOPAGESCONFIGURED' ? getCustomLabel(sectionValidation.Use_Custom_Label__c, pageName) : 'NOPAGESCONFIGURED';
                    mapOfFormValidationsLabels.put(pageName, pageOutputName);
                }
            }
        }
    }

    private static String getDisplayLabel(H8_Flow_Form_Section__mdt section){
        return getCustomLabel(section.Use_Custom_Label__c, section.MasterLabel);
    }

    private static String getCustomLabel(Boolean useLabel, String masterLabel){
        return useLabel ? Label.get(null, masterLabel) : masterLabel;
    }
}
