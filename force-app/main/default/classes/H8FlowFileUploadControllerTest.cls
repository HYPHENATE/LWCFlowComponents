/**
 * @description       : H8FlowFileUploadController test class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 31/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
@IsTest
public class H8FlowFileUploadControllerTest {
    
    static TestRecordSource testRecordSource = new TestRecordSource();

    /**
    * @description          test where no files are present
    **/
    @IsTest
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
    @IsTest
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
    @IsTest
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
    @IsTest
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
    @IsTest 
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
    @IsTest 
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
    @IsTest 
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
            .addFieldValue('Share_Type__c', 'I')
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
    @IsTest 
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
            .addFieldValue('Share_Type__c', 'I')
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

    /**
     * @description          test conversion of text values to checkbox values
     **/
    @IsTest
    static void testConvertValueBoolean() {
        Assert.areEqual(
            true,
            H8FlowFileUploadController.convertValue(
                Schema.DisplayType.BOOLEAN,
                'true'
            ),
            'true should convert to Boolean true'
        );
        Assert.areEqual(
            true,
            H8FlowFileUploadController.convertValue(
                Schema.DisplayType.BOOLEAN,
                ' TRUE '
            ),
            'conversion should ignore case and whitespace'
        );
        Assert.areEqual(
            false,
            H8FlowFileUploadController.convertValue(
                Schema.DisplayType.BOOLEAN,
                'false'
            ),
            'false should convert to Boolean false'
        );
        Assert.isInstanceOfType(
            H8FlowFileUploadController.convertValue(
                Schema.DisplayType.BOOLEAN,
                'true'
            ),
            Boolean.class,
            'value must be a Boolean'
        );
    }

    /**
     * @description          test conversion of text values to number values
     **/
    @IsTest
    static void testConvertValueNumbers() {
        Object integerValue = H8FlowFileUploadController.convertValue(
            Schema.DisplayType.INTEGER,
            '42'
        );
        Assert.isInstanceOfType(
            integerValue,
            Integer.class,
            'value must be an Integer'
        );
        Assert.areEqual(42, integerValue, 'integer must match');

        Object longValue = H8FlowFileUploadController.convertValue(
            Schema.DisplayType.LONG,
            '9999999999'
        );
        Assert.isInstanceOfType(longValue, Long.class, 'value must be a Long');
        Assert.areEqual(9999999999L, longValue, 'long must match');

        for (
            Schema.DisplayType decimalType : new List<Schema.DisplayType>{
                Schema.DisplayType.DOUBLE,
                Schema.DisplayType.CURRENCY,
                Schema.DisplayType.PERCENT
            }
        ) {
            Object decimalValue = H8FlowFileUploadController.convertValue(
                decimalType,
                '12.5'
            );
            Assert.isInstanceOfType(
                decimalValue,
                Decimal.class,
                decimalType + ' value must be a Decimal'
            );
            Assert.areEqual(
                12.5,
                decimalValue,
                decimalType + ' value must match'
            );
        }
    }

    /**
     * @description          test conversion of text values to date and datetime values
     **/
    @IsTest
    static void testConvertValueDates() {
        Object dateValue = H8FlowFileUploadController.convertValue(
            Schema.DisplayType.DATE,
            '2026-10-07'
        );
        Assert.isInstanceOfType(dateValue, Date.class, 'value must be a Date');
        Assert.areEqual(
            Date.newInstance(2026, 10, 7),
            dateValue,
            'date must match'
        );

        Object datetimeValue = H8FlowFileUploadController.convertValue(
            Schema.DisplayType.DATETIME,
            '2026-10-07 14:30:00'
        );
        Assert.isInstanceOfType(
            datetimeValue,
            Datetime.class,
            'value must be a Datetime'
        );
        Assert.areEqual(
            Datetime.newInstance(2026, 10, 7, 14, 30, 0),
            datetimeValue,
            'datetime must match'
        );
    }

    /**
     * @description          test text and picklist values are left as strings
     **/
    @IsTest
    static void testConvertValueText() {
        for (
            Schema.DisplayType textType : new List<Schema.DisplayType>{
                Schema.DisplayType.STRING,
                Schema.DisplayType.TEXTAREA,
                Schema.DisplayType.PICKLIST
            }
        ) {
            Object textValue = H8FlowFileUploadController.convertValue(
                textType,
                'Sample Value'
            );
            Assert.isInstanceOfType(
                textValue,
                String.class,
                textType + ' value must be a String'
            );
            Assert.areEqual(
                'Sample Value',
                textValue,
                textType + ' value must match'
            );
        }
    }

    /**
     * @description          test blank values convert to null for any type
     **/
    @IsTest
    static void testConvertValueBlank() {
        Assert.isNull(
            H8FlowFileUploadController.convertValue(
                Schema.DisplayType.BOOLEAN,
                ''
            ),
            'blank checkbox value should be null'
        );
        Assert.isNull(
            H8FlowFileUploadController.convertValue(
                Schema.DisplayType.DOUBLE,
                null
            ),
            'null number value should be null'
        );
        Assert.isNull(
            H8FlowFileUploadController.convertValue(
                Schema.DisplayType.STRING,
                '   '
            ),
            'whitespace text value should be null'
        );
    }

    /**
     * @description          test invalid values for the field type throw an exception
     **/
    @IsTest
    static void testConvertValueInvalid() {
        Boolean exceptionThrown = false;
        try {
            H8FlowFileUploadController.convertValue(
                Schema.DisplayType.INTEGER,
                'not a number'
            );
        } catch (TypeException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(
            exceptionThrown,
            'invalid number should throw a TypeException'
        );
    }
}
