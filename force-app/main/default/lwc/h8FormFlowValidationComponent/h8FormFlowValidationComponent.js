/**
 * @description       : Sample Description
 * @author            : daniel@hyphen8.com
 * @last modified on  : 02/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

import validateFormData from '@salesforce/apex/H8FlowFormValidation.validateCompleteForm';
import { FlowNavigationNextEvent } from "lightning/flowSupport";

export default class H8FormFlowValidationComponent extends LightningElement {
    @api recordId;
    @api formName;
    @api parentObjectAPIName;
    @api displayTitleIcon;
    @api displayText;
    isLoading = true;
    sections;
    hasErrors;
    isValid;

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
            console.log(JSON.stringify(parsedResults));
            this.sections = parsedResults.sections;
            this.hasErrors = parsedResults.hasErrors;
            this.isValid = parsedResults.isValid;
            this.isLoading = false;
            if(this.isValid){
                let item = sessionStorage.getItem('formProcessing');
                if(item){
                    sessionStorage.removeItem('formProcessing');
                }
            } else {
                sessionStorage.setItem('formProcessing', JSON.stringify({ formName: this.formName, recordId: this.recordId, parentObjectAPIName: this.parentObjectAPIName}));
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