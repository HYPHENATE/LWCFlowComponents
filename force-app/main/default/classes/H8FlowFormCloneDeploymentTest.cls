/**
 * @description       : H8FlowFormCloneDeployment test
 * @author            : daniel@hyphen8.com
 * @last modified on  : 26-06-2025
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8FlowFormCloneDeploymentTest {

    @isTest
    static void errorMissingDataTest(){
        H8FlowFormCloneDeployment.testFormValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
        H8FlowFormCloneDeployment.testFormSections = new List<H8_Flow_Form_Section__mdt>();
        Test.startTest();
            try {
                Id asyncJobId = H8FlowFormCloneDeployment.cloneFlowForm(null,null,null);
            } catch (Exception e){
                String expectedError = 'Script-thrown exception';
                System.assertEquals(expectedError, e.getMessage(), 'we expect this value to match');
            }
        Test.stopTest();
    }
    
    @isTest
    static void noConflictOfNameTest(){
        H8FlowFormCloneDeployment.testFormValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
        H8FlowFormCloneDeployment.testFormSections = new List<H8_Flow_Form_Section__mdt>();

        List<H8_Flow_Form__mdt> testFlowForms = new List<H8_Flow_Form__mdt>();
        testFlowForms.add((H8_Flow_Form__mdt)new MockMetaManager('H8_Flow_Form__mdt')
            .addFieldValue('MasterLabel', 'TestShareObjectKeyReferece')
            .addFieldValue('DeveloperName', 'TestShareObjectKeyReferece')
            .addFieldValue('Type__c', 'Application')
            .addFieldValue('Status__c', 'ACTIVE')
            .addFieldValue('Validation_Flow_API_Name__c', 'SampleFlow')
            .getSingleMockMetaData());

        H8FlowFormCloneDeployment.testForm = testFlowForms[0];

        Test.startTest();
            Id asyncJobId = H8FlowFormCloneDeployment.cloneFlowForm('TestShareObjectKeyReferece','NewForm', 'NewForm');
            System.assertEquals(asyncJobId, UserInfo.getUserId(), 'we expect these ids to match');
        Test.stopTest();
    }

    @isTest 
    static void fullTest(){

        List<H8_Flow_Form_Section_Validation__mdt> testFlowSectionsValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
        testFlowSectionsValidations.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'childValidation')
            .addFieldValue('MasterLabel', 'childValidation')
            .addFieldValue('CustomErrorMessage__c', 'customErrorMessage')
            .addFieldValue('DataType__c', 'String')
            .addFieldValue('Disabled__c', false)
            .addFieldValue('FieldAPIName__c', 'FieldAPIName__c')
            .addFieldValue('FlowValidationType__c', 'flowValidationType')
            .addFieldValue('IsFlowValidation__c', false)
            .addFieldValue('Order__c', 10)
            .addFieldValue('Page__c', 'pageName')
            .addFieldValue('QuestionName__c', 'questionName')
            .addFieldValue('Use_Custom_Label__c', false)
            .addFieldValue('Validation_Value__c', 'validationValue')
            .getSingleMockMetaData());

        List<H8_Flow_Form_Section__mdt> testFlowSections = new List<H8_Flow_Form_Section__mdt>();
        testFlowSections.add((H8_Flow_Form_Section__mdt)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'childSectionchildSectionchildSection')
            .addFieldValue('MasterLabel', 'childSectionchildSectionchildSection')
            .addFieldValue('Flow_API_Name__c', 'sampleflowname')
            .addFieldValue('Icon_Name__c', 'utility:icon')
            .addFieldValue('Order__c', 10)
            .addFieldValue('Use_Custom_Label__c', false)
            .addChildren('H8_Flow_Form_Section_Validations__r', testFlowSectionsValidations)
            .getSingleMockMetaData());

        List<H8_Flow_Form__mdt> testFlowForms = new List<H8_Flow_Form__mdt>();
        testFlowForms.add((H8_Flow_Form__mdt)new MockMetaManager('H8_Flow_Form__mdt')
            .addFieldValue('MasterLabel', 'TestShareObjectKeyReferece')
            .addFieldValue('DeveloperName', 'TestShareObjectKeyReferece')
            .addFieldValue('Type__c', 'Application')
            .addFieldValue('Status__c', 'ACTIVE')
            .addFieldValue('Validation_Flow_API_Name__c', 'SampleFlow')
            .addChildren('H8_Flow_Form_Sections__r', testFlowSections)
            .getSingleMockMetaData());
        
        List<H8_Flow_Form_Section_Validation__mdt> testFlowSectionsValidationsExisting = new List<H8_Flow_Form_Section_Validation__mdt>();
        testFlowSectionsValidationsExisting.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'childValidation')
            .addFieldValue('MasterLabel', 'childValidation')
            .addFieldValue('CustomErrorMessage__c', 'customErrorMessage')
            .addFieldValue('DataType__c', 'String')
            .addFieldValue('Disabled__c', false)
            .addFieldValue('FieldAPIName__c', 'FieldAPIName__c')
            .addFieldValue('FlowValidationType__c', 'flowValidationType')
            .addFieldValue('IsFlowValidation__c', false)
            .addFieldValue('Order__c', 10)
            .addFieldValue('Page__c', 'pageName')
            .addFieldValue('QuestionName__c', 'questionName')
            .addFieldValue('Use_Custom_Label__c', false)
            .addFieldValue('Validation_Value__c', 'validationValue')
            .getSingleMockMetaData());

        List<H8_Flow_Form_Section__mdt> testFlowSectionsExisting = new List<H8_Flow_Form_Section__mdt>();
        testFlowSectionsExisting.add((H8_Flow_Form_Section__mdt)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'childSectionchildSectionchildSection')
            .addFieldValue('MasterLabel', 'childSectionchildSectionchildSection')
            .addFieldValue('Flow_API_Name__c', 'sampleflowname')
            .addFieldValue('Icon_Name__c', 'utility:icon')
            .addFieldValue('Order__c', 10)
            .addFieldValue('Use_Custom_Label__c', false)
            .addChildren('H8_Flow_Form_Section_Validations__r', testFlowSectionsValidationsExisting)
            .getSingleMockMetaData());

        List<H8_Flow_Form__mdt> testFlowFormsExisting = new List<H8_Flow_Form__mdt>();
        testFlowFormsExisting.add((H8_Flow_Form__mdt)new MockMetaManager('H8_Flow_Form__mdt')
            .addFieldValue('MasterLabel', 'TestShareObjectKeyReferece')
            .addFieldValue('DeveloperName', 'TestShareObjectKeyReferece')
            .addFieldValue('Type__c', 'Application')
            .addFieldValue('Status__c', 'ACTIVE')
            .addFieldValue('Validation_Flow_API_Name__c', 'SampleFlow')
            .addChildren('H8_Flow_Form_Sections__r', testFlowSectionsExisting)
            .getSingleMockMetaData());

        H8FlowFormCloneDeployment.testForm = testFlowForms[0];
        H8FlowFormCloneDeployment.nonUniqueMasterTestLabel = 'SampleFlow';
        H8FlowFormCloneDeployment.masterLabels.add('SampleFlow');
        H8FlowFormCloneDeployment.testFormValidations = testFlowSectionsValidationsExisting;
        H8FlowFormCloneDeployment.testFormSections = testFlowSectionsExisting;

        Test.startTest();
            Id asyncJobId = H8FlowFormCloneDeployment.cloneFlowForm('TestShareObjectKeyReferece','NewForm', 'NewForm');
            System.assertEquals(asyncJobId, UserInfo.getUserId(), 'we expect these ids to match');
        Test.stopTest();
    }

    @isTest 
    static void fullTestNoDuplicates(){

        List<H8_Flow_Form_Section_Validation__mdt> testFlowSectionsValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
        testFlowSectionsValidations.add((H8_Flow_Form_Section_Validation__mdt)new MockMetaManager('H8_Flow_Form_Section_Validation__mdt')
            .addFieldValue('MasterLabel', 'childValidation')
            .addFieldValue('MasterLabel', 'childValidation')
            .addFieldValue('CustomErrorMessage__c', 'customErrorMessage')
            .addFieldValue('DataType__c', 'String')
            .addFieldValue('Disabled__c', false)
            .addFieldValue('FieldAPIName__c', 'FieldAPIName__c')
            .addFieldValue('FlowValidationType__c', 'flowValidationType')
            .addFieldValue('IsFlowValidation__c', false)
            .addFieldValue('Order__c', 10)
            .addFieldValue('Page__c', 'pageName')
            .addFieldValue('QuestionName__c', 'questionName')
            .addFieldValue('Use_Custom_Label__c', false)
            .addFieldValue('Validation_Value__c', 'validationValue')
            .getSingleMockMetaData());

        List<H8_Flow_Form_Section__mdt> testFlowSections = new List<H8_Flow_Form_Section__mdt>();
        testFlowSections.add((H8_Flow_Form_Section__mdt)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'childSectionchildSectionchildSection')
            .addFieldValue('MasterLabel', 'childSectionchildSectionchildSection')
            .addFieldValue('Flow_API_Name__c', 'sampleflowname')
            .addFieldValue('Icon_Name__c', 'utility:icon')
            .addFieldValue('Order__c', 10)
            .addFieldValue('Use_Custom_Label__c', false)
            .addChildren('H8_Flow_Form_Section_Validations__r', testFlowSectionsValidations)
            .getSingleMockMetaData());

        List<H8_Flow_Form__mdt> testFlowForms = new List<H8_Flow_Form__mdt>();
        testFlowForms.add((H8_Flow_Form__mdt)new MockMetaManager('H8_Flow_Form__mdt')
            .addFieldValue('MasterLabel', 'TestShareObjectKeyReferece')
            .addFieldValue('DeveloperName', 'TestShareObjectKeyReferece')
            .addFieldValue('Type__c', 'Application')
            .addFieldValue('Status__c', 'ACTIVE')
            .addFieldValue('Validation_Flow_API_Name__c', 'SampleFlow')
            .addChildren('H8_Flow_Form_Sections__r', testFlowSections)
            .getSingleMockMetaData());

        H8FlowFormCloneDeployment.testForm = testFlowForms[0];
        
        Test.startTest();
            Id asyncJobId = H8FlowFormCloneDeployment.cloneFlowForm('TestShareObjectKeyReferece','NewForm', 'NewForm');
            System.assertEquals(asyncJobId, UserInfo.getUserId(), 'we expect these ids to match');
        Test.stopTest();
    }
}