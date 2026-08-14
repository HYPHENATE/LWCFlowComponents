# h8ESignature

## Description

js to support with collection of the esignature

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - ESignature

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| isReadOnly | false |
| required | false |
| signatureFileName |  |
| recordId |  |
| signatureRecordId |  |

## Public API Methods

| Method | Parameters |
| --- | --- |
| validate |  |

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | isReadOnly | Is Read Only | Boolean | inputOnly | false | Set this to true if the signature has already been returned and you just want to output the signature for view |
| lightning__FlowScreen | required | Required | Boolean | inputOnly | false | Use this to enforce that a signature is provided prior to navigation to the next screen |
| lightning__FlowScreen | signatureFileName | Signature File Name | String | inputOnly |  | The file name to use when saving the signature image |
| lightning__FlowScreen | recordId | Record Id | String | inputOnly |  | The Id of the record to which this signature is related. This is used to save the signature to the correct record. |
| lightning__FlowScreen | signatureRecordId | Saved Signature Id | String | outputOnly |  | This is the content version id saved during the process |

## Bundle Files

- `h8ESignature.css`
- `h8ESignature.html`
- `h8ESignature.js`
- `h8ESignature.js-meta.xml`
- `h8ESignature.svg`
- `labels.js`
