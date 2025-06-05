/**
 * @description       : js for form validation section component
 * @author            : daniel@hyphen8.com
 * @last modified on  : 05-06-2025
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

import getSectionValidation from '@salesforce/apex/H8FlowFormSectionValidation.validatePage';

export default class H8FormFlowValidationSectionComponent extends LightningElement {
    @api recordId;
    @api formName;
    @api parentObjectAPIName;
    @api sectionName;
    @api helpText = 'You must complete the following fields';
    @api affectTextLabel = 'Question(s) affected:';
    hasValidationErrors;
    pages;
    isLoading = true;
    success = true;
    message;

    connectedCallback(){
        const item = sessionStorage.getItem('formProcessing');
        if (item) {
            const records = JSON.parse(item);
            const exists = records.some(record => record.recordId === this.recordId);
            if (exists) {
                this.handleGetSectionValidation();
            } else {
                this.isLoading = false;
                this.success = true;
            }
        } else {
            this.isLoading = false;
            this.success = true;
        }
    }

    handleGetSectionValidation() {
        getSectionValidation({
            recordId: this.recordId,
            formName: this.formName,
            parentObjectAPIName:this.parentObjectAPIName,
            sectionName:this.sectionName
        })
        .then((results) => {
            let parsedResults = JSON.parse(results);
            this.success = parsedResults.success;
            this.message = parsedResults.message;
            this.isLoading = false;
            if(parsedResults.success){
                this.hasValidationErrors = parsedResults.hasErrors;
                this.pages = parsedResults.pages;
            }
            
        
        })
        .catch((error) => {
            console.error('error handleGetSectionValidation > ' + JSON.stringify(error));
            this.isLoading = false; //remove spinner if error
            this.success = true; //remove error on page. Possibly should display something?
        });
    }
}