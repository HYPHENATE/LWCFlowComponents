/**
 * @description       : this class performs the actual clone and deployment of the form clone
 * @author            : daniel@hyphen8.com
 * @last modified on  : 25-06-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowFormCloneDeployment {

    public static Set<String> masterLabels = new Set<String>();
    public static String nonUniqueMasterTestLabel;
    public static List<H8_Flow_Form_Section_Validation__mdt> testFormValidations = new List<H8_Flow_Form_Section_Validation__mdt>();
    public static List<H8_Flow_Form_Section__mdt> testFormSections = new List<H8_Flow_Form_Section__mdt>();
    public static H8_Flow_Form__mdt testForm;
    
    /**
    * @description          method that supports the clone of metadata and their child / grandchild records
    * @param                sourceDeveloperName 
    * @param                newMasterLabel 
    * @param                newDeveloperName 
    **/
    @AuraEnabled
    public static void cloneFlowForm(String sourceDeveloperName, String newMasterLabel, String newDeveloperName) {
        if (String.isBlank(sourceDeveloperName) || String.isBlank(newMasterLabel) || String.isBlank(newDeveloperName)) {
            throw new AuraHandledException('All inputs are required to clone the form.');
        }
        getMasterLabels();

        H8_Flow_Form__mdt sourceForm = !Test.isRunningTest() ?[
            SELECT Id, DeveloperName, MasterLabel, Type__c, Status__c, Validation_Flow_API_Name__c,
                (SELECT DeveloperName, MasterLabel, Flow_API_Name__c, Icon_Name__c, Order__c, Use_Custom_Label__c, H8_Flow_Form__c,
                    (SELECT DeveloperName, MasterLabel, CustomErrorMessage__c, DataType__c, Disabled__c, FieldAPIName__c,
                            FlowValidationType__c, IsFlowValidation__c, Order__c, Page__c, QuestionName__c, Use_Custom_Label__c, Validation_Value__c
                        FROM H8_Flow_Form_Section_Validations__r)
                    FROM H8_Flow_Form_Sections__r)
            FROM H8_Flow_Form__mdt
            WHERE DeveloperName = :sourceDeveloperName
            LIMIT 1
        ] : testForm;

        Metadata.CustomMetadata newMetadata = new Metadata.CustomMetadata();
        newMetadata.fullName = 'H8_Flow_Form__mdt.' + newDeveloperName;
        newMetadata.label = newMasterLabel;

        newMetadata.values = new List<Metadata.CustomMetadataValue>{
            buildCMDTValue('Type__c', sourceForm.Type__c, 'String'),
            buildCMDTValue('Status__c', sourceForm.Status__c, 'String'),
            buildCMDTValue('Validation_Flow_API_Name__c', sourceForm.Validation_Flow_API_Name__c, 'String')
        };

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(newMetadata);

        for (H8_Flow_Form_Section__mdt section : sourceForm.H8_Flow_Form_Sections__r) {
            Metadata.CustomMetadata newSection = new Metadata.CustomMetadata();
            String uniqueDevName = getUniqueName(newDeveloperName, section.DeveloperName);
            if(masterLabels.contains(uniqueDevName)){
                uniqueDevName = regenerateUnique(newDeveloperName, section.DeveloperName);
            } else {
                masterLabels.add(uniqueDevName);
            }
            newSection.fullName = 'H8_Flow_Form_Section__mdt.' + uniqueDevName;
            newSection.label = section.MasterLabel;

            newSection.values = new List<Metadata.CustomMetadataValue>{
                buildCMDTValue('Flow_API_Name__c', section.Flow_API_Name__c, 'String'),
                buildCMDTValue('Icon_Name__c', section.Icon_Name__c, 'String'),
                buildCMDTValue('Order__c', section.Order__c, 'String'),
                buildCMDTValue('Use_Custom_Label__c', section.Use_Custom_Label__c, 'Boolean'),
                buildCMDTValue('H8_Flow_Form__c', newDeveloperName, 'String')
            };

            mdContainer.addMetadata(newSection);
            for (H8_Flow_Form_Section_Validation__mdt validation : section.H8_Flow_Form_Section_Validations__r) {
                Metadata.CustomMetadata newValidation = new Metadata.CustomMetadata();
                String validationUniqueName = getUniqueName(uniqueDevName, validation.DeveloperName);
                if(masterLabels.contains(validationUniqueName)){
                    validationUniqueName = regenerateUnique(uniqueDevName, validation.DeveloperName);
                } else {
                    masterLabels.add(validationUniqueName);
                }
                newValidation.fullName = 'H8_Flow_Form_Section_Validation__mdt.' + validationUniqueName;
                newValidation.label = validation.MasterLabel;

                newValidation.values = new List<Metadata.CustomMetadataValue>{
                    buildCMDTValue('CustomErrorMessage__c', validation.CustomErrorMessage__c, 'String'),
                    buildCMDTValue('DataType__c', validation.DataType__c, 'String'),
                    buildCMDTValue('Disabled__c', validation.Disabled__c, 'Boolean'),
                    buildCMDTValue('FieldAPIName__c', validation.FieldAPIName__c, 'String'),
                    buildCMDTValue('FlowValidationType__c', validation.FlowValidationType__c, 'String'),
                    buildCMDTValue('IsFlowValidation__c', validation.IsFlowValidation__c, 'Boolean'),
                    buildCMDTValue('Order__c', validation.Order__c, 'String'),
                    buildCMDTValue('Page__c', validation.Page__c, 'String'),
                    buildCMDTValue('QuestionName__c', validation.QuestionName__c, 'String'),
                    buildCMDTValue('Use_Custom_Label__c', validation.Use_Custom_Label__c, 'Boolean'),
                    buildCMDTValue('Validation_Value__c', validation.Validation_Value__c, 'String'),
                    buildCMDTValue('H8_Flow_Form_Section__c', uniqueDevName, 'String')
                };

                mdContainer.addMetadata(newValidation);
            }
        }

        Id asyncJobId = !Test.isRunningTest() ? Metadata.Operations.enqueueDeployment(mdContainer, null) : UserInfo.getUserId();
    }

    /**
    * @description          helper for setting values within the metadata fields
    * @param                field 
    * @param                value 
    * @param                dataType 
    * @return               Metadata.CustomMetadataValue 
    **/
    private static Metadata.CustomMetadataValue buildCMDTValue(String field, Object value, String dataType) {
        Metadata.CustomMetadataValue val = new Metadata.CustomMetadataValue();
        val.field = field;
        if(dataType == 'String'){
            val.value = value != null ? String.valueOf(value) : '';
        } else if(dataType == 'Boolean'){
            val.value = value;
        }
        return val;
    }

    /**
    * @description          helper to ensure the developer name is unique
    * @param                newName 
    * @param                originalName 
    * @return               String 
    **/
    private static String getUniqueName(String newName, String originalName){
        String baseName = newName + originalName;
        baseName = baseName.length() > 30 ? baseName.substring(0, 30) : baseName;
        String uniqueSuffix = String.valueOf(Math.abs(Crypto.getRandomInteger())).substring(0, 6);
        String uniqueDevName = baseName + uniqueSuffix;
        uniqueDevName = uniqueDevName.length() > 40 ? uniqueDevName.substring(0, 40) : uniqueDevName;
        return (Test.isRunningTest() && null != nonUniqueMasterTestLabel) ? nonUniqueMasterTestLabel : uniqueDevName;
    }

    /**
    * @description          helper to ensure the developer name is unique
    * @param                newName 
    * @param                uniqueDevName 
    * @return               String 
    **/
    private static String regenerateUnique(String newName, String uniqueDevName){
        String uniqueName;
        for(Integer i=0;i<20;i++){
            uniqueName = getUniqueName(newName, uniqueDevName);
            if(!masterLabels.contains(uniqueName)){
                masterLabels.add(uniqueName);
                break;
            }
        }
        return uniqueName;
    }

    /**
    * @description          method to pull in and store all unique names currently within the system
    **/
    private static void getMasterLabels(){
        List<H8_Flow_Form_Section__mdt> formSections = !Test.isRunningTest() ? [SELECT MasterLabel, DeveloperName FROM H8_Flow_Form_Section__mdt] : testFormSections;
        System.debug('formSections > ' + formSections);
        for(H8_Flow_Form_Section__mdt section:formSections){
            masterLabels.add(section.DeveloperName);
        }
        List<H8_Flow_Form_Section_Validation__mdt> formValidations = !Test.isRunningTest() ? [SELECT MasterLabel, DeveloperName FROM H8_Flow_Form_Section_Validation__mdt] : testFormValidations;
        System.debug('formValidations > ' + formValidations);
        for(H8_Flow_Form_Section_Validation__mdt validation:formValidations){
            masterLabels.add(validation.DeveloperName);
        }
    }
}