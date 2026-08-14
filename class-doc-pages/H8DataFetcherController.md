# H8DataFetcherController

## Description

master controller for fetching data from the server using dynamic SOQL queries. It provides methods to execute queries and return results in a structured format.

## API Version

66.0

## Sharing

with

## Methods

### getSObjects

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| queryDeveloperName | String |
| bindsJson | String |

**Output Variables**

| Type |
| --- |
| QueryResult |

**Visibility**

public

### getAvailableQueries

**Description**



**Input Variables**

None

**Output Variables**

| Type |
| --- |
| List<QueryOption> |

**Visibility**

public

### getQueryDefinition

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| queryDeveloperName | String |

**Output Variables**

| Type |
| --- |
| QueryDefinition |

**Visibility**

private

### getQueryMetadata

**Description**



**Input Variables**

None

**Output Variables**

| Type |
| --- |
| List<H8_DataFetcherQuery__mdt> |

**Visibility**

private

### validateTemplate

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| soqlTemplate | String |
| objectApiName | String |

**Output Variables**

| Type |
| --- |
| void |

**Visibility**

private

### parseBindsJson

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| bindsJson | String |

**Output Variables**

| Type |
| --- |
| Map<String, Object> |

**Visibility**

private

### resolveAccessLevel

**Description**



**Input Variables**

| Variable | Type |
| --- | --- |
| accessMode | String |

**Output Variables**

| Type |
| --- |
| System.AccessLevel |

**Visibility**

private

