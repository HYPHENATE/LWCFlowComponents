# customPrintButton

## Description

js for custom print button

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Custom Print Button

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| buttonLabel |  |
| buttonAssistiveText |  |
| buttonFloat |  |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | buttonLabel | Button Label | String | inputOnly |  | This is the label for the print button, it is never displayed on screen but does appear when someone hovers over the button. |
| lightning__FlowScreen | buttonAssistiveText | Button Assistive Text | String | inputOnly |  | Assistive text for the button, this is read by screen readers when a user tabs between items on screen and should be descriptive of the action. |
| lightning__FlowScreen | buttonFloat | Button Float | String | inputOnly |  | Populate this with slds-float_left, slds-float_right or leave blank to position the button on screen. |

## Bundle Files

- `customPrintButton.html`
- `customPrintButton.js`
- `customPrintButton.js-meta.xml`
- `customPrintButton.svg`
