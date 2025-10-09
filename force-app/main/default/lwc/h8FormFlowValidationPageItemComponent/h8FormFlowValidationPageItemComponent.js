/**
 * @file
 * H8FormFlowValidationPageItemComponent.js
 *
 * Renders a single page item within a validation results panel.
 * - Displays the page label and any associated error fields (handled in template).
 * - Hides itself when the "page" entry is a placeholder (`pageName === "NOPAGESCONFIGURED"`).
 *
 * Expected `page` shape (from Apex validation payload):
 * {
 *   pageName: string,
 *   pageLabel?: string,
 *   errors?: Array<{ message: string, field?: string }>
 * }
 *
 * Usage (in parent template):
 * <c-h8-form-flow-validation-page-item-component
 *   page={page}
 *   affect-text-label={label.affectedQuestionsText}>
 * </c-h8-form-flow-validation-page-item-component>
 *
 * @description       : js to support displaying pages and error fields
 * @autor             : daniel@hyphen8.com
 * @last modified on  : 09-09-2025
 * @last modified by  : daniel@hyphen8.com
 */

import { LightningElement, api } from 'lwc';
import labels from 'c/h8UtilLabels';

export default class H8FormFlowValidationPageItemComponent extends LightningElement {
    /** i18n bundle injected from shared utilities. */
    label = labels;

    // ------------------------------
    // Public API
    // ------------------------------

    /**
     * Page validation payload.
     * Example: { pageName: "Eligibility", errors: [{ message: "Field X required" }] }
     * @type {object}
     */
    @api page;

    /**
     * Label for the "affected questions" section shown beneath page errors.
     * Typically comes from shared labels (e.g., this.label.affectedQuestionsText).
     * @type {string}
     */
    @api affectTextLabel;

    // ------------------------------
    // Computed
    // ------------------------------

    /**
     * Whether to render this page entry.
     * Skips display when Apex returns a "NOPAGESCONFIGURED" placeholder.
     * @returns {boolean}
     */
    get displayPage() {
        return this.page.pageName !== 'NOPAGESCONFIGURED';
    }
}