# H8FlowFormManagerController

## Description

controller class to support the flow form management page - lists a form's sections and each section's validations, and resolves the FlowRecord's Lightning record URL for a section's flow

## API Version

67.0

## Sharing

with

## Methods

### getFormSections

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formDeveloperName | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### queryFormSections

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formDeveloperName | String |

**Output Variables**

| Type |
| --- |
| List<H8_Flow_Form_Section__mdt> |

**Visibility**

private

### getSectionValidations

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sectionDeveloperName | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### querySectionValidations

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sectionDeveloperName | String |

**Output Variables**

| Type |
| --- |
| List<H8_Flow_Form_Section_Validation__mdt> |

**Visibility**

private

### getFlowRecordUrl

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| flowApiName | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### getFlowRecordId

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| flowApiName | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### getFlowUsage

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| flowApiName | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### queryFlowUsageSections

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| flowApiName | String |

**Output Variables**

| Type |
| --- |
| List<H8_Flow_Form_Section__mdt> |

**Visibility**

private

### queryFlowUsageForms

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| flowApiName | String |

**Output Variables**

| Type |
| --- |
| List<H8_Flow_Form__mdt> |

**Visibility**

private

### getUsedFlows

**Description**



**Input Variables**

None

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### queryUsedFlows

**Description**



**Input Variables**

None

**Output Variables**

| Type |
| --- |
| List<FlowUsageOption> |

**Visibility**

private

### generateUsedFlowsResponse

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| flows | List<FlowUsageOption> |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### generateFlowUsageResponse

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sectionUsages | List<H8_Flow_Form_Section__mdt> |
| formUsages | List<H8_Flow_Form__mdt> |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### getIsProductionOrg

**Description**



**Input Variables**

None

**Output Variables**

| Type |
| --- |
| Boolean |

**Visibility**

public

### queryIsProductionOrg

**Description**



**Input Variables**

None

**Output Variables**

| Type |
| --- |
| Boolean |

**Visibility**

private

### getFormCustomFields

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formDeveloperName | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### queryFormCustomFields

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formDeveloperName | String |

**Output Variables**

| Type |
| --- |
| List<CustomFieldValue> |

**Visibility**

private

### getSectionCustomFieldsForForm

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formDeveloperName | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

public

### querySectionCustomFieldsForForm

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| formDeveloperName | String |

**Output Variables**

| Type |
| --- |
| Map<String, List<CustomFieldValue>> |

**Visibility**

private

### generateSectionCustomFieldsForFormResponse

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| fieldsBySectionDeveloperName | Map<String, List<CustomFieldValue>> |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### deriveCustomFieldApiNames

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| allFieldApiNames | Set<String> |
| knownFieldApiNames | Set<String> |

**Output Variables**

| Type |
| --- |
| List<String> |

**Visibility**

private

### buildCustomFieldValues

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| objectApiName | String |
| fieldApiNames | List<String> |
| developerName | String |

**Output Variables**

| Type |
| --- |
| List<CustomFieldValue> |

**Visibility**

private

### buildCustomFieldValuesForDeveloperNames

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| objectApiName | String |
| fieldApiNames | List<String> |
| developerNames | List<String> |

**Output Variables**

| Type |
| --- |
| Map<String, List<CustomFieldValue>> |

**Visibility**

private

### validateApiName

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| apiName | String |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### formatCustomFieldValue

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| record | SObject |
| fieldApiName | String |
| describeResult | Schema.DescribeFieldResult |

**Output Variables**

| Type |
| --- |
| CustomFieldValue |

**Visibility**

private

### generateCustomFieldsResponse

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| customFields | List<CustomFieldValue> |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### generateSectionsResponse

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| sections | List<H8_Flow_Form_Section__mdt> |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### resolveSectionDisplayName

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

### generateValidationsResponse

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| validations | List<H8_Flow_Form_Section_Validation__mdt> |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### nullSafe

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| value | String |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### nullSafe

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| value | Decimal |

**Output Variables**

| Type |
| --- |
| Decimal |

**Visibility**

private

