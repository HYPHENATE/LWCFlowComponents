/**
 * @description       : js to support displaying a form with side navigation
 * @author            : daniel@hyphen8.com
 * @last modified on  : 02/10/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getForm from '@salesforce/apex/H8FlowFormController.getForm';
import validateForm from '@salesforce/apex/H8FlowFormValidation.validateCompleteForm';

export default class H8FlowFormRenderComponent extends LightningElement {
    @api formName;
    @api recordId;
    @api defaultPage = 1;
    isLoading = true;
    @track sections;
    activeSectionId;
    flowAPIName;
    loadFlow = false;
    intervalId;

    // connected call back to support with getting the form structure
    connectedCallback(){
        this.handleGetForm();
        this.intervalId = setInterval(() => {
            this.checkSessionStorage();
        }, 5000);
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }

    checkSessionStorage(){
        const item = sessionStorage.getItem('formProcessing');
        if (item) {
            clearInterval(this.intervalId);
            this.handleGetValidations(JSON.parse(item));
        }
    }

    handleGetValidations(storageItem){
        const { formName, recordId, parentObjectAPIName } = storageItem;
        if(formName == this.formName && recordId == this.recordId){
            this.handleValidateForm(formName, recordId, parentObjectAPIName);
        }
    }

    handleValidateForm(formName, recordId, parentObjectAPIName){
        validateForm({
            recordId : recordId,
            primaryObjectAPIName : parentObjectAPIName, 
            formAPIName : formName
        })
        .then((results) => {
            let parsedResults = JSON.parse(results);
            if(parsedResults.success){
                let sections = parsedResults.sections;
                
                this.sections.forEach(label => {
                    label.hasValidationError = false;
                });
                
                sections.forEach(section => {
                    const matchingLabel = this.sections.find(label => label.label === section.sectionName);
                    if (matchingLabel) {
                        matchingLabel.hasValidationError = true;
                    }
                });
            }
        })
        .catch((error) => {
            console.error('error handleValidateForm > ' + JSON.stringify(error));
        });
    }

    // apex function to pull in the form structure
    handleGetForm() {
        getForm({
            formAPIName: this.formName
        })
        .then((results) => {
            let parsedResults = JSON.parse(results);
            if(parsedResults.success){
                this.sections = parsedResults.sections;
                if(this.defaultPage === 1){
                    this.activeSectionId = this.sections[0].id;
                    this.flowAPIName = this.sections[0].flow;
                } else {
                    let currentPage = this.defaultPage - 1;
                    this.activeSectionId = this.sections[currentPage].id;
                    this.flowAPIName = this.sections[currentPage].flow;
                }
                this.isLoading = false;
            } else {
                this.showToast('Error Encountered', parsedResults.message, 'error');
            }
        })
        .catch((error) => {
            this.showToast('Error Encountered', JSON.stringify(error), 'error');
        });
    }

    // getter to set the input variables
    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId != null ? this.recordId : ''
            }
        ];
    }

    // dispatched event that will set the current selected section and reload the flow for the selected section
    handleChangeSection(event){
        this.loadFlow = true;
        this.activeSectionId = event.detail.sectionId;
        this.flowAPIName = event.detail.flowName;
        this.checkSessionStorage();
        setTimeout(() => {
            this.loadFlow = false;
        }, 500);
    }

    // dispatched even from the flow to confirm that the flow is finished and to support with determining where to go next
    handleStatusChange(event){
        if(event.detail.status === "FINISHED"){
            const availableSections = this.sections;
            const currentIndex = availableSections.findIndex(section => section.id === this.activeSectionId);
            if (currentIndex !== -1 && currentIndex < availableSections.length - 1) {
                let currentSection = availableSections[currentIndex + 1];
                this.loadFlow = true;
                this.activeSectionId = currentSection.id;
                this.flowAPIName = currentSection.flow;
                this.checkSessionStorage();
                setTimeout(() => {
                    this.loadFlow = false;
                }, 500);
            } else {
                return null;
            }
        }
    }

    // generic dispatch toast event
    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({title: toastTitle, message: toastMessage, variant: toastVariant}));
    }
}