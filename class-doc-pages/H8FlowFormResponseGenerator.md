# H8FlowFormResponseGenerator

## Description

Helper class for generating JSON responses for form validation flows.

## API Version

66.0

## Sharing

with

## Methods

### generateFormValidationResponse

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| success | Boolean |
| message | String |
| Map<String |  |
| Map<String |  |
| validationErrors | List<String>>> |
| formDetails | H8_Flow_Form__mdt |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### generateFormSectionResponse

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| success | Boolean |
| message | String |
| Map<String |  |
| currentErrors | List<String>> |
| formDetails | H8_Flow_Form__mdt |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### generateFormPageResponse

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| success | Boolean |
| message | String |
| currentErrors | List<String> |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### generateMapOfValues

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formDetails | H8_Flow_Form__mdt |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### getDisplayLabel

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| section | H8_Flow_Form_Section__mdt |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### getCustomLabel

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| useLabel | Boolean |
| masterLabel | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

