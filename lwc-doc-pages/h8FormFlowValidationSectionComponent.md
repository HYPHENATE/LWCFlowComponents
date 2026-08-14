# h8FormFlowValidationSectionComponent

## Description

html to output an entire sections validation errors

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Flow Form Section Validations

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| recordId |  |
| formName |  |
| parentObjectAPIName |  |
| sectionName |  |
| helpText | this.label.H8FFGeneralHelpText |
| affectTextLabel | this.label.H8FFAffectedQuestions |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | recordId | Master RecordId | String | inputOnly |  | Provide the master record id for processing validations against |
| lightning__FlowScreen | formName | Form API Name | String | inputOnly |  | Please provide the developer name of the form you want to display |
| lightning__FlowScreen | parentObjectAPIName | Parent Object API Name | String | inputOnly |  | Provide the Object Name for your Parent recordId |
| lightning__FlowScreen | sectionName | Form Section Name | String | inputOnly |  | This is the developer api name for the section within your form that you want to validate |
| lightning__FlowScreen | helpText | Help Text | String | inputOnly | You must complete the following fields | Provide help text to help guide users on what next steps a user should perform |
| lightning__FlowScreen | affectTextLabel | Affect Fields/Question Text | String | inputOnly | Question(s) affected: | Provide the text you want to display on screen to help explain what validations error actions |

## Bundle Files

- `h8FormFlowValidationSectionComponent.css`
- `h8FormFlowValidationSectionComponent.html`
- `h8FormFlowValidationSectionComponent.js`
- `h8FormFlowValidationSectionComponent.js-meta.xml`
- `h8FormFlowValidationSectionComponent.svg`
