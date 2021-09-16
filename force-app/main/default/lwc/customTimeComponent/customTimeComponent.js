/**
 * @description       : 
 * @author            : daniel@hyphen8.com
 * @last modified on  : 16/09/2021
 * @last modified by  : daniel@hyphen8.com
**/
import { LightningElement, api } from 'lwc';

import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class CustomTimeComponent extends LightningElement {

    @api value;
    @api label;
    @api required = false;
    @api disabled = false;
    @api minValue = '00:00:00.000Z';
    @api maxValue = '23:59:59.000Z';
    @api requiredMessage

    // default flow validation method
    // flow will automatically run this when you press next or previous on screen to ensure the content is valid
    @api validate() {
        let validInput = this.validateInput();
        return { isValid: validInput.isValid, errorMessage: validInput.errorMessage};
    }

    // simple method for setting custom validation message on the field
    setCustomValidityMessage(message){
        const timeInput = this.template.querySelector('.timeComponent');
        timeInput.setCustomValidity(message);
        timeInput.reportValidity();
    }

    // method that performs the actual validation on the field on screen
    validateInput(){
        
        let valid = false;
        let customErrorMessage = '';

        if(this.required && (this.value == null || this.value == undefined)){
            valid = false;
            customErrorMessage = this.requiredMessage;
        } else {
            valid = true;
        }
         
        if(valid){
            return {isValid: valid};
        } else {
            return {isValid: valid, errorMessage: customErrorMessage};
        }
    }


    // handles change of the input and validation
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


    // function for ensuring the value set within the component is available for assignment
    handleFlowChangeEvent(value) {
        const attributeChangeEvent = new FlowAttributeChangeEvent('value', value);
        this.dispatchEvent(attributeChangeEvent);
    }
    
}