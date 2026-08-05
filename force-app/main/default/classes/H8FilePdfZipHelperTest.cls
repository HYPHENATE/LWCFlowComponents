/**
* @description       : Tests H8FilePDFZipHelper file payload retrieval for ContentDocument and ContentVersion inputs.
* @author            : daniel@hyphen8.com
* @last modified on  : 04-08-2026
* @last modified by  : OpenAI
**/
@IsTest(testFor='ApexClass:H8FilePdfZipHelper')
private class H8FilePdfZipHelperTest {
    @IsTest
    static void getFilePayloadsReturnsOrderedPayloadsForDocumentAndVersionIds() {
        ContentVersion initialVersion = createContentVersion(
            'ReusablePdf',
            'ReusablePdf.pdf',
            Blob.valueOf('PDF version 1')
        );
        insert new ContentVersion(
            ContentDocumentId = initialVersion.ContentDocumentId,
            Title = 'ReusablePdf',
            PathOnClient = 'ReusablePdf.pdf',
            VersionData = Blob.valueOf('PDF version 2')
        );

        ContentVersion latestVersion = [
            SELECT Id, ContentDocumentId, Title, FileExtension, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :initialVersion.ContentDocumentId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        ContentVersion docxVersion = createContentVersion(
            'ReusableTemplate',
            'ReusableTemplate.docx',
            Blob.valueOf('DOCX body')
        );

        ContentVersion deletedVersion = createContentVersion(
            'DeletedTemplate',
            'DeletedTemplate.pdf',
            Blob.valueOf('Deleted body')
        );
        delete [SELECT Id FROM ContentDocument WHERE Id = :deletedVersion.ContentDocumentId LIMIT 1];

        Test.startTest();
        List<H8FilePdfZipHelper.FilePayload> results = H8FilePdfZipHelper.getFilePayloads(new List<String>{
            String.valueOf(initialVersion.ContentDocumentId),
            String.valueOf(docxVersion.Id),
            'not-an-id',
            String.valueOf(deletedVersion.Id)
        });
        Test.stopTest();

        Assert.areEqual(4, results.size(), 'The helper should return one result per requested id.');

        H8FilePdfZipHelper.FilePayload documentPayload = results[0];
        Assert.areEqual(String.valueOf(initialVersion.ContentDocumentId), documentPayload.requestedId);
        Assert.areEqual(initialVersion.ContentDocumentId, documentPayload.contentDocumentId);
        Assert.areEqual(latestVersion.Id, documentPayload.contentVersionId, 'ContentDocument input should resolve to the latest published version.');
        Assert.areEqual('ReusablePdf.pdf', documentPayload.fileName);
        Assert.areEqual('pdf', documentPayload.fileExtension);
        Assert.areEqual(EncodingUtil.base64Encode(Blob.valueOf('PDF version 2')), documentPayload.base64Data);
        Assert.areEqual(null, documentPayload.errorMessage);

        H8FilePdfZipHelper.FilePayload versionPayload = results[1];
        Assert.areEqual(String.valueOf(docxVersion.Id), versionPayload.requestedId);
        Assert.areEqual(docxVersion.ContentDocumentId, versionPayload.contentDocumentId);
        Assert.areEqual(docxVersion.Id, versionPayload.contentVersionId);
        Assert.areEqual('ReusableTemplate.docx', versionPayload.fileName);
        Assert.areEqual('docx', versionPayload.fileExtension);
        Assert.areEqual(EncodingUtil.base64Encode(Blob.valueOf('DOCX body')), versionPayload.base64Data);
        Assert.areEqual(null, versionPayload.errorMessage);

        H8FilePdfZipHelper.FilePayload invalidPayload = results[2];
        Assert.areEqual('Unsupported file id prefix.', invalidPayload.errorMessage);
        Assert.areEqual(null, invalidPayload.base64Data);

        H8FilePdfZipHelper.FilePayload missingPayload = results[3];
        Assert.areEqual('ContentVersion not found.', missingPayload.errorMessage);
        Assert.areEqual(null, missingPayload.base64Data);
    }

    @IsTest
    static void getFilePayloadsHandlesBlankAndMissingDocumentInputs() {
        Test.startTest();
        List<H8FilePdfZipHelper.FilePayload> results = H8FilePdfZipHelper.getFilePayloads(new List<String>{
            null,
            '',
            '069000000000000AAA'
        });
        Test.stopTest();

        Assert.areEqual(3, results.size(), 'Blank and missing requests should still return aligned results.');
        Assert.areEqual(null, results[0].requestedId);
        Assert.areEqual('File id is blank.', results[0].errorMessage);
        Assert.areEqual('', results[1].requestedId);
        Assert.areEqual('File id is blank.', results[1].errorMessage);
        Assert.areEqual(
            'ContentDocument not found or has no latest published version.',
            results[2].errorMessage,
            'A missing ContentDocument should return an item-level error rather than throwing.'
        );
    }

    private static ContentVersion createContentVersion(String title, String pathOnClient, Blob versionData) {
        ContentVersion contentVersion = new ContentVersion(
            Title = title,
            PathOnClient = pathOnClient,
            VersionData = versionData
        );
        insert contentVersion;

        return [
            SELECT Id, ContentDocumentId, Title, FileExtension, VersionData
            FROM ContentVersion
            WHERE Id = :contentVersion.Id
            LIMIT 1
        ];
    }
}
