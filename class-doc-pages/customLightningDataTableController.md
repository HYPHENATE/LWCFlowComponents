# customLightningDataTableController

## Description

custom data table controller class

## API Version

66.0

## Sharing

with

## Methods

### getFieldsAndRecords

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sObjectName | String |
| fieldSetAPIName | String |
| parentIDField | String |
| parentId | String |
| whereClause | String |
| orderByClause | String |

**Output Variables**

| Type |
| --- |
| customLightningDataTableWrapper |

**Visibility**

public

### getFieldDetails

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sObjectAPIName | String |
| lstFSMember | List<Schema.FieldSetMember> |

**Output Variables**

| Type |
| --- |
| List<customLightningDataTableWrapper.fieldSetup> |

**Visibility**

private

### getPicklistOptionsMap

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| dfr | Schema.DescribeFieldResult |

**Output Variables**

| Type |
| --- |
| List<Map<String, String>> |

**Visibility**

private

