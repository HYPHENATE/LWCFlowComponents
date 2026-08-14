# customTimeComponent

## Description

* @author : daniel@hyphen8.com

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Custom Time Input/Output

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| value |  |
| label |  |
| required | false |
| disabled | false |
| minValue | '00:00:00.000Z' |
| maxValue | '23:59:59.000Z' |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | value | Value | String |  |  | The content in the field. |
| lightning__FlowScreen | label | Label | String | inputOnly |  | The label of the field. |
| lightning__FlowScreen | required | Required | String | inputOnly |  | If present, the time field must be filled out before the form can be submitted. |
| lightning__FlowScreen | disabled | Disabled | String | inputOnly |  | If present, the time field is disabled and users cannot interact with it. |
| lightning__FlowScreen | minValue | Min Value | String | inputOnly |  | If present, the time has a min value set. Must be in a form of 00:00:00.000Z |
| lightning__FlowScreen | maxValue | Max Value | String | inputOnly |  | If present, the time has a max value set. Must be in a form of 23:59:59.000Z |
| lightning__FlowScreen | requiredMessage | Required Message | String | inputOnly |  | Set the message to display if the field is required and not populated. |

## Bundle Files

- `customTimeComponent.html`
- `customTimeComponent.js`
- `customTimeComponent.js-meta.xml`
- `customTimeComponent.svg`
