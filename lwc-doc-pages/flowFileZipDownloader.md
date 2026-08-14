# flowFileZipDownloader

## Description

Downloads a supplied list of ContentDocument or ContentVersion files as a ZIP archive from a Screen Flow.

## API Version

66.0

## Exposed

true

## Master Label

Flow File ZIP Downloader

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| fileIds |  |
| outputFileName | 'fileZip' |
| buttonLabel | 'Download ZIP' |
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
| lightning__FlowScreen | fileIds | File Ids | String[] | inputOnly |  | Collection of ContentDocumentIds or ContentVersionIds to include in the ZIP. |
| lightning__FlowScreen | outputFileName | Output File Name | String | inputOnly |  | Name for the downloaded ZIP file. |
| lightning__FlowScreen | buttonLabel | Button Label | String | inputOnly |  | Label displayed on the ZIP download button. |
| lightning__FlowScreen | variant | Button Variant | String | inputOnly |  | Optional SLDS button variant such as neutral or brand. |
| lightning__FlowScreen | downloadComplete | Download Complete | Boolean | outputOnly |  | True after the ZIP download has started. |
| lightning__FlowScreen | errorMessage | Error Message | String | outputOnly |  | Error message returned when the ZIP download fails. |

## Bundle Files

- `flowFileZipDownloader.html`
- `flowFileZipDownloader.js`
- `flowFileZipDownloader.js-meta.xml`
