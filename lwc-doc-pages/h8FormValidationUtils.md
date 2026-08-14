# h8FormValidationUtils

## Description

@file

## API Version

66.0

## Exposed

false

## Master Label



## Targets

None

## Public API Properties

None

## Public API Methods

None

## Exported Functions

| Function | Parameters |
| --- | --- |
| norm | s |
| loose | s |
| keysEqual | a, b |
| findMatchingKey | keys, target |
| toBool | v |
| uiKey | uiSection |
| serverKey | serverSection |
| getAllStore |  |
| setAllStore | obj |
| readFlexibleStore | key, recordId |
| getRecordStore | recordId |
| setRecordStore | recordId, patch |
| ackMasterTrigger | recordId |
| suppressLiveValidationNow | recordId |
| persistLiveValidationForSection | recordId, label, pages, hasErrors |
| upsertMasterSectionResult | recordId, label, pages, hasErrors |
| masterHasErrorsForSection | store, sectionKey |
| liveHasErrorsForSection | store, sectionKey |
| masterHasErrorsForPage | store, sectionKey, pageName |
| liveHasErrorsForPage | store, sectionKey, pageName |
| gateSectionRender | store, sectionKey |
| gatePageRender | store, sectionKey, pageName |

## Builder Properties

None

## Bundle Files

- `h8FormValidationUtils.js`
- `h8FormValidationUtils.js-meta.xml`
