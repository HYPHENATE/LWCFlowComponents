# H8FlowFormValidationHelper

## Description

flow form validations helper class

## API Version

66.0

## Sharing

with

## Methods

### getCompleteForm

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formAPIName | String |
| sectionsToNotDisplay | List<String> |

**Output Variables**

| Type |
| --- |
| H8_Flow_Form__mdt |

**Visibility**

public

### getSpecificSectionForm

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formAPIName | String |
| sectionName | String |

**Output Variables**

| Type |
| --- |
| H8_Flow_Form__mdt |

**Visibility**

public

### getSpecificPageForm

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formAPIName | String |
| pageName | String |

**Output Variables**

| Type |
| --- |
| H8_Flow_Form__mdt |

**Visibility**

public

### getProcessingRecord

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| recordId | String |
| primaryObjectAPIName | String |
| soqlFields | Set<String> |

**Output Variables**

| Type |
| --- |
| SObject |

**Visibility**

public

### getFieldValue

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| currentRecord | SObject |
| fieldAPIName | String |

**Output Variables**

| Type |
| --- |
| Object |

**Visibility**

public

### getFlowValidations

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| validationFlowName | String |
| flowFormName | String |
| flowFormSectionName | String |
| flowFormSectionPageName | String |
| recordId | String |
| sectionsToNotDisplay | List<String> |

**Output Variables**

| Type |
| --- |
| Map<String, List<String>> |

**Visibility**

public

