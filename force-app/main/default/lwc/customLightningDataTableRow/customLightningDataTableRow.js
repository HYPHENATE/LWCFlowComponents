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

    const fields = (this.currentData.fields || []).map(f =>
      f.fieldAPIName === apiPath ? { ...f, value: newVal } : f
    );

    this.currentData = { id: this.currentData.id, fields };

    // Apply deps if this field is a controller
    this.applyDependenciesForController(apiPath);

    // If this field is a dependent picklist, clear its error when user selects something
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
    if (!this._picklistMeta || !this.currentData?.fields) return;

    const fields = [...this.currentData.fields];

    const ctrlVals = {};
    fields.forEach(f => { ctrlVals[this._norm(f.fieldAPIName)] = f.value; });

    const nextFields = fields.map(f => {
      if (f.isPicklist && f.controllerFieldAPIName) {
        const ctrlVal = ctrlVals[f.controllerFieldAPIName];
        return this._filteredDependentField(f, ctrlVal, false);
      }
      if (f.isPicklist) return { ...f, _disabled: false };
      return f;
    });

    this.currentData = { id: this.currentData.id, fields: nextFields };
  }

  applyDependenciesForController(controllerApiPath) {
    if (!this._picklistMeta || !this.currentData?.fields) return;

    const ctrlNorm = this._norm(controllerApiPath);
    const fields = [...this.currentData.fields];

    const ctrlField = fields.find(f => this._norm(f.fieldAPIName) === ctrlNorm);
    if (!ctrlField) return;

    const ctrlVal = ctrlField.value;

    const nextFields = fields.map(f => {
      const isDependentOfThis = f.isPicklist && f.controllerFieldAPIName === ctrlNorm;
      return isDependentOfThis ? this._filteredDependentField(f, ctrlVal, true) : f;
    });

    this.currentData = { id: this.currentData.id, fields: nextFields };
  }

  _filteredDependentField(depField, controllerValue, fromControllerChange) {
    const depNorm = this._norm(depField.fieldAPIName);
    const meta = this._picklistMeta?.[depNorm];

    if (!meta || !controllerValue) {
      const hadValue = !!depField.value;
      const cleared = { ...depField, _disabled: true, value: '', picklistOptions: [] };

      if (fromControllerChange && hadValue) this._showFieldClearedMessage(depField.fieldAPIName);
      else this._clearFieldError(depField.fieldAPIName);

      return cleared;
    }

    const idxMap = meta.controllerValues || {};
    const ctrlIdx = idxMap[controllerValue];

    if (ctrlIdx === undefined) {
      const hadValue = !!depField.value;
      const cleared = { ...depField, _disabled: true, value: '', picklistOptions: [] };

      if (fromControllerChange && hadValue) this._showFieldClearedMessage(depField.fieldAPIName);
      else this._clearFieldError(depField.fieldAPIName);

      return cleared;
    }

    const allowed = (meta.values || [])
      .filter(v => this._validForIncludes(v.validFor, Number(ctrlIdx)))
      .map(v => ({ label: v.label, value: v.value }));

    const hadValue = !!depField.value;
    let nextValue = depField.value;

    if (nextValue && !allowed.some(o => o.value === nextValue)) {
      nextValue = '';
      if (fromControllerChange && hadValue) this._showFieldClearedMessage(depField.fieldAPIName);
      else this._clearFieldError(depField.fieldAPIName);
    } else {
      this._clearFieldError(depField.fieldAPIName);
    }

    return { ...depField, _disabled: false, value: nextValue, picklistOptions: allowed };
  }

  _validForIncludes(validFor, index) {
    if (validFor == null || index == null) return false;

    if (typeof validFor === 'string') {
      try {
        const bin = atob(validFor);
        const bytes = Array.from(bin, c => c.charCodeAt(0));
        return this._bitsetHas(bytes, index);
      } catch {
        return false;
      }
    }

    if (Array.isArray(validFor)) {
      // If someone ever passes an index list
      if (validFor.includes(index)) return true;
      return this._bitsetHas(validFor, index);
    }

    return false;
  }

  _bitsetHas(bytes, index) {
    const byteIndex = Math.floor(index / 8);
    if (!bytes || byteIndex >= bytes.length) return false;
    const bitIndex = index % 8;

    // ✅ Salesforce validFor uses MSB-first within each byte
    const mask = 1 << (7 - bitIndex);

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