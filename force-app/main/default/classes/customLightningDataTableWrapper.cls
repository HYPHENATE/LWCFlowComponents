/**
 * @description       : field specification wrapper class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 06-04-2023
 * @last modified by  : daniel@hyphen8.com
**/
@SuppressWarnings('PMD')
public with sharing class customLightningDataTableWrapper {

    @AuraEnabled public fieldData fieldDetail;
    @AuraEnabled public List<sObject> records;
    
    public class fieldData {
        @AuraEnabled public List<fieldSetup> fields;
    }
    
    public class fieldSetup {
        @AuraEnabled public string fieldAPIName;
        @AuraEnabled public string fieldType;
        @AuraEnabled public string label;
        @AuraEnabled public decimal scale;
        @AuraEnabled public integer length;
        @AuraEnabled public boolean required;
        @AuraEnabled public boolean isPicklist;
        @AuraEnabled public boolean isCheckbox;
        @AuraEnabled public boolean isText;
        @AuraEnabled public boolean isNumber;
        @AuraEnabled public boolean isDate;
        @AuraEnabled public boolean isEmail;
        @AuraEnabled public boolean isPhone;
        @AuraEnabled public boolean isURL;
        @AuraEnabled public boolean isPercent;
        @AuraEnabled public boolean isCurrency;
        @AuraEnabled public decimal stepScale;
        @AuraEnabled public List<String> picklistOptions;
    }
}