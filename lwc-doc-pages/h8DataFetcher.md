# h8DataFetcher

## Description

LWC component for CPE of Data Fetcher Flow Action

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Data Fetcher

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| queryDeveloperName |  |
| bindsJson |  |
| firstRetrievedRecord |  |
| retrievedRecords | [] |
| error |  |
| debounceTime |  |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | queryDeveloperName | Query Developer Name | String | inputOnly |  | DeveloperName of the H8_DataFetcherQuery__mdt record to execute. |
| lightning__FlowScreen | bindsJson | Bind Variables (JSON) | String | inputOnly |  | JSON object mapping bind variable names to values, used with Database.queryWithBinds (e.g. {"type":"Customer"}). |
| lightning__FlowScreen | debounceTime |  | String | inputOnly | 300 |  |
| lightning__FlowScreen | firstRetrievedRecord | First Retrieved Record | {T} |  |  |  |
| lightning__FlowScreen | retrievedRecords | Retrieved Records | {T[]} |  |  |  |
| lightning__FlowScreen | error | Error Message | String | outputOnly |  | Error message when there is an error output from Data Fetcher |

## Bundle Files

- `h8DataFetcher.html`
- `h8DataFetcher.js`
- `h8DataFetcher.js-meta.xml`
