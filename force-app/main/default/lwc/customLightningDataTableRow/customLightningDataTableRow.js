/**
 * @description : row component with dependent picklist filtering
 *                - renders from currentData.fields (HTML unchanged)
 *                - normalizes API names (handles dotted paths)
 *                - supports validFor as [indexes] | [bytes] | base64
 *                - disables dependent until controller chosen
 *                - clears invalid dependent on controller change
 *                - shows inline message when a value is cleared
 */
import { LightningElement, api } from 'lwc';
import deleteIconLabel from '@salesforce/label/c.H8CustomDataTableDeleteIconLabel';
import invalidSelectionText from '@salesforce/label/c.H8CustomDataTableDependentFieldInvalidSelection';

const SHOW_CLEAR_MESSAGE = true;

export default class CustomLightningDataTableRow extends LightningElement {
    _rowData;
    _picklistMeta;

    currentData = { id: undefined, fields: [] };
    deleteIconLabel = deleteIconLabel;
    invalidSelectionText = invalidSelectionText;

    @api
    get rowData() { return this._rowData; }
    set rowData(value) {
        this._rowData = value;
        const fields = (value?.fields || []).map(f => ({ ...f }));
        this.currentData = { id: value?.id, fields };
        this.applyAllDependencies(); 
    }

    @api
    get picklistMeta() { return this._picklistMeta; }
    set picklistMeta(val) {
        this._picklistMeta = val;
        this.applyAllDependencies(); 
    }

    @api recordId;
    @api rowDeleteEnabled;

    fieldChange(event) {
        const apiPath = event.target.dataset.targetField; 
        const type = event.target.dataset.targetFieldType;
        const newVal = (type === 'checkbox') ? event.target.checked : event.target.value;

        const fields = [...(this.currentData.fields || [])];
        const idx = fields.findIndex(f => f.fieldAPIName === apiPath);
        if (idx >= 0) fields[idx] = { ...fields[idx], value: newVal };

        this.currentData = { id: this.currentData.id, fields };

        this.applyDependenciesForController(apiPath);

        const norm = this._norm(apiPath);
        const f = fields.find(x => this._norm(x.fieldAPIName) === norm);
        if (f && f.isPicklist && f.controllerFieldAPIName) {
            this._clearFieldError(apiPath);
        }

        this.dispatchEvent(new CustomEvent('rowupdated', {
            detail: { recordId: this.recordId, rowData: this.currentData.fields }
        }));
    }

    deleteRow() {
        this.dispatchEvent(new CustomEvent('rowdeleted', { detail: { detail: this.recordId } }));
    }

    _norm(api) {
        if (!api) return api;
        const i = api.lastIndexOf('.');
        return i >= 0 ? api.substring(i + 1) : api;
    }

    applyAllDependencies() {
        if (!this._picklistMeta) return;
        const fields = [...(this.currentData.fields || [])];

        const ctrlVals = {};
        fields.forEach(f => { ctrlVals[this._norm(f.fieldAPIName)] = f.value; });

        fields.forEach(f => {
        if (f.isPicklist && f.controllerFieldAPIName) {
            const ctrlVal = ctrlVals[f.controllerFieldAPIName];
            this._filterAndDisable(f, ctrlVal, false);
        } else if (f.isPicklist) {
            f._disabled = false; 
        }
        });

        this.currentData = { id: this.currentData.id, fields };
    }

    applyDependenciesForController(controllerApiPath) {
        if (!this._picklistMeta) return;
        const fields = [...(this.currentData.fields || [])];

        const ctrlNorm = this._norm(controllerApiPath);
        const ctrlField = fields.find(f => this._norm(f.fieldAPIName) === ctrlNorm);
        if (!ctrlField) return;

        const ctrlVal = ctrlField.value;
        const dependents = fields.filter(f =>
        f.isPicklist && f.controllerFieldAPIName === ctrlNorm);

        dependents.forEach(dep => this._filterAndDisable(dep, ctrlVal, true));

        this.currentData = { id: this.currentData.id, fields };
    }

    _filterAndDisable(depField, controllerValue, fromControllerChange) {
        const depNorm = this._norm(depField.fieldAPIName);
        const meta = this._picklistMeta && this._picklistMeta[depNorm];

        if (!meta || !controllerValue) {
        const hadValue = !!depField.value;
        depField._disabled = true;
        depField.value = '';
        depField.picklistOptions = [];
        if (fromControllerChange && hadValue) {
            this._showFieldClearedMessage(depField.fieldAPIName);
        } else {
            this._clearFieldError(depField.fieldAPIName);
        }
        return;
        }

        const idxMap = meta.controllerValues || {};
        const ctrlIdx = idxMap[controllerValue];

        if (ctrlIdx === undefined) {
        const hadValue = !!depField.value;
        depField._disabled = true;
        depField.value = '';
        depField.picklistOptions = [];
        if (fromControllerChange && hadValue) {
            this._showFieldClearedMessage(depField.fieldAPIName);
        } else {
            this._clearFieldError(depField.fieldAPIName);
        }
        return;
        }

        const allowed = (meta.values || [])
        .filter(v => this._validForIncludes(v.validFor, Number(ctrlIdx)))
        .map(v => ({ label: v.label, value: v.value }));

        const hadValue = !!depField.value;
        depField._disabled = false;

        if (depField.value && !allowed.some(o => o.value === depField.value)) {
        depField.value = '';
        depField.picklistOptions = allowed;
        if (fromControllerChange && hadValue) {
            this._showFieldClearedMessage(depField.fieldAPIName);
        } else {
            this._clearFieldError(depField.fieldAPIName);
        }
        } else {
        depField.picklistOptions = allowed;
        this._clearFieldError(depField.fieldAPIName);
        }
    }

    /**
     * Return true if validFor indicates the option is valid for the given controller index.
     * Supports:
     *  - index list: [0,4,7]
     *  - byte array (bitset): [1,0,16,...]
     *  - base64 bitset: "AQ=="
     */
    _validForIncludes(validFor, index) {
        if (validFor == null || index == null) return false;

        if (Array.isArray(validFor)) {
        if (validFor.includes(index)) return true;
        return this._bitsetHas(validFor, index);
        }

        if (typeof validFor === 'string') {
        try {
            const bin = atob(validFor);
            const bytes = Array.from(bin, c => c.charCodeAt(0));
            return this._bitsetHas(bytes, index);
        } catch {
            return false;
        }
        }

        return false;
        }

    _bitsetHas(bytes, index) {
        const byteIndex = Math.floor(index / 8);
        if (!bytes || byteIndex >= bytes.length) return false;
        const bitIndex = index % 8;
        const mask = 1 << bitIndex;
        return (bytes[byteIndex] & mask) !== 0;
    }

    _showFieldClearedMessage(fieldApiPath) {
        if (!SHOW_CLEAR_MESSAGE) return;
        requestAnimationFrame(() => {
        const el = this.template.querySelector(
            `lightning-combobox[data-target-field="${fieldApiPath}"]`
        );
        if (el) {
            el.setCustomValidity(this.invalidSelectionText);
            el.reportValidity();
        }
        });
    }

    _clearFieldError(fieldApiPath) {
        const el = this.template.querySelector(
        `lightning-combobox[data-target-field="${fieldApiPath}"]`
        );
        if (el) {
        el.setCustomValidity('');
        el.reportValidity();
        }
    }
}