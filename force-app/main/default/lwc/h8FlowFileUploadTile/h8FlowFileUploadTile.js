/**
 * @description       : js to support with flow tile output
 * @author            : daniel@hyphen8.com
 * @last modified on  : 31/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';
export default class H8FlowFileUploadTile extends LightningElement {
    @api objFile;

    // onclick event that will open a file for preview using the standard namedPage filePreview
    openFile(event) {
        let contentDocumentId = event.currentTarget.dataset.docid;
        event.preventDefault();
        let downloadUrl = 'https://' + window.location.hostname + '/sfc/servlet.shepherd/document/download/' + contentDocumentId + '?operationContext=S1';
        window.open(downloadUrl);
    }
}