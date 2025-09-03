/**
 * @description       : test class for customLightningDataTableController
 * @author            : daniel@hyphen8.com
 * @last modified on  : 30-08-2025
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class customLightningDataTableControllerTest {

    @isTest 
    static void testGetFieldsAndRecordNoRecords(){

        Account account = new Account(Name='DEMO');
        insert account;

        string oppwhereClause = 'Type = \'New Business\'';

        customLightningDataTableWrapper oppWrapper = customLightningDataTableController.getFieldsAndRecords('Opportunity', 'SampleFlowFieldSet', 'AccountId', account.Id, oppwhereClause);
        customLightningDataTableWrapper contactWrapper = customLightningDataTableController.getFieldsAndRecords('Contact', 'SampleFlowFieldSet', 'AccountId', account.Id, null);
        customLightningDataTableWrapper nullWrapper = customLightningDataTableController.getFieldsAndRecords('', '', 'AccountId', account.Id, null);

        try {
            customLightningDataTableWrapper errorWrapper = customLightningDataTableController.getFieldsAndRecords('Contact', 'SampleFlowFieldSetError', 'Account', account.Id, null);
        } catch (Exception e){
            string error = e.getMessage();
            boolean errorContains = error.contains('Script');
            system.assertEquals(true, errorContains, 'Error message was different to expected');
        }
    }
}