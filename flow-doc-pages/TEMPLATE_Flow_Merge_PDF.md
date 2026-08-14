# TEMPLATE_Flow_Merge_PDF

## Description



## Label

TEMPLATE - Flow Merge PDF

## API Version

67.0

## Flow Type

Flow

## Status

Draft

## Template

false

## Interview Label

TEMPLATE - Flow Merge PDF {!$Flow.CurrentDateTime}

## Variables

None

## Flow Elements

| Name | Label | Type | Detail |
| --- | --- | --- | --- |
| Get_Account | Get Account | Screen | 2 field(s), 1 component instance(s) |
| MergePage | MergePage | Screen | 1 field(s), 1 component instance(s) |
| PDFMergePage | PDFMergePage | Screen | 3 field(s), 1 component instance(s) |
| Get_Content_Document_Links | Get Content Document Links | Record Lookup | ContentDocumentLink |
| Get_PDF_Documents | Get PDF Documents | Record Lookup | ContentDocument |
| Transform_Content_Document_Ids | Transform Content Document Ids | Transform | String |
| Transform_File_Names | Transform File Names | Transform | String |
| Transform_PDF_File_Ids | Transform PDF File Ids | Transform | String |

## Screen Components

| Screen | Field | Component | Inputs |
| --- | --- | --- | --- |
| Get Account | selectAccount | flowruntime:lookup | fieldApiName=AccountId, label=Account, objectApiName=Contact, maxValues=1.0, required=true |
| MergePage | pdfMergeComponent | c:flowPdfMergeDownloader | fileIds=Transform_PDF_File_Ids, buttonLabel=Merge PDFs, variant=brand, outputFileName=Name_of_PDF_File |
| PDFMergePage | mergeDataTable | flowruntime:datatable | label=Files for Merging, selectionMode=MULTI_SELECT, minRowSelection=1.0, tableData=Get_PDF_Documents, shouldDisplayLabel=true, columns=[{"apiName":"Title","guid":"column-916e","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":0,"sortable":false,"label":"Title","type":"text"},{"apiName":"ContentSize","guid":"column-6643","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":1,"sortable":false,"label":"Size","type":"customRichText"},{"apiName":"FileType","guid":"column-5cf4","editable":false,"hasCustomHeaderLabel":false,"customHeaderLabel":"","wrapText":true,"order":2,"sortable":false,"label":"File Type","type":"text"}] |

## Source File

- `force-app/main/default/flows/TEMPLATE_Flow_Merge_PDF.flow-meta.xml`
