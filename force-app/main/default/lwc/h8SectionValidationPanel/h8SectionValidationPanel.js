/**
 * @file
 * H8SectionValidationPanel.js
 *
 * A small, self-contained panel that displays validation results for a single form section.
 * It can show either:
 *  - **Master** (post full-form validation) results, or
 *  - **Live** (per-section/on-the-fly) results,
 * with **master** taking precedence when provided.
 *
 * Typical usage:
 * <c-h8-section-validation-panel
 *   default-open="true"
 *   auto-collapse-on-fix="true"
 *   live-has-errors={activeLiveHasErrors}
 *   live-pages={activeLivePages}
 *   master-has-errors={activeMasterHasErrors}
 *   master-pages={activeMasterPages}>
 * </c-h8-section-validation-panel>
 *
 * Display logic:
 * - If masterHasErrors is strictly true/false (i.e., defined), the panel renders **master** results.
 * - Otherwise, it renders **live** results.
 * - When `autoCollapseOnFix` is true, the panel automatically closes when errors transition
 *   from true -> false (i.e., when the issues are fixed).
 */

import { LightningElement, api, track } from 'lwc';
import labels from 'c/h8UtilLabels';

export default class H8SectionValidationPanel extends LightningElement {
    /** i18n bundle injected from shared utilities. */
    label = labels;

    // ------------------------------
    // Public API (text/labels)
    // ------------------------------

    /**
     * Help text displayed in the panel header or intro.
     * Defaults to labels.H8FFGeneralHelpText.
     * @type {string}
     */
    @api helpText = this.label.H8FFGeneralHelpText;

    /**
     * Label used above the list of items that are affected by validation errors.
     * Defaults to labels.H8FFAffectedQuestions.
     * @type {string}
     */
    @api affectTextLabel = this.label.H8FFAffectedQuestions;

    // ------------------------------
    // Public API (controls/behavior)
    // ------------------------------

    /**
     * If true, the panel is expanded on first render.
     * @type {boolean}
     * @default false
     */
    @api defaultOpen = false;

    /**
     * If true, panel will automatically collapse when errors transition from present -> none.
     * @type {boolean}
     * @default false
     */
    @api autoCollapseOnFix = false;

    // ------------------------------
    // Public API (live results)
    // ------------------------------

    /**
     * Live validation error flag (pre-master). Used when master is not provided.
     * @type {boolean}
     * @default false
     */
    @api liveHasErrors = false;

    /**
     * Live validation pages payload. Expected shape:
     *   [{ pageLabel: string, errors: [{ message: string, field?: string }] }]
     * When master is not provided, these pages are displayed.
     * @type {Array}
     * @default []
     */
    @api livePages = [];

    // ------------------------------
    // Public API (master results)
    // ------------------------------

    /**
     * Master validation error flag. When strictly true or false, master results take precedence.
     * If undefined, the component falls back to live results.
     * @type {boolean|undefined}
     */
    @api masterHasErrors;

    /**
     * Master validation pages payload. Same shape as livePages.
     * Displayed when masterHasErrors is strictly true/false.
     * @type {Array}
     * @default []
     */
    @api masterPages = [];

    // ------------------------------
    // Internal state
    // ------------------------------

    /**
     * Tracks whether the panel is currently open (expanded).
     * Initialized from `defaultOpen` on connectedCallback.
     * @type {boolean}
     * @reactive
     */
    @track isOpen;

    /**
     * Stores the previous computed hasErrors value to detect transitions
     * for auto-collapse behavior.
     * @type {boolean|undefined}
     * @private
     */
    _prevHasErrors = undefined;

    // ------------------------------
    // Lifecycle
    // ------------------------------

    /**
     * Initialize open/closed state from the public API.
     */
    connectedCallback() {
        this.isOpen = this.defaultOpen;
    }

    /**
     * After each render, if autoCollapseOnFix is enabled and we detect a change
     * from errors=true to errors=false, close the panel.
     */
    renderedCallback() {
        if (this.autoCollapseOnFix) {
            if (this._prevHasErrors === true && this.hasErrors === false) {
                this.isOpen = false;
            }
        }
        this._prevHasErrors = this.hasErrors;
    }

    // ------------------------------
    // Derived/computed model
    // ------------------------------

    /**
     * True when masterHasErrors is explicitly provided (strict boolean),
     * meaning master results should be used.
     * @returns {boolean}
     */
    get hasMaster() {
        return this.masterHasErrors === true || this.masterHasErrors === false;
    }

    /**
     * Effective error flag. Prefers master when available, otherwise falls back to live.
     * @returns {boolean}
     */
    get hasErrors() {
        return this.hasMaster ? this.masterHasErrors : this.liveHasErrors;
    }

    /**
     * Effective pages/errors to display. Prefers master when available, otherwise falls back to live.
     * Expected shape per page: { pageLabel: string, errors: Array<{ message: string, field?: string }> }
     * @returns {Array}
     */
    get pages() {
        return this.hasMaster ? (this.masterPages || []) : (this.livePages || []);
    }
}