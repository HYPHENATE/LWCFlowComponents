/**
 * @description       : H8FlowFormController test class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 05-09-2025
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8FlowFormControllerTest {
    
    /**
    * @description          test missing form
    **/
    @isTest 
    static void getNoFormPresent(){
        String jsonResponse = H8FlowFormController.getForm('DUMMY FORM', new List<String>());
        Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        Assert.isFalse((Boolean)jsonObjects.get('success'), 'we expect this to be false');
    }

    /**
    * @description          testing a form with no child records
    **/
    @isTest 
    static void getFormPresent(){

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

        H8FlowFormController.formTest = testRecords[0];
        H8FlowFormController.formSectionsTest = childList;

        String jsonResponse = H8FlowFormController.getForm('Form', new List<String>());
        Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        Assert.isTrue((Boolean)jsonObjects.get('success'), 'we expect this to be true');
    }

    /**
    * @description          testing a form with no child records
    **/
    @isTest 
    static void getFormPresentCustomLabel(){

        List<H8_Flow_Form_Section__mdt> childList = (List<H8_Flow_Form_Section__mdt>)new MockMetaManager('H8_Flow_Form_Section__mdt')
            .addFieldValue('MasterLabel', 'H8FFSNameTestLabel')
            .addFieldValue('DeveloperName', 'H8FFSNameTestLabel')
            .addFieldValue('Flow_API_Name__c', 'Contact')
            .addFieldValue('Icon_Name__c', 'Email')
            .addFieldValue('Order__c', '1')
            .addFieldValue('Id', 'SampleId')
            .addFieldValue('Use_Custom_Label__c', true)
            .getListMockMetaData();

        List<H8_Flow_Form__mdt> testRecords = (List<H8_Flow_Form__mdt>)new MockMetaManager('H8_Flow_Form__mdt')    
            .addFieldValue('MasterLabel', 'TestRecord')
            .addFieldValue('DeveloperName', 'TestRecord')
            .addChildren('H8_Flow_Form_Sections__r', childList)
            .getListMockMetaData();

        H8FlowFormController.formTest = testRecords[0];
        H8FlowFormController.formSectionsTest = childList;

        String jsonResponse = H8FlowFormController.getForm('Form', new List<String>());
        Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        Assert.isTrue((Boolean)jsonObjects.get('success'), 'we expect this to be true');
        List<Object> sections = (List<Object>)jsonObjects.get('sections');
        for(Object section:sections){
            Map<String, Object> sectionMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(section));
            String labelValue = (String)sectionMap.get('label');
            System.assertEquals(Label.get(null, 'H8FFSNameTestLabel'), labelValue, 'we expect the custom label to be used');
        }
    }
}