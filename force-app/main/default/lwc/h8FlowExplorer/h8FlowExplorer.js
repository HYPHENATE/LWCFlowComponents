import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUsedFlows from '@salesforce/apex/H8FlowFormManagerController.getUsedFlows';
import getFlowRecordUrl from '@salesforce/apex/H8FlowFormManagerController.getFlowRecordUrl';
import labels from './labels';

export default class H8FlowExplorer extends LightningElement {
    label = labels;

    isLoadingFlows = true;
    availableFlows = [];
    selectedFlowApiName;
    flowSearchTerm = '';
    isFlowDropdownOpen = false;
    highlightedFlowOptionIndex = -1;

    connectedCallback() {
        this.fetchUsedFlows();
    }

    fetchUsedFlows() {
        this.isLoadingFlows = true;
        getUsedFlows({})
            .then((results) => {
                const parsedResults = JSON.parse(results);
                this.availableFlows = parsedResults.flows;
            })
            .catch((error) => {
                this.showToast(labels.errorLoadingFlowsToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            })
            .finally(() => {
                this.isLoadingFlows = false;
            });
    }

    get filteredFlowOptions() {
        const term = (this.flowSearchTerm || '').trim().toLowerCase();
        return this.availableFlows
            .filter((flow) => !term || flow.label.toLowerCase().includes(term) || flow.apiName.toLowerCase().includes(term))
            .map((flow) => ({ label: flow.label, value: flow.apiName, id: `flow-option-${flow.apiName}` }));
    }

    get hasFilteredFlowOptions() {
        return this.filteredFlowOptions.length > 0;
    }

    get flowComboboxClass() {
        return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click${this.isFlowDropdownOpen ? ' slds-is-open' : ''}`;
    }

    get isFlowDropdownExpanded() {
        return this.isFlowDropdownOpen ? 'true' : 'false';
    }

    get highlightedFlowOptionId() {
        const option = this.filteredFlowOptions[this.highlightedFlowOptionIndex];
        return option ? option.id : undefined;
    }

    get flowOptionsForDisplay() {
        return this.filteredFlowOptions.map((option, index) => ({
            ...option,
            isHighlighted: index === this.highlightedFlowOptionIndex,
            optionClass: `slds-media slds-listbox__option slds-listbox__option_plain slds-media_small${index === this.highlightedFlowOptionIndex ? ' slds-has-focus' : ''}`
        }));
    }

    get hasSelectedFlow() {
        return !!this.selectedFlowApiName;
    }

    handleFlowSearchInput(event) {
        this.flowSearchTerm = event.target.value;
        this.isFlowDropdownOpen = true;
        this.highlightedFlowOptionIndex = this.filteredFlowOptions.length > 0 ? 0 : -1;
    }

    handleFlowSearchFocus() {
        this.isFlowDropdownOpen = true;
    }

    handleFlowSearchBlur() {
        window.setTimeout(() => {
            this.isFlowDropdownOpen = false;
            this.highlightedFlowOptionIndex = -1;
        }, 200);
    }

    handleFlowSearchKeydown(event) {
        const options = this.filteredFlowOptions;
        switch (event.key) {
            case 'ArrowDown':
                event.preventDefault();
                this.isFlowDropdownOpen = true;
                if (options.length > 0) {
                    this.highlightedFlowOptionIndex = (this.highlightedFlowOptionIndex + 1) % options.length;
                }
                break;
            case 'ArrowUp':
                event.preventDefault();
                this.isFlowDropdownOpen = true;
                if (options.length > 0) {
                    this.highlightedFlowOptionIndex = this.highlightedFlowOptionIndex <= 0
                        ? options.length - 1
                        : this.highlightedFlowOptionIndex - 1;
                }
                break;
            case 'Enter':
                if (this.isFlowDropdownOpen && options[this.highlightedFlowOptionIndex]) {
                    event.preventDefault();
                    this.selectFlow(options[this.highlightedFlowOptionIndex].value);
                }
                break;
            case 'Escape':
                this.isFlowDropdownOpen = false;
                this.highlightedFlowOptionIndex = -1;
                break;
            default:
                break;
        }
    }

    handleFlowOptionSelect(event) {
        this.selectFlow(event.currentTarget.dataset.value);
    }

    selectFlow(apiName) {
        this.selectedFlowApiName = apiName;
        const selectedFlow = this.availableFlows.find((flow) => flow.apiName === apiName);
        this.flowSearchTerm = selectedFlow?.label || '';
        this.isFlowDropdownOpen = false;
        this.highlightedFlowOptionIndex = -1;
    }

    handleOpenFlow() {
        if (!this.selectedFlowApiName) {
            return;
        }
        // open the tab synchronously, inside the click handler, so browsers don't block it as a popup -
        // the flow's URL isn't known yet (it comes back from the async Apex call below), so we open a
        // blank tab now and redirect it once the URL arrives, rather than calling window.open() in .then()
        // where the user-gesture context needed to avoid the popup blocker would already be gone
        const newTab = window.open('', '_blank');
        getFlowRecordUrl({ flowApiName: this.selectedFlowApiName })
            .then((url) => {
                if (newTab) {
                    newTab.location.href = url;
                } else {
                    // window.open() above returned null (e.g. blocked anyway) - fall back to a direct
                    // call now, best-effort, since there's no pre-opened tab to redirect
                    window.open(url, '_blank');
                }
            })
            .catch((error) => {
                if (newTab) {
                    // the Apex call failed - close the blank tab rather than leaving an empty orphan open
                    newTab.close();
                }
                this.showToast(labels.errorOpeningFlowToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            });
    }

    handleOpenFormFromUsage(event) {
        // bubble this up so the parent (h8FormManager) can switch to the Form Explorer tab and select the form/section
        this.dispatchEvent(new CustomEvent('openform', { detail: event.detail }));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
