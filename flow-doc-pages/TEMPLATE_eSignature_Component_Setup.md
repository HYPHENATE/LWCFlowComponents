# TEMPLATE_eSignature_Component_Setup

## Description



## Label

TEMPLATE - eSignature Component Setup

## API Version

66.0

## Flow Type

Flow

## Status

Draft

## Template

true

## Interview Label

TEMPLATE - eSignature Component Setup {!$Flow.CurrentDateTime}

## Variables

| Name | DataType | ObjectOrClass | Collection | Input | Output | Default |
| --- | --- | --- | --- | --- | --- | --- |
| recordId | String |  | false | true | false |  |
| savedSignatureId | String |  | false | false | false |  |

## Flow Elements

| Name | Label | Type | Detail |
| --- | --- | --- | --- |
| DisplaySignatureScreen | DisplaySignatureScreen | Screen | 2 field(s), 1 component instance(s) |
| ESignatureScreen | ESignatureScreen1 | Screen | 2 field(s), 1 component instance(s) |
| ESignatureScreen2 | ESignatureScreen2 | Screen | 2 field(s), 1 component instance(s) |
| SignatureScreen3 | SignatureScreen3 | Screen | 2 field(s), 1 component instance(s) |

## Screen Components

| Screen | Field | Component | Inputs |
| --- | --- | --- | --- |
| DisplaySignatureScreen | displaySignatureComponent | c:h8SignatureView | contentVersionId=savedSignatureId |
| ESignatureScreen1 | page1Signature | c:h8ESignature | recordId=recordId, signatureFileName=signature, isReadOnly=false, required=false |
| ESignatureScreen2 | page2Signature | c:h8ESignature | recordId=recordId, signatureFileName=signature, isReadOnly=false, required=true |
| SignatureScreen3 | page3Signature | c:h8ESignature | recordId=recordId, signatureFileName=signature, isReadOnly=true, required=false |

## Source File

- `force-app/main/default/flows/TEMPLATE_eSignature_Component_Setup.flow-meta.xml`
