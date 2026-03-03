/**
 * @description       : js to support with flow tile output
 * @author            : daniel@hyphen8.com
 * @last modified on  : 03-03-2026
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';
export default class H8FlowFileUploadTile extends LightningElement {
    @api objFile;

    // onclick event that will open a file for preview using the standard namedPage filePreview
    openFile(event) {
        event.preventDefault();

        const contentDocumentId = event.currentTarget.dataset.docid;

        // Handles both: https://host/s/... and https://host/<sitePrefix>/s/...
        const path = window.location.pathname;
        const sIndex = path.indexOf('/s/');
        const sitePrefix = sIndex > -1 ? path.substring(0, sIndex) : '';

        const downloadUrl =
            `${window.location.origin}${sitePrefix}` +
            `/sfc/servlet.shepherd/document/download/${encodeURIComponent(contentDocumentId)}?operationContext=S1`;

        window.open(downloadUrl, '_blank');
    }
}