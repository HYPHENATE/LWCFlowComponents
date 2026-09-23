/**
 * @description       : H8FlowFormManagerController test class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 22-09-2026
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8FlowFormManagerControllerTest {

    @isTest
    static void testGetFormSectionsNoData(){
        H8FlowFormManagerController.testFormSections = new List<H8_Flow_Form_Section__mdt>();

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getFormSections('SomeForm');
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            System.assertEquals(true, mapOfObject.containsKey('sections'), 'we always expect sections to be returned here');
            List<Object> sections = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('sections')));
            System.assertEquals(0, sections.size(), 'we expect 0 sections to be returned');
        Test.stopTest();
    }

    @isTest
    static void testGetFormSectionsWithData(){
        List<H8_Flow_Form_Section__mdt> testFormSections = new List<H8_Flow_Form_Section__mdt>();
        testFormSections.add((H8_Flow_Form_Section__mdt)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'childSection')
            .addFieldValue('DeveloperName', 'childSection')
            .addFieldValue('Flow_API_Name__c', 'sampleflowname')
            .addFieldValue('Icon_Name__c', 'utility:icon')
            .addFieldValue('Order__c', 10)
            .getSingleMockMetaData());

        H8FlowFormManagerController.testFormSections = testFormSections;

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getFormSections('TestForm');
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            System.assertEquals(true, mapOfObject.containsKey('sections'), 'we always expect sections to be returned here');
            List<Object> sections = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('sections')));
            System.assertEquals(1, sections.size(), 'we expect 1 section to be returned');
            Map<String, Object> section = (Map<String, Object>)sections[0];
            System.assertEquals('childSection', section.get('displayName'), 'we expect the raw master label to be used as the display name when Use_Custom_Label__c is false');
        Test.stopTest();
    }

    @isTest
    static void testGetFormSectionsWithCustomLabelDisplayName(){
        List<H8_Flow_Form_Section__mdt> testFormSections = new List<H8_Flow_Form_Section__mdt>();
        testFormSections.add((H8_Flow_Form_Section__mdt)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'H8FormManagerSectionsCardTitle')
            .addFieldValue('DeveloperName', 'childSection')
            .addFieldValue('Flow_API_Name__c', 'sampleflowname')
            .addFieldValue('Order__c', 10)
            .addFieldValue('Use_Custom_Label__c', true)
            .getSingleMockMetaData());

        H8FlowFormManagerController.testFormSections = testFormSections;

        String customLabelValue = System.Label.H8FormManagerSectionsCardTitle;

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getFormSections('TestForm');
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            List<Object> sections = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('sections')));
            Map<String, Object> section = (Map<String, Object>)sections[0];
            System.assertEquals(customLabelValue, section.get('displayName'), 'we expect the resolved custom label value to be used as the display name');
        Test.stopTest();
    }

    @isTest
    static void testGetSectionValidationsNoData(){
        H8FlowFormManagerController.testSectionValidations = new List<H8_Flow_Form_Section_Validation__mdt>();

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getSectionValidations('SomeSection');
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            System.assertEquals(true, mapOfObject.containsKey('validations'), 'we always expect validations to be returned here');
            List<Object> validations = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('validations')));
            System.assertEquals(0, validations.size(), 'we expect 0 validations to be returned');
        Test.stopTest();
    }

    @isTest
    static void testGetSectionValidationsWithData(){
        List<H8_Flow_Form_Section_Validation__mdt> testSectionValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
        testSectionValidations.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'childValidation')
            .addFieldValue('DeveloperName', 'childValidation')
            .addFieldValue('CustomErrorMessage__c', 'customErrorMessage')
            .addFieldValue('DataType__c', 'String')
            .addFieldValue('Disabled__c', false)
            .addFieldValue('FieldAPIName__c', 'FieldAPIName__c')
            .addFieldValue('Order__c', 10)
            .addFieldValue('QuestionName__c', 'questionName')
            .addFieldValue('Validation_Value__c', 'validationValue')
            .addFieldValue('IsFlowValidation__c', false)
            .addFieldValue('FlowValidationType__c', '')
            .addFieldValue('Page__c', 'Page 1')
            .getSingleMockMetaData());

        H8FlowFormManagerController.testSectionValidations = testSectionValidations;

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getSectionValidations('TestSection');
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            System.assertEquals(true, mapOfObject.containsKey('validations'), 'we always expect validations to be returned here');
            List<Object> validations = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('validations')));
            System.assertEquals(1, validations.size(), 'we expect 1 validation to be returned');
            Map<String, Object> validation = (Map<String, Object>)validations[0];
            System.assertEquals(false, validation.get('isFlowValidation'), 'we expect isFlowValidation to be returned as false');
            System.assertEquals('Page 1', validation.get('page'), 'we expect the page value to be returned');
        Test.stopTest();
    }

    @isTest
    static void testGetSectionValidationsWithFlowValidation(){
        List<H8_Flow_Form_Section_Validation__mdt> testSectionValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
        testSectionValidations.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'flowValidation')
            .addFieldValue('DeveloperName', 'flowValidation')
            .addFieldValue('IsFlowValidation__c', true)
            .addFieldValue('FlowValidationType__c', 'RequiredFieldCheck')
            .addFieldValue('Order__c', 10)
            .getSingleMockMetaData());

        H8FlowFormManagerController.testSectionValidations = testSectionValidations;

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getSectionValidations('TestSection');
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            List<Object> validations = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('validations')));
            Map<String, Object> validation = (Map<String, Object>)validations[0];
            System.assertEquals(true, validation.get('isFlowValidation'), 'we expect isFlowValidation to be returned as true');
            System.assertEquals('RequiredFieldCheck', validation.get('flowValidationType'), 'we expect the flow validation type to be returned');
        Test.stopTest();
    }

    @isTest
    static void testGetFlowUsageNoData(){
        H8FlowFormManagerController.testFlowUsageSections = new List<H8_Flow_Form_Section__mdt>();
        H8FlowFormManagerController.testFlowUsageForms = new List<H8_Flow_Form__mdt>();

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getFlowUsage('sharedFlow');
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            System.assertEquals(true, mapOfObject.containsKey('usages'), 'we always expect usages to be returned here');
            List<Object> usages = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('usages')));
            System.assertEquals(0, usages.size(), 'we expect 0 usages to be returned');
        Test.stopTest();
    }

    @isTest
    static void testGetFlowUsageWithSectionAndFormUsage(){
        Map<String, Object> parentFormRelationship = new Map<String, Object>{
            'attributes' => new Map<String, Object>{ 'type' => 'H8_Flow_Form__mdt' },
            'DeveloperName' => 'ValidationFormDevName',
            'MasterLabel' => 'ValidationFormLabel'
        };
        
        H8_Flow_Form_Section__mdt sectionUsage = (H8_Flow_Form_Section__mdt)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'UsageSection')
            .addFieldValue('DeveloperName', 'UsageSection')
            .addFieldValue('Flow_API_Name__c', 'sharedFlow')
            .addFieldValue('Order__c', 10)
            .addFieldValue('H8_Flow_Form__r', parentFormRelationship)
            .getSingleMockMetaData();

        H8_Flow_Form__mdt formUsage = (H8_Flow_Form__mdt)new MockMetaManager('H8_Flow_Form__mdt')
            .addFieldValue('MasterLabel', 'ValidationFormLabel')
            .addFieldValue('DeveloperName', 'ValidationFormDevName')
            .addFieldValue('Validation_Flow_API_Name__c', 'sharedFlow')
            .getSingleMockMetaData();

        H8FlowFormManagerController.testFlowUsageSections = new List<H8_Flow_Form_Section__mdt>{ sectionUsage };
        H8FlowFormManagerController.testFlowUsageForms = new List<H8_Flow_Form__mdt>{ formUsage };

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getFlowUsage('sharedFlow');
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            List<Object> usages = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('usages')));
            System.assertEquals(2, usages.size(), 'we expect 2 usages to be returned');

            Map<String, Object> firstUsage = (Map<String, Object>)usages[0];
            System.assertEquals('Section', firstUsage.get('usageType'), 'we expect the section usage to be returned first');
            System.assertEquals('UsageSection', firstUsage.get('sectionLabel'), 'we expect the section label to be returned');
            System.assertEquals('ValidationFormLabel', firstUsage.get('formLabel'), 'we expect the parent form label to be resolved via H8_Flow_Form__r');
            System.assertEquals('ValidationFormDevName', firstUsage.get('formDeveloperName'), 'we expect the parent form developer name to be resolved via H8_Flow_Form__r');

            Map<String, Object> secondUsage = (Map<String, Object>)usages[1];
            System.assertEquals('Validation Flow', secondUsage.get('usageType'), 'we expect the validation flow usage to be returned second');
            System.assertEquals('ValidationFormLabel', secondUsage.get('formLabel'), 'we expect the form label to be returned');
        Test.stopTest();
    }


    @isTest
    static void testGetFlowRecordUrlWithMatch(){
        H8FlowFormManagerController.testFlowRecordId = '2aFRR00000000001AA';

        Test.startTest();
            String url = H8FlowFormManagerController.getFlowRecordUrl('sampleflowname');
            System.assertEquals('/lightning/r/FlowRecord/2aFRR00000000001AA/view', url, 'we expect the standard Lightning record url to be built from the FlowRecord id');
        Test.stopTest();
    }

    @isTest
    static void testGetFlowRecordUrlNoMatch(){
        H8FlowFormManagerController.testFlowRecordId = null;

        Test.startTest();
            try {
                H8FlowFormManagerController.getFlowRecordUrl('sampleflowname');
                System.assert(false, 'we expect an exception to be thrown when no flow matches the api name');
            } catch (AuraHandledException e) {
                System.assert(true, 'we expect an AuraHandledException to be thrown');
            }
        Test.stopTest();
    }

    // The methods below exercise the real (non-mocked) SOQL query paths, which are otherwise
    // unreachable in a test context since Test.isRunningTest() is always true there. Custom Metadata
    // records can't be created via DML in a test, and this package ships no sample H8_Flow_Form__mdt/
    // H8_Flow_Form_Section__mdt records of its own (consistent with H8FlowFormCloneControllerTest, which
    // uses MockMetaManager-built records exclusively rather than live org data) - so these call the
    // @TestVisible private query methods directly using developer names that are guaranteed not to match
    // any real record, purely to exercise the query mechanism itself and preserve code coverage on the
    // "real" branch. The two real, permanently-shipped fixtures this package does ship - the
    // "H8FlowFormCustomValidationTemplate" flow (deployed without an active version) and the
    // "Data_Table_Example" flow (deployed active) - are used below for the FlowDefinitionView-backed
    // methods, since those are always present regardless of which org this runs against.

    @isTest
    static void testQueryFormSectionsLiveQueryNoMatch(){
        Test.startTest();
            List<H8_Flow_Form_Section__mdt> sections = H8FlowFormManagerController.queryFormSections('ThisFormDoesNotExist');
            System.assertEquals(0, sections.size(), 'we expect an empty list when no form matches the developer name');
        Test.stopTest();
    }

    @isTest
    static void testQuerySectionValidationsLiveQuery(){
        Test.startTest();
            List<H8_Flow_Form_Section_Validation__mdt> validations = H8FlowFormManagerController.querySectionValidations('SampleFormPage1');
            System.assertEquals(true, validations != null, 'we expect a list to be returned, even if the real section currently has no validations');
        Test.stopTest();
    }

    @isTest
    static void testQuerySectionValidationsLiveQueryNoMatch(){
        Test.startTest();
            List<H8_Flow_Form_Section_Validation__mdt> validations = H8FlowFormManagerController.querySectionValidations('ThisSectionDoesNotExist');
            System.assertEquals(0, validations.size(), 'we expect an empty list when no section matches the developer name');
        Test.stopTest();
    }

    // FlowRecord (unlike FlowDefinitionView/Organization elsewhere in this class) is not visible in a
    // standard test context at all - confirmed empirically: the exact same query that finds a real row
    // via anonymous Apex returns zero rows in a unit test, and only becomes visible with SeeAllData=true.
    // SeeAllData is deliberately not used in this package (it disables test-data isolation and makes
    // tests depend on mutable, shared org state), and there's no way to insert a FlowRecord via DML to
    // work around that (it's a system-managed object, not user data). So the "match found" branch of
    // getFlowRecordId is verified manually instead (confirmed via anonymous Apex against Data_Table_Example
    // and the Draft H8FlowFormCustomValidationTemplate flow while building this feature) rather than by
    // an automated test - the query itself (SELECT Id FROM FlowRecord WHERE ApiName = :flowApiName LIMIT 1)
    // is simple enough that this is an acceptable trade-off. The no-match branch below still gets real
    // automated coverage, since a query for a name that doesn't exist correctly returns zero rows with or
    // without SeeAllData. getFlowRecordUrl's own behaviour (both the URL built when a FlowRecord id is
    // present, and the exception thrown when it isn't) is fully covered without SeeAllData via
    // testGetFlowRecordUrlWithMatch/testGetFlowRecordUrlNoMatch above, using the standard testFlowRecordId
    // injection point.

    @isTest
    static void testGetFlowRecordIdLiveQueryNoMatch(){
        Test.startTest();
            String flowRecordId = H8FlowFormManagerController.getFlowRecordId('ThisFlowDoesNotExist');
            System.assertEquals(null, flowRecordId, 'we expect null when no flow matches the api name');
        Test.stopTest();
    }

    @isTest
    static void testQueryFlowUsageSectionsLiveQueryNoMatch(){
        // this package ships no sample H8_Flow_Form_Section__mdt records, so there's no flow api name
        // guaranteed to have a real section usage - this exists purely to exercise the real query branch
        Test.startTest();
            List<H8_Flow_Form_Section__mdt> usages = H8FlowFormManagerController.queryFlowUsageSections('ThisFlowDoesNotExist');
            System.assertEquals(0, usages.size(), 'we expect an empty list when no section references the given flow');
        Test.stopTest();
    }

    @isTest
    static void testQueryFlowUsageFormsLiveQueryNoMatch(){
        // this package ships no sample H8_Flow_Form__mdt records, so there's no flow api name
        // guaranteed to have a real validation-flow usage - this exists purely to exercise the real query branch
        Test.startTest();
            List<H8_Flow_Form__mdt> usages = H8FlowFormManagerController.queryFlowUsageForms('ThisFlowDoesNotExist');
            System.assertEquals(0, usages.size(), 'we expect an empty list when no form references the given flow as its validation flow');
        Test.stopTest();
    }

    @isTest
    static void testResolveSectionDisplayNameFallsBackWhenLabelDoesNotExist(){
        List<H8_Flow_Form_Section__mdt> testFormSections = new List<H8_Flow_Form_Section__mdt>();
        testFormSections.add((H8_Flow_Form_Section__mdt)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'ThisLabelDefinitelyDoesNotExistXyzAbc123')
            .addFieldValue('DeveloperName', 'childSection')
            .addFieldValue('Order__c', 10)
            .addFieldValue('Use_Custom_Label__c', true)
            .getSingleMockMetaData());

        H8FlowFormManagerController.testFormSections = testFormSections;

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getFormSections('TestForm');
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            List<Object> sections = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('sections')));
            Map<String, Object> section = (Map<String, Object>)sections[0];
            System.assertEquals('ThisLabelDefinitelyDoesNotExistXyzAbc123', section.get('displayName'), 'we expect the raw master label to be used as a fallback when the custom label cannot be resolved');
        Test.stopTest();
    }

    // The custom field support below lets consultants/developers add their own fields to H8_Flow_Form__mdt
    // and have them appear automatically. The package ships no such fields itself, so the filtering logic
    // is deliberately factored to take plain field-name sets rather than calling Schema directly - that lets
    // these tests fabricate a "Description__c"-style field name and prove the mechanism without needing one
    // to actually exist. The dynamic SOQL/formatting mechanism is proven separately using a real, already-known
    // field (MasterLabel) standing in for a "custom" one, since the mechanism is field-name-driven either way.

    @isTest
    static void testDeriveCustomFieldApiNamesReturnsOnlyUnknownFields(){
        Set<String> allFields = new Set<String>{ 'Id', 'DeveloperName', 'MasterLabel', 'Type__c', 'Status__c', 'Description__c' };
        Set<String> knownFields = new Set<String>{ 'Id', 'DeveloperName', 'MasterLabel', 'Type__c', 'Status__c' };

        Test.startTest();
            List<String> customFieldApiNames = H8FlowFormManagerController.deriveCustomFieldApiNames(allFields, knownFields);
        Test.stopTest();

        System.assertEquals(1, customFieldApiNames.size(), 'we expect only the unknown field to be returned');
        System.assertEquals('Description__c', customFieldApiNames[0], 'we expect the unrecognised field to be treated as custom');
    }

    @isTest
    static void testDeriveCustomFieldApiNamesNoCustomFields(){
        Set<String> allFields = new Set<String>{ 'Id', 'DeveloperName' };
        Set<String> knownFields = new Set<String>{ 'Id', 'DeveloperName' };

        Test.startTest();
            List<String> customFieldApiNames = H8FlowFormManagerController.deriveCustomFieldApiNames(allFields, knownFields);
        Test.stopTest();

        System.assertEquals(0, customFieldApiNames.size(), 'we expect no custom fields when every field is already known');
    }

    @isTest
    static void testDeriveCustomFieldApiNamesSortsResultsAlphabetically(){
        Set<String> allFields = new Set<String>{ 'Zeta__c', 'Alpha__c' };
        Set<String> knownFields = new Set<String>();

        Test.startTest();
            List<String> customFieldApiNames = H8FlowFormManagerController.deriveCustomFieldApiNames(allFields, knownFields);
        Test.stopTest();

        System.assertEquals('Alpha__c', customFieldApiNames[0], 'we expect the results sorted alphabetically');
        System.assertEquals('Zeta__c', customFieldApiNames[1], 'we expect the results sorted alphabetically');
    }

    @isTest
    static void testFormatCustomFieldValueReturnsLabelDataTypeAndValue(){
        H8_Flow_Form__mdt fakeForm = new H8_Flow_Form__mdt(MasterLabel = 'Sample Label Value');
        Schema.DescribeFieldResult describeResult = H8_Flow_Form__mdt.MasterLabel.getDescribe();

        Test.startTest();
            H8FlowFormManagerController.CustomFieldValue fieldValue = H8FlowFormManagerController.formatCustomFieldValue(fakeForm, 'MasterLabel', describeResult);
        Test.stopTest();

        System.assertEquals('MasterLabel', fieldValue.apiName, 'we expect the api name to be passed through as-is');
        System.assertEquals(describeResult.getLabel(), fieldValue.label, 'we expect the field label to come from the describe result');
        System.assertEquals('Sample Label Value', fieldValue.value, 'we expect the raw value to be stringified');
    }

    @isTest
    static void testFormatCustomFieldValueNullRawValueReturnsEmptyString(){
        H8_Flow_Form__mdt fakeForm = new H8_Flow_Form__mdt();
        Schema.DescribeFieldResult describeResult = H8_Flow_Form__mdt.MasterLabel.getDescribe();

        Test.startTest();
            H8FlowFormManagerController.CustomFieldValue fieldValue = H8FlowFormManagerController.formatCustomFieldValue(fakeForm, 'MasterLabel', describeResult);
        Test.stopTest();

        System.assertEquals('', fieldValue.value, 'we expect a null raw value to be formatted as an empty string rather than "null"');
    }

    @isTest
    static void testGetFormCustomFieldsUsesTestInjectedList(){
        H8FlowFormManagerController.CustomFieldValue fieldValue = new H8FlowFormManagerController.CustomFieldValue();
        fieldValue.apiName = 'Description__c';
        fieldValue.label = 'Description';
        fieldValue.dataType = 'STRING';
        fieldValue.value = 'Some description';
        H8FlowFormManagerController.testFormCustomFields = new List<H8FlowFormManagerController.CustomFieldValue>{ fieldValue };

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getFormCustomFields('SampleForm');
        Test.stopTest();

        Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(true, mapOfObject.containsKey('customFields'), 'we always expect customFields to be returned here');
        List<Object> customFields = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('customFields')));
        System.assertEquals(1, customFields.size(), 'we expect 1 custom field to be returned');
        Map<String, Object> firstField = (Map<String, Object>)customFields[0];
        System.assertEquals('Description__c', firstField.get('apiName'), 'we expect the injected field to be returned');
    }

    @isTest
    static void testQueryFormCustomFieldsLiveQueryExcludesAllKnownFields(){
        // doesn't assert the list is empty - a real custom field may genuinely exist on this org (e.g. one
        // added manually to try the feature out). instead this is a regression check on FORM_KNOWN_FIELD_API_NAMES:
        // if a future package field is added to H8_Flow_Form__mdt without being added to that set, it will
        // incorrectly show up as "custom" here and fail
        Test.startTest();
            List<H8FlowFormManagerController.CustomFieldValue> customFields = H8FlowFormManagerController.queryFormCustomFields('SampleForm');
        Test.stopTest();

        for (H8FlowFormManagerController.CustomFieldValue field : customFields) {
            System.assertEquals(false, H8FlowFormManagerController.FORM_KNOWN_FIELD_API_NAMES.contains(field.apiName.toLowerCase()),
                'we expect none of our own package fields to ever be reported as custom: ' + field.apiName);
        }
    }

    @isTest
    static void testBuildCustomFieldValuesLiveQueryNoMatch(){
        Test.startTest();
            List<H8FlowFormManagerController.CustomFieldValue> customFields = H8FlowFormManagerController.buildCustomFieldValues(
                'H8_Flow_Form__mdt',
                new List<String>{ 'MasterLabel' },
                'ThisFormDoesNotExist'
            );
        Test.stopTest();

        System.assertEquals(0, customFields.size(), 'we expect an empty list when no record matches the developer name');
    }

    @isTest
    static void testBuildCustomFieldValuesForDeveloperNamesLiveQueryMatchFound(){
        // this package ships no H8_Flow_Form__mdt sample records, so the bulk query's "match found"
        // branch is proven here against a real, permanently-shipped record from a different feature
        // (H8_DataFetcherQuery__mdt.AccountByType) - the method is fully generic on object/field/developer
        // name, so this still genuinely exercises the query/grouping/formatting logic end-to-end
        Test.startTest();
            Map<String, List<H8FlowFormManagerController.CustomFieldValue>> valuesByDeveloperName = H8FlowFormManagerController.buildCustomFieldValuesForDeveloperNames(
                'H8_DataFetcherQuery__mdt',
                new List<String>{ 'ObjectApiName__c' },
                new List<String>{ 'AccountByType' }
            );
        Test.stopTest();

        System.assertEquals(true, valuesByDeveloperName.containsKey('AccountByType'), 'we expect the real AccountByType record to be found and keyed by its developer name');
        List<H8FlowFormManagerController.CustomFieldValue> fields = valuesByDeveloperName.get('AccountByType');
        System.assertEquals(1, fields.size(), 'we expect 1 field value to be returned');
        System.assertEquals('ObjectApiName__c', fields[0].apiName, 'we expect the requested field api name to be returned');
        System.assertEquals('Account', fields[0].value, 'we expect the real ObjectApiName__c value to be retrieved via the bulk dynamic SOQL');
    }

    @isTest
    static void testBuildCustomFieldValuesForDeveloperNamesLiveQueryMultipleMatches(){
        // proves the grouping-by-developer-name logic keys each result correctly when more than one
        // record matches, using two real permanently-shipped Test_Record_Generator__mdt records
        Test.startTest();
            Map<String, List<H8FlowFormManagerController.CustomFieldValue>> valuesByDeveloperName = H8FlowFormManagerController.buildCustomFieldValuesForDeveloperNames(
                'Test_Record_Generator__mdt',
                new List<String>{ 'MasterLabel' },
                new List<String>{ 'Account_Form_Validation', 'Opportunity_Form_Validation' }
            );
        Test.stopTest();

        System.assertEquals(2, valuesByDeveloperName.size(), 'we expect both real records to be found and keyed by their own developer name');
        System.assertEquals(true, valuesByDeveloperName.containsKey('Account_Form_Validation'), 'we expect the Account record keyed correctly');
        System.assertEquals(true, valuesByDeveloperName.containsKey('Opportunity_Form_Validation'), 'we expect the Opportunity record keyed correctly');
    }

    // Section-level custom fields reuse the exact same building blocks (deriveCustomFieldApiNames/buildCustomFieldValues)
    // proven above for the Form object, but bulked up across every section under a form in one call, so the
    // Sections table can show them as extra columns rather than requiring a row to be selected first.

    @isTest
    static void testGetSectionCustomFieldsForFormUsesTestInjectedMap(){
        H8FlowFormManagerController.CustomFieldValue fieldValue = new H8FlowFormManagerController.CustomFieldValue();
        fieldValue.apiName = 'Special_Instructions__c';
        fieldValue.label = 'Special Instructions';
        fieldValue.dataType = 'STRING';
        fieldValue.value = 'Some instructions';
        H8FlowFormManagerController.testSectionCustomFieldsForForm = new Map<String, List<H8FlowFormManagerController.CustomFieldValue>>{
            'childSection' => new List<H8FlowFormManagerController.CustomFieldValue>{ fieldValue }
        };

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getSectionCustomFieldsForForm('SampleForm');
        Test.stopTest();

        Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(true, mapOfObject.containsKey('sectionCustomFields'), 'we always expect sectionCustomFields to be returned here');
        Map<String, Object> sectionCustomFields = (Map<String, Object>)mapOfObject.get('sectionCustomFields');
        System.assertEquals(true, sectionCustomFields.containsKey('childSection'), 'we expect the injected section key to be returned');
        List<Object> fields = (List<Object>)sectionCustomFields.get('childSection');
        System.assertEquals(1, fields.size(), 'we expect 1 custom field to be returned for the section');
        Map<String, Object> firstField = (Map<String, Object>)fields[0];
        System.assertEquals('Special_Instructions__c', firstField.get('apiName'), 'we expect the injected field to be returned');
    }

    @isTest
    static void testQuerySectionCustomFieldsForFormLiveQueryExcludesAllKnownFields(){
        // same regression-check approach as testQueryFormCustomFieldsLiveQueryExcludesAllKnownFields above -
        // tolerant of a real custom field existing, but guards against a package field being reported as custom
        Test.startTest();
            Map<String, List<H8FlowFormManagerController.CustomFieldValue>> fieldsBySectionDeveloperName = H8FlowFormManagerController.querySectionCustomFieldsForForm('SampleForm');
        Test.stopTest();

        for (String sectionDeveloperName : fieldsBySectionDeveloperName.keySet()) {
            for (H8FlowFormManagerController.CustomFieldValue field : fieldsBySectionDeveloperName.get(sectionDeveloperName)) {
                System.assertEquals(false, H8FlowFormManagerController.SECTION_KNOWN_FIELD_API_NAMES.contains(field.apiName.toLowerCase()),
                    'we expect none of our own package fields to ever be reported as custom: ' + field.apiName);
            }
        }
    }

    @isTest
    static void testQuerySectionCustomFieldsForFormLiveQueryNoMatch(){
        Test.startTest();
            Map<String, List<H8FlowFormManagerController.CustomFieldValue>> fieldsBySectionDeveloperName = H8FlowFormManagerController.querySectionCustomFieldsForForm('ThisFormDoesNotExist');
        Test.stopTest();

        System.assertEquals(0, fieldsBySectionDeveloperName.size(), 'we expect an empty map when no form matches the developer name');
    }

    // The Flow Explorer tab needs a distinct list of every flow api name in use across all forms/sections,
    // resolved against real deployed fixtures the same way the flow usage lookups above are.

    @isTest
    static void testGetUsedFlowsUsesTestInjectedList(){
        H8FlowFormManagerController.FlowUsageOption option = new H8FlowFormManagerController.FlowUsageOption();
        option.apiName = 'sharedFlow';
        option.label = 'Shared Flow';
        H8FlowFormManagerController.testUsedFlows = new List<H8FlowFormManagerController.FlowUsageOption>{ option };

        Test.startTest();
            String jsonString = H8FlowFormManagerController.getUsedFlows();
        Test.stopTest();

        Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        System.assertEquals(true, mapOfObject.containsKey('flows'), 'we always expect flows to be returned here');
        List<Object> flows = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('flows')));
        System.assertEquals(1, flows.size(), 'we expect 1 flow to be returned');
        Map<String, Object> firstFlow = (Map<String, Object>)flows[0];
        System.assertEquals('sharedFlow', firstFlow.get('apiName'), 'we expect the injected flow to be returned');
    }

    @isTest
    static void testQueryUsedFlowsLiveQuery(){
        // this package ships no sample H8_Flow_Form__mdt/H8_Flow_Form_Section__mdt records, so there's
        // no flow api name guaranteed to be referenced - this exists purely to exercise the real query
        // branch and prove it runs without error, tolerant of whatever forms/sections genuinely exist
        Test.startTest();
            List<H8FlowFormManagerController.FlowUsageOption> flows = H8FlowFormManagerController.queryUsedFlows();
        Test.stopTest();

        System.assertEquals(true, flows != null, 'we expect a list to be returned, even if no flows are currently referenced');
    }

    @isTest
    static void testFlowUsageOptionSortsByLabel(){
        H8FlowFormManagerController.FlowUsageOption optionA = new H8FlowFormManagerController.FlowUsageOption();
        optionA.label = 'Zeta Flow';
        H8FlowFormManagerController.FlowUsageOption optionB = new H8FlowFormManagerController.FlowUsageOption();
        optionB.label = 'Alpha Flow';
        List<H8FlowFormManagerController.FlowUsageOption> options = new List<H8FlowFormManagerController.FlowUsageOption>{ optionA, optionB };

        Test.startTest();
            options.sort();
        Test.stopTest();

        System.assertEquals('Alpha Flow', options[0].label, 'we expect the options sorted alphabetically by label');
        System.assertEquals('Zeta Flow', options[1].label, 'we expect the options sorted alphabetically by label');
    }

    // The Test Mode screen needs to know whether this org is production, to warn users before they save
    // real data. Organization is standard setup metadata, not user data, so it's queryable in tests as-is.

    @isTest
    static void testGetIsProductionOrgUsesTestInjectedValue(){
        H8FlowFormManagerController.testIsProductionOrg = true;

        Test.startTest();
            Boolean isProductionOrg = H8FlowFormManagerController.getIsProductionOrg();
        Test.stopTest();

        System.assertEquals(true, isProductionOrg, 'we expect the injected test value to be returned');
    }

    @isTest
    static void testQueryIsProductionOrgLiveQuery(){
        Test.startTest();
            Boolean isProductionOrg = H8FlowFormManagerController.queryIsProductionOrg();
        Test.stopTest();

        System.assertEquals(false, isProductionOrg, 'we expect this scratch org to not be reported as a production org');
    }
}
