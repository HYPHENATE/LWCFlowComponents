# H8FlowFormCloneDeployment

## Description

this class performs the actual clone and deployment of the form clone

## API Version

66.0

## Sharing

with

## Methods

### cloneFlowForm

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sourceDeveloperName | String |
| newMasterLabel | String |
| newDeveloperName | String |

**Output Variables**

| Type |
| --- |
| Id |

**Visibility**

public

### buildCMDTValue

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| field | String |
| value | Object |
| dataType | String |

**Output Variables**

| Type |
| --- |
| Metadata.CustomMetadataValue |

**Visibility**

private

### getUniqueName

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| newName | String |
| originalName | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### regenerateUnique

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| newName | String |
| uniqueDevName | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### getMasterLabels

**Description**



**Input Variables**

None

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

