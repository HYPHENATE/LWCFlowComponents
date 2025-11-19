/**
 * @file
 * H8FlowFormRenderItem.js
 *
 * Single entry in the side navigation for a multi-section Flow form.
 * - Renders an accessible <li>/<button>-like control for a given section.
 * - Applies the correct SLDS classes when active.
 * - Exposes ARIA attributes to convey validation state to screen readers.
 * - Emits a custom "sectionselected" event when clicked or activated via keyboard.
 *
 * Event contract:
 *  - "sectionselected"
 *      detail: { sectionId: string, flowName: string }
 *    Dispatched when the user selects this section (click or Enter/Space).
 *
 * Expected `section` shape (subset):
 *  {
 *    id: string,
 *    label: string,
 *    flow: string,
 *    hasValidationError?: boolean,
 *    hasValidationWarning?: boolean,
 *    hasValidationSuccess?: boolean
 *  }
 *
 * @description       : js for individual item (accessible)
 * @author            : daniel@hyphen8.com
 * @last modified on  : 09-09-2025
 * @last modified by  : daniel@hyphen8.com
 */

import { LightningElement, api } from 'lwc';
import labels from 'c/h8UtilLabels';

export default class H8FlowFormRenderItem extends LightningElement {
    /** i18n bundle injected from shared utilities. */
    label = labels;

    // ------------------------------
    // Public API
    // ------------------------------

    /**
     * Section view model for this nav item (see expected shape in header).
     * @type {object}
     */
    @api section;

    /**
     * Id of the currently active section (from parent component).
     * Used to style this item as active and set ARIA state.
     * @type {string}
     */
    @api activeSection;

    // ------------------------------
    // Computed (styling & ARIA)
    // ------------------------------

    /**
     * SLDS classes for the <li> element based on active state.
     * @returns {string}
     */
    get sectionCSS() {
        return this.activeSection === this.section.id
            ? 'slds-vertical-tabs__nav-item slds-is-active'
            : 'slds-vertical-tabs__nav-item';
    }

    /**
     * ARIA selected state for the interactive element representing this section.
     * @returns {boolean}
     */
    get ariaSelected() {
        return this.activeSection === this.section.id;
    }

    /**
     * Unique id used for the visually-hidden status text, referenced by aria-describedby.
     * @returns {string}
     */
    get statusId() {
        return `${this.section.id}-status`;
    }

    /**
     * Whether there is any validation status to announce or decorate.
     * @returns {boolean}
     */
    get hasStatus() {
        return !!(
            this.section?.hasValidationError ||
            this.section?.hasValidationWarning ||
            this.section?.hasValidationSuccess
        );
    }

    /**
     * Screen-reader friendly status string describing the section’s validation state.
     * Example: "Eligibility: validation errors found."
     * @returns {string}
     */
    get statusTextForSR() {
        const label = this.section?.label || 'Section';
        if (this.section?.hasValidationError)   return `${label}: validation errors found.`;
        if (this.section?.hasValidationWarning) return `${label}: potential issues found.`;
        if (this.section?.hasValidationSuccess) return `${label}: no validation errors found.`;
        return `${label}: status not available.`;
    }

    /**
     * Only link the hidden status element when there’s something meaningful to describe.
     * @returns {string|null}
     */
    get describedById() {
        return this.hasStatus ? this.statusId : null;
    }

    // ------------------------------
    // Handlers (keyboard & click)
    // ------------------------------

    /**
     * Keyboard interaction handler for the section "button".
     * Activates selection on Enter or Space to match button semantics.
     */
    handleOnSectionKeyDown(event){
        const key = event.key || event.keyCode;
        if (key === 'Enter' || key === 13 || key === ' ') {
            this.handleOnSectionSelection(event);
        }
    }

    /**
     * Click/activate handler: notifies parent that this section is selected.
     * Emits: "sectionselected" with { sectionId, flowName }.
     */
    handleOnSectionSelection(event){
        event.preventDefault();
        this.dispatchEventFunction('sectionselected', {
            detail: { sectionId: this.section.id, flowName: this.section.flow }
        });
    }

    // ------------------------------
    // Utilities
    // ------------------------------

    /**
     * Small helper to dispatch a CustomEvent with the given name/detail.
     * @param {string} eventName
     * @param {CustomEventInit} eventDetail
     */
    dispatchEventFunction(eventName, eventDetail) {
        this.dispatchEvent(new CustomEvent(eventName, eventDetail));
    }
}