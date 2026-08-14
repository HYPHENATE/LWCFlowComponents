# h8FlowFormRenderComponent

## Description

html to output vertical tabs based on metadata configuration

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Form Flow Component

## Targets

- `lightning__HomePage`
- `lightning__RecordPage`
- `lightningCommunity__Page`
- `lightningCommunity__Default`
- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| formName |  |
| recordId |  |
| defaultPage | 1 |
| scrollToTopOffset | 150 |
| navWidth | '12rem' |
| getLanguage | false |
| sectionsToNotDisplay |  |
| liveValidation | false |
| showSectionValidationPanel | false |
| showSectionHeader | false |
| showNoValidationErrorsFound | false |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__HomePage | formName | Form Name | String |  |  | Please provide the developer name of the form you want to display |
| lightning__HomePage | defaultPage | Default Page | Integer |  |  | Enter the section number that you want to default the loading to |
| lightning__HomePage | scrollToTopOffset | On Click Scroll Offset | Integer |  |  | Selecting a section will scroll to the top but you might want to offset that in px, enter a number without the px to set the offset difference |
| lightning__HomePage | navWidth | Tab Navigation Width | String |  | 12rem | You can use this to determine the width of the tab columns, for full responsiveness you should use rem options, the default is 12rem |
| lightning__HomePage | getLanguage | Get Language | Boolean |  | false | Tick this is you want to pass in the the URL site language on to the flow, to prevent errors you will need a varaible varLanguage available within the flow as an input |
| lightning__HomePage | showSectionHeader | Show Current Section Header | Boolean |  | false | When set to true this displays the currently active section name as a heading above the rendered form content |
| lightning__RecordPage | formName | Form Name | String |  |  | Please provide the developer name of the form you want to display |
| lightning__RecordPage | recordId | RecordId | String |  |  | Please provide the recordId for your parent record for use within the form |
| lightning__RecordPage | defaultPage | Default Page | Integer |  |  | Enter the section number that you want to default the loading to |
| lightning__RecordPage | scrollToTopOffset | On Click Scroll Offset | Integer |  |  | Selecting a section will scroll to the top but you might want to offset that in px, enter a number without the px to set the offset difference |
| lightning__RecordPage | navWidth | Tab Navigation Width | String |  | 12rem | You can use this to determine the width of the tab columns, for full responsiveness you should use rem options, the default is 12rem |
| lightning__RecordPage | getLanguage | Get Language | Boolean |  | false | Tick this is you want to pass in the the URL site language on to the flow, to prevent errors you will need a varaible varLanguage available within the flow as an input |
| lightning__RecordPage | showSectionHeader | Show Current Section Header | Boolean |  | false | When set to true this displays the currently active section name as a heading above the rendered form content |
| lightningCommunity__Default | formName | Form Name | String |  |  | Please provide the developer name of the form you want to display |
| lightningCommunity__Default | recordId | RecordId | String |  |  | Please provide the recordId for your parent record for use within the form |
| lightningCommunity__Default | defaultPage | Default Page | Integer |  |  | Enter the section number that you want to default the loading to |
| lightningCommunity__Default | scrollToTopOffset | On Click Scroll Offset | Integer |  |  | Selecting a section will scroll to the top but you might want to offset that in px, enter a number without the px to set the offset difference |
| lightningCommunity__Default | navWidth | Tab Navigation Width | String |  | 12rem | You can use this to determine the width of the tab columns, for full responsiveness you should use rem options, the default is 12rem |
| lightningCommunity__Default | getLanguage | Get Language | Boolean |  | false | Tick this is you want to pass in the the URL site language on to the flow, to prevent errors you will need a varaible varLanguage available within the flow as an input |
| lightningCommunity__Default | showSectionHeader | Show Current Section Header | Boolean |  | false | When set to true this displays the currently active section name as a heading above the rendered form content |
| lightning__FlowScreen | formName | Form Name | String |  |  | Please provide the developer name of the form you want to display |
| lightning__FlowScreen | recordId | RecordId | String |  |  | Please provide the recordId for your parent record for use within the form |
| lightning__FlowScreen | defaultPage | Default Page | Integer |  |  | Enter the section number that you want to default the loading to |
| lightning__FlowScreen | scrollToTopOffset | On Click Scroll Offset | Integer |  |  | Selecting a section will scroll to the top but you might want to offset that in px, enter a number without the px to set the offset difference |
| lightning__FlowScreen | navWidth | Tab Navigation Width | String |  | 12rem | You can use this to determine the width of the tab columns, for full responsiveness you should use rem options, the default is 12rem |
| lightning__FlowScreen | getLanguage | Get Language | Boolean |  | false | Tick this is you want to pass in the the URL site language on to the flow, to prevent errors you will need a varaible varLanguage available within the flow as an input |
| lightning__FlowScreen | sectionsToNotDisplay | Sections to Not Display | String[] |  |  | A collection of Section APINames that you do not want to display or validate within this currently displaying of the form |
| lightning__FlowScreen | liveValidation | Perform Live Validation | Boolean |  | false | When set to true each time that a user navigated between sections the previous section will be validated, if errors are found a warning icon will appear, if no errors found a green tick will appear. This does not impact the full validation at the end of the form where the red alert will still appear. |
| lightning__FlowScreen | showSectionValidationPanel | Show inline Validation Panel per section | Boolean |  | false | When set to true this will display the inline section validation component with any errors per section, you will no longer need to use the component within the flow per section. If you are using per page configuration then you should set this to false and continue using the individual components |
| lightning__FlowScreen | showNoValidationErrorsFound | Show No Validation Errors Icon on Section | Boolean |  | false | When set to true this will display a green tick on sections that have validations configured and no errors |
| lightning__FlowScreen | showSectionHeader | Show Current Section Header | Boolean |  | false | When set to true this displays the currently active section name as a heading above the rendered form content |

## Bundle Files

- `h8FlowFormRenderComponent.css`
- `h8FlowFormRenderComponent.html`
- `h8FlowFormRenderComponent.js`
- `h8FlowFormRenderComponent.js-meta.xml`
- `h8FlowFormRenderComponent.svg`
