import { LightningElement, api, wire } from 'lwc';
import base64Image from '@salesforce/apex/H8SignatureController.getBase64Image';
import errorText from '@salesforce/label/c.H8ESignatureViewError';
import signatureAlt from '@salesforce/label/c.H8ESignatureAltValue';

export default class H8SignatureView extends LightningElement {
    @api contentVersionId;
    imageDataUri;
    error;
    errorText = errorText;
    signatureAlt = signatureAlt;

    @wire(base64Image, { contentVersionId: '$contentVersionId' })
    wiredImage({ error, data }) {
        if (data) {
            this.imageDataUri = `data:image/png;base64,${data}`;
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
        }
    }
}