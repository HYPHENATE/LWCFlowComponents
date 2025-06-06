/**
 * @description       : H8FlowFormSectionValidation test class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 03/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8FlowFormSectionValidationTest {
    
    static TestRecordSource testRecordSource = new TestRecordSource();

    /**
    * @description          testing where really bad data is sent to method how it is handled
    **/
    @isTest 
    static void testCompleteError(){
        Test.startTest();
            String jsonString = H8FlowFormSectionValidation.validatePage('dsdasdsa', 'fsdfsdfds', 'sdfsdfsd','dasdasdas');
            Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Assert.isFalse((Boolean)jsonObjects.get('success'), 'we expect this to be false');
        Test.stopTest();
    }
    
    /**
    * @description          testing running the code when no form validations are present
    **/
    @isTest 
    static void testNoValidationsOnForm(){

        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
        .asVariant('FormValidation')
        .withInsert();

        Opportunity opportunity = (Opportunity)testRecordSource.getObject(Opportunity.sObjectType) 
        .asVariant('FormValidation')
        .withOutInsert();
        opportunity.AccountId = account.Id;
        opportunity.CloseDate = System.today();
        insert opportunity;

        List<H8_Flow_Form_Section__mdt> childList = (List<H8_Flow_Form_Section__mdt>)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'FirstChild')
            .addFieldValue('DeveloperName', 'FirstChild')
            .addFieldValue('Flow_API_Name__c', 'Contact')
            .addFieldValue('Icon_Name__c', 'Email')
            .addFieldValue('Order__c', '1')
            .addFieldValue('Id', 'SampleId')
            .getListMockMetaData();

        List<H8_Flow_Form__mdt> testRecords = (List<H8_Flow_Form__mdt>)new MockMetaManager('H8_Flow_Form__mdt')    
            .addFieldValue('MasterLabel', 'TestRecord')
            .addFieldValue('DeveloperName', 'TestRecord')
            .addChildren('H8_Flow_Form_Sections__r', childList)
            .getListMockMetaData();

        H8FlowFormValidationHelper.testForm = testRecords[0];

        Test.startTest();
            String jsonString = H8FlowFormSectionValidation.validatePage(opportunity.Id, 'TestRecord', 'Opportunity', 'FirstChild');
            Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Assert.areEqual(true, jsonObjects.containsKey('success'), 'we expect the success key to be present');
            Assert.areEqual(true, (Boolean)jsonObjects.get('success'), 'we expect success to be set as true');
        Test.stopTest();
        
    }

    /**
    * @description          testing running the code when 1 form validations are present on master object and form is valid
    **/
    @isTest 
    static void testValidationsOnFormMasterObjectValid(){

        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
        .asVariant('FormValidation')
        .withInsert();

        Opportunity opportunity = (Opportunity)testRecordSource.getObject(Opportunity.sObjectType) 
        .asVariant('FormValidation')
        .withOutInsert();
        opportunity.AccountId = account.Id;
        opportunity.CloseDate = System.today();
        insert opportunity;

        List<H8_Flow_Form_Section_Validation__mdt> validationList = (List<H8_Flow_Form_Section_Validation__mdt>)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'OppCloseDate')
            .addFieldValue('DeveloperName', 'OppCloseDate')
            .addFieldValue('FieldAPIName__c', 'CloseDate')
            .addFieldValue('DataType__c', 'Date')
            .addFieldValue('Page__c', 'Page1')
            .addFieldValue('QuestionName__c', 'CloseDate')
            .addFieldValue('Id', 'SampleId2')
            .addFieldValue('Disabled__c', false)
            .getListMockMetaData();

        List<H8_Flow_Form_Section__mdt> childList = (List<H8_Flow_Form_Section__mdt>)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'FirstChild')
            .addFieldValue('DeveloperName', 'FirstChild')
            .addFieldValue('Flow_API_Name__c', 'Contact')
            .addFieldValue('Icon_Name__c', 'Email')
            .addFieldValue('Order__c', '1')
            .addFieldValue('Id', 'SampleId1')
            .addChildren('H8_Flow_Form_Section_Validations__r', validationList)
            .getListMockMetaData();

        List<H8_Flow_Form__mdt> testRecords = (List<H8_Flow_Form__mdt>)new MockMetaManager('H8_Flow_Form__mdt')    
            .addFieldValue('MasterLabel', 'TestRecord')
            .addFieldValue('DeveloperName', 'TestRecord')
            .addChildren('H8_Flow_Form_Sections__r', childList)
            .getListMockMetaData();

        H8FlowFormValidationHelper.testForm = testRecords[0];

        Test.startTest();
            String jsonString = H8FlowFormSectionValidation.validatePage(opportunity.Id, 'TestRecord', 'Opportunity', 'FirstChild');
            Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Assert.areEqual(true, jsonObjects.containsKey('success'), 'we expect the success key to be present');
            Assert.areEqual(true, (Boolean)jsonObjects.get('success'), 'we expect success to be set as true');
            Assert.areEqual(false, (Boolean)jsonObjects.get('hasErrors'), 'we expect hasErrors to be set as false');
        Test.stopTest();
        
    }

    /**
    * @description          testing running the code when 2 form validations are present on master object and form is invalid
    **/
    @isTest 
    static void testValidationsOnFormMasterObjectInvalid(){

        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
        .asVariant('FormValidation')
        .withInsert();

        Opportunity opportunity = (Opportunity)testRecordSource.getObject(Opportunity.sObjectType) 
        .asVariant('FormValidation')
        .withOutInsert();
        opportunity.AccountId = account.Id;
        opportunity.CloseDate = System.today();
        insert opportunity;

        List<H8_Flow_Form_Section_Validation__mdt> validationList = new List<H8_Flow_Form_Section_Validation__mdt>();
        validationList.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'OppType')
            .addFieldValue('DeveloperName', 'OppType')
            .addFieldValue('FieldAPIName__c', 'Type')
            .addFieldValue('DataType__c', 'String')
            .addFieldValue('Page__c', 'Page1')
            .addFieldValue('QuestionName__c', 'Amount')
            .addFieldValue('Id', 'SampleId2')
            .addFieldValue('Disabled__c', false)
            .getSingleMockMetaData());
        validationList.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'OppAmount')
            .addFieldValue('DeveloperName', 'OppAmount')
            .addFieldValue('FieldAPIName__c', 'Amount')
            .addFieldValue('DataType__c', 'Decimal')
            .addFieldValue('Page__c', 'Page1')
            .addFieldValue('QuestionName__c', 'Amount')
            .addFieldValue('Id', 'SampleId3')
            .addFieldValue('Disabled__c', false)
            .getSingleMockMetaData());

        List<H8_Flow_Form_Section__mdt> childList = (List<H8_Flow_Form_Section__mdt>)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'FirstChild')
            .addFieldValue('DeveloperName', 'FirstChild')
            .addFieldValue('Flow_API_Name__c', 'Contact')
            .addFieldValue('Icon_Name__c', 'Email')
            .addFieldValue('Order__c', '1')
            .addFieldValue('Id', 'SampleId1')
            .addChildren('H8_Flow_Form_Section_Validations__r', validationList)
            .getListMockMetaData();

        List<H8_Flow_Form__mdt> testRecords = (List<H8_Flow_Form__mdt>)new MockMetaManager('H8_Flow_Form__mdt')    
            .addFieldValue('MasterLabel', 'TestRecord')
            .addFieldValue('DeveloperName', 'TestRecord')
            .addChildren('H8_Flow_Form_Sections__r', childList)
            .getListMockMetaData();

        H8FlowFormValidationHelper.testForm = testRecords[0];

        Test.startTest();
            String jsonString = H8FlowFormSectionValidation.validatePage(opportunity.Id, 'TestRecord', 'Opportunity', 'FirstChild');
            Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Assert.areEqual(true, jsonObjects.containsKey('success'), 'we expect the success key to be present');
            Assert.areEqual(true, (Boolean)jsonObjects.get('success'), 'we expect success to be set as true');
            Assert.areEqual(true, (Boolean)jsonObjects.get('hasErrors'), 'we expect hasErrors to be set as true');
            List<Object> pages = (List<Object>)jsonObjects.get('pages');
            Assert.areEqual(1, pages.size(), 'we expect 1 page to be present');
            for(Object page:pages){
                Map<String, Object> pageObjects = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(page));
                List<Object> errors = (List<Object>)pageObjects.get('errors');
                Assert.areEqual(2, errors.size(), 'we expect 2 section to be present');
            }
        Test.stopTest();
        
    }

    /**
    * @description          testing running the code when 5 form validations are present on master object and form is invalid
    **/
    @isTest 
    static void testValidationsOnFormMasterObjectInvalidLarge(){

        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
        .asVariant('FormValidation')
        .withInsert();

        Opportunity opportunity = (Opportunity)testRecordSource.getObject(Opportunity.sObjectType) 
        .asVariant('FormValidation')
        .withOutInsert();
        opportunity.AccountId = account.Id;
        opportunity.CloseDate = System.today();
        insert opportunity;

        List<H8_Flow_Form_Section_Validation__mdt> validationList = new List<H8_Flow_Form_Section_Validation__mdt>();
        validationList.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'OppType')
            .addFieldValue('DeveloperName', 'OppType')
            .addFieldValue('FieldAPIName__c', 'Account.Type')
            .addFieldValue('DataType__c', 'String')
            .addFieldValue('Validation_Value__c', 'Sample')
            .addFieldValue('Page__c', 'Page1')
            .addFieldValue('QuestionName__c', 'Type')
            .addFieldValue('Id', 'SampleId2')
            .addFieldValue('Disabled__c', false)
            .getSingleMockMetaData());
        validationList.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'OppAmount')
            .addFieldValue('DeveloperName', 'OppAmount')
            .addFieldValue('FieldAPIName__c', 'Amount')
            .addFieldValue('DataType__c', 'Decimal')
            .addFieldValue('Validation_Value__c', '1000')
            .addFieldValue('Page__c', 'Page1')
            .addFieldValue('QuestionName__c', 'Amount')
            .addFieldValue('Id', 'SampleId3')
            .addFieldValue('Disabled__c', false)
            .getSingleMockMetaData());
        validationList.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'OppCloseDate')
            .addFieldValue('DeveloperName', 'OppCloseDate')
            .addFieldValue('FieldAPIName__c', 'CloseDate')
            .addFieldValue('DataType__c', 'Date')
            .addFieldValue('Validation_Value__c', '24/04/2024')
            .addFieldValue('Page__c', 'Page1')
            .addFieldValue('QuestionName__c', 'CloseDate')
            .addFieldValue('Id', 'SampleId5')
            .addFieldValue('Disabled__c', false)
            .getSingleMockMetaData());
        validationList.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'OppName')
            .addFieldValue('DeveloperName', 'OppName')
            .addFieldValue('FieldAPIName__c', 'Name')
            .addFieldValue('Validation_Value__c', 'Name')
            .addFieldValue('Page__c', 'Page1')
            .addFieldValue('QuestionName__c', 'Name')
            .addFieldValue('Id', 'SampleId6')
            .addFieldValue('Disabled__c', false)
            .getSingleMockMetaData());
        validationList.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'IsPrivate')
            .addFieldValue('DeveloperName', 'IsPrivate')
            .addFieldValue('FieldAPIName__c', 'IsPrivate')
            .addFieldValue('DataType__c', 'Boolean')
            .addFieldValue('Validation_Value__c', 'true')
            .addFieldValue('Page__c', 'Page1')
            .addFieldValue('QuestionName__c', 'IsPrivate')
            .addFieldValue('Id', 'SampleId7')
            .addFieldValue('Disabled__c', false)
            .getSingleMockMetaData());
        validationList.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'Probability')
            .addFieldValue('DeveloperName', 'Probability')
            .addFieldValue('FieldAPIName__c', 'Probability')
            .addFieldValue('DataType__c', 'Integer')
            .addFieldValue('Validation_Value__c', '4')
            .addFieldValue('Page__c', 'Page1')
            .addFieldValue('QuestionName__c', 'Probability')
            .addFieldValue('Id', 'SampleId8')
            .addFieldValue('Disabled__c', false)
            .getSingleMockMetaData());

        List<H8_Flow_Form_Section__mdt> childList = (List<H8_Flow_Form_Section__mdt>)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'FirstChild')
            .addFieldValue('DeveloperName', 'FirstChild')
            .addFieldValue('Flow_API_Name__c', 'Contact')
            .addFieldValue('Icon_Name__c', 'Email')
            .addFieldValue('Order__c', '1')
            .addFieldValue('Id', 'SampleId1')
            .addChildren('H8_Flow_Form_Section_Validations__r', validationList)
            .getListMockMetaData();

        List<H8_Flow_Form__mdt> testRecords = (List<H8_Flow_Form__mdt>)new MockMetaManager('H8_Flow_Form__mdt')    
            .addFieldValue('MasterLabel', 'TestRecord')
            .addFieldValue('DeveloperName', 'TestRecord')
            .addChildren('H8_Flow_Form_Sections__r', childList)
            .getListMockMetaData();

        H8FlowFormValidationHelper.testForm = testRecords[0];

        Test.startTest();
            String jsonString = H8FlowFormSectionValidation.validatePage(opportunity.Id, 'TestRecord', 'Opportunity', 'FirstChild');
            Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Assert.areEqual(true, jsonObjects.containsKey('success'), 'we expect the success key to be present');
            Assert.areEqual(true, (Boolean)jsonObjects.get('success'), 'we expect success to be set as true');
            Assert.areEqual(true, (Boolean)jsonObjects.get('hasErrors'), 'we expect hasErrors to be set as true');
            List<Object> pages = (List<Object>)jsonObjects.get('pages');
            Assert.areEqual(1, pages.size(), 'we expect 1 page to be present');
            for(Object page:pages){
                Map<String, Object> pageObjects = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(page));
                List<Object> errors = (List<Object>)pageObjects.get('errors');
                Assert.areEqual(6, errors.size(), 'we expect 6 section to be present');
            }
        Test.stopTest();
        
    }

    /**
    * @description          testing running the code when 1 form Flow validation is present on master object and form is valid
    **/
    @isTest 
    static void testFlowValidationsOnFormMasterObjectValid(){

        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
        .asVariant('FormValidation')
        .withInsert();
        
        List<H8_Flow_Form_Section_Validation__mdt> validationList = (List<H8_Flow_Form_Section_Validation__mdt>)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'FlowValTest')
            .addFieldValue('DeveloperName', 'FlowValTest')
            .addFieldValue('IsFlowValidation__c', 'true')
            .addFieldValue('FlowValidationType__c', 'Test')
            .addFieldValue('Id', 'SampleId2')
            .addFieldValue('Disabled__c', false)
            .getListMockMetaData();

        List<H8_Flow_Form_Section__mdt> childList = (List<H8_Flow_Form_Section__mdt>)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'FirstChild')
            .addFieldValue('DeveloperName', 'FirstChild')
            .addFieldValue('Flow_API_Name__c', 'Contact')
            .addFieldValue('Icon_Name__c', 'Email')
            .addFieldValue('Order__c', '1')
            .addFieldValue('Id', 'SampleId1')
            .addChildren('H8_Flow_Form_Section_Validations__r', validationList)
            .getListMockMetaData();

        List<H8_Flow_Form__mdt> testRecords = (List<H8_Flow_Form__mdt>)new MockMetaManager('H8_Flow_Form__mdt')    
            .addFieldValue('MasterLabel', 'TestRecord')
            .addFieldValue('DeveloperName', 'TestRecord')
            .addFieldValue('Validation_Flow_API_Name__c', 'H8FlowFormCustomValidationTemplate')
            .addChildren('H8_Flow_Form_Sections__r', childList)
            .getListMockMetaData();

        H8FlowFormValidationHelper.testForm = testRecords[0];

        Test.startTest();
            String jsonString = H8FlowFormSectionValidation.validatePage(account.Id, 'TestRecord', 'Account', 'FirstChild');
            Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Assert.areEqual(true, jsonObjects.containsKey('success'), 'we expect the success key to be present');
            Assert.areEqual(true, (Boolean)jsonObjects.get('success'), 'we expect success to be set as true');
            Assert.areEqual(true, (Boolean)jsonObjects.get('hasErrors'), 'we expect hasErrors to be set as true');
            List<Object> pages = (List<Object>)jsonObjects.get('pages');
            Assert.areEqual(1, pages.size(), 'we expect 1 page to be present');
            for(Object page:pages){
                Map<String, Object> pageObjects = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(page));
                List<Object> errors = (List<Object>)pageObjects.get('errors');
                Assert.areEqual(1, errors.size(), 'we expect 1 section to be present');
            }            
        Test.stopTest();
        
    }
}