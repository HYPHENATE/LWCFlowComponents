/**
 * @description       : Test class for H8DataFetcherObjectPickerController
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-04-2026
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8DataFetcherObjectPickerControllerTest {
    private final static String TEST_OBJECT_TYPE_LEAD = 'Lead';
    private final static String TEST_OBJECT_PICKLIST_FIELD = 'LeadSource';

    @isTest
    public static void testGetPicklistValues() {
        List<H8DataFetcherObjectPickerController.Member> memberList = H8DataFetcherObjectPickerController.getPicklistValues(TEST_OBJECT_TYPE_LEAD, TEST_OBJECT_PICKLIST_FIELD);
        Assert.areNotEqual(memberList, null, 'Expected non-null list of picklist values');
    }

    @isTest
    public static void testGetObjects() {
        List<H8DataFetcherObjectPickerController.Member> memberList = H8DataFetcherObjectPickerController.getObjects(new List<String>{
                TEST_OBJECT_TYPE_LEAD
        });
        Assert.areEqual(1, memberList.size(), 'Expected one object in the list');
        Assert.areEqual(TEST_OBJECT_TYPE_LEAD, memberList[0].value, 'Expected lead object');
        memberList = H8DataFetcherObjectPickerController.getObjects(null);
        Assert.isTrue(memberList.size() > 1, 'Expected multiple objects in the list');
    }
}