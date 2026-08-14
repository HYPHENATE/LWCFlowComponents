# customLightningDataTable

## Description

top level custom lightning data table

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Custom Lightning Data Table

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| sObjectAPIName |  |
| fieldSetAPIName |  |
| parentFieldAPIName |  |
| parentRecordId |  |
| allowAddRow | false |
| allowEdit | false |
| allowRowDeletion | false |
| maxRows |  |
| startingRowCount |  |
| whereClause |  |
| orderByClause |  |
| defaultFieldValues |  |
| newRecords |  |
| existingRecords |  |
| minRows |  |
| addRowButtonLabel | 'Add Row' |
| totalFields |  |
| currencyCode |  |
| readOnlyFields |  |

## Public API Methods

| Method | Parameters |
| --- | --- |
| validate |  |

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | sObjectAPIName | Object API Name | String | inputOnly |  | The API Name of the object data is stored in. |
| lightning__FlowScreen | fieldSetAPIName | Field Set API Name | String | inputOnly |  | FieldSet on the entered object that confirms the fields to display. |
| lightning__FlowScreen | parentFieldAPIName | Parent Field API Name | String | inputOnly |  | API for the Parent lookup field. |
| lightning__FlowScreen | parentRecordId | Parent Record Id | String | inputOnly |  | The ID for the parent record. |
| lightning__FlowScreen | allowAddRow | Allow Add Row | Boolean | inputOnly |  | Confirm if new rows can be added. |
| lightning__FlowScreen | allowEdit | Allow Edit | Boolean | inputOnly |  | Confirm if rows can be edited |
| lightning__FlowScreen | maxRows | Maximum Row Count | Integer | inputOnly |  | Confirm what the maximum number of rows allowed is. |
| lightning__FlowScreen | minRows | Minimum Row Count | Integer | inputOnly |  | Confirm what the min number of rows allowed is and validate against it |
| lightning__FlowScreen | startingRowCount | Starting Row Count | Integer | inputOnly |  | Confirm what the default row count on edit should be. |
| lightning__FlowScreen | whereClause | Where Clause | String | inputOnly |  | This is the a part of the SOQL query for the where clause to pull back the existing fields |
| lightning__FlowScreen | orderByClause | Order By Clause | String | inputOnly |  | This is the a part of the SOQL query for the order by clause i.e ORDER BY CreatedDate ASC |
| lightning__FlowScreen | defaultFieldValues | Default Field Values | String | inputOnly |  | Provide a JSON entry to set default fields when new records being created. |
| lightning__FlowScreen | newRecords | Records for Insert | {T[]} | outputOnly |  |  |
| lightning__FlowScreen | existingRecords | Records for Update | {T[]} | outputOnly |  |  |
| lightning__FlowScreen | allowRowDeletion | Allow Row Deletion | Boolean | inputOnly |  | Set this if you want to allow deletion of a row within the component |
| lightning__FlowScreen | addRowButtonLabel | Add Row Button Label | String | inputOnly | Add Row | This is the label for the add row button on the table |
| lightning__FlowScreen | totalFields | Total Field API Names | String | inputOnly |  | Comma-separated API names of Number/Currency/Percent fields to total in the footer. |
| lightning__FlowScreen | currencyCode | Currency Code (optional) | String | inputOnly |  | Currency code to use for currency totals (e.g., USD, GBP). Leave blank to use the default. |
| lightning__FlowScreen | readOnlyFields | Read Only Field API Names | String | inputOnly |  | Comma-separated API names of fields to render as read-only in the editable table (e.g., Amount__c, Account.Name). |

## Bundle Files

- `customLightningDataTable.css`
- `customLightningDataTable.html`
- `customLightningDataTable.js`
- `customLightningDataTable.js-meta.xml`
- `customLightningDataTable.svg`
