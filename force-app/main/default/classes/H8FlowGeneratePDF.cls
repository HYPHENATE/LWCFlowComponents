/**
 * @description       : invocable class to generate PDF files from HTML content in Flow
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-01-2026
 * @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8FlowGeneratePDF {
    
    @InvocableMethod(label='Generate PDF File' iconName='slds:standard:file')
    public static List<Response> generatePDFFile(List<Request> requests) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        for (Request request:requests) {
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = request.title.trim();
            contentVersion.PathOnClient = contentVersion.Title + '.pdf';
            contentVersion.VersionData = Blob.toPdf(request.html);

            if (request.recordId != null) {
                contentVersion.FirstPublishLocationId = request.recordId;
            }

            contentVersions.add(contentVersion);
        }

        insert contentVersions;

        List<Response> responses = new List<Response>();
        for (ContentVersion contentVersion:contentVersions) {
            Response response = new Response();
            response.contentVersionId = contentVersion.Id;
            responses.add(response);
        }
        return responses;
    }

    public class Request {
        @InvocableVariable(required=true)
        public String html;
        @InvocableVariable(required=false)
        public Id recordId;
        @InvocableVariable(required=true)
        public String title;
    }

    public class Response {
        @InvocableVariable
        public Id contentVersionId;
    }
}