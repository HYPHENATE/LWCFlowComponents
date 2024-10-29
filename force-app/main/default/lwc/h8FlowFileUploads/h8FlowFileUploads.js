/**
 * @description       : js to support with file uploads
 * @author            : daniel@hyphen8.com
 * @last modified on  : 08/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import getKey from '@salesforce/apex/H8FlowFileUploadController.getKey';
import encrypt from '@salesforce/apex/H8FlowFileUploadController.encrypt';
import createContentDocLink from '@salesforce/apex/H8FlowFileUploadController.createContentDocLink';
import deleteContentDoc from '@salesforce/apex/H8FlowFileUploadController.deleteContentDoc';
import getExistingFiles from '@salesforce/apex/H8FlowFileUploadController.getExistingFiles';
import updateFileName from '@salesforce/apex/H8FlowFileUploadController.updateFileName';
import { reduceErrors } from 'c/h8UtilReduceErrors';

export default class H8FlowFileUploads extends LightningElement {

    @api recordId;
    @api acceptedFormats
    @api allowMultipleFiles;
    @api disableFileDelete;
    @api helpText;
    @api fileUploadLabel;
    @api icon;
    @api overriddenFileName;
    @api relatedRecordId;
    @api disableDelete;
    @api required;
    @api requiredValidationMessage;
    @api setVisibilityToAllUsers;
    @api existingFiles;
    @api uploadedFiles;
    @api uploadedlabel;
    @api contentDocumentIds;
    @api contentVersionIds;
    @api uploadedFileNames;

    @track docIds =[];
    @track fileNames = [];
    @track objFiles = [];
    @track versIds = [];

    isLoading = true;
    key;
    value;
    disabled = false;
    numberOfFilesToUpload = 0;
    loading = false;

    // flow validation function to confirm if when marked as required we prevent navigation away until files have been provided
    @api
    validate(){
        if(this.required && (null == this.uploadedFiles || null == this.existingFiles)){
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

    // connected call back function pull in the existing file details if they have been provided
    connectedCallback(){
        let cachedSelection = sessionStorage.getItem(this.sessionKey);
        if(cachedSelection){
            this.processFiles(JSON.parse(cachedSelection));
        } else if(this.recordId && this.renderExistingFiles) {
            getExistingFiles({recordId: this.recordId, contentDocumentIds: this.existingFiles})
                .then((files) => {
                    if(files != undefined && files.length > 0){
                        this.processFiles(files);
                    } else {
                        this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);
                    }
                })
                .catch((error) => {
                    this.showErrors(this.reduceErrors(error).toString());
                })
        } else {
            this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);
        }
        this.isLoading = false;
    }

    // wire function to obtain an encryption key
    @wire(getKey)
    wiredKey({error,data}){
        if(data){
            this.key = data;
        }
        else if (error){
            this.showToast('Error', reduceErrors(error).toString(), 'error');
        }
    }

    // wire function to encrpyt out recordId for enhanced security and later user
    @wire(encrypt,{recordId: '$recordId', encodedKey: '$key'})
    wiredValue({error,data}){
        if(data){
            this.value = data;
        }
        else if (error){
            this.showToast('Error', reduceErrors(error).toString(), 'error');
        }
    }

    // function to process files for output
    processFiles(files){
        files.forEach(file => {
            let filetype = getIconSpecs(file.name.split('.').pop());
            let objFile = {
                name: file.name,
                filetype: filetype,
                documentId: file.documentId,
                contentVersionId: file.contentVersionId
            };
            this.objFiles.push(objFile);
            this.docIds.push(file.documentId);
            this.versIds.push(file.contentVersionId);
            this.fileNames.push(file.name);
        });

        this.checkDisabled();

        this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);

        function getIconSpecs(docType){
            switch(docType){
                case 'csv':
                    return 'doctype:csv';
                case 'pdf':
                    return 'doctype:pdf';
                case 'ppt':
                    return 'doctype:ppt';
                case 'pptx':
                    return 'doctype:ppt';
                case 'xls':
                    return 'doctype:excel'
                case 'xlsx':
                    return 'doctype:excel';
                case 'doc':
                    return 'doctype:word'
                case 'docx':
                    return 'doctype:word';
                case 'txt':
                    return 'doctype:txt';
                case 'png':
                    return 'doctype:image';
                case 'jpeg':
                    return 'doctype:image';
                case 'jpg':
                    return 'doctype:image';
                case 'gif':
                    return 'doctype:image';
                default:
                    return 'doctype:unknown';
            }
        }
    }

    // function that run on finish of upload within component
    handleUpload(event){
        let files = event.detail.files;
        this.handleUploadFinished(files);
    }

    // function that processes uploaded files
    handleUploadFinished(files) {
        let objFiles = [];
        let versIds = [];
        files.forEach(file => {
            let name;
            if(this.overriddenFileName){
                name = this.overriddenFileName.substring(0,255) +'.'+ file.name.split('.').pop();
            } else {
                name = file.name;
            }
            
            let objFile = {
                name: name,
                documentId: file.documentId,
                contentVersionId: file.contentVersionId
            }
            objFiles.push(objFile);

            versIds.push(file.contentVersionId);
        })

        if(this.overriddenFileName){
            updateFileName({versIds: versIds, fileName: this.overriddenFileName.substring(0,255)})
                .catch(error => {
                    this.showToast('Error', reduceErrors(error).toString(), 'error');
                });
        }

        if(this.recordId){
            createContentDocLink({versIds: versIds, encodedKey: this.key, visibleToAllUsers: this.visibleToAllUsers})
                .catch(error => {
                    this.showToast('Error', reduceErrors(error).toString(), 'error');
                });
        }

        this.processFiles(objFiles);
    }

    // function to delete a document
    deleteDocument(event){
        this.loading = true;
        event.target.blur();
        let contentVersionId = event.target.dataset.contentversionid;    

        if(this.disableDelete){
            this.removeFileFromUi(contentVersionId);
        } else {
            deleteContentDoc({versId: contentVersionId})
            .then(() => {
                this.removeFileFromUi(contentVersionId);
            })
            .catch((error) => {
                this.showToast('Error', reduceErrors(error).toString(), 'error');
                this.loading = false;
            })
        } 
    }

    // this function will remove the file from the UI
    removeFileFromUi(contentVersionId){
        let objFiles = this.objFiles;
        let removeIndex;
        for(let i=0; i<objFiles.length; i++){
            if(contentVersionId === objFiles[i].contentVersionId){
                removeIndex = i;
            }
        }
        this.objFiles.splice(removeIndex,1);
        this.docIds.splice(removeIndex,1);
        this.versIds.splice(removeIndex,1);
        this.fileNames.splice(removeIndex,1);
        this.checkDisabled();
        this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);
        this.loading = false;
    }

    // function to open the file
    openFile(event) {
        let docId = event.target.dataset.docid;
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: docId
            }
        });
    }


    // function check if upload is disabled
    checkDisabled(){
        if(!this.allowMultiple && this.objFiles.length >= 1){
            this.disabled = true;
        } else {
            this.disabled = false;
        }
    }

    // function to ensure flow is aware of all files within the current context and to set session storage
    communicateEvent(docIds, versIds, fileNames, objFiles){
        this.dispatchEvent(new FlowAttributeChangeEvent('contentDocumentIds', [...docIds]));
        this.dispatchEvent(new FlowAttributeChangeEvent('contentVersionIds', [...versIds]));
        this.dispatchEvent(new FlowAttributeChangeEvent('uploadedFileNames', [...fileNames]));
        sessionStorage.setItem(this.sessionKey, JSON.stringify(objFiles));
    }

    // generic dispatch toast event
    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({title: toastTitle, message: toastMessage, variant: toastVariant}));
    }
}