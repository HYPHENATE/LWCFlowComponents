/**
* @description       : Retrieves file payloads for ContentDocument or ContentVersion ids so client-side ZIP/PDF utilities can work without browser CORS issues.
* @author            : daniel@hyphen8.com
* @last modified on  : 04-08-2026
* @last modified by  : OpenAI
**/
public with sharing class H8FilePdfZipHelper {
    private static final String CONTENT_VERSION_PREFIX = '068';
    private static final String CONTENT_DOCUMENT_PREFIX = '069';

    public class FilePayload {
        @AuraEnabled public String requestedId;
        @AuraEnabled public Id contentDocumentId;
        @AuraEnabled public Id contentVersionId;
        @AuraEnabled public String fileName;
        @AuraEnabled public String fileExtension;
        @AuraEnabled public String base64Data;
        @AuraEnabled public String errorMessage;
    }

    /**
    * @description Retrieves file payloads for a supplied list of ContentDocument or ContentVersion ids.
    * @param fileIds Collection of ContentDocument or ContentVersion ids.
    * @return Ordered payload list aligned with the requested ids.
    **/
    @AuraEnabled
    public static List<FilePayload> getFilePayloads(List<String> fileIds) {
        List<String> requestedIds = fileIds == null ? new List<String>() : fileIds;
        Map<String, FilePayload> payloadsByRequestId = new Map<String, FilePayload>();
        Set<Id> contentVersionIds = new Set<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();

        for (String requestedId : requestedIds) {
            FilePayload payload = new FilePayload();
            payload.requestedId = requestedId;
            payloadsByRequestId.put(requestedId, payload);

            String normalizedId = String.isBlank(requestedId) ? null : requestedId.trim();
            if (String.isBlank(normalizedId)) {
                payload.errorMessage = 'File id is blank.';
                continue;
            }

            if (normalizedId.startsWith(CONTENT_VERSION_PREFIX)) {
                Id contentVersionId = tryParseId(normalizedId);
                if (contentVersionId == null) {
                    payload.errorMessage = 'Invalid ContentVersion id.';
                    continue;
                }
                contentVersionIds.add(contentVersionId);
            } else if (normalizedId.startsWith(CONTENT_DOCUMENT_PREFIX)) {
                Id contentDocumentId = tryParseId(normalizedId);
                if (contentDocumentId == null) {
                    payload.errorMessage = 'Invalid ContentDocument id.';
                    continue;
                }
                contentDocumentIds.add(contentDocumentId);
            } else {
                payload.errorMessage = 'Unsupported file id prefix.';
            }
        }

        Map<Id, ContentDocument> contentDocumentsById = contentDocumentIds.isEmpty()
            ? new Map<Id, ContentDocument>()
            : new Map<Id, ContentDocument>([
                SELECT Id, LatestPublishedVersionId
                FROM ContentDocument
                WHERE Id IN :contentDocumentIds
                WITH USER_MODE
            ]);

        for (String requestedId : requestedIds) {
            FilePayload payload = payloadsByRequestId.get(requestedId);
            if (payload == null || payload.errorMessage != null || String.isBlank(requestedId)) {
                continue;
            }

            String normalizedId = requestedId.trim();
            if (!normalizedId.startsWith(CONTENT_DOCUMENT_PREFIX)) {
                continue;
            }

            Id contentDocumentId = tryParseId(normalizedId);
            ContentDocument contentDocument = contentDocumentId == null ? null : contentDocumentsById.get(contentDocumentId);
            if (contentDocument == null || contentDocument.LatestPublishedVersionId == null) {
                payload.errorMessage = 'ContentDocument not found or has no latest published version.';
                continue;
            }

            payload.contentDocumentId = contentDocument.Id;
            payload.contentVersionId = contentDocument.LatestPublishedVersionId;
            contentVersionIds.add(contentDocument.LatestPublishedVersionId);
        }

        Map<Id, ContentVersion> contentVersionsById = contentVersionIds.isEmpty()
            ? new Map<Id, ContentVersion>()
            : new Map<Id, ContentVersion>([
                SELECT Id, Title, FileExtension, ContentDocumentId, VersionData
                FROM ContentVersion
                WHERE Id IN :contentVersionIds
                WITH USER_MODE
            ]);

        List<FilePayload> results = new List<FilePayload>();
        for (String requestedId : requestedIds) {
            FilePayload payload = payloadsByRequestId.get(requestedId);
            if (payload == null) {
                continue;
            }
            if (payload.errorMessage != null || String.isBlank(requestedId)) {
                results.add(payload);
                continue;
            }

            String normalizedId = requestedId.trim();
            if (normalizedId.startsWith(CONTENT_VERSION_PREFIX)) {
                Id contentVersionId = tryParseId(normalizedId);
                ContentVersion contentVersion = contentVersionId == null ? null : contentVersionsById.get(contentVersionId);
                if (contentVersion == null) {
                    payload.errorMessage = 'ContentVersion not found.';
                    results.add(payload);
                    continue;
                }
                applyContentVersion(payload, contentVersion);
            } else if (normalizedId.startsWith(CONTENT_DOCUMENT_PREFIX)) {
                ContentVersion contentVersion = payload.contentVersionId == null ? null : contentVersionsById.get(payload.contentVersionId);
                if (contentVersion == null) {
                    payload.errorMessage = 'Latest published ContentVersion not found.';
                    results.add(payload);
                    continue;
                }
                applyContentVersion(payload, contentVersion);
            }

            results.add(payload);
        }

        return results;
    }

    private static void applyContentVersion(FilePayload payload, ContentVersion contentVersion) {
        payload.contentVersionId = contentVersion.Id;
        payload.contentDocumentId = contentVersion.ContentDocumentId;
        payload.fileExtension = contentVersion.FileExtension;
        payload.fileName = buildFileName(contentVersion);
        payload.base64Data = EncodingUtil.base64Encode(contentVersion.VersionData);
    }

    private static String buildFileName(ContentVersion contentVersion) {
        String extension = String.isBlank(contentVersion.FileExtension)
            ? ''
            : '.' + contentVersion.FileExtension;
        return contentVersion.Title + extension;
    }

    private static Id tryParseId(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        try {
            return Id.valueOf(value);
        } catch (Exception ex) {
            return null;
        }
    }
}
