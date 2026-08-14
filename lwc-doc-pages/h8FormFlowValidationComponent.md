# h8FormFlowValidationComponent

## Description

Core validation component that validates the entire form

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Flow Form Validations

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| recordId |  |
| formName |  |
| parentObjectAPIName |  |
| cardTitle | this.label.cardTitle |
| nextButtonLabel | this.label.submissionButtonLabel |
| completeFieldsText | this.label.generalHelpText |
| invalidCardDescription | this.label.invalidSubmissionText |
| validCardDescription | this.label.validSubmissionText |
| affectTextLabel | this.label.affectedQuestionsText |
| sectionsToNotDisplay |  |
| availableActions | [] |

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
| lightning__FlowScreen | cardTitle | Card Title | String | inputOnly | Review.. before you submit | Please provide a title for the validation output component |
| lightning__FlowScreen | nextButtonLabel | Next Button Label | String | inputOnly | Review Submission | This is the label for the button that will appear when no validation errors have been found |
| lightning__FlowScreen | completeFieldsText | Complete Fields Text | String | inputOnly | You must complete the following fields | Provide text to inform the person with validation errors what they must do |
| lightning__FlowScreen | invalidCardDescription | Invalid Submission Next Steps Description | String | inputOnly | We have picked up that some of your answers are not valid. Before you can submit the form you will have to complete the required fields. | Provide text to explain what the next steps are that need to be completed prior to progression forward |
| lightning__FlowScreen | validCardDescription | Valid Submission Next Steps Description | String | inputOnly | If you have done all these feel free to submit... good luck | Provide text to confirm there are no validation errors and what the next steps are |
| lightning__FlowScreen | affectTextLabel | Affect Fields/Question Text | String | inputOnly | Question(s) affected: | Provide the text you want to display on screen to help explain what validations error actions |
| lightning__FlowScreen | sectionsToNotDisplay | Sections to Not Display | String[] |  |  | A collection of Section APINames that you do not want to display or validate within this currently displaying of the form |

## Bundle Files

- `h8FormFlowValidationComponent.css`
- `h8FormFlowValidationComponent.html`
- `h8FormFlowValidationComponent.js`
- `h8FormFlowValidationComponent.js-meta.xml`
- `h8FormFlowValidationComponent.svg`
