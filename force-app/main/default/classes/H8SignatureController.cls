/**
 * @description       : e signature controller for handling signature uploads
 * @author            : daniel@hyphen8.com
 * @last modified on  : 17-07-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8SignatureController {

    private static ContentVersion contentVersion;
    
    @AuraEnabled 
    public static String processSignature(String recordId, String signatureName, String dataUrl){
        try {
            createContentVersion(recordId, signatureName, dataUrl);
            Id contentVersionId = insertContentVersion();
            return contentVersionId;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to process signature: ' + e.getMessage());
        }
    }

    private static void createContentVersion(String recordId, String signatureName, String dataUrl){
        String base64Body = dataUrl.substringAfter(',');
        contentVersion = new ContentVersion();
        contentVersion.Title = signatureName;
        contentVersion.PathOnClient = signatureName + '.png';
        contentVersion.VersionData = EncodingUtil.base64Decode(base64Body);
        contentVersion.FirstPublishLocationId = recordId; 
    }

    private static Id insertContentVersion(){
        insert contentVersion;
        return contentVersion.Id;
    }
}