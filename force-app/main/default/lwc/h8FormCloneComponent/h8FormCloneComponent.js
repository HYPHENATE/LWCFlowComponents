import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import flowForms from '@salesforce/apex/H8FlowFormCloneController.getFlowForms';
import cloneFlowForm from '@salesforce/apex/H8FlowFormCloneDeployment.cloneFlowForm';
import checkDeploymentStatus from '@salesforce/apex/H8FlowFormCloneStatus.checkDeployStatus';
import labels from './labels';

export default class H8FormCloneComponent extends LightningElement {
    @api initialSourceDeveloperName;

    isLoading = true;
    availabeFlowForms = [];
    selectedForm;
    formSelected = false;
    newFormName;
    isCloning = false;
    label = labels;
    @track asynJobId;
    @track deploymentStatus;

    get cardTitle(){
        if(this.isCloning){
            if(null != this.deploymentStatus){
                return labels.cloningWithStatusTitle + ' ' +  this.deploymentStatus;
            } else {
                return labels.cloningWaitTitle;
            }
            
        }else{
            return labels.cloneFormTitle;
        }
    }

    pollTimeoutId;

    connectedCallback(){
        this.fetchFlowForms();
    }

    disconnectedCallback(){
        this.clearPollTimeout();
    }

    clearPollTimeout(){
        if (this.pollTimeoutId) {
            clearTimeout(this.pollTimeoutId);
            this.pollTimeoutId = undefined;
        }
    }

    fetchFlowForms() {
        flowForms({})
        .then((results) => {
            const parsedResults = JSON.parse(results);
            this.availabeFlowForms = parsedResults.forms;
            this.isLoading = false;
            this.applyInitialSelection();
        })
        .catch((error) => {
            this.showToast(labels.errorGettingFormToastMessage, error?.body?.message || labels.unknownErrorToastMessage, 'error');
        });
    }

    applyInitialSelection(){
        if (this.initialSourceDeveloperName && this.availabeFlowForms.some(form => form.developerName === this.initialSourceDeveloperName)) {
            this.selectedForm = this.initialSourceDeveloperName;
            this.formSelected = true;
        }
    }

    handleRefresh(){
        this.isLoading = true;
        this.fetchFlowForms();
    }

    get formOptions() {
        return this.availabeFlowForms.map(item => ({
            label: item.masterLabel,
            value: item.developerName
        }));
    }

    handleFormSelection(event){
        this.selectedForm = event.detail.value;
        this.formSelected = true;
    }

    handleNewNameSet(event){
        this.newFormName = event.detail.value;
    }

    get isDisabled() {
        if (!this.newFormName || this.newFormName.length < 8 || this.newFormName.length > 40) {
            return true;
        }

        const newName = this.newFormName.trim();
        const normalizedDevName = newName.replace(/\s+/g, '_').toLowerCase();

        return this.availabeFlowForms.some(form =>
            form.masterLabel.toLowerCase() === newName.toLowerCase() ||
            form.developerName.toLowerCase() === normalizedDevName
        );
    }

    get nameIsDuplicate() {
        if (!this.newFormName) return false;

        const newName = this.newFormName.trim();
        const normalizedDevName = newName.replace(/\s+/g, '_').toLowerCase();

        return this.availabeFlowForms.some(form =>
            form.masterLabel.toLowerCase() === newName.toLowerCase() ||
            form.developerName.toLowerCase() === normalizedDevName
        );
    }

    handleCloneForm(){
        this.isCloning = true;
        const masterLabel = this.newFormName.trim();
        const developerName = masterLabel.replace(/\s+/g, '_');
        cloneFlowForm({
            sourceDeveloperName: this.selectedForm,
            newMasterLabel: masterLabel,
            newDeveloperName: developerName
        })
        .then((results) => {
            this.asynJobId = results;
            this.handleQueryDeploymentProcess();
            this.showToast('Success', labels.successCloningToastTitle, 'success');
        })
        .catch(error => {
            this.showToast(labels.errorEncounteredToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            this.handleResetPage();
        });
    }

    handleQueryDeploymentProcess(){
        this.clearPollTimeout();
        const check = () => {
            if (this.isCloning) {
                this.handleCheckDeploymentStatus();
                this.pollTimeoutId = setTimeout(check, 5000);
            }
        };
        check();
    }

    handleCheckDeploymentStatus() {
       checkDeploymentStatus({
           deploymentId: this.asynJobId,
           includeDetails: true
        })
        .then((results) => {
            this.deploymentStatus = results;
            if(results == 'Succeeded'){
                this.showToast(results, labels.successCloningToastMessage, 'success');
                this.handleResetPage();
            } else if(results == 'Failed' || results == 'Canceling' || results == 'Canceled'){
                this.showToast(results, labels.deploymentErrorToastMessage, 'error');
                this.handleResetPage();
            } 
        })
        .catch((error) => {
            this.showToast(labels.errorEncounteredToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            this.handleResetPage();
        });
    }

    // generic dispatch toast event
    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({title: toastTitle, message: toastMessage, variant: toastVariant}));
    }

    handleResetPage(){
        this.clearPollTimeout();
        this.isLoading = true;
        this.fetchFlowForms();
        this.newFormName = undefined;
        this.selectedForm = undefined;
        this.formSelected = false;
        this.isCloning = false;
    }
}