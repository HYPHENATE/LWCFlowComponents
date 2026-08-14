# customFlowNavigationButton

## Description

js for supporting a custom button in a flow

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Custom Flow Navigation Button

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| buttonLabel |  |
| variant |  |
| flowAction |  |
| position |  |
| buttonPressed | false |
| stetchButton | false |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | buttonLabel | Label | String |  |  | Label to be displayed on the button |
| lightning__FlowScreen | variant | Button Variant | String |  |  | Following SLDS Standards accepted values brand,base,neutral,brand-outline,destructive,destructive-text,inverse,success |
| lightning__FlowScreen | flowAction | FLOW Action | String |  |  | On click where do we go in the flow NEXT or PREVIOUS or FINISH |
| lightning__FlowScreen | position | Button position | String |  |  | Float the button on the LEFT or on the RIGHT leave blank for anywhere |
| lightning__FlowScreen | buttonPressed | Confirmation Button Pressed | Boolean |  |  | Confirms that the button has been pressed |
| lightning__FlowScreen | stetchButton | Stretch button to fill available space | Boolean |  | false | Forces the button to fill the entire space available |

## Bundle Files

- `customFlowNavigationButton.css`
- `customFlowNavigationButton.html`
- `customFlowNavigationButton.js`
- `customFlowNavigationButton.js-meta.xml`
- `customFlowNavigationButton.svg`
