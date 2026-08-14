# customRichTextComponent

## Description

custom rich text area component with word / character counter

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Custom Rich Text Input/Output

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| value |  |
| label |  |
| fieldLevelHelp |  |
| required |  |
| readOnly |  |
| disabled |  |
| labelVisible |  |
| placeholder |  |
| maxCharacterCount |  |
| maxCharacterCountMessage |  |
| minCharacterCount |  |
| minCharacterCountMessage |  |
| maxWordCount |  |
| maxWordCountMessage |  |
| minWordCount |  |
| minWordCountMessage |  |
| formats |  |
| displayCharacterCount | false |
| displayWordCount | false |
| requireFieldMessage |  |
| textAreaHeight |  |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | value | Value | String |  |  | This is the input and output value for this rich text component. |
| lightning__FlowScreen | label | Label | String | inputOnly |  | Provide the label / title for the rich text area. |
| lightning__FlowScreen | fieldLevelHelp | Help Text | String | inputOnly |  | The help text that appears in a popover. |
| lightning__FlowScreen | required | Required | String | inputOnly |  | If present, the textarea field must be filled out before the form can be submitted. Accepts true or false |
| lightning__FlowScreen | readOnly | Read Only (Depreciated) | String | inputOnly |  | If present, the textarea field is read-only and cannot be edited. Accepts true or false |
| lightning__FlowScreen | disabled | Disabled | String | inputOnly |  | If present, the textarea field is disabled and users cannot interact with it. Accepts true or false |
| lightning__FlowScreen | labelVisible | Label Visible | String | inputOnly |  | If present, the label on the rich text editor is visible. Accepts true or false |
| lightning__FlowScreen | placeholder | Placeholder | String | inputOnly |  | Text that is displayed when the field is empty, to prompt the user for a valid entry. |
| lightning__FlowScreen | maxCharacterCount | Max Character Count | String | inputOnly |  | Maximum number of characters allowed |
| lightning__FlowScreen | maxCharacterCountMessage | Max Character Count Message | String | inputOnly |  | Maximum number of characters allowed error message |
| lightning__FlowScreen | minCharacterCount | Min Character Count | String | inputOnly |  | Minimum number of characters required (if value is provided) |
| lightning__FlowScreen | minCharacterCountMessage | Min Character Count Message | String | inputOnly |  | Message to show when the input value is shorter than Min Character Count. |
| lightning__FlowScreen | maxWordCount | Max Word Count | String | inputOnly |  | Maximum number of words allowed |
| lightning__FlowScreen | maxWordCountMessage | Max Word Count Message | String | inputOnly |  | Maximum number of words allowed error message |
| lightning__FlowScreen | minWordCount | Min Word Count | String | inputOnly |  | Minimum number of words required (if value is provided) |
| lightning__FlowScreen | minWordCountMessage | Min Word Count Message | String | inputOnly |  | Message to show when the input value has fewer words than Min Word Count. |
| lightning__FlowScreen | formats | Formats | String | inputOnly |  | A list of allowed formats. By default, the list is computed based on enabled categories. The 'table' format is always enabled to support copying and pasting of tables if formats are not provided. |
| lightning__FlowScreen | displayCharacterCount | Display Character Count | Boolean | inputOnly |  | Confirm that you want to apply and display the character count on page |
| lightning__FlowScreen | displayWordCount | Display Word Count | Boolean | inputOnly |  | Confirm that you want to apply and display the word count on page |
| lightning__FlowScreen | requireFieldMessage | Required field message | String | inputOnly |  | Provide a message when a field is required but not completed |
| lightning__FlowScreen | textAreaHeight | Input box minimum height | String | inputOnly |  | Define the minimum height of the input box supports px, em or rem sizes but you must include them so 300px/30em/30rem are all valid |

## Bundle Files

- `customRichTextComponent.css`
- `customRichTextComponent.html`
- `customRichTextComponent.js`
- `customRichTextComponent.js-meta.xml`
- `customRichTextComponent.svg`
