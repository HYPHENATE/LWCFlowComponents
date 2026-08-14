# h8FlowFormPageValidationComponent

## Description

html to render current page validations

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Flow Form Page Validations

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| recordId |  |
| formName |  |
| parentObjectAPIName |  |
| pageName |  |
| sectionName |  |
| helpText | this.label.generalHelpText |
| affectTextLabel | this.label.affectedQuestionsText |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | recordId | Master RecordId | String | inputOnly |  | Provide the master record id for processing validations against |
| lightning__FlowScreen | formName | Form API Name | String | inputOnly |  | Provide the developer API name for your form |
| lightning__FlowScreen | parentObjectAPIName | Parent Object API Name | String | inputOnly |  | Provide the Object Name for your Parent recordId |
| lightning__FlowScreen | pageName | Page Name | String | inputOnly |  | Enter the page name you are current viewing (you cannot pass in the Stage as its not available for export) |
| lightning__FlowScreen | helpText | Help Text | String | inputOnly | You must complete the following fields |  |
| lightning__FlowScreen | affectTextLabel | Affect Fields/Question Text | String | inputOnly | Question(s) affected: | Provide the text you want to display on screen to help explain what validations error actions are required |

## Bundle Files

- `h8FlowFormPageValidationComponent.css`
- `h8FlowFormPageValidationComponent.html`
- `h8FlowFormPageValidationComponent.js`
- `h8FlowFormPageValidationComponent.js-meta.xml`
- `h8FlowFormPageValidationComponent.svg`
