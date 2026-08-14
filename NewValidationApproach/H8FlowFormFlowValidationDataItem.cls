/**
 * @description       : A data item for holding flow validation information
 * @author            : daniel@hyphen8.com
 * @last modified on  : 12-08-2026
 * @last modified by  : daniel@hyphen8.com
**/
public class H8FlowFormFlowValidationDataItem {
    @AuraEnabled public String dataKey { get; set; }
    @AuraEnabled public String objectApiName { get; set; }
    @AuraEnabled public Boolean isCollection { get; set; }
    @AuraEnabled public String objectData { get; set; }
}