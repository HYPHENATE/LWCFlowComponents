/**
 * @description       : field specification wrapper class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 30-08-2025
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
        @AuraEnabled public String fieldAPIName;
        @AuraEnabled public String fieldType;
        @AuraEnabled public String label;
        @AuraEnabled public Decimal scale;
        @AuraEnabled public Integer length;
        @AuraEnabled public Boolean required;
        @AuraEnabled public Boolean isPicklist;
        @AuraEnabled public Boolean isCheckbox;
        @AuraEnabled public Boolean isText;
        @AuraEnabled public Boolean isNumber;
        @AuraEnabled public Boolean isDate;
        @AuraEnabled public Boolean isEmail;
        @AuraEnabled public Boolean isPhone;
        @AuraEnabled public Boolean isURL;
        @AuraEnabled public Boolean isPercent;
        @AuraEnabled public Boolean isCurrency;
        @AuraEnabled public Decimal stepScale;

        @AuraEnabled public List<Map<String,String>> picklistOptions;

        @AuraEnabled public String controllerFieldAPIName;       
        @AuraEnabled public List<String> controllerValues;       
        @AuraEnabled public Map<String, List<String>> dependencyMap; 
    }
}
