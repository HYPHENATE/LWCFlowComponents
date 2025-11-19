/**
 * @description : Data Transfer Object (DTO) used to return validation results 
 *                from flow/form validation logic back to Aura or Flow components.
 *                Exposed via @AuraEnabled so it can be serialized automatically
 *                and consumed client-side.
 * 
 * Example JSON structure returned to the client:
 * {
 *   "validationFieldType": "RequiredField",
 *   "validationMessages": [
 *     "First Name is required",
 *     "Email must be valid"
 *   ]
 * }
 * 
 * Usage:
 * - Returned by Apex methods invoked in Flow/Aura that need to provide 
 *   field-specific validation messages.
 * - Allows the UI to easily render errors grouped by type/field.
 */
public class H8FlowFormFlowValidationResults {
    
    /** 
     * @description  The type/category of validation failure. 
     *               Typically matches a field type, validation rule, or error category 
     *               (e.g., "RequiredField", "RegexMismatch", "CustomRule").
     */
    @AuraEnabled public String validationFieldType { get; set; }

    /** 
     * @description  A list of validation error messages associated with this type. 
     *               Each string should describe a single issue that can be displayed 
     *               to the user in the UI. 
     *               Example: ["First Name is required", "Email must be valid"].
     */
    @AuraEnabled public List<String> validationMessages { get; set; }
}