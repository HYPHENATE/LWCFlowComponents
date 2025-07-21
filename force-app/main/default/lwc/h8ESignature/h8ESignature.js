/**
 * @description       : js to support with collection of the esignature
 * @author            : daniel@hyphen8.com
 * @last modified on  : 17-07-2025
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';
import { reduceErrors } from 'c/h8UtilReduceErrors';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import SIGNATURE_PAD from '@salesforce/resourceUrl/H8ESignature';
import processSignature from '@salesforce/apex/H8SignatureController.processSignature';
import labels from './labels';

export default class H8ESignature extends LightningElement {
    @api isReadOnly = false;
    @api required = false;
    @api signatureFileName;
    @api recordId;
    @api signatureRecordId;
    label = labels;
    
    signaturePad;
    canvas;
    signaturePadInitialized = false;
    saveComplete = false;

    @api
    validate(){
        if(this.required && this.signatureRecordId == undefined){
            return {
                isValid: false,
                errorMessage: labels.requiredValidationMessage
            }
        } else {
            return {
                isValid: true
            }
        }
    }
    
    renderedCallback() {
        if (this.signaturePadInitialized) return;
        this.signaturePadInitialized = true;
        Promise.all([
            loadScript(this, SIGNATURE_PAD)
        ]).then(() => {
            this.canvas = this.template.querySelector('canvas');
            this.resizeCanvas();
            this.signaturePad = new window.SignaturePad(this.canvas);
            if(this.isReadOnly){
                this.signaturePad.off();
            }
        }).catch(error => {
            this.showToast('Error', labels.failedToLoadLibraryToastMessage + ' ' + reduceErrors(error).toString(), 'error');
        });
    }

    resizeCanvas() {
        const ratio = Math.max(window.devicePixelRatio || 1, 1);
        this.canvas.width = this.canvas.offsetWidth * ratio;
        this.canvas.height = this.canvas.offsetHeight * ratio;
        this.canvas.getContext('2d').scale(ratio, ratio);
    }

    get disableSaveButtons(){
        if(this.isReadOnly){
            return true;
        } else {
            return false;
        }
    }

    clearSignature() {
        this.signaturePad.clear();
    }

    saveSignature() {
        if (this.signaturePad.isEmpty()) {
            this.showToast('Error', labels.signatureRequiredToastMessage, 'error');
        } else {
            this.signaturePad.off();
            const dataUrl = this.signaturePad.toDataURL();
            this.handleSaveContentVersion(dataUrl);
        }
    }

    handleSaveContentVersion(dataUrl) {
        processSignature({
           recordId: this.recordId,
           signatureName: this.signatureFileName,
           dataUrl: dataUrl
        })
        .then((results) => {
            this.signatureRecordId = results;
            this.saveComplete = true;
        })
        .catch((error) => {
            this.showToast('Error', labels.failedToSaveSignatureToastMessage + ' ' + reduceErrors(error).toString(), 'error');
        });
    }

    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({title: toastTitle, message: toastMessage, variant: toastVariant}));
    }
}