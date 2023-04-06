/**
 * @description       : save wrapper class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 06-04-2023
 * @last modified by  : daniel@hyphen8.com
**/
@SuppressWarnings('PMD')
public class CustomLDTSaveWrapper {
    
    @AuraEnabled public string id;
    @AuraEnabled public List<field> fields;

    public class field {
        @AuraEnabled public string value;
        @AuraEnabled public string fieldAPIName;
        @AuraEnabled public string fieldType;
        @AuraEnabled public boolean isCalculated;
    }
}
