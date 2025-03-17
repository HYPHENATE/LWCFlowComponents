/**
 * @description       : Sample Description
 * @author            : daniel@hyphen8.com
 * @last modified on  : 03/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

import validatePage from '@salesforce/apex/H8FlowFormPageValidation.validatePage';

export default class H8FlowFormPageValidationComponent extends LightningElement {
    @api recordId;
    @api formName;
    @api parentObjectAPIName;
    @api pageName;
    @api helpText;
    @api affectTextLabel;
    isLoading = true;
    hasValidationErrors = false;
    validationErrors;
    success;
    message;

    connectedCallback(){
        const item = sessionStorage.getItem('formProcessing');
        if (item) {
            this.handleValidatePage();
        }
    }

    handleValidatePage() {
        validatePage({
            recordId: this.recordId,
            formName: this.formName,
            parentObjectAPIName:this.parentObjectAPIName,
            pageName:this.pageName
        })
        .then((results) => {
            let parsedResults = JSON.parse(results);
            this.success = parsedResults.success;
            this.message = parsedResults.message;
            this.isLoading = false;
            if(parsedResults.success){
                this.hasValidationErrors = parsedResults.hasValidationErrors;
                this.validationErrors = parsedResults.errors;                
            }
        })
        .catch((error) => {
            console.error('error handleValidatePage > ' + JSON.stringify(error));
        });
    }
}