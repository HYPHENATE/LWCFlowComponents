/**
 * @description       : test class for H8FlowRenderEmailInvocable
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-01-2026
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8FlowRenderEmailInvocableTest {

    static TestRecordSource testRecordSource = new TestRecordSource();
    
    private static EmailTemplate getAnyTemplate() {
        List<EmailTemplate> templates = [SELECT Id, DeveloperName, Name, Subject
                                                FROM EmailTemplate
                                                WHERE IsActive = true
                                                ORDER BY LastModifiedDate DESC
                                                LIMIT 1];
        if (templates.isEmpty()) {
            return null;
        }
        return templates[0];
    }

    private static Id createWhoContact(Id accountId) {
        Contact contact = (Contact)testRecordSource.getObject(Contact.sObjectType) 
            .asVariant('FormValidation')
            .withOutInsert();
            contact.AccountId = accountId;
        insert contact;
        return contact.Id;
    }

    private static Id createWhatRecord() {
        Account account = (Account)testRecordSource.getObject(Account.sObjectType) 
            .asVariant('FormValidation')
        .withInsert();
        return account.Id;
    }

    @IsTest
    static void testRenderEmailTemplateHappyPathAndDedupe() {
        EmailTemplate tpl = getAnyTemplate();
        System.assertNotEquals(
            null,
            tpl,
            'No active EmailTemplate found in this org. Create/activate a template to run this test.'
        );

        Id whatId = createWhatRecord();
        Id whoId = createWhoContact(whatId);
        

        // Build 3 requests, where the first two are identical to exercise the de-dupe mapping
        List<H8FlowRenderEmailInvocable.Request> reqs = new List<H8FlowRenderEmailInvocable.Request>();

        H8FlowRenderEmailInvocable.Request r1 = new H8FlowRenderEmailInvocable.Request();
        r1.templateId = tpl.Id;
        r1.whoId = whoId;
        r1.recordId = whatId;
        reqs.add(r1);

        H8FlowRenderEmailInvocable.Request r2 = new H8FlowRenderEmailInvocable.Request();
        r2.templateId = tpl.Id;
        r2.whoId = whoId;
        r2.recordId = whatId;
        reqs.add(r2);

        H8FlowRenderEmailInvocable.Request r3 = new H8FlowRenderEmailInvocable.Request();
        r3.templateId = tpl.Id;
        r3.whoId = whoId;
        r3.recordId = whatId;
        reqs.add(r3);

        Test.startTest();
        List<H8FlowRenderEmailInvocable.Response> res =
            H8FlowRenderEmailInvocable.renderEmailTemplate(reqs);
        Test.stopTest();

        System.assertEquals(3, res.size(), 'Should return a response for each request in the same order.');

        for (H8FlowRenderEmailInvocable.Response one : res) {
            System.assertNotEquals(null, one, 'Response should never be null.');
            System.assertNotEquals(null, one.subject, 'Subject should be returned (may be blank depending on template).');
            // Bodies can be null depending on template type/content, so be tolerant:
            // but htmlBodyNoStyle should at least be present if htmlBody is present.
            if (one.htmlBody != null) {
                System.assertNotEquals(null, one.htmlBodyNoStyle, 'Sanitised body should be returned when HTML exists.');
                System.assert(one.htmlBodyNoStyle.length() <= one.htmlBody.length(),
                    'Sanitised body should not be longer than original in typical cases.');
            }
        }

        // If de-dupe worked, identical requests should have identical outputs
        System.assertEquals(res[0].subject, res[1].subject, 'Duplicate requests should map to the same rendered subject.');
        System.assertEquals(res[0].htmlBody, res[1].htmlBody, 'Duplicate requests should map to the same rendered HTML.');
        System.assertEquals(res[0].textBody, res[1].textBody, 'Duplicate requests should map to the same rendered text.');
    }

    @IsTest
    static void testTooManyRequestsGuardrail() {
        EmailTemplate tpl = getAnyTemplate();
        System.assertNotEquals(
            null,
            tpl,
            'No active EmailTemplate found in this org. Create/activate a template to run this test.'
        );

        Id whatId = createWhatRecord();
        Id whoId = createWhoContact(whatId);

        // MAX_RENDERS_PER_INVOCATION is 50 in the class under test; request 51
        List<H8FlowRenderEmailInvocable.Request> reqs = new List<H8FlowRenderEmailInvocable.Request>();
        for (Integer i = 0; i < 51; i++) {
            H8FlowRenderEmailInvocable.Request r = new H8FlowRenderEmailInvocable.Request();
            r.templateId = tpl.Id;
            r.whoId = whoId;
            r.recordId = whatId;
            reqs.add(r);
        }

        try {
            Test.startTest();
            H8FlowRenderEmailInvocable.renderEmailTemplate(reqs);
            Test.stopTest();
            System.assert(false, 'Expected an exception due to too many requests.');
        } catch (Exception e) {
            System.assert(
                e.getMessage().contains('Too many template renders requested'),
                'Expected guardrail message, got: ' + e.getMessage()
            );
        }
    }

    @IsTest
    static void testValidationMissingFields() {
        EmailTemplate tpl = getAnyTemplate();
        System.assertNotEquals(
            null,
            tpl,
            'No active EmailTemplate found in this org. Create/activate a template to run this test.'
        );

        Id whatId = createWhatRecord();
        Id whoId = createWhoContact(whatId);

        // Missing whoId
        H8FlowRenderEmailInvocable.Request bad1 = new H8FlowRenderEmailInvocable.Request();
        bad1.templateId = tpl.Id;
        bad1.recordId = whatId;
        bad1.whoId = null;

        try {
            H8FlowRenderEmailInvocable.renderEmailTemplate(
                new List<H8FlowRenderEmailInvocable.Request>{ bad1 }
            );
            System.assert(false, 'Expected an exception for missing whoId.');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('whoId is required'), 'Unexpected message: ' + e.getMessage());
        }

        // Missing recordId
        H8FlowRenderEmailInvocable.Request bad2 = new H8FlowRenderEmailInvocable.Request();
        bad2.templateId = tpl.Id;
        bad2.whoId = whoId;
        bad2.recordId = null;

        try {
            H8FlowRenderEmailInvocable.renderEmailTemplate(
                new List<H8FlowRenderEmailInvocable.Request>{ bad2 }
            );
            System.assert(false, 'Expected an exception for missing recordId.');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('recordId is required'), 'Unexpected message: ' + e.getMessage());
        }

        // Missing templateId
        H8FlowRenderEmailInvocable.Request bad3 = new H8FlowRenderEmailInvocable.Request();
        bad3.templateId = null;
        bad3.whoId = whoId;
        bad3.recordId = whatId;

        try {
            H8FlowRenderEmailInvocable.renderEmailTemplate(
                new List<H8FlowRenderEmailInvocable.Request>{ bad3 }
            );
            System.assert(false, 'Expected an exception for missing templateId.');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('templateId is required'), 'Unexpected message: ' + e.getMessage());
        }
    }

    @IsTest
    static void testNullOrEmptyRequestsReturnsEmpty() {
        Test.startTest();
        List<H8FlowRenderEmailInvocable.Response> res1 =
            H8FlowRenderEmailInvocable.renderEmailTemplate(null);
        List<H8FlowRenderEmailInvocable.Response> res2 =
            H8FlowRenderEmailInvocable.renderEmailTemplate(new List<H8FlowRenderEmailInvocable.Request>());
        Test.stopTest();

        System.assertEquals(0, res1.size(), 'Null input should return empty list.');
        System.assertEquals(0, res2.size(), 'Empty input should return empty list.');
    }
}