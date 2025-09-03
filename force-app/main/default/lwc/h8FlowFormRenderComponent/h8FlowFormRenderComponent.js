/**
 * @description       : js to support displaying a form with side navigation
 * @author            : daniel@hyphen8.com
 * @last modified on  : 29-08-2025
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api, track } from 'lwc';
import LANG from '@salesforce/i18n/lang';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getForm from '@salesforce/apex/H8FlowFormController.getForm';
import validateForm from '@salesforce/apex/H8FlowFormValidation.validateCompleteForm';

export default class H8FlowFormRenderComponent extends LightningElement {
    @api formName;
    @api recordId;
    @api defaultPage = 1;
    @api scrollToTopOffset = 150;
    @api navWidth = '12rem';
    @api getLanguage = false;
    varLanguage;
    isLoading = true;
    @track sections;
    activeSectionId;
    flowAPIName;
    loadFlow = false;
    intervalId;
    @track scrollToFlow = false;

    // connected call back to support with getting the form structure
    connectedCallback(){
        this.handleGetForm();
        if(this.getLanguage){
            this.fetchLanguage();
        }
        this.intervalId = setInterval(() => {
            this.checkSessionStorage();
        }, 500);
    }

    fetchLanguage(){
        const urlLang = this._getUrlLanguage();
        const raw = (urlLang || LANG || 'en').toLowerCase();
        const normalized = this.normalizeToTwoLetters ? raw.substring(0, 2) : raw;
        this.varLanguage = normalized;
        this.isLoading = false;
    }

    _getUrlLanguage() {
        try {
            const params = new URL(window.location.href).searchParams;
            return params.get('language');
        } catch (e) {
            return null;
        }
    }

    renderedCallback() {
        //this.template.host.style.setProperty('--custom-nav-width', this.navWidth);
        const hostWrapper = this.template.querySelector('[data-id="hostWrapper"]');
        if (hostWrapper) {
            hostWrapper.style.setProperty('--custom-nav-width', this.navWidth);
        }
        if (this.scrollToFlow) {
            setTimeout(() => {
                const flowWrapper = this.template.querySelector('[data-id="flowWrapper"]');
                if (flowWrapper) {
                    const y = flowWrapper.getBoundingClientRect().top + window.pageYOffset - this.scrollToTopOffset;
                    window.scrollTo({ top: y, behavior: 'smooth' });
                }
                this.scrollToFlow = false;
            }, 50);
        }
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }

    checkSessionStorage() {
        const item = sessionStorage.getItem('formProcessing');
        if (item) {
            const records = JSON.parse(item);
            const matchedRecord = records.find(record => record.recordId === this.recordId);
            if (matchedRecord) {
                clearInterval(this.intervalId);
                this.handleGetValidations(matchedRecord);
            }
        }
    }

    handleGetValidations(storageItem){
        const { formName, recordId, parentObjectAPIName } = storageItem;
        if(recordId == this.recordId){
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
        if(this.getLanguage){
            return [
                {
                    name: 'recordId',
                    type: 'String',
                    value: this.recordId != null ? this.recordId : ''
                },
                {
                    name: 'varLanguage',
                    type: 'String',
                    value: this.varLanguage != null ? this.varLanguage : 'en'
                }
            ];
        } else {
            return [
                {
                    name: 'recordId',
                    type: 'String',
                    value: this.recordId != null ? this.recordId : ''
                }
            ];
        }
    }

    // dispatched event that will set the current selected section and reload the flow for the selected section
    handleChangeSection(event){
        this.loadFlow = true;
        this.activeSectionId = event.detail.sectionId;
        this.flowAPIName = event.detail.flowName;
        this.checkSessionStorage();
        
        setTimeout(() => {
            this.loadFlow = false;
            this.scrollToFlow = true; 
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
                    this.scrollToFlow = true;
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