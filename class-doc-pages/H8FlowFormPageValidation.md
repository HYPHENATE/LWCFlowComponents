# H8FlowFormPageValidation

## Description

Apex controller for display page level validation errors within a flow

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
| pageName | String |

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
| pageValidation | H8_Flow_Form_Section_Validation__mdt |

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

