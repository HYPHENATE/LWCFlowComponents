/**
 * @description       : H8FlowFormCloneController test class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 25-06-2025
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8FlowFormCloneControllerTest {
    
    @isTest 
    static void testNoFormMetadata(){
        Test.startTest();
            String jsonString = H8FlowFormCloneController.getFlowForms();
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            System.assertEquals(true, mapOfObject.containsKey('forms'), 'we always expect forms to be returned here');
            List<Object> forms = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('forms')));
            System.assertEquals(0, forms.size(), 'we expect 0 forms to be returned');
        Test.stopTest();
    }

    @isTest 
    static void testWithFormMetadata(){

        List<H8_Flow_Form__mdt> testFlowForms = new List<H8_Flow_Form__mdt>();
        testFlowForms.add((H8_Flow_Form__mdt)new MockMetaManager('H8_Flow_Form__mdt')
            .addFieldValue('MasterLabel', 'TestShareObjectKeyReferece')
            .addFieldValue('DeveloperName', 'TestShareObjectKeyReferece')
            .addFieldValue('Type__c', 'Application')
            .addFieldValue('Status__c', 'ACTIVE')
            .addFieldValue('Validation_Flow_API_Name__c', 'SampleFlow')
            .getSingleMockMetaData());

        H8FlowFormCloneController.testFlowForms = testFlowForms;


        Test.startTest();
            String jsonString = H8FlowFormCloneController.getFlowForms();
            Map<String, Object> mapOfObject = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            System.assertEquals(true, mapOfObject.containsKey('forms'), 'we always expect forms to be returned here');
            List<Object> forms = (List<Object>)JSON.deserializeUntyped(JSON.serialize(mapOfObject.get('forms')));
            System.assertEquals(1, forms.size(), 'we expect 1 forms to be returned');
        Test.stopTest();
    }
}