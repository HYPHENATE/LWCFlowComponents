# h8LightningInputDate

## Description

javascript for lightning-input date

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Custom Lightning Input (Date)

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
| max |  |
| min |  |
| messageWhenValueMissing |  |
| messageWhenRangeOverflow |  |
| messageWhenRangeUnderflow |  |
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
| lightning__FlowScreen | value | Field Value | Date |  |  | This is the current and new value for this field |
| lightning__FlowScreen | fieldLevelHelp | Field Level Help | String | inputOnly |  | Provide some guidance text that will appear in the help popup icon |
| lightning__FlowScreen | required | Required | Boolean | inputOnly | false | Set this if you want this field to be required for input |
| lightning__FlowScreen | disabled | Disabled | Boolean | inputOnly | false | Set this if you want to disable the ability to interact with this field |
| lightning__FlowScreen | readOnly | Read Only | Boolean | inputOnly | false | Set this if you want to make the input read only but still appear as an input field |
| lightning__FlowScreen | max | Maximum Date | Date | inputOnly |  | This is the maximum date value that you want to allow within this field |
| lightning__FlowScreen | min | Minimum Date | Date | inputOnly |  | This is the minimum date value that you want to allow within this field |
| lightning__FlowScreen | messageWhenValueMissing | Required value missing message | String | inputOnly |  | Provide text here that will appear if you have set the field as required, this can appear twice during the process, once if the user clicks into the field and doesn't set a value and then again if the user presses next/finish within the flow. |
| lightning__FlowScreen | messageWhenRangeOverflow | Message when date provided is over the minimum date | String | inputOnly |  | This is the message you want to display when the provided date is over your defined maximum date value |
| lightning__FlowScreen | messageWhenRangeUnderflow | Message when date provided is under the minimum date | String | inputOnly |  | This is the message you want to display when the provided date is under your defined minimum date value |
| lightning__FlowScreen | messageWhenBadInput | Message value provided is not a date | String | inputOnly |  | This is the message you want to display when the input provided is not a date or in correct date format |
| lightning__FlowScreen | variant | Variant | String | inputOnly |  | The variant changes the appearance of an input field. Accepted variants include standard, label-inline, label-hidden, and label-stacked. This value defaults to standard, which displays the label above the field. Use label-hidden to hide the label but make it available to assistive technology. Use label-inline to horizontally align the label and input field. Use label-stacked to place the label above the input field. |

## Bundle Files

- `h8LightningInputDate.html`
- `h8LightningInputDate.js`
- `h8LightningInputDate.js-meta.xml`
- `h8LightningInputDate.svg`
