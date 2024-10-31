/**
 * @description       : js to support with handling a delete request
 * @author            : daniel@hyphen8.com
 * @last modified on  : 31/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';
import deleteContentDoc from '@salesforce/apex/H8FlowFileUploadController.deleteContentDoc';
import { reduceErrors } from 'c/h8UtilReduceErrors';
import toastTitle from '@salesforce/label/c.H8FFUCStandardToastTitle';
import cancelLabel from '@salesforce/label/c.H8FFUCDeleteModalCancelLabel';
import deleteFileLabel from '@salesforce/label/c.H8FFUCDeleteFileLabel';
import deleteFileGuidanceText from '@salesforce/label/c.H8FFUCDeleteFileGuidanceText';
import deleteFileFieldLabel from '@salesforce/label/c.H8FFUCDeleteFileFieldLabel';

export default class H8FlowFileUploadDeleteFile extends LightningElement {
    @api objFile;
    showConfirmDelete = false;
    cancelLabel = cancelLabel;
    deleteFileLabel = deleteFileLabel;
    deleteFileGuidanceText = deleteFileGuidanceText;
    deleteFileFieldLabel = deleteFileFieldLabel;

    handleDeleteDocument(event){
        this.showConfirmDelete = true;
    }

    closeModal(event){
        this.showConfirmDelete = false;
    }

    confirmDelete(event){
        this.showConfirmDelete = false;
        this.deleteDocument();
    }

    // onclick event that will delete an uploaded document if disableFileDelete is set to false
    deleteDocument(event){
        deleteContentDoc({contentVersionId: this.objFile.contentVersionId})
        .then(() => {
            this.dispatchEventFunction('deletefile');
        })
        .catch((error) => {
            this.showToast(toastTitle, reduceErrors(error).toString(), 'error');
        })
    }

    // generic dispatch event function
    dispatchEventFunction(eventName, eventDetail) {
       this.dispatchEvent(new CustomEvent(eventName, { eventDetail }));
    }
}