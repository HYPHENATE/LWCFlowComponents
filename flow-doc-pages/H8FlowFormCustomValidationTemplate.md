# H8FlowFormCustomValidationTemplate

## Description



## Label

H8FlowFormCustomValidationTemplate

## API Version

62.0

## Flow Type

AutoLaunchedFlow

## Status

Draft

## Template

true

## Interview Label

H8FlowFormCustomValidationTemplate {!$Flow.CurrentDateTime}

## Variables

| Name | DataType | ObjectOrClass | Collection | Input | Output | Default |
| --- | --- | --- | --- | --- | --- | --- |
| currentItem_Filter_Sections | SObject | H8_Flow_Form_Section__mdt | false | false | false |  |
| currentItem_Filter_Validation_Pages | SObject | H8_Flow_Form_Section_Validation__mdt | false | false | false |  |
| currentItemFromSourceCollection | SObject | H8_Flow_Form_Section_Validation__mdt | false | false | false |  |
| H8FlowFormName | String |  | false | true | false | Dans_Test_Form |
| H8FlowFormSectionName | String |  | false | true | false |  |
| H8FlowFormSectionPageName | String |  | false | true | false |  |
| isValid | Boolean |  | false | false | true | true |
| recordId | String |  | false | true | false |  |
| validationMessages | String |  | true | false | false |  |
| validationMessagesEmpty | String |  | true | false | false |  |
| validationResult | Apex | H8FlowFormFlowValidationResults | false | false | false |  |
| validationResults | Apex | H8FlowFormFlowValidationResults | true | false | true |  |

## Flow Elements

| Name | Label | Type | Detail |
| --- | --- | --- | --- |
| Get_Account | Get Account | Record Lookup | Account |
| Get_H8_Flow_Form_Metadata | Get H8 Flow Form Metadata | Record Lookup | H8_Flow_Form__mdt |
| Get_H8_Flow_Form_Sections | Get H8 Flow Form Sections | Record Lookup | H8_Flow_Form_Section__mdt |
| Get_H8_Flow_Form_Validations | Get H8 Flow Form Validations | Record Lookup | H8_Flow_Form_Section_Validation__mdt |
| Assign_Default_Error | Assign Default Error | Assignment | 1 item(s) |
| Assign_Filtered_Sections | Assign Filtered Sections | Assignment | 1 item(s) |
| Assign_Filtered_Validations | Assign Filtered Validations | Assignment | 1 item(s) |
| Assign_Output_Messages | Assign Output Messages | Assignment | 4 item(s) |
| Assign_Test_Validation_Message | Assign Test Validation Message | Assignment | 1 item(s) |
| Are_we_filtering_on_a_section | Are we filtering on a section? | Decision | 1 rule(s) |
| Are_we_filtering_on_pages | Are we filtering on pages? | Decision | 1 rule(s) |
| Test_Check | Test Check | Decision | 1 rule(s) |
| Type_of_Validation | Type of Validation | Decision | 1 rule(s) |
| For_each_validation_field | For each validation field | Loop | Get_H8_Flow_Form_Validations |
| Filter_Sections | Filter Sections | Collection Processor | FilterCollectionProcessor |
| Filter_Validation_Pages | Filter Validation Pages | Collection Processor | FilterCollectionProcessor |
| Collate_H8_Flow_Form_Section_Ids | Collate H8 Flow Form Section Ids | Transform | String |
| NoValidationTypeFoundErrorMessage | NoValidationTypeFoundErrorMessage | Formula | String |

## Screen Components

None

## Source File

- `force-app/main/default/flows/H8FlowFormCustomValidationTemplate.flow-meta.xml`
