/**
 * @file
 * H8FormFlowValidationSectionComponent.js
 *
 * Renders ONLY when:
 *  - showSectionValidationPanel = false, AND
 *  - (MASTER) store.sections includes an error entry for this section, OR
 *  - (LIVE)   store.partialValidations has an error entry for this section
 *
 * Loose label matching avoids label formatting issues (e.g., "Section 2" == "section2").
 * No cross-section bleed.
 *
 * @last modified on: 09-10-2025
 */

import { LightningElement, api } from 'lwc';
import getSectionValidation from '@salesforce/apex/H8FlowFormSectionValidation.validatePage';
import { reduceErrors } from 'c/h8UtilReduceErrors';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import labels from 'c/h8UtilLabels';

import {
  getRecordStore,
  gateSectionRender
} from 'c/h8FormValidationUtils';

export default class H8FormFlowValidationSectionComponent extends LightningElement {
  label = labels;

  // Public API
  @api recordId;
  @api formName;
  @api parentObjectAPIName;
  @api sectionName;

  @api helpText = this.label.H8FFGeneralHelpText;
  @api affectTextLabel = this.label.H8FFAffectedQuestions;

  // View model
  hasValidationErrors;
  pages;
  isLoading = true;
  success = true;
  message;

  connectedCallback() {
    const store = getRecordStore(this.recordId);
    if (!store) return this._finishWithoutRendering();

    const targetSection = (this.sectionName || store.currentSectionName || '').trim();
    if (!targetSection) return this._finishWithoutRendering();

    const shouldShow = gateSectionRender(store, targetSection);
    if (!shouldShow) return this._finishWithoutRendering();

    // Fill inputs defensively
    this.formName = this.formName || store.formName;
    this.parentObjectAPIName = this.parentObjectAPIName || store.parentObjectAPIName;
    this.sectionName = targetSection;

    if (!this.recordId || !this.formName || !this.parentObjectAPIName || !this.sectionName) {
      return this._finishWithoutRendering();
    }

    this.handleGetSectionValidation();
  }

  // Apex
  handleGetSectionValidation() {
    getSectionValidation({
      recordId: this.recordId,
      formName: this.formName,
      parentObjectAPIName: this.parentObjectAPIName,
      sectionName: this.sectionName
    })
    .then((results) => {
      let parsed = JSON.parse(results);
      
      this.success = parsed.success === true;
      this.message = parsed.message;
      this.isLoading = false;

      if (!this.success) return;

      const pages = Array.isArray(parsed.pages) ? parsed.pages : [];
      const normalizedPages = pages.map(p => ({ ...p, pageLabel: p.pageLabel || p.pageName || '' }));
      const inferredHasErrors = normalizedPages.some(p => Array.isArray(p.errors) && p.errors.length > 0);

      this.hasValidationErrors = parsed.hasErrors === true || inferredHasErrors;
      this.pages = normalizedPages;
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
    this.pages = [];
  }
  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}