/**
 * @description       : custom rich text area component with word / character counter
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

export default class CustomRichTextComponent extends LightningElement {

    // configuration variables
    @api value;
    @api label;
    @api fieldLevelHelp;
    @api required;
    @api readOnly;
    @api disabled;
    @api labelVisible;
    @api placeholder;
    @api maxCharacterCount;
    @api maxCharacterCountMessage;
    @api minCharacterCount;
    @api minCharacterCountMessage;
    @api maxWordCount;
    @api maxWordCountMessage;
    @api minWordCount;
    @api minWordCountMessage;
    @api formats;
    @api displayCharacterCount = false;
    @api displayWordCount = false;
    @api requireFieldMessage;
    @api textAreaHeight;


    errorMessage;
    valid;

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
        this.resize();
    }

    resize(){
        var css = this.template.host.style;
        css.setProperty('--txt-size', this.textAreaHeight);
    }

    // default flow validation method
    // flow will automatically run this when you press next or previous on screen to ensure the content is valid
    @api validate() {
        let validInput = this.validateInput();
        return { isValid: validInput.isValid, errorMessage: validInput.errorMessage};
    }


    validateInput(){
        
        if(this.readOnly || this.disabled){
            this.valid = true;
            this.errorMessage = '';
            return {isValid: true};
        }

        const rawValue = this._safeValue();
        const trimmedValue = rawValue.trim();
        const isEmpty = trimmedValue.length === 0;

        if (this.required && isEmpty) {
            this.valid = false;
            this.errorMessage = this.requireFieldMessage;
            return {isValid: false, errorMessage: this.requireFieldMessage};
        }

        const wordCount = this._getWordCount();
        const characterCount = this._getCharacterCount();

        const maxWordCount = this._toOptionalInt(this.maxWordCount);
        const minWordCount = this._toOptionalInt(this.minWordCount);
        const maxCharacterCount = this._toOptionalInt(this.maxCharacterCount);
        const minCharacterCount = this._toOptionalInt(this.minCharacterCount);

        if (this.displayWordCount || maxWordCount != null || minWordCount != null) {
            if (maxWordCount != null && wordCount > maxWordCount) {
                this.wordCountError = true;
                this.minWordCountError = false;
                this.valid = false;
                this.errorMessage = this.maxWordCountMessage || `Maximum word count is ${maxWordCount}.`;
                return {isValid: false, errorMessage: this.errorMessage};
            }
            this.wordCountError = false;

            if (minWordCount != null && !isEmpty && wordCount < minWordCount) {
                this.minWordCountError = true;
                this.valid = false;
                this.errorMessage = this.minWordCountMessage || `Minimum word count is ${minWordCount}.`;
                return {isValid: false, errorMessage: this.errorMessage};
            }
            this.minWordCountError = false;
        }

        if (this.displayCharacterCount || maxCharacterCount != null || minCharacterCount != null) {
            if (maxCharacterCount != null && characterCount > maxCharacterCount) {
                this.characterCountError = true;
                this.minCharacterCountError = false;
                this.valid = false;
                this.errorMessage = this.maxCharacterCountMessage || `Maximum character count is ${maxCharacterCount}.`;
                return {isValid: false, errorMessage: this.errorMessage};
            }
            this.characterCountError = false;

            if (minCharacterCount != null && !isEmpty && characterCount < minCharacterCount) {
                this.minCharacterCountError = true;
                this.valid = false;
                this.errorMessage = this.minCharacterCountMessage || `Minimum character count is ${minCharacterCount}.`;
                return {isValid: false, errorMessage: this.errorMessage};
            }
            this.minCharacterCountError = false;
        }

        this.valid = true;
        this.errorMessage = '';
        return {isValid: true};
    }

    // handle any change within the rich text or text area component to support with displaying error messages
    handleChangeValidation(event){
        let currentValue = event.target.value;
        this.value = currentValue;
        this.handleFlowChangeEvent(currentValue);
        this.currentWordCount = this.wordCount();
        this.currentCharacterCount = this.characterCount();
        let validate = this.validateInput(currentValue);
    }

    // get our wordCount for display
    wordCount(){
        try {
            if(this.displayWordCount){
                const count = this._getWordCount();
                const maxWordCount = this._toOptionalInt(this.maxWordCount);
                const minWordCount = this._toOptionalInt(this.minWordCount);

                this.wordCountError = maxWordCount != null ? count > maxWordCount : false;
                this.minWordCountError = minWordCount != null ? (this._safeValue().trim().length > 0 && count < minWordCount) : false;
                return count;
            } else {
                return 0;
            }
        } catch {
            this.wordCountError = false;
            this.minWordCountError = false;
            return 0;
        }
    }

    // get our character count for display
    characterCount(){
        try {

            if(this.displayCharacterCount){
                const count = this._getCharacterCount();
                const maxCharacterCount = this._toOptionalInt(this.maxCharacterCount);
                const minCharacterCount = this._toOptionalInt(this.minCharacterCount);
                this.characterCountError = maxCharacterCount != null ? count > maxCharacterCount : false;
                this.minCharacterCountError = minCharacterCount != null ? (this._safeValue().trim().length > 0 && count < minCharacterCount) : false;
                return count;
            }

            return this._getCharacterCount();
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


    // get set formats or set defaults
    get customFormats(){
        try {
            let splitFormats = this.formats.split(',');
            return splitFormats;
        } catch {
            return ['font', 'size', 'bold', 'italic', 'underline', 'strike', 'list', 'indent', 'align', 'link', 'image', 'clean', 'table', 'header', 'color'];
        }
    }
    
    // function for ensuring the value set within the component is available for assignment
    handleFlowChangeEvent(value) {
        const attributeChangeEvent = new FlowAttributeChangeEvent('value', value);
        this.dispatchEvent(attributeChangeEvent);
    }
}
