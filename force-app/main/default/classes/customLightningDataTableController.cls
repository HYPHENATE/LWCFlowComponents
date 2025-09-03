/**
 * @description       : custom data table controller class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 30-08-2025
 * @last modified by  : daniel@hyphen8.com
**/
@SuppressWarnings('PMD')
public with sharing class customLightningDataTableController {

    @AuraEnabled
    public static customLightningDataTableWrapper getFieldsAndRecords(String sObjectName, String fieldSetAPIName, String parentIDField, String parentId, String whereClause){
        try {
            if (String.isBlank(sObjectName) || String.isBlank(fieldSetAPIName)) {
                return null;
            }

            SObject sObj = (SObject)(Type.forName('Schema.'+ sObjectName).newInstance());   
            List<Schema.FieldSetMember> lstFSMember =
                sObj.getSObjectType().getDescribe().fieldSets.getMap().get(fieldSetAPIName).getFields();

            String fieldsCsv = '';
            Integer idx = 0;
            for (Schema.FieldSetMember f : lstFSMember) {
                fieldsCsv += (idx++ == 0 ? '' : ', ') + f.getFieldPath();
            }

            String query = 'SELECT Id, ' + fieldsCsv + ' FROM ' + sObjectName;

            List<String> whereParts = new List<String>();
            if (!String.isBlank(parentIDField) && !String.isBlank(parentId)) {
                try {
                    Id pid = Id.valueOf(parentId);
                    whereParts.add(parentIDField + ' = \'' + String.escapeSingleQuotes(String.valueOf(pid)) + '\'');
                } catch (Exception ex) {
                    whereParts.add(parentIDField + ' = \'' + String.escapeSingleQuotes(parentId) + '\'');
                }
            }
            if (!String.isBlank(whereClause)) {
                whereParts.add('(' + whereClause + ')');
            }
            if (!whereParts.isEmpty()) {
                query += ' WHERE ' + String.join(whereParts, ' AND ');
            }

            List<SObject> lstRecords = Database.query(query);

            customLightningDataTableWrapper returnWrapper = new customLightningDataTableWrapper();
            returnWrapper.records = lstRecords;

            customLightningDataTableWrapper.fieldData fd = new customLightningDataTableWrapper.fieldData();
            fd.fields = getFieldDetails(sObjectName, lstFSMember);
            returnWrapper.fieldDetail = fd;

            return returnWrapper;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<customLightningDataTableWrapper.fieldSetup> getFieldDetails(String sObjectAPIName,List<Schema.FieldSetMember> lstFSMember){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectAPIName).getDescribe().fields.getMap();

        List<customLightningDataTableWrapper.fieldSetup> fieldDetails = new List<customLightningDataTableWrapper.fieldSetup>();

        for (Schema.FieldSetMember fsm : lstFSMember) {
            Schema.DescribeFieldResult d = fieldMap.get(fsm.getFieldPath()).getDescribe();

            customLightningDataTableWrapper.fieldSetup f = new customLightningDataTableWrapper.fieldSetup();
            f.fieldAPIName = fsm.getFieldPath();
            f.label        = fsm.getLabel();
            f.fieldType    = String.valueOf(d.getType()).toLowerCase();
            f.length       = d.getLength();
            f.scale        = d.getScale();
            f.required     = fsm.required;

            f.isCheckbox = f.fieldType == 'boolean';
            f.isText     = f.fieldType == 'string' || f.fieldType == 'text' || f.fieldType == 'textarea';
            f.isCurrency = f.fieldType == 'currency';
            f.isNumber   = f.fieldType == 'double';
            f.isDate     = f.fieldType == 'date' || f.fieldType == 'datetime';
            f.isEmail    = f.fieldType == 'email';
            f.isPhone    = f.fieldType == 'phone';
            f.isURL      = f.fieldType == 'url';
            f.isPicklist = f.fieldType == 'picklist' || f.fieldType == 'multipicklist';
            f.isPercent  = f.fieldType == 'percent';

            if (f.isCurrency || f.isNumber || f.isPercent) {
                if (d.getScale() == 0) {
                    f.stepScale = 0;
                } else {
                    String stepValue = '0.';
                    for (Integer i = 1; i <= d.getScale(); i++) {
                        stepValue += (i == d.getScale()) ? '1' : '0';
                    }
                    f.stepScale = Decimal.valueOf(stepValue);
                }
            }

            if (f.isPicklist) {
                f.picklistOptions = getPicklistOptionsMap(d);
            }

            Schema.SObjectField ctrl = d.getController();
            if (ctrl != null) {
                f.controllerFieldAPIName = ctrl.getDescribe().getName();
            }

            fieldDetails.add(f);
        }

        return fieldDetails;
    }

    private static List<Map<String, String>> getPicklistOptionsMap(Schema.DescribeFieldResult dfr) {
        List<Map<String, String>> out = new List<Map<String, String>>();
        for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {
            out.add(new Map<String, String>{
                'label' => pe.getLabel(),
                'value' => pe.getValue()
            });
        }
        return out;
    }
}