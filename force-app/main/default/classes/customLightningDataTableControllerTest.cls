/**
 * @description       : test class for customLightningDataTableController
 * @author            : daniel@hyphen8.com
 * @last modified on  : 17-02-2026
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class customLightningDataTableControllerTest {

    @isTest 
    static void testGetFieldsAndRecordNoRecords(){

        Account account = new Account(Name='DEMO');
        insert account;

        string oppwhereClause = 'Type = \'New Business\'';

        customLightningDataTableWrapper oppWrapper = customLightningDataTableController.getFieldsAndRecords('Opportunity', 'SampleFlowFieldSet', 'AccountId', account.Id, oppwhereClause, 'ORDER BY CreatedDate ASC', null);
        customLightningDataTableWrapper contactWrapper = customLightningDataTableController.getFieldsAndRecords('Contact', 'SampleFlowFieldSet', 'AccountId', account.Id, null, null, null);
        customLightningDataTableWrapper nullWrapper = customLightningDataTableController.getFieldsAndRecords('', '', 'AccountId', account.Id, null, null, null);

        try {
            customLightningDataTableWrapper errorWrapper = customLightningDataTableController.getFieldsAndRecords('Contact', 'SampleFlowFieldSetError', 'Account', account.Id, null, null, null);
        } catch (Exception e){
            string error = e.getMessage();
            boolean errorContains = error.contains('Script');
            system.assertEquals(true, errorContains, 'Error message was different to expected');
        }
    }

    @isTest
    static void testGetFieldsAndRecordsDataAccessModes(){

        Account account = new Account(Name='DEMO');
        insert account;

        customLightningDataTableWrapper userModeWrapper = customLightningDataTableController.getFieldsAndRecords('Contact', 'SampleFlowFieldSet', 'AccountId', account.Id, null, null, 'USER_MODE');
        system.assertNotEquals(null, userModeWrapper, 'USER_MODE should return a wrapper');

        customLightningDataTableWrapper systemModeWrapper = customLightningDataTableController.getFieldsAndRecords('Contact', 'SampleFlowFieldSet', 'AccountId', account.Id, null, null, 'SYSTEM_MODE');
        system.assertNotEquals(null, systemModeWrapper, 'SYSTEM_MODE should return a wrapper');

        customLightningDataTableWrapper systemModeWithoutSharingWrapper = customLightningDataTableController.getFieldsAndRecords('Contact', 'SampleFlowFieldSet', 'AccountId', account.Id, null, null, 'system_mode_without_sharing');
        system.assertNotEquals(null, systemModeWithoutSharingWrapper, 'SYSTEM_MODE_WITHOUT_SHARING should return a wrapper');

        customLightningDataTableWrapper blankModeWrapper = customLightningDataTableController.getFieldsAndRecords('Contact', 'SampleFlowFieldSet', 'AccountId', account.Id, null, null, '');
        system.assertNotEquals(null, blankModeWrapper, 'A blank data access mode should fall back to USER_MODE rather than error');
    }

    @isTest
    static void testDeleteRecordDataAccessModes(){

        Account account = new Account(Name='DEMO');
        insert account;

        List<Contact> contacts = new List<Contact>{
            new Contact(LastName='USER_MODE', AccountId=account.Id),
            new Contact(LastName='SYSTEM_MODE', AccountId=account.Id),
            new Contact(LastName='SYSTEM_MODE_WITHOUT_SHARING', AccountId=account.Id),
            new Contact(LastName='BLANK_MODE', AccountId=account.Id)
        };
        insert contacts;

        customLightningDataTableController.deleteRecord(contacts[0].Id, 'USER_MODE');
        customLightningDataTableController.deleteRecord(contacts[1].Id, 'SYSTEM_MODE');
        customLightningDataTableController.deleteRecord(contacts[2].Id, 'system_mode_without_sharing');
        customLightningDataTableController.deleteRecord(contacts[3].Id, '');
        customLightningDataTableController.deleteRecord(null, 'USER_MODE');

        system.assertEquals(0, [SELECT Id FROM Contact].size(), 'All contacts should have been deleted regardless of data access mode');
    }
}