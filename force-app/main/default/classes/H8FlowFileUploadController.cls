/**
 * @description       : flow file upload controller
 *                      has to run without shared to support guest user access
 * @author            : daniel@hyphen8.com
 * @last modified on  : 08/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
public without sharing class H8FlowFileUploadController {
    
    /**
    * @description          encryption security to protect files being uploaded
    * @return               String 
    **/
    @AuraEnabled(cacheable = true)
    public static String getKey(){
        Blob key = Crypto.generateAesKey(256);
        String encodedKey = EncodingUtil.base64Encode(key);
        return encodedKey;
    }
        
    /**
    * @description          encryption security to protect files being uploaded
    * @param                recordId 
    * @param                encodedKey 
    * @return               String 
    **/
    @AuraEnabled(cacheable = true)
    public static String encrypt(String recordId, String encodedKey){
        Blob key = EncodingUtil.base64Decode(encodedKey);
        Blob value = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(recordId));
        String encodedValue = EncodingUtil.base64Encode(value);
        return encodedValue;
    }
    
    /**
    * @description          aura method to create contentVersions
    * @param                fileNames 
    * @param                encodedRecordId 
    * @param                fileType
    * @return               List<objFiles> 
    **/
    @AuraEnabled 
    public static List<objFiles> createContentVersions(List<String> fileNames, String encodedRecordId, String fileType){
        List<ContentVersion> versions = new List<ContentVersion>();
        for(String fileName : fileNames){
            Integer startOfExtension = fileName.lastIndexOf('.');
            ContentVersion version = new ContentVersion(
                Title = fileName.Substring(0,startOfExtension),
                PathOnClient = '/'+fileName,
                VersionData = Blob.valueOf(' '),
                IsMajorVersion = FALSE
                // Guest_Record_fileupload__c = encodedRecordId
            );
            versions.add(version);
        }
    
        List<Database.SaveResult> results = Database.insert(versions);
    
        List<Id> versionIds = new List<Id>();
        for(Database.SaveResult result : results){
            versionIds.add(result.getId());
        }
    
        Boolean isStandardUser = UserInfo.getUserType() == 'Standard';
        List<objFiles> objFiles = new List<objFiles>();
        for(ContentVersion version : [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension FROM ContentVersion WHERE Id IN :versionIds ORDER BY Id]){
            objFiles objFile = new objFiles();
            objFile.name = version.ContentDocument.Title +'.'+ version.ContentDocument.FileExtension;
            objFile.contentVersionId = version.Id;

            if(isStandardUser){
                objFile.documentId = version.ContentDocumentId;
            }
            
            objFiles.add(objFile);
        }

        return objFiles;
    }
    
    /**
    * @description              aura method to append data to content versions already created
    * @param                    versionId 
    * @param                    base64Data 
    **/
    @AuraEnabled 
    public static void appendDataToContentVersion(String versionId, String base64Data){
        ContentVersion vers = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :versionId];
        String existingVersionData = EncodingUtil.base64Encode(vers.VersionData);
        if(existingVersionData == 'IA=='){
            vers.VersionData = EncodingUtil.base64Decode(base64Data);
        } else {
            vers.VersionData = EncodingUtil.base64Decode(existingVersionData + base64Data);
        }
        update vers;
    }
        
    /**
    * @description              aura method to generate content document links
    * @param                    versIds 
    * @param                    encodedKey 
    * @param                    visibleToAllUsers 
    **/
    @AuraEnabled
    public static void createContentDocLink(List<String> versIds, String encodedKey, Boolean visibleToAllUsers){
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        // for(ContentVersion vers : [SELECT Id, ContentDocumentId, Guest_Record_fileupload__c FROM ContentVersion WHERE Id IN :versIds]){
        for(ContentVersion vers : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :versIds]){
            ContentDocumentLink link = new ContentDocumentLink(
                ContentDocumentId = vers.ContentDocumentId
                // LinkedEntityId = decrypt(vers.Guest_Record_fileupload__c, encodedKey)
            );
            if(visibleToAllUsers != null){
                if(visibleToAllUsers){
                    link.Visibility = 'AllUsers';
                }
            }
            links.add(link);
        }
        if(!links.isEmpty()){
            insert links;
        }
    }
    
    /**
    * @description              aura method to update files names
    * @param                    versIds 
    * @param                    fileName 
    **/
    @AuraEnabled
    public static void updateFileName(List<String> versIds, String fileName){
        List<ContentDocument> docs = new List<ContentDocument>();
        for(ContentVersion vers : [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentVersion WHERE Id IN :versIds]){
            if(vers.ContentDocument.Title != fileName){
                ContentDocument doc = new ContentDocument(
                    Id = vers.ContentDocumentId,
                    Title = fileName
                );
                docs.add(doc);
            }
        }
        if(!docs.isEmpty()){
            update docs;
        }
    }

    /**
    * @description              aura method to delete a content document
    * @param                    versId 
    **/
    @AuraEnabled
    public static void deleteContentDoc(String versId){
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :versId LIMIT 1];
        ContentDocument cd = new ContentDocument(Id=cv.ContentDocumentId);
        delete cd;
    }

    /**
    * @description              aura method to get existing files
    * @param                    recordId 
    * @param                    contentDocumentIds
    * @return                   List<objFiles> 
    **/
    @AuraEnabled
    public static List<objFiles> getExistingFiles(String recordId, List<String> contentDocumentIds){
        Boolean isStandardUser = UserInfo.getUserType() == 'Standard';
        Map<Id,objFiles> objFiles = new Map<Id,objFiles>();
        for(ContentDocumentLink link : [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]){
            if(contentDocumentIds.contains(link.ContentDocumentId)){
                objFiles files = new objFiles();
                files.name = link.ContentDocument.Title +'.'+ link.ContentDocument.FileExtension;
                if(isStandardUser){
                    files.documentId = link.ContentDocumentId;
                }
                objFiles.put(link.ContentDocumentId,files);
            }
        }
        for(ContentVersion vers : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :objFiles.keyset() AND IsLatest = TRUE]){
            if(contentDocumentIds.contains(vers.ContentDocumentId)){
                objFiles.get(vers.ContentDocumentId).contentVersionId = vers.Id;
            }
        }
        return objFiles.values();
    }

    public class objFiles{
        @AuraEnabled
        public string name;

        @AuraEnabled
        public string documentId;

        @AuraEnabled
        public string contentVersionId;
    }


    /**
    * @description              private method to decrypt our encrypted data
    * @param                    encodedValue 
    * @param                    encodedKey 
    * @return                   String 
    **/
    private static String decrypt(String encodedValue, String encodedKey){
        Blob key = EncodingUtil.base64Decode(encodedKey);
        Blob value = EncodingUtil.base64Decode(encodedValue);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', key, value);
        String recordId = decryptedBlob.toString();
        return recordId;
    }
}