/**
 * @description       : js for lightning-input component
 * @author            : daniel@hyphen8.com
 * @last modified on  : 14/08/2024
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

export default class H8LightningInputText extends LightningElement {
    
    @api label;
    @api placeholder;
    @api value;
    @api required;
    @api disabled;
    @api readOnly;
    @api fieldLevelHelp;
    @api maxLength;
    @api minLength;
    @api messageWhenValueMissing;
    @api messageWhenTooLong;
    @api messageWhenTooShort;
    @api showCharacterCount;
    @api variant;


    // getter to return the current count of charaters for the input field
    get characterCount(){
        return this.value != null ? this.value.length : 0;
    }

    get inputLabel(){
        if(!this.readOnly && !this.disabled){
            if(this.required){
                return this.label + ' (Required)';
            } else if(!this.required) {
                return this.label + ' (Optional)';
            }
        } else {
            return this.label;
        }
    }

    // default flow validation method
    // flow will automatically run this when you press next or previous on screen to ensure the content is valid
    @api validate() {
        let validInput = this.validateInput();
        return { isValid: validInput.isValid, errorMessage: validInput.errorMessage};
    }

    // simple method for setting custom validation message on the field
    setCustomValidityMessage(message){
        var textInput = this.template.querySelector(".customLightningInputText");
        textInput.setCustomValidity(message);
        textInput.reportValidity();

    }

    handleChangeValidation(event){
        let currentValue = event.target.value;
        this.value = currentValue;
        this.handleFlowChangeEvent(currentValue);
        let validateInput = this.validateInput();
        if(!validateInput.isValid){
            this.setCustomValidityMessage(validateInput.errorMessage);
        } else {
            this.setCustomValidityMessage('');
        }
    }

    // method that performs the actual validation on the field on screen
    validateInput(){

        let customErrorMessage = [];
        let valueAvailable = this.value != null && this.value != '' && this.value != undefined;
        if(this.required && !valueAvailable) {
            customErrorMessage.push(this.messageWhenValueMissing);
        }

        if(this.minLength > 0 && valueAvailable && this.value.length < this.minLength){
            customErrorMessage.push(this.messageWhenTooShort);
        }
        if(this.maxLength > 0 && valueAvailable && this.value.length > this.maxLength){
            customErrorMessage.push(this.messageWhenValueMissing);
        }
        
        let valid = customErrorMessage.length == 0;

        if(valid || this.readOnly){
            return {isValid: valid};
        } else {
            return {isValid: valid, errorMessage: customErrorMessage.join()};
        }
    }


    // function for ensuring the value set within the component is available for assignment
    handleFlowChangeEvent(value) {
        const attributeChangeEvent = new FlowAttributeChangeEvent('value', value);
        this.dispatchEvent(attributeChangeEvent);
    }
}