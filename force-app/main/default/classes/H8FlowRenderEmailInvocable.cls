/**
 * @description       : Invocable apex class to render email templates for use in Flows.
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-01-2026
 * @last modified by  : daniel@hyphen8.com
**/
@SuppressWarnings('PMD.OperationWithLimitsInLoop')
public with sharing class H8FlowRenderEmailInvocable {

    private static final Integer MAX_RENDERS_PER_INVOCATION = 50;

    
    @InvocableMethod(label='Render Email Template HTML' iconName='slds:standard:template'
        description='Renders an email template without sending, returning subject/HTML/text, including a sanitised HTML variant for display on screen.'
    )
    public static List<Response> renderEmailTemplate(List<Request> requests) {

        if (requests == null || requests.isEmpty()) {
            return new List<Response>();
        }

        if (requests.size() > MAX_RENDERS_PER_INVOCATION) {
            throw new IllegalArgumentException(
                'Too many template renders requested in a single transaction (' + requests.size() + '). ' +
                'This action is limited to ' + MAX_RENDERS_PER_INVOCATION + ' per invocation. ' +
                'Reduce batch size in the Flow or redesign to process asynchronously.'
            );
        }

        Map<String, Integer> firstIndexByKey = new Map<String, Integer>();
        List<String> keysByIndex = new List<String>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request r = requests[i];

            String key = String.valueOf(r.templateId) + '|' + String.valueOf(r.whoId) + '|' + String.valueOf(r.recordId);
            keysByIndex.add(key);

            if (!firstIndexByKey.containsKey(key)) {
                firstIndexByKey.put(key, i);
            }
        }

        Map<String, Response> responseByKey = new Map<String, Response>();

        for (String key : firstIndexByKey.keySet()) {
            Integer idx = firstIndexByKey.get(key);
            Request r = requests[idx];

            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(r.templateId, r.whoId, r.recordId);

            if (message == null) {
                throw new IllegalStateException('Template rendering returned null. Verify templateId, whoId, and recordId. (index ' + idx + ')');
            }

            String html = message.getHtmlBody();

            Response resp = new Response();
            resp.subject = message.getSubject();
            resp.htmlBody = html;
            resp.textBody = message.getPlainTextBody();
            resp.htmlBodyNoStyle = sanitizeBody(html);

            responseByKey.put(key, resp);
        }

        List<Response> results = new List<Response>();
        for (String key : keysByIndex) {
            results.add(responseByKey.get(key));
        }

        return results;
    }

    private static String sanitizeBody(String html) {
        if (String.isBlank(html)) {
            return html;
        }

        String cleaned = html;
        cleaned = cleaned.replaceAll('(?is)<style[^>]*>.*?</style>', '');
        cleaned = cleaned.replaceAll('(?s)<!--.*?-->', '');
        cleaned = cleaned.replaceAll('(?is)<link[^>]+rel\\s*=\\s*["\\\']?stylesheet["\\\']?[^>]*>', '');
        cleaned = cleaned.replace('p{margin-top:0px; margin-bottom:0px;}', '');
        cleaned = cleaned.replace('<style type="text/css">p{margin-top:0px; margin-bottom:0px;}</style>', '');
        cleaned = cleaned.replace('<style>p{margin-top:0px; margin-bottom:0px;}</style>', '');

        return cleaned.trim();
    }

    public class Request {
        @InvocableVariable(required=true)
        public Id templateId;
        @InvocableVariable
        public Id recordId;
        @InvocableVariable
        public Id whoId;
    }

    public class Response {
        @InvocableVariable(label='Subject')
        public String subject;
        @InvocableVariable(label='HTML Body (Original)')
        public String htmlBody;
        @InvocableVariable(label='HTML Body (No Style)')
        public String htmlBodyNoStyle;
        @InvocableVariable(label='Text Body')
        public String textBody;
    }
}