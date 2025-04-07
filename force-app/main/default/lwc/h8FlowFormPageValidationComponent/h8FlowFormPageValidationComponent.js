/**
 * @description       : Sample Description
 * @author            : daniel@hyphen8.com
 * @last modified on  : 07/04/2025
 * @last modified by  : dan@hyphen8.com
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
    success = true;
    message;

    connectedCallback(){
        const item = sessionStorage.getItem('formProcessing');
        if (item) {
            this.handleValidatePage();
        } else {
            this.isLoading = false;
            this.success = true;
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
            this.isLoading = false; //remove spinner if error
            this.success = true; //remove error on page. Possibly should display something?
        });
    }
}