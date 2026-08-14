# TEMPLATE_DataFetcher_Example

## Description



## Label

TEMPLATE - DataFetcher Example

## API Version

66.0

## Flow Type

Flow

## Status

Draft

## Template

true

## Interview Label

TEMPLATE - DataFetcher Example {!$Flow.CurrentDateTime}

## Variables

None

## Flow Elements

| Name | Label | Type | Detail |
| --- | --- | --- | --- |
| SampleScreen | SampleScreen | Screen | 3 field(s), 2 component instance(s) |

## Screen Components

| Screen | Field | Component | Inputs |
| --- | --- | --- | --- |
| SampleScreen | dataFetcherExample | c:h8DataFetcher | queryDeveloperName=AccountByType, bindsJson=dataFetcherBindValues |
| SampleScreen | accountsTable | flowruntime:datatable | label=Accounts, selectionMode=NO_SELECTION, minRowSelection=0.0, shouldDisplayLabel=true, tableData=dataFetcherExample.retrievedRecords, isShowSearchBar=true, maxRowSelection=0.0, columns=[{"apiName":"Name","guid":"column-3e9c","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":0,"sortable":false,"label":"Account Name","type":"text"},{"apiName":"Type","guid":"column-8cc9","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":1,"sortable":false,"label":"Account Type","type":"text"}] |

## Source File

- `force-app/main/default/flows/TEMPLATE_DataFetcher_Example.flow-meta.xml`
