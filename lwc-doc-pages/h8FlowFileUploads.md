# h8FlowFileUploads

## Description

js to support with file uploads

## API Version

66.0

## Exposed

true

## Master Label

Hyphen8 - Flow File Upload

## Targets

- `lightning__FlowScreen`

## Public API Properties

| Property | Default |
| --- | --- |
| recordId |  |
| allowMultipleFiles |  |
| disableFileDelete |  |
| helpText |  |
| fileUploadLabel |  |
| overrideConfiguration |  |
| required |  |
| requiredValidationMessage |  |
| existingFileIds | [] |
| uploadedlabel |  |
| showUploadButton |  |

## Public API Methods

| Method | Parameters |
| --- | --- |
| validate |  |

## Exported Functions

None

## Builder Properties

| Target(s) | Property | Label | Type | Role | Default | Description |
| --- | --- | --- | --- | --- | --- | --- |
| lightning__FlowScreen | recordId | Related Record Id | String | inputOnly |  | Provide the parent Id that you wish to associate your uploaded File/s with. |
| lightning__FlowScreen | fileUploadLabel | File Upload Label | String | inputOnly |  | This is the label for your file upload button. |
| lightning__FlowScreen | uploadedlabel | Uploaded File List Label | String | inputOnly |  | The text on the list of files uploaded. |
| lightning__FlowScreen | acceptedFormats | Accepted Formats | String | inputOnly |  | The accepted file types. Enter a comma-separated list of the file extensions (such as .jpg,.pdf,.xlsx,.docx) |
| lightning__FlowScreen | allowMultipleFiles | Allow Multiple Files | Boolean | inputOnly |  | Allow the user to upload multiple files. If this is not TRUE, then once the user uploads one file, the file upload component will not allow any additional files to be uploaded. |
| lightning__FlowScreen | existingFileIds | Existing File Ids | String[] | inputOnly |  | This is a collection(text) of ContentDocumentId that have already been uploaded. |
| lightning__FlowScreen | required | Required | Boolean | inputOnly |  | Require the user to upload at least one file. |
| lightning__FlowScreen | showUploadButton | Show Upload Button | Boolean | inputOnly |  | If you want to dynamically display this button dependant on if the form is now in readonly mode set this to false, when set to true the button will display. The button is still disable automatically in some cases. |
| lightning__FlowScreen | requiredValidationMessage | Required Validation Message | String | inputOnly |  | When component is configured that files are required, this is the message that will display to the user if they do not perform the action. This message will only display when they attempt to navigation to the next screen or finish the flow. |
| lightning__FlowScreen | overrideConfiguration | File Configuration | String | inputOnly |  | This is the configuration that you created in meta data, specify the DeveloperAPIName for the Metadata record which will contain your custom configuration |
| lightning__FlowScreen | disableFileDelete | Disable File Deletion | Boolean | inputOnly |  | When this is TRUE the X next to the file will not be available. |
| lightning__FlowScreen | helpText | Help Text | String | inputOnly |  | The message that will be displayed in the help text popup. |

## Bundle Files

- `h8FlowFileUploads.html`
- `h8FlowFileUploads.js`
- `h8FlowFileUploads.js-meta.xml`
- `h8FlowFileUploads.svg`
