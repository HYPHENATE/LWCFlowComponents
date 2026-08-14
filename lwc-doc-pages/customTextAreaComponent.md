# customTextAreaComponent

## Description

custom text area component with word / character counter javascript

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Custom TextArea Input/Output

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| value |  |
| label |  |
| variant |  |
| required |  |
| readOnly |  |
| disabled |  |
| placeholder |  |
| fieldLevelHelp |  |
| maxCharacterCount |  |
| maxCharacterCountMessage |  |
| minCharacterCount |  |
| minCharacterCountMessage |  |
| maxWordCount |  |
| maxWordCountMessage |  |
| minWordCount |  |
| minWordCountMessage |  |
| displayCharacterCount | false |
| displayWordCount | false |
| requireFieldMessage |  |
| textAreaHeight | '40rem' |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | value | Value | String |  |  | This is the existing value for input or the current value for output. |
| lightning__FlowScreen | label | Label | String | inputOnly |  | Provide the label / title for the text area. |
| lightning__FlowScreen | fieldLevelHelp | Help Text | String | inputOnly |  | The help text that appears in a popover. |
| lightning__FlowScreen | required | Required | String | inputOnly |  | If present, the textarea field must be filled out before the form can be submitted. |
| lightning__FlowScreen | readOnly | Read Only | String | inputOnly |  | If present, the textarea field is read-only and cannot be edited. |
| lightning__FlowScreen | disabled | Disabled | String | inputOnly |  | If present, the textarea field is disabled and users cannot interact with it. |
| lightning__FlowScreen | variant | Variant | String | inputOnly |  | The variant changes the appearance of the textarea. Accepted variants include standard, label-hidden, label-inline, and label-stacked. This value defaults to standard. Use label-hidden to hide the label but make it available to assistive technology. Use label-inline to horizontally align the label and textarea. Use label-stacked to place the label above the textarea. |
| lightning__FlowScreen | placeholder | Placeholder | String | inputOnly |  | Text that is displayed when the field is empty, to prompt the user for a valid entry. |
| lightning__FlowScreen | maxCharacterCount | Max Character Count | String | inputOnly |  | Maximum number of characters allowed |
| lightning__FlowScreen | maxCharacterCountMessage | Max Character Count Message | String | inputOnly |  | Provide the text to appear should if you have set the Max Character Count and the input value exceeds this. This message is a live message and so is activated only the limit is reached.  |
| lightning__FlowScreen | minCharacterCount | Min Character Count | String | inputOnly |  | Minimum number of characters required (if value is provided) |
| lightning__FlowScreen | minCharacterCountMessage | Min Character Count Message | String | inputOnly |  | Message to show when the input value is shorter than Min Character Count. |
| lightning__FlowScreen | maxWordCount | Max Word Count | String | inputOnly |  | Maximum number of words allowed |
| lightning__FlowScreen | maxWordCountMessage | Max Word Count Message | String | inputOnly |  | Provide the text to appear should if you have set the Max Word Count and the input value exceeds this. This message is a live message and so is activated only the limit is reached.  |
| lightning__FlowScreen | minWordCount | Min Word Count | String | inputOnly |  | Minimum number of words required (if value is provided) |
| lightning__FlowScreen | minWordCountMessage | Min Word Count Message | String | inputOnly |  | Message to show when the input value has fewer words than Min Word Count. |
| lightning__FlowScreen | displayCharacterCount | Display Character Count | Boolean | inputOnly |  | Confirm that you want to apply and display the character count on page |
| lightning__FlowScreen | displayWordCount | Display Word Count | Boolean | inputOnly |  | Confirm that you want to apply and display the word count on page |
| lightning__FlowScreen | requireFieldMessage | Required field message | String | inputOnly |  | Provide a message to appear if this field is required and the value has not been provided. This message will display in 2 different places. If the field is required and the user enters the box then moves to another box it will highlight that it is required. If the user navigates to the next page within the flow and the value has not been provided it will appear. |
| lightning__FlowScreen | textAreaHeight | Input box minimum height | String | inputOnly |  | Define the minimum height of the input box supports px, em or rem sizes but you must include them so 300px/30em/30rem are all valid |

## Bundle Files

- `customTextAreaComponent.css`
- `customTextAreaComponent.html`
- `customTextAreaComponent.js`
- `customTextAreaComponent.js-meta.xml`
- `customTextAreaComponent.svg`
