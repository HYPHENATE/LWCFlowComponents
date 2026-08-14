# Data_Table_Example

## Description



## Label

Data Table Example

## API Version

62.0

## Flow Type

Flow

## Status

Active

## Template

false

## Interview Label

Data Table Example {!$Flow.CurrentDateTime}

## Variables

| Name | DataType | ObjectOrClass | Collection | Input | Output | Default |
| --- | --- | --- | --- | --- | --- | --- |
| newRecordList | SObject | Opportunity | true | true | true |  |
| oldRecordList | SObject | Opportunity | true | true | true |  |
| recordId | String |  | false | true | false |  |

## Flow Elements

| Name | Label | Type | Detail |
| --- | --- | --- | --- |
| Data_Table_Insert_or_Update | Data Table Insert or Update | Screen | 1 field(s), 1 component instance(s) |
| OutputRecords | OutputRecords | Screen | 1 field(s), 1 component instance(s) |
| createNewRecords | createNewRecords | Record Create |  |
| UpdateExistingRecords | UpdateExistingRecords | Record Update |  |

## Screen Components

| Screen | Field | Component | Inputs |
| --- | --- | --- | --- |
| Data Table Insert or Update | ADDUPDATE | c:customLightningDataTable | allowAddRow=true, allowEdit=true, fieldSetAPIName=SampleFlowFieldSet, maxRows=10.0, parentFieldAPIName=AccountId, parentRecordId=recordId, sObjectAPIName=Opportunity, startingRowCount=10.0, minRows=5.0, defaultFieldValues={"CampaignID":"7012z0000007EgQAAU", "Type":"Existing Business"}, whereClause=Type = 'Existing Business' |
| OutputRecords | outputdata | c:customLightningDataTable | allowAddRow=false, allowEdit=false, fieldSetAPIName=SampleFlowFieldSet, maxRows=10.0, parentFieldAPIName=AccountId, parentRecordId=recordId, sObjectAPIName=Opportunity, startingRowCount=1.0, whereClause=Type = 'Existing Business' |

## Source File

- `force-app/main/default/flows/Data_Table_Example.flow-meta.xml`
