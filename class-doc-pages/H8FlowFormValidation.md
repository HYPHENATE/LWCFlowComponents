# H8FlowFormValidation

## Description

master form flow validation class for validating an entire form submission looking for errors

## API Version

66.0

## Sharing

with

## Methods

### validateCompleteForm

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| recordId | String |
| primaryObjectAPIName | String |
| formAPIName | String |
| sectionsToNotDisplay | List<String> |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### getValidationFields

**Description**



**Input Variables**

None

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### processFormSectionsValidationRecords

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formSection | H8_Flow_Form_Section__mdt |
| formSectionValidation | H8_Flow_Form_Section_Validation__mdt |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### storeValidationValue

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sectionValidation | H8_Flow_Form_Section_Validation__mdt |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### validateCurrentRecord

**Description**



**Input Variables**

None

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### generateErrorFromSection

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| validations | List<H8_Flow_Form_Section_Validation__mdt> |
| sectionName | String |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### handleFlowValidationErrors

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sectionName | String |
| validations | List<H8_Flow_Form_Section_Validation__mdt> |
| validation | H8_Flow_Form_Section_Validation__mdt |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### handleCustomValidationErrors

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sectionName | String |
| validation | H8_Flow_Form_Section_Validation__mdt |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### generateError

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sectionName | String |
| validation | H8_Flow_Form_Section_Validation__mdt |
| errorMessage | String |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

