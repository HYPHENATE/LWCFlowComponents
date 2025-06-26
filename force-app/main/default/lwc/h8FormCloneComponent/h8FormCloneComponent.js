import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import flowForms from '@salesforce/apex/H8FlowFormCloneController.getFlowForms';
import cloneFlowForm from '@salesforce/apex/H8FlowFormCloneDeployment.cloneFlowForm';
import checkDeploymentStatus from '@salesforce/apex/H8FlowFormCloneStatus.checkDeployStatus';
import labels from './labels';

export default class H8FormCloneComponent extends LightningElement {
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

    connectedCallback(){
        this.fetchFlowForms();
    }

    fetchFlowForms() {
        flowForms({})
        .then((results) => {
            let parsedResults = JSON.parse(results);
            this.availabeFlowForms = parsedResults.forms;
            this.isLoading = false;
        })
        .catch((error) => {
            this.showToast(labels.errorGettingFormToastMessage, error?.body?.message || labels.unknownErrorToastMessage, 'error');
        });
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
        const check = () => {
            if (this.isCloning) {
                this.handleCheckDeploymentStatus();
                setTimeout(check, 5000);
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
        this.isLoading = true;
        this.fetchFlowForms();
        this.newFormName = undefined;
        this.selectedForm = undefined;
        this.formSelected = false;
        this.isCloning = false;
    }
}