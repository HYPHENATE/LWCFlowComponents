/**
 * @description       : Sample Description
 * @author            : daniel@hyphen8.com
 * @last modified on  : 03/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

import getSectionValidation from '@salesforce/apex/H8FlowFormSectionValidation.validatePage';

export default class H8FormFlowValidationSectionComponent extends LightningElement {
    @api recordId;
    @api formName;
    @api parentObjectAPIName;
    @api sectionName;
    @api helpText;
    @api affectTextLabel;
    hasValidationErrors;
    pages;

    connectedCallback(){
        const item = sessionStorage.getItem('formProcessing');
        if (item) {
            this.handleGetSectionValidation();
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
            if(parsedResults.success){
                this.hasValidationErrors = parsedResults.hasErrors;
                this.pages = parsedResults.pages;
            }
            
        
        })
        .catch((error) => {
            console.error('error handleGetSectionValidation > ' + JSON.stringify(error));
        });
    }
}