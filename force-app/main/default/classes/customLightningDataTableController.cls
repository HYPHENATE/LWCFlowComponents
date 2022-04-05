/**
 * @description       : custom data table controller class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 05/04/2022
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log
 * Ver   Date         Author               Modification
 * 1.0   01/04/2022   daniel@hyphen8.com   Initial Version
**/
@SuppressWarnings('PMD')
public with sharing class customLightningDataTableController {
    
    @AuraEnabled
    public static customLightningDataTableWrapper getFieldsAndRecords(string sObjectName, string fieldSetAPIName, string parentIDField, string parentId, string whereClause){
        try {

            Map<String, String> returnMap = new Map<String,String>();
            if(!String.isEmpty(sObjectName) && !String.isEmpty(fieldSetAPIName))
            {    
                SObject sObj = (SObject)(Type.forName('Schema.'+ sObjectName).newInstance());   
                List<Schema.FieldSetMember> lstFSMember = sObj.getSObjectType().getDescribe().fieldSets.getMap().get(fieldSetAPIName).getFields();
                String query = 'SELECT Id, ';
                integer fieldSetMemberCount = 1;
                for(Schema.FieldSetMember f : lstFSMember) 
                {
                    query += f.getFieldPath();
                    if(fieldSetMemberCount != lstFSMember.size()){
                        query += ', ';
                    }
                    fieldSetMemberCount = fieldSetMemberCount + 1;
                }
                query += ' FROM ' + sObjectName ;
                
                if(!(String.isEmpty(parentIDField) && String.isEmpty(parentId)))
                {
                    query += ' WHERE ' + parentIDField + '=\'' + parentId + '\'';
                }

                if(!(String.isEmpty(whereClause)))
                {
                    query += ' AND ' + whereClause;
                }
                            
                List<SObject> lstRecords = Database.query(query);

                customLightningDataTableWrapper returnWrapper = new customLightningDataTableWrapper();
                returnWrapper.records = lstRecords;
                customLightningDataTableWrapper.fieldData fieldData = new customLightningDataTableWrapper.fieldData();
                fieldData.fields = getFieldDetails(sObjectName, lstFSMember);
                returnWrapper.fieldDetail = fieldData;

                return returnWrapper;
            }
            
            return null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<customLightningDataTableWrapper.fieldSetup> getFieldDetails(string sObjectAPIName, List<Schema.FieldSetMember> lstFSMember){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectAPIName).getDescribe().fields.getMap();
        List<customLightningDataTableWrapper.fieldSetup> fieldDetails = new List<customLightningDataTableWrapper.fieldSetup>();
        for(Schema.FieldSetMember field:lstFSMember){
            DescribeFieldResult currentFieldDetal = fieldMap.get(field.getFieldPath()).getDescribe();
            customLightningDataTableWrapper.fieldSetup fieldWrapper = new customLightningDataTableWrapper.fieldSetup();
            fieldWrapper.fieldAPIName = field.getFieldPath();
            fieldWrapper.label = field.getLabel();
            fieldWrapper.fieldType = string.valueOf(currentFieldDetal.getType()).toLowerCase();
            fieldWrapper.picklistOptions = getPickListValues(currentFieldDetal);
            fieldWrapper.length = currentFieldDetal.getLength();
            fieldWrapper.scale = currentFieldDetal.getScale();
            fieldWrapper.required = field.required;
            fieldWrapper.isCheckbox = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'boolean') ? true:false;
            fieldWrapper.isText = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'string' || string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'text' || string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'textarea') ? true:false;
            fieldWrapper.isCurrency = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'currency') ? true:false;
            fieldWrapper.isNumber = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'double') ? true:false;
            fieldWrapper.isDate = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'date' || string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'datetime') ? true:false;
            fieldWrapper.isEmail = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'email') ? true:false;
            fieldWrapper.isPhone = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'phone') ? true:false;
            fieldWrapper.isURL = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'url') ? true:false;
            fieldWrapper.isPicklist = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'picklist' || string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'multipicklist') ? true:false;
            fieldWrapper.isPercent = (string.valueOf(currentFieldDetal.getType()).toLowerCase() == 'percent') ? true:false;
            fieldDetails.add(fieldWrapper);
        }

        return fieldDetails;
    }

    //TODO Switch to Map<String, String> then update JS to convert this
    private static List<String> getPickListValues(DescribeFieldResult currentFieldDetal){
        List<Schema.PicklistEntry> pickListValue = currentFieldDetal.getPicklistValues();
        List<String> returnList = new List<String>();
        for(Schema.PicklistEntry picklist:pickListValue){
            returnList.add(picklist.getLabel());
        }
        return returnList;
    }

    @AuraEnabled
    public static List<sObject> generateSaveDataRecords(string sObjectAPIName, string parentIDField, string parentId, string dataArray, string defaultFieldValues){
        try {

            Map<String, Object> defaultObjectValues;
            if(!String.isEmpty(defaultFieldValues)){
                defaultObjectValues = (Map<String, Object>) JSON.deserializeUntyped(defaultFieldValues);
            } else {
                defaultObjectValues = new Map<String, Object>();
            }
            List<CustomLDTSaveWrapper> saveData = (List<CustomLDTSaveWrapper>)JSON.deserialize(dataArray, List<CustomLDTSaveWrapper>.class);
            List<sObject> returnList = new List<sObject>();
            for(CustomLDTSaveWrapper data:saveData){
                sObject sObj = Schema.getGlobalDescribe().get(sObjectAPIName).newSObject();
                sObj.put(parentIDField, parentId);

                string recordId = data.id;
            
                if(recordId.length() > 5){
                    sObj.put('Id', data.id);
                }

                for(String defaultField:defaultObjectValues.keySet()){
                    object defaultValue = defaultObjectValues.get(defaultField);
                    try {
                        sObj = setObjectValue(defaultValue, defaultField, sObj);
                    } catch (Exception e){
                        system.debug(e.getMessage());
                    }
                }

                List<CustomLDTSaveWrapper.field> fields = data.fields;
                for(CustomLDTSaveWrapper.field field:fields){
                    if(field.value != ''){
                        if(field.fieldType == 'date'){
                            sObj.put(field.fieldAPIName, date.valueOf(field.value));
                        } else if(field.fieldType == 'checkbox'){
                            sObj.put(field.fieldAPIName, boolean.valueOf(field.value));
                        } else if(field.fieldType == 'number'){
                            sObj.put(field.fieldAPIName, decimal.valueOf(field.value));
                        } else {
                            sObj.put(field.fieldAPIName, field.value);
                        }
                    }
                }
                returnList.add(sObj);
            }

            return returnList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static sObject setObjectValue(Object obj, string fieldAPIName, sObject newObject) {
        if(obj instanceof Boolean) {
            boolean booleanValue = boolean.valueOf(obj);
            newObject.put(fieldAPIName, booleanValue);
        } else if(obj instanceof Id){
            string stringIdValue = string.valueOf(obj);
            newObject.put(fieldAPIName, stringIdValue);
        } else if(obj instanceof String){
            string stringValue = string.valueOf(obj);
            newObject.put(fieldAPIName, stringValue);
        } else if(obj instanceof Date) {
            date dateValue = date.valueOf(obj);
            newObject.put(fieldAPIName, dateValue);
        } else if(obj instanceof Datetime){
            datetime datetimeValue = datetime.valueOf(obj);
            newObject.put(fieldAPIName, datetimeValue);
        } else if(obj instanceof Integer) {
            integer integerValue = integer.valueOf(obj);
            newObject.put(fieldAPIName, integerValue);
        } else if(obj instanceof Long){
            string stringDecimalValue = string.valueOf(obj);
            decimal decimalValue = decimal.valueOf(stringDecimalValue);
            newObject.put(fieldAPIName, decimalValue);
        } else if(obj instanceof Decimal){
            string stringDecimalValue = string.valueOf(obj);
            decimal decimalValue = decimal.valueOf(stringDecimalValue);
            newObject.put(fieldAPIName, decimalValue);
        } else if(obj instanceof Double){
            double doubleValue = double.valueOf(obj);
            newObject.put(fieldAPIName, doubleValue);
        }
        
        return newObject;
    }
}
