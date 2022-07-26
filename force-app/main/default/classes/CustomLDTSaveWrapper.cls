/**
 * @description       : save wrapper class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 05/04/2022
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   04/04/2022   daniel@hyphen8.com   Initial Version
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
