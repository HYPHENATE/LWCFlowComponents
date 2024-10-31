/**
 * @description       : H8FlowFileUploadController test class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 31/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8FlowFileUploadControllerTest {
    
    static TestRecordSource testRecordSource = new TestRecordSource();

    /**
    * @description          test where no files are present
    **/
    @isTest
    static void getFilesNoFilesPresent(){
        Test.startTest();
            String files = H8FlowFileUploadController.getExistingFiles(new List<String>());
            Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(files);
            List<Object> filesList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(jsonObjects.get('files')));
            Assert.areEqual(0, filesList.size(), 'we never expect this list to have any files present');
        Test.stopTest();
    }

    /**
    * @description          test where files are present
    **/
    @isTest
    static void getFilesFilesPresent(){

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'Test';
        contentVersion.PathOnClient = 'Test.jpg';
        contentVersion.versionData = EncodingUtil.base64Decode('Test Content');
        insert contentVersion;

        Id contentDocumentId = [SELECT Id, ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE Id=:contentVersion.Id 
                                                LIMIT 1].ContentDocumentId;

        Test.startTest();
            String files = H8FlowFileUploadController.getExistingFiles(new List<String>{contentDocumentId});
            Map<String, Object> jsonObjects = (Map<String, Object>)JSON.deserializeUntyped(files);
            List<Object> filesList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(jsonObjects.get('files')));
            Assert.areEqual(1, filesList.size(), 'we only expect 1 file present');
        Test.stopTest();
    }

    /**
    * @description          test where docid is present
    **/
    @isTest
    static void deleteDocIdPresent(){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'Test';
        contentVersion.PathOnClient = 'Test.jpg';
        contentVersion.versionData = EncodingUtil.base64Decode('Test Content');
        insert contentVersion;

        Test.startTest();
            H8FlowFileUploadController.deleteContentDoc(contentVersion.Id);
            Assert.areEqual(0, [SELECT COUNT() FROM ContentVersion], 'we never expect there to be a content version here');
        Test.stopTest();
    }

    /**
    * @description          test where wrong type of id is provided
    **/
    @isTest
    static void deleteDocIdWrong(){
        Test.startTest();
            try {
                H8FlowFileUploadController.deleteContentDoc(UserInfo.getUserId());
            } catch (Exception e){
                Assert.isTrue(true, 'we expect to get here');
            }
        Test.stopTest();
    }

    /**
    * @description          test updating a file with no recordId or configuration
    **/
    @isTest 
    static void testUpdateNoRecordIdConfiguration(){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'Test';
        contentVersion.PathOnClient = 'Test.jpg';
        contentVersion.versionData = EncodingUtil.base64Decode('Test Content');
        insert contentVersion;

        Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id LIMIT 1].ContentDocumentId;

        Test.startTest();
            H8FlowFileUploadController.updateFileData(new List<String>{contentDocumentId}, null, null);
            List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: UserInfo.getUserId()];
            Assert.areEqual(1, links.size(), 'we expect to have a link created');
        Test.stopTest();
    }

    /**
    * @description          test updating a record with a recordId and no configuration
    **/
    @isTest 
    static void testUpdateWithRecordIdNoConfiguration(){
        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
        .asVariant('FormValidation')
        .withInsert();

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'Test';
        contentVersion.PathOnClient = 'Test.jpg';
        contentVersion.versionData = EncodingUtil.base64Decode('Test Content');
        insert contentVersion;

        Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id LIMIT 1].ContentDocumentId;

        Test.startTest();
            H8FlowFileUploadController.updateFileData(new List<String>{contentDocumentId}, null, account.Id);
            List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: account.Id];
            Assert.areEqual(1, links.size(), 'we expect to have a link created');
        Test.stopTest();
    }

    /**
    * @description          test with a record and also configuration
    **/
    @isTest 
    static void testUpdateWithRecordIdAndConfiguration(){
        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
        .asVariant('FormValidation')
        .withInsert();

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'Test';
        contentVersion.PathOnClient = 'Test.jpg';
        contentVersion.versionData = EncodingUtil.base64Decode('Test Content');
        insert contentVersion;

        Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id LIMIT 1].ContentDocumentId;

        List<H8_File_Upload_Configuration_Field__mdt> childList = (List<H8_File_Upload_Configuration_Field__mdt>)new MockMetaManager('H8_File_Upload_Configuration_Field__mdt')
            .addFieldValue('MasterLabel', 'FirstChild')
            .addFieldValue('DeveloperName', 'FirstChild')
            .addEntityDefinition('Content_Version_Object__c', 'ContentVersion')
            .addFieldDefinition('Custom_Field__c', 'Description')
            .addFieldValue('Value__c', 'Sample File')
            .addFieldValue('Id', 'SampleId')
            .getListMockMetaData();

        List<H8_File_Upload_Configuration__mdt> testRecords = (List<H8_File_Upload_Configuration__mdt>)new MockMetaManager('H8_File_Upload_Configuration__mdt')    
            .addFieldValue('MasterLabel', 'TestRecord')
            .addFieldValue('DeveloperName', 'TestRecord')
            .addFieldValue('ShareType__c', 'AllUsers')
            .addFieldValue('OverrideFileName__c', 'DummyFile')
            .addChildren('H8_File_Upload_Configuration_Fields__r', childList)
            .getListMockMetaData();

        H8FlowFileUploadController.testConfigurationRecord = testRecords[0];

        Test.startTest();
            H8FlowFileUploadController.updateFileData(new List<String>{contentDocumentId}, 'Bank_File', account.Id);
            List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: account.Id];
            Assert.areEqual(1, links.size(), 'we expect to have a link created');
            Assert.areEqual('Sample File', [SELECT Description FROM ContentVersion WHERE Id=:contentVersion.Id LIMIT 1].Description, 'this must match');
        Test.stopTest();
    }

    /**
    * @description          test with no record but has configuration
    **/
    @isTest 
    static void testUpdateNoRecordIdWithConfiguration(){
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.title = 'Test';
        contentVersion.PathOnClient = 'Test.jpg';
        contentVersion.versionData = EncodingUtil.base64Decode('Test Content');
        insert contentVersion;

        Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:contentVersion.Id LIMIT 1].ContentDocumentId;

        List<H8_File_Upload_Configuration_Field__mdt> childList = (List<H8_File_Upload_Configuration_Field__mdt>)new MockMetaManager('H8_File_Upload_Configuration_Field__mdt')
            .addFieldValue('MasterLabel', 'FirstChild')
            .addFieldValue('DeveloperName', 'FirstChild')
            .addEntityDefinition('Content_Version_Object__c', 'ContentVersion')
            .addFieldDefinition('Custom_Field__c', 'Description')
            .addFieldValue('Value__c', 'Sample File')
            .addFieldValue('Id', 'SampleId')
            .getListMockMetaData();

        List<H8_File_Upload_Configuration__mdt> testRecords = (List<H8_File_Upload_Configuration__mdt>)new MockMetaManager('H8_File_Upload_Configuration__mdt')    
            .addFieldValue('MasterLabel', 'TestRecord')
            .addFieldValue('DeveloperName', 'TestRecord')
            .addFieldValue('ShareType__c', 'AllUsers')
            .addFieldValue('OverrideFileName__c', 'DummyFile')
            .addChildren('H8_File_Upload_Configuration_Fields__r', childList)
            .getListMockMetaData();

        H8FlowFileUploadController.testConfigurationRecord = testRecords[0];

        Test.startTest();
            H8FlowFileUploadController.updateFileData(new List<String>{contentDocumentId}, 'Bank_File', null);
            List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: UserInfo.getUserId()];
            Assert.areEqual(1, links.size(), 'we expect to have a link created');
            Assert.areEqual('Sample File', [SELECT Description FROM ContentVersion WHERE Id=:contentVersion.Id LIMIT 1].Description, 'this must match');
        Test.stopTest();
    }
}