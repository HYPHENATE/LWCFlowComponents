# TEMPLATE_Flow_Zip_Files

## Description



## Label

TEMPLATE - Flow Zip Files

## API Version

67.0

## Flow Type

Flow

## Status

Draft

## Template

true

## Interview Label

TEMPLATE - Flow Zip Files {!$Flow.CurrentDateTime}

## Variables

None

## Flow Elements

| Name | Label | Type | Detail |
| --- | --- | --- | --- |
| Get_Account | Get Account | Screen | 2 field(s), 1 component instance(s) |
| PDFMergeZipPage | PDFMergeZipPage | Screen | 3 field(s), 1 component instance(s) |
| ZipPage | ZipPage | Screen | 1 field(s), 1 component instance(s) |
| Get_Content_Document_Links | Get Content Document Links | Record Lookup | ContentDocumentLink |
| Get_ZIP_Documents | Get ZIP Documents | Record Lookup | ContentDocument |
| Transform_Content_Document_Ids | Transform Content Document Ids | Transform | String |
| Transform_Zip_File_Ids | Transform Zip File Ids | Transform | String |

## Screen Components

| Screen | Field | Component | Inputs |
| --- | --- | --- | --- |
| Get Account | selectAccount | flowruntime:lookup | fieldApiName=AccountId, label=Account, objectApiName=Contact, maxValues=1.0, required=true |
| PDFMergeZipPage | zipDataTable | flowruntime:datatable | label=Files for Zipping, selectionMode=MULTI_SELECT, minRowSelection=1.0, tableData=Get_ZIP_Documents, shouldDisplayLabel=true, columns=[{"apiName":"Title","guid":"column-916e","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":0,"sortable":false,"label":"Title","type":"text"},{"apiName":"ContentSize","guid":"column-6643","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":1,"sortable":false,"label":"Size","type":"customRichText"},{"apiName":"FileType","guid":"column-5cf4","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":2,"sortable":false,"label":"File Type","type":"text"}] |
| ZipPage | zipComponent | c:flowFileZipDownloader | fileIds=Transform_Zip_File_Ids, buttonLabel=Download Zip File, variant=brand, outputFileName=Name_of_Zip_File |

## Source File

- `force-app/main/default/flows/TEMPLATE_Flow_Zip_Files.flow-meta.xml`
