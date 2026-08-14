# H8FilePdfZipHelper

## Description

Retrieves file payloads for ContentDocument or ContentVersion ids so client-side ZIP/PDF utilities can work without browser CORS issues.

## API Version

66.0

## Sharing

with

## Methods

### getFilePayloads

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| fileIds | List<String> |

**Output Variables**

| Type |
| --- |
| List<FilePayload> |

**Visibility**

public

### applyContentVersion

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| payload | FilePayload |
| contentVersion | ContentVersion |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### buildFileName

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| contentVersion | ContentVersion |

**Output Variables**

| Type |
| --- |
| String |

**Visibility**

private

### tryParseId

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| value | String |

**Output Variables**

| Type |
| --- |
| Id |

**Visibility**

private

