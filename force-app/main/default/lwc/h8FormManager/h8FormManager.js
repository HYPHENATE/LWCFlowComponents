import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import H8FormCloneModal from 'c/h8FormCloneModal';
import H8FlowUsageModal from 'c/h8FlowUsageModal';
import flowForms from '@salesforce/apex/H8FlowFormCloneController.getFlowForms';
import getFormSections from '@salesforce/apex/H8FlowFormManagerController.getFormSections';
import getSectionValidations from '@salesforce/apex/H8FlowFormManagerController.getSectionValidations';
import getFlowRecordUrl from '@salesforce/apex/H8FlowFormManagerController.getFlowRecordUrl';
import getFormCustomFields from '@salesforce/apex/H8FlowFormManagerController.getFormCustomFields';
import getSectionCustomFieldsForForm from '@salesforce/apex/H8FlowFormManagerController.getSectionCustomFieldsForForm';
import getIsProductionOrg from '@salesforce/apex/H8FlowFormManagerController.getIsProductionOrg';
import labels from './labels';

export default class H8FormManager extends LightningElement {
    label = labels;

    isProductionOrg = false;

    isLoadingForms = true;
    availableFlowForms = [];
    selectedForm;
    formTypeFilter = 'All';
    formSearchTerm = '';
    isFormDropdownOpen = false;
    highlightedFormOptionIndex = -1;
    formInfoActiveSections = ['sections'];
    activeTabValue = 'formExplorer';
    pendingSectionDeveloperName;

    customFields = [];

    isLoadingSections = false;
    isLoadingSectionCustomFields = false;
    hasSectionsError = false;
    sections = [];
    sectionCustomFieldsByDeveloperName = {};
    sectionsSortedBy = 'order';
    sectionsSortedDirection = 'asc';
    selectedSectionDeveloperName;

    isLoadingValidations = false;
    hasValidationsError = false;
    validations = [];
    flowValidationsSortedBy = 'masterLabel';
    flowValidationsSortedDirection = 'asc';
    fieldValidationsSortedBy = 'fieldAPIName';
    fieldValidationsSortedDirection = 'asc';

    formRequestToken = 0;
    sectionRequestToken = 0;

    isTestMode = false;
    testRecordId;
    testSectionsToNotDisplay;
    testingSectionLabel;
    isTestSettingsOpen = false;
    testLiveValidation = false;
    testShowSectionValidationPanel = false;
    testShowNoValidationErrorsFound = false;
    testShowSectionHeader = false;

    get sectionColumns() {
        return [
            { label: labels.sectionOrderColumnLabel, fieldName: 'order', type: 'number', initialWidth: 90, sortable: true },
            {
                label: 'Icon Name',
                fieldName: 'iconName',
                type: 'button-icon',
                initialWidth: 100,
                typeAttributes: {
                    iconName: { fieldName: 'iconName' },
                    variant: 'bare',
                    disabled: true,
                    alternativeText: labels.sectionIconAltText
                }
            },
            {
                label: labels.sectionNameColumnLabel,
                fieldName: 'metadataUrl',
                type: 'button',
                sortable: true,
                typeAttributes: {
                    label: { fieldName: 'displayName' },
                    name: 'open_metadata',
                    variant: 'base',
                    iconName: 'utility:new_window',
                    iconPosition: 'right'
                }
            },
            {
                label: labels.sectionFlowApiNameColumnLabel,
                fieldName: 'flowAPIName',
                type: 'button',
                sortable: true,
                typeAttributes: {
                    label: { fieldName: 'flowAPIName' },
                    name: 'open_flow',
                    variant: 'base',
                    iconName: 'utility:new_window',
                    iconPosition: 'right'
                }
            },
            ...this.sectionCustomFieldColumns,
            {
                type: 'action',
                typeAttributes: {
                    rowActions: [
                        { label: labels.testSectionActionAltText, name: 'test_section' },
                        { label: labels.whereUsedActionAltText, name: 'where_used' }
                    ]
                }
            }
        ];
    }

    get sectionCustomFieldColumns() {
        const sectionDeveloperNames = Object.keys(this.sectionCustomFieldsByDeveloperName);
        if (sectionDeveloperNames.length === 0) {
            return [];
        }
        const firstSectionFields = this.sectionCustomFieldsByDeveloperName[sectionDeveloperNames[0]] || [];
        return firstSectionFields.map((field) => ({ label: field.label, fieldName: field.apiName, type: 'text', sortable: true }));
    }

    get sectionsForDatatable() {
        const mergedSections = this.sections.map((section) => {
            const customFields = this.sectionCustomFieldsByDeveloperName[section.developerName] || [];
            const customFieldValues = {};
            customFields.forEach((field) => {
                customFieldValues[field.apiName] = field.value;
            });
            return { ...section, ...customFieldValues };
        });
        // the "Section" column's cell type needs a URL (metadataUrl) to link out, but sorting by
        // the URL itself would be meaningless to a user - sort by the display name shown instead
        return this.sortRows(mergedSections, this.sectionsSortedBy, this.sectionsSortedDirection, { metadataUrl: 'displayName' });
    }

    handleSectionsSort(event) {
        this.sectionsSortedBy = event.detail.fieldName;
        this.sectionsSortedDirection = event.detail.sortDirection;
    }

    sortRows(rows, fieldName, direction, sortFieldNameOverrides = {}) {
        const sortFieldName = sortFieldNameOverrides[fieldName] || fieldName;
        const multiplier = direction === 'asc' ? 1 : -1;
        return [...rows].sort((rowA, rowB) => {
            let valueA = rowA[sortFieldName];
            let valueB = rowB[sortFieldName];
            valueA = typeof valueA === 'string' ? valueA.toLowerCase() : (valueA ?? '');
            valueB = typeof valueB === 'string' ? valueB.toLowerCase() : (valueB ?? '');
            if (valueA < valueB) {
                return -1 * multiplier;
            }
            if (valueA > valueB) {
                return 1 * multiplier;
            }
            return 0;
        });
    }

    connectedCallback() {
        this.fetchFlowForms();
        this.fetchIsProductionOrg();
    }

    fetchIsProductionOrg() {
        getIsProductionOrg({})
            .then((result) => {
                this.isProductionOrg = result;
            })
            .catch(() => {
                // fail silently - the base test-mode warning always shows regardless of org type,
                // this only controls whether the stronger production-specific banner also shows
            });
    }

    fetchFlowForms() {
        this.isLoadingForms = true;
        flowForms({})
            .then((results) => {
                const parsedResults = JSON.parse(results);
                this.availableFlowForms = parsedResults.forms;
            })
            .catch((error) => {
                this.showToast(labels.errorLoadingFormsToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            })
            .finally(() => {
                this.isLoadingForms = false;
            });
    }

    get formTypeFilterOptions() {
        const types = new Set();
        this.availableFlowForms.forEach((form) => {
            if (form.type) {
                types.add(form.type);
            }
        });
        return [
            { label: labels.allTypesOptionLabel, value: 'All' },
            ...Array.from(types).sort().map((type) => ({ label: type, value: type }))
        ];
    }

    get filteredFormOptions() {
        const term = (this.formSearchTerm || '').trim().toLowerCase();
        return this.availableFlowForms
            .filter((form) => this.formTypeFilter === 'All' || form.type === this.formTypeFilter)
            .filter((form) => !term || form.masterLabel.toLowerCase().includes(term) || form.developerName.toLowerCase().includes(term))
            .map((form) => ({ label: form.masterLabel, value: form.developerName, id: `form-option-${form.developerName}` }));
    }

    get hasFilteredFormOptions() {
        return this.filteredFormOptions.length > 0;
    }

    get formComboboxClass() {
        return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click${this.isFormDropdownOpen ? ' slds-is-open' : ''}`;
    }

    get isFormDropdownExpanded() {
        return this.isFormDropdownOpen ? 'true' : 'false';
    }

    get highlightedFormOptionId() {
        const option = this.filteredFormOptions[this.highlightedFormOptionIndex];
        return option ? option.id : undefined;
    }

    get formOptionsForDisplay() {
        return this.filteredFormOptions.map((option, index) => ({
            ...option,
            isHighlighted: index === this.highlightedFormOptionIndex,
            optionClass: `slds-media slds-listbox__option slds-listbox__option_plain slds-media_small${index === this.highlightedFormOptionIndex ? ' slds-has-focus' : ''}`
        }));
    }

    get hasSelectedForm() {
        return !!this.selectedForm;
    }

    get selectedFormDetails() {
        return this.availableFlowForms.find((form) => form.developerName === this.selectedForm);
    }

    get hasValidationFlow() {
        return !!this.selectedFormDetails?.validationFlowAPIName;
    }

    get selectedFormMetadataUrl() {
        return this.buildMetadataUrl(this.selectedFormDetails?.id);
    }

    get formInfoCardTitle() {
        return `${labels.formInfoSectionLabel} ${this.selectedFormDetails?.masterLabel || ''}`;
    }

    get testModeCardTitle() {
        const baseTitle = `${labels.testModeTitle} ${this.selectedFormDetails?.masterLabel || ''}`;
        return this.hasTestingSection ? `${baseTitle} - ${this.testingSectionLabel}` : baseTitle;
    }

    get hasCustomFields() {
        return this.customFields.length > 0;
    }

    get hasSections() {
        return this.sections.length > 0;
    }

    get isSectionsAreaLoading() {
        // wait for the section-level custom-field columns too, so the datatable doesn't render once
        // and then have columns appear/reflow a moment later once those resolve separately
        return this.isLoadingSections || this.isLoadingSectionCustomFields;
    }

    get hasSelectedSection() {
        return !!this.selectedSectionDeveloperName;
    }

    get hasValidations() {
        return this.validations.length > 0;
    }

    get flowValidations() {
        return this.validations.filter((validation) => validation.isFlowValidation);
    }

    get hasFlowValidations() {
        return this.flowValidations.length > 0;
    }

    get fieldValidations() {
        return this.validations.filter((validation) => !validation.isFlowValidation);
    }

    get hasFieldValidations() {
        return this.fieldValidations.length > 0;
    }

    get flowValidationsForDatatable() {
        return this.sortRows(this.flowValidations, this.flowValidationsSortedBy, this.flowValidationsSortedDirection);
    }

    get fieldValidationsForDatatable() {
        return this.sortRows(this.fieldValidations, this.fieldValidationsSortedBy, this.fieldValidationsSortedDirection);
    }

    get flowValidationColumns() {
        return [
            { label: labels.validationNameColumnLabel, fieldName: 'masterLabel', type: 'text', sortable: true },
            {
                label: labels.viewMetadataLinkLabel,
                fieldName: 'metadataUrl',
                type: 'button',
                typeAttributes: {
                    label: labels.viewMetadataLinkLabel,
                    name: 'view_metadata',
                    variant: 'base',
                    iconName: 'utility:new_window',
                    iconPosition: 'right'
                }
            },
            { label: labels.validationDisabledColumnLabel, fieldName: 'disabled', type: 'boolean', sortable: true }
        ];
    }

    get fieldValidationColumns() {
        return [
            { label: labels.validationFieldColumnLabel, fieldName: 'fieldAPIName', type: 'text', sortable: true },
            { label: labels.validationDataTypeColumnLabel, fieldName: 'dataType', type: 'text', sortable: true },
            { label: labels.validationValueColumnLabel, fieldName: 'validationValue', type: 'text', sortable: true },
            { label: labels.validationErrorMessageColumnLabel, fieldName: 'customErrorMessage', type: 'text', sortable: true },
            { label: labels.validationDisabledColumnLabel, fieldName: 'disabled', type: 'boolean', sortable: true },
            { label: labels.validationPageColumnLabel, fieldName: 'page', type: 'text', sortable: true },
            {
                label: labels.viewMetadataLinkLabel,
                fieldName: 'metadataUrl',
                type: 'button',
                typeAttributes: {
                    label: labels.viewMetadataLinkLabel,
                    name: 'view_metadata',
                    variant: 'base',
                    iconName: 'utility:new_window',
                    iconPosition: 'right'
                }
            }
        ];
    }

    handleFlowValidationsSort(event) {
        this.flowValidationsSortedBy = event.detail.fieldName;
        this.flowValidationsSortedDirection = event.detail.sortDirection;
    }

    handleFieldValidationsSort(event) {
        this.fieldValidationsSortedBy = event.detail.fieldName;
        this.fieldValidationsSortedDirection = event.detail.sortDirection;
    }

    handleValidationRowAction(event) {
        const actionName = event.detail.action.name;
        if (actionName === 'view_metadata') {
            this.openInNewTab(event.detail.row.metadataUrl);
        }
    }

    get hasMasterObject() {
        return !!this.selectedFormDetails?.masterObject;
    }

    get hasTestRecord() {
        return !!this.testRecordId;
    }

    get hasTestingSection() {
        return !!this.testingSectionLabel;
    }

    get isTestActionDisabled() {
        return !this.hasMasterObject;
    }

    get testActionTitle() {
        return this.isTestActionDisabled ? labels.noMasterObjectText : '';
    }

    get isFormSelectionDisabled() {
        return this.isLoadingForms;
    }

    handleFormTypeFilterChange(event) {
        this.formTypeFilter = event.detail.value;
    }

    handleFormSearchInput(event) {
        this.formSearchTerm = event.target.value;
        this.isFormDropdownOpen = true;
        this.highlightedFormOptionIndex = this.filteredFormOptions.length > 0 ? 0 : -1;
    }

    handleFormSearchFocus() {
        this.isFormDropdownOpen = true;
    }

    handleFormSearchBlur() {
        window.setTimeout(() => {
            this.isFormDropdownOpen = false;
            this.highlightedFormOptionIndex = -1;
        }, 200);
    }

    handleFormSearchKeydown(event) {
        const options = this.filteredFormOptions;
        switch (event.key) {
            case 'ArrowDown':
                event.preventDefault();
                this.isFormDropdownOpen = true;
                if (options.length > 0) {
                    this.highlightedFormOptionIndex = (this.highlightedFormOptionIndex + 1) % options.length;
                }
                break;
            case 'ArrowUp':
                event.preventDefault();
                this.isFormDropdownOpen = true;
                if (options.length > 0) {
                    this.highlightedFormOptionIndex = this.highlightedFormOptionIndex <= 0
                        ? options.length - 1
                        : this.highlightedFormOptionIndex - 1;
                }
                break;
            case 'Enter':
                if (this.isFormDropdownOpen && options[this.highlightedFormOptionIndex]) {
                    event.preventDefault();
                    this.selectForm(options[this.highlightedFormOptionIndex].value);
                }
                break;
            case 'Escape':
                this.isFormDropdownOpen = false;
                this.highlightedFormOptionIndex = -1;
                break;
            default:
                break;
        }
    }

    handleFormOptionSelect(event) {
        this.selectForm(event.currentTarget.dataset.value);
    }

    selectForm(developerName) {
        this.selectedForm = developerName;
        this.formSearchTerm = this.selectedFormDetails?.masterLabel || '';
        this.isFormDropdownOpen = false;
        this.highlightedFormOptionIndex = -1;
        this.selectedSectionDeveloperName = undefined;
        this.validations = [];
        this.hasValidationsError = false;
        this.customFields = [];
        this.sectionCustomFieldsByDeveloperName = {};
        const requestToken = ++this.formRequestToken;
        this.fetchFormSections(requestToken);
        this.fetchFormCustomFields(requestToken);
        this.fetchSectionCustomFieldsForForm(requestToken);
    }

    fetchFormCustomFields(requestToken) {
        getFormCustomFields({ formDeveloperName: this.selectedForm })
            .then((results) => {
                if (requestToken !== this.formRequestToken) {
                    return;
                }
                const parsedResults = JSON.parse(results);
                this.customFields = parsedResults.customFields;
            })
            .catch((error) => {
                if (requestToken !== this.formRequestToken) {
                    return;
                }
                this.showToast(labels.errorLoadingCustomFieldsToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            });
    }

    fetchSectionCustomFieldsForForm(requestToken) {
        this.isLoadingSectionCustomFields = true;
        getSectionCustomFieldsForForm({ formDeveloperName: this.selectedForm })
            .then((results) => {
                if (requestToken !== this.formRequestToken) {
                    return;
                }
                const parsedResults = JSON.parse(results);
                this.sectionCustomFieldsByDeveloperName = parsedResults.sectionCustomFields;
            })
            .catch((error) => {
                if (requestToken !== this.formRequestToken) {
                    return;
                }
                this.showToast(labels.errorLoadingCustomFieldsToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            })
            .finally(() => {
                if (requestToken === this.formRequestToken) {
                    this.isLoadingSectionCustomFields = false;
                }
            });
    }

    fetchFormSections(requestToken) {
        this.isLoadingSections = true;
        this.hasSectionsError = false;
        getFormSections({ formDeveloperName: this.selectedForm })
            .then((results) => {
                if (requestToken !== this.formRequestToken) {
                    return;
                }
                const parsedResults = JSON.parse(results);
                this.sections = parsedResults.sections.map((section) => ({
                    ...section,
                    metadataUrl: this.buildMetadataUrl(section.id)
                }));
                if (this.pendingSectionDeveloperName) {
                    const pendingSectionDeveloperName = this.pendingSectionDeveloperName;
                    this.pendingSectionDeveloperName = undefined;
                    const matchedSection = this.sections.find((section) => section.developerName === pendingSectionDeveloperName);
                    if (matchedSection) {
                        this.selectedSectionDeveloperName = matchedSection.developerName;
                        this.fetchSectionValidations();
                    }
                }
            })
            .catch((error) => {
                if (requestToken !== this.formRequestToken) {
                    return;
                }
                this.hasSectionsError = true;
                this.sections = [];
                this.showToast(labels.errorLoadingSectionsToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            })
            .finally(() => {
                if (requestToken === this.formRequestToken) {
                    this.isLoadingSections = false;
                }
            });
    }


    get selectedSectionRows() {
        return this.selectedSectionDeveloperName ? [this.selectedSectionDeveloperName] : [];
    }

    handleTabActive(event) {
        // keep this in sync with manual tab clicks - otherwise setting activeTabValue to a value it
        // already holds (because the user switched tabs without going through this handler) is a no-op
        // for LWC's change detection and the programmatic tab switch below silently fails
        this.activeTabValue = event.target.value;
    }

    handleOpenFormFromFlowExplorer(event) {
        const { formDeveloperName, sectionDeveloperName } = event.detail || {};
        if (!formDeveloperName) {
            return;
        }
        this.activeTabValue = 'formExplorer';
        this.pendingSectionDeveloperName = sectionDeveloperName;
        this.selectForm(formDeveloperName);
    }

    handleSectionSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows && selectedRows.length > 0) {
            this.selectedSectionDeveloperName = selectedRows[0].developerName;
            this.fetchSectionValidations();
        } else {
            this.selectedSectionDeveloperName = undefined;
            this.validations = [];
            this.hasValidationsError = false;
            this.isLoadingValidations = false;
            // invalidate any in-flight validations fetch so its response can't overwrite this cleared state
            this.sectionRequestToken++;
        }
    }

    fetchSectionValidations() {
        this.isLoadingValidations = true;
        this.hasValidationsError = false;
        const requestToken = ++this.sectionRequestToken;
        const requestedSectionDeveloperName = this.selectedSectionDeveloperName;
        getSectionValidations({ sectionDeveloperName: requestedSectionDeveloperName })
            .then((results) => {
                if (requestToken !== this.sectionRequestToken) {
                    return;
                }
                const parsedResults = JSON.parse(results);
                this.validations = parsedResults.validations.map((validation) => ({
                    ...validation,
                    metadataUrl: this.buildMetadataUrl(validation.id)
                }));
            })
            .catch((error) => {
                if (requestToken !== this.sectionRequestToken) {
                    return;
                }
                this.hasValidationsError = true;
                this.validations = [];
                this.showToast(labels.errorLoadingValidationsToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            })
            .finally(() => {
                if (requestToken === this.sectionRequestToken) {
                    this.isLoadingValidations = false;
                }
            });
    }

    handleSectionRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'open_flow') {
            this.openFlow(row.flowAPIName);
        } else if (actionName === 'open_metadata') {
            this.openInNewTab(row.metadataUrl);
        } else if (actionName === 'test_section') {
            this.enterTestMode(row);
        } else if (actionName === 'where_used') {
            this.openFlowUsage(row.flowAPIName);
        }
    }

    handleOpenValidationFlow() {
        if (this.hasValidationFlow) {
            this.openFlow(this.selectedFormDetails.validationFlowAPIName);
        }
    }

    handleShowValidationFlowUsage() {
        if (this.hasValidationFlow) {
            this.openFlowUsage(this.selectedFormDetails.validationFlowAPIName);
        }
    }

    async handleCloneAction() {
        await H8FormCloneModal.open({
            size: 'medium',
            initialSourceDeveloperName: this.selectedForm
        });
        this.fetchFlowForms();
    }

    handleTestAction() {
        this.enterTestMode();
    }

    handleBackToFormManagement() {
        this.isTestMode = false;
        this.testSectionsToNotDisplay = undefined;
        this.testingSectionLabel = undefined;
        this.isTestSettingsOpen = false;
    }

    handleTestRecordSelection(event) {
        this.testRecordId = event.detail.recordId;
    }

    enterTestMode(section) {
        this.isTestMode = true;
        this.testRecordId = undefined;
        this.isTestSettingsOpen = false;
        this.testLiveValidation = this.hasValidationFlow;
        this.testShowSectionValidationPanel = this.hasValidationFlow;
        this.testShowNoValidationErrorsFound = this.hasValidationFlow;
        this.testShowSectionHeader = this.hasValidationFlow;
        if (section) {
            this.testSectionsToNotDisplay = this.sections
                .filter((s) => s.developerName !== section.developerName)
                .map((s) => s.developerName);
            this.testingSectionLabel = section.displayName;
        } else {
            this.testSectionsToNotDisplay = undefined;
            this.testingSectionLabel = undefined;
        }
    }

    handleToggleTestSettings() {
        this.isTestSettingsOpen = !this.isTestSettingsOpen;
    }

    handleTestSettingToggle(event) {
        const setting = event.currentTarget.dataset.setting;
        this[setting] = event.target.checked;
    }

    async openFlowUsage(flowApiName) {
        await H8FlowUsageModal.open({
            size: 'medium',
            flowApiName
        });
    }

    buildMetadataUrl(recordId) {
        return recordId ? `${labels.metadataSetupUrlPrefix}${recordId}` : undefined;
    }

    openFlow(flowApiName) {
        const newTab = window.open('', '_blank');
        getFlowRecordUrl({ flowApiName })
            .then((url) => {
                this.setNewTabLocation(newTab, url);
            })
            .catch((error) => {
                if (newTab) {
                    newTab.close();
                }
                this.showToast(labels.errorOpeningFlowToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            });
    }

    openInNewTab(url) {
        const newTab = window.open('', '_blank');
        this.setNewTabLocation(newTab, url);
    }

    setNewTabLocation(newTab, url) {
        if (newTab) {
            newTab.location.href = url;
        } else {
            window.open(url, '_blank');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
