/**
 * @description       : test class for customLightningDataTableController
 * @author            : daniel@hyphen8.com
 * @last modified on  : 06-04-2023
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class customLightningDataTableControllerTest {

    
    
    @isTest 
    static void testSetObjectValue(){

        Account account = new Account(Name='DEMO');
        insert account;

        sObject oppsObj = Schema.getGlobalDescribe().get('Opportunity').newSObject();
        oppsObj = customLightningDataTableController.setObjectValue(account.Id, 'AccountId', oppsObj);
        oppsObj = customLightningDataTableController.setObjectValue('DEMO', 'Name', oppsObj);
        oppsObj = customLightningDataTableController.setObjectValue('Closed Won', 'StageName', oppsObj);
        decimal decimalValue = 10;
        oppsObj = customLightningDataTableController.setObjectValue(decimalValue, 'Amount', oppsObj);
        long longValue = 10;
        oppsObj = customLightningDataTableController.setObjectValue(longValue, 'Amount', oppsObj);
        double doubleValue = double.valueOf(10);
        oppsObj = customLightningDataTableController.setObjectValue(doubleValue, 'Amount', oppsObj);
        integer integerValue = 1;
        oppsObj = customLightningDataTableController.setObjectValue(integerValue, 'Amount', oppsObj);
        oppsObj = customLightningDataTableController.setObjectValue(system.today(), 'CloseDate', oppsObj);
        insert oppsObj;

        sObject contactSobj = Schema.getGlobalDescribe().get('Contact').newSObject();
        contactSobj = customLightningDataTableController.setObjectValue(true, 'HasOptedOutOfEmail', contactSobj);
        contactSobj = customLightningDataTableController.setObjectValue('demo@demo.com', 'Email', contactSobj);
        contactSobj = customLightningDataTableController.setObjectValue(account.Id, 'AccountId', contactSobj);
        contactSobj = customLightningDataTableController.setObjectValue('DEMO', 'LastName', contactSobj);
        insert contactSobj;

        sObject eventSobj = Schema.getGlobalDescribe().get('Event').newSObject();
        Date todayValue = system.today();
        Time timeValue = Time.newInstance(3, 3, 3, 0);
        DateTime dateTimeValue = DateTime.newInstance(todayValue, timeValue);
        eventSobj = customLightningDataTableController.setObjectValue(dateTimeValue, 'StartDateTime', eventSobj);
        eventSobj = customLightningDataTableController.setObjectValue(account.Id, 'WhatId', eventSobj);
        eventSobj = customLightningDataTableController.setObjectValue('DEMO', 'Subject', eventSobj);
        eventSobj = customLightningDataTableController.setObjectValue(8, 'DurationInMinutes', eventSobj);
        insert eventSobj;

        system.assertEquals(1, [SELECT COUNT() FROM Contact], 'Wrong nunber of contacts returned expected 1');
        system.assertEquals(1, [SELECT COUNT() FROM Opportunity], 'Wrong nunber of opportunities returned expected 1');
        

    }

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


    @isTest
    static void testSaveGenerationMethod(){

        Account account = new Account(Name='DEMO');
        insert account;

        Opportunity opp = new Opportunity(Name='DEMO', CloseDate=system.today(),StageName='Closed Won', Amount=1000);
        insert opp;


        string defaultFieldValuesNew = '{"Type":"Existing Business"}';

        string mockComponentDataNewRecord = '[{"id":"45","fields":[{"value":"DEMO 2","fieldAPIName":"Name","fieldType":"text","required":true,"isPicklist":false,"isCheckbox":false,"isText":true,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[]},{"value":"DEMO 2","fieldAPIName":"Description","fieldType":"text","required":false,"isPicklist":false,"isCheckbox":false,"isText":true,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[]},{"value":600,"fieldAPIName":"Amount","fieldType":"number","required":true,"isPicklist":false,"isCheckbox":false,"isText":false,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":true,"picklistOptions":[]},{"value":"2022-04-08","fieldAPIName":"CloseDate","fieldType":"date","required":true,"isPicklist":false,"isCheckbox":false,"isText":false,"isNumber":false,"isDate":true,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[]},{"value":false,"fieldAPIName":"IsPrivate","fieldType":"checkbox","required":false,"isPicklist":false,"isCheckbox":true,"isText":false,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[]},{"value":"Needs Analysis","fieldAPIName":"StageName","fieldType":"combobox","required":true,"isPicklist":true,"isCheckbox":false,"isText":false,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}]}]';
        string mockComponentDataOldRecord = '[{"id":"' + opp.Id + '","fields":[{"value":"DEMO 2","fieldAPIName":"Name","fieldType":"text","required":true,"isPicklist":false,"isCheckbox":false,"isText":true,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[]},{"value":"DEMO 2","fieldAPIName":"Description","fieldType":"text","required":false,"isPicklist":false,"isCheckbox":false,"isText":true,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[]},{"value":600,"fieldAPIName":"Amount","fieldType":"number","required":true,"isPicklist":false,"isCheckbox":false,"isText":false,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":true,"picklistOptions":[]},{"value":"2022-04-08","fieldAPIName":"CloseDate","fieldType":"date","required":true,"isPicklist":false,"isCheckbox":false,"isText":false,"isNumber":false,"isDate":true,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[]},{"value":false,"fieldAPIName":"IsPrivate","fieldType":"checkbox","required":false,"isPicklist":false,"isCheckbox":true,"isText":false,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[]},{"value":"Needs Analysis","fieldAPIName":"StageName","fieldType":"combobox","required":true,"isPicklist":true,"isCheckbox":false,"isText":false,"isNumber":false,"isDate":false,"isEmail":false,"isPhone":false,"isURL":false,"isPercent":false,"isCurrency":false,"picklistOptions":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}]}]';
        
        
        List<SObject> generateRecordsNew = customLightningDataTableController.generateSaveDataRecords('Opportunity', 'AccountId', account.Id, mockComponentDataNewRecord, defaultFieldValuesNew);
        system.assertEquals(1, generateRecordsNew.size(), 'Expected 1 new record');

        List<SObject> generateRecordsOld = customLightningDataTableController.generateSaveDataRecords('Opportunity', 'AccountId', account.Id, mockComponentDataOldRecord, null);
        system.assertEquals(1, generateRecordsOld.size(), 'Expected 1 old record');

        try {
            List<SObject> generateRecordsError = customLightningDataTableController.generateSaveDataRecords('Opportunity', 'AccountId', account.Id, 'error data explode', 'error data exploder');
        } catch (Exception e){
            string error = e.getMessage();
            boolean errorContains = error.contains('Script');
            system.assertEquals(true, errorContains, 'The error through a different message');
        }

    }
    
}