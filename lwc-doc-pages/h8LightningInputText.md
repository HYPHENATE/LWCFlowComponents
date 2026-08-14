# h8LightningInputText

## Description

js for lightning-input component

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Custom Lightning Input (Text)

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| label |  |
| placeholder |  |
| value |  |
| required |  |
| disabled |  |
| readOnly |  |
| fieldLevelHelp |  |
| maxLength |  |
| minLength |  |
| messageWhenValueMissing |  |
| messageWhenTooLong |  |
| messageWhenTooShort |  |
| showCharacterCount |  |
| variant |  |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | label | Field Label | String | inputOnly |  | Provide the field label / title for output |
| lightning__FlowScreen | placeholder | Field Placeholder | String | inputOnly |  | Provide a placeholder for the field as an example |
| lightning__FlowScreen | value | Field Value | String |  |  | This is the current and new value for this field |
| lightning__FlowScreen | fieldLevelHelp | Field Level Help | String | inputOnly |  | Provide some guidance text that will appear in the help popup icon |
| lightning__FlowScreen | required | Required | Boolean | inputOnly | false | Set this if you want this field to be required for input |
| lightning__FlowScreen | disabled | Disabled | Boolean | inputOnly | false | Set this if you want to disable the ability to interact with this field |
| lightning__FlowScreen | readOnly | Read Only | Boolean | inputOnly | false | Set this if you want to make the input read only but still appear as an input field |
| lightning__FlowScreen | maxLength | Maximum Character Length | Integer | inputOnly | 255 | Set the maximum number of characters allowed for this field |
| lightning__FlowScreen | minLength | Minimum Character Length | Integer | inputOnly | 0 | Set the minimum number of characters allowed for this field |
| lightning__FlowScreen | messageWhenValueMissing | Required value missing message | String | inputOnly |  | Provide text here that will appear if you have set the field as required, this can appear twice during the process, once if the user clicks into the field and doesn't set a value and then again if the user presses next/finish within the flow. |
| lightning__FlowScreen | messageWhenTooLong | Message when too many characters provided | String | inputOnly |  | Provide text here to display on the component when the number of characters provided is greater than your set limit. |
| lightning__FlowScreen | messageWhenTooShort | Message when not enought characters provided | String | inputOnly |  | Provide text here to display on the component when the number of characters provided is less then you set limit |
| lightning__FlowScreen | showCharacterCount | Display the character count | Boolean | inputOnly | false | Set this if you would like to display the character counter for the user as feedback during entering of their text |
| lightning__FlowScreen | variant | Variant | String | inputOnly |  | The variant changes the appearance of an input field. Accepted variants include standard, label-inline, label-hidden, and label-stacked. This value defaults to standard, which displays the label above the field. Use label-hidden to hide the label but make it available to assistive technology. Use label-inline to horizontally align the label and input field. Use label-stacked to place the label above the input field. |

## Bundle Files

- `h8LightningInputText.html`
- `h8LightningInputText.js`
- `h8LightningInputText.js-meta.xml`
- `h8LightningInputText.svg`
