/**
 * @file
 * H8FormFlowValidationComponent.js
 *
 * Core validation component that:
 *  1) Runs a **master (full-form)** server-side validation via Apex.
 *  2) Publishes a **sessionStorage trigger** so sibling components (e.g., the render component)
 *     know to refresh their section icons and validation panels (showing red crosses, etc).
 *  3) Optionally advances the Flow when "Next" is available.
 *
 * Apex contract: H8FlowFormValidation.validateCompleteForm(recordId, primaryObjectAPIName, formAPIName, sectionsToNotDisplay[])
 *  -> JSON {
 *       success: boolean,
 *       isValid: boolean,
 *       hasErrors: boolean,
 *       message?: string,
 *       sections: [{
 *         id/sectionName/developerName,
 *         isValid: boolean,
 *         hasErrors: boolean,
 *         pages: [{ pageLabel, errors: [{ message, field? }] }]
 *       }]
 *     }
 *
 * Cross-component signaling:
 *  - This component sets sessionStorage["h8:formProcessing"][recordId].isMasterValidation = true
 *    after a successful master run. Listeners (e.g., H8FlowFormRenderComponent) poll this store,
 *    run their own fetch/refresh based on the trigger, and then clear the flag.
 *  - It also cleans up any legacy array found at sessionStorage["formProcessing"].
 *
 * UI copy is provided via `c/h8UtilLabels` with sensible defaults, all overridable via @api.
 *
 * @description       : Core validation component that validates the entire form
 *                      and signals the render component to show red crosses.
 * @author            : daniel@hyphen8.com
 * @last modified on  : 09-09-2025
 * @last modified by  : daniel@hyphen8.com
 */

import { LightningElement, api } from 'lwc';

import validateFormData from '@salesforce/apex/H8FlowFormValidation.validateCompleteForm';
import { reduceErrors } from 'c/h8UtilReduceErrors';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import labels from 'c/h8UtilLabels';

/** Current per-record store (object map) used by sibling components to coordinate. */
const STORE_KEY  = 'h8:formProcessing';
/** Legacy array-based key (kept for backward compatibility; cleaned up when detected). */
const LEGACY_KEY = 'formProcessing';

export default class H8FormFlowValidationComponent extends LightningElement {
    /** i18n bundle injected from shared utilities. */
    label = labels;

    // ------------------------------
    // Public API (inputs/labels)
    // ------------------------------

    /** The record Id to validate against. */
    @api recordId;

    /** DeveloperName of the form to validate. */
    @api formName;

    /** API name of the form’s parent/master SObject. */
    @api parentObjectAPIName;

    /** Card title text (header of this component’s UI). */
    @api cardTitle = this.label.cardTitle;

    /** Label for the “Next”/submit button. */
    @api nextButtonLabel = this.label.submissionButtonLabel;

    /** Helper text prompting users to complete fields. */
    @api completeFieldsText = this.label.generalHelpText;

    /** Description shown when validation failed. */
    @api invalidCardDescription = this.label.invalidSubmissionText;

    /** Description shown when validation passed. */
    @api validCardDescription = this.label.validSubmissionText;

    /** Label used above the list of affected questions. */
    @api affectTextLabel = this.label.affectedQuestionsText;

    /**
     * Optional list of sections to exclude from master validation.
     * @type {Array<string>|undefined}
     */
    @api sectionsToNotDisplay;

    // ------------------------------
    // Public API (Flow integration)
    // ------------------------------

    /**
     * Flow-provided list of available actions for this screen (e.g., ["NEXT", "BACK"]).
     * Used to decide whether we can dispatch FlowNavigationNextEvent.
     */
    @api availableActions = [];

    // ------------------------------
    // Internal state (view model)
    // ------------------------------

    /** Spinner/initial state while Apex call is in-flight. */
    isLoading = true;

    /** Server-returned sections payload (used for detailed results display). */
    sections;

    /** Whether server detected any errors across the form. */
    hasErrors;

    /** Whether the form is valid overall. */
    isValid;

    /** Whether the Apex validation call succeeded (transport + domain). */
    success;

    /** Optional server message. */
    message;

    // ------------------------------
    // Lifecycle
    // ------------------------------

    /**
     * On mount, kick off a master (full-form) validation.
     * On success, emit a cross-component sessionStorage trigger.
     */
    connectedCallback(){
        this.handleValidateFormData();
    }

    // ------------------------------
    // sessionStorage helpers
    // ------------------------------

    /** Read the entire current-store map (by recordId). */
    _getAllStore() {
        try { return JSON.parse(sessionStorage.getItem(STORE_KEY)) || {}; }
        catch { return {}; }
    }

    /** Persist the entire current-store map (by recordId). */
    _setAllStore(obj) {
        sessionStorage.setItem(STORE_KEY, JSON.stringify(obj || {}));
    }

    /**
     * Write an “isMasterValidation” trigger for this.recordId into the current store
     * so sibling components can detect and refresh their UI (icons/panels).
     * Also clears legacy array entries for this.recordId if found.
     *
     * @param {{ sections: Array }} param0 - currently unused here, but retained for clarity/future use
     */
    _setMasterTrigger({ sections }) {
        const all = this._getAllStore();
        const prev = all[this.recordId] || {};
        all[this.recordId] = {
            ...prev,
            formName: this.formName,
            recordId: this.recordId,
            parentObjectAPIName: this.parentObjectAPIName,
            isMasterValidation: true
        };
        this._setAllStore(all);

        // Best-effort cleanup of the legacy array store
        try {
            const raw = sessionStorage.getItem(LEGACY_KEY);
            if (!raw) return;
            const arr = JSON.parse(raw);
            if (Array.isArray(arr)) {
                const remaining = arr.filter(r => r?.recordId !== this.recordId);
                sessionStorage.setItem(LEGACY_KEY, JSON.stringify(remaining));
            } else {
                sessionStorage.removeItem(LEGACY_KEY);
            }
        } catch {
            /* ignore parse errors / absence */
        }
    }

    // ------------------------------
    // Master validation (Apex)
    // ------------------------------

    /**
     * Execute the server-side full-form validation and update local view model.
     * On success, set the cross-component trigger in sessionStorage.
     */
    handleValidateFormData() {
        validateFormData({
            recordId: this.recordId,
            primaryObjectAPIName: this.parentObjectAPIName,
            formAPIName: this.formName,
            sectionsToNotDisplay: undefined != this.sectionsToNotDisplay ? this.sectionsToNotDisplay : []
        })
        .then((results) => {
            const parsedResults = JSON.parse(results);

            // Persist server payload to view model
            this.sections  = parsedResults.sections;
            this.hasErrors = parsedResults.hasErrors;
            this.isValid   = parsedResults.isValid;
            this.success   = parsedResults.success;
            this.message   = parsedResults.message;

            this.isLoading = false;

            // Notify sibling components (renderer, panels) to refresh their state
            this._setMasterTrigger({ sections: parsedResults.sections });
        })
        .catch((error) => {
            this.isLoading = false;
            this.showToast(this.label.validationToastTitle, reduceErrors(error).toString(), 'error');
        });
    }

    // ------------------------------
    // Flow navigation
    // ------------------------------

    /**
     * If the Flow screen exposes a NEXT action, dispatch FlowNavigationNextEvent.
     * Safe no-op when NEXT is not available (e.g., configured differently).
     */
    handleNext() {
        if (this.availableActions.find((action) => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    // ------------------------------
    // Toast helper
    // ------------------------------

    /**
     * Publish a lightning/platformShowToastEvent.
     * @param {string} toastTitle
     * @param {string} toastMessage
     * @param {"info"|"success"|"warning"|"error"} toastVariant
     */
    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({ title: toastTitle, message: toastMessage, variant: toastVariant }));
    }
}