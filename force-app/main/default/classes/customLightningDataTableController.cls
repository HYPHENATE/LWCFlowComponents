/**
 * @description       : custom data table controller class
 * @author            : daniel@hyphen8.com
 * @last modified on  : 03-09-2026
 * @last modified by  : daniel@hyphen8.com
**/
@SuppressWarnings('PMD')
public with sharing class customLightningDataTableController {

    public static final String USER_MODE = 'USER_MODE';
    public static final String SYSTEM_MODE = 'SYSTEM_MODE';
    public static final String SYSTEM_MODE_WITHOUT_SHARING = 'SYSTEM_MODE_WITHOUT_SHARING';

    @AuraEnabled
    public static customLightningDataTableWrapper getFieldsAndRecords(String sObjectName, String fieldSetAPIName, String parentIDField, String parentId, String whereClause, String orderByClause, String dataAccessMode){
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

            if(!String.isBlank(orderByClause)){
                query += ' ' + orderByClause;
            }

            String mode = resolveMode(dataAccessMode);

            List<SObject> lstRecords;
            if (mode == SYSTEM_MODE_WITHOUT_SHARING) {
                lstRecords = customLightningDataTableNoSharing.queryWithoutSharing(query);
            } else if (mode == SYSTEM_MODE) {
                lstRecords = Database.query(query, AccessLevel.SYSTEM_MODE);
            } else {
                lstRecords = Database.query(query, AccessLevel.USER_MODE);
            }

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

    @AuraEnabled
    public static void deleteRecord(String recordId, String dataAccessMode){
        try {
            if (String.isBlank(recordId)) {
                return;
            }

            List<Id> ids = new List<Id>{ Id.valueOf(recordId) };
            String mode = resolveMode(dataAccessMode);

            List<Database.DeleteResult> results;
            if (mode == SYSTEM_MODE_WITHOUT_SHARING) {
                // lightning/uiRecordApi's deleteRecord always enforces the running user's sharing
                // and FLS, so it cannot honour this mode - it is routed through Apex instead.
                results = customLightningDataTableNoSharing.deleteWithoutSharing(ids);
            } else if (mode == SYSTEM_MODE) {
                results = Database.delete(ids, AccessLevel.SYSTEM_MODE);
            } else {
                results = Database.delete(ids, AccessLevel.USER_MODE);
            }

            if (!results.isEmpty() && !results[0].isSuccess()) {
                throw new AuraHandledException(results[0].getErrors()[0].getMessage());
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String resolveMode(String dataAccessMode){
        return String.isBlank(dataAccessMode) ? USER_MODE : dataAccessMode.trim().toUpperCase();
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