/**
 * @description       : e signature controller for handling signature uploads
 * @author            : daniel@hyphen8.com
 * @last modified on  : 17-07-2025
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8SignatureController {

    @AuraEnabled 
    public static String processSignature(String recordId, String signatureName, String dataUrl){
        try {
            String base64Body = dataUrl.substringAfter(',');
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = signatureName;
            contentVersion.PathOnClient = signatureName + '.png';
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Body);
            contentVersion.FirstPublishLocationId = recordId; 
            insert contentVersion;
            return contentVersion.Id;
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.H8ESignatureProcessSignatureError + ' ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getBase64Image(Id contentVersionId) {
        try {
            ContentVersion cv = [SELECT VersionData
                                        FROM ContentVersion
                                        WHERE Id = :contentVersionId
                                        LIMIT 1];
            return EncodingUtil.base64Encode(cv.VersionData);
        } catch (Exception e){
            throw new AuraHandledException(System.label.H8ESignatureGetBase64ImageError + ' ' + e.getMessage());
        }
    }
}