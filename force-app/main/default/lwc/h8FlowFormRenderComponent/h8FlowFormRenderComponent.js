/**
 * @file
 * H8FlowFormRenderComponent.js
 *
 * PURPOSE
 * -------
 * - Render a multi-section, Flow-driven form with a side navigation panel.
 * - Load the form definition (sections) from Apex.
 * - Host a <lightning-flow> for the active section.
 * - Support both live (per-section) and master (entire form) validations.
 * - Persist lightweight state/results in sessionStorage for cross-component coordination,
 *   external master triggers, and refresh-resilient UX.
 *
 * CANONICAL KEY
 * -------------
 * - The ONLY key used to identify sections for validation is **customLabel**.
 * - All caches, comparisons, and persisted results are keyed strictly by customLabel.
 * - UI may still display `label`; logic must not depend on `label` or `sectionName`.
 *
 * @author
 * @last modified on  : 09-10-2025
 */

import { LightningElement, api, track } from 'lwc';
import LANG from '@salesforce/i18n/lang';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getForm from '@salesforce/apex/H8FlowFormController.getForm';
import validateForm from '@salesforce/apex/H8FlowFormValidation.validateCompleteForm';
import validationSection from '@salesforce/apex/H8FlowFormSectionValidation.validatePage';

import { reduceErrors } from 'c/h8UtilReduceErrors';
import labels from 'c/h8UtilLabels';

// ---- Shared utilities (single source of truth)
import {
    // store I/O
    getAllStore,
    setAllStore,
    getRecordStore,
    setRecordStore,
    ackMasterTrigger,
    suppressLiveValidationNow,
    persistLiveValidationForSection,
    upsertMasterSectionResult,
    // key helpers
    uiKey,
    serverKey,
    // misc
    toBool
} from 'c/h8FormValidationUtils';

export default class H8FlowFormRenderComponent extends LightningElement {
    // ------------------------------
    // Public API (@api)
    // ------------------------------

    label = labels;

    /** DeveloperName of the Form to load. */
    @api formName;

    /** Current record Id for the hosted Flow. */
    @api recordId;

    /** 1-based index of the initial section to show. */
    @api defaultPage = 1;

    /** Pixels to offset when auto-scrolling the Flow into view after nav. */
    @api scrollToTopOffset = 150;

    /** CSS width for the side nav, e.g. "12rem". */
    @api navWidth = '12rem';

    /** When true, detects language (URL param or org LANG) and passes to Flow as varLanguage. */
    @api getLanguage = false;

    /** Array<string> of section names to exclude from rendering/validation. */
    @api sectionsToNotDisplay;

    /** Enable live per-section validation as the user navigates. */
    @api liveValidation = false;

    /** Show the right-hand validation results panel for the active section. */
    @api showSectionValidationPanel = false;

    /**
     * When true, allow success ticks to show when no errors.
     * When false (default), never show green ticks — only warnings/errors appear.
     */
    @api showNoValidationErrorsFound = false;

    // ------------------------------
    // Private state
    // ------------------------------

    /** Parent/master SObject API name (from getForm). */
    masterObject;

    /** Actual API name of the form returned by getForm (may differ from @api formName). */
    formDeveloperName;

    /** 2-letter language code passed to Flow when getLanguage=true. */
    varLanguage;

    /** Loading flags. */
    isLoading = true;
    loadFlow = false;

    /** All form sections (as returned by Apex). */
    @track sections;

    /** Currently active section id and Flow api name. */
    activeSectionId;
    flowAPIName;

    /** When true, scroll to Flow wrapper after section change. */
    @track scrollToFlow = false;

    /** Interval id for polling for master triggers in storage. */
    intervalId;

    // ------------------------------
    // Caches for inline panel (keyed by **customLabel**)
    // ------------------------------

    /**
     * Live (per-section) validation cache:
     * { [customLabel]: { hasErrors: boolean, pages: [], ts: number } }
     */
    @track _liveErrorsByKey = {};

    /**
     * Master (post full-validate) cache:
     * { [customLabel]: { hasErrors: boolean, pages: [], ts: number } }
     */
    @track _masterErrorsByKey = {};

    /** Prevents double-submit of master validations. */
    masterValidationInProgress = false;

    // ------------------------------
    // Inline panel (computed) — keys are **customLabel**
    // ------------------------------

    get activeSectionObj() {
        return this.sections?.find(s => s.id === this.activeSectionId);
    }

    get activeSectionKey() {
        const s = this.activeSectionObj;
        // Prefer customLabel; fall back to utils, then label
        return s ? (s.customLabel || uiKey(s) || s.label || '') : '';
    }

    get activeSectionLabel() {
        // UI-only
        return this.activeSectionObj?.label || this.label.activeSectionLabel;
    }

    get activeLiveHasErrors() {
        const entry = this._liveErrorsByKey[this.activeSectionKey];
        return !!(entry && entry.hasErrors);
    }

    get activeLivePages() {
        const entry = this._liveErrorsByKey[this.activeSectionKey];
        return entry?.pages || [];
    }

    get activeMasterHasErrors() {
        const entry = this._masterErrorsByKey[this.activeSectionKey];
        return entry ? !!entry.hasErrors : undefined;
    }

    get activeMasterPages() {
        const entry = this._masterErrorsByKey[this.activeSectionKey];
        return entry?.pages || [];
    }

    get renderValidationPanel() {
        if (!this.showSectionValidationPanel) return false;
        const hasLive = this.activeLiveHasErrors === true;
        const hasMaster = this.activeMasterHasErrors === true;
        return hasLive || hasMaster;
    }

    // ------------------------------
    // Lifecycle
    // ------------------------------

    connectedCallback(){
        this.handleGetForm();
        if (this.getLanguage) this.fetchLanguage();

        // Expose flags for children/gating
        if (this.recordId) {
            setRecordStore(this.recordId, {
                liveValidation: !!this.liveValidation,
                showSectionValidationPanel: !!this.showSectionValidationPanel
            });
        }

        // Poll every 500ms for external "isMasterValidation" triggers
        this.intervalId = setInterval(() => this.checkSessionStorage(), 500);
    }

    fetchLanguage(){
        const urlLang = this._getUrlLanguage();
        const raw = (urlLang || LANG || 'en').toLowerCase();
        this.varLanguage = raw.substring(0, 2);
        this.isLoading = false;
    }

    _getUrlLanguage() {
        try {
            const params = new URL(window.location.href).searchParams;
            return params.get('language');
        } catch {
            return null;
        }
    }

    renderedCallback() {
        const hostWrapper = this.template.querySelector('[data-id="hostWrapper"]');
        if (hostWrapper) {
            hostWrapper.style.setProperty('--custom-nav-width', this.navWidth);
        }
        if (this.scrollToFlow) {
            requestAnimationFrame(() => {
                const flowWrapper = this.template.querySelector('[data-id="flowWrapper"]');
                if (flowWrapper) {
                    const y = flowWrapper.getBoundingClientRect().top + window.pageYOffset - this.scrollToTopOffset;
                    window.scrollTo({ top: y, behavior: 'smooth' });
                }
                this.scrollToFlow = false;
            });
        }
    }

    disconnectedCallback() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }

    // ------------------------------
    // Master trigger polling
    // ------------------------------

    checkSessionStorage() {
        const allRaw = getAllStore();
        if (!allRaw) return;

        let trigger = false;

        try {
            if (Array.isArray(allRaw)) {
                // Legacy array of requests; pluck and migrate a matching entry
                const match = allRaw.find(r => r?.recordId === this.recordId);
                trigger = !!match;
                if (trigger) {
                    const map = getAllStore() || {};
                    const existing = (map && !Array.isArray(map)) ? map : {};
                    const updated = {
                        ...existing,
                        [this.recordId]: {
                            ...(existing[this.recordId] || {}),
                            formName: match.formName,
                            recordId: match.recordId,
                            parentObjectAPIName: match.parentObjectAPIName,
                            isMasterValidation: true
                        }
                    };
                    setAllStore(updated);
                    const remaining = allRaw.filter(r => r?.recordId !== this.recordId);
                    setAllStore(remaining);
                }
            } else if (typeof allRaw === 'object') {
                trigger = !!allRaw?.[this.recordId]?.isMasterValidation;
            }
        } catch {
            // ignore parse errors
        }

        if (trigger) {
            const rs = getRecordStore(this.recordId);
            const { formName, parentObjectAPIName } = rs || {};
            this.handleValidateForm(
                formName || this.formName,
                this.recordId,
                parentObjectAPIName || this.masterObject,
                this.sectionsToNotDisplay
            );
            ackMasterTrigger(this.recordId);
        }
    }

    // ------------------------------
    // Live / per-section validation (by **customLabel**)
    // ------------------------------
    handleValidationSpecificSection(customKey, { postMaster = false } = {}) {
        if (!customKey) return;
        if (!this._hasValidationsConfiguredForSection(customKey)) return;

        validationSection({
            recordId: this.recordId,
            formName: this.formDeveloperName,
            parentObjectAPIName: this.masterObject,
            // Apex expects "sectionName"; we provide our canonical customLabel
            sectionName: customKey
        })
        .then((results) => {
            const rs = getRecordStore(this.recordId);
            const uiSec = this._findSection(customKey);
            if (!uiSec) return;

            const parsed = JSON.parse(results);
            if (!parsed?.success) return;

            const hasErrors = parsed.hasErrors === true || parsed.isValid === false;
            const pages = Array.isArray(parsed.pages) ? parsed.pages : [];

            // Cache + persist LIVE snapshot
            this._setLiveErrors(customKey, pages, hasErrors);
            persistLiveValidationForSection(this.recordId, customKey, pages, hasErrors);

            // Icon behavior
            if (postMaster || rs?.masterValidatedAt) {
                // Master-style (error/success only)
                uiSec.hasValidationWarning = false;
                uiSec.hasValidationError = !!hasErrors;
                uiSec.hasValidationSuccess = !hasErrors && this.showNoValidationErrorsFound;

                // Cache + persist MASTER snapshot for this section
                this._setMasterErrorsForSection(customKey, hasErrors ? pages : [], hasErrors);
                upsertMasterSectionResult(this.recordId, customKey, hasErrors ? pages : [], hasErrors);
            } else {
                // Pre-master: warnings/success
                uiSec.hasValidationWarning = !!hasErrors;
                uiSec.hasValidationSuccess = !hasErrors && this.showNoValidationErrorsFound;
                uiSec.hasValidationError = false;
            }

            // Reactive refresh
            this.sections = [...this.sections];
        })
        .catch((error) => {
            this.showToast(this.label.validationToastTitle, reduceErrors(error).toString(), 'error');
        });
    }

    // ------------------------------
    // Master (full form) validation (keys by **customLabel**)
    // ------------------------------
    handleValidateForm(formName, recordId, parentObjectAPIName, sectionsToNotDisplay){
        this.masterValidationInProgress = true;
        validateForm({
            recordId : recordId,
            primaryObjectAPIName : parentObjectAPIName,
            formAPIName : formName,
            sectionsToNotDisplay: undefined !== sectionsToNotDisplay ? sectionsToNotDisplay : []
        })
        .then((results) => {
            const parsedResults = JSON.parse(results);
            if (parsedResults.success) {
                const serverSections = Array.isArray(parsedResults.sections) ? parsedResults.sections : [];

                // Compute which customLabels have errors
                const errorKeys = new Set();
                serverSections.forEach(sec => {
                    const pages = Array.isArray(sec.pages) ? sec.pages : [];
                    const hasAny = pages.some(p => Array.isArray(p?.errors) && p.errors.length > 0)
                                 || sec.hasErrors === true
                                 || sec.isValid === false;
                    const key = sec.customLabel || serverKey(sec) || sec.sectionName || sec.label;
                    if (key && hasAny) errorKeys.add(key);
                });

                // Apply icons by customLabel (suppress success if flag set to false)
                this.sections?.forEach(uiSec => {
                    uiSec.hasValidationWarning = false; // master suppresses warnings
                    const hasConfig = toBool(uiSec.hasConfiguredValidations);
                    if (!hasConfig) {
                        uiSec.hasValidationError = false;
                        uiSec.hasValidationSuccess = false;
                        return;
                    }
                    const key = uiSec.customLabel || uiKey(uiSec) || uiSec.label;
                    if (errorKeys.has(key)) {
                        uiSec.hasValidationError = true;
                        uiSec.hasValidationSuccess = false;
                    } else {
                        uiSec.hasValidationError = false;
                        uiSec.hasValidationSuccess = this.showNoValidationErrorsFound;
                    }
                });

                // Build master cache for the inline panel (keyed by customLabel)
                this._applyMasterErrorsFromPayload(serverSections);

                // Reactive refresh
                this.sections = [...(this.sections || [])];

                // Persist full master results + mark master timestamp
                setRecordStore(this.recordId, {
                    sections: serverSections,  // sections[].customLabel preferred; accept legacy fields too
                    partialValidations: {}     // clear live snapshots to avoid stale gating
                });
                suppressLiveValidationNow(this.recordId);
            }
        })
        .catch((error) => {
            this.showToast(this.label.validationToastTitle, reduceErrors(error).toString(), 'error');
        })
        .finally(() => {
            this.masterValidationInProgress = false;
        });
    }

    // ------------------------------
    // Form load
    // ------------------------------
    handleGetForm() {
        getForm({
            formAPIName: this.formName,
            sectionsToExclude: undefined !== this.sectionsToNotDisplay ? this.sectionsToNotDisplay : []
        })
        .then((results) => {
            const parsed = JSON.parse(results);
            if (!parsed.success) {
                this.showToast(this.label.formLoaderErrorToastTitle, parsed.message, 'error');
                return;
            }

            // Normalize UI sections; ensure canonical key
            this.sections = (parsed.sections || []).map(s => ({
                ...s,
                customLabel: s.customLabel || s.label, // ensure presence
                hasConfiguredValidations: toBool(s?.hasConfiguredValidations),
                hasValidationWarning: false,
                hasValidationError: false,
                hasValidationSuccess: false
            }));
            this.formDeveloperName = parsed.formDeveloperName;
            this.masterObject = parsed.masterObject;

            // Reset caches
            this._liveErrorsByKey = {};
            this._masterErrorsByKey = {};

            // Initialize store flags for children/gating
            setRecordStore(this.recordId, {
                liveValidation: !!this.liveValidation,
                showSectionValidationPanel: !!this.showSectionValidationPanel,
                partialValidations: {} // start fresh on load
            });

            // Seed UI from any existing storage (refresh-friendly)
            const rs = getRecordStore(this.recordId);

            // a) Seed master caches + icons if prior master results exist
            if (Array.isArray(rs?.sections) && rs.sections.length > 0) {
                this._applyMasterErrorsFromPayload(rs.sections);

                const errKeys = new Set();
                rs.sections.forEach(sec => {
                    const pages = Array.isArray(sec.pages) ? sec.pages : [];
                    const hasAny = pages.some(p => Array.isArray(p?.errors) && p.errors.length > 0)
                                 || sec.hasErrors === true
                                 || sec.isValid === false;
                    const key = sec.customLabel || serverKey(sec) || sec.sectionName || sec.label;
                    if (key && hasAny) errKeys.add(key);
                });

                this.sections?.forEach(uiSec => {
                    uiSec.hasValidationWarning = false;
                    if (!toBool(uiSec.hasConfiguredValidations)) {
                        uiSec.hasValidationError = false;
                        uiSec.hasValidationSuccess = false;
                        return;
                    }
                    const key = uiSec.customLabel || uiKey(uiSec) || uiSec.label;
                    if (errKeys.has(key)) {
                        uiSec.hasValidationError = true;
                        uiSec.hasValidationSuccess = false;
                    } else {
                        uiSec.hasValidationError = false;
                        uiSec.hasValidationSuccess = this.showNoValidationErrorsFound;
                    }
                });

                this.sections = [...this.sections];
            }

            // b) If no master, seed pre-master warning/success from partial live snapshots (keyed by customLabel)
            if (!rs?.masterValidatedAt && rs?.partialValidations && typeof rs.partialValidations === 'object') {
                Object.entries(rs.partialValidations).forEach(([key, entry]) => {
                    const uiSec = (this.sections || []).find(s => s.customLabel === key);
                    if (!uiSec) return;
                    if (!toBool(uiSec.hasConfiguredValidations)) return;

                    const hasErr = !!(entry?.hasErrors ||
                        ((entry?.pages || []).some(p => Array.isArray(p.errors) && p.errors.length > 0)));
                    uiSec.hasValidationWarning = hasErr;
                    uiSec.hasValidationSuccess = !hasErr && this.showNoValidationErrorsFound;
                    uiSec.hasValidationError = false;
                });
                this.sections = [...this.sections];
            }

            // Choose initial section
            const total = this.sections?.length ?? 0;
            if (total === 0) {
                this.isLoading = false;
                this.showToast(this.label.formLoaderErrorToastTitle, this.label.formLoaderErrorNoSections, 'warning');
                return;
            }
            const idx = Math.min(Math.max((this.defaultPage ?? 1) - 1, 0), Math.max(total - 1, 0));

            this.activeSectionId = this.sections[idx].id;
            this.flowAPIName = this.sections[idx].flow;

            // Persist current section (customLabel)
            this.sectionValidationHandling(this.sections[idx].customLabel);

            this.isLoading = false;
        })
        .catch((error) => {
            this.showToast(this.label.formLoaderErrorToastTitle, reduceErrors(error).toString(), 'error');
        });
    }

    // ------------------------------
    // State write (current section)
    // ------------------------------
    sectionValidationHandling(customKey){
        setRecordStore(this.recordId, { currentSectionKey: customKey });
    }

    // ------------------------------
    // Flow input vars
    // ------------------------------
    get inputVariables() {
        if (this.getLanguage){
            return [
                { name: 'recordId', type: 'String', value: this.recordId ?? '' },
                { name: 'varLanguage', type: 'String', value: this.varLanguage ?? 'en' }
            ];
        } else {
            return [
                { name: 'recordId', type: 'String', value: this.recordId ?? '' }
            ];
        }
    }

    // ------------------------------
    // Post/master & live nav-time revalidation
    // ------------------------------
    _maybeRevalidatePreviousOnNav(previousKey) {
        if (!previousKey) return;
        if (!this._hasValidationsConfiguredForSection(previousKey)) return;
        if (this.masterValidationInProgress) return;

        const rs = getRecordStore(this.recordId);
        const postMaster = !!rs?.masterValidatedAt;

        if (postMaster) {
            this.handleValidationSpecificSection(previousKey, { postMaster: true });
            return;
        }

        const liveSuppressed = !!rs?.suppressLiveValidation;
        if (this.liveValidation && !liveSuppressed) {
            this.handleValidationSpecificSection(previousKey, { postMaster: false });
        }
    }

    // ------------------------------
    // Navigation handlers (ensure flow restart)
    // ------------------------------
    handleChangeSection(event){
        this.loadFlow = true;

        const rs = getRecordStore(this.recordId);
        const previousKey = rs?.currentSectionKey;

        try {
            const d = (event && event.detail) ? event.detail : {};
            let sectionId = d.sectionId ?? d.id ?? null;
            let flowName  = d.flowName ?? d.flow ?? null;

            // Prefer id; fallback to customLabel/label/sectionName from event
            let target = sectionId
                ? (this.sections?.find(s => s.id === sectionId) || null)
                : null;

            if (!target && (d.customLabel || d.label || d.sectionName)) {
                target = this._findSection(d.customLabel || d.label || d.sectionName);
            }
            if (!target) {
                this.showToast(this.label.changeSectionErrorToastTitle, this.label.changeSectionErrorDescription, 'error');
                return;
            }
            if (!flowName) flowName = target.flow;

            // Switch to the new section
            this.activeSectionId = target.id;
            this.flowAPIName = flowName;

            // Revalidate the section we just left (pre- or post-master)
            this._maybeRevalidatePreviousOnNav(previousKey);

            // Persist new current section (customLabel)
            this.sectionValidationHandling(target.customLabel);

            // Render flow then explicitly start it
            setTimeout(() => {
                this.loadFlow = false;
                this.scrollToFlow = true;
                this._restartFlow();
            }, 50);

            // External check remains available
            this.checkSessionStorage();

        } catch (error) {
            this.showToast(this.label.changeSectionErrorToastTitle, reduceErrors(error).toString(), 'error');
        } finally {
            // Safety to ensure flow host unblocks in edge cases
            setTimeout(() => { this.loadFlow = false; }, 250);
        }
    }

    handleStatusChange(event){
        if (event.detail.status === "FINISHED"){
            const availableSections = this.sections;
            const currentIndex = availableSections.findIndex(section => section.id === this.activeSectionId);
            if (currentIndex !== -1 && currentIndex < availableSections.length - 1) {
                const rs = getRecordStore(this.recordId);
                const previousKey = rs?.currentSectionKey;

                const nextSection = availableSections[currentIndex + 1];
                this.loadFlow = true;
                this.activeSectionId = nextSection.id;
                this.flowAPIName = nextSection.flow;

                // Revalidate the section we just left (pre- or post-master)
                this._maybeRevalidatePreviousOnNav(previousKey);

                this.sectionValidationHandling(nextSection.customLabel);

                setTimeout(() => {
                    this.loadFlow = false;
                    this.scrollToFlow = true;
                    this._restartFlow();
                }, 50);

                this.checkSessionStorage();
            }
        }
    }

    // ------------------------------
    // Local helpers (thin wrappers / UI)
    // ------------------------------

    /** True/false: does this section have validations configured? */
    _hasValidationsConfiguredForSection(key) {
        const sec = this.sections?.find(s => s.customLabel === key);
        return !!(sec && toBool(sec.hasConfiguredValidations));
    }

    /** Resolve UI section by customLabel (preferred), then by id, then legacy label/sectionName. */
    _findSection(ref) {
        if (!ref) return null;
        let s = this.sections?.find(x => x.customLabel === ref);
        if (s) return s;
        s = this.sections?.find(x => x.id === ref);
        if (s) return s;
        // Legacy compatibility for external callers still passing label/sectionName
        s = this.sections?.find(x => x.label === ref || x.sectionName === ref);
        return s || null;
    }

    /** Explicitly restart the Flow (when name same but inputs/DOM changed). */
    _restartFlow() {
        requestAnimationFrame(() => {
            const flowEl = this.template.querySelector('lightning-flow');
            if (!flowEl) return;
            try {
                flowEl.startFlow(this.flowAPIName, this.inputVariables);
            } catch {
                // ignore if already started by lightning-flow
            }
        });
    }

    /** Replace the master cache from a server payload (keyed by customLabel). */
    _applyMasterErrorsFromPayload(serverSections) {
        const next = {};
        const seen = new Set();

        (serverSections || []).forEach(sec => {
            const key = sec.customLabel || serverKey(sec) || sec.sectionName || sec.label;
            if (!key) return;
            seen.add(key);

            const pages = Array.isArray(sec?.pages) ? sec.pages : [];
            const hasAny = pages.some(p => Array.isArray(p?.errors) && p.errors.length > 0)
                        || sec.hasErrors === true
                        || sec.isValid === false;

            next[key] = { hasErrors: !!hasAny, pages, ts: Date.now() };
        });

        (this.sections || []).forEach(ui => {
            const key = ui.customLabel || uiKey(ui) || ui.label;
            if (!toBool(ui?.hasConfiguredValidations)) return;
            if (!seen.has(key)) {
                next[key] = { hasErrors: false, pages: [], ts: Date.now() };
            }
        });

        this._masterErrorsByKey = next;
    }

    _setLiveErrors(customKey, pages, hasErrors) {
        this._liveErrorsByKey = {
            ...this._liveErrorsByKey,
            [customKey]: { hasErrors: !!hasErrors, pages: pages || [], ts: Date.now() }
        };
    }

    _setMasterErrorsForSection(customKey, pages, hasErrors) {
        this._masterErrorsByKey = {
            ...this._masterErrorsByKey,
            [customKey]: { hasErrors: !!hasErrors, pages: pages || [], ts: Date.now() }
        };
    }

    showToast(toastTitle, toastMessage, toastVariant){
       this.dispatchEvent(new ShowToastEvent({ title: toastTitle, message: toastMessage, variant: toastVariant }));
    }
}