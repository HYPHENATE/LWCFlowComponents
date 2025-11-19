/**
 * @file
 * H8FlowFormPageValidationComponent.js
 *
 * Renders ONLY when:
 *  - showSectionValidationPanel = false, AND
 *  - (MASTER) the matching section in store.sections has an error page matching pageName, OR
 *  - (LIVE)   the matching section in store.partialValidations has an error page matching pageName
 *
 * Prevents cross-section bleed when page names repeat.
 *
 * @last modified on: 09-10-2025
 */

import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validatePage from '@salesforce/apex/H8FlowFormPageValidation.validatePage';
import labels from 'c/h8UtilLabels';
import { reduceErrors } from 'c/h8UtilReduceErrors';

import {
  getRecordStore,
  gatePageRender
} from 'c/h8FormValidationUtils';

export default class H8FlowFormPageValidationComponent extends LightningElement {
  label = labels;

  // Public API
  @api recordId;
  @api formName;
  @api parentObjectAPIName;
  @api pageName;

  /**
   * Section label this page component belongs to (recommended).
   * If omitted, falls back to store.currentSectionName.
   */
  @api sectionName;

  @api helpText = this.label.generalHelpText;
  @api affectTextLabel = this.label.affectedQuestionsText;

  // View model
  isLoading = true;
  hasValidationErrors = false;
  validationErrors;
  success = true;
  message;

  connectedCallback(){
    const store = getRecordStore(this.recordId);
    if (!store) return this._finishWithoutRendering();

    const sectionLabel = (this.sectionName || store.currentSectionName || '').trim();
    if (!sectionLabel) return this._finishWithoutRendering();

    const shouldShow = gatePageRender(store, sectionLabel, this.pageName);
    if (!shouldShow) return this._finishWithoutRendering();

    // Fill inputs defensively
    this.formName = this.formName || store.formName;
    this.parentObjectAPIName = this.parentObjectAPIName || store.parentObjectAPIName;

    if (!this.recordId || !this.formName || !this.parentObjectAPIName || !this.pageName) {
      return this._finishWithoutRendering();
    }

    this.handleValidatePage();
  }

  // Apex
  handleValidatePage() {
    validatePage({
      recordId: this.recordId,
      formName: this.formName,
      parentObjectAPIName: this.parentObjectAPIName,
      pageName: this.pageName
    })
    .then((results) => {
      let parsed = JSON.parse(results);
      
      this.success = parsed.success === true;
      this.message = parsed.message;
      this.isLoading = false;

      if (!this.success) return;

      const errors = Array.isArray(parsed.errors) ? parsed.errors : [];
      this.validationErrors = errors.map(e => ({
        ...e,
        questionName: e.questionName || e.field || e.message || ''
      }));

      this.hasValidationErrors = parsed.hasValidationErrors === true
        || this.validationErrors.length > 0;
    })
    .catch((error) => {
      this.showToast(this.label.validationToastTitle, reduceErrors(error).toString(), 'error');
      this._finishWithoutRendering();
    });
  }

  // Helpers
  _finishWithoutRendering() {
    this.isLoading = false;
    this.success = true;
    this.hasValidationErrors = false;
    this.validationErrors = [];
  }
  showToast(title, message, variant){
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}