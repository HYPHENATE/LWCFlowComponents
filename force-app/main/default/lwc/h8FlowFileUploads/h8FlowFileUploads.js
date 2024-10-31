/**
 * @description       : js to support with file uploads
 * @author            : daniel@hyphen8.com
 * @last modified on  : 31/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExistingFiles from '@salesforce/apex/H8FlowFileUploadController.getExistingFiles';
import updateFileData from '@salesforce/apex/H8FlowFileUploadController.updateFileData';
import { reduceErrors } from 'c/h8UtilReduceErrors';
import toastTitle from '@salesforce/label/c.H8FFUCStandardToastTitle';
import loadingSpinnerLabel from '@salesforce/label/c.H8FFUCLoadingSpinnerLabel'; 
export default class H8FlowFileUploads extends LightningElement {

    @api recordId;
    @api acceptedFormats
    @api allowMultipleFiles;
    @api disableFileDelete;
    @api helpText;
    @api fileUploadLabel;
    @api overrideConfiguration;
    @api required;
    @api requiredValidationMessage;
    @api existingFileIds = [];
    @api uploadedlabel;
    @api showUploadButton;
    @track existingFiles = [];
    @track newFileIds = [];
    loadingSpinnerLabel = loadingSpinnerLabel;

    isLoading = true;
    @track uploadProcessing = false;
    disabled = false;

    // flow validation function to confirm if when marked as required we prevent navigation away until files have been provided
    @api
    validate(){
        if(this.required && (this.existingFiles.length == 0)){
            return {
                isValid: false,
                errorMessage: this.requiredValidationMessage
            }
        } else {
            return {
                isValid: true
            }
        }
    }

    get hasUploadedFiles(){
        return this.existingFiles.length > 0;
    }

    // connected call back function to get existing files or to pull in recently uploaded files for display
    connectedCallback(){
        this.handleGetExistingFiles();
    }

    // apex function that will use apex to pull back the relevant information about uploaded files
    handleGetExistingFiles() {
        let fileIdsToGet = [];
        if(this.existingFileIds.length > 0){
            this.existingFileIds.forEach(file => {
                fileIdsToGet.push(file);
            });
        }
        if(this.newFileIds.length > 0){
            this.newFileIds.forEach(file => {
                fileIdsToGet.push(file);
            });
        }
        getExistingFiles({contentDocumentIds: fileIdsToGet})
        .then((files) => {
            let parsedResults = JSON.parse(files);
            this.existingFiles = parsedResults.files;
            this.isLoading = false;
            this.uploadProcessing = false;
            this.checkDisabled();
        })
        .catch((error) => {
            this.showToast(toastTitle, reduceErrors(error).toString(), 'error');
            this.isLoading = false;
        })
    }

    // function that run on finish of upload within component
    handleUpload(event){
        let files = event.detail.files;
        this.handleUploadFinished(files);
    }

    // function that processes uploaded files and set defaults if provided
    handleUploadFinished(files) {
        this.uploadProcessing = true;
        let currentNewFileIds = [];
        files.forEach(file => {
            let documentId = file.documentId;
            this.newFileIds.push(documentId);
            currentNewFileIds.push(documentId);
        });
        this.handleSetFileDefaults(currentNewFileIds);
    }

    handleSetFileDefaults(currentNewFileIds) {
        updateFileData({
            contentDocumentIds: currentNewFileIds,
            configuration: this.overrideConfiguration,
            recordId: this.recordId
        })
        .then((results) => {
            this.handleGetExistingFiles();
        })
        .catch((error) => {
            this.showToast(toastTitle, reduceErrors(error).toString(), 'error');
        });
    }

    handleOnDeleteFile(event){
        this.handleGetExistingFiles();
    }

    // function to ensure we have disable uploades when single file upload has been completed
    checkDisabled(){
        this.disabled = !this.allowMultipleFiles && this.existingFiles.length >= 1;
    }

    // generic dispatch toast event
    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({title: toastTitle, message: toastMessage, variant: toastVariant}));
    }
}