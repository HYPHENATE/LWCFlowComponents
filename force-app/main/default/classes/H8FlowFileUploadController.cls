/**
 * @description       : flow file upload controller
 *                      has to run without shared to support guest user access or temp permission issues
 * @author            : daniel@hyphen8.com
 * @last modified on  : 31/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
public without sharing class H8FlowFileUploadController {

    private static H8_File_Upload_Configuration__mdt configurationRecord;
    public static H8_File_Upload_Configuration__mdt testConfigurationRecord;
    private static List<ContentVersion> contentVersions = new List<ContentVersion>();
    private static Set<Id> contentDocumentIdSet = new Set<Id>();

    /**
    * @description          method to update file data based on meta data configuration if available and for creation of content document links
    * @param                contentDocumentIds 
    * @param                configuration 
    * @param                recordId 
    **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled 
    public static void updateFileData(List<String> contentDocumentIds, String configuration, String recordId){
        getConfiguration(configuration);
        getContentDocumentIds(contentDocumentIds);
        if(null != recordId){    
            contentDocumentCreation(recordId);
        }

        if(null != configurationRecord){
            fileValuesSet();
        }
    }
    
    /**
    * @description          method to generate content document links
    * @param                recordId 
    **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    private static void contentDocumentCreation(String recordId){
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(Id contentDocumentId:contentDocumentIdSet){
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentDocumentId;
            contentDocumentLink.LinkedEntityId = recordId;
            if(null != configurationRecord){
                contentDocumentLink.Visibility = configurationRecord.ShareType__c;
            }
            contentDocumentLinks.add(contentDocumentLink);
        }
        insert contentDocumentLinks;
    }

    /**
    * @description          method to set field values or rename file
    **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    private static void fileValuesSet(){
        List<H8_File_Upload_Configuration_Field__mdt> childFieldUpdates = configurationRecord.H8_File_Upload_Configuration_Fields__r;
        if(childFieldUpdates.size() > 0){
            List<ContentVersion> contentVersionUpdates = new List<ContentVersion>();
            for(ContentVersion contentVersion:contentVersions){
                for(H8_File_Upload_Configuration_Field__mdt fieldUpdates:childFieldUpdates){
                    contentVersion.put(fieldUpdates.Custom_Field__r.QualifiedAPIName, fieldUpdates.Value__c);
                }
                if(null != configurationRecord.OverrideFileName__c){
                    contentVersion.Title = configurationRecord.OverrideFileName__c;
                }
                contentVersionUpdates.add(contentVersion);
            }
            update contentVersionUpdates;
        }
    }

    /**
    * @description                  method to process the content versions and get the relevant data
    * @param                        contentDocumentIds 
    **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    private static void getContentDocumentIds(List<String> contentDocumentIds){
        for(ContentVersion version:[SELECT Id, ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId IN:contentDocumentIds]){
            contentDocumentIdSet.add(version.ContentDocumentId);
            contentVersions.add(version);
        }
    }

    /**
    * @description                  method to pull in the metadata configuration
    * @param                        configuration 
    **/
    private static void getConfiguration(String configuration){
        try {
            configurationRecord = Test.isRunningTest() ? testConfigurationRecord : [SELECT Id, OverrideFileName__c, ShareType__c, 
                                                                                                (SELECT Id, Custom_Field__r.QualifiedAPIName, Value__c 
                                                                                                                FROM H8_File_Upload_Configuration_Fields__r) 
                                                                                                FROM H8_File_Upload_Configuration__mdt 
                                                                                                WHERE DeveloperName=:configuration 
                                                                                                LIMIT 1];
        } catch (Exception e){
            configurationRecord = new H8_File_Upload_Configuration__mdt();
        }
    }

    /**
    * @description                  aura method to delete a content document
    * @param                        contentVersionId 
    **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled
    public static void deleteContentDoc(String contentVersionId){
        try {
            ContentVersion contentVersion = [SELECT ContentDocumentId 
                                                        FROM ContentVersion 
                                                        WHERE Id=:contentVersionId 
                                                        LIMIT 1];
            ContentDocument contentDocument = new ContentDocument(Id=contentVersion.ContentDocumentId);
            delete contentDocument;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description              aura method to get existing files
    * @param                    contentDocumentIds
    * @return                   List<objFiles> 
    **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled
    public static String getExistingFiles(List<String> contentDocumentIds){
        List<ContentVersion> contentVersions = [SELECT Id, ContentModifiedDate, ContentSize, ContentDocumentId, ContentDocument.FileExtension, ContentDocument.Title FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds AND IsLatest = TRUE];
        return generateExistingFilesResponse(contentVersions);
    }

    /**
    * @description              method to generate our json for returning to the front end
    * @param                    contentVersions 
    * @return                   String 
    **/
    private static String generateExistingFilesResponse(List<ContentVersion> contentVersions){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('files');
        gen.writeStartArray();
        for(ContentVersion version:contentVersions){
            gen.writeStartObject();
                gen.writeStringField('name', version.ContentDocument.Title);
                gen.writeStringField('documentId', version.ContentDocumentId);
                gen.writeStringField('contentVersionId', version.Id);
                gen.writeStringField('fileExtension', version.ContentDocument.FileExtension);
                gen.writeStringField('contentDescription', getContentDescription(version));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
    * @description              method to get the content description for returning with the contentversion information
    * @param                    contentVersion 
    * @return                   String 
    **/
    private static String getContentDescription(ContentVersion contentVersion){
        Integer kbSize = contentVersion.ContentSize / 1000;
        return contentVersion.ContentModifiedDate + ' - ' + kbSize + 'KB - ' + contentVersion.ContentDocument.FileExtension; 
    }

}