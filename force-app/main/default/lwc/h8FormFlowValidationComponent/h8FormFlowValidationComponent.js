/**
 * @description       : Sample Description
 * @author            : daniel@hyphen8.com
 * @last modified on  : 05-06-2025
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

import validateFormData from '@salesforce/apex/H8FlowFormValidation.validateCompleteForm';
import { FlowNavigationNextEvent } from "lightning/flowSupport";

export default class H8FormFlowValidationComponent extends LightningElement {
    @api recordId;
    @api formName;
    @api parentObjectAPIName;
    @api cardTitle = 'Review.. before you submit';
    @api nextButtonLabel = 'Review Sumbission';
    @api completeFieldsText = 'You must complete the following fields';
    @api invalidCardDescription = 'We have picked up that some of your answers are not valid. Before you can submit the form you will have to complete the required fields';
    @api validCardDescription = 'If you have done all these feel free to submit... good luck';
    @api affectTextLabel = 'Question(s) affected:';
    isLoading = true;
    sections;
    hasErrors;
    isValid;
    success;
    message;

    connectedCallback(){
        this.handleValidateFormData();
    }

    handleValidateFormData() {
        validateFormData({
           recordId: this.recordId,
           primaryObjectAPIName: this.parentObjectAPIName,
           formAPIName: this.formName
        })
        .then((results) => {
            let parsedResults = JSON.parse(results);
            this.sections = parsedResults.sections;
            this.hasErrors = parsedResults.hasErrors;
            this.isValid = parsedResults.isValid;
            this.success = parsedResults.success;
            this.message = parsedResults.message;
            this.isLoading = false;
            if(this.hasErrors){
                const newRecord = {
                    formName: this.formName,
                    recordId: this.recordId,
                    parentObjectAPIName: this.parentObjectAPIName
                };
                let existingRecords = JSON.parse(sessionStorage.getItem('formProcessing')) || [];
                const exists = existingRecords.some(item => item.recordId === newRecord.recordId);
                if (!exists) {
                    existingRecords.push(newRecord);
                    sessionStorage.setItem('formProcessing', JSON.stringify(existingRecords));
                }
            }
        })
        .catch((error) => {
            console.error('error handleValidateFormData > ' + JSON.stringify(error));
        });
    }

    @api availableActions = [];

    handleNext() {
        if (this.availableActions.find((action) => action === "NEXT")) {
          const navigateNextEvent = new FlowNavigationNextEvent();
          this.dispatchEvent(navigateNextEvent);
        }
    }
}