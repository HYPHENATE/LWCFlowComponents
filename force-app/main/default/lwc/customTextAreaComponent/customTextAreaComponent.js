/**
 * @description       : custom text area component with word / character counter javascript
 * @author            : daniel@hyphen8.com
 * @last modified on  : 14-04-2026
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   06/07/2021   daniel@hyphen8.com   Initial Version
**/
import { LightningElement, api } from 'lwc';

import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

import characterLabelText from '@salesforce/label/c.CharacterCountText';
import wordCountLabelText from '@salesforce/label/c.WordCountText';
import minWordCharacterCountText from '@salesforce/label/c.MinWordCharacterCountText';

export default class CustomTextAreaComponent extends LightningElement {

    @api value;
    @api label;
    @api variant;
    @api required;
    @api readOnly;
    @api disabled;
    @api placeholder;
    @api fieldLevelHelp;

    @api maxCharacterCount;
    @api maxCharacterCountMessage;
    @api minCharacterCount;
    @api minCharacterCountMessage;
    @api maxWordCount;
    @api maxWordCountMessage;
    @api minWordCount;
    @api minWordCountMessage;
    @api displayCharacterCount = false;
    @api displayWordCount = false;
    @api requireFieldMessage;
    @api textAreaHeight = '40rem';

    labels = {
        characterLabelText,
        wordCountLabelText,
        minWordCharacterCountText,
    }

    wordCountError;
    characterCountError;
    minWordCountError;
    minCharacterCountError;
    currentWordCount = 0;
    currentCharacterCount = 0;

    // rendered call back to support displaying the current count when navigating back and forward between screens
    renderedCallback() {
        this.currentWordCount = this.wordCount();
        this.currentCharacterCount = this.characterCount();
        //this.resize();
    }

    // resize(){
    //     var css = this.template.host.style;
    //     css.setProperty('--txt-size', this.textAreaHeight);
    // }

    get textareaCssVars() {
    return this.textAreaHeight
        ? `--slds-c-textarea-sizing-min-height: ${this.textAreaHeight};`
        : '40rem';
    }

    // default flow validation method
    // flow will automatically run this when you press next or previous on screen to ensure the content is valid
    @api validate() {
        let validInput = this.validateInput();
        return { isValid: validInput.isValid, errorMessage: validInput.errorMessage};
    }

    // simple method for setting custom validation message on the field
    setCustomValidityMessage(message){
        var textArea = this.template.querySelector(".customTextArea");
        textArea.setCustomValidity(message);
        textArea.reportValidity();

    }

    // method that performs the actual validation on the field on screen
    validateInput(){
        
        let valid = false;
        let customErrorMessage = '';

        if(this.readOnly || this.disabled){
            return {isValid: true};
        }

        const rawValue = this._safeValue();
        const trimmedValue = rawValue.trim();
        const isEmpty = trimmedValue.length === 0;

        if (this.required && isEmpty) {
            return {isValid: false, errorMessage: this.requireFieldMessage};
        }

        const wordCount = this._getWordCount();
        const characterCount = this._getCharacterCount();

        const maxWordCount = this._toOptionalInt(this.maxWordCount);
        const minWordCount = this._toOptionalInt(this.minWordCount);
        const maxCharacterCount = this._toOptionalInt(this.maxCharacterCount);
        const minCharacterCount = this._toOptionalInt(this.minCharacterCount);

        // Word constraints apply if configured or if count is displayed.
        if (this.displayWordCount || maxWordCount != null || minWordCount != null) {
            if (maxWordCount != null && wordCount > maxWordCount) {
                this.wordCountError = true;
                customErrorMessage = this.maxWordCountMessage || `Maximum word count is ${maxWordCount}.`;
                return {isValid: false, errorMessage: customErrorMessage};
            }
            this.wordCountError = false;

            if (minWordCount != null && !isEmpty && wordCount < minWordCount) {
                this.minWordCountError = true;
                customErrorMessage = this.minWordCountMessage || `Minimum word count is ${minWordCount}.`;
                return {isValid: false, errorMessage: customErrorMessage};
            }
            this.minWordCountError = false;
        }

        // Character constraints apply if configured or if count is displayed.
        if (this.displayCharacterCount || maxCharacterCount != null || minCharacterCount != null) {
            if (maxCharacterCount != null && characterCount > maxCharacterCount) {
                this.characterCountError = true;
                customErrorMessage = this.maxCharacterCountMessage || `Maximum character count is ${maxCharacterCount}.`;
                return {isValid: false, errorMessage: customErrorMessage};
            }
            this.characterCountError = false;

            if (minCharacterCount != null && !isEmpty && characterCount < minCharacterCount) {
                this.minCharacterCountError = true;
                customErrorMessage = this.minCharacterCountMessage || `Minimum character count is ${minCharacterCount}.`;
                return {isValid: false, errorMessage: customErrorMessage};
            }
            this.minCharacterCountError = false;
        }

        valid = true;

        if(valid){
            return {isValid: valid};
        } else {
            return {isValid: valid, errorMessage: customErrorMessage};
        }
    }

    // handle any change within the rich text or text area component to support with displaying error messages
    handleChangeValidation(event){
        let currentValue = event.target.value;
        this.value = currentValue;
        this.handleFlowChangeEvent(currentValue);
        this.currentWordCount = this.wordCount();
        this.currentCharacterCount = this.characterCount();
        let validateInput = this.validateInput();
        if(!validateInput.isValid){
            this.setCustomValidityMessage(validateInput.errorMessage);
        } else {
            this.setCustomValidityMessage('');
        }
    }

    // get our wordCount for display
    wordCount(){
        try {
            if(!this.displayWordCount){
                return 0;
            }

            const count = this._getWordCount();
            const maxWordCount = this._toOptionalInt(this.maxWordCount);
            const minWordCount = this._toOptionalInt(this.minWordCount);

            this.wordCountError = maxWordCount != null ? count > maxWordCount : false;
            this.minWordCountError = minWordCount != null ? (this._safeValue().trim().length > 0 && count < minWordCount) : false;

            return count;
        } catch {
            this.wordCountError = false;
            this.minWordCountError = false;
            return 0;
        }
    }

    // get our character count for display
    characterCount(){
        try {
            const count = this._getCharacterCount();
            if(this.displayCharacterCount){
                const maxCharacterCount = this._toOptionalInt(this.maxCharacterCount);
                const minCharacterCount = this._toOptionalInt(this.minCharacterCount);
                this.characterCountError = maxCharacterCount != null ? count > maxCharacterCount : false;
                this.minCharacterCountError = minCharacterCount != null ? (this._safeValue().trim().length > 0 && count < minCharacterCount) : false;
            }
            return count;
        } catch {
            return 0;
        }
    }

    _safeValue() {
        return this.value == null ? '' : String(this.value);
    }

    _getCharacterCount() {
        return this._safeValue().length;
    }

    _getWordCount() {
        const text = this._safeValue()
            .replace(/<[^>]*>/gim, ' ')
            .replace(/\s+/g, ' ')
            .trim();

        if (!text) {
            return 0;
        }

        return text.split(' ').filter((w) => w.trim().length > 0).length;
    }

    _toOptionalInt(value) {
        if (value === null || value === undefined || value === '') {
            return null;
        }
        const parsed = parseInt(value, 10);
        return Number.isFinite(parsed) ? parsed : null;
    }
    
    // function for ensuring the value set within the component is available for assignment
    handleFlowChangeEvent(value) {
        const attributeChangeEvent = new FlowAttributeChangeEvent('value', value);
        this.dispatchEvent(attributeChangeEvent);
    }
}
