import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFlowUsage from '@salesforce/apex/H8FlowFormManagerController.getFlowUsage';
import labels from './labels';

export default class H8FlowUsageTable extends LightningElement {
    label = labels;
    isLoading = false;
    hasError = false;
    usages = [];
    sortedBy = 'formLabel';
    sortedDirection = 'asc';

    _flowApiName;
    requestToken = 0;

    @api
    get flowApiName() {
        return this._flowApiName;
    }

    set flowApiName(value) {
        this._flowApiName = value;
        this.requestToken++;
        if (value) {
            this.fetchUsage();
        } else {
            this.usages = [];
            this.hasError = false;
        }
    }

    get columns() {
        return [
            {
                label: labels.formColumnLabel,
                fieldName: 'formDeveloperName',
                type: 'button',
                sortable: true,
                typeAttributes: {
                    label: { fieldName: 'formLabel' },
                    name: 'open_form',
                    variant: 'base'
                }
            },
            {
                label: labels.sectionColumnLabel,
                fieldName: 'sectionDeveloperName',
                type: 'button',
                sortable: true,
                typeAttributes: {
                    label: { fieldName: 'sectionDisplayLabel' },
                    name: 'open_section',
                    variant: 'base',
                    disabled: { fieldName: 'isSectionButtonDisabled' }
                }
            },
            { label: labels.typeColumnLabel, fieldName: 'usageType', type: 'text', sortable: true }
        ];
    }

    get usagesForDatatable() {
        // the Form/Section columns' cell type needs a developer name (fieldName) to identify the row action,
        // but sorting by the developer name itself would be meaningless to a user - sort by the display label instead
        return this.sortRows(this.usages, this.sortedBy, this.sortedDirection, {
            formDeveloperName: 'formLabel',
            sectionDeveloperName: 'sectionDisplayLabel'
        });
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
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

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'open_form') {
            this.dispatchEvent(new CustomEvent('openform', { detail: { formDeveloperName: row.formDeveloperName } }));
        } else if (actionName === 'open_section' && row.sectionDeveloperName) {
            this.dispatchEvent(new CustomEvent('openform', {
                detail: { formDeveloperName: row.formDeveloperName, sectionDeveloperName: row.sectionDeveloperName }
            }));
        }
    }

    fetchUsage() {
        this.isLoading = true;
        this.hasError = false;
        const requestToken = this.requestToken;
        getFlowUsage({ flowApiName: this._flowApiName })
            .then((results) => {
                if (requestToken !== this.requestToken) {
                    return;
                }
                const parsedResults = JSON.parse(results);
                this.usages = parsedResults.usages.map((usage) => ({
                    ...usage,
                    key: `${usage.usageType}-${usage.formDeveloperName}-${usage.sectionDeveloperName}`,
                    sectionDisplayLabel: usage.sectionLabel || '—',
                    isSectionButtonDisabled: !usage.sectionDeveloperName
                }));
            })
            .catch((error) => {
                if (requestToken !== this.requestToken) {
                    return;
                }
                this.hasError = true;
                this.usages = [];
                this.showToast(labels.errorLoadingToastTitle, error?.body?.message || labels.unknownErrorToastMessage, 'error');
            })
            .finally(() => {
                if (requestToken === this.requestToken) {
                    this.isLoading = false;
                }
            });
    }

    get hasUsages() {
        return this.usages.length > 0;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
