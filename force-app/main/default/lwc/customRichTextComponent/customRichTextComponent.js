/**
 * @description       : custom rich text area component with word / character counter
 * @author            : daniel@hyphen8.com
 * @last modified on  : 12/07/2021
 * @last modified by  : daniel@hyphen8.com
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   06/07/2021   daniel@hyphen8.com   Initial Version
**/
import { LightningElement, api } from 'lwc';

import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

import characterLabelText from '@salesforce/label/c.CharacterCountText';
import wordCountLabelText from '@salesforce/label/c.WordCountText';

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
    @api maxWordCount;
    @api maxWordCountMessage;
    @api formats;
    @api displayCharacterCount = false;
    @api displayWordCount = false;
    @api requireFieldMessage;

    errorMessage;
    valid;

    labels = {
        characterLabelText,
        wordCountLabelText,
    }

    wordCountError;
    characterCountError;
    currentWordCount = 0;
    currentCharacterCount = 0;

    // rendered call back to support displaying the current count when navigating back and forward between screens
    renderedCallback() {
        this.currentWordCount = this.wordCount();
        this.currentCharacterCount = this.characterCount();
    }

    // default flow validation method
    // flow will automatically run this when you press next or previous on screen to ensure the content is valid
    @api validate() {
        let validInput = this.validateInput();
        return { isValid: validInput.isValid, errorMessage: validInput.errorMessage};
    }


    validateInput(){
        
        let valid = false;
        let customErrorMessage = '';

        if(this.displayWordCount){
            if(!this.wordCountError && !this.required){
                valid = true;
            } else if (this.wordCountError){
                valid = false;
                customErrorMessage = this.maxWordCountMessage;
            } else if(!this.wordCountError && this.required && this.value == undefined){
                valid = false;
                customErrorMessage = this.requireFieldMessage;
            } else {
                valid = true;
            }
        } else if(this.displayCharacterCount){
            if(!this.characterCountError && !this.required){
                valid = true;
            } else if (this.characterCountError){
                valid = false;
                customErrorMessage = this.maxCharacterCountMessage;
            } else if(!this.characterCountError && this.required && this.value == undefined){
                valid = false;
                customErrorMessage = this.requireFieldMessage;
            } else {
                valid = true;
            }
        }

        if(valid){
            this.valid = true;
            return {isValid: valid};
        } else {
            this.valid = false;
            this.errorMessage = customErrorMessage;
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
        let validateInput = this.validateInput(currentValue);
    }

    // get our wordCount for display
    wordCount(){
        try {
            if(this.displayWordCount){
                const regExEnd = new RegExp('</[^>]*>','gim');
                const regEx = new RegExp('<[^>]*>','gim');
                let newValue = this.value.replaceAll(regExEnd, ' ');
                newValue = newValue.replaceAll(regEx, ' ');
                let splitValue = newValue.split(' ');
                let joinValue = [];
                splitValue.forEach((item) => {
                    if (item.trim().length >= 1){
                        joinValue.push(item);
                    }
                });

                if(joinValue.length > this.maxWordCount){
                    this.wordCountError = true;
                    this.valid = false;
                } else {
                    this.wordCountError = false;
                    this.errorMessage = this.maxWordCountMessage;
                    this.valid = true;
                }

                return joinValue.length;
            } else {
                return 0;
            }
        } catch {
            this.wordCountError = false;
            return 0;
        }
    }

    // get our character count for display
    characterCount(){
        try {

            if(this.displayCharacterCount){
                if(this.value.length > this.maxCharacterCount){
                    this.characterCountError = true;
                    this.valid = false;
                } else {
                    this.characterCountError = false;
                    this.errorMessage = this.maxCharacterCountMessage;
                    this.valid = true;
                }
            }

            return this.value.length;
        } catch {
            return 0;
        }
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