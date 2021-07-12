/**
 * @description       : custom text area component with word / character counter javascript
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
    @api maxWordCount;
    @api maxWordCountMessage;
    @api displayCharacterCount = false;
    @api displayWordCount = false;
    @api requireFieldMessage;

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
                } else {
                    this.wordCountError = false;
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
                } else {
                    this.characterCountError = false;
                }
            }
            return this.value.length;
        } catch {
            return 0;
        }
    }
    
    // function for ensuring the value set within the component is available for assignment
    handleFlowChangeEvent(value) {
        const attributeChangeEvent = new FlowAttributeChangeEvent('value', value);
        this.dispatchEvent(attributeChangeEvent);
    }
}