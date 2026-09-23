/**
 * @description       : controller class to support the flow form management page - lists a form's sections
 *                       and each section's validations, and resolves the FlowRecord's Lightning record URL for a section's flow
 * @author            : daniel@hyphen8.com
 * @last modified on  : 21-09-2026
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormManagerController {

    public static List<H8_Flow_Form_Section__mdt> testFormSections = new List<H8_Flow_Form_Section__mdt>();
    public static List<H8_Flow_Form_Section_Validation__mdt> testSectionValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
    public static String testFlowRecordId;
    public static List<H8_Flow_Form_Section__mdt> testFlowUsageSections = new List<H8_Flow_Form_Section__mdt>();
    public static List<H8_Flow_Form__mdt> testFlowUsageForms = new List<H8_Flow_Form__mdt>();
    public static List<CustomFieldValue> testFormCustomFields = new List<CustomFieldValue>();
    public static Map<String, List<CustomFieldValue>> testSectionCustomFieldsForForm = new Map<String, List<CustomFieldValue>>();
    public static List<FlowUsageOption> testUsedFlows = new List<FlowUsageOption>();
    public static Boolean testIsProductionOrg = false;

    // fields already surfaced explicitly elsewhere on H8_Flow_Form__mdt - anything else found on the
    // object's describe is assumed to have been added by a consultant/developer and is treated as "custom".
    // note: Schema...fields.getMap().keySet() always returns field api names lower-cased, so this set
    // must be lower-cased too or every real field will incorrectly be treated as "custom"
    @TestVisible
    private static final Set<String> FORM_KNOWN_FIELD_API_NAMES = new Set<String>{
        'id', 'developername', 'masterlabel', 'label', 'language', 'namespaceprefix', 'qualifiedapiname', 'systemmodstamp',
        'masterobject__c', 'status__c', 'type__c', 'validation_flow_api_name__c'
    };

    // same idea as FORM_KNOWN_FIELD_API_NAMES, for H8_Flow_Form_Section__mdt
    @TestVisible
    private static final Set<String> SECTION_KNOWN_FIELD_API_NAMES = new Set<String>{
        'id', 'developername', 'masterlabel', 'label', 'language', 'namespaceprefix', 'qualifiedapiname', 'systemmodstamp',
        'flow_api_name__c', 'h8_flow_form__c', 'icon_name__c', 'order__c', 'use_custom_label__c'
    };

    /**
    * @description          pull back the ordered list of sections for a given flow form
    * @param                formDeveloperName
    * @return               String
    **/
    @AuraEnabled(cacheable=true)
    public static String getFormSections(String formDeveloperName) {
        List<H8_Flow_Form_Section__mdt> sections = !Test.isRunningTest() ? queryFormSections(formDeveloperName) : testFormSections;
        return generateSectionsResponse(sections);
    }

    /**
    * @description          method to pull in the sections for a form via the parent's child relationship,
    *                        since the H8_Flow_Form__c lookup value resolves to the parent Id rather than its DeveloperName
    * @param                formDeveloperName
    * @return               List<H8_Flow_Form_Section__mdt>
    **/
    @TestVisible
    private static List<H8_Flow_Form_Section__mdt> queryFormSections(String formDeveloperName) {
        List<H8_Flow_Form__mdt> forms = [
            SELECT Id,
                (SELECT Id, DeveloperName, MasterLabel, Flow_API_Name__c, Icon_Name__c, Order__c, Use_Custom_Label__c
                    FROM H8_Flow_Form_Sections__r
                    ORDER BY Order__c ASC)
            FROM H8_Flow_Form__mdt
            WHERE DeveloperName = :formDeveloperName
            LIMIT 1
        ];
        return forms.isEmpty() ? new List<H8_Flow_Form_Section__mdt>() : forms[0].H8_Flow_Form_Sections__r;
    }

    /**
    * @description          pull back the ordered list of validations for a given form section
    * @param                sectionDeveloperName
    * @return               String
    **/
    @AuraEnabled(cacheable=true)
    public static String getSectionValidations(String sectionDeveloperName) {
        List<H8_Flow_Form_Section_Validation__mdt> validations = !Test.isRunningTest() ? querySectionValidations(sectionDeveloperName) : testSectionValidations;
        return generateValidationsResponse(validations);
    }

    /**
    * @description          method to pull in the validations for a section via the parent's child relationship,
    *                        since the H8_Flow_Form_Section__c lookup value resolves to the parent Id rather than its DeveloperName
    * @param                sectionDeveloperName
    * @return               List<H8_Flow_Form_Section_Validation__mdt>
    **/
    @TestVisible
    private static List<H8_Flow_Form_Section_Validation__mdt> querySectionValidations(String sectionDeveloperName) {
        List<H8_Flow_Form_Section__mdt> sections = [
            SELECT Id,
                (SELECT Id, DeveloperName, MasterLabel, FieldAPIName__c, QuestionName__c, DataType__c,
                        Validation_Value__c, CustomErrorMessage__c, Disabled__c, Order__c,
                        IsFlowValidation__c, FlowValidationType__c, Page__c
                    FROM H8_Flow_Form_Section_Validations__r
                    ORDER BY Order__c ASC)
            FROM H8_Flow_Form_Section__mdt
            WHERE DeveloperName = :sectionDeveloperName
            LIMIT 1
        ];
        return sections.isEmpty() ? new List<H8_Flow_Form_Section_Validation__mdt>() : sections[0].H8_Flow_Form_Section_Validations__r;
    }

    /**
    * @description          resolve the standard Lightning record URL for the flow's FlowRecord, so an
    *                        admin can jump straight to it regardless of whether it has an active version
    *                        (unlike a Flow Builder deep-link, which only works for an active version).
    *                        This also avoids depending on the unsupported/internal
    *                        /builder_platform_interaction/flowBuilder.app url structure - FlowRecord is a
    *                        real, queryable, documented sObject and /lightning/r/{Object}/{Id}/view is the
    *                        platform's standard supported record-navigation pattern
    * @param                flowApiName
    * @return               String
    **/
    @AuraEnabled
    public static String getFlowRecordUrl(String flowApiName) {
        String flowRecordId = !Test.isRunningTest() ? getFlowRecordId(flowApiName) : testFlowRecordId;
        if (String.isBlank(flowRecordId)) {
            throw new AuraHandledException('No flow was found with API name "' + flowApiName + '".');
        }
        return '/lightning/r/FlowRecord/' + flowRecordId + '/view';
    }

    /**
    * @description          method to live query the FlowRecord id for a flow by its api name
    * @param                flowApiName
    * @return               String
    **/
    @TestVisible
    private static String getFlowRecordId(String flowApiName) {
        List<FlowRecord> records = [
            SELECT Id FROM FlowRecord WHERE ApiName = :flowApiName LIMIT 1
        ];
        return records.isEmpty() ? null : records[0].Id;
    }

    /**
    * @description          pull back every form section and form-level validation flow that references the given flow API name
    * @param                flowApiName
    * @return               String
    **/
    @AuraEnabled(cacheable=true)
    public static String getFlowUsage(String flowApiName) {
        List<H8_Flow_Form_Section__mdt> sectionUsages = !Test.isRunningTest() ? queryFlowUsageSections(flowApiName) : testFlowUsageSections;
        List<H8_Flow_Form__mdt> formUsages = !Test.isRunningTest() ? queryFlowUsageForms(flowApiName) : testFlowUsageForms;
        return generateFlowUsageResponse(sectionUsages, formUsages);
    }

    /**
    * @description          method to find every section referencing the given flow, traversing up to the parent form for its label
    * @param                flowApiName
    * @return               List<H8_Flow_Form_Section__mdt>
    **/
    @TestVisible
    private static List<H8_Flow_Form_Section__mdt> queryFlowUsageSections(String flowApiName) {
        return [
            SELECT DeveloperName, MasterLabel, H8_Flow_Form__r.DeveloperName, H8_Flow_Form__r.MasterLabel
            FROM H8_Flow_Form_Section__mdt
            WHERE Flow_API_Name__c = :flowApiName
            ORDER BY Order__c ASC
        ];
    }

    /**
    * @description          method to find every form using the given flow as its validation flow
    * @param                flowApiName
    * @return               List<H8_Flow_Form__mdt>
    **/
    @TestVisible
    private static List<H8_Flow_Form__mdt> queryFlowUsageForms(String flowApiName) {
        return [
            SELECT DeveloperName, MasterLabel
            FROM H8_Flow_Form__mdt
            WHERE Validation_Flow_API_Name__c = :flowApiName
            ORDER BY MasterLabel ASC
        ];
    }

    /**
    * @description          pull back every distinct flow api name referenced by any form section or form-level
    *                        validation flow, for the Flow Explorer tab's search/typeahead
    * @return               String
    **/
    @AuraEnabled(cacheable=true)
    public static String getUsedFlows() {
        List<FlowUsageOption> flows = !Test.isRunningTest() ? queryUsedFlows() : testUsedFlows;
        return generateUsedFlowsResponse(flows);
    }

    /**
    * @description          method to live query every distinct flow api name in use, resolving each one's
    *                        label from FlowDefinitionView where available
    * @return               List<FlowUsageOption>
    **/
    @TestVisible
    private static List<FlowUsageOption> queryUsedFlows() {
        Set<String> flowApiNames = new Set<String>();
        for (H8_Flow_Form_Section__mdt section : [SELECT Flow_API_Name__c FROM H8_Flow_Form_Section__mdt WHERE Flow_API_Name__c != null]) {
            flowApiNames.add(section.Flow_API_Name__c);
        }
        for (H8_Flow_Form__mdt form : [SELECT Validation_Flow_API_Name__c FROM H8_Flow_Form__mdt WHERE Validation_Flow_API_Name__c != null]) {
            flowApiNames.add(form.Validation_Flow_API_Name__c);
        }
        if (flowApiNames.isEmpty()) {
            return new List<FlowUsageOption>();
        }

        Map<String, String> labelsByApiName = new Map<String, String>();
        for (FlowDefinitionView flowDefinition : [SELECT ApiName, Label FROM FlowDefinitionView WHERE ApiName IN :flowApiNames]) {
            labelsByApiName.put(flowDefinition.ApiName, flowDefinition.Label);
        }

        List<FlowUsageOption> options = new List<FlowUsageOption>();
        for (String flowApiName : flowApiNames) {
            FlowUsageOption option = new FlowUsageOption();
            option.apiName = flowApiName;
            option.label = labelsByApiName.containsKey(flowApiName) ? labelsByApiName.get(flowApiName) : flowApiName;
            options.add(option);
        }
        options.sort();
        return options;
    }

    /**
    * @description          method to generate a json response for used flows
    * @param                flows
    * @return               String
    **/
    private static String generateUsedFlowsResponse(List<FlowUsageOption> flows) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('flows');
        generator.writeStartArray();
        for (FlowUsageOption flow : flows) {
            generator.writeStartObject();
                generator.writeStringField('apiName', flow.apiName);
                generator.writeStringField('label', flow.label);
            generator.writeEndObject();
        }
        generator.writeEndArray();
        generator.writeEndObject();
        return generator.getAsString();
    }

    /**
    * @description          simple wrapper for a flow available for selection in the Flow Explorer tab, sortable by label
    **/
    @TestVisible
    private class FlowUsageOption implements Comparable {
        @TestVisible private String apiName;
        @TestVisible private String label;

        public Integer compareTo(Object compareTo) {
            FlowUsageOption other = (FlowUsageOption)compareTo;
            if (this.label == other.label) {
                return 0;
            }
            return this.label < other.label ? -1 : 1;
        }
    }

    /**
    * @description          method to generate a json response for flow usage
    * @param                sectionUsages
    * @param                formUsages
    * @return               String
    **/
    private static String generateFlowUsageResponse(List<H8_Flow_Form_Section__mdt> sectionUsages, List<H8_Flow_Form__mdt> formUsages) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('usages');
        generator.writeStartArray();
        for (H8_Flow_Form_Section__mdt section : sectionUsages) {
            generator.writeStartObject();
                generator.writeStringField('usageType', 'Section');
                generator.writeStringField('formDeveloperName', nullSafe(section.H8_Flow_Form__r?.DeveloperName));
                generator.writeStringField('formLabel', nullSafe(section.H8_Flow_Form__r?.MasterLabel));
                generator.writeStringField('sectionDeveloperName', section.DeveloperName);
                generator.writeStringField('sectionLabel', section.MasterLabel);
            generator.writeEndObject();
        }
        for (H8_Flow_Form__mdt form : formUsages) {
            generator.writeStartObject();
                generator.writeStringField('usageType', 'Validation Flow');
                generator.writeStringField('formDeveloperName', form.DeveloperName);
                generator.writeStringField('formLabel', form.MasterLabel);
                generator.writeStringField('sectionDeveloperName', '');
                generator.writeStringField('sectionLabel', '');
            generator.writeEndObject();
        }
        generator.writeEndArray();
        generator.writeEndObject();
        return generator.getAsString();
    }

    /**
    * @description          resolve whether this org is a production org (i.e. not a sandbox/scratch org), so the
    *                        Test Mode screen can warn users clearly before they save real data against real records
    * @return               Boolean
    **/
    @AuraEnabled(cacheable=true)
    public static Boolean getIsProductionOrg() {
        return !Test.isRunningTest() ? queryIsProductionOrg() : testIsProductionOrg;
    }

    /**
    * @description          method to live query whether the running org is a sandbox/scratch org
    * @return               Boolean
    **/
    @TestVisible
    private static Boolean queryIsProductionOrg() {
        return ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    /**
    * @description          pull back any fields on H8_Flow_Form__mdt that aren't already known/surfaced
    *                        by this package, so consultant/developer-added custom fields display automatically
    * @param                formDeveloperName
    * @return               String
    **/
    @AuraEnabled(cacheable=true)
    public static String getFormCustomFields(String formDeveloperName) {
        List<CustomFieldValue> customFields = !Test.isRunningTest() ? queryFormCustomFields(formDeveloperName) : testFormCustomFields;
        return generateCustomFieldsResponse(customFields);
    }

    /**
    * @description          method to live query the values of any custom fields found on H8_Flow_Form__mdt
    * @param                formDeveloperName
    * @return               List<CustomFieldValue>
    **/
    @TestVisible
    private static List<CustomFieldValue> queryFormCustomFields(String formDeveloperName) {
        List<String> customFieldApiNames = deriveCustomFieldApiNames(
            Schema.SObjectType.H8_Flow_Form__mdt.fields.getMap().keySet(),
            FORM_KNOWN_FIELD_API_NAMES
        );
        return customFieldApiNames.isEmpty()
            ? new List<CustomFieldValue>()
            : buildCustomFieldValues('H8_Flow_Form__mdt', customFieldApiNames, formDeveloperName);
    }

    /**
    * @description          pull back any fields on H8_Flow_Form_Section__mdt that aren't already known/surfaced
    *                        by this package, for every section under the given form, so the Sections table can
    *                        display them as extra columns rather than requiring a row to be selected first
    * @param                formDeveloperName
    * @return               String
    **/
    @AuraEnabled(cacheable=true)
    public static String getSectionCustomFieldsForForm(String formDeveloperName) {
        Map<String, List<CustomFieldValue>> fieldsBySectionDeveloperName = !Test.isRunningTest()
            ? querySectionCustomFieldsForForm(formDeveloperName)
            : testSectionCustomFieldsForForm;
        return generateSectionCustomFieldsForFormResponse(fieldsBySectionDeveloperName);
    }

    /**
    * @description          method to live query the values of any custom fields found on H8_Flow_Form_Section__mdt,
    *                        for every section belonging to the given form
    * @param                formDeveloperName
    * @return               Map<String, List<CustomFieldValue>>
    **/
    @TestVisible
    private static Map<String, List<CustomFieldValue>> querySectionCustomFieldsForForm(String formDeveloperName) {
        Map<String, List<CustomFieldValue>> fieldsBySectionDeveloperName = new Map<String, List<CustomFieldValue>>();
        List<String> customFieldApiNames = deriveCustomFieldApiNames(
            Schema.SObjectType.H8_Flow_Form_Section__mdt.fields.getMap().keySet(),
            SECTION_KNOWN_FIELD_API_NAMES
        );
        if (customFieldApiNames.isEmpty()) {
            return fieldsBySectionDeveloperName;
        }

        List<H8_Flow_Form__mdt> forms = [
            SELECT Id, (SELECT DeveloperName FROM H8_Flow_Form_Sections__r)
            FROM H8_Flow_Form__mdt
            WHERE DeveloperName = :formDeveloperName
            LIMIT 1
        ];
        if (forms.isEmpty()) {
            return fieldsBySectionDeveloperName;
        }

        List<String> sectionDeveloperNames = new List<String>();
        for (H8_Flow_Form_Section__mdt section : forms[0].H8_Flow_Form_Sections__r) {
            sectionDeveloperNames.add(section.DeveloperName);
        }

        // one bulk query for every section on the form, rather than one query per section
        Map<String, List<CustomFieldValue>> valuesByDeveloperName = buildCustomFieldValuesForDeveloperNames(
            'H8_Flow_Form_Section__mdt', customFieldApiNames, sectionDeveloperNames
        );
        for (String sectionDeveloperName : sectionDeveloperNames) {
            fieldsBySectionDeveloperName.put(sectionDeveloperName,
                valuesByDeveloperName.containsKey(sectionDeveloperName)
                    ? valuesByDeveloperName.get(sectionDeveloperName)
                    : new List<CustomFieldValue>());
        }
        return fieldsBySectionDeveloperName;
    }

    /**
    * @description          method to generate a json response for section custom fields, keyed by section developer name
    * @param                fieldsBySectionDeveloperName
    * @return               String
    **/
    private static String generateSectionCustomFieldsForFormResponse(Map<String, List<CustomFieldValue>> fieldsBySectionDeveloperName) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('sectionCustomFields');
        generator.writeStartObject();
        for (String sectionDeveloperName : fieldsBySectionDeveloperName.keySet()) {
            generator.writeFieldName(sectionDeveloperName);
            generator.writeStartArray();
            for (CustomFieldValue field : fieldsBySectionDeveloperName.get(sectionDeveloperName)) {
                generator.writeStartObject();
                    generator.writeStringField('apiName', field.apiName);
                    generator.writeStringField('label', field.label);
                    generator.writeStringField('dataType', field.dataType);
                    generator.writeStringField('value', field.value);
                generator.writeEndObject();
            }
            generator.writeEndArray();
        }
        generator.writeEndObject();
        generator.writeEndObject();
        return generator.getAsString();
    }

    /**
    * @description          pure filtering logic - given every field api name on an object and the set already
    *                        known/handled by this package, returns the remainder in alphabetical order.
    *                        kept free of any Schema calls so it can be unit tested against fabricated field names
    * @param                allFieldApiNames
    * @param                knownFieldApiNames
    * @return               List<String>
    **/
    @TestVisible
    private static List<String> deriveCustomFieldApiNames(Set<String> allFieldApiNames, Set<String> knownFieldApiNames) {
        List<String> customFieldApiNames = new List<String>();
        for (String fieldApiName : allFieldApiNames) {
            if (!knownFieldApiNames.contains(fieldApiName)) {
                customFieldApiNames.add(fieldApiName);
            }
        }
        customFieldApiNames.sort();
        return customFieldApiNames;
    }

    /**
    * @description          dynamic-SOQL query mechanism - fetches the given record and formats a value for
    *                        each of the given field api names, whatever they turn out to be
    * @param                objectApiName
    * @param                fieldApiNames
    * @param                developerName
    * @return               List<CustomFieldValue>
    **/
    @TestVisible
    private static List<CustomFieldValue> buildCustomFieldValues(String objectApiName, List<String> fieldApiNames, String developerName) {
        Map<String, List<CustomFieldValue>> valuesByDeveloperName = buildCustomFieldValuesForDeveloperNames(
            objectApiName, fieldApiNames, new List<String>{ developerName }
        );
        return valuesByDeveloperName.containsKey(developerName) ? valuesByDeveloperName.get(developerName) : new List<CustomFieldValue>();
    }

    /**
    * @description          bulk dynamic-SOQL query mechanism - fetches every record matching the given developer
    *                        names in a single query and formats a value for each of the given field api names,
    *                        keyed by developer name. Used instead of calling buildCustomFieldValues once per
    *                        record, to avoid a query-per-record pattern when formatting fields for many sections at once
    * @param                objectApiName
    * @param                fieldApiNames
    * @param                developerNames
    * @return               Map<String, List<CustomFieldValue>>
    **/
    @TestVisible
    private static Map<String, List<CustomFieldValue>> buildCustomFieldValuesForDeveloperNames(String objectApiName, List<String> fieldApiNames, List<String> developerNames) {
        Map<String, List<CustomFieldValue>> valuesByDeveloperName = new Map<String, List<CustomFieldValue>>();
        if (developerNames.isEmpty()) {
            return valuesByDeveloperName;
        }
        validateApiName(objectApiName);
        for (String fieldApiName : fieldApiNames) {
            validateApiName(fieldApiName);
        }

        String query = 'SELECT DeveloperName, ' + String.join(fieldApiNames, ', ') + ' FROM ' + objectApiName + ' WHERE DeveloperName IN :developerNames';
        List<SObject> records = Database.query(query);
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        for (SObject record : records) {
            List<CustomFieldValue> fieldValues = new List<CustomFieldValue>();
            for (String fieldApiName : fieldApiNames) {
                fieldValues.add(formatCustomFieldValue(record, fieldApiName, fieldMap.get(fieldApiName).getDescribe()));
            }
            valuesByDeveloperName.put((String)record.get('DeveloperName'), fieldValues);
        }
        return valuesByDeveloperName;
    }

    /**
    * @description          defence-in-depth for the dynamic SOQL above: every value interpolated into the query
    *                        string (object/field api names) must already look like a real api name. In practice
    *                        objectApiName is always a hardcoded literal at the call site and fieldApiNames always
    *                        come from Schema...fields.getMap().keySet(), but since these are reusable private
    *                        helpers this guards against a future caller passing anything else
    * @param                apiName
    **/
    private static void validateApiName(String apiName) {
        if (String.isBlank(apiName) || !Pattern.matches('^[A-Za-z0-9_]+$', apiName)) {
            throw new IllegalArgumentException('"' + apiName + '" is not a valid object/field api name.');
        }
    }

    /**
    * @description          method to format a single field's value for display, regardless of its underlying data type
    * @param                record
    * @param                fieldApiName
    * @param                describeResult
    * @return               CustomFieldValue
    **/
    @TestVisible
    private static CustomFieldValue formatCustomFieldValue(SObject record, String fieldApiName, Schema.DescribeFieldResult describeResult) {
        Object rawValue = record.get(fieldApiName);
        CustomFieldValue fieldValue = new CustomFieldValue();
        fieldValue.apiName = fieldApiName;
        fieldValue.label = describeResult.getLabel();
        fieldValue.dataType = String.valueOf(describeResult.getType());
        fieldValue.value = null == rawValue ? '' : String.valueOf(rawValue);
        return fieldValue;
    }

    /**
    * @description          method to generate a json response for custom fields
    * @param                customFields
    * @return               String
    **/
    private static String generateCustomFieldsResponse(List<CustomFieldValue> customFields) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('customFields');
        generator.writeStartArray();
        for (CustomFieldValue field : customFields) {
            generator.writeStartObject();
                generator.writeStringField('apiName', field.apiName);
                generator.writeStringField('label', field.label);
                generator.writeStringField('dataType', field.dataType);
                generator.writeStringField('value', field.value);
            generator.writeEndObject();
        }
        generator.writeEndArray();
        generator.writeEndObject();
        return generator.getAsString();
    }

    /**
    * @description          simple wrapper for a single dynamically-discovered custom field's display data
    **/
    @TestVisible
    private class CustomFieldValue {
        @TestVisible private String apiName;
        @TestVisible private String label;
        @TestVisible private String dataType;
        @TestVisible private String value;
    }

    /**
    * @description          method to generate a json response for sections
    * @param                sections
    * @return               String
    **/
    private static String generateSectionsResponse(List<H8_Flow_Form_Section__mdt> sections) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('sections');
        generator.writeStartArray();
        for (H8_Flow_Form_Section__mdt section : sections) {
            generator.writeStartObject();
                generator.writeStringField('id', nullSafe(section.Id));
                generator.writeStringField('developerName', section.DeveloperName);
                generator.writeStringField('masterLabel', section.MasterLabel);
                generator.writeStringField('displayName', resolveSectionDisplayName(section));
                generator.writeStringField('flowAPIName', nullSafe(section.Flow_API_Name__c));
                generator.writeStringField('iconName', nullSafe(section.Icon_Name__c));
                generator.writeNumberField('order', nullSafe(section.Order__c));
            generator.writeEndObject();
        }
        generator.writeEndArray();
        generator.writeEndObject();
        return generator.getAsString();
    }

    /**
    * @description          method to resolve the section's display name - when Use_Custom_Label__c is ticked,
    *                        MasterLabel holds the Custom Label API name to resolve rather than literal display text
    * @param                section
    * @return               String
    **/
    private static String resolveSectionDisplayName(H8_Flow_Form_Section__mdt section) {
        if (section.Use_Custom_Label__c && String.isNotBlank(section.MasterLabel)) {
            try {
                String labelValue = System.Label.get(null, section.MasterLabel);
                if (String.isNotBlank(labelValue)) {
                    return labelValue;
                }
            } catch (Exception e) {
                // fall through and use the raw master label below - but log so a genuine label-resolution
                // failure is distinguishable from "the label just doesn't exist" when debugging display issues
                System.debug(LoggingLevel.WARN, 'H8FlowFormManagerController.resolveSectionDisplayName: could not resolve custom label "' + section.MasterLabel + '" - ' + e.getMessage());
            }
        }
        return section.MasterLabel;
    }

    /**
    * @description          method to generate a json response for section validations
    * @param                validations
    * @return               String
    **/
    private static String generateValidationsResponse(List<H8_Flow_Form_Section_Validation__mdt> validations) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('validations');
        generator.writeStartArray();
        for (H8_Flow_Form_Section_Validation__mdt validation : validations) {
            generator.writeStartObject();
                generator.writeStringField('id', nullSafe(validation.Id));
                generator.writeStringField('developerName', validation.DeveloperName);
                generator.writeStringField('masterLabel', validation.MasterLabel);
                generator.writeStringField('fieldAPIName', nullSafe(validation.FieldAPIName__c));
                generator.writeStringField('questionName', nullSafe(validation.QuestionName__c));
                generator.writeStringField('dataType', nullSafe(validation.DataType__c));
                generator.writeStringField('validationValue', nullSafe(validation.Validation_Value__c));
                generator.writeStringField('customErrorMessage', nullSafe(validation.CustomErrorMessage__c));
                generator.writeBooleanField('disabled', validation.Disabled__c);
                generator.writeNumberField('order', nullSafe(validation.Order__c));
                generator.writeBooleanField('isFlowValidation', validation.IsFlowValidation__c);
                generator.writeStringField('flowValidationType', nullSafe(validation.FlowValidationType__c));
                generator.writeStringField('page', nullSafe(validation.Page__c));
            generator.writeEndObject();
        }
        generator.writeEndArray();
        generator.writeEndObject();
        return generator.getAsString();
    }

    /**
    * @description          method to format a string value for json output, coalescing null to an empty string
    * @param                value
    * @return               String
    **/
    private static String nullSafe(String value) {
        return null == value ? '' : value;
    }

    /**
    * @description          method to format a decimal value for json output, coalescing null to 0
    * @param                value
    * @return               Decimal
    **/
    private static Decimal nullSafe(Decimal value) {
        return null == value ? 0 : value;
    }
}
