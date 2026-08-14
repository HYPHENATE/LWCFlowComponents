# flowPdfMergeDownloader

## Description

Merges a supplied list of PDF files referenced by ContentDocument or ContentVersion ids and downloads the result from a Screen Flow.

## API Version

66.0

## Exposed

true

## Master Label

Flow PDF Merge Downloader

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| fileIds |  |
| outputFileName | 'pdfMerge' |
| buttonLabel | 'Download Merged PDF' |
| variant | 'neutral' |
| downloadComplete | false |
| errorMessage | '' |

## Public API Methods

None

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | fileIds | File Ids | String[] | inputOnly |  | Collection of ContentDocumentIds or ContentVersionIds to merge as PDFs. |
| lightning__FlowScreen | outputFileName | Output File Name | String | inputOnly |  | Name for the downloaded merged PDF file. |
| lightning__FlowScreen | buttonLabel | Button Label | String | inputOnly |  | Label displayed on the merged PDF download button. |
| lightning__FlowScreen | variant | Button Variant | String | inputOnly |  | Optional SLDS button variant such as neutral or brand. |
| lightning__FlowScreen | downloadComplete | Download Complete | Boolean | outputOnly |  | True after the merged PDF download has started. |
| lightning__FlowScreen | errorMessage | Error Message | String | outputOnly |  | Error message returned when the PDF merge or download fails. |

## Bundle Files

- `flowPdfMergeDownloader.html`
- `flowPdfMergeDownloader.js`
- `flowPdfMergeDownloader.js-meta.xml`
