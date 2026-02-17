/**
 * Custom Lightning Data Table (no session storage, UI API picklist deps, live totals)
 */
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

// UI API for picklists
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

import actionsLabel from '@salesforce/label/c.H8CustomDataTableActionsLabel';
import getData from '@salesforce/apex/customLightningDataTableController.getFieldsAndRecords';

export default class CustomLightningDataTable extends LightningElement {
  // public api
  @api sObjectAPIName;
  @api fieldSetAPIName;
  @api parentFieldAPIName;
  @api parentRecordId;
  @api allowAddRow = false;
  @api allowEdit = false;
  @api allowRowDeletion = false;
  @api maxRows;
  @api startingRowCount;
  @api whereClause;
  @api orderByClause;
  @api defaultFieldValues;
  @api newRecords;
  @api existingRecords;
  @api minRows;
  @api addRowButtonLabel = 'Add Row';

  // NEW: totals configuration
  @api totalFields;      // comma-separated API names, e.g. "Amount, Discount__c"
  @api currencyCode;     // optional, e.g. "USD", "GBP" (for currency totals)

  actionsLabel = actionsLabel;

  // picklist dependency meta
  @track picklistMeta = {};
  recordTypeId;

  // wires
  @wire(getObjectInfo, { objectApiName: '$sObjectAPIName' })
  handleObjectInfo({ data }) {
    if (data) this.recordTypeId = data.defaultRecordTypeId;
  }

  @wire(getPicklistValuesByRecordType, { objectApiName: '$sObjectAPIName', recordTypeId: '$recordTypeId' })
  handlePicklistValues({ data }) {
    if (data) {
      const out = {};
      const pfv = data.picklistFieldValues || {};
      Object.keys(pfv).forEach(api => {
        out[api] = {
          controllerValues: pfv[api].controllerValues,
          values: pfv[api].values
        };
      });
      this.picklistMeta = out;
    }
  }

  // validation used by Flow
  @api
  validate() {
    this.template.querySelectorAll('lightning-input, lightning-combobox').forEach(el => el.blur());
    this.refreshOutputs(); // ensure latest
    if (this.validForSaveCheck || !this.allowEdit) return { isValid: true };
    return { isValid: false, errorMessage: 'You need to complete this table before you proceed' };
  }

  // state
  @track columns;
  @track data;
  @track defaultFields;
  editData;

  @track rowCount = 0;
  offSet = 0;

  // NEW: field meta + totals
  fieldMetaByApi = {};                 // { api : { type, scale, isCurrency, isPercent, isNumber } }
  totalFieldSet = new Set();           // normalized list of fields to total
  @track totalsByField = {};           // { api : number }
  @track footerRow = [];               // array aligned to columns for tfoot

  connectedCallback() {
    this.handleGetData();
  }

  // Load records + field metadata
  handleGetData() {
    getData({
      sObjectName: this.sObjectAPIName,
      fieldSetAPIName: this.fieldSetAPIName,
      parentIDField: this.parentFieldAPIName,
      parentId: this.parentRecordId,
      whereClause: this.whereClause,
      orderByClause: this.orderByClause
    })
      .then((results) => {
        const recordData = results.records || [];
        const fieldData = (results.fieldDetail && results.fieldDetail.fields) || [];

        // Build meta map and defaultFields template
        this.fieldMetaByApi = {};
        const templateFields = [];
        fieldData.forEach(fd => {
          // meta
          this.fieldMetaByApi[fd.fieldAPIName] = {
            type: fd.fieldType, // original type: 'currency' | 'double' | 'percent' | 'string' ...
            scale: fd.scale || 0,
            isCurrency: fd.isCurrency,
            isPercent: fd.isPercent,
            isNumber: fd.isNumber || fd.fieldType === 'double'
          };

          // template
          const pickListValues = this.getPickListValues(fd.picklistOptions);
          const fieldType = this.getType(fd.fieldType);
          const defaultValue = fieldType === 'checkbox' ? false : '';
          templateFields.push({
            value: defaultValue,
            fieldAPIName: fd.fieldAPIName,
            fieldType: fieldType,
            label: fd.label,
            scale: fd.scale,
            length: fd.length,
            required: fd.required,
            isPicklist: fd.isPicklist,
            isCheckbox: fd.isCheckbox,
            isText: fd.isText,
            isNumber: fd.isNumber,
            isDate: fd.isDate,
            isEmail: fd.isEmail,
            isPhone: fd.isPhone,
            isURL: fd.isURL,
            isPercent: fd.isPercent,
            isCurrency: fd.isCurrency,
            picklistOptions: pickListValues,
            stepScale: fd.stepScale,
            controllerFieldAPIName: fd.controllerFieldAPIName
          });
        });

        // Parse totals config now that we know available fields
        this.configureTotals();

        // Existing rows -> editData
        this.rowCount = 0;
        let editItems = [];
        recordData.forEach(rec => {
          this.rowCount += 1;
          const flat = Object.entries(rec).map(([k, v]) => ({ key: k, value: v }));
          let individualrecord = [];
          fieldData.forEach(fd => {
            const pickListValues = this.getPickListValues(fd.picklistOptions);
            const found = flat.find(f => f.key === fd.fieldAPIName);
            const value = found ? found.value : '';
            individualrecord.push({
              value: value,
              fieldAPIName: fd.fieldAPIName,
              fieldType: this.getType(fd.fieldType),
              required: fd.required,
              isPicklist: fd.isPicklist,
              isCheckbox: fd.isCheckbox,
              isText: fd.isText,
              isNumber: fd.isNumber,
              isDate: fd.isDate,
              isEmail: fd.isEmail,
              isPhone: fd.isPhone,
              isURL: fd.isURL,
              isPercent: fd.isPercent,
              isCurrency: fd.isCurrency,
              picklistOptions: pickListValues,
              stepScale: fd.stepScale,
              scale: fd.scale,
              length: fd.length,
              controllerFieldAPIName: fd.controllerFieldAPIName
            });
          });
          editItems.push({ id: rec.Id, fields: individualrecord });
        });

        // columns for read-only datatable
        this.columns = fieldData.map(fd => ({
          label: fd.label,
          fieldName: fd.fieldAPIName,
          type: this.getType(fd.fieldType)
        }));

        this.data = recordData;
        this.defaultFields = templateFields;
        this.editData = editItems;

        // starting rows
        if (this.allowAddRow && this.allowEdit && this.startingRowCount) {
          const startingCount = this.rowCount + 1;
          for (let i = startingCount; i <= this.startingRowCount; i++) {
            this.generateRecord();
          }
        }

        // Build outputs & totals
        if (this.allowEdit) {
          this.refreshOutputs();
        } else {
          this.recalculateTotals(); // if you later want totals in read-only mode
        }
      })
      .catch((error) => {
        // eslint-disable-next-line no-console
        console.error('error handleGetData > ' + JSON.stringify(error && error.message));
        this.showToast('Error encountered', 'Contact the site administrator an error or configuration error has been encountered', 'error');
      });
  }

  // UI helpers
  getPickListValues(pickValues) {
    const pickListValues = [];
    (pickValues || []).forEach(p => {
      if (p && typeof p === 'object' && 'label' in p && 'value' in p) {
        pickListValues.push({ label: p.label, value: p.value });
      } else {
        pickListValues.push({ label: p, value: p });
      }
    });
    return pickListValues;
  }

  getType(typeValue) {
    switch (typeValue) {
      case 'string':   return 'text';
      case 'email':    return 'email';
      case 'phone':    return 'phone';
      case 'boolean':  return 'checkbox';
      case 'date':
      case 'datetime': return 'date';
      case 'url':      return 'url';
      case 'textarea': return 'text';
      case 'picklist': return 'combobox';
      case 'currency':
      case 'double':
      case 'percent':  return 'number';
      default:         return 'text';
    }
  }

  get displayRowAddButton() {
    const currentRowCount = this.rowCount + 1;
    return currentRowCount <= this.maxRows && this.allowAddRow;
  }

  generateRecord() {
    this.rowCount += 1;
    const randomValue = Math.floor(Math.random() * 1000000) + 1;
    const fields = this.defaultFields.map(f => ({ ...f }));
    this.editData = [...this.editData, { id: `tmp_${randomValue}`, fields }];
    if (this.allowEdit) this.refreshOutputs();
  }

  handleRowDelete(event) {
    this.rowCount -= 1;
    const deleteRowEvent = event.detail.detail;
    this.editData = (this.editData || []).filter(record => record.id !== deleteRowEvent);
    if (deleteRowEvent && !deleteRowEvent.startsWith('tmp_')) {
      deleteRecord(deleteRowEvent).catch(error => {
        // eslint-disable-next-line no-console
        console.error(JSON.stringify(error && error.message));
      });
    }
    this.recalculateTotals();
    if (this.allowEdit) this.refreshOutputs();
  }

  handleRowUpdate(event) {
    const rowId = event.detail.recordId;
    const rowData = event.detail.rowData;
    const rowIndex = (this.editData || []).findIndex(row => row.id === rowId);
    if (rowIndex >= 0) {
      this.editData[rowIndex].fields = rowData.map(f => ({ ...f }));
    }
    this.recalculateTotals();
    if (this.allowEdit) this.refreshOutputs();
  }

  // Validation
  get validForSaveCheck() {
    let validForSave = true;
    (this.editData || []).forEach(element => {
      (element.fields || []).forEach(field => {
        if (field.required && (field.value === '' || field.value === null || field.value === undefined)) {
          validForSave = false;
        }
      });
    });
    if (this.minRows > 0 && this.rowCount < this.minRows) {
      validForSave = false;
    }
    return validForSave;
  }

  // ==== Totals ====

  configureTotals() {
    this.totalFieldSet = new Set();
    if (!this.totalFields) return;

    const wanted = this.totalFields.split(',').map(s => s.trim()).filter(Boolean);
    wanted.forEach(api => {
      const meta = this.fieldMetaByApi[api];
      if (!meta) return;
      if (meta.isCurrency || meta.isPercent || meta.isNumber || meta.type === 'double' || meta.type === 'currency' || meta.type === 'percent') {
        this.totalFieldSet.add(api);
      }
    });
  }

    addRow() {
        this.generateRecord();
    }

  recalculateTotals() {
    const totals = {};
    // init totals to 0
    this.totalFieldSet.forEach(api => { totals[api] = 0; });

    (this.editData || []).forEach(row => {
      (row.fields || []).forEach(f => {
        if (!this.totalFieldSet.has(f.fieldAPIName)) return;
        const v = f.value;
        if (v === '' || v === null || v === undefined) return;
        const num = Number(v);
        if (!isNaN(num)) totals[f.fieldAPIName] += num;
      });
    });

    this.totalsByField = totals;
    this.rebuildFooterRow();
  }

  rebuildFooterRow() {
    // Build a row aligned to columns (+ actions if present)
    const cells = [];
    const cols = this.columns || [];
    cols.forEach(col => {
      const api = col.fieldName;
      const meta = this.fieldMetaByApi[api] || {};
      const isTotal = this.totalFieldSet.has(api);
      const raw = isTotal ? (this.totalsByField[api] || 0) : null;
      const cell = {
        key: `f_${api}`,
        isTotal,
        isCurrency: !!meta.isCurrency,
        isPercent: !!meta.isPercent,
        isNumber: !!meta.isNumber || meta.type === 'double',
        value: raw,
        scale: meta.scale || 0,
        percentDisplayValue: null
      };
      if (isTotal && cell.isPercent) {
        // lightning-formatted-number with style="percent" expects decimals (0.1 === 10%)
        cell.percentDisplayValue = raw / 100;
      }
      cells.push(cell);
    });

    if (this.allowRowDeletion) {
      cells.push({ key: 'f_actions', isTotal: false }); // blank under actions
    }
    this.footerRow = cells;
  }

  // ==== Outputs (client-side) ====
  buildSavePayload() {
    const toTyped = (f) => {
      const v = f.value;
      if (v === '' || v === null || v === undefined) return undefined;
      switch (f.fieldType) {
        case 'checkbox': return !!v;
        case 'number':   return Number(v);
        case 'date':     return v;
        default:         return v;
      }
    };

    let defaults = {};
    if (this.defaultFieldValues) {
      try { defaults = JSON.parse(this.defaultFieldValues) || {}; } catch (e) { /* noop */ }
    }

    const newList = [];
    const oldList = [];

    (this.editData || []).forEach(row => {
      const rec = { [this.parentFieldAPIName]: this.parentRecordId };
      Object.assign(rec, defaults);

      (row.fields || []).forEach(f => {
        const typed = toTyped(f);
        if (typed !== undefined) rec[f.fieldAPIName] = typed;
      });

      const isExisting = row.id && !row.id.startsWith('tmp_') && (row.id.length === 15 || row.id.length === 18);
      if (isExisting) {
        rec.Id = row.id;
        oldList.push(rec);
      } else {
        newList.push(rec);
      }
    });

    return { newList, oldList };
  }

  refreshOutputs() {
    const { newList, oldList } = this.buildSavePayload();
    this.newRecords = newList;
    this.existingRecords = oldList;
    this.notifyFlowComponentOfData('newRecords', newList);
    this.notifyFlowComponentOfData('existingRecords', oldList);

    // ensure totals reflect latest data
    this.recalculateTotals();
  }

  // events
  showToast(toastTitle, toastMessage, toastVariant) {
    this.dispatchEvent(new ShowToastEvent({ title: toastTitle, message: toastMessage, variant: toastVariant }));
  }

  notifyFlowComponentOfData(variable, value) {
    const attributeChangeEvent = new FlowAttributeChangeEvent(variable, value);
    this.dispatchEvent(attributeChangeEvent);
  }

  // Totals row visibility
  get showTotalsRow() {
    return this.allowEdit && this.totalFieldSet.size > 0 && (this.columns || []).length > 0;
  }
}