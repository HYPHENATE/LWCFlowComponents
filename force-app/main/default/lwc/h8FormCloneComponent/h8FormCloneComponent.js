import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import flowForms from '@salesforce/apex/H8FlowFormCloneController.getFlowForms';
import cloneFlowForm from '@salesforce/apex/H8FlowFormCloneDeployment.cloneFlowForm';
import labels from './labels';

export default class H8FormCloneComponent extends LightningElement {
    isLoading = true;
    availabeFlowForms = [];
    selectedForm;
    formSelected = false;
    newFormName;
    isCloning = false;
    label = labels;

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
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Getting Forms',
                message: error?.body?.message || 'An unknown error occurred',
                variant: 'error'
            }));
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
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Form clone process started successfully, this can take 5 minutes to complete dependent on the size of your form',
                variant: 'success'
            }));
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Cloning Form',
                message: error?.body?.message || 'An unknown error occurred',
                variant: 'error'
            }));
        })
        .finally(() => {
            this.isLoading = true;
            this.fetchFlowForms();
            this.newFormName = undefined;
            this.selectedForm = undefined;
            this.formSelected = false;
            this.isCloning = false;
        });
    }
}