# H8FlowFormSectionValidation

## Description

apex controller to support with generating validations for an entire section

## API Version

66.0

## Sharing

with

## Methods

### validatePage

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| recordId | String |
| formName | String |
| parentObjectAPIName | String |
| sectionName | String |

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

### handleFlowValidationErrors

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
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
| validation | H8_Flow_Form_Section_Validation__mdt |
| errorMessage | String |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

